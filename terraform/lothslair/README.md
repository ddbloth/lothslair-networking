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

<h2>Also need to install some utilities</h2>
<ul>
  <li>zip/unzip Utilities (required): sudo apt install unzip -y</li>
  <li>Powershell (if you run PS scripts in pipeline):  sudo snap install powershell --classic</li>
  <li>Azure CLI (if you are running any az cli commands in pipeline):  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash</li>
</ul>

<h3>NOTES</h3>
<ul>
  <li>I see a failure on the first run in terraform install.  Terrafrom does install and is findable, however my ADO agent crashes runnign hte "verion" check of it.  Second run - the install is not done becuase it is found, and version check completes successfully
    <li>CAUSE:  CPU  - Need to upgrade to a 2 vCPU host.  Upgrade did cause loss of connection, but all setup (agent, etc) was still present</li>
  </li>

