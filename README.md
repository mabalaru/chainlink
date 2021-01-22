# chainlink
Chainlink monitoring

mkdir -p /run/node_exporter/collector

cp services/* /etc/systemd/system
cp scripts/* /usr/local/bin


Edit each .js file and update ws + jobs for your node. 
Edit chainlink_rewards_exporter.sh and modify:
```
node_binary=/root/.nvm/versions/node/v15.2.0/bin/node
js_path=/usr/local/bin
contract_runlog=0x0000000000000000000000000000000000000000      #ETH Node contract for runlog
admin_eth_addr=0x0000000000000000000000000000000000000000       #ETH Node address
admin_ocr_eth_addr=0x0000000000000000000000000000000000000000   #OCR Node Address
admin_matic_eth_addr=0x0000000000000000000000000000000000000000 #Matic Node Address
rpc=http://GETH_RPC:8545
```

systemctl enable --now price_exporter.timer
systemctl enable --now chainlink_rewards_exporter.timer
systemctl enable --now node_exporter.service

