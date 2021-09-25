#!/bin/bash
set -e
PUBLIC_IP=$(curl ipinfo.io/ip)
AWS_REGION=us-east-2
SG_ID=sg-0c8b28fbae64b1c66
/usr/local/bin/aws  ec2 authorize-security-group-ingress --region $AWS_REGION --group-id $SG_ID \
  --protocol tcp --port 22 --cidr $PUBLIC_IP/24
sleep 5

EC2_USERNAME=ubuntu
EC2_PUBLIC_IP=3.142.232.170

#Old EC2_PUBLIC_IP=18.159.135.7
scp -r -o  StrictHostKeyChecking=no $PWD/* $EC2_USERNAME@$EC2_PUBLIC_IP:~
ssh -o  StrictHostKeyChecking=no $EC2_USERNAME@$EC2_PUBLIC_IP bash << EOF
#$(aws ecr get-login --no-include-email --region us-east-2) && \
docker-compose.yml up -d
#&&
#docker images | awk '{print $3}' | xargs docker rmi
EOF

/usr/local/bin/aws ec2 revoke-security-group-ingress --region $AWS_REGION --group-id $SG_ID \
 --protocol tcp --port 22 --cidr $PUBLIC_IP/24
