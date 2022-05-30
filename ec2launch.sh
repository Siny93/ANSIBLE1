#!/usr/bin/env bash
if [ -z "$1" ]; then
  echo -e "\e[1;31minput missing\e[0m"
  exit 1
fi

COMPONENT=$1
ENV=$2
if [ ! -z "$2" ]; then
  ENV="-${ENV}"
fi

TEMP_ID="lt-036bfca06cfea93b6"
TEMP_VER=5
ZONE_ID=Z0763712QSDNO6WPG06S

# check if instance is already there
CREATE_INSTANCE() {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | sed 's/"//g' | grep -E 'running|stopped' &>/dev/null

  if [ $? -eq 0 ]; then
    echo -e "\e[1;33minstance is already there\e[0m"
  else
      aws ec2 run-instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VER} --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]" "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq
  fi
  sleep 10


  IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].PrivateIpAddress | sed 's/"//g' | grep -v null)

  # update a dns record
  sed -e "s/IPADDRESS/${IPADDRESS}/" -e "s/COMPONENT/${COMPONENT}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq

}

if [ "$COMPONENT" == "all" ]; then
  for comp in frontend$ENV mongodb$ENV catalogue$ENV redis$ENV user$ENV cart$ENV; do
    COMPONENT=$comp
    CREATE_INSTANCE
  done
else
  COMPONENT=$COMPONENT$ENV
  CREATE_INSTANCE
fi