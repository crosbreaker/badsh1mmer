#!/bin/sh -u
# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# lobotomized version of chromeos-tpm-recovery, only resets kernel space

# does this even work in badreco?

tpmc=tpmc
crossystem=crossystem
awk=awk
initctl=initctl
daemon_was_running=
err=0
secdata_kernel=0x1008

tpm2_target() {
  # This is not an ideal way to tell if we are running on a tpm2 target, but
  # it will have to do for now.
  if [ -f "/etc/init/trunksd.conf" ]; then
    return 0
  else
    return 1
  fi
}

use_v0_secdata_kernel() {
  local fwid=$(crossystem ro_fwid)
  local major=$(printf "$fwid" | cut -d. -f2)
  local minor=$(printf "$fwid" | cut -d. -f3)

  # TPM1 firmware never supports the v1 kernel space format.
  if ! tpm2_target; then
    return 0
  fi

  # First some validity checks: X -eq X checks that X is a number. cut may
  # return the whole string if no delimiter found, so major != minor checks that
  # the version was at least somewhat correctly formatted.
  if [ $major -eq $major ] && [ $minor -eq $minor ] && [ $major -ne $minor ]; then
    # Now what we really care about: is this firmware older than CL:2041695?
    if [ $major -lt 12953 ]; then
      return 0
    else
      return 1
    fi
  else
    log "Cannot parse FWID. Assuming local build that supports v1 kernel space."
    return 1
  fi
}

log() {
  echo "$*"
}

quit() {
  log "ERROR: $*"
  restart_daemon_if_needed
  log "exiting"

  exit 1
}

log_tryfix() {
  log "$*: attempting to fix"
}

log_error() {
  err=$((err + 1))
  log "ERROR: $*"
}


log_warn() {
  log "WARNING: $*"
}

write_space () {
  # do not quote "$2", as we mean to expand it here
  if ! $tpmc write $1 $2; then
    log_error "writing to $1 failed"
  else
    log "$1 written successfully"
  fi
}

reset_rw_space () {
  local index=$1
  local bytes="$2"
  local size=$(printf "$bytes" | wc -w)
  local permissions=0x1

  if tpm2_target; then
    permissions=0x40050001
  fi

  if ! $tpmc definespace $index $size $permissions; then
    log_error "could not redefine RW space $index"
    # try writing it anyway, just in case it works...
  fi

  write_space $index "$bytes"
}

restart_daemon_if_needed() {
  if [ "$daemon_was_running" = 1 ]; then
    log "Restarting ${DAEMON}..."
    $initctl start "${DAEMON}" >/dev/null
  fi
}

# ------------
# MAIN PROGRAM
# ------------

if tpm2_target; then
  DAEMON="trunksd"
else
  DAEMON="tcsd"
fi

# TPM daemon may or may not be running

log "Stopping ${DAEMON}..."
if $initctl stop "${DAEMON}" >/dev/null 2>/dev/null; then
  daemon_was_running=1
  log "done"
else
  daemon_was_running=0
  log "(was not running)"
fi

# Is the state of the PP enable flags correct?

if ! tpm2_target; then
  if ! ($tpmc getpf | grep -q "physicalPresenceLifetimeLock 1" &&
      $tpmc getpf | grep -q "physicalPresenceHWEnable 0" &&
      $tpmc getpf | grep -q "physicalPresenceCMDEnable 1"); then
    log_tryfix "bad state of physical presence enable flags"
    if $tpmc ppfin; then
      log "physical presence enable flags are now correctly set"
    else
      quit "could not set physical presence enable flags"
    fi
  fi

  # Is physical presence turned on?

  if $tpmc getvf | grep -q "physicalPresence 0"; then
    log_tryfix "physical presence is OFF, expected ON"
    # attempt to turn on physical presence
    if $tpmc ppon; then
      log "physical presence is now on"
    else
      quit "could not turn physical presence on"
    fi
  fi
else
  if ! $tpmc getvf | grep -q 'phEnable 1'; then
    quit "Platform Hierarchy is disabled, TPM can't be recovered"
  fi
fi

if use_v0_secdata_kernel; then
  reset_rw_space $secdata_kernel "02  4c 57 52 47  1 0 1 0  0 0 0  55"
else
  reset_rw_space $secdata_kernel "10  28  0c  0  1 0 1 0  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
fi

restart_daemon_if_needed

if [ "$err" -eq 0 ]; then
  log "Kernel rollback version has successfully been reset to factory defaults"
else
  log_error "An error occured..."
  exit 1
fi
