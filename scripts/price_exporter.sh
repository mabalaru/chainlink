#!/usr/bin/env bash

SCRIPT=${0##*/}
COLLECTOR_DIR="/run/node_exporter/collector"
OUTPUT="${COLLECTOR_DIR}/${SCRIPT%.*}.prom"
mkdir -p "$COLLECTOR_DIR"

#IDS=the-graph,cosmos,iris-network,kava,terra-krw,terra-luna,certik,solana,chainlink,ethereum
IDS=$1

curl_w() {
  local output=""
  until [ "$output" != "" ] && echo "$output" | jq '.'; do
  output=$(curl \
    --retry 10 \
    --retry-delay 0 \
    --retry-max-time 10 \
    --connect-timeout 1 \
    --retry-connrefused \
    -sf "${@}")
  done
}


collector() {
  local output
  local output_json
  local amount
  local line

  line="# TYPE node_textfile_exchange_rates gauge"
  >&2 echo "debug:$line"
  output+="${line}\n"

  output_json=$(curl_w -X GET "https://api.coingecko.com/api/v3/simple/price?ids=$IDS&vs_currencies=usd")

  for i in ${IDS//,/$IFS}; do

    amount=$(echo "$output_json" | jq -re --arg i "$i" '.[$i].usd')
    line="exchange_rates{chain_id=\"$i\"} ${amount}"
    >&2 echo "debug:$line"

    if [ "$amount" != "null" ] && [ "$amount" != "" ] && [ "$amount" != "0" ] && echo "${amount}" | bc >/dev/null; then
      output+="${line}\n"
    else
      # script exits on any error, so we can use absent() on alerts
      exit 1
    fi

  done


  if [ "$amount" != "null" ] && [ "$amount" != "" ] && [ "$amount" != "0" ] && echo "${amount}" | bc >/dev/null; then
    output+="${line}\n"
  else
    # script exits on any error, so we can use absent() on alerts
    exit 1
  fi

  echo -en "${output}"
  echo

}

collector | sponge "$OUTPUT"
cat "$OUTPUT"
