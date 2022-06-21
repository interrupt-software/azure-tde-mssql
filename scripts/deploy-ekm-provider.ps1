$EKM_PROVIDER_SOURCE="https://releases.hashicorp.com/vault-mssql-ekm-provider/0.1.0+ent/vault-mssql-ekm-provider_0.1.0+ent_windows_amd64.zip"
$EKM_PROVIDER_ZIP_FILE="C:\Users\mssql-tde-dev\Downloads\vault-mssql-ekm-provider_0.1.0+ent_windows_amd64.zip"
$EKM_PROVIDER_MSI_FILE="C:\Users\mssql-tde-dev\Downloads\vault-mssql-ekm-provider.msi"
$EKM_PROVIDER_LOG_FILE="C:\Users\mssql-tde-dev\Downloads\vault-mssql-ekm-provider.log"

Invoke-WebRequest -URI $EKM_PROVIDER_SOURCE -Outfile $EKM_PROVIDER_ZIP_FILE
Expand-Archive $EKM_PROVIDER_ZIP_FILE -DestinationPath "C:\Users\mssql-tde-dev\Downloads"
Start-Process -FilePath "msiexec" -ArgumentList "/i $EKM_PROVIDER_MSI_FILE /quiet -l $EKM_PROVIDER_LOG_FILE"