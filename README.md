# Obelion Terraform

Lightweight Terraform project to provision a VPC, public subnets, two EC2 instances (frontend/backend) and a private MySQL RDS instance.



## Prerequisites
- Terraform >= 1.0
- AWS credentials configured (~/.aws/credentials or environment variables)
- Recommended: a single-purpose AWS account or a sandbox

## Quick usage
```bash
cd /home/tokal/Desktop/Obelion-terraform
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform show tfplan
# when ready:
terraform apply tfplan
```

## Important outputs
The project defines these Terraform outputs (available after apply):
- `backend_public_ip` — public IP of the backend EC2
- `frontend_public_ip` — public IP of the frontend EC2
- `rds_endpoint` — RDS connection endpoint

View outputs:
```bash
terraform output
terraform output backend_public_ip
```



## Security notes
- Do not commit terraform.tfstate or sensitive tfvars. See `.gitignore`.
- Avoid default DB passwords in production — use a secrets manager or environment variables.
- Restrict SSH access (currently 0.0.0.0/0) to your IP or use a bastion host.

## Screenshots / Images
Place images in `images/` and commit them (or keep locally). Example filenames are used below.

1) Configuration is validated

<img width="1188" height="719" alt="Screenshot from 2025-11-23 12-07-30" src="https://github.com/user-attachments/assets/a6c4559a-bf27-4b68-9a5e-1b946ebd0bee" />


2) Outputs

<img width="1188" height="719" alt="Screenshot from 2025-11-23 12-06-03" src="https://github.com/user-attachments/assets/6e32a63e-e3dd-4cc0-a5c0-9ed00bbf548f" />


3) Architecture diagram

<img width="1188" height="719" alt="Screenshot from 2025-11-23 10-22-48" src="https://github.com/user-attachments/assets/476f01b0-d85d-4121-a896-2066b399c60b" />

## Contributing
- Run `terraform fmt` and `terraform validate` before committing.
- Keep secrets out of the repository.
