@echo off
echo Building Flutter APK...

echo Stopping Java processes...
taskkill /f /im java.exe >nul 2>&1

echo Waiting...
timeout /t 3 /nobreak >nul

echo Cleaning project...
if exist build rmdir /s /q build >nul 2>&1
flutter clean

echo Getting dependencies...
flutter pub get

echo Building APK...
flutter build apk --debug

if %errorlevel% equ 0 (
    echo.
    echo ✅ APK built successfully!
    echo APK location: build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo.
    echo ❌ APK build failed!
)

echo.
pause