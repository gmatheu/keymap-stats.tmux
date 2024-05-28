#!/bin/bash -x

_log() {
	local msg=$*
	echo "[$(date -Iseconds)][init] ${msg}"
}
rebind_keys() {
	local restore_file="restore-bind-keys.sh"
	local instrument_file="instrument-bind-keys.sh"
	local log_filename=".tmux-keys.log"
	local log_file="$HOME/${log_filename}"
	# Cleanup
	all_prefix_bind_keys=$(tmux list-keys -T prefix)
	echo "" >${restore_file}
	echo "" >${instrument_file}
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
		cmd=$(echo "${after_prefix}" | cut -d ' ' -f 2- | sed -e 's/"/\"/g')
		local key
		key=$(echo "${after_prefix}" | cut -d ' ' -f 1)
		echo "tmux unbind-key -T prefix ${key}" >>${restore_file}
		echo "tmux ${bind_key}" >>${restore_file}
		if [[ "$cmd" =~ "${log_filename}" ]]; then
			_log "Already instrumented: ${cmd}"
		else
			local log_cmd
			log_cmd="echo \"[\$(date -Iseconds)][key:${key}][${cmd}]\" >> ${log_file}"
			local instrumented_cmd="tmux bind-key ${repeat} -T prefix ${key} run-shell '${log_cmd}; tmux ${cmd}'"
			_log "Replaced: ${instrumented_cmd}"

			echo "${instrumented_cmd}" >>${instrument_file}
			eval "${instrumented_cmd}"
		fi
	done <<<"${all_prefix_bind_keys}" | tee -a "${log_file}"
}

rebind_keys
