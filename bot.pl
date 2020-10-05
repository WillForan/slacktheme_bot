#!/usr/bin/env perl
use strict; use warnings; use feature qw/say signatures/;
no warnings qw/experimental::signatures/;
#
# send a giphy url for a given theme to the random slack channel
# - if "manual-theme.txt" has been updated in the last day. theme will be pulled from that
# - otherwise randomply pulls from theme_list.txt
#
# depends on system running `shuf`, `curl`, and `jq`
# 
# posts json to https://slack.com/api/chat.postMessage to send message
# WebService::Slack::WebApi is a heavy depend to run auth and send message

# 20200925WF - init. send a giphy to 'random'
# 20200929WF - send a reminder to a person for them to set a theme.

package GiphyTheme;
use File::Slurp;
use URI::Escape;

sub get_theme(){
   #system('git pull'); # update maybe
  my $man_fname = "manual-theme.txt";
  my $is_manual = ( -s $man_fname and -M $man_fname < 1);
  
  my $theme = $is_manual ? qx/sed 1q $man_fname/ : qx/shuf -n 1 theme_list.txt/;
  my $theme_note = $is_manual ? "manual" : "automatic";
  chomp($theme);
  return($theme_note, $theme);
}

sub get_giphy($theme){
  chomp(my $giphy_key = read_file('.giphy'));
  my $giphy_search = "https://api.giphy.com/v1/gifs/search?api_key=".
                     "$giphy_key&q=".
                     uri_escape($theme).
                     "&offset=0&limit=10";
  chomp(my $img_url = qx/
     curl -qL "$giphy_search" |
     jq -r '.data[] |
            select(.images.original.size|tonumber| . <= 1000000)| .url' |
     shuf -n1/);
  return $img_url;
}
sub slack_text($img_url, $theme, $prefix="") {
  # prefix previously like "today's note theme: "
  my $have_img = $img_url =~ m/http/;
  my $txt = $have_img?"$prefix<$img_url|$theme>": "no giphy for *$theme*! :scream:";
  return($txt)
}

sub giphy_text() {
   my ($note, $theme) = get_theme();
   my $img_url = get_giphy($theme);
   return slack_text($img_url, $theme);
}


package Slack;
use WebService::Slack::WebApi;
use File::Slurp;
sub slack_login() {
   chomp(my $slack_token = read_file('.oauth'));
   my $slack = WebService::Slack::WebApi->new(token => $slack_token) or die "no slack! $!";
   return($slack);
}

use Class::Tiny { auth => sub {slack_login} };
sub msg($self, $txt, $to="random") {
    # to can be a person (e.g. @name) or channel (e.g. random)
    # posting message to specified channel and getting message description
    my $posted_message = $self->auth->chat->post_message(
         channel  => $to,
         text     => "$txt",
         link_names=>1,
    );
    return($posted_message);
}


package main;
use Data::Dumper;
use File::Slurp;
use FindBin;
use Time::Piece;
# auth info and themes are all in the script directory
chdir $FindBin::Bin;

sub date_idx{
   # index days of the year skipping weekends
   # weirdness around weekends: sat reports same as thursday, sun same as friday
   my $ymd = shift;
   my $dt = $ymd?Time::Piece->strptime($ymd,"%Y-%m-%d"):Time::Piece->new();
   return($dt->yday - $dt->week*2);
}

sub get_setter(){
  my @everyone = read_file('ids.txt', chomp=>1);
  my $setter = $everyone[date_idx() % ($#everyone+1)];
  return $setter;
}


my $setter = "@".get_setter();
# sometimes we just want to check who is next
# without sending anythign to slack
if ($ENV{DRYRUN}){
  say $setter;
  exit;
}
# or to check that date index works
if($#ARGV >= 0) {
   say date_idx($ARGV[0]);
   exit;
}


my $giphy_txt = GiphyTheme::giphy_text();
# my $edit_note = ". Set tomorrow's theme on <https://github.com/LabNeuroCogDevel/slacktheme_bot/edit/master/manual-theme.txt|github>";
my $slack = Slack->new;
my $resp = $slack->msg("<$setter> sets the theme next!", 'random');
$resp = $slack->msg("It's your turn to set the theme next. Here's some insperation: $giphy_txt", $setter);
