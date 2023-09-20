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

# Convert a byte array into a string
# Source: https://stackoverflow.com/a/48431552

def btostring:
	[foreach .[] as $item (
    	[0, 0]
    	;
    	if .[0] > 0 then [.[0] - 1, .[1] * 64 + ($item % 64)]
    	elif $item >= 240 then [3, $item % 8]
    	elif $item >= 224 then [2, $item % 16]
    	elif $item >= 192 then [1, $item % 32]
    	elif $item < 128 then [0, $item]
    	else error("Malformed UTF-8 bytes")
    	end
    	;
    	if .[0] == 0 then .[1] else empty end
	)] | implode
;


def fmt_message($msg):
	if $msg | type == "array" then
		$msg | btostring
	else
		$msg
	end
;

# Select fields from the journalctl output and tranform to
# a human readable format
def fmt_entry($entry):
  [fmt_date($entry.__REALTIME_TIMESTAMP), fmt_unit($entry), fmt_message(.MESSAGE)] | join(" ")
;

# Process the entry
fmt_entry(.)
