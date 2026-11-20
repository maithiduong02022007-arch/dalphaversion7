$lines = Get-Content -Encoding utf8 index.html
for ($i = 5675; $i -lt 5780; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
