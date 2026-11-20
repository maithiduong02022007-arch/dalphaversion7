$lines = Get-Content -Encoding utf8 index.html
for ($i = 6185; $i -lt 6260; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
