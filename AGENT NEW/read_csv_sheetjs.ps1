$lines = Get-Content -Encoding utf8 index.html
for ($i = 5775; $i -lt 5850; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
