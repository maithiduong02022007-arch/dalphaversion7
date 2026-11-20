# Máy chủ HTTP Localhost cho CRM AI Agent DAlpha (PowerShell tích hợp sẵn trên Windows)
$port = 8080
$prefix = "http://localhost:$port/"
$rootPath = $PSScriptRoot

if (-not $rootPath) {
    $rootPath = Get-Location
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Host "Loi mo cong: " $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " DALPHA TECHNOLOGY - AI AGENT CRM SYSTEM (LOCALHOST)" -ForegroundColor Green
Write-Host " Đang phục vụ tại: $prefix" -ForegroundColor Yellow
Write-Host " Nhấn Ctrl + C để dừng máy chủ." -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan

# Mở trình duyệt mặc định
Start-Process $prefix

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = $request.Url.LocalPath
        if ($urlPath -eq "/api/send-email" -and $request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
            $bodyStr = $reader.ReadToEnd()
            $reader.Close()
            $payload = $bodyStr | ConvertFrom-Json

            $smtpUser = "$($payload.smtp_user)".Trim()
            $smtpPass = "$($payload.smtp_pass)".Replace(" ", "").Trim()
            $toEmail = "$($payload.to_email)".Trim()

            if ([string]::IsNullOrWhiteSpace($smtpUser) -or [string]::IsNullOrWhiteSpace($smtpPass)) {
                $resObj = @{ success = $false; mode = "no_smtp"; message = "Chua cau hinh SMTP" } | ConvertTo-Json
            } else {
                try {
                    $mail = New-Object System.Net.Mail.MailMessage
                    $mail.From = New-Object System.Net.Mail.MailAddress($smtpUser, "DAlpha Technology AI")
                    $mail.To.Add($toEmail)
                    $mail.Subject = "$($payload.subject)"
                    $mail.SubjectEncoding = [System.Text.Encoding]::UTF8
                    $mail.BodyEncoding = [System.Text.Encoding]::UTF8
                    if (-not [string]::IsNullOrWhiteSpace("$($payload.html_body)")) {
                        $mail.Body = "$($payload.html_body)"
                        $mail.IsBodyHtml = $true
                    } else {
                        $mail.Body = "$($payload.text_body)"
                        $mail.IsBodyHtml = $false
                    }

                    $smtp = New-Object System.Net.Mail.SmtpClient("smtp.gmail.com", 587)
                    $smtp.EnableSsl = $true
                    $smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPass)
                    $smtp.Send($mail)

                    $resObj = @{ success = $true; mode = "smtp"; message = "Da gui email that thanh cong toi $toEmail" } | ConvertTo-Json
                } catch {
                    $resObj = @{ success = $false; mode = "smtp_error"; message = $_.Exception.Message } | ConvertTo-Json
                }
            }

            $resBytes = [System.Text.Encoding]::UTF8.GetBytes($resObj)
            $response.ContentType = "application/json; charset=utf-8"
            $response.ContentLength64 = $resBytes.Length
            $response.OutputStream.Write($resBytes, 0, $resBytes.Length)
            $response.Close()
            continue
        }

        if ($urlPath -eq "/" -or [string]::IsNullOrWhiteSpace($urlPath)) {
            $urlPath = "/landing.html"
        }

        $filePath = Join-Path $rootPath $urlPath.TrimStart('/')

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            
            # Content type detection
            if ($filePath.EndsWith(".html")) {
                $response.ContentType = "text/html; charset=utf-8"
            } elseif ($filePath.EndsWith(".js")) {
                $response.ContentType = "application/javascript; charset=utf-8"
            } elseif ($filePath.EndsWith(".css")) {
                $response.ContentType = "text/css; charset=utf-8"
            } elseif ($filePath.EndsWith(".json")) {
                $response.ContentType = "application/json; charset=utf-8"
            } else {
                $response.ContentType = "application/octet-stream"
            }

            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    } catch {
        # Bỏ qua lỗi ngắt kết nối client
    }
}

