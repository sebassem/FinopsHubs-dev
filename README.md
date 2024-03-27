# FinOps hub public deployment

To deploy leverage the existing bicepparam file.

```powershell
az deployment group create -f .\main.bicep -p .\main.bicepparam -g <resource group name>
```
