#!/usr/bin/env bash

TEMP_ID="lt-091dc1f3bbce4364e"
TEMP_VER=2

ec2 run instances --launch-template LaunchTemplateId=${TEMP_ID},Version=${TEMP_VER}