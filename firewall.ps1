# a) Salvar o estado atual do firewall
$backupFile = "C:\Windows\System32\firewall-saved.rules"
netsh advfirewall export $backupFile
Write-Output "Regras de firewall salvas em $backupFile"

# b) Resetar regras existentes
Write-Output "Resetando regras atuais do Firewall..."
netsh advfirewall reset

# c) Bloquear todo o tráfego de saída por padrão
Write-Output "Bloqueando todo o tráfego de saída por padrão..."
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Block

# d) Permitir tráfego DNS (porta 53)
New-NetFirewallRule -DisplayName "Allow DNS" -Direction Outbound -Protocol UDP -RemotePort 53 -Action Allow
New-NetFirewallRule -DisplayName "Allow DNS TCP" -Direction Outbound -Protocol TCP -RemotePort 53 -Action Allow

# e) Permitir tráfego HTTPS (443) para os domínios permitidos
$allowedDomains = @(
    "react.dev",
    "mui.com",
    "docker.com",
    "github.com",
    "npmjs.com",
    "getbootstrap.com",
    "microsoft.com" # abrangente para a loja de apps
)

foreach ($domain in $allowedDomains) {
    $ips = [System.Net.Dns]::GetHostAddresses($domain) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
    foreach ($ip in $ips) {
        New-NetFirewallRule -DisplayName "Allow HTTPS to $domain ($ip)" `
            -Direction Outbound `
            -Protocol TCP `
            -RemotePort 443 `
            -RemoteAddress $ip.IPAddressToString `
            -Action Allow
    }
}

Write-Output "Firewall configurado para permitir acesso apenas aos domínios especificados."

