# Readme

## Project Description
This project files demostrate a proof-of-concept of log4j vulnerability (CVE-2021-44228) on AWS using Terraform Infrastructure-as-a-code means.

# Credit
This poc was from :
https://github.com/kozmer/log4j-shell-poc  

This medium blog explain how her attempt walkthrough : 
https://chennylmf.medium.com/apache-log4j-shell-poc-exploits-5953c42fa873  

# My testing  

Personally, I tested using Windows + Powershell, cloud machine is Ubuntu 18 LTS. (Exploitation with kali or any linux)
  
# Pre-requisite

1. Installed AWS_CLI  
2. Installed Terraform CLI   
3. Have Access key ready

## RSA KEY

Create via web (Name it 'tf-aws'): https://console.aws.amazon.com/ec2/v2/home?#KeyPairs


## Get Access key
https://us-east-1.console.aws.amazon.com/iamv2/home#/users > Select user > Select section security_credentials

## Set Access key in shell

Powershell:  
`$env:AWS_ACCESS_KEY_ID="<user access key input>"`  
`$env:AWS_SECRET_ACCESS_KEY="<secret key input>"`  
`$env:AWS_DEFAULT_REGION="<region>"`  

  
Linux:  
`export AWS_ACCESS_KEY_ID="<user access key input>"`  
`export AWS_SECRET_ACCESS_KEY="<secret key input>`  
`export AWS_DEFAULT_REGION="<region>"`

# Usage
## Setup EC2 in AWS platform
 `cd single-instance`  
 `terraform init`    
 `terraform apply`   

Ensure `http:<aws host url>:8080` is accessible

## Prepare Remote / Localhost client (attacker):
Set execute permission  (in same workdir= single-instance)
`chmod +x runscript.sh`    

Run script with 2 supplied variable   
`./runscript.sh <1: desktop | cloud> <2: remote ip>`

Note the payload is displayed end of script

## Vulnerable Server:  
Visit `http:<aws host url>:8080`

Copy the payload into the username field then submit forms  
[[/images/Screenshot 2022-06-07 034332.png|exploit here]]


## References
Instance
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance


Spot instance:
https://www.tderflinger.com/en/ec2-spot-with-terraform


SSh to verify
https://jhooq.com/terraform-ssh-into-aws-ec2/
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html

[ssh key on the fly]
https://stackoverflow.com/questions/49743220/how-do-i-create-an-ssh-key-in-terraform

Waf
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_rule
https://medium.com/kudos-engineering/terraforming-amazons-web-application-firewall-e5c22b7d317d
https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/

Templating
https://spacelift.io/blog/terraform-templates

AWS AZ ID
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-availability-zones 

# Things learnt

* (lots of time spent) dont use provision as bash script / use template instead (could better see if could downgrade privilege)
* The RSA key generated from web is more reliable than manually generated from aws-cli if using .pem (the compatibility .pem file to SSH client or AWS server) otherwise use normal rsa key without pem.
* managed to use spot instance instead of normal for some cost saving
* Docker exposing port may overwrite firewall rules
* (lots of time spent) Setting up and Troublehouting networking take lots of time - Route, vpc need 1 sec-group and ec2 host need another sec-group - and both sec-group need to point to vpc


* 

# # Time keeping
* Start 06 Jun 11AM UTC+0800 - 07 Jun 4AM (Completed poc+tf+aws -waf) - 17 hours
* Start 07 Jun 1PM UTC+0800





