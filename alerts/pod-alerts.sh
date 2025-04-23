#!/bin/bash

# alert receivers
#phone_numbers=("923087072788" "92xxxx")
phone_numbers=("923087072788")

# save env variable KUBECTL_VSPHERE_PASSWORD for the cronjob user of tkg cluster user used in following login command, or use -p 
kprod="kubectl vsphere login --server=10.50.49.1 --insecure-skip-tls-verify --vsphere-username service-acc-jenkins-wos2@vsphere.local --tanzu-kubernetes-cluster-name tkc-prod-wso2-ns001 --tanzu-kubernetes-cluster-namespace tkgs-prod-wso2-ns001"

# Check if the current context is not equal to "tkc-prod-wso2-ns001"
if [ "$(kubectl config current-context)" != "tkc-prod-wso2-ns001" ]; then
    $kprod
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] - LOG - Cluster not Logged In - Trying to Login"

    if [ "$(kubectl config current-context)" != "tkc-prod-wso2-ns001" ]; then
       $kprod
       echo "[$(date +"%Y-%m-%d %H:%M:%S")] - LOG - Cluster is not logged - Maybe down"
       
       alert_messages="TKG Alert\n\nAlert is unable to login JAZZ TKG Cluster" 
       # sending msg as cluster may not be connectable
       for number in "${phone_numbers[@]}"; do
          curl -H "Content-Type: application/json" -X POST --data "{\"MSISDN\": \"$number\",\"SHORTCODE\":\"JAZZ\",\"TEXT\":\"$alert_messages\"}" http://10.50.13.220:8281/ecarelive/sms/$number >> /dev/null 2>&1
       done

       #stop the remaining
       exit
    fi
fi

# Flag to check if all pods are in running state
all_running=true

# Get the list of pods in the 'wso2' namespace and their statuses
pod_statuses=$(kubectl get pods -n wso2 -o=jsonpath='{range .items[*]}{.metadata.name}:{.status.phase}{"\n"}{end}')

timestamp=$(date +"%Y-%m-%d %H:%M:%S")

alert_messages="JAZZ TKG Alert - Pod(s) Down"

while IFS= read -r pod_status; do
    pod_name=$(echo "$pod_status" | cut -d ':' -f 1)
    status=$(echo "$pod_status" | cut -d ':' -f 2)

    if [ "$status" != "Running" ] && [ "$status" != "Completed" ] && [ "$status" != "Succeeded" ];  then
        all_running=false
        echo "[$timestamp] - ERROR - POD_NAME=$pod_name - STATUS=$status"

        # Append alert message to the string
        alert_messages+="\n\n$pod_name = $status"
    fi
done <<< "$pod_statuses"

# Check if there are any alert messages to send
if [ "$all_running" = false ]; then
    for number in "${phone_numbers[@]}"; do
        # Send a single curl request with all the alert messages
        curl -H "Content-Type: application/json" -X POST --data "{\"MSISDN\": \"$number\",\"SHORTCODE\":\"JAZZ\",\"TEXT\":\"$alert_messages\"}" http://10.50.13.220:8281/ecarelive/sms/$number >> /dev/null 2>&1
    done
fi

# Check if all pods are running
if [ "$all_running" = true ]; then
    echo "[$timestamp] - INFO - All pods are running successfully"
fi
