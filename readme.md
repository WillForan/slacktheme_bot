# Daily theme

Set the user responsible for picking tomorrow's daily theme. Rotate evenly over the calendar year weekdays.

Setter is
 * is annonced to the `random` channel.
 * sent a DM from the bot with a suggested theme (and giphy). 

Suggested theme list from https://literarydevices.net/a-huge-list-of-common-themes/

## Using

Should be run from cron weekday afternoons (a la `crontab -e`):
```
00 17 * * 1,2,3,4,5 /path/to/slacktheme_bot/bot.pl
```

* `.oauth` and `.giphy` are untracked files with the key/token to use for slack and giphy respectively.
* perl depends: `cpanm Class::Tiny WebService::Slack::WebApi`

### Auth
* create using https://api.slack.com/apps/
* paste "Bot User Oauth Access Token" into `.oauth`
* scopes: need `chat:write` and `chat:write.public`
* `users:read` is useful for discovering user IDs (see `Makefile`)

## Attic

Previously manually set themes would come from github. This is still posibile, but no longer useful.

### Setting theme
bot does a `git pull` before looking for a theme. if `manual-theme.txt` has been modified, text in that file will be used as a theme.

Github enables [editting the manual theme](https://github.com/LabNeuroCogDevel/slacktheme_bot/edit/master/manual-theme.txt) on the web!
