locals {
  tags = {
    Owner              = "Loth's Lair"
    Project            = "Loths Lair"
    Environment        = var.environment
    Toolkit            = "terraform"
  }

  rg_name = "rg-${var.azureRegion}-${var.environment}-lothslair"

}