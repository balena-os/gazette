#!/usr/bin/env jq -Mf

# TODO: convert priority to a message (and maybe a color?)
# Transform the date
(.__REALTIME_TIMESTAMP | tonumber | . / 1000000 | strftime("%Y-%m-%d %H:%M:%S")) 
+
" "
+
# Include the unit that owns the message
"[" + (
  if .SYSTEMD_UNIT != null then 
    .SYSTEMD_UNIT 
  else 
    .SYSLOG_IDENTIFIER 
  end
  ) + "]"
+
" "
+
# Add the message
.MESSAGE
