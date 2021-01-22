#!/usr/bin/env bash

SCRIPT=${0##*/}
COLLECTOR_DIR="/run/node_exporter/collector/"
OUTPUT="${COLLECTOR_DIR}/${SCRIPT%.*}.prom"
mkdir -p "$COLLECTOR_DIR"


node_binary=/root/.nvm/versions/node/v15.2.0/bin/node
contract_runlog=0x0000000000000000000000000000000000000000      #ETH Node contract for runlog
admin_eth_addr=0x0000000000000000000000000000000000000000       #ETH Node address
admin_ocr_eth_addr=0x0000000000000000000000000000000000000000   #OCR Node Address
admin_matic_eth_addr=0x0000000000000000000000000000000000000000 #Matic Node Address
rpc=http://GETH_RPC:8545

denom=1000000000000000000
node_name=$(hostname)

runlog_reward=`/usr/bin/curl -s -X POST --header 'Content-Type: application/json' --data '{"jsonrpc":"2.0", "method": "eth_getStorageAt", "params": ["'$contract_runlog'", "0x4", "latest"], "id": 1}' $rpc  | /usr/bin/jq -r '.result' | tr a-z A-Z | sed -e "s/^0X//" | xargs -I % echo "ibase=16; scale=2;" % " / DE0B6B3A7640000" | /usr/bin/bc`

#Runlog
        echo "chainlink_rewards_runlog{job_type=\"runlog\",contract=\"$contract_runlog\"} $runlog_reward" > $OUTPUT

$node_binary /root/fluxmonitor.js $admin_eth_addr > /tmp/fluxmonitor.out
head -n -1 /tmp/fluxmonitor.out > /tmp/fluxmonitor_jobs.out
$node_binary /root/ocr.js $admin_ocr_eth_addr > /tmp/ocr.out
head -n -1 /tmp/ocr.out > /tmp/ocr_jobs.out
$node_binary /root/fluxmonitor_matic.js $admin_matic_eth_addr > /tmp/fluxmonitor_matic.out
head -n -1 /tmp/fluxmonitor_matic.out > /tmp/fluxmonitor_matic_jobs.out

total_rewards_flux_jobs=$(tail -n 1 /tmp/fluxmonitor.out)
total_rewards_ocr_jobs1=$(tail -n 1 /tmp/ocr.out)
total_rewards_ocr_jobs=$(echo "scale=2 ; $total_rewards_ocr_jobs1/1.0" | bc)
total_rewards_flux_matic_jobs=$(tail -n 1 /tmp/fluxmonitor_matic.out)

file="/tmp/fluxmonitor_jobs.out"
while IFS= read line
do
	contract=$(echo "$line"|awk '{print $1}')
	job_name=$(echo "$line"|awk '{print $2}')
	job_reward=$(echo "$line"|awk '{print $3}')
        echo "chainlink_rewards_fluxmonitor{job_type=\"fluxmonitor\",contract=\"$contract\",job_name=\"$job_name\"} $job_reward" >> $OUTPUT
done < "$file"
        echo "chainlink_rewards_fluxmonitor_total{job_type=\"fluxmonitor\"} $total_rewards_flux_jobs" >> $OUTPUT


file="/tmp/fluxmonitor_matic_jobs.out"
while IFS= read line
do
        contract=$(echo "$line"|awk '{print $1}')
        job_name=$(echo "$line"|awk '{print $2}')
        job_reward=$(echo "$line"|awk '{print $3}')
        echo "chainlink_rewards_matic{job_type=\"matic\",contract=\"$contract\",job_name=\"$job_name\"} $job_reward" >> $OUTPUT
done < "$file"
        echo "chainlink_rewards_matic_total{job_type=\"matic\"} $total_rewards_flux_matic_jobs" >> $OUTPUT


file="/tmp/ocr_jobs.out"
while IFS= read line
do
        contract=$(echo "$line"|awk '{print $1}')
        job_name=$(echo "$line"|awk '{print $2}')
        job_reward1=$(echo "$line"|awk '{print $3}')
	job_reward=$(echo "scale=2 ; $job_reward1/1.0" | bc)
        echo "chainlink_rewards_ocr{job_type=\"ocr\",contract=\"$contract\",job_name=\"$job_name\"} $job_reward" >> $OUTPUT
done < "$file"
        echo "chainlink_rewards_ocr_total{job_type=\"ocr\"} $total_rewards_ocr_jobs" >> $OUTPUT


