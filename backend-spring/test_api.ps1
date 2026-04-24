$ProgressPreference = 'SilentlyContinue'
$BASE = "http://localhost:8081"
$pass = 0; $fail = 0; $total = 0
$failedTests = @()

function T {
    param([string]$M, [string]$U, [string]$B, [string]$Tk, [string]$L, [int]$Ex = 200)
    $script:total++
    $h = @{}
    if ($Tk) { $h["Authorization"] = "Bearer $Tk" }
    try {
        $p = @{ Method = $M; Uri = "$BASE$U"; Headers = $h; ErrorAction = "Stop" }
        if ($B) { $p["Body"] = $B; $p["ContentType"] = "application/json" }
        $r = Invoke-RestMethod @p
        if ($r.success -eq $true) {
            $script:pass++
            Write-Host "  PASS $M $U - $L" -ForegroundColor Green
        } else {
            if ($Ex -ne 200) {
                $script:pass++
                Write-Host "  PASS $M $U - $L (expected $Ex)" -ForegroundColor Green
            } else {
                $script:fail++
                $script:failedTests += "$M $U - $L => $($r.message)"
                Write-Host "  FAIL $M $U - $L => $($r.message)" -ForegroundColor Red
            }
        }
        return $r
    } catch {
        $code = 0
        $msg = $_.Exception.Message
        try { $code = [int]$_.Exception.Response.StatusCode } catch {}
        if ($code -eq 0) {
            try {
                if ($_.Exception.Message -match "(\d{3})") { $code = [int]$matches[1] }
            } catch {}
        }
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            if ($stream) {
                $sr = [System.IO.StreamReader]::new($stream)
                $body = $sr.ReadToEnd()
                if ($body) { $eb = $body | ConvertFrom-Json; $msg = $eb.message }
            }
        } catch {}
        if ($code -eq $Ex -and $Ex -ne 200) {
            $script:pass++
            Write-Host "  PASS $M $U - $L (expected $Ex)" -ForegroundColor Green
            return $null
        }
        $script:fail++
        $script:failedTests += "$M $U - $L => [$code] $msg"
        Write-Host "  FAIL [$code] $M $U - $L => $msg" -ForegroundColor Red
        return $null
    }
}

Write-Host "`n========================================"
Write-Host "  CRONOS API FULL TEST SUITE"
Write-Host "========================================`n"

# ---- 1. HEALTH ----
Write-Host "--- 1. HEALTH ---" -ForegroundColor Yellow
T -M GET -U "/" -L "Health check"

# ---- 2. AUTH ----
Write-Host "`n--- 2. AUTH ---" -ForegroundColor Yellow
$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$r = T -M POST -U "/api/auth/register" -B "{`"name`":`"Konsumen$ts`",`"email`":`"konsumen$ts@test.id`",`"password`":`"Test@123`",`"phone`":`"08111$ts`",`"role`":`"konsumen`"}" -L "Register konsumen"
$kToken = ""; if ($r -and $r.data) { $kToken = $r.data.token }

$r = T -M POST -U "/api/auth/login" -B '{"email":"admin@cronos.id","password":"Admin@123"}' -L "Login admin"
$aToken = ""; if ($r -and $r.data) { $aToken = $r.data.token }

T -M POST -U "/api/auth/login" -B '{"email":"bad@x.com","password":"badpassword"}' -L "Login invalid (401)" -Ex 401
T -M GET -U "/api/auth/profile" -Tk $aToken -L "Get profile"
T -M PUT -U "/api/auth/profile" -B '{"name":"Admin Updated"}' -Tk $aToken -L "Update profile"
T -M GET -U "/api/auth/profile" -L "No token (401)" -Ex 401

# ---- 3. ADMIN USERS ----
Write-Host "`n--- 3. ADMIN ---" -ForegroundColor Yellow
$r = T -M POST -U "/api/admin/users" -B "{`"name`":`"Petambak$ts`",`"email`":`"pet$ts@test.id`",`"password`":`"Test@123`",`"phone`":`"08222$ts`",`"role`":`"petambak`"}" -Tk $aToken -L "Create petambak"
$petId = ""; if ($r -and $r.data) { $petId = $r.data.id }

$r = T -M POST -U "/api/admin/users" -B "{`"name`":`"Logistik$ts`",`"email`":`"log$ts@test.id`",`"password`":`"Test@123`",`"phone`":`"08333$ts`",`"role`":`"logistik`"}" -Tk $aToken -L "Create logistik"
$logId = ""; if ($r -and $r.data) { $logId = $r.data.id }

$r = T -M POST -U "/api/auth/login" -B "{`"email`":`"pet$ts@test.id`",`"password`":`"Test@123`"}" -L "Login petambak"
$pToken = ""; if ($r -and $r.data) { $pToken = $r.data.token }

$r = T -M POST -U "/api/auth/login" -B "{`"email`":`"log$ts@test.id`",`"password`":`"Test@123`"}" -L "Login logistik"
$lToken = ""; if ($r -and $r.data) { $lToken = $r.data.token }

T -M GET -U "/api/admin/users?page=1&limit=10" -Tk $aToken -L "List users"
T -M GET -U "/api/admin/users?page=1&limit=10&role=petambak" -Tk $aToken -L "List users (petambak)"
T -M GET -U "/api/admin/dashboard" -Tk $aToken -L "Admin dashboard"
T -M GET -U "/api/admin/users" -Tk $kToken -L "Admin by konsumen (403)" -Ex 403

# ---- 4. SHRIMP TYPES ----
Write-Host "`n--- 4. SHRIMP TYPES ---" -ForegroundColor Yellow
$r = T -M POST -U "/api/admin/shrimp-types" -B "{`"name`":`"Vaname$ts`",`"description`":`"Premium shrimp`"}" -Tk $aToken -L "Create shrimp type"
$stId = ""; if ($r -and $r.data) { $stId = $r.data.id }
T -M POST -U "/api/admin/shrimp-types" -B "{`"name`":`"Windu$ts`",`"description`":`"Wild shrimp`"}" -Tk $aToken -L "Create shrimp type 2"
T -M GET -U "/api/shrimp-types" -L "Get shrimp types (public)"
if ($stId) { T -M PUT -U "/api/admin/shrimp-types/$stId" -B "{`"name`":`"Vaname Updated $ts`"}" -Tk $aToken -L "Update shrimp type" }

# ---- 5. FARMS ----
Write-Host "`n--- 5. FARMS ---" -ForegroundColor Yellow
$r = T -M POST -U "/api/farms" -B '{"name":"Tambak Jaya","location":"Surabaya","area":5.5,"description":"Modern shrimp farm"}' -Tk $pToken -L "Create farm"
$fId = ""; if ($r -and $r.data) { $fId = $r.data.id }
T -M GET -U "/api/farms" -Tk $pToken -L "Get my farms"
if ($fId) {
    T -M GET -U "/api/farms/$fId" -Tk $pToken -L "Get farm by ID"
    T -M PUT -U "/api/farms/$fId" -B '{"name":"Tambak Updated","location":"Gresik","area":7}' -Tk $pToken -L "Update farm"
}

# ---- 6. PONDS ----
Write-Host "`n--- 6. PONDS ---" -ForegroundColor Yellow
$pdId = ""
if ($fId) {
    $r = T -M POST -U "/api/farms/$fId/ponds" -B '{"name":"Kolam A1","area":2.0,"depth":1.5,"status":"active"}' -Tk $pToken -L "Create pond"
    if ($r -and $r.data) { $pdId = $r.data.id }
    T -M GET -U "/api/farms/$fId/ponds" -Tk $pToken -L "Get ponds"
    if ($pdId) { T -M PUT -U "/api/farms/ponds/$pdId" -B '{"name":"Kolam Updated","area":3,"depth":2,"status":"active"}' -Tk $pToken -L "Update pond" }
}

# ---- 7. CULTIVATION ----
Write-Host "`n--- 7. CULTIVATION ---" -ForegroundColor Yellow
$cId = ""
if ($pdId -and $stId) {
    $r = T -M POST -U "/api/cultivations" -B "{`"pond_id`":`"$pdId`",`"shrimp_type_id`":`"$stId`",`"start_date`":`"2026-01-15T00:00:00`",`"expected_end_date`":`"2026-04-15T00:00:00`",`"density`":100,`"notes`":`"Cycle 1`"}" -Tk $pToken -L "Create cycle"
    if ($r -and $r.data) { $cId = $r.data.id }
}
T -M GET -U "/api/cultivations" -Tk $pToken -L "Get my cycles"
if ($cId) {
    T -M GET -U "/api/cultivations/$cId" -Tk $pToken -L "Get cycle"
    T -M POST -U "/api/cultivations/$cId/feed-logs" -B '{"feed_type":"Pelet","quantity":25.5,"feeding_time":"2026-02-01T08:00:00","notes":"AM feed"}' -Tk $pToken -L "Add feed log"
    T -M GET -U "/api/cultivations/$cId/feed-logs" -Tk $pToken -L "Get feed logs"
    T -M POST -U "/api/cultivations/$cId/water-quality" -B '{"temperature":28.5,"ph":7.8,"salinity":25,"dissolved_oxygen":5.5,"recorded_at":"2026-02-01T09:00:00"}' -Tk $pToken -L "Add water quality"
    T -M GET -U "/api/cultivations/$cId/water-quality" -Tk $pToken -L "Get water quality"
    T -M PUT -U "/api/cultivations/$cId" -B '{"status":"completed","notes":"Done"}' -Tk $pToken -L "Update cycle"
}

# ---- 8. HARVEST & BATCH ----
Write-Host "`n--- 8. HARVEST & BATCH ---" -ForegroundColor Yellow
$hId = ""
if ($cId) {
    $r = T -M POST -U "/api/harvests" -B "{`"cultivation_cycle_id`":`"$cId`",`"harvest_date`":`"2026-04-01T06:00:00`",`"total_weight`":500,`"shrimp_size`":`"40`",`"quality_grade`":`"A`"}" -Tk $pToken -L "Create harvest"
    if ($r -and $r.data) { $hId = $r.data.id }
}
T -M GET -U "/api/harvests" -Tk $pToken -L "Get harvests"
$bId = ""; $bCode = ""
if ($hId) {
    T -M GET -U "/api/harvests/$hId" -Tk $pToken -L "Get harvest"
    $r = T -M POST -U "/api/batches" -B "{`"harvest_id`":`"$hId`",`"quantity`":200}" -Tk $pToken -L "Create batch"
    if ($r -and $r.data) { $bId = $r.data.id; $bCode = $r.data.batch_code }
    T -M GET -U "/api/batches" -Tk $pToken -L "Get batches"
}

# ---- 9. PRODUCTS ----
Write-Host "`n--- 9. PRODUCTS ---" -ForegroundColor Yellow
$prBody = @{ name="Udang Segar"; description="Fresh shrimp"; price=85000; stock=100; shrimp_type="Vaname"; size="40"; unit="kg" }
if ($bId) { $prBody["batch_id"] = $bId }
$r = T -M POST -U "/api/products" -B ($prBody | ConvertTo-Json -Compress) -Tk $pToken -L "Create product"
$prId = ""; if ($r -and $r.data) { $prId = $r.data.id }

T -M GET -U "/api/products" -L "Marketplace (public)"
T -M GET -U "/api/products?search=udang" -L "Search products"
T -M GET -U "/api/products?sort_by=price_asc" -L "Sort by price"
if ($prId) {
    T -M GET -U "/api/products/$prId" -L "Get product"
    T -M GET -U "/api/products/$prId/reviews" -L "Get reviews"
}
T -M GET -U "/api/products/my" -Tk $pToken -L "My products"
if ($prId) { T -M PUT -U "/api/products/$prId" -B '{"name":"Udang Premium","price":90000,"stock":100}' -Tk $pToken -L "Update product" }

# ---- 10. ORDERS ----
Write-Host "`n--- 10. ORDERS ---" -ForegroundColor Yellow
$oId = ""
if ($prId) {
    $r = T -M POST -U "/api/orders" -B "{`"shipping_address`":`"Jl. Merdeka 1`",`"notes`":`"Pagi`",`"items`":[{`"product_id`":`"$prId`",`"quantity`":2}]}" -Tk $kToken -L "Create order"
    if ($r -and $r.data) { $oId = $r.data.id }
}
T -M GET -U "/api/orders?page=1&limit=10" -Tk $kToken -L "Get my orders"
if ($oId) { T -M GET -U "/api/orders/$oId" -Tk $kToken -L "Get order" }

# ---- 11. PAYMENTS ----
Write-Host "`n--- 11. PAYMENTS ---" -ForegroundColor Yellow
if ($oId) {
    T -M POST -U "/api/payments/create" -B "{`"order_id`":`"$oId`"}" -Tk $kToken -L "Create payment"
    T -M GET -U "/api/payments/$oId" -Tk $kToken -L "Get payment"
}
T -M POST -U "/api/payments/midtrans/webhook" -B '{"order_id":"CRONOS-fake","transaction_status":"settlement","payment_type":"bank_transfer","fraud_status":"accept"}' -L "Webhook (expect 400)" -Ex 400

# ---- 12. ADMIN ORDERS ----
Write-Host "`n--- 12. ADMIN ORDERS ---" -ForegroundColor Yellow
T -M GET -U "/api/admin/orders?page=1&limit=10" -Tk $aToken -L "Admin orders"

# ---- 13. SHIPMENTS ----
Write-Host "`n--- 13. SHIPMENTS ---" -ForegroundColor Yellow
$sId = ""
if ($oId -and $logId) {
    $r = T -M POST -U "/api/admin/shipments" -B "{`"order_id`":`"$oId`",`"courier_id`":`"$logId`",`"tracking_number`":`"JNE$ts`"}" -Tk $aToken -L "Create shipment"
    if ($r -and $r.data) { $sId = $r.data.id }
}
T -M GET -U "/api/admin/shipments" -Tk $aToken -L "Admin shipments"
T -M GET -U "/api/shipments" -Tk $lToken -L "Logistik shipments"
if ($sId) {
    T -M PUT -U "/api/shipments/$sId/status" -B '{"status":"pickup","location":"Surabaya","notes":"Picked up"}' -Tk $lToken -L "Shipment pickup"
    T -M GET -U "/api/shipments/$sId/logs" -Tk $lToken -L "Shipment logs"
    T -M PUT -U "/api/shipments/$sId/status" -B '{"status":"transit","location":"Jakarta","notes":"In transit"}' -Tk $lToken -L "Shipment transit"
    T -M PUT -U "/api/shipments/$sId/status" -B '{"status":"delivered","location":"Jakarta","notes":"Done"}' -Tk $lToken -L "Shipment delivered"
}

# ---- 14. REVIEWS ----
Write-Host "`n--- 14. REVIEWS ---" -ForegroundColor Yellow
if ($prId) {
    T -M POST -U "/api/reviews" -B "{`"product_id`":`"$prId`",`"rating`":5,`"comment`":`"Excellent!`"}" -Tk $kToken -L "Create review"
    T -M GET -U "/api/products/$prId/reviews" -L "Reviews after add"
}

# ---- 15. WITHDRAWALS ----
Write-Host "`n--- 15. WITHDRAWALS ---" -ForegroundColor Yellow
T -M POST -U "/api/withdrawals" -B '{"amount":50000,"bank_name":"BCA","account_number":"123456","account_name":"Petambak"}' -Tk $pToken -L "Create withdrawal (expect 400)" -Ex 400
T -M GET -U "/api/withdrawals" -Tk $pToken -L "My withdrawals"
T -M GET -U "/api/admin/withdrawals" -Tk $aToken -L "Admin withdrawals"

# ---- 16. SALES ----
Write-Host "`n--- 16. SALES ---" -ForegroundColor Yellow
T -M GET -U "/api/sales" -Tk $pToken -L "Seller orders"

# ---- 17. DASHBOARDS ----
Write-Host "`n--- 17. DASHBOARDS ---" -ForegroundColor Yellow
T -M GET -U "/api/dashboard/petambak" -Tk $pToken -L "Petambak dashboard"
T -M GET -U "/api/dashboard/logistik" -Tk $lToken -L "Logistik dashboard"
T -M GET -U "/api/dashboard/konsumen" -Tk $kToken -L "Konsumen dashboard"

# ---- 18. TRACEABILITY ----
Write-Host "`n--- 18. TRACEABILITY ---" -ForegroundColor Yellow
if ($bCode) { T -M GET -U "/api/traceability/$bCode" -L "Trace batch (public)" }
T -M GET -U "/api/admin/traceability/logs" -Tk $aToken -L "Admin trace logs"
T -M GET -U "/api/admin/traceability/verify" -Tk $aToken -L "Verify blockchain"

# ---- 19. CHAT ----
Write-Host "`n--- 19. CHAT ---" -ForegroundColor Yellow
T -M GET -U "/api/chat/rooms" -Tk $kToken -L "Chat rooms"
T -M GET -U "/api/chat/users" -Tk $kToken -L "Chat users"
if ($petId) {
    $r = T -M POST -U "/api/chat/rooms" -B "{`"type`":`"private`",`"target_user_id`":`"$petId`"}" -Tk $kToken -L "Create chat room"
    $rmId = ""; if ($r -and $r.data) { $rmId = $r.data.id }
    if ($rmId) { T -M GET -U "/api/chat/rooms/$rmId/messages" -Tk $kToken -L "Chat messages" }
}

# ---- 20. CANCEL ORDER ----
Write-Host "`n--- 20. CANCEL ORDER ---" -ForegroundColor Yellow
if ($prId) {
    $r = T -M POST -U "/api/orders" -B "{`"shipping_address`":`"Cancel Addr`",`"notes`":`"cancel`",`"items`":[{`"product_id`":`"$prId`",`"quantity`":1}]}" -Tk $kToken -L "Create order to cancel"
    $o2Id = ""; if ($r -and $r.data) { $o2Id = $r.data.id }
    if ($o2Id) { T -M PUT -U "/api/orders/$o2Id/cancel" -Tk $kToken -L "Cancel order" }
}

# ---- SUMMARY ----
Write-Host "`n========================================"
$summary = @()
$summary += "RESULTS: Total=$total  PASS=$pass  FAIL=$fail"
$rate = 0
if ($total -gt 0) { $rate = [math]::Round(($pass / $total) * 100, 1) }
$summary += "Success Rate: $rate%"
if ($fail -gt 0) {
    $summary += "FAILED TESTS:"
    foreach ($f in $failedTests) { $summary += "  - $f" }
}
$summary | Set-Content -Path "test_summary.txt" -Encoding UTF8

Write-Host "`nRESULTS: Total=$total  PASS=$pass  FAIL=$fail"
Write-Host "Success Rate: $rate%"
if ($fail -gt 0) {
    Write-Host "`nFAILED TESTS:" -ForegroundColor Red
    foreach ($f in $failedTests) { Write-Host "  - $f" -ForegroundColor Red }
}
Write-Host "`n========================================`n"
