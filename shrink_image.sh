#!/bin/bash

DELETE_PARTS="8 9 10 11 12"
SECTOR_SIZE=512
SECTOR_START=2048

dlog() {
    if [[ ${DEBUG:-} == 1 ]]; then
        printf 'DEBUG: %s\n' "$*"
    fi
    return 0
}

should_delete_part() {
    local candidate

    for candidate in $DELETE_PARTS; do
        if [[ $1 == "$candidate" ]]; then
            return 0
        fi
    done
    return 1
}

main() {
    if (( $# != 2 )); then
        printf 'Usage: %s <input_image> <output_image>\n' "${0##*/}" >&2
        return 1
    fi

    if (( EUID != 0 )); then
        printf 'Error: this script must be run as root.\n' >&2
        return 1
    fi

    local input_image=$1
    local output_image=$2

    if [[ ! -e $input_image ]]; then
        printf 'Error: input image does not exist: %s\n' "$input_image" >&2
        return 1
    fi
    if [[ ! -r $input_image ]]; then
        printf 'Error: input image is not readable: %s\n' "$input_image" >&2
        return 1
    fi
    if [[ $input_image == "$output_image" ]] ||
       { [[ -e $output_image ]] && [[ $input_image -ef $output_image ]]; }; then
        printf 'Error: input and output must be different files.\n' >&2
        return 1
    fi

    local command_name
    for command_name in sfdisk dd truncate sort; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            printf 'Error: required command not found: %s\n' "$command_name" >&2
            return 1
        fi
    done

    local dump
    if ! dump=$(sfdisk -d "$input_image"); then
        printf 'Error: could not dump the input partition table.\n' >&2
        return 1
    fi

    local -a old_starts part_sizes metadata present retained_parts
    local line device old_start size fields digits part
    local saw_gpt=0
    local partition_count=0
    local table_length=
    local total_sectors=0

    while IFS= read -r line || [[ -n $line ]]; do
        if [[ $line =~ ^[[:space:]]*label[[:space:]]*:[[:space:]]*(.*)$ ]]; then
            if [[ ${BASH_REMATCH[1]} != gpt ]]; then
                printf 'Error: input partition table is not GPT.\n' >&2
                return 1
            fi
            saw_gpt=1
            continue
        fi

        if [[ $line =~ ^[[:space:]]*sector-size[[:space:]]*:[[:space:]]*([0-9]+)[[:space:]]*$ ]]; then
            if (( 10#${BASH_REMATCH[1]} != SECTOR_SIZE )); then
                printf 'Error: input logical sector size is not %d bytes.\n' "$SECTOR_SIZE" >&2
                return 1
            fi
            continue
        fi

        if [[ $line =~ ^[[:space:]]*table-length[[:space:]]*:[[:space:]]*([0-9]+)[[:space:]]*$ ]]; then
            table_length=$((10#${BASH_REMATCH[1]}))
            if (( table_length < 1 )); then
                printf 'Error: invalid GPT table length.\n' >&2
                return 1
            fi
            continue
        fi

        if [[ -z $line || $line =~ ^[[:space:]]*# ]]; then
            continue
        fi
        if [[ $line =~ ^[[:space:]]*(label-id|device|unit|first-lba|last-lba|grain)[[:space:]]*: ]]; then
            continue
        fi

        if [[ ! $line =~ ^[[:space:]]*(.*[^[:space:]])[[:space:]]*:[[:space:]]*start[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*,[[:space:]]*size[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*,[[:space:]]*(.*[^[:space:]])[[:space:]]*$ ]]; then
            printf 'Error: could not parse partition record: %s\n' "$line" >&2
            return 1
        fi

        device=${BASH_REMATCH[1]}
        old_start=${BASH_REMATCH[2]}
        size=${BASH_REMATCH[3]}
        fields=${BASH_REMATCH[4]}

        if [[ ! $device =~ ([0-9]+)[[:space:]]*$ ]]; then
            printf 'Error: could not determine partition number: %s\n' "$device" >&2
            return 1
        fi
        digits=${BASH_REMATCH[1]}
        part=$((10#$digits))
        if (( part < 1 )); then
            printf 'Error: invalid partition number: %s\n' "$digits" >&2
            return 1
        fi
        if [[ -n ${present[$part]:-} ]]; then
            printf 'Error: duplicate partition number: %d\n' "$part" >&2
            return 1
        fi
        if [[ ! $fields =~ (^|,[[:space:]]*)type[[:space:]]*= ]] ||
           [[ ! $fields =~ (^|,[[:space:]]*)uuid[[:space:]]*= ]]; then
            printf 'Error: partition %d is missing GPT metadata.\n' "$part" >&2
            return 1
        fi

        old_start=$((10#$old_start))
        size=$((10#$size))
        if (( size < 1 )); then
            printf 'Error: partition %d has an invalid size.\n' "$part" >&2
            return 1
        fi

        present[$part]=1
        old_starts[$part]=$old_start
        part_sizes[$part]=$size
        metadata[$part]=$fields
        partition_count=$((partition_count + 1))

        if ! should_delete_part "$part"; then
            retained_parts[${#retained_parts[@]}]=$part
            if (( total_sectors > 9223372036854775807 - size )); then
                printf 'Error: retained partition sizes are too large.\n' >&2
                return 1
            fi
            total_sectors=$((total_sectors + size))
        fi
    done <<< "$dump"

    if (( ! saw_gpt )); then
        printf 'Error: GPT label was not found in the partition dump.\n' >&2
        return 1
    fi
    dlog "parsed $partition_count partition(s); retaining ${#retained_parts[@]} partition(s)"

    if (( total_sectors > 9223372036854775807 - 4096 )); then
        printf 'Error: output image size is too large.\n' >&2
        return 1
    fi
    local output_sectors=$((total_sectors + 4096))
    if (( output_sectors > 9223372036854775807 / SECTOR_SIZE )); then
        printf 'Error: output image size is too large.\n' >&2
        return 1
    fi
    local output_bytes=$((output_sectors * SECTOR_SIZE))

    if ! truncate -s "$output_bytes" -- "$output_image"; then
        printf 'Error: could not create output image.\n' >&2
        return 1
    fi

    local sorted_parts=
    if (( ${#retained_parts[@]} > 0 )); then
        if ! sorted_parts=$(printf '%s\n' "${retained_parts[@]}" | sort -n); then
            printf 'Error: could not sort partition records.\n' >&2
            return 1
        fi
    fi

    local new_start=$SECTOR_START
    local table
    table=$'label: gpt\nunit: sectors\n'
    if [[ -n $table_length ]]; then
        table+="table-length: $table_length"$'\n'
    fi
    table+=$'\n'

    while IFS= read -r part; do
        [[ -z $part ]] && continue

        old_start=${old_starts[$part]}
        size=${part_sizes[$part]}
        fields=${metadata[$part]}
        dlog "copy partition $part: $old_start -> $new_start ($size sectors)"

        if ! dd if="$input_image" of="$output_image" bs="$SECTOR_SIZE" \
                skip="$old_start" seek="$new_start" count="$size" \
                conv=notrunc status=none; then
            printf 'Error: failed to copy partition %d.\n' "$part" >&2
            return 1
        fi

        printf -v line '%d : start=%d, size=%d, %s\n' \
            "$part" "$new_start" "$size" "$fields"
        table+=$line
        new_start=$((new_start + size))
    done <<< "$sorted_parts"

    dlog "writing GPT to $output_image"
    if ! printf '%s' "$table" | sfdisk --force --quiet "$output_image"; then
        printf 'Error: could not write output GPT.\n' >&2
        return 1
    fi

    printf 'Created compacted image: %s\n' "$output_image"
    return 0
}

main "$@"
