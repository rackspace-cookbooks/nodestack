#
# Cookbook Name:: nodestack
# Recipe:: postgresql_master
#
# Copyright 2014, Rackspace
#

include_recipe 'nodestack::postgresql_base'

include_recipe 'pg-multi::pg_master'
