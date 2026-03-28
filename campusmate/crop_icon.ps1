Add-Type -AssemblyName System.Drawing

$src = "d:\mis\studentcompanionapp\campusmate\campusmate.png"
$bmp = [System.Drawing.Bitmap]::new($src)
$w = $bmp.Width
$h = $bmp.Height
Write-Host "Original: ${w}x${h}"

$top = 0
$bottom = $h - 1
$left = 0
$right = $w - 1

# Scan top
$foundTop = $false
for ($y = 0; $y -lt $h -and -not $foundTop; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.A -gt 10 -and -not ($px.R -gt 240 -and $px.G -gt 240 -and $px.B -gt 240)) {
            $top = $y
            $foundTop = $true
            break
        }
    }
}

# Scan bottom
$foundBottom = $false
for ($y = $h - 1; $y -ge 0 -and -not $foundBottom; $y--) {
    for ($x = 0; $x -lt $w; $x++) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.A -gt 10 -and -not ($px.R -gt 240 -and $px.G -gt 240 -and $px.B -gt 240)) {
            $bottom = $y
            $foundBottom = $true
            break
        }
    }
}

# Scan left
$foundLeft = $false
for ($x = 0; $x -lt $w -and -not $foundLeft; $x++) {
    for ($y = 0; $y -lt $h; $y++) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.A -gt 10 -and -not ($px.R -gt 240 -and $px.G -gt 240 -and $px.B -gt 240)) {
            $left = $x
            $foundLeft = $true
            break
        }
    }
}

# Scan right
$foundRight = $false
for ($x = $w - 1; $x -ge 0 -and -not $foundRight; $x--) {
    for ($y = 0; $y -lt $h; $y++) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.A -gt 10 -and -not ($px.R -gt 240 -and $px.G -gt 240 -and $px.B -gt 240)) {
            $right = $x
            $foundRight = $true
            break
        }
    }
}

Write-Host "Bounds: top=$top bottom=$bottom left=$left right=$right"
$cw = $right - $left + 1
$ch = $bottom - $top + 1
Write-Host "Cropped size: ${cw}x${ch}"

$rect = New-Object System.Drawing.Rectangle($left, $top, $cw, $ch)
$cropped = $bmp.Clone($rect, $bmp.PixelFormat)
$bmp.Dispose()
$cropped.Save($src)
$cropped.Dispose()
Write-Host "Saved cropped icon!"
