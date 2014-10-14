# drives logging configurations for the shared functionality
default['logstash_commons']['instance_name'] = 'agent'
default['logstash_commons']['service_name'] = 'agent'

# for forever
default['nodestack']['forever']['watch_ignore_patterns'] = ['*.log', '*.logs']
