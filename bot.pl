#!/usr/bin/env perl
use strict; use warnings; use feature qq/say/;
#
# send a giphy url for a given theme to the random slack channel
# - if "manual-theme.txt" has been updated in the last day. theme will be pulled from that
# - otherwise randomply pulls from theme_list.txt
#
# depends on system running `shuf`, `curl`, and `jq`
# 
# posts json to https://slack.com/api/chat.postMessage to send message
# WebService::Slack::WebApi is a heavy depend to run auth and send message

# 20200925WF - init
use WebService::Slack::WebApi;
use File::Slurp;
use URI::Escape;
use Data::Dumper;

# read in api key/tokens
chomp(my $slack_token = read_file('.oauth'));
chomp(my $giphy_key = read_file('.giphy'));


# find theme
system('git pull'); # update maybe
my $man_fname = "manual-theme.txt";
my $is_manual = ( -s $man_fname and -M $man_fname < 1);

my $theme = $is_manual ? qx/sed 1q $man_fname/ : qx/shuf -n 1 theme_list.txt/;
my $theme_note = $is_manual ? "manual" : "automatic";
chomp($theme);

# pull image url from giphy
my $giphy_search = "https://api.giphy.com/v1/gifs/search?api_key=$giphy_key&q=".uri_escape($theme)."&offset=0&limit=10";
chomp(my $img_url = qx/curl -qL "$giphy_search" | jq -r '.data[] | select(.images.original.size|tonumber| . <= 1000000)| .url'|shuf -n1/);
my $have_img = $img_url =~ m/http/;
my $txt = $have_img?"today's $theme_note theme: <$img_url|$theme>": "no giphy for *$theme*! :scream:";

# init slack
my $slack = WebService::Slack::WebApi->new(token => $slack_token) or die "no slack! $!";

my $edit_note = "; <https://github.com/LabNeuroCogDevel/slacktheme_bot/edit/master/manual-theme.txt|set tomorrow's theme>";
# posting message to specified channel and getting message description
my $posted_message = $slack->chat->post_message(
    channel  => '@will', # required
    #channel  => 'random', # required
    text     => "$txt $edit_note",       # required (not required if 'attachments' argument exists)
);

#say Dumper($posted_message);
