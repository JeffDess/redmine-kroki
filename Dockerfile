ARG TAG=6-alpine

FROM redmine:${TAG}

ARG THEME_PATH
ADD https://github.com/martin-svoboda/bs-redmine-theme-dark.git \
  $THEME_PATH/dark_theme/

ARG PLUGIN_PATH=/usr/src/redmine/plugins
ADD https://github.com/haru/redmine_theme_changer.git#0.7.0 \
  $PLUGIN_PATH/redmine_theme_changer/
