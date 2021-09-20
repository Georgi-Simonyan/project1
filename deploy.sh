#!/bin/bash
set -e
PUBLIC_IP=$(curl ipinfo.io/ip)
AWS_REGION=eu-central-1
SG_ID=sg-0e36f051e3fe48761
/usr/local/bin/aws  ec2 authorize-security-group-ingress --region $AWS_REGION --group-id $SG_ID \
  --protocol tcp --port 22 --cidr $PUBLIC_IP/24
sleep 5

EC2_USERNAME=ec2-user
EC2_PUBLIC_IP=18.157.74.101

#Old EC2_PUBLIC_IP=18.159.135.7
scp -r -o  StrictHostKeyChecking=no $PWD/* $EC2_USERNAME@$EC2_PUBLIC_IP:~
ssh -o  StrictHostKeyChecking=no $EC2_USERNAME@$EC2_PUBLIC_IP bash << EOF
$(aws ecr get-login --no-include-email --region eu-central-1) && \
docker-compose up -d
#&& \
#docker images | awk '{print $3}' | xargs docker rmi
EOF

/usr/local/bin/aws ec2 revoke-security-group-ingress --region $AWS_REGION --group-id $SG_ID \
 --protocol tcp --port 22 --cidr $PUBLIC_IP/24
