# What Is This?
A simple terraform project to create an EC2 instance with nginx and python installed. Also, generates ssh key to access the instance.  


# How To?
## Pre-requisites
1. Create an IAM user with Administrator access [here](https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/users)
2. Create Access key for the above user for CLI access. You will find the option under **Security Credentials** tab on the IAM user console.
3. Install aws cli on your machine. Steps [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
4. Run `aws configure --profile asmigar`. It will prompt for the Access Key and Secret Access Key you created in Step 2.
```bash
$ aws configure --profile asmigar
AWS Access Key ID [None]: [Enter your access key id here. And then press enter]
AWS Secret Access Key [None]: [Enter your corresponding secret access key here. And then press enter]
Default region name [None]: [You can keep it blank. So just press Enter]
Default output format [None]: [You can keep it blank. So just press Enter]
```
5. Verify your aws creds are configured by running `aws iam list-users --profile asmigar`. You should at least see the admin user you created in step 1.
```bash
$ aws iam list-users --profile asmigar
{
    "Users": [
        {
            "Path": "/",
            "UserName": "SagarM",
            "UserId": "AIDA5FTY6HTRVAX2LBERT",
            "Arn": "arn:aws:iam::905417997539:user/SagarM",
            "CreateDate": "2024-03-26T11:11:14+00:00",
            "PasswordLastUsed": "2024-04-01T04:59:30+00:00"
        }
    ]
}
```
6. Install Terraform's latest version from [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
7. Install Terragrunt's latest version from [here](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## Create Remote State
Terraform keeps all the info about the resources in a state file. Rather than keeping it on local disk, we store it on S3 bucket.
To learn more read the docs [here](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

1. Run below terraform command to create remote state bucket on your AWS account.
```bash
cd remote_state; terraform init; terraform apply --auto-approve
```
2. The above command will output the s3 bucket name. Copy the s3 bucket name. For example, 
```bash
Outputs:

terraform_state_bucket_name = [
"asmigar-<env1>-create-nginx-terraform-state-<aws_account_id>", 
"asmigar-<env2>-create-nginx-terraform-state-<aws_account_id>"
```

## Create Infra
1. Run below command to create EC2 instance. This will even output the ssh command to access the instance.
```bash
cd infra/dev; terragrunt init; terragrunt apply --auto-approve
```

## CI/CD
Github Actions are configured to apply terraform code. You would need to create environments in the GitHub repo and create some secrets needed in workflow `tf-ci.yml

## Report Bug
To raise issue/bug click [here](https://github.com/asmigar/create-nginx/issues/new).

## Want to Discuss More?
Feel free to reach out to me [here](https://sagarmaurya.dev/).
