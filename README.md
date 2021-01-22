# chainlink
Chainlink monitoring

Prometheus config:
port :80 is a proxy which serve :6688 from localhost so that you can safetly export the metrics and use normal UFW rules to firewall it.
```
- job_name: node_exporter
    static_configs:
    - targets: ['monitoring01:9100']
      labels:
        service: 'monitoring'
        env: 'prod'

  - job_name: chainlink_exporter
    static_configs:
    - targets: ["chainlink01:80"]
      labels:
        service: 'chainlink'
        env: 'prod'
    - targets: ["chainlink-matic01:80"]
      labels:
        service: 'chainlink-matic'
        env: 'prod'
    - targets: ["chainlink-ocr01:80"]
      labels:
        service: 'chainlink-ocr'
        env: 'prod'

  - job_name: geth_exporter
    static_configs:
    - targets: ["geth_instance01:9090"]
      labels:
        service: 'geth_exporter'
        env: 'prod'
```


On the monitoring node (not needed on the chainlink server itself) install the scripts:
```
mkdir -p /run/node_exporter/collector

cp services/* /etc/systemd/system
cp scripts/* /usr/local/bin
```

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
```
systemctl enable --now price_exporter.timer
systemctl enable --now chainlink_rewards_exporter.timer
systemctl enable --now node_exporter.service
```
