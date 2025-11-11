name = "lothslair"
environment = "dev"
location    = "cus"
azureRegion = "centralus"

spoke_vnet_rg_name = "rg-subnetworking"
spoke_vnet_name = "vnet-centralus-dev-lothslair"
spoke_subnet_name = "Default"

#tf_kv_name = "kv-tf-lothslair12265"
#tf_rg_name = "rg-terraform"

sql_administrator_login = "sqladmin"

###
# Azure DevOps Agent VM Parameters
#  Version 2
###
vm_publisher       = "Canonical"
vm_offer           = "0001-com-ubuntu-server-focal"
vm_sku             = "20_04-lts"
vm_version         = "latest"
vm_admin_username     = "vmadminuser"
vm_size            = "Standard_B2ms"


# Azure DevOps AAD Group (display name: AzureDevOps) object id for RBAC assignments
azure_devops_group_object_id = "c4fb595e-20c7-4138-bc2b-88d428854789"


