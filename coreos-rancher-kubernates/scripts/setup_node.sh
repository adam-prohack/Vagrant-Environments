#!/bin/bash -x

# Configuration
rancher_server_ip=$1
rancher_version=$2
rancher_login=$3
rancher_password=$4
rancher_cluster_name=$5

# Get agent ip
agent_ip=`ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

# Login to rancher server
login_token=$(
    curl "https://$rancher_server_ip/v3-public/localProviders/local?action=login" \
        -H 'content-type: application/json' \
        --data-binary '{"username":"'$rancher_login'","password":"'$rancher_password'"}' \
        --insecure | jq -r .token
)
echo $login_token

# Get cluster id
cluster_id=$(
    curl "https://$rancher_server_ip/v3/clusters?name='$rancher_cluster_name'" \
        -H 'content-type: application/json' \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .data[].id
)
echo $cluster_id

# Get agent image name
agent_image=$(
    curl "https://$rancher_server_ip/v3/settings/agent-image" \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .value
)
echo $agent_image

# Get agent token
agent_token=$(
    curl "https://$rancher_server_ip/v3/clusterregistrationtoken?name='$cluster_id'" \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .data[].token
)
echo $agent_token

# Get CA checksum
ca_checksum=$(
    curl "https://$rancher_server_ip/v3/settings/cacerts" \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .value | sha256sum | awk '{ print $1 }'
)
echo $ca_checksum

# Install agent
docker run -d --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock --net=host $agent_image \
    --server https://$rancher_server_ip \
    --token $agent_token \
    --ca-checksum $ca_checksum \
    --address $agent_ip \
    --internal-address $agent_ip \
    --etcd --controlplane --worker

# Check agent status
while true; do
    nodes_list=$(
        curl "https://$rancher_server_ip/v3/nodes?limit=-1" \
            -H "Authorization: Bearer $login_token" \
            --insecure | jq '.data[] | .customConfig.internalAddress + "-" + .state'
    )
    echo $nodes_list
    if [[ $nodes_list = *"$agent_ip-active"* ]]; then
        break
    fi
    sleep 15
done