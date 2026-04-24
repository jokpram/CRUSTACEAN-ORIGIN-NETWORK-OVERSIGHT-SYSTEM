$ProgressPreference = 'SilentlyContinue'
$BASE = "http://localhost:8081"
$token = ""

$r = Invoke-WebRequest -Method POST -Uri "$BASE/api/auth/login" -ContentType "application/json" -Body '{"email":"petambak1@cronos.id","password":"Test@123"}' -ErrorAction SilentlyContinue -UseBasicParsing
if ($r.Content) {
    $j = $r.Content | ConvertFrom-Json
    if ($j.data -and $j.data.token) {
        $token = $j.data.token
    }
}

if (-not $token) {
    Write-Host "Could not get token, trying pet@test.id..."
    # try the seeded user from the test
    $r = Invoke-WebRequest -Method POST -Uri "$BASE/api/auth/login" -ContentType "application/json" -Body '{"email":"pet@test.id","password":"Test@123"}' -ErrorAction SilentlyContinue -UseBasicParsing
    if ($r.Content) {
        $j = $r.Content | ConvertFrom-Json
        if ($j.data -and $j.data.token) {
            $token = $j.data.token
        }
    }
}

if ($token) {
    Write-Host "Got token, sending GET /api/cultivations"
    try {
        $r2 = Invoke-WebRequest -Method GET -Uri "$BASE/api/cultivations" -Headers @{"Authorization"="Bearer $token"} -ErrorAction Stop -UseBasicParsing
        Write-Host "Success: $($r2.StatusCode)"
        Write-Host $r2.Content
    } catch {
        Write-Host "Failed: $($_.Exception.Response.StatusCode)"
        $stream = $_.Exception.Response.GetResponseStream()
        $sr = [System.IO.StreamReader]::new($stream)
        $body = $sr.ReadToEnd()
        Write-Host "Error Body:"
        Write-Host $body
    }
} else {
    Write-Host "Could not login."
}
