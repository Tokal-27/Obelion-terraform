# Obelion Terraform

Lightweight Terraform project to provision a VPC, public subnet, two EC2 instances (frontend & backend) and a private MySQL RDS instance.

---

## Project overview
This repository creates:
- VPC, public subnet and private subnets (RDS)
- Internet Gateway and public route table
- Two EC2 instances (frontend, backend) in the public subnet
- MySQL RDS (private, multi-AZ subnets)
- Security groups for web and DB access
- Outputs for EC2 public IPs and RDS endpoint

---

## Files (what they do)
- `main.tf` — main resources: VPC, subnets, IGW, route table, security groups, EC2, DB subnet group, RDS instance.
- `Variables.tf` — configurable variables (aws_region, project_name, db_username, db_password).
- `outputs.tf` — exports `backend_public_ip`, `frontend_public_ip`, `rds_endpoint`.
- `.gitignore` — ignored files (Terraform state, .terraform, secrets, IDE files).
- `images/` — suggested folder to place screenshots referenced below.

---

## Prerequisites
- Terraform >= 1.0
- AWS CLI credentials configured (env or `~/.aws/credentials`)
- Recommended: dedicated sandbox AWS account and minimal IAM permissions for infra

---

## Quick usage
Run from repo root:
```bash
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform show tfplan
# when ready:
terraform apply tfplan
```

View outputs after apply:
```bash
terraform output
terraform output backend_public_ip
terraform output frontend_public_ip
terraform output rds_endpoint
```

---

## Validation
1. Ensure Terraform init and provider configured:
   - `terraform init`
2. Validate configuration:
   - `terraform fmt`
   - `terraform validate`  ← take screenshot to `images/validate.png`

---

## Outputs
After apply, expected outputs (see `outputs.tf`):
- `backend_public_ip` — backend EC2 public IP
- `frontend_public_ip` — frontend EC2 public IP
- `rds_endpoint` — RDS connection endpoint

Take screenshot of `terraform output` and save as `images/outputs.png`.

---

## Architecture diagram
Add a simple diagram illustrating:
- VPC
- Public subnet with two EC2 (frontend, backend) and Internet Gateway
- Private subnets (private_1, private_2) with RDS
- Security group arrows (web -> RDS on 3306)

Save diagram to `images/diagram.png`.

---

## Images / screenshots (place in `images/`)

1) Configuration validated
   
<img width="1188" height="719" alt="Screenshot from 2025-11-23 12-07-30" src="https://github.com/user-attachments/assets/b8b90b10-6db6-455a-a5c2-4c191e58d95c" />


2) Outputs (terraform output)

removed due to sensetivity 


3) Architecture diagram

<img width="1188" height="719" alt="Screenshot from 2025-11-23 10-22-48" src="https://github.com/user-attachments/assets/cb7c2183-2d26-4b8e-b47c-a129afaa1d0d" />



---

## Security notes
- Remove default DB password from `Variables.tf` and use a secrets manager or CI secrets.
- Restrict SSH access CIDR instead of `0.0.0.0/0`, or use a bastion host.
- Never commit `.tfstate`, `.tfvars` with secrets — use `.gitignore`.

---

## Helpful commands for cleaning repo size
- Stop tracking local state & caches:
```bash
git rm -r --cached .terraform terraform.tfstate terraform.tfstate.backup *.tfplan *.tfvars
git add .gitignore
git commit -m "Ignore Terraform state and local files"
```
- Shrink repo history if sensitive files were committed (use `bfg` or `git-filter-repo`) — follow tool docs.

---

## Where to edit
- Change region/project name in `Variables.tf`.
- Remove `db_password` default and provide via `terraform.tfvars` (ignored) or environment/CI secrets.

--- 

