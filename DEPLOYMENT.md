# GitHub Pages Deployment Guide

## 🚀 Quick Start

This repository is configured to automatically deploy to GitHub Pages whenever you push to the `main` branch.

### Your Site URLs
Once deployed, your sites will be available at:

**Main site (CanvasKit renderer):**
```
https://comsindeed.github.io/json_stream_parser_demo/
```

**Experimental site (HTML renderer with native web elements):**
```
https://comsindeed.github.io/json_stream_parser_demo/native-experimental/
```

## 📋 Setup Instructions

### 1. Enable GitHub Pages (One-time setup)

1. Go to your repository on GitHub
2. Click on **Settings** tab
3. Navigate to **Pages** in the left sidebar
4. Under **Source**, select **GitHub Actions**
5. Save the changes

### 2. Automatic Deployment

Two workflows deploy different versions automatically:

**Main workflow** (`.github/workflows/deploy.yml`):
- ✅ Triggers on every push to `main` branch
- ✅ Builds with CanvasKit renderer (default)
- ✅ Deploys to root path
- ✅ URL: https://comsindeed.github.io/json_stream_parser_demo/

**Native Experimental workflow** (`.github/workflows/deploy-native-experimental.yml`):
- ✅ Triggers on every push to `main` branch
- ✅ Builds with HTML renderer (native web elements)
- ✅ Deploys to `/native-experimental/` subdirectory
- ✅ URL: https://comsindeed.github.io/json_stream_parser_demo/native-experimental/

You can also manually trigger either deployment:
1. Go to **Actions** tab on GitHub
2. Select the workflow you want to run
3. Click **Run workflow** button

### 3. Manual Local Build (Optional)

To build and test locally before pushing:

**Windows (PowerShell/CMD):**
```batch
.\build_web.bat
```

**Mac/Linux:**
```bash
chmod +x build_web.sh
./build_web.sh
```

Or manually:
```bash
flutter build web --release --base-href /json_stream_parser_demo/
```

## 📊 GitHub Pages Free Tier Limitations

### Storage & Bandwidth
- ✅ **Repository size limit**: 1 GB (soft limit)
- ✅ **Published site size**: Recommended max 1 GB
- ✅ **Bandwidth**: 100 GB/month (soft limit)
- ✅ **Builds**: 10 deployments per hour

### Usage Limits
- ✅ **Build time**: 10 minutes per workflow run
- ✅ **GitHub Actions**: 2,000 minutes/month for free accounts (public repos = unlimited)

### Important Notes for Your Project
1. **Your Flutter web build** is typically 2-10 MB (very small)
2. **Public repositories** get unlimited GitHub Actions minutes
3. **No credit card required** - completely free for public repos
4. **Custom domain support** available if you want to use your own domain

### What This Means for You
✅ Your project is **well within limits** (Flutter web apps are lightweight)  
✅ **No costs** since your repo is public  
✅ **Unlimited builds** for public repositories  
✅ **No bandwidth concerns** for typical usage  

## 🔍 Monitoring Your Deployment

### Check Build Status
1. Go to the **Actions** tab on GitHub
2. You'll see the workflow runs with ✅ (success) or ❌ (failure)
3. Click on any run to see detailed logs

### After First Deployment
- It may take 1-2 minutes for your site to go live
- Subsequent updates are usually live within 30 seconds

## 🛠️ Troubleshooting

### Deployment fails?
1. Check the Actions tab for error logs
2. Common issues:
   - GitHub Pages not enabled in Settings → Pages
   - Branch protection rules blocking deployment
   - Build errors in Flutter code

### Site not loading?
1. Wait 1-2 minutes after first deployment
2. Clear your browser cache
3. Check that the base-href is correct in the build

### Changes not appearing?
1. Check if the workflow ran successfully in Actions tab
2. Hard refresh your browser (Ctrl+F5 / Cmd+Shift+R)
3. Wait a minute - GitHub Pages has a small propagation delay

## 🧪 Native Experimental Build

### What is it?
The native experimental build uses Flutter's **HTML renderer** instead of the default **CanvasKit renderer**. This provides:

- ✅ Better integration with native web elements (DOM)
- ✅ Smaller initial download size
- ✅ Better text selection and accessibility
- ❌ Less consistent rendering across browsers
- ❌ Potentially lower graphics performance

### How it works
The `deploy-native-experimental.yml` workflow:
1. Builds with `--web-renderer html` flag
2. Deploys to the `gh-pages` branch in a `native-experimental/` subdirectory
3. Both builds coexist on the same GitHub Pages site

### Testing locally
To build the native experimental version locally:
```bash
flutter build web --release --web-renderer html --base-href /json_stream_parser_demo/native-experimental/
```

## 📝 Customization

### Change Deploy Branch
Edit `.github/workflows/deploy.yml`:
```yaml
on:
  push:
    branches:
      - main  # Change this to your preferred branch
```

### Manual Deployment Only
Remove the `push:` trigger and keep only `workflow_dispatch:` in the workflow file.

### Update Flutter Version
Edit the workflow file:
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.x'  # Change version here
```

## 🎉 That's It!

Your Flutter web app will now automatically deploy to GitHub Pages every time you push to `main`. No manual steps needed!

---

**Need help?** Check the [GitHub Pages documentation](https://docs.github.com/en/pages) or [Flutter web deployment guide](https://docs.flutter.dev/deployment/web).
