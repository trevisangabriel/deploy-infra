#!/bin/bash

cd 08-jenkins/deploy-infra-img-jap-app/terraform
curl "http://$(/home/ubuntu/terraform output | grep public_dns | awk '{print $2;exit}')"
