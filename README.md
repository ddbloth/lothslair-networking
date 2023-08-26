# lothslair-networking
Terraform &amp; Pipelines for LothsLair Networking Configuration

This is an attempt to build a pipeline & terraform for Point-to-site VPN netowrking setup.

Sourced form this article: https://gmusumeci.medium.com/how-to-deploy-a-vpn-virtual-network-gateway-point-to-site-in-azure-using-terraform-d7202e901afc

Goals:
Create a private network configuration in Azure
Allow connectivity to it
Allow for implemenation fo Private Endpoints / Connections

Some Notes
Before running hte self signed cert script, you may need to do the following:
 Set-ExecutionPolicy -ExecutionPolicy Bypass

When looking for VM Images, you can run the following to list them:
 az vm image list --output table --publisher Canonical

 0001-com-ubuntu-server-jammy                 Canonical    22_04-lts                     Canonical:0001-com-ubuntu-server-jammy:22_04-lts:22.04.202204200                             22.04.202204200

 <h3>Post deployment - VPN Connection</h3>
 <ol>
   <li>Down Load Connection zip from Portal</li>
   <li>Run hte installer for your network Config/Architecture</li>
</ol>

