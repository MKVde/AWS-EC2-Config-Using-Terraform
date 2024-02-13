# Terraform Homelab on AWS

This Terraform script automates the setup of a basic homelab on AWS, including essential tools and services. Follow the steps below to deploy and customize your homelab:

## Prerequisites

1. Install and configure the AWS CLI.
2. Install Terraform on your local machine.
3. Have an existing AWS Access keys  to send programmatic calls to AWS from the AWS CLI.

## Configuration

- **main.tf**: Defines AWS resources, including EC2 instance, security group, and SSH key pair.

- **variables.tf**: Customize variables like region, instance type, AMI, VPC, and user data.

- **output.tf**: Retrieves the public IP address and instance ID of the created EC2 instance.

## Usage

1. Modify variables in `variables.tf` to suit your preferences.

2. Run the following commands:

   ```bash
   terraform init
   terraform apply
   ```

3. After deployment, get the instance's public IP & instance's ID:

   ```bash
   terraform output
   ```

## Important Notes

- Configure AWS credentials with proper permissions.

- Review and adjust security group settings.

- Customize the `user_data` script for your homelab requirements.

- Ensure the security of your AWS key pair.

## Cleanup

To destroy resources, run:

```bash
terraform destroy
```
