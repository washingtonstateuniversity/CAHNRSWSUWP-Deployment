<?php

namespace WSUWP\Deployment;

add_action( 'wsuwp_run_scheduled_deployment', 'WSUWP\Deployment\run_scheduled_deployment', 10, 5 );
add_filter( 'http_request_args', 'WSUWP\Deployment\filter_authorization_header', 10, 2 );

/**
 * Run a scheduled deployment of a public repository using the arguments
 * stored when the schedule was set.
 *
 * @since 3.0.0
 *
 * @param string $tag         The version of the package being deployed (x.y.z).
 * @param string $directory   The directory name the package should be installed under.
 * @param string $url         The URL from which to download the package.
 * @param string $deploy_type Type of deployment. Currently supported: theme-individual,
 *                            plugin-individual, mu-plugin-individual
 * @param string $sender      The GitHub user who tagged the release.
 */
function run_scheduled_deployment( $tag, $directory, $url, $deploy_type, $sender ) {

	if ( ! in_array( $deploy_type, array(
		'theme-individual',
		'plugin-individual',
		'mu-plugin-individual',
		'build-plugins-public',
		'build-plugins-private',
		'build-themes-public',
		'platform',
	), true ) ) {
		return;
	}

	// Load file and upgrade management files from WordPress core.
	require_once ABSPATH . 'wp-admin/includes/file.php';
	require_once ABSPATH . 'wp-admin/includes/plugin-install.php';
	require_once ABSPATH . 'wp-admin/includes/class-wp-upgrader.php';
	require_once ABSPATH . 'wp-admin/includes/plugin.php';

	// Start up the WP filesystem global, required by things like unzip_file().
	WP_Filesystem();

	$temp_file = download_url( $url );

	if ( is_wp_error( $temp_file ) ) {
		send_slack_notification( $temp_file->get_error_message() );
		return;
	}

	$deploy_file = WP_CONTENT_DIR . '/uploads/deploys/' . $tag . '.zip';

	// use copy and unlink because rename breaks streams.
	$move_new_file = @ copy( $temp_file, $deploy_file ); // @codingStandardsIgnoreLine
	@ unlink( $temp_file ); // @codingStandardsIgnoreLine

	if ( false === $move_new_file ) {
		send_slack_notification( 'Unable to move ' . $deploy_file );
		return;
	}

	$unzip_result = unzip_file( $deploy_file, WP_CONTENT_DIR . '/uploads/deploys' );

	if ( is_wp_error( $unzip_result ) ) {
		send_slack_notification( $unzip_result->get_error_message() );
		return;
	}

	if ( 'plugin-individual' === $deploy_type ) {
		$destination = 'plugins/' . $directory;
	} elseif ( 'theme-individual' === $deploy_type ) {
		$destination = 'themes/' . $directory;
	} elseif ( 'mu-plugin-individual' === $deploy_type ) {
		$destination = 'mu-plugins/' . $directory;
	} elseif ( 'build-plugins-public' === $deploy_type || 'build-plugins-private' === $deploy_type ) {
		$destination = 'build-plugins/' . $directory;
	} elseif ( 'build-themes-public' === $deploy_type ) {
		$destination = 'build-themes/' . $directory;
	} elseif ( 'platform' === $deploy_type ) {
		$destination = 'platform/' . $directory;
	} else {
		send_slack_notification( 'Unsupported deploy attempt.' );
		return;
	}

	// Given a URL like https://github.com/washingtonstateuniversity/WSUWP-spine-parent-theme/archive/0.27.16.zip
	// Determine a directory name like WSUWP-spine-parent-theme-0.27.16
	$url_pieces = explode( '/', $url );
	$unzipped_directory = $url_pieces[4] . '-' . $tag;

	$skin = new \Automatic_Upgrader_Skin();
	$upgrader = new \WP_Upgrader( $skin );

	// "Install" the package to a shadow directory to be looped through by an external script.
	$install_result = $upgrader->install_package( array(
		'source' => WP_CONTENT_DIR . '/uploads/deploys/' . $unzipped_directory,
		'destination' => WP_CONTENT_DIR . '/uploads/deploys/' . $destination,
		'clear_destination' => true,
		'clear_working' => true,
		'abort_if_destination_exists' => true,
	) );

	if ( is_wp_error( $install_result ) ) {
		send_slack_notification( $install_result->get_error_message() );
		return;
	}

	$message = 'Version ' . $tag . ' of ' . $directory . ' has been staged for deployment on ' . gethostname() . ' by ' . $sender . '.';
	send_slack_notification( $message );
}

/**
 * Filter the headers used to download a zip file from GitHub to include
 * our authentication token when necessary.
 *
 * @since 3.0.0
 *
 * @param array  $request An array of HTTP request arguments.
 * @param string $url     The request URL.
 *
 * @return array Modified array of HTTP request arguments.
 */
function filter_authorization_header( $request, $url ) {
	if ( ! defined( 'WSUWP_PRIVATE_DEPLOY_TOKEN' ) ) {
		return $request;
	}

	$url = strtolower( $url );

	// Whitelist individual private repositories.
	if ( 0 === strpos( $url, 'https://github.com/washingtonstateuniversity/wsuwp-build-plugins-private' ) ) {
		$request['headers']['Authorization'] = 'token ' . WSUWP_PRIVATE_DEPLOY_TOKEN;
	} elseif ( 0 === strpos( $url, 'https://github.com/washingtonstateuniversity/wsuwp-plugin-sso-authentication' ) ) {
		$request['headers']['Authorization'] = 'token ' . WSUWP_PRIVATE_DEPLOY_TOKEN;
	} elseif ( 0 === strpos( $url, 'https://github.com/washingtonstateuniversity/wsuwp-plugin-secrets' ) ) {
		$request['headers']['Authorization'] = 'token ' . WSUWP_PRIVATE_DEPLOY_TOKEN;
	}

	return $request;
}

/**
 * Send a notification to the WSU Web Slack.
 *
 * @since 3.0.0
 *
 * @param string $message
 */
function send_slack_notification( $message ) {
	$payload_json = wp_json_encode( array(
		'channel'      => '#webadmin',
		'username'     => 'cahnrswsuwp-deployment',
		'text'         => esc_js( $message ),
		'icon_emoji'   => ':rocket:',
	) );

	wp_remote_post( 'https://hooks.slack.com/services/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', array(
		'body'       => $payload_json,
		'headers' => array(
			'Content-Type' => 'application/json',
		),
	) );
}
