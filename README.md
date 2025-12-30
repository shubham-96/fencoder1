# fencoder1

This repository contains infrastructure & utility scripts for managing & deploying resources for video encoding using ffmpeg.

**⚠️ THIS REPOSITORY HAS BEEN ARCHIVED AND IS NOW READ-ONLY ⚠️**

This repo was created to manually test the encoding workflow before automating it (see [fencoder2](https://github.com/shubham-96/fencoder2)).

## Directory Structure

- `bin/`
  - `mount-ebs.sh`: Shell script for mounting EBS volumes.
- `infra/`
  - `main.tf`, `provider.tf`, `variables.tf`, `data.tf`, `iam.tf`: Terraform configuration files for provisioning infrastructure.
  - `terraform.tfvars`, `terraform.tfvars.example`: Variable definitions for Terraform.

## Getting Started

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- AWS CLI configured with appropriate credentials
- An AMI with ffmpeg installed (I created my own but you can find one on AMI Marketplace. Or you can install ffmpeg everytime you spin up a new instance)

### Usage

#### Infrastructure Setup
1. Navigate to the `infra/` directory:
   ```sh
   cd infra
   ```
2. Create a `terraform.tfvars` & add the required variables (see `terraform.tfvars.example` for reference)

3. Initialize Terraform:
   ```sh
   terraform init
   ```
4. Review and update `terraform.tfvars` as needed.
5. Create & review terraform plan:
   ```sh
   terraform plan -out=tfplan
   ``` 
5. Apply the Terraform configuration:
   ```sh
   terraform apply tfplan
   ```

> Terraform will create access to EC2 only from the computer where you ran terraform apply (using its IP). You wont be allowed access from anywhere else

#### Workflow
1. ssh into the EC2 instance using your ssh key & EC2's public address shown in the terraform output
   ```sh
   ssh -i "~/.ssh/my_ec2_key" ubuntu@ec2-xx-xxx-xx-xx.us-east-1.compute.amazonaws.com
   ```
