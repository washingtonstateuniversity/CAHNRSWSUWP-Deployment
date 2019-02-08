#!/bin/bash
#
# Process staged deployments on a cron schedule.

cd [wp-content-path]/uploads/deploys

if [ ! -z "$(ls -A themes)" ]; then
   for theme in `ls -d themes/*/`
   do
     find "[wp-content-path]/uploads/deploys/$theme" -type d -exec chmod 775 {} \;
     find "[wp-content-path]/uploads/deploys/$theme" -type f -exec chmod 664 {} \;

     mkdir -p "[wp-content-path]/$theme"

     rsync -rgvzh --delete --exclude '.git' "[wp-content-path]/uploads/deploys/$theme" "[wp-content-path]/$theme"

     chown -R webadmin:webadmin "[wp-content-path]/$theme"

     rm -rf "[wp-content-path]/uploads/deploys/$theme"

     slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$theme deployed\", \"icon_emoji\": \":rocket:\"}'"
     slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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e"
     eval $slack_command
   done
fi

cd [wp-content-path]/uploads/deploys

if [ ! -z "$(ls -A plugins)" ]; then
  for plugin in `ls -d plugins/*/`
  do
    find "[wp-content-path]/uploads/deploys/$plugin" -type d -exec chmod 775 {} \;
    find "[wp-content-path]/uploads/deploys/$plugin" -type f -exec chmod 664 {} \;

    mkdir -p "[wp-content-path]/$plugin"

    rsync -rgvzh --delete --exclude '.git' "[wp-content-path]/uploads/deploys/$plugin" "[wp-content-path]/$plugin"

    chown -R webadmin:webadmin "[wp-content-path]/$plugin"

    rm -rf "[wp-content-path]/uploads/deploys/$plugin"

    slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$plugin deployed\", \"icon_emoji\": \":rocket:\"}'"
    slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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e"
    eval $slack_command
  done
fi

cd [wp-content-path]/uploads/deploys

if [ ! -z "$(ls -A mu-plugins)" ]; then
  for muplugin in `ls -d mu-plugins/*/`
  do
    find "[wp-content-path]/uploads/deploys/$muplugin" -type d -exec chmod 775 {} \;
    find "[wp-content-path]/uploads/deploys/$muplugin" -type f -exec chmod 664 {} \;

    mkdir -p "[wp-content-path]/$muplugin"

    rsync -rgvzh --delete --exclude '.git' "[wp-content-path]/uploads/deploys/$muplugin" "[wp-content-path]/$muplugin"

    chown -R webadmin:webadmin "[wp-content-path]/$muplugin"

    rm -rf "[wp-content-path]/uploads/deploys/$muplugin"

    slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$muplugin deployed\", \"icon_emoji\": \":rocket:\"}'"
    slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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e"
    eval $slack_command
  done
fi

if [ ! -z "$(ls -A build-plugins)" ]; then
  for plugin in `ls -d build-plugins/public-plugins-build/*/ | sed "s/build-plugins\/public-plugins-build\///g"`
  do
    find "[wp-content-path]/uploads/deploys/build-plugins/public-plugins-build/$plugin" -type d -exec chmod 775 {} \;
    find "[wp-content-path]/uploads/deploys/build-plugins/public-plugins-build/$plugin" -type f -exec chmod 664 {} \;

    mkdir -p "[wp-content-path]/plugins/$plugin"

    rsync -rgvzh --delete --exclude '.git' "[wp-content-path]/uploads/deploys/build-plugins/public-plugins-build/$plugin" "[wp-content-path]/plugins/$plugin"

    chown -R webadmin:webadmin "[wp-content-path]/plugins/$plugin"

    rm -rf "[wp-content-path]/uploads/deploys/build-plugins/public-plugins-build/$plugin"
  done

  for plugin in `ls -d build-plugins/private-plugins-build/*/ | sed "s/build-plugins\/private-plugins-build\///g"`
  do
    find "[wp-content-path]/uploads/deploys/build-plugins/private-plugins-build/$plugin" -type d -exec chmod 775 {} \;
    find "[wp-content-path]/uploads/deploys/build-plugins/private-plugins-build/$plugin" -type f -exec chmod 664 {} \;

    mkdir -p "[wp-content-path]/plugins/$plugin"

    rsync -rgvzh --delete --exclude '.git' "[wp-content-path]/uploads/deploys/build-plugins/private-plugins-build/$plugin" "[wp-content-path]/plugins/$plugin"

    chown -R webadmin:webadmin "[wp-content-path]/plugins/$plugin"

    rm -rf "[wp-content-path]/uploads/deploys/build-plugins/private-plugins-build/$plugin"
  done

  rm -rf "[wp-content-path]/uploads/deploys/build-plugins/private-plugins-build"
  rm -rf "[wp-content-path]/uploads/deploys/build-plugins/public-plugins-build"

  slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"public and private build plugins deployed\", \"icon_emoji\": \":rocket:\"}'"
  slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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e"
  eval $slack_command
fi

if [ ! -z "$(ls -A build-themes)" ]; then
  for theme in `ls -d build-themes/public-themes-build/*/ | sed "s/build-themes\/public-themes-build\///g"`
  do
    find "[wp-content-path]/uploads/deploys/build-themes/public-themes-build/$theme" -type d -exec chmod 775 {} \;
    find "[wp-content-path]/uploads/deploys/build-themes/public-themes-build/$theme" -type f -exec chmod 664 {} \;

    mkdir -p "[wp-content-path]/themes/$theme"

    rsync -rgvzh --delete --exclude '.git' "[wp-content-path]/uploads/deploys/build-themes/public-themes-build/$theme" "[wp-content-path]/themes/$theme"

    chown -R webadmin:webadmin "[wp-content-path]/themes/$theme"

    rm -rf "[wp-content-path]/uploads/deploys/build-themes/public-themes-build/$theme"
  done

  rm -rf "[wp-content-path]/uploads/deploys/build-themes/public-themes-build"

  slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"public theme collection deployed\", \"icon_emoji\": \":rocket:\"}'"
  slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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e"
  eval $slack_command
fi

if [ ! -z "$(ls -A platform)" ]; then
  find "[wp-content-path]/uploads/deploys/platform/wsuwp-platform/" -type d -exec chmod 775 {} \;
  find "[wp-content-path]/uploads/deploys/platform/wsuwp-platform/" -type f -exec chmod 664 {} \;

  rsync -rgvzh --delete [wp-content-path]/uploads/deploys/platform/wsuwp-platform/www/wordpress/ /var/www/wordpress/

  cp -f [wp-content-path]/uploads/deploys/platform/wsuwp-platform/www/wp-content/*.php [wp-content-path]/
  cp -f [wp-content-path]/uploads/deploys/platform/wsuwp-platform/www/wp-content/mu-plugins/*.php [wp-content-path]/mu-plugins/

  chown -R webadmin:webadmin /var/www/wordpress/
  chown -R webadmin:webadmin [wp-content-path]/*.php
  chown -R webadmin:webadmin [wp-content-path]/mu-plugins/*.php

  rm -rf "[wp-content-path]/uploads/deploys/platform/wsuwp-platform"

  slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"platform/wsuwp-platform deployed\", \"icon_emoji\": \":rocket:\"}'"
  slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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e"
eval $slack_command
fi

# Remove all previously deployed zip files.
rm [wp-content-path]/uploads/deploys/*.zip
