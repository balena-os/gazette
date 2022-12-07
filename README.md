# Gazette

A simple log collection agent that follows the logs for user defined services and agregates them
in a single stream. This allows the supervisor to collect and send the logs to the API and provides
users and support agents with an extra source of data to diagnose potential device issues. By default only
log entries with priority error or higher are collected.

## Features

- Lightweight. Uses `journalctl` to monitor and filter logs.
- Configurable. Only collect relevant logs to avoid unnecessary bandwidth usage.
- Small image size

## Supported devices

This block is compatible with all [Balena](https://www.balena.io/) [supported device types](https://hub.balena.io/device-types).

## Usage

To use this block as part of a larger application, add the following to your `docker-compose.yml`.

```yaml
version: '2.1'

services:
  gazette:
    image: ghcr.io/balena-os/gazette
    labels:
      # Necessary to give the container access to the journal directories
      io.balena.features.journal-logs: '1'
    restart: unless_stopped
```

## Environment variables

| Name             | Description                                                                                                                 | Default Value |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------- |
| JOURNAL_UNITS    | Space separated list of [systemd services](https://wiki.archlinux.org/title/systemd#Using_units) from where to collect logs | openvpn       |
| JOURNAL_IDS      | Space separated list of syslog identifiers from where to collect logs                                                       | kernel        |
| JOURNAL_LOGLEVEL | Minimal priority of log entries to make them elegible for collection. One of `debug`, `info`, `warn`, `error`               | error         |
