
default['rails-unicorn-nginx']['appname'] = ''
default['rails-unicorn-nginx']['gitrepo'] = ''

default['nginx']['worker_processes'] = '2'
default['nginx']['worker_connections'] = '2048'
default['nginx']['worker_rlimit_nofile'] = '32096'


default['rails-unicorn-nginx']['user'] = 'deploy'
default['rails-unicorn-nginx']['group'] = 'deploy'

default['rails-unicorn-nginx']['app_root'] = "/var/www/#{node['rails-unicorn-nginx']['appname']}/current"

default['rvm']['default_ruby'] = "ruby-1.9.3-p545"
default['rvm']['vagrant']['system_chef_client'] = "/opt/chef/bin/chef-client"
default['rvm']['vagrant']['system_chef_solo'] = "/opt/chef/bin/chef-solo"