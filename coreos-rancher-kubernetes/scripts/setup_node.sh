#!/bin/bash -x

# Configuration
rancher_server_ip=$1
rancher_version=$2
rancher_login=$3
rancher_password=$4
rancher_cluster_name=$5

# Get agent ip
agent_ip=`ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

# Get node id
node_id=`ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | cut -d . -f 4`

# Login to rancher server
login_token=$(
    curl -s "https://$rancher_server_ip/v3-public/localProviders/local?action=login" \
        -H 'content-type: application/json' \
        --data-binary '{"username":"'$rancher_login'","password":"'$rancher_password'"}' \
        --insecure | jq -r .token
)
echo $login_token

# Get cluster id
cluster_id=$(
    curl -s "https://$rancher_server_ip/v3/clusters?name=$rancher_cluster_name" \
        -H 'content-type: application/json' \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .data[].id
)
echo $cluster_id

# Get agent image name
agent_image=$(
    curl -s "https://$rancher_server_ip/v3/settings/agent-image" \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .value
)
echo $agent_image

# Create agent token
agent_token=$(
    curl -s "https://$rancher_server_ip/v3/clusters/$cluster_id/clusterregistrationtoken" \
        -H 'content-type: application/json' \
        -H "Authorization: Bearer $login_token" \
        --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$cluster_id'"}' \
        --insecure | jq -r .token
)

# Get agent token
echo $agent_token

# Get CA checksum
ca_checksum=$(
    curl -s "https://$rancher_server_ip/v3/settings/cacerts" \
        -H "Authorization: Bearer $login_token" \
        --insecure | jq -r .value | sha256sum | awk '{ print $1 }'
)
echo $ca_checksum

# Install agent
sudo docker run -d --privileged --restart=unless-stopped --net=host \
    -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run \
    $agent_image \
    --server https://$rancher_server_ip \
    --token $agent_token --ca-checksum $ca_checksum \
    --address $agent_ip --internal-address $agent_ip \
    --etcd --controlplane --worker