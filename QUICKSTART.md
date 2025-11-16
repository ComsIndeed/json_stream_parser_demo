# 🚀 Quick Reference - GitHub Pages Deployment

## Automatic Deployment (Default)
✅ **Just push to `main` branch** - that's it!
```bash
git add .
git commit -m "Your changes"
git push origin main
```
→ Your sites update automatically at:
- **Main:** https://comsindeed.github.io/json_stream_parser_demo/
- **Native Experimental:** https://comsindeed.github.io/json_stream_parser_demo/native-experimental/

---

## One-Time Setup (If not done yet)
1. Go to your repo on GitHub
2. **Settings** → **Pages** → **Source** → Select **GitHub Actions**
3. Done! ✅

---

## Manual Deployment
Go to **Actions** tab → **Deploy to GitHub Pages** → **Run workflow**

---

## Local Testing
```bash
# Build locally
.\build_web.bat          # Windows
./build_web.sh           # Mac/Linux

# Test the build
cd build\web
python -m http.server 8000
# Visit http://localhost:8000
```

---

## GitHub Pages Free Tier - What You Get
✅ **Completely FREE** for public repos  
✅ **Unlimited builds** (public repos)  
✅ **100 GB bandwidth/month** (more than enough)  
✅ **1 GB storage** (Flutter web apps are ~5-10 MB)  
✅ **Custom domain support** (optional)  
✅ **HTTPS enabled** by default  

### Your Project Status
- ✅ Build size: ~5-10 MB (well within limits)
- ✅ No bandwidth concerns for typical usage
- ✅ No costs, no credit card needed
- ✅ Unlimited deploys for public repo

---

## Troubleshooting
| Issue | Solution |
|-------|----------|
| Site not loading | Wait 1-2 minutes after first deploy |
| Changes not showing | Hard refresh (Ctrl+F5) or check Actions tab |
| Build failed | Check Actions tab for error logs |

---

## File Structure
```
.github/workflows/deploy.yml                      ← Main deployment workflow (CanvasKit)
.github/workflows/deploy-native-experimental.yml  ← Native experimental workflow (HTML)
build_web.bat                                     ← Local build script (Windows)
build_web.sh                                      ← Local build script (Mac/Linux)
DEPLOYMENT.md                                     ← Detailed guide
```

---

**Need more help?** See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.
