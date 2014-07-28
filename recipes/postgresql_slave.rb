#
# Cookbook Name:: nodestack
# Recipe:: postgresql_slave
#
# Copyright 2014, Rackspace
#

include_recipe 'nodestack::postgresql_base'

include_recipe 'pg-multi::pg_slave'