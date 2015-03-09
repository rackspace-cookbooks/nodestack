nodestack CHANGELOG
===================

This file is used to list changes made in each version of the nodestack cookbook.

2.4.1
---
- Forever cookbook unpinned.
- Removed old ELK attributes.
- Added unless to nginx confd hash.
- Fix Chefspec test for mysql_add_drive.
- Removed all ocurrences of action parameters as strings.

2.4.0
---
- @lmunro - Added nginx reverse proxy with tests. Fixed logstash log path.

2.3.5
---

- Seandon Mooy - Added "cwd" option for forever-monitor to enter the applications actual directory

2.3.4
---

- @marcoamorales - Disable setcap by default.
- @marcoamorales - Support Chef 12

2.3.3
---

- @marcoamorales - Unpinned apache2 cookbook
- @marcoamorales - Specify Kiabana branch
- @mattjbarlow - Make setcap optional via attribute

2.3.2
---

- Marco Morales - Rewrote the init script for CentOS 6, which was causing problems when stopping/restarting an app. Issue 164

2.3.1
---

- Seandon Mooy - Added "open_files" option per-app to allow setting the "ulimit -n" value per application.

2.3.0
---

- Marco Morales - Removed recipe import from platformstack.

2.2.1
---

- Marco Morales - Pin the version of forever, 0.12.0 was causing restarts in CentOS 6.5 to fail.

2.2.0
---

- @martinb3 - Move away from logstash_commons, just set attributes in case elkstack is present.

2.1.0
---
- Marco Morales - Adding template variables to be available for the before_symlink_template.

2.0.0
---
- Marco Morales - Decoupled forever from `application_nodejs` recipe to make nodestack more modular and add more deployment strategies in the future. The attribute `node['nodestack']['apps']['my_nodejs_app']['deployment']['strategy'] = 'forever'` will need to be set when updating to 2.0.0.

1.0.2
---
- Marco Morales - Removed npm-install-retry since it's no longer being used. Resource `nodejs_npm` is used now.

1.0.1
---
- Marco Morales - Added attribute `app_config['deployment']['before_symlink_template']` that should have a template name to be called by the the before_symlink callback.

1.0.0
---
- Marco Morales - Moved the demo attributes to recipes/demo.rb `default['nodestack']['apps_to_deploy']` is no longer needed. It will deploy all the apps in the apps hash.

0.11.1
---
- Marco Morales - Exposes the before_symlink attribute from the application resource.

0.11.0
---
- Martin Smith - Added ELK stack logging customization for node and forever logs, if ELK stack is available through platformstack.

0.10.0
---
- Marco Morales - Code deployment is now optional

0.9.8
---
- Jacob Dearing - Expose git_submodule attribute for application resource call.

0.9.7
---
- Marco Morales - Removed platformstack from Berksfile and fixed the new serverspec syntax.

0.9.5
-----
- Sheppy Reno - Added basic Chefspec for application_nodejs.rb

0.9.4
---
- Marco Morales - Allow options to be passed to apps via forevers 'options'

0.9.3
-----
- John Schwinghammer - Updated cloud_monitoring recipe name

0.9.2
-----
- Sheppy Reno - Make npm options an attribute

0.9.1
-----
- Sheppy Reno - Set NPM to only pull in production dependencies for the application.

0.9.0
-----
- Bob Garza - Added logrotate recipe and included in application_nodejs.rb.  Configures logrotate, by default, for daily rotation of forever.(err|out|log)

0.8.15
------
- Sheppy Reno - Cleanup application_nodejs.rb

0.8.14
------
- Seandon Mooy - Added logic to cleanup child processes during code deployments https://github.com/AutomationSupport/nodestack/pull/119

0.8.13
------
- Marco Morales - Added support for CentOS 7.

0.8.12
------
- Bob Garza - Forever logs are now being appended instead of being overwritten.

0.8.11
------
- Sheppy Reno - Check for attributes prior to setting iptables rules.
              - Corrected some Rubocop warnings

0.8.10
------
- Sheppy Reno - Prettify the config.js JSON

0.8.9
-----
- Marco Morales - Added HTTP monitor check


- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
