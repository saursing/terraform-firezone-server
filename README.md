# gcp-terraform-firezone-server

This project uses Terraform to automate the creation of a VM instance in Google Cloud Platform (GCP), and configure it as a firezone server for vpn usage.

## Getting Started

Before you begin, ensure that you have the following software installed on your local machine:

- Terraform
- Google Cloud SDK

You also need to have a GCP account with a project set up.

## Pre-req
Firezone requires a fully-qualified domain name (e.g. firezone.company.com) for production use. You'll need to create the appropriate DNS record at your registrar to achieve this. Typically this is either an A, CNAME, or AAAA record depending on your requirements. See more [here](https://www.firezone.dev/docs/deploy/)

## How to Use

1. Clone this repository to your local machine.
2. Enable "Cloud Resource Manager API" and "Compute Engine API" on the GCP project 
3. Navigate to the directory containing the Terraform configuration files.
4. Initialize your Terraform workspace, which will download the provider plugins for GCP:

    ```bash
    terraform init
    ```

5. Validate the configuration:

    ```bash
    terraform validate
    ```

6. Review the execution plan:

    ```bash
    terraform plan -out=tfplan -var 'project_id=your-gcp-project-id'
    ```

7. Apply the changes:

    ```bash
    terraform apply "tfplan"
    ```

8. After terraform deploys, you will get below ip in output. Use it to configure domain custom records.
    ```
    instance_ip_address = "xxx.xxx.xxx.xxx"
    ```

9. Run below command and find out the DEFAULT_ADMIN_EMAIL, DEFAULT_ADMIN_PASSWORD

    ```bash
    gcloud compute instances get-serial-port-output [INSTANCE_NAME] --zone=[ZONE] --project=[PROJECT_ID] 2>&1 | awk '/DEFAULT_ADMIN_EMAIL|DEFAULT_ADMIN_PASSWORD/ {for(i=1;i<=NF;i++) if ($i ~ /DEFAULT_ADMIN_EMAIL|DEFAULT_ADMIN_PASSWORD/) print $i}' | grep -E "DEFAULT_ADMIN_EMAIL=|DEFAULT_ADMIN_PASSWORD=" | grep -v "Specify --start"
    ```

    Output should look like:
    ```
    DEFAULT_ADMIN_EMAIL=admin@firezone.com
    DEFAULT_ADMIN_PASSWORD=xxxxxxxxxxxxxx
    ```

10. Go to your domain management service website (for google domains, go to https://domains.google.com/)

11. Take google domain as an example, go to manage, then navigate to DNS. Click on manage custom records. Fill out Host name, Type, and Data.
    ```
    | Host name | Type | TTL | Data |
    | --------- | ---- | --- | ---- |
    | fz        | A    | 3600| instance_ip_address (from step 7) |
    ```
    Then you will be able to login and manage the firezone server via `fz.yourdomain.com`

12. Congratulations! You have set up a firezone vpn server in GCP! Next you can login using the credentials retrieved from step 8 and perform below steps for vpn using. 

    [Create User](https://www.firezone.dev/docs/user-guides/add-users/)

    Then use the user created to log in and do below 

    [Add Device](https://www.firezone.dev/docs/user-guides/add-devices/)

    [Wireguard Installation and Connect](https://www.firezone.dev/docs/user-guides/client-instructions/)

## Workflow Chart

Here's a simple workflow chart for this project:

```mermaid
graph LR
  A(Start) --> B{Is GCP and Terraform set up?}
  B -->|Yes| C[Clone the repository]
  B -->|No| D[Set up GCP and Terraform]
  D --> C
  C --> E[Run terraform init]
  E --> F[Run terraform validate]
  F --> G[Run terraform plan]
  G --> H{Did plan succeed?}
  H -->|Yes| I[Run terraform apply]
  H -->|No| J[Fix issues and return to terraform plan]
  I --> K[Configure domain manually]
  K --> L[Connect VPN]
  L --> M(End)
  J --> G
