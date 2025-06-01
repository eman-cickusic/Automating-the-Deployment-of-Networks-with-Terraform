# Automating the Deployment of Networks with Terraform

This project demonstrates how to automate the deployment of Google Cloud Platform (GCP) networks using Terraform. It creates three different network configurations with firewall rules and VM instances.

## Overview

The project creates:
- **managementnet**: A custom-mode network with one subnet and one VM instance
- **privatenet**: A custom-mode network with two subnets and one VM instance  
- **mynetwork**: An auto-mode network with two VM instances

## Architecture

```
├── managementnet (Custom Mode)
│   ├── managementsubnet-us (10.130.0.0/20)
│   ├── Firewall rule (HTTP, SSH, RDP, ICMP)
│   └── managementnet-us-vm
│
├── privatenet (Custom Mode)
│   ├── privatesubnet-us (172.16.0.0/24)
│   ├── privatesubnet-second-subnet (172.20.0.0/24)
│   ├── Firewall rule (HTTP, SSH, RDP, ICMP)
│   └── privatenet-us-vm
│
└── mynetwork (Auto Mode)
    ├── Auto-created subnets in all regions
    ├── Firewall rule (HTTP, SSH, RDP, ICMP)
    ├── mynet-us-vm
    └── mynet-second-vm
```

## Project Structure

```
terraform-gcp-networks/
├── README.md
├── provider.tf              # Google Cloud provider configuration
├── managementnet.tf         # Management network resources
├── privatenet.tf           # Private network resources
├── mynetwork.tf            # Auto-mode network resources
├── instance/               # VM instance module
│   └── main.tf             # Reusable VM instance configuration
├── terraform.tfvars.example # Example variables file
└── .gitignore              # Git ignore file
```

## Prerequisites

- Google Cloud Platform account
- Terraform installed (version 0.12+)
- `gcloud` CLI configured with appropriate permissions
- Google Cloud project with the following APIs enabled:
  - Compute Engine API
  - VPC API

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd terraform-gcp-networks
   ```

2. **Set up your GCP project**
   ```bash
   export GOOGLE_PROJECT="your-project-id"
   gcloud config set project $GOOGLE_PROJECT
   gcloud auth application-default login
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the execution plan**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```

6. **Confirm the deployment**
   Type `yes` when prompted.

## Configuration Details

### Networks

**Management Network (Custom Mode)**
- Network: `managementnet`
- Subnet: `managementsubnet-us` (10.130.0.0/20)
- Region: Configurable (default: us-central1)

**Private Network (Custom Mode)**
- Network: `privatenet`
- Subnets: 
  - `privatesubnet-us` (172.16.0.0/24)
  - `privatesubnet-second-subnet` (172.20.0.0/24)
- Regions: Configurable

**My Network (Auto Mode)**
- Network: `mynetwork`
- Subnets: Auto-created in all regions
- Default IP ranges: 10.128.0.0/9

### Firewall Rules

All networks include firewall rules allowing:
- SSH (port 22)
- HTTP (port 80)
- RDP (port 3389)
- ICMP (ping)
- Source ranges: 0.0.0.0/0 (all IPs)

### VM Instances

All VM instances use:
- Machine type: `e2-standard-2` (configurable)
- Boot disk: Debian 11
- External IP: Ephemeral
- Network tags: None (firewall rules apply to all instances)

## Module Usage

The project includes a reusable VM instance module in the `instance/` directory. This module accepts the following variables:

- `instance_name`: Name of the VM instance (required)
- `instance_zone`: GCP zone for the instance (required)
- `instance_type`: Machine type (optional, default: e2-standard-2)
- `instance_subnetwork`: Subnetwork for the instance (required)

### Example module usage:
```hcl
module "my-vm" {
  source              = "./instance"
  instance_name       = "my-vm-instance"
  instance_zone       = "us-central1-a"
  instance_type       = "e2-micro"
  instance_subnetwork = google_compute_subnetwork.my-subnet.self_link
}
```

## Customization

### Regions and Zones
Update the region and zone values in the configuration files:
- Replace `"REGION 1"` with your desired primary region (e.g., "us-central1")
- Replace `"ZONE 1"` with your desired primary zone (e.g., "us-central1-a")
- Replace `"REGION 2"` and `"ZONE 2"` with your desired secondary region/zone

### IP Ranges
Modify the CIDR blocks in the network configuration files as needed:
- Management subnet: `10.130.0.0/20`
- Private subnet 1: `172.16.0.0/24`
- Private subnet 2: `172.20.0.0/24`

### VM Instance Types
Change the default machine type in `instance/main.tf` or override it when calling the module.

## Testing Connectivity

After deployment, you can test network connectivity:

1. **Between different networks** (should fail):
   ```bash
   # SSH to managementnet-us-vm
   ping <privatenet-us-vm-internal-ip>
   ```

2. **Within the same network** (should succeed):
   ```bash
   # SSH to mynet-us-vm
   ping <mynet-second-vm-internal-ip>
   ```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm destruction.

## Troubleshooting

### Common Issues

1. **Provider initialization fails**
   - Ensure you have the correct Google Cloud credentials
   - Verify your project ID is set correctly

2. **Resource creation fails**
   - Check that required APIs are enabled
   - Verify you have sufficient permissions
   - Ensure resource names are unique

3. **Connectivity issues**
   - Verify firewall rules are applied correctly
   - Check that VM instances are in the correct subnets
   - Confirm external IP addresses are assigned

### Terraform Commands

- `terraform fmt`: Format configuration files
- `terraform validate`: Validate configuration syntax
- `terraform plan`: Preview changes
- `terraform apply`: Apply changes
- `terraform destroy`: Destroy resources
- `terraform state list`: List managed resources

## Best Practices

1. **State Management**: Consider using remote state storage for production
2. **Variables**: Use variables for environment-specific values
3. **Modules**: Leverage the instance module pattern for reusability
4. **Naming**: Follow consistent naming conventions
5. **Security**: Restrict firewall rules to necessary ports and sources

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the configuration
5. Submit a pull request

## Resources

- [Terraform Google Cloud Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud VPC Documentation](https://cloud.google.com/vpc/docs)
- [Terraform Module Documentation](https://www.terraform.io/docs/modules/index.html)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
