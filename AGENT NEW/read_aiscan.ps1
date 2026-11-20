$lines = Get-Content -Encoding utf8 index.html
for ($i = 6100; $i -lt 6185; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
