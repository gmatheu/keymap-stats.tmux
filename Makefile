show-log:
	tail -n 50 ~/.tmux-keys.log

show-stats:
	cat ~/.tmux-keys.log |\
		grep -v init |\
		sed -e 's/\]\[/,/g' -e 's/\[//' -e 's/\]//' |\
		cut -d ',' -f 2- |\
		sed -e 's/key://' |\
		awk -F, '{print $$1 " "  $$2}' |\
		sort |\
		uniq -c |\
		sort -h -r

show-keymaps:
	cat ~/.tmux-keys.log |\
		grep -e init |\
		grep -e Processing |\
		sed -e 's/\]\[/,/g' -e 's/\[//' -e 's/\]//' |\
		cut -d ',' -f 2- |\
		sed -e 's/.*prefix//' |\
		awk -F, '{print $$1 " "  $$2}' |\
		sort |\
		uniq |\
		sort -h
