@echo off
echo Cleaning Flutter project...
flutter clean
timeout /t 2 /nobreak >nul

echo Getting dependencies...
flutter pub get
timeout /t 2 /nobreak >nul

echo Starting Android emulator (if not running)...
start /min cmd /c "emulator -avd Pixel_3a_API_34_extension_level_7_x86_64 -no-snapshot-save"
timeout /t 5 /nobreak >nul

echo Building and running app...
flutter run --debug

pause