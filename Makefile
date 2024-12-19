HOME_DIR=${HOME}/.local/share/tmux/keymap-stats
NAME=keymap-stats.tmux
RESTORE_FILE=${HOME_DIR}/restore-bind-keys.sh
INSTRUMENT_FILE=${HOME_DIR}/instrument-bind-keys.sh
LOG_FILE=${HOME_DIR}/${NAME}.log

show-log:
	tail -n 50 ${LOG_FILE}
follow-log:
	tail -f -n 50 ${LOG_FILE}

show-stats:
	cat ${LOG_FILE} |\
		grep -v init |\
		sed -e 's/\]\[/,/g' -e 's/\[//' -e 's/\]//' |\
		cut -d ',' -f 2- |\
		sed -e 's/key://' |\
		awk -F, '{print $$1 " "  $$2}' |\
		sort |\
		uniq -c |\
		sort -h -r

show-keymaps:
	cat ${LOG_FILE} |\
		grep -e init |\
		grep -e Processing |\
		sed -e 's/\]\[/,/g' -e 's/\[//' -e 's/\]//' |\
		cut -d ',' -f 2- |\
		sed -e 's/.*prefix//' |\
		awk -F, '{print $$1 " "  $$2}' |\
		sort |\
		uniq |\
		sort -h

example-bind-key:
	tmux list-keys | grep 'display-panes'

instrument:
	bash scripts/instrument-bind-key.sh
restore:
	bash ${RESTORE_FILE}
