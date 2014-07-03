actions :create, :delete, :restart

attribute 'name', kind_of: String, name_attribute: true
attribute 'cookbook', kind_of: String, default: 'nodestack'
attribute 'port', kind_of: [String], default: node['nodestack']['apps']['my_nodejs_app']['http_port']
attribute 'path', kind_of:  [String], default: node['nodestack']['apps']['my_nodejs_app']['app_dir']
attribute 'js', kind_of: [String], default: node['nodestack']['apps']['my_nodejs_app']['entry_point']
attribute 'user', kind_of: [String], default: node['nodestack']['apps']['my_nodejs_app']['app_user']
attribute 'group', kind_of: [String], default: node['nodestack']['apps']['my_nodejs_app']['app_user']

attr_accessor 'exists'

def initialize(*args)
  super
  @action = 'create'
end
