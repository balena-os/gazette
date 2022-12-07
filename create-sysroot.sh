#!/bin/sh

set -ex

binaries="$*"

for bin in $binaries; do
	mkdir -p "/sysroot/$(dirname "$bin")"
	cp "$bin" "/sysroot/$bin"

	# Get list of dependencies
	for lib in $(ldd "$bin" | grep -oE '(\/.+?) '); do
		mkdir -p "/sysroot/$(dirname "$lib")"
		# Copy -L dereferences links
		cp -L "$lib" "/sysroot/$lib"
	done
done
