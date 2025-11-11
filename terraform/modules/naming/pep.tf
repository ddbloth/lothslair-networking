## private endpoint
locals {
  # alphanum 1-80 with hypen, underscore and period.
  pe = {
    passthrough = (var.type == "pep" && var.convention == "passthrough") ? substr(local.filtered.alphanumhup, 0, local.max) : null
    hpstandard  = (var.type == "pep" && var.convention == "hpstandard") ? substr("${local.filtered.alphanumhup}${lookup(var.az_postfix, var.type)}${local.filteredpostfix.alphanumhup}", 0, local.max) : null
    random      = (var.type == "pep" && var.convention == "random") ? substr(local.fullyrandom, 0, local.max) : null
  }
}
output "pe" {
  depends_on = [local.pe]
  value      = local.pe[var.convention]
}