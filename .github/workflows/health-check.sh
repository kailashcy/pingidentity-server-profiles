#!/bin/bash

check_deployment_readiness() {
    local deployment_name="$1"
    local namespace="$2"
    local timeout_sec="${3:-500}" # Default to 500 seconds if not provided

    if [ -z "$deployment_name" ] || [ -z "$namespace" ]; then
        echo "Error: Deployment name or namespace is missing."
        return 1
    fi

    echo "Checking readiness for deployment: $deployment_name in namespace: $namespace"

    # Start time
    local start_time=$(date +%s)

    # Check pod readiness
    while true; do
        local elapsed_time=$(( $(date +%s) - start_time ))
        if [ "$elapsed_time" -ge "$timeout_sec" ]; then
            echo "Timeout reached after $timeout_sec seconds. Exiting with failure."
            return 1
        fi

        # Get ready and desired replicas
        local ready_replicas
        local desired_replicas
        ready_replicas=$(kubectl get deployment "$deployment_name" -n "$namespace" -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
        desired_replicas=$(kubectl get deployment "$deployment_name" -n "$namespace" -o jsonpath='{.status.replicas}' 2>/dev/null)

        if [ -n "$ready_replicas" ] && [ -n "$desired_replicas" ] && [ "$ready_replicas" -eq "$desired_replicas" ]; then
            echo "Deployment '$deployment_name' is ready. Ready replicas: $ready_replicas."
            return 0
        fi

        echo "Waiting for pods to become ready... Ready: ${ready_replicas:-0}, Desired: ${desired_replicas:-0}"
        sleep 5
    done
}

# Call the function when invoked
if [ "$1" = "check_deployment_readiness" ]; then
    check_deployment_readiness "$2" "$3" "$4"
fi
