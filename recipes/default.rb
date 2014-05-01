#
# Cookbook Name:: rails-unicorn-nginx
# Recipe:: default
#
# Copyright (C) 2014 Andre Mosin
#
# All rights reserved - Do Not Redistribute
#

user node['rails-unicorn-nginx']['user'] do
  comment "Deployer"
  shell "/bin/bash"
end

# setup ssh keys
["/home/#{node['rails-unicorn-nginx']['user']}","/home/#{node['rails-unicorn-nginx']['user']}/.ssh"].each do |path|
  directory path do
  owner node['rails-unicorn-nginx']['user']
  group node['rails-unicorn-nginx']['group']
  mode "0700"
  recursive true
  action :create
  end
end


file "/home/#{node['rails-unicorn-nginx']['user']}/.ssh/id_rsa" do
  owner node['rails-unicorn-nginx']['user']
  group node['rails-unicorn-nginx']['group']
  mode "0600"
  content node['rails-unicorn-nginx']['private_key']
  action :create
end

file "/home/deploy/.ssh/id_rsa.pub" do
  owner node['rails-unicorn-nginx']['user']
  group node['rails-unicorn-nginx']['group']
  mode "0600"
  content node['rails-unicorn-nginx']['public_key']
  action :create
end
file "/home/deploy/.ssh/known_hosts" do
  owner node['rails-unicorn-nginx']['user']
  group node['rails-unicorn-nginx']['group']
  mode "0600"
  content node['rails-unicorn-nginx']['known_hosts']
  action :create
end

package "libmysqlclient-dev" do
	action :install
end

include_recipe 'apt'
include_recipe 'nginx'


["/var/www","/var/www/#{node['rails-unicorn-nginx']['appname']}","/var/www/#{node['rails-unicorn-nginx']['appname']}/shared"].each do |path|
  directory path do
  owner node['rails-unicorn-nginx']['user']
  group node['rails-unicorn-nginx']['group']
  action :create
  end
end

template "/var/www/#{node['rails-unicorn-nginx']['appname']}/shared/nginx.conf" do
	source "nginx.erb"
end

link "/etc/nginx/sites-enabled/default" do
  to "/var/www/#{node['rails-unicorn-nginx']['appname']}/shared/nginx.conf"
end


include_recipe "rvm::system"
include_recipe "rvm::vagrant"

gem_package "bundler" do
	options "--no-ri --no-rdoc"
	action :install
end


git	node['rails-unicorn-nginx']['app_root'] do
	repository node['rails-unicorn-nginx']['gitrepo']
	reference "master"
    user node['rails-unicorn-nginx']['user']
    group node['rails-unicorn-nginx']['group']
    action :sync
end

execute 'bundle install --without development' do
  cwd node['rails-unicorn-nginx']['app_root']
  not_if 'bundle check' # This is not run inside /myapp
  user 'deploy'
end

execute 'bundle install --binstubs' do
  cwd node['rails-unicorn-nginx']['app_root']
  not_if 'bundle check' # This is not run inside /myapp
  user 'deploy'
end

execute 'rake db:migrate RAILS_ENV=production' do
  cwd node['rails-unicorn-nginx']['app_root']
  not_if 'bundle check' # This is not run inside /myapp
  user 'deploy'
end

template "/var/www/#{node['rails-unicorn-nginx']['appname']}/shared/unicorn.rb" do
	source "unicorn.erb"
end

template "/etc/init.d/unicorn" do
	source "unicorn_init.sh.erb"
	owner "root"
	group "root"
	mode "0755"
end

execute 'service unicorn restart' do
end
