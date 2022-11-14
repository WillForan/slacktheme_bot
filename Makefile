id_list.txt:
	curl -d token="$(shell cat .oauth)" https://slack.com/api/users.list | jq -r '.members[]|[.profile.display_name, .name, .id]|@tsv' > $@

emoji.txt:
	curl -d token="$(shell cat .oauth)" https://slack.com/api/emoji.list |  jq -r '.emoji|keys|join("\n")' > $@
