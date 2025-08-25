Write-Host "Starting Flutter Todo App..." -ForegroundColor Green

# Function to force delete directory
function Force-Delete {
    param($Path)
    if (Test-Path $Path) {
        Write-Host "Removing $Path..." -ForegroundColor Yellow
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Start-Sleep -Seconds 1
        } catch {
            Write-Host "Retrying deletion..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            try {
                Get-ChildItem -Path $Path -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Some files may still be locked, continuing..." -ForegroundColor Yellow
            }
        }
    }
}

# Clean build directories
Write-Host "Cleaning Flutter project..." -ForegroundColor Cyan
Force-Delete "build"
Force-Delete ".dart_tool"

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

# Check if emulator is running
Write-Host "Checking for running emulator..." -ForegroundColor Cyan
$emulatorRunning = flutter devices | Select-String "emulator"

if (-not $emulatorRunning) {
    Write-Host "Starting Android emulator..." -ForegroundColor Cyan
    Start-Process -FilePath "emulator" -ArgumentList "-avd", "Pixel_3a_API_34_extension_level_7_x86_64", "-no-snapshot-save" -WindowStyle Minimized
    Write-Host "Waiting for emulator to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}

# Run the app
Write-Host "Running Flutter app..." -ForegroundColor Green
flutter run --debug

Write-Host "Press any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")