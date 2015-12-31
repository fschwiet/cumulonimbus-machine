#
# Cookbook Name:: mynginx
# Recipe:: default
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx"

default404conf =<<__EOL__

server {
    listen      80 default_server;
    server_name _;
    return      404;
}

__EOL__

file '/etc/nginx/conf.d/default404.conf' do
  content default404conf
  ## can we notify nginx?  notifies :restart, 'mysql_service[default]'
  action :create
end