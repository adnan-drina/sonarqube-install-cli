#!/bin/bash

#Make sure you're connected to your OpenShift cluster with admin user before running this script

echo "Creating Sonarqube namespace"
oc apply -f sonarqube-namespace.yaml
echo "Sonarqube namespace created!"

echo "Deploying Sonarqube"
oc apply -f sonarqube-template.yaml -n sonarqube
echo "Sonarqube deployed!"

echo "Searching for available routes"
oc get routes -n sonarqube
echo "connect to the route named **sonarqube** using your browser \n
and login using credentials (username/password: admin/admin)"