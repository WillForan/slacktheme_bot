# Daily theme
Set the daily theme to facilitate labwide checkin on the random slack channel.

Should be run from cron weekday mornings.

theme list from https://literarydevices.net/a-huge-list-of-common-themes/

## Setting theme
bot does a `git pull` before looking for a theme. if `manual-theme.txt` has been modified, text in that file will be used as a theme.

Github enables [editting the manual theme](https://github.com/LabNeuroCogDevel/slacktheme_bot/edit/master/manual-theme.txt) on the web!
