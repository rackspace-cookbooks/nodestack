nodestack Cookbook
==================
This cookbook deploys a NodeJS applitcation stack.

Requirements
------------

#### cookbooks
```text
apt
mysql
mysql-multi
database
chef-sugar
apt
mysql
database
chef-sugar
elasticsearch
apache2, ~> 1.10
memcached
openssl
redisio
varnish
rackspace_gluster
platformstack
mongodb
build-essential
java
yum
git
nodejs
ssh_known_hosts
application
application_nodejs
firewall
```

Attributes
----------

`node['nodestack']['apps']['my_nodejs_app']['app_dir']` path where the application will be deployed
`node['nodestack']['apps']['my_nodejs_app']['app_user']` OS user that will be used to run the app
`node['nodestack']['apps']['my_nodejs_app']['git_repo']` Git repository where the code lives.
`node['nodestack']['apps']['my_nodejs_app']['entry_point']` the .js file that will be ran as the server.
`node['nodestack']['apps']['my_nodejs_app']['rev']` Code revision that should be used. Example: HEAD
`node['nodestack']['apps']['my_nodejs_app']['deploy_key']` SSH key to pull the code from the git repo. You don't need this if you use https instead of git.
`node['nodestack']['apps']['my_nodejs_app']['http_port']` HTTP port for the NodeJS app
`node['nodestack']['apps']['my_nodejs_app']['https_port']` HTTPS port for the NodeJS app
`node['nodestack']['apps']['my_nodejs_app']['mysql_app_user_password']` Password for the mysql user. The user is named after `node['nodestack']['apps']['my_nodejs_app']['app_user']`


Usage
-----
To deploy a app node these is how a `nodejs_app` role would look like:
```text
$ knife role show nodejs_app
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_app
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::rack_user]
  recipe[nodestack::default]
```

To deploy a app node these is how a `nodejs_mysql` role would look like:
```text
$ knife role show nodejs_mysql
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mysql
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::rack_user]
  recipe[nodestack::mysql_base]
```

These are the minimum environment variables that would be needed:
```text
$ knife environment show nodejs
chef_type:           environment
cookbook_versions:
default_attributes:
description:
json_class:          Chef::Environment
name:                nodejs
override_attributes:
  mysql:
    server_root_password: randompass
  nodestack:
    app_name: beer_survey
    git_repo: https://github.com/jrperritt/beer-survey.git
  platformstack:
    cloud_backup:
      enabled: false
    cloud_monitoring:
      enabled: false
  rackspace:
    cloud_credentials:
      api_key:  xxx
      username: xxx
```

Contributing
------------
* See the guide [here](https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md)

License and Authors
-------------------
- Author:: Marco A Morales (marco.morales@rackspace.com)
- Author:: Martin Smith (martin.smith@rackspace.com)

```text
Copyright 2014, Rackspace, US Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
