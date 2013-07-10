#
# Cookbook Name:: pgbouncer_test
# Recipe:: default
#
# Copyright (C) 2013 Mathieu Sauve-Frankel
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


node.set['postgresql']['password']['postgres'] = 'badpassword'

include_recipe "postgresql::server"
include_recipe "postgresql::ruby"

pg_conn = {:host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']}

postgresql_database_user "test" do
  connection pg_conn
  password "reallybadpassword"
  action :create
end

postgresql_database "pgbouncer_test" do
  connection pg_conn
  owner "test"
  action :create
end

node.set["pgbouncer"]["auth_type"] = "md5"
node.set["pgbouncer"]["databases"] = {
  "pgbouncer_test" => "host=localhost port=5432"
}

node.set["pgbouncer"]["userlist"] = {
  "test" => "md5f3f52c3e700834c4b35f221c560ff276"
}

include_recipe "pgbouncer"
