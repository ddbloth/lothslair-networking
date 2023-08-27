<h2>Notes on the ADo Agents VM BUild for LothsLair</h2>

When you destroy and rebuild the VM - the keys change, so you need to modify your known-host file to connect again via SSH

Get Agent Installed and hooked up
https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent?view=azure-devops

      curl https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz --output vsts-agent-linux-x64-3.225.0.tar.gz
      mkdir myagent && cd myagent
      tar zxvf ~/vsts-agent-linux-x64-3.225.0.tar.gz
      ./config.sh

      ** Run through prompts, make sure to have you ADO PAT

      Set the agent to run as a service
      sudo ./svc.sh install

      Start the service
      sudo ./svc.sh start

      Check the status of the service
      sudo ./svc.sh status
