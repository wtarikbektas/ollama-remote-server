#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
env_file="$project_dir/.env"

if [ -f "$env_file" ]; then
  echo ".env already exists; nothing changed."
  exit 0
fi

api_key=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
cp "$project_dir/.env.example" "$env_file"
sed -i.bak "s/replace-with-a-long-random-secret/$api_key/" "$env_file"
rm -f "$env_file.bak"
printf 'Created .env. API key: %s\nStore this key safely.\n' "$api_key"

