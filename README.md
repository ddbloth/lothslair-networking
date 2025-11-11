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

This repository contains two sets of pipeline automation in parallel: older Azure DevOps YAMLs under `workflow/` (kept for reference and compatibility) and the newer GitHub Actions workflow(s) used for primary deployments.

Primary GitHub Actions workflow

- Primary workflow (used for GitHub-based deployments): `.github/workflows/infra-deployment.yaml` — this is the canonical, entry-point workflow for repo-based CI/CD.
- The job steps call custom actions hosted in the separate repository `git@github.com:ddbloth/lothslair-workflow-actions.git` (see `uses: lothslair/lothslair-workflow-actions/*` in the workflow). Ensure that repository is accessible to your organization, and review the external actions' README for additional required inputs/secrets.

Required GitHub Actions secrets and variables

The `infra-deployment.yaml` workflow references the following secrets and conventions. Add these as repository secrets under Settings → Secrets and variables → Actions (or set them at the org level):

- `BACKEND_RG` — the resource group name that contains the Terraform backend storage account (example: `rg-terraform`).
- `BACKEND_SA` — the name of the storage account used for the Terraform backend (example: `sttfdata13669`).
- `backend_sa_container` — container is hard-coded to `tfstate` in the workflow; no secret required unless you change it.
- `backend_sa_key` — the backend key is set per-environment at runtime (`${{ inputs.environment }}.tfstate`) — no secret required for the key but note the naming pattern.

Environment-level backend variables (preferred)

The workflow can read non-secret backend values from GitHub Environment variables (recommended when the values differ between environments but are not sensitive). The workflow file has been updated to use `vars.BACKEND_RG` and `vars.BACKEND_SA` when jobs are scoped to the matching environment.

To add these per-environment variables:

1. In the repository, go to Settings → Environments and open the environment (e.g., `dev`, `staging`, `prod`).
2. Under that environment, add variables (not secrets) with the exact names:
  - `BACKEND_RG` = the resource group name for the backend in that environment
  - `BACKEND_SA` = the storage account name for the backend in that environment
3. Ensure the jobs that need these variables are configured with `environment: <name>` (the workflow already sets `environment: ${{ inputs.environment }}` for relevant jobs). When a job is associated with an environment, environment-scoped variables are available as `vars.<NAME>` in the workflow.

This pattern keeps resource identifiers configurable per-environment while treating sensitive keys (like the service principal JSON) as repository secrets.

Recommended secret for Azure authentication (when actions need to access Azure)

- `AZURE_CREDENTIALS` — recommended. Create a service principal and add its JSON (SDK-auth format) to this secret so GitHub Actions can authenticate to Azure. Example creation command (replace <SUBSCRIPTION_ID>):

    az ad sp create-for-rbac --name "LothLair-IaC-GHA-sp" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID> --sdk-auth

    Copy the JSON output and add it to the repository secret named `AZURE_CREDENTIALS` (Actions -> Secrets and variables -> Actions -> New repository secret).

Notes about the external actions repository

- The workflow depends heavily on `lothslair/lothslair-workflow-actions` (the `uses:` lines). That repository contains the implementation of setup, init, plan, apply, download, and validate actions used by the workflow. Review that repo's README for any additional secret names or inputs the actions require (for example, some actions may expect a storage account key or Key Vault references).
- To make reproduction easier, consider adding that actions repo as a submodule or pinning specific action versions/tags in `infra-deployment.yaml`.

Keeping Azure DevOps pipelines

- The `workflow/` Azure DevOps YAML files are kept in this repository for reference and for teams that still use ADO. Current production CI will use the GitHub Actions workflow above; ADO pipelines are maintained as "notes" and legacy support.

Quick checklist to add the GitHub secrets

1. Create the service principal and capture SDK-auth JSON (see example above).
2. In the GitHub repo, go to Settings → Secrets and variables → Actions → New repository secret.
3. Add `AZURE_CREDENTIALS` with the JSON value.
4. Add `BACKEND_RG` and `BACKEND_SA` secrets with the resource group and storage account names used for the Terraform backend.
5. Confirm the `lothslair-workflow-actions` repo is accessible to the organization and review that repo for any other secret requirements.

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

## Azure DevOps setup checklist (short)

Follow these steps to create the `LothLair-IaC-Terraform` Azure Resource Manager service connection and the pipeline variables/variable group used by the included pipelines.

1. Create or obtain a service principal
   - (CLI) Create a service principal that the pipelines will use:
     - Open a machine with Azure CLI and run:
       az ad sp create-for-rbac --name "LothLair-IaC-Terraform-sp" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-terraform
     - Save the output JSON (it contains appId, password, tenant). This is used for the service connection.
   - Recommended permissions:
     - Contributor on the resource group(s) where you create or manage resources (or narrower, as needed).
     - Storage Blob Data Contributor (or equivalent) on the storage account used for the Terraform backend if you want to scope down further.

2. Create the Azure DevOps service connection
   - In Azure DevOps go to Project settings → Service connections → New service connection → Azure Resource Manager.
   - Choose "Service principal (manual)" and paste the `appId` (client id), `password` (client secret) and `tenant` from the `az` command output.
   - Give the connection the exact name used in the pipelines: `LothLair-IaC-Terraform`.
   - Optionally restrict the scope to the specific subscription and resource group used for state (`rg-terraform`).

3. Create pipeline variables / variable group for backend values
   - In Azure DevOps go to Pipelines → Library → + Variable group.
   - Add variables used by the templates (example names and suggested values):
     - `tfStateRGName` = rg-terraform
     - `tfStateStorageAccountName` = sttfdata13669
     - `tfStateContainerName` = tfstate
     - `tfStateKeyName` = per-stack key (e.g., `dev`, `dev-network`, `lothslair-resources`)
   - Mark any sensitive variables as secret in the variable group (if they contain secrets).
   - If you use Azure Key Vault: link the Key Vault to the variable group (Use the "Link secrets from an Azure key vault as variables" option) and select the `LothLair-IaC-Terraform` service connection so the pipeline can retrieve secure values at runtime.

4. Update or confirm `params/*.tfvars` files
   - Ensure the `params/<environment>-ado-variables.tfvars` files exist and do not contain plaintext secrets. If secrets are required by tfvars, store them in Key Vault and reference them in pipelines or variable groups.

5. Validate the pipeline
   - In the Azure DevOps UI, create a pipeline run (use the YAML in `workflow/`), choose the variable group and service connection, then run the pipeline.
   - Confirm `terraform init` completes and the backend is initialized (it should use the storage account and container values from the variables). If the run fails with permissions errors, verify the service principal roles and the storage account ACLs.

6. Test destroy/apply flows safely
   - Use a non-production environment (example `dev`) first. The repository includes both plan/apply and plan/destroy flows — use the destroy YAMLs only when you want to remove infrastructure.

Notes and best practices
   - Do not commit secrets (client secrets, private keys, passwords) to the repository. Use Key Vault or the pipeline's secret variables.
   - Prefer least-privilege roles for the service principal. Use two service principals if you want more fine-grained separation (one limited to state management, another with broader resource creation rights).
   - Keep service connection names stable. The pipelines reference `LothLair-IaC-Terraform` explicitly; renaming it requires updating pipeline YAMLs or the parameter value.


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
