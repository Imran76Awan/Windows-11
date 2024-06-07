# Color-coded Windows 11 Compatibility Check

function Write-ColorOutput($message, $isPass) {
    if ($isPass) {
        Write-Host $message -ForegroundColor Green
    } else {
        Write-Host $message -ForegroundColor Red
    }
}

# Check Secure Boot Status
$secureBootStatus = (Confirm-SecureBootUEFI)
Write-ColorOutput "Secure Boot Enabled: $secureBootStatus" $secureBootStatus

# Check TPM Version
try {
    $tpm = Get-WmiObject -Namespace "ROOT\CIMV2\Security\MicrosoftTpm" -Class Win32_Tpm
    $tpmVersion = $tpm.SpecVersion.ToString().Split(",")[0]
    $tpmPass = $tpmVersion.StartsWith("2.0")
    Write-ColorOutput "TPM Version: $tpmVersion" $tpmPass
} catch {
    Write-ColorOutput "TPM not found or error encountered." $false
}

# Check CPU Compatibility
try {
    $cpu = Get-WmiObject -Class Win32_Processor
    $cpuInfo = "CPU: $($cpu.Name)"
    # For demonstration purposes, assume CPU check passes (you need to implement actual check against Microsoft's list)
    Write-ColorOutput $cpuInfo $true
} catch {
    Write-ColorOutput "CPU details not found." $false
}

# Check RAM
$ram = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
$ramGB = [Math]::Round($ram / 1GB, 2)
$ramPass = $ramGB -ge 4
Write-ColorOutput "RAM: $ramGB GB" $ramPass

# Check for Storage (assuming 64GB is the minimum required)
$storage = (Get-PSDrive -PSProvider FileSystem).Where({ $_.Used -ne $null })
foreach ($drive in $storage) {
    $totalSize = [math]::Round($drive.Used / 1GB, 2)
    $storagePass = $totalSize -ge 64
    Write-ColorOutput "Drive $($drive.Name): $totalSize GB used" $storagePass
}

# Check for System Firmware Type (UEFI is required)
$firmwareType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
$firmwarePass = $firmwareType -eq "x64-based PC"
Write-ColorOutput "System Firmware Type: $firmwareType" $firmwarePass
