#!/bin/sh

###
# Creates directory & download ADO agent install files
###
su - vmadminuser -c "
mkdir adoagent && cd adoagent
wget --no-check-certificate https://vstsagentpackage.azureedge.net/agent/3.230.0/vsts-agent-linux-x64-3.230.0.tar.gz
tar zxvf vsts-agent-linux-x64-3.230.0.tar.gz"

###
# Unattended install
###
# su - vmadminuser -c "
# ./config.sh --unattended \
#   --agent "${AZP_AGENT_NAME:-$(hostname)}" \
#   --url "https://dev.azure.com/HealthPartners" \
#   --auth PAT \
#   --token "<INSERT_TOKEN_HERE>" \
#   --pool "default" \
#   --replace \
#   --acceptTeeEula & wait $!"

# cd /home/adoagent/

## Configure as a service
# sudo ./svc.sh install

## Start svc
# sudo ./svc.sh start