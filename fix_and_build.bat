@echo off
echo Cleaning Flutter project...
flutter clean

echo Removing .dart_tool directory...
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo Removing build directory...
if exist "build" rmdir /s /q "build"

echo Getting dependencies...
flutter pub get

echo Building APK...
flutter build apk --release

echo Done!
pause
