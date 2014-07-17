nodestack Cookbook
==================
This cookbook deploys a NodeJS applitcation stack.

The NodeJS app will be deployed using [forever](https://github.com/nodejitsu/forever) to keep the app running in case it crashes, but we actually use init/upstart scripts to call forever and start/stop the NodeJS app.

Requirements
------------

#### cookbooks
- apt
- mysql
- mysql-multi
- database
- chef-sugar
- apt
- mysql
- database
- chef-sugar
- elasticsearch
- apache2, ~> 1.10
- memcached
- openssl
- redisio
- varnish
- rackspace_gluster
- platformstack
- mongodb
- build-essential
- java
- yum
- git
- nodejs
- ssh_known_hosts
- application


Attributes
----------

####Note: the 'my_nodejs_app' defines the name of the app, please change this to something more relevant to the customer.

`node['nodestack']['apps']['my_nodejs_app']['app_dir']` path where the application will be deployed

`node['nodestack']['apps']['my_nodejs_app']['app_user']` OS user that will be used to run the app

`node['nodestack']['apps']['my_nodejs_app']['git_repo']` Git repository where the code lives.

`node['nodestack']['apps']['my_nodejs_app']['git_repo_domain']` The domain name for the git repo. Example: `github.com`

`node['nodestack']['apps']['my_nodejs_app']['ssh_auth']` `true/false` - Are we using git+ssh to deploy the application?

`node['nodestack']['apps']['my_nodejs_app']['entry_point']` the .js file that will be ran as the server.

`node['nodestack']['apps']['my_nodejs_app']['rev']` Code revision that should be used. Example: HEAD

`node['nodestack']['apps']['my_nodejs_app']['npm']` `true/false` - Wether we should run `npm install` during a deployment.

`node['nodestack']['apps']['my_nodejs_app']['deploy_key']` SSH key to pull the code from the git repo. You don't need this if you use https instead of git.

`node['nodestack']['apps']['my_nodejs_app']['port']` For now, we can't bind the well known ports, so we're redirecting. This is we would like the app to listen to.

`node['nodestack']['apps']['my_nodejs_app']['port_local']` This is the port the app really listens to.


Usage
-----
To deploy an app node these is how a `nodejs_app` role would look like:
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
  recipe[rackops_rolebook::default]
  recipe[nodestack::application_nodejs]
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
  recipe[rackops_rolebook::default]
  recipe[nodestack::mysql_master]
```

To deploy a mongo node these is how a `nodejs_mongo` role would look like:
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
  recipe[rackops_rolebook::default]
  recipe[nodestack::mongodb_standalone]
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
  mysql-multi:
    master: 10.x.x.x
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
- Author:: Rackspace DevOps (devops@rackspace.com)

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
