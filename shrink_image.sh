#!/bin/bash
# Copyright (c) 2026 kxtzownsu
# A copy of the All Rights Reserved license should have been provided with this file.

# partition numbers to delete
DELETE_PARTS="8 9 10 11 12"

dlog(){
  if [ "$DEBUG" = "1" ]; then
    printf '%s\n' "$*"
  fi
}

should_delete_part() {
  local part="$1"
  for num in $DELETE_PARTS; do
    [ "$part" = "$num" ] && return 0
  done
  return 1
}

main(){
  INPUT_FILE="$1"
  OUTPUT_FILE="$2"

  SECTOR_SIZE=512
  SECTOR_START=2048

  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_image> <output_image>"
    exit 1
  fi

  if [ "$EUID" != "0" ]; then
    echo "Please run this script as root!"
    exit 1
  fi

  if [ "$INPUT_FILE" == "$OUTPUT_FILE" ]; then
    echo "bro?? don't override your source file???"
    exit 1
  fi

  echo "Shrinking $INPUT_FILE to $OUTPUT_FILE"
  [ -n "$DELETE_PARTS" ] && echo "Deleting partitions: $DELETE_PARTS"

  DUMP=$(sfdisk -d "$INPUT_FILE")

  PART_DATA=$(echo "$DUMP" | grep "^$INPUT_FILE" | sed "s|^$INPUT_FILE[p]*||")

  TOTAL_PART_SIZE=0
  while read -r LINE; do
    PART_NUM=$(echo "$LINE" | awk -F'[: ]' '{print $1}')
    PART_SIZE=$(echo "$LINE" | grep -o "size=[ ]*[0-9]*" | cut -d= -f2 | tr -d ' ')

    if should_delete_part "$PART_NUM"; then
      dlog "Skipping size for deleted partition $PART_NUM"
      continue
    fi

    TOTAL_PART_SIZE=$((TOTAL_PART_SIZE + PART_SIZE))
  done <<< "$PART_DATA"

  TOTAL_DISK_SECTORS=$((TOTAL_PART_SIZE + 4096))
  truncate -s $((TOTAL_DISK_SECTORS * SECTOR_SIZE)) "$OUTPUT_FILE"

  CURRENT_START=$SECTOR_START
  NEW_LAYOUT="label: gpt\nunit: sectors\n\n"

  while read -r LINE; do
    PART_NUM=$(echo "$LINE" | awk -F'[: ]' '{print $1}')

    if should_delete_part "$PART_NUM"; then
      dlog "Deleting partition $PART_NUM"
      continue
    fi

    PART_OLD_START=$(echo "$LINE" | grep -o "start=[ ]*[0-9]*" | cut -d= -f2 | tr -d ' ')
    PART_SIZE=$(echo "$LINE" | grep -o "size=[ ]*[0-9]*" | cut -d= -f2 | tr -d ' ')
    PART_TYPE=$(echo "$LINE" | grep -o "type=[^ ,]*")
    PART_UUID=$(echo "$LINE" | grep -o "uuid=[^ ,]*")
    PART_NAME=$(echo "$LINE" | grep -o "name=\"[^\"]*\"")
    PART_ATTR=$(echo "$LINE" | grep -o "attrs=\"[^\"]*\"")

    dlog "part=$PART_NUM old_start=$PART_OLD_START new_start=$CURRENT_START size=$PART_SIZE type=$PART_TYPE uuid=$PART_UUID name=$PART_NAME attrs=$PART_ATTR"

    dd if="$INPUT_FILE" of="$OUTPUT_FILE" bs="$SECTOR_SIZE" \
       skip="$PART_OLD_START" seek="$CURRENT_START" count="$PART_SIZE" \
       conv=notrunc status=none

    NEW_LINE="$OUTPUT_FILE$PART_NUM : start=$CURRENT_START, size=$PART_SIZE, $PART_TYPE, $PART_UUID, $PART_NAME"
    [ -n "$PART_ATTR" ] && NEW_LINE+=", $PART_ATTR"
    NEW_LAYOUT+="$NEW_LINE\n"

    CURRENT_START=$((CURRENT_START + PART_SIZE))
  done <<< "$(echo "$PART_DATA" | sort -n)"

  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!!! if you see any signature errors below this, ignore them, they are intended !!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo -e "$NEW_LAYOUT" | sfdisk "$OUTPUT_FILE" --force --quiet
  echo "Done!"
  exit 0
}

main "$@"
