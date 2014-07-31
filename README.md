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
- mysql-multi
- pg-multi
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
- magic_shell


Attributes
----------

####Note: the 'my_nodejs_app' defines the name of the app, please change this to something more relevant to the customer.

`node['nodestack']['apps_to_deploy']` - This array defines the application names to deploy.

`node['nodestack']['apps']['my_nodejs_app']['app_dir']` path where the application will be deployed

`node['nodestack']['apps']['my_nodejs_app']['git_repo']` Git repository where the code lives.

`node['nodestack']['apps']['my_nodejs_app']['git_rev']` Code revision or branch that should be used ('origin/' should not be specified for remote branches.) Example: HEAD

`node['nodestack']['apps']['my_nodejs_app']['git_repo_domain']` The domain name for the git repo. Example: `github.com`

`node['nodestack']['apps']['my_nodejs_app']['ssh_auth']` `true/false` - Are we using git+ssh to deploy the application?

`node['nodestack']['apps']['my_nodejs_app']['entry_point']` the .js file that will be ran as the server.

`node['nodestack']['apps']['my_nodejs_app']['npm']` `true/false` - Wether we should run `npm install` during a deployment.

`node['nodestack']['apps']['my_nodejs_app']['config_file']` `true/false` - Wether the coobook will write a config.js from the following config hash.

`node['nodestack']['apps']['my_nodejs_app']['config_js']`= {} - This config hash contains writes the config.js file to be read by the application. Whatever attributes are set through this hash will be available to the application, Example:

Attribute:
```ruby
default['nodestack']['apps']['my_nodejs_app']['config_js']['port'] = 80
```

Node.js app:
```javascript
var config = require('./config');
app.listen(config.port);
```


`node['nodestack']['apps']['my_nodejs_app']['env']`= {} - This config hash contains environment variables that will be available to the application.

`node['nodestack']['apps']['my_nodejs_app']['env']['PORT']` This is the only `env` attribute the cookbook expects to have by default, this is the port the app listens on.

How to deploy an Node.js application with Nodestack
----

There's a couple of things that need to be considered when deploying an application with this cookbook, in other words, the app must be setup in a specific way.
This cookbook will deploy an application by running a simple server.js Node.js app, which in turn will run the Node.js application that is going to be deployed. This server.js application will monitor any changes on the application files and reload itself if it finds any changes. There's also other options that can be implemented in the future, like the amount of child processes.

One important thing to note is that the application's entry point must not be `server.js`. It can be anything else but `server.js`.

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

To deploy a standalone db for an app node these is how a `nodejs_mysql` role would look like:
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
  recipe[nodestack::mysql_base]
```

To deploy a mongo node these is how a `nodejs_mongo` role would look like:
```text
$ knife role show nodejs_mongo
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mongo
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

* Building MySQL cluster for nodestack.

Ensure the following attributes are set within environment or wrapper cookbook.

```
['mysql']['server_repl_password'] = 'rootlogin'
['mysql']['server_repl_password'] = 'replicantlogin'
['mysql-multi']['master'] = '1.2.3.4'
['mysql-multi']['slaves'] = ['5.6.7.8']
```

MySQL Master node:
```text
$ knife role show nodejs_mysql_master
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mysql_master
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::mysql_master]
```

MySQL Slave node:
```text
$ knife role show nodejs_mysql_slave
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mysql_slave
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::mysql_slave]
```

* Building a PostgreSQL cluster for nodestack.

Ensure the following attributes are set within environment or wrapper cookbook.

```
['postgresql']['version'] = '9.3' 
['postgresql']['password'] = 'postgresdefault'
['pg-multi']['replication']['password'] = 'useagudpasswd'
['pg-multi']['master_ip'] = '1.2.3.4'
['pg-multi']['slave_ip'] = ['5.6.7.8']

Depending on OS one of the following two must be set:
['postgresql']['enable_pdgd_yum'] = true  (Redhat Family)
['postgresql']['enable_pdgd_apt'] = true  (Debian Family)
```

PostgreSQL Master node:
```text
$ knife role show nodejs_postgresql_master
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_postgresql_master
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::postgresql_master]
```

PostgreSQL Slave node:
```text
$ knife role show nodejs_postgresql_slave
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_postgresql_slave
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::postgresql_slave]
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
