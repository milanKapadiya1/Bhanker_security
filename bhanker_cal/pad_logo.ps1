Add-Type -AssemblyName System.Drawing

$sourcePath = "c:\Users\Milan\OneDrive\Desktop\bhanker_security\bhanker_cal\assets\images\splash_logo.png"
$destPath = "c:\Users\Milan\OneDrive\Desktop\bhanker_security\bhanker_cal\assets\images\splash_logo_padded.png"

if (-not (Test-Path $sourcePath)) {
    Write-Error "Source file not found: $sourcePath"
    exit 1
}

$img = [System.Drawing.Image]::FromFile($sourcePath)
$width = $img.Width
$height = $img.Height

# Create a new bitmap with the same dimensions
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.Clear([System.Drawing.Color]::Transparent)

# Calculate new size (e.g., 60% of original) to fit in circle safely
# Android 12 circle mask diameter is roughly 2/3 of the icon size
$scale = 0.60
$newWidth = [int]($width * $scale)
$newHeight = [int]($height * $scale)
$x = [int](($width - $newWidth) / 2)
$y = [int](($height - $newHeight) / 2)

# Draw the image scaled down in the center
$gfx.DrawImage($img, $x, $y, $newWidth, $newHeight)

$bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)

$gfx.Dispose()
$bmp.Dispose()
$img.Dispose()

Write-Host "Created padded image at $destPath"
