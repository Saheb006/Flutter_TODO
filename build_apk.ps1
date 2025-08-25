Write-Host "Building Flutter APK..." -ForegroundColor Green

# Kill any Java processes that might be locking files
Write-Host "Stopping Java processes..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait a moment
Start-Sleep -Seconds 2

# Force delete build directory
Write-Host "Cleaning build directory..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
}

# Clean Flutter
Write-Host "Running flutter clean..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Build APK
Write-Host "Building APK..." -ForegroundColor Green
flutter build apk --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK built successfully!" -ForegroundColor Green
    Write-Host "APK location: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Cyan
} else {
    Write-Host "❌ APK build failed!" -ForegroundColor Red
}

Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")