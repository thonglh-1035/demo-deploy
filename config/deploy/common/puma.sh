#!/bin/bash
APP_ROOT=/home/ec2-user/rails_app/demo-deploy/current
# rvm use 2.3.1
# source ~/.bashrc
cd $APP_ROOT
bundle exec puma -C $APP_ROOT/config/puma.rb
