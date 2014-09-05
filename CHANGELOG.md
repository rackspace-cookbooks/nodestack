nodestack CHANGELOG
===================

This file is used to list changes made in each version of the nodestack cookbook.

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
