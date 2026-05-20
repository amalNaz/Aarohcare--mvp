# Flutter Web Deployment Guide - Vercel

## Prerequisites
- Flutter SDK installed locally
- GitHub account with your repository
- Vercel account (free tier available)

## Deployment Steps

### 1. Pre-Build the Web App Locally

```bash
cd doctor_booking_app
flutter clean
flutter pub get
flutter build web --release
```

Your optimized web app is now in `build/web/`

### 2. Commit to GitHub

Before pushing, ensure your `.gitignore` is properly configured:
- ✅ Already excludes unnecessary files
- ✅ `build/` is in `.gitignore` (generated output)

Push your code:
```bash
git add .
git commit -m "Ready for Vercel deployment"
git push origin main
```

### 3. Deploy to Vercel

#### Option A: Using Vercel Dashboard (Recommended)

1. Go to https://vercel.com/new
2. Import your GitHub repository
3. **Framework Preset:** Other
4. **Build Command:** `flutter build web`
5. **Output Directory:** `build/web`
6. Click **Deploy**

#### Option B: Using Vercel CLI

```bash
npm install -g vercel
cd doctor_booking_app
vercel
```

### 4. Configuration Details

The following files are already configured:
- ✅ `vercel.json` - Rewrites for SPA routing
- ✅ `.vercelignore` - Optimizes deployment size
- ✅ `build.sh` - Custom build script (optional)

### 5. Important Notes

**Note:** Vercel's default Linux environment may not have Flutter SDK pre-installed.

**Solutions:**
1. **Recommended:** Skip the build step on Vercel
   - Build locally with `flutter build web`
   - Commit `build/web` to GitHub temporarily for first deployment
   - OR use Vercel's Docker support

2. **Alternative:** Use GitHub Actions to build
   - Create `.github/workflows/deploy.yml`
   - Build before pushing to GitHub
   - Vercel deploys the `build/web` folder

### 6. Troubleshooting

**Error: "Flutter not found"**
- Solution: Change approach - build locally and deploy pre-built version

**Error: "build/web not found"**
- Solution: Run `flutter build web` locally first

**App loads but routing doesn't work**
- Solution: ✅ Already fixed with `vercel.json` rewrites

**Performance issues**
- Make sure to use `flutter build web --release` flag

## Environment Variables

If you need to add environment variables:
1. Go to Vercel Project Settings → Environment Variables
2. Add any needed variables (API endpoints, etc.)

## Deployment Verification

After deployment:
1. Check Vercel dashboard for build status
2. Visit your assigned Vercel URL
3. Test all app routes and features
4. Check browser console for errors (F12)

## Next Steps

1. Set up custom domain (optional)
2. Configure analytics in Vercel
3. Set up automatic deployments on push
4. Monitor performance

For more help: https://vercel.com/docs
