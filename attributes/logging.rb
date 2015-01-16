# for forever
default['nodestack']['forever']['watch_ignore_patterns'] = ['*.log', '*.logs']

# Ensure it's an empty array if no one else has set it
default_unless['elkstack']['config']['custom_logstash']['name'] = []

# use this to accumulate logging
default['nodestack']['logstash']['logging_paths'] = []

# NodeJS logging patterns
default['elkstack']['config']['custom_logstash']['name'].push('nodejs')
default['elkstack']['config']['custom_logstash']['nodejs']['name'] = 'input_nodejs'
default['elkstack']['config']['custom_logstash']['nodejs']['cookbook'] = 'nodestack'
default['elkstack']['config']['custom_logstash']['nodejs']['source'] = 'input_nodejs.conf.erb'
default['elkstack']['config']['custom_logstash']['nodejs']['variables'] = { paths: node['nodestack']['logstash']['logging_paths'] }
