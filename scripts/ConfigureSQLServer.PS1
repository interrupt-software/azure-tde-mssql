$EKM_WORKING_DIR="C:\Users\mssql-tde-dev\Desktop"

if (!(Test-Path -Path $EKM_WORKING_DIR)) {
  New-Item -ItemType Directory -Path $EKM_WORKING_DIR
}

$BASE_URL = "https://raw.githubusercontent.com/interrupt-software/azure-tde-mssql/main/scripts"

$files = @(
  "01-ConfigureMSSQL_DB.sql", 
  "02-CheckMSSQL_DB.sql", 
  "03-RotateMSSQL_DEK.sql", 
  "04-Re-encryptMSSQL_DB.sql"
)

$files | forEach-Object {
 $URL = "$BASE_URL/$PSItem"
 $local = "$EKM_WORKING_DIR\$PSItem"
 Invoke-WebRequest -URI $URL -Outfile $local
}

$PS1Script_Local="$EKM_WORKING_DIR\$files[0]"

((Get-Content -path $PS1Script_Local -Raw) -replace 'approle-role-id','APPROLE_ROLE_ID') | Set-Content -Path $PS1Script_Local

((Get-Content -path $PS1Script_Local -Raw) -replace 'approle-secret-id','APPROLE_SECRET_ID') | Set-Content -Path $PS1Script_Local

# Invoke-Sqlcmd -ServerInstance example-mssql -InputFile $PS1Script_Local -Verbose