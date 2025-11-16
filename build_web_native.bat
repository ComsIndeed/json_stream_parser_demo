@echo off
REM Build Flutter web app with HTML renderer (native web elements) for GitHub Pages deployment
REM This script builds the native experimental web version locally for testing

echo Building Flutter web app with HTML renderer (native web elements)...
echo.

REM Get the repository name (assuming it's json_stream_parser_demo)
set REPO_NAME=json_stream_parser_demo

echo Building with base-href: /%REPO_NAME%/native-experimental/
echo Using HTML renderer for native web elements...
flutter build web --release --web-renderer html --base-href /%REPO_NAME%/native-experimental/

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo Build successful!
    echo.
    echo Output directory: build\web
    echo.
    echo To test locally, you can serve the build folder:
    echo   cd build\web
    echo   python -m http.server 8000
    echo.
    echo Then visit: http://localhost:8000
    echo.
    echo Note: This build uses the HTML renderer instead of CanvasKit.
    echo ============================================
) else (
    echo.
    echo Build failed with error code %ERRORLEVEL%
)

pause
