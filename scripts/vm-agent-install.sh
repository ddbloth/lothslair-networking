#!/bin/sh

# Creates directory & download ADO agent install files

su - thomasthorntoncloud -c "
mkdir myagent && cd myagent
wget https://vstsagentpackage.azureedge.net/agent/2.186.1/vsts-agent-linux-x64-2.186.1.tar.gz
tar zxvf vsts-agent-linux-x64-2.186.1.tar.gz"

# Unattended install

su - thomasthorntoncloud -c "
./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "https://dev.azure.com/LothsLair/" \
  --auth PAT \
  --token "bemct44ctffbsiumrzvy5cqsbh2ejnvdccu3curymzjhkn3cegiq" \
  --pool "lothslair" \
  --replace \
  --acceptTeeEula & wait $!"

cd /home/thomasthorntoncloud/
#Configure as a service
sudo ./svc.sh install thomasthorntoncloud

#Start svc
sudo ./svc.sh start