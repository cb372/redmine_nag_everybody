# redmine_nag_everybody

A plugin to send the 'deadlines approaching' reminder mail to all issue watchers, not only the assignee.

The plugin replicates the default Redmine behaviour (send reminders only to assignees) by default. Sending to watchers can be enabled on a per-project basis.

## Install

```
git clone https://github.com/cb372/redmine_nag_everybody.git $REDMINE_ROOT/plugins/redmine_nag_everybody
rake redmine:plugins:migrate
# restart Redmine
```

## Usage

To enable the plugin for a project, 

1. Add the "Reminder mail options" module in the project's settings
2. Check the checkbox on the "Reminder Mail Options" tab

## Warning

Monkeys galore! Might break in future versions of Redmine. Only tested against 2.5.1
