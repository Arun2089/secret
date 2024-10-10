#!/bin/bash
output=$(aws secretsmanager get-secret-value --secret-id name)
secret_string=$(echo "$output" | jq -r '.SecretString')
key_value=$(echo "$secret_string" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
echo "$key_value" > .env
ccrypt -e -k arun .env

docker-compose up -d 
sleep 5

docker exec  my_nginx /bin/bash -c "apt update && apt install ccrypt"
docker exec  my_nginx /bin/bash -c "cd /usr/share/nginx/html/ && rm -f .env"
docker cp arun my_nginx:/usr/share/nginx/html/
docker cp .env.cpt my_nginx:/usr/share/nginx/html/
docker exec  my_nginx /bin/bash -c "cd /usr/share/nginx/html/ && ccrypt -d -k arun .env.cpt"


docker exec  my_nginx /bin/bash -c "cd /usr/share/nginx/html/ && cat .env > index.html"
rm -f .env.cpt
