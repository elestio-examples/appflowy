#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./postgres_data
mkdir -p ./minio_data

chown -R 1000:1000 ./postgres_data
chown -R 1000:1000 ./minio_data

chmod +x ./docker/portainer/setup.sh


cat /opt/elestio/startPostfix.sh > post.txt
filename="./post.txt"

SMTP_LOGIN=""
SMTP_PASSWORD=""

# Read the file line by line
while IFS= read -r line; do
  # Extract the values after the flags (-e)
  values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

  # Loop through each value and store in respective variables
  while IFS= read -r value; do
    if [[ $value == RELAYHOST_USERNAME=* ]]; then
      SMTP_LOGIN=${value#*=}
    elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
      SMTP_PASSWORD=${value#*=}
    fi
  done <<< "$values"

done < "$filename"

rm post.txt

cat << EOT >> ./.env

GOTRUE_SMTP_HOST=tuesday.mxrouting.net
APPFLOWY_MAILER_SMTP_HOST=tuesday.mxrouting.net
GOTRUE_SMTP_PORT=465
APPFLOWY_MAILER_SMTP_PORT=465
GOTRUE_SMTP_USER=${SMTP_LOGIN}
GOTRUE_SMTP_ADMIN_EMAIL=${SMTP_LOGIN}
GOTRUE_ADMIN_EMAIL=${SMTP_LOGIN}
APPFLOWY_MAILER_SMTP_USERNAME=${SMTP_LOGIN}
APPFLOWY_MAILER_SMTP_EMAIL=${SMTP_LOGIN}
GOTRUE_SMTP_PASS=${SMTP_PASSWORD}
GOTRUE_ADMIN_PASSWORD=${SMTP_PASSWORD}
APPFLOWY_MAILER_SMTP_PASSWORD=${SMTP_PASSWORD}
EOT
