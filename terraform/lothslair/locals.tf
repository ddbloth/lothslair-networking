locals {
  tf_kv_name = "kv-tf-${var.name}12265"
  tf_rg_name = "rg-terraform"

  tags = {
    Owner              = "Loth's Lair"
    Project            = "Loths Lair"
    Environment        = var.environment
    Toolkit            = "terraform"
  }
}