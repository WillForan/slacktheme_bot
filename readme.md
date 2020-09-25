# Daily theme
Set the daily theme to facilitate labwide checkin on the random slack channel.

theme list from https://literarydevices.net/a-huge-list-of-common-themes/

## Setting theme
bot does a `git pull` before looking for a theme. if `manual-theme.txt` has been modified, text in that file will be used as a theme.

Github enables [editting the manual theme](https://github.com/LabNeuroCogDevel/slacktheme_bot/edit/master/manual-theme.txt) on the web!

## Using

Should be run from cron weekday mornings (a la `crontab -e`):
```
00 8 * * 1,2,3,4,5 /path/to/slacktheme_bot/bot.pl
```

`.oauth` and `.giphy` are untracked files with the key/token to use for slack and giphy respectively.
