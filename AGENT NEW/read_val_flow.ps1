$lines = Get-Content -Encoding utf8 index.html
for ($i = 6235; $i -lt 6310; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
