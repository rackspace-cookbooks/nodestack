#Demo

You can spin up a single node demo by using the default recipe in a role:

```
marco@shiny ~/opsdev/nodestack (application_nodejs*) $ knife role show nodestack_app
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodestack_app
override_attributes:
  nodestack:
      username: nodejs
      run_list:            recipe[nodestack::default]
```

Then bootstrap the node with this role:

`knife bootstrap 0.0.0.0 -x root -r 'role[nodestack_app]'
