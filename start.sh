#!/bin/sh

set -e

# Set to 1 to debug commands
DEBUG=${DEBUG:-0}
[ "${DEBUG}" = "1" ] && set -x

# Just send openvpn logs by default
JOURNAL_UNITS=${JOURNAL_UNITS:-"openvpn"}

# Set this to add units by identifier, e.g. "kernel"
JOURNAL_IDS=${JOURNAL_IDS:="kernel"}

# Send only errors or more critical messages
JOURNAL_LOGLEVEL=${JOURNAL_LOGLEVEL:-"error"}

# Add identifiers arguments
if [ -n "${JOURNAL_IDS}" ]; then
	for id in ${JOURNAL_IDS}; do
		set -- "$@" "SYSLOG_IDENTIFIER=$id"
	done
fi

# Add unit arguments
if [ -n "${JOURNAL_UNITS}" ]; then
	for u in ${JOURNAL_UNITS}; do
		set -- "$@" "_SYSTEMD_UNIT=$u.service"
	done
fi

filters=$(echo "$@" | sed 's/ / + /g')

# Use $@ to manage journalctl arguments
# get at most 1000 lines since the API won't be able
# to consume any more
set -- -f --lines=1000 -q -a -o json

# Set priority (error by default)
priority=3
if [ -n "${JOURNAL_LOGLEVEL}" ]; then
	case "${JOURNAL_LOGLEVEL}" in
	debug | DEBUG)
		priority=7
		;;
	info | INFO)
		priority=6
		;;
	warn | WARN)
		priority=4
		;;
	error | ERROR)
		priority=3
		;;
	esac
fi

# Set the priority according to the environment variable
set -- "$@" -p "0..$priority"

if [ -f /tmp/balena/logs.since ]; then
	# Get logs since the last service exit
	set -- "$@" --since "$(cat /tmp/balena/logs.since)"
else
	# If the file doesn't exist show logs since boot
	set -- "$@" --boot
fi

# we want globbing of the filters variable so disable shellcheck warnings here
# shellcheck disable=SC2086
journalctl "$@" $filters | jq -r -f ./format.jq &
journal=$!

# Trap exit signals in order to save the log report
cleanup() {
	echo "Termination signal received"

	# /tmp/balena files will persist until reboot, we
	# write the exit time there so we can read the logs
	# starting at this date next time we run
	[ -d /tmp/balena ] && date +"%Y-%m-%d %H:%M:%S" >/tmp/balena/logs.since

	# Kill the process
	kill $journal
}

# Trap the termination signal from the engine
trap 'cleanup' HUP INT TERM

# Wait for the journal to be killed
wait $journal
