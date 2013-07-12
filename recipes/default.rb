#
# Cookbook Name:: pgbouncer
# Recipe:: default
# Author:: Christoph Krybus <ckrybus@googlemail.com>
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
#
# Copyright 2011, Christoph Krybus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

pgb_user = node['pgbouncer']['user']

package "pgbouncer" do
  action :install
end

# EL rpms don't create this directory automatically
directory "/etc/pgbouncer" do
  owner pgb_user
  group pgb_user
  mode  "774"
end

template node[:pgbouncer][:initfile] do
  source "pgbouncer.ini.erb"
  owner "root"
  group pgb_user
  mode "664"
  notifies :restart, "service[pgbouncer]"
end

template node[:pgbouncer][:additional_config_file] do
  source "pgbouncer.default.erb"
  owner pgb_user
  group pgb_user
  mode "664"
  notifies :restart, "service[pgbouncer]"
end

template "/etc/pgbouncer/userlist.txt" do
  source "userlist.txt.erb"
  owner pgb_user
  group pgb_user
  mode  "0600"
  notifies :restart, "service[pgbouncer]"
end

include_recipe "runit"

execute "stop init script" do
  command "/etc/init.d/pgbouncer stop"
  only_if { ::File.exist? "/etc/init.d/pgbouncer" }
  only_if "/etc/init.d/pgbouncer status | grep 'pgbouncer is running'"
  not_if { ::File.symlink? "/etc/init.d/pgbouncer" }
  notifies :run, "execute[remove pgbouncer init script]", :immediately
end

execute "remove pgbouncer init script" do
  command "rm /etc/init.d/pgbouncer"
  notifies :run, "execute[remove pgbouncer rc.d links]", :immediately
  action :nothing
end

execute "remove pgbouncer rc.d links" do
  command "update-rc.d -f pgbouncer remove"
  action :nothing
end


runit_service "pgbouncer" do
  action [ :enable, :start ]
  log true
  default_logger true
end
