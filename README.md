# Azure Firewall: Forced Tunneling Pattern (Split Planes)

This repository contains the deployment-ready Terraform reference architecture demonstrating how to successfully configure **Azure Firewall with Forced Tunneling**.

### The Problem
When you configure an Azure Firewall (or standard NVAs) and attempt to force all 0.0.0.0/0 traffic to your on-premises datacenter (via a Route Table), the firewall will often fail or degrade. This happens because Microsoft's underlying Azure control plane cannot communicate with the firewall to perform health checks, push updates, or sync metrics—its traffic is being blackholed to your corporate network.

### The Solution
Azure Firewall supports a **Forced Tunneling** mode. Under this configuration, the firewall uses two distinct subnets:
1. **`AzureFirewallSubnet` (Data Plane):** Handles all user and application traffic. The 0.0.0.0/0 route here points to your on-premises firewall/NVA.
2. **`AzureFirewallMgmtSubnet` (Management Plane):** A dedicated escape hatch that routes directly to the `Internet`, allowing Azure's control plane to manage the appliance without routing through your corporate network.

### Read the Full Blog Post
For an in-depth explanation of why compliance teams frequently get this wrong and how to approach it strategically, read the full thought leadership post:
👉 **[Breaking the Cloud: The Hidden Dangers of Azure Forced Tunneling](https://portfolio.upendrakumar.com/blog/2026-02-19-breaking-the-cloud-forced-tunneling.html)**

### Usage

1. **Clone the repository.**
2. **Review `variables.tf`** to adjust the CIDR ranges and your on-premises firewall IP address.
3. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

*Disclaimer: This is reference architecture provided for educational purposes. Ensure you review all route tables and IP schemes before deploying to a production environment.*
