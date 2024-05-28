#!/bin/bash -x

_log() {
	local msg=$1
	echo "[$(date -Iseconds)][init] ${msg}"
}
rebind_keys() {
	all_prefix_bind_keys=$(tmux list-keys -T prefix)
	echo "" >restore-bind-keys.sh
	echo "" >instrument-bind-keys.sh
	while read -r bind_key; do
		_log "Processing: $bind_key"
		local repeat
		repeat=""
		if [[ "$bind_key" =~ "-r" ]]; then
			repeat="-r"
		fi
		local cmd
		local after_prefix
		after_prefix=$(echo "${bind_key}" | sed 's/.*prefix //' | tr -s ' ')
		cmd=$(echo "${after_prefix}" | cut -d ' ' -f 2-)
		local key
		key=$(echo "${after_prefix}" | cut -d ' ' -f 1)
		echo "tmux unbind-key -T prefix ${key}" >>restore-bind-keys.sh
		echo "tmux ${bind_key}" >>restore-bind-keys.sh
		if [[ "$cmd" =~ "tmux-keys.log" ]]; then
			_log "Already instrumented: ${cmd}"
		else
			if [[ "$cmd" =~ "confirm-before" ]]; then
				_log "Skipping: ${cmd}"
			else
				local log_cmd
				log_cmd="echo \"[\$(date -Iseconds)][key:${key}][${cmd}]\" >> ~/.tmux-keys.log"
				local instrumented_cmd="tmux bind-key ${repeat} -T prefix ${key} run-shell '${log_cmd}; tmux ${cmd}'"
				_log "Replaced: ${instrumented_cmd}"

				echo "${instrumented_cmd}" >>instrument-bind-keys.sh
				eval "${instrumented_cmd}"
			fi
		fi
	done <<<"${all_prefix_bind_keys}" | tee -a ~/.tmux-keys.log
}

rebind_keys
