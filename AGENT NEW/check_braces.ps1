$html = Get-Content -Encoding utf8 index.html -Raw
$startTag = "<script>"
$endTag = "</script>"
$scriptStart = $html.LastIndexOf($startTag)
$scriptEnd = $html.LastIndexOf($endTag)
$js = $html.Substring($scriptStart + $startTag.Length, $scriptEnd - $scriptStart - $startTag.Length)

$openCurlies = ([regex]::Matches($js, '\{')).Count
$closeCurlies = ([regex]::Matches($js, '\}')).Count
Write-Host "Curlies: $openCurlies open, $closeCurlies close"

$openParens = ([regex]::Matches($js, '\(')).Count
$closeParens = ([regex]::Matches($js, '\)')).Count
Write-Host "Parens: $openParens open, $closeParens close"

if ($openCurlies -eq $closeCurlies -and $openParens -eq $closeParens) {
    Write-Host "All brackets balanced perfectly!" -ForegroundColor Green
} else {
    Write-Host "Bracket mismatch!" -ForegroundColor Red
}
