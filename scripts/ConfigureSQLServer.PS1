$EKM_WORKING_DIR="C:\Users\mssql-tde-dev\Desktop"

if (!(Test-Path -Path $EKM_WORKING_DIR)) {
  New-Item -ItemType Directory -Path $EKM_WORKING_DIR
}

$PS1Script_URL="https://raw.githubusercontent.com/interrupt-software/azure-tde-mssql/main/scripts/01-ConfigureMSSQL_DB.sql"
$PS1Script_Local="$EKM_WORKING_DIR\ConfigureSQLServer.sql"

Invoke-WebRequest -URI $PS1Script_URL -Outfile $PS1Script_Local

((Get-Content -path $PS1Script_Local -Raw) -replace 'approle-role-id','APPROLE_ROLE_ID') | Set-Content -Path $PS1Script_Local

((Get-Content -path $PS1Script_Local -Raw) -replace 'approle-secret-id','APPROLE_SECRET_ID') | Set-Content -Path $PS1Script_Local

# Invoke-Sqlcmd -ServerInstance example-mssql -InputFile $PS1Script_Local -Verbose