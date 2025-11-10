# LothLair - Networking Terraform & Deployment

This repository contains Terraform code, reusable modules, scripts, and CI workflows used to provision and manage the LothLair Azure networking and related infrastructure.

The project is organized to separate reusable modules from environment / stack definitions and includes automation for pipelines and VM provisioning helpers.

## Purpose

- Provide Terraform infrastructure-as-code for the LothLair environment and networking stacks.
- Share common, reusable modules for Azure resources (VMs, networking, databases, storage, etc.).
- Supply automation scripts and GitHub Actions workflows to deploy and destroy environments.

## Top-level layout

Root files and top-level directories (brief):

- `tfcode/` - Primary Terraform configuration for multiple stacks and environments.
	- `lothslair/` - Terraform for the main LothLair environment (stack-level code, params, README).
	- `lothslair-network/` - Terraform for network-focused resources (VNets, DNS zones, network modules, root cert).
	- `modules/` - Collection of reusable Terraform modules used by stacks (VM images, keyvault, network, databases, etc.).
	- `resources/` - Additional Terraform resources used across stacks.

- `modules/` - Module source code organized by resource type. Many modules are included (VMs, AD/roles, storage, databases, databricks, keyvault, networking, etc.). Use these as building blocks for stack configs.

- `workflow/` - GitHub Actions workflows used to automate Terraform deployments and resource deployments.
	- `lothslair/` and `lothslair-network/` contain pipeline YAMLs for deploying and destroying infrastructure.

- `scripts/` - Helper scripts used for local or remote provisioning.
	- `make-self-signed-cert.ps1` - PowerShell helper to generate a self-signed certificate (Windows).
	- `vm-agent-install.sh` - Shell script for installing VM agent components on Linux VMs.

## Important files of note

- `tfcode/lothslair-network/LothLair-RootCert.crt` - Root certificate used by networking stack.
- Many `params/*.tfvars` files exist under `tfcode/*/params/` — these provide environment-specific variables (examples: `dev-ado-variables.tfvars`).
- `modules/...` - each module folder contains `main.tf`, `variables.tf` and `outputs.tf` (or similar) — see individual module READMEs for details.

## Quickstart / Prerequisites

Before using the Terraform code or workflows, install and configure the following locally:

- git (to clone repository)
- Terraform (recommended v1.3+; match the version used by your CI/pipelines)
- Azure CLI (`az`) and authenticated subscription access (or use service principal credentials in CI)
- Optional: `jq`, `pwsh` (PowerShell) for Windows helpers, and common build tools

You should also be familiar with Terraform workspaces and how your organization manages state (remote backend, e.g., Azurerm storage account, or Terraform Cloud). The provided code expects state management to be configured in `providers.tf`/`backend` blocks or by CI.

## Typical local workflow (example)

1. Clone the repo:

	 git clone <your-repo-url>
	 cd lothslair-networking

2. Inspect the stack you want to work on, for example `tfcode/lothslair-network`.

3. Choose or create a `*.tfvars` file for your environment. Example files live under `tfcode/*/params/`.

4. Initialize Terraform and plan/apply:

	 terraform init
	 terraform plan -var-file=params/dev-ado-variables.tfvars
	 terraform apply -var-file=params/dev-ado-variables.tfvars

Note: Replace the `-var-file` value with the appropriate environment file or pass variables via the environment/CI.

## CI / GitHub Actions

This repository includes workflows in the `workflow/` directory. These automate common tasks such as:

- `lothslair-iac-deployment.yml` / destroy counterpart — deploy or tear down stacks for the LothLair environment.
- Terraform plan/apply flows for both `lothslair` and `lothslair-network` stacks.

Workflows expect secrets and service principals to be configured in the GitHub repository or organization (for example: AZURE_CREDENTIALS or service principal client id/secret/tenant). Review each workflow YAML to see required secrets and how the state backend is set up.

## Required service connections & pipeline variables

The repository uses Azure DevOps pipeline templates. The pipelines do not embed secret values in source; instead they reference Azure DevOps service connections and pipeline parameters. The key items to configure before running the pipelines are:

- Azure DevOps service connection(s):
	- `LothLair-IaC-Terraform` — this is the service connection referenced by the included ADO pipelines (`workflow/lothslair/*`, `workflow/lothslair-network/*`, `workflow/resources/*`). Configure this as an Azure Resource Manager service connection that uses a service principal with sufficient permissions (Contributor or a custom role allowing resource and storage account access) on the target subscription and resource group used for state.

- Terraform backend / pipeline variables (passed into pipeline templates):
	- `tfStateRGName` — resource group that holds the Terraform backend storage account (example value in pipelines: `rg-terraform`).
	- `tfStateStorageAccountName` — storage account name used for tfstate (example shown: `sttfdata13669`).
	- `tfStateContainerName` — blob container name used for state (example: `tfstate`).
	- `tfStateKeyName` — per-stack key name used for the tfstate file (examples: `dev`, `dev-network`, `lothslair-resources`).

- Parameter files: pipelines pass `-var-file` pointing to files named like `${environment}-ado-variables.tfvars` in each stack `params/` directory. Ensure these files are present (and do not contain committed secrets) or set equivalent pipeline variables/Key Vault references.

Notes & migration options:

- If you prefer to run these pipelines from GitHub Actions instead of ADO, create a GitHub secret named `AZURE_CREDENTIALS` containing the JSON of a service principal with equivalent rights (the format produced by `az ad sp create-for-rbac --sdk-auth`) and adapt the pipeline to use GitHub runners and that secret.
- The repository's ADO templates rely on the `serviceConnectionName` parameter rather than storing client id/secret in the YAML files. This is intentionally secure — the service connection stores secrets in Azure DevOps and is referenced by name in the pipeline YAMLs.

Files that reference the `LothLair-IaC-Terraform` connection:

- `workflow/lothslair/lothslair-iac-deployment.yml`
- `workflow/lothslair/lothslair-iac-deployment-destroy.yml`
- `workflow/lothslair-network/lothslair-iac-tf-deploy.yml`
- `workflow/lothslair-network/lothslair-iac-tf-destroy.yml`
- `workflow/resources/lothslair-resources-deployment.yml`
- `workflow/resources/lothslair-resources-deployment-destroy.yml`

If you'd like, I can add a short ADO setup checklist (steps to create the service connection, set pipeline variables and securely reference Key Vault) to the README — tell me whether you want a full step-by-step or a short checklist.

## Scripts

- `scripts/make-self-signed-cert.ps1` — helper to create a self-signed certificate used by the network stack for quick test/dev scenarios.
- `scripts/vm-agent-install.sh` — provision-time helper to install VM agent components (intended to be used by module `vm` provisioning or custom extension scripts).

## Modules & Reuse

Module code is under `modules/`. Each module is intended to be reusable across stacks. When creating or updating stacks:

- Prefer adding logic to a module when multiple stacks will reuse it.
- Keep module interfaces (inputs/outputs) stable to avoid breaking consumers.

Examples of modules (non-exhaustive): `azuread`, `databricks`, `keyvault`, `mssql_server`, `network`, `ubuntu_vm`, `windows_vm`, `naming`, and others.

## Environment and Params

Stacks contain `variables.tf` and `params/*.tfvars` files. Keep sensitive values out of checked-in tfvars — instead use secure mechanisms (Azure Key Vault, GitHub Secrets, or Terraform Cloud variables).

## Security & Secrets

- Do not commit secrets, passwords, or private keys to the repository.
- Use a remote state backend that supports locking (Azure Storage with blob lease, or Terraform Cloud) to avoid concurrent state writes.

## Common troubleshooting

- If Terraform complains about provider versions or plugins, run `terraform init -upgrade` to refresh plugins.
- Confirm Azure CLI is authenticated (`az login`) or that CI service principal has correct permissions.
- Check workflows for required secrets and backend configuration.

## Contributing

If you add modules or stacks:

1. Add or update module README with inputs/outputs and examples.
2. Add tests or a small smoke test plan describing how to validate the change.
3. Update CI workflows if stack inputs or backend config changes.

## Maintainer / Contact

Maintainer: repository owner `ddbloth` (git remote/owner: ddbloth). Open issues or PRs in this repository for questions, feature requests or bugs.

## License

No license file is included in the repository root. If you need to publish or share this code publicly, add a `LICENSE` file describing the intended license.

---
Last updated: 2025-11-09
