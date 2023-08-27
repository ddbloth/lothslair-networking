<h2>Notes on the ADo Agents VM BUild for LothsLair</h2>

When you destroy and rebuild the VM - the keys change, so you need to modify your known-host file to connect again via SSH

Get Agent Installed and hooked up

      curl https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz --output vsts-agent-linux-x64-3.225.0.tar.gz
      ~/$ mkdir myagent && cd myagent
      ~/myagent$ tar zxvf ~/Downloads/vsts-agent-linux-x64-3.225.0.tar.gz
