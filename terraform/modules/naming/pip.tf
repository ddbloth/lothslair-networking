## public IP address
locals {
  # alphanum 1-80 with hypen, underscore and period.
  pip = {
    passthrough = (var.type == "pip" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
    hpstandard  = (var.type == "pip" && var.convention == "hpstandard") ? substr("${local.filtered.alphanumhup}${lookup(var.az_postfix, var.type)}-${local.filteredpostfix.alphanumhup}", 0, local.max) : null
    random      = (var.type == "pip" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
  }
}
output "pip" {
  depends_on = [local.pip]
  value      = local.pip[var.convention]
}