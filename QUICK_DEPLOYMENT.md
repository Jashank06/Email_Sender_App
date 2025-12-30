# 🚀 Quick Deployment Reference

## Backend → Hostinger Docker (5 Minutes)

### 1️⃣ Build & Push to Docker Hub
```bash
# Login
docker login

# Build
docker build -t yourusername/email-backend:latest .

# Push
docker push yourusername/email-backend:latest
```

### 2️⃣ Deploy on Hostinger VPS
```bash
# SSH into your Hostinger VPS
ssh root@your-vps-ip

# Pull image
docker pull yourusername/email-backend:latest

# Create .env file
nano .env
# Add: PORT=3000, GMAIL_USER, GMAIL_APP_PASSWORD, SHEET_ID

# Run container
docker run -d \
  --name email-backend \
  -p 3000:3000 \
  --env-file .env \
  --restart unless-stopped \
  yourusername/email-backend:latest

# Check if running
docker ps
docker logs -f email-backend

# Test health endpoint
curl http://localhost:3000/health
```

### 3️⃣ Setup Domain (Optional but Recommended)
```bash
# Install Nginx
sudo apt update
sudo apt install nginx

# Configure Nginx
sudo nano /etc/nginx/sites-available/email-backend

# Add this configuration:
server {
    listen 80;
    server_name yourdomain.com;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/email-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Setup SSL (Free HTTPS)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

**Your backend is now live at:** `https://yourdomain.com` 🎉

---

## APK Build (3 Minutes)

### 1️⃣ Update Backend URL
```bash
# Edit this file
nano flutter_email_app/lib/services/api_service.dart

# Change line 8:
static const String baseUrl = 'https://yourdomain.com';
```

### 2️⃣ Build APK
```bash
cd flutter_email_app
flutter clean
flutter build apk --release --split-per-abi
```

### 3️⃣ Get APK
```bash
# Your APK is here:
open build/app/outputs/flutter-apk/

# Install this file on Android phones:
# app-arm64-v8a-release.apk (15-20 MB)
```

**APK ready! Share kar sakte ho** 📱

---

## 🧪 Test Complete System

### Test Backend:
```bash
curl https://yourdomain.com/health
# Should return: {"status":"ok"}
```

### Test from Phone Browser:
```
https://yourdomain.com/health
```

### Install & Test APK:
```bash
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 📋 Checklist

Backend:
- [ ] Docker image pushed to Docker Hub
- [ ] Container running on Hostinger VPS
- [ ] Health endpoint accessible: `curl http://your-vps:3000/health`
- [ ] Domain configured (optional)
- [ ] SSL certificate installed (optional)

APK:
- [ ] Backend URL updated in `api_service.dart`
- [ ] APK built successfully
- [ ] APK installed on test device
- [ ] App can connect to backend
- [ ] Email sending works end-to-end

---

## 🆘 Quick Troubleshooting

### Backend not accessible:
```bash
docker logs email-backend
docker restart email-backend
sudo ufw allow 3000
```

### APK can't connect:
1. Check backend URL in app
2. Test URL in phone browser first
3. Check phone has internet
4. Check firewall allows port 3000

### Rebuild everything:
```bash
# Backend
docker stop email-backend && docker rm email-backend
docker build -t email-backend . && docker run -d --name email-backend -p 3000:3000 --env-file .env email-backend

# APK
cd flutter_email_app
flutter clean && flutter build apk --release
```

---

## 📞 Useful Commands

```bash
# Backend logs
docker logs -f email-backend

# Restart backend
docker restart email-backend

# Stop backend
docker stop email-backend

# Update backend
docker pull yourusername/email-backend:latest
docker stop email-backend && docker rm email-backend
docker run -d --name email-backend -p 3000:3000 --env-file .env --restart unless-stopped yourusername/email-backend:latest

# Install APK via ADB
adb install app-release.apk

# Check device logs
adb logcat | grep flutter
```

---

## 🎯 Final URLs

- **Backend API:** `https://yourdomain.com` (or `http://vps-ip:3000`)
- **Health Check:** `https://yourdomain.com/health`
- **APK Location:** `flutter_email_app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

**Total Time: ~10 minutes** ⚡
