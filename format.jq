#!/usr/bin/env jq -Mf

# Format the time
def fmt_date($timeMicros) :
  $timeMicros | tonumber | . / 1000000 | strftime("%Y-%m-%d %H:%M:%S")
;

# Get the unit name from the entry
def fmt_unit($entry):
  "["+
  if $entry.SYSTEMD_UNIT != null then
    $entry.SYSTEMD_UNIT
  else
    $entry.SYSLOG_IDENTIFIER
  end
  +"]"
;

# Select fields from the journalctl output and tranform to
# a human readable format
def fmt_entry($entry):
  [fmt_date($entry.__REALTIME_TIMESTAMP), fmt_unit($entry), .MESSAGE] | join(" ")
;

# Process the entry
fmt_entry(.)
