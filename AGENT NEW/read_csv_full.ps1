$lines = Get-Content -Encoding utf8 index.html
for ($i = 5690; $i -lt 5825; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
