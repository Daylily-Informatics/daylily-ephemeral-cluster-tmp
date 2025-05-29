#!/bin/bash

cluster_init_values="$1"
cluster_cfg_yaml="$2"

# Usage check
if [[ -z "$cluster_init_values" || -z "$cluster_cfg_yaml" ]]; then
    echo "Usage: $0 <cluster_init_values.txt> <cluster_cfg_yaml.yaml>"
    exit 1
fi

# File existence check
if [[ ! -f "$cluster_init_values" ]]; then
    echo "Error: '$cluster_init_values' not found!"
    exit 1
fi

if [[ ! -f "$cluster_cfg_yaml" ]]; then
    echo "Error: '$cluster_cfg_yaml' not found!"
    exit 1
fi

# Detect OS (for sed)
if [[ "$(uname)" == "Darwin" ]]; then
    SED_INPLACE=(sed -i "")
else
    SED_INPLACE=(sed -i)
fi

# Iterate over each line in cluster_init_values.txt
while IFS='=' read -r key value; do
    # Trim whitespace from key and value
    key="$(echo -e "$key" | sed 's/^[ \t]*//;s/[ \t]*$//')"
    value="$(echo -e "$value" | sed 's/^[ \t]*//;s/[ \t]*$//')"

    # Skip empty lines, lines without key-value pairs, or commented lines
    [[ -z "$key" || -z "$value" || "$key" == \#* ]] && continue

    # Escape special chars in value
    escaped_value=$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')

    # Perform the substitution
    "${SED_INPLACE[@]}" "s|$key|$escaped_value|g" "$cluster_cfg_yaml"

done < "$cluster_init_values"

echo ""
echo "Substitutions completed in $cluster_cfg_yaml."
echo ""
