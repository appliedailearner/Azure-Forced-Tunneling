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

## Deployment Guide
1. `terraform init` to download the azurerm provider.
2. `terraform plan -out=tfplan` to review the architecture and ensuring AzureFirewallManagementSubnet is mapped correctly.
3. `terraform apply tfplan` to execute. Allow 45+ minutes for Azure Firewall provisioning.

*Disclaimer: This is reference architecture provided for educational purposes. Ensure you review all route tables and IP schemes before deploying to a production environment.*

## References & Further Reading

### Microsoft Learn and Azure Official
- [Forced Tunneling](https://learn.microsoft.com/en-us/azure/firewall/forced-tunneling)
- [Management NIC](https://learn.microsoft.com/en-us/azure/firewall/management-nic)
- [SNAT Private Range](https://learn.microsoft.com/en-us/azure/firewall/snat-private-range)
- [Firewall FAQ](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq)
- [Firewall Known Issues](https://learn.microsoft.com/en-us/azure/firewall/firewall-known-issues)
- [Features by SKU](https://learn.microsoft.com/en-us/azure/firewall/features-by-sku)
- [Virtual Networks UDR Overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Manage Route Table](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)
- [Service Tags Overview](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview)
- [Firewall Service Tags](https://learn.microsoft.com/en-us/azure/firewall/service-tags)
- [Create Route Table Tutorial](https://learn.microsoft.com/en-us/azure/virtual-network/tutorial-create-route-table)
- [Virtual Network Service Endpoints Overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Deploy Firewall in Portal](https://learn.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal)

### Microsoft Troubleshooting (KMS and forced tunneling)
- [Custom Routes Enable KMS Activation](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/custom-routes-enable-kms-activation)
- [Windows Activation Stopped Working](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/windows-activation-stopped-working)

### Microsoft Architecture Center (patterns)
- [Firewall + Application Gateway](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/gateway/firewall-application-gateway)
- [Application Gateway before Azure Firewall](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/gateway/application-gateway-before-azure-firewall)

### TechCommunity Deep Dives
- [Configuring Azure Firewall in Forced Tunneling Mode](https://techcommunity.microsoft.com/blog/azurenetworksecurityblog/configuring-azure-firewall-in-forced-tunneling-mode/3581955)
- [Azure Firewall NAT Behaviors](https://techcommunity.microsoft.com/blog/azurenetworksecurityblog/azure-firewall-nat-behaviors/3825834)

### Historical Context
- [Forced Tunneling GA Announcement](https://azure.microsoft.com/en-us/blog/azure-firewall-forced-tunneling-and-sql-fqdn-filtering-now-generally-available/)
