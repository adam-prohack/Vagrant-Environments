#!/bin/bash -x

# Configuration
rancher_server_ip=$1
rancher_version=$2
rancher_login=$3
rancher_password=$4
rancher_cluster_name=$5

# Install rancher server
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/server:$rancher_version
while true; do
    wget -T 5 -c https://$rancher_server_ip --no-check-certificate && break
    sleep 10
done

# Login to rancher server
login_token=$(
    curl "https://$rancher_server_ip/v3-public/localProviders/local?action=login" \
        -H 'content-type: application/json' \
        --data-binary '{"username":"'$rancher_login'","password":"admin"}' \
        --insecure | jq -r .token
)
echo $login_token

# Change rancher server password
curl "https://$rancher_server_ip/v3/users?action=changepassword" \
    -H 'content-type: application/json' \
    -H "Authorization: Bearer $login_token" \
    --data-binary '{"currentPassword":"'$rancher_login'","newPassword":"'$rancher_password'"}' \
    --insecure

# Create rancher API key
api_token=$(
    curl "https://$rancher_server_ip/v3/token" \
        -H 'content-type: application/json' \
        -H "Authorization: Bearer $login_token" \
        --data-binary '{"type":"token","description":"automation","name":""}' \
        --insecure | jq -r .token)
echo $api_token

# Create cluster
cluster_id=$(
    curl "https://$rancher_server_ip/v3/cluster" \
        -H 'content-type: application/json' \
        -H "Authorization: Bearer $api_token" \
        --data-binary '{"type":"cluster","nodes":[],"rancherKubernetesEngineConfig":{"type":"rancherKubernetesEngineConfig","hosts":[],"network":{"options":[],"plugin":"flannel"},"ignoreDockerVersion":true,"services":{"kubeApi":{"serviceClusterIpRange":"10.233.0.0/18","podSecurityPolicy":false,"extraArgs":{"v":"4"}},"kubeController":{"clusterCidr":"10.233.64.0/18","serviceClusterIpRange":"10.233.0.0/18"},"kubelet":{"clusterDnsServer":"10.233.0.3","clusterDomain":"cluster.local","infraContainerImage":"gcr.io/google_containers/pause-amd64:3.0"}},"authentication":{"options":[],"strategy":"x509"}},"googleKubernetesEngineConfig":null,"name":"'$rancher_cluster_name'","id":""}' \
        --insecure | jq -r .id
)
echo $cluster_id

# Create agent token
agent_token=$(
    curl "https://$rancher_server_ip/v3/clusterregistrationtoken" \
        -H 'content-type: application/json' \
        -H "Authorization: Bearer $api_token" \
        --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$cluster_id'"}' \
        --insecure | jq -r .token
)
echo $agent_token