#!/usr/bin/env bash
if [ -z "$1" ]; then
  echo -e "\e[1;31minput missing\e[0m"
  exit 1
fi

COMPONENT=$1

TEMP_ID="lt-091dc1f3bbce4364e"
TEMP_VER=2

# check if instance is already there
aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | sed 's/"//g' | grep -E 'running|stopped' &>/dev/null

if [ $? -eq 0 ]; then
  echo -e "\e[1;33minstance is already there\e[0m"
  exit
fi



aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VER} --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]"
"ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq