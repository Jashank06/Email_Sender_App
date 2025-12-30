# 🐳 Docker Deployment Guide for Hostinger

## Prerequisites
- Docker installed on Hostinger VPS
- Git installed
- Your serviceAccount.json file ready

## 📦 Step 1: Prepare Your Files

Make sure you have these files ready:
- `server.js`
- `sendEmails.js`
- `Job.js`
- `package.json`
- `package-lock.json`
- `serviceAccount.json` (Google Service Account credentials)
- `.env` file with production values

## 🚀 Step 2: Deploy to Hostinger

### Option A: Using Docker Hub (Recommended)

1. **Build and Push to Docker Hub:**
```bash
# Login to Docker Hub
docker login

# Build the image (replace 'yourusername' with your Docker Hub username)
docker build -t yourusername/email-backend:latest .

# Push to Docker Hub
docker push yourusername/email-backend:latest
```

2. **On Hostinger VPS:**
```bash
# Pull the image
docker pull yourusername/email-backend:latest

# Create .env file on server
nano .env
# Add your environment variables (see .env.example)

# Run the container
docker run -d \
  --name email-backend \
  -p 3000:3000 \
  --env-file .env \
  --restart unless-stopped \
  yourusername/email-backend:latest

# Check logs
docker logs -f email-backend
```

### Option B: Build Directly on Hostinger

1. **Upload your code to Hostinger:**
```bash
# On your Mac, push to GitHub
git add .
git commit -m "Ready for deployment"
git push origin main

# On Hostinger VPS
git clone https://github.com/yourusername/your-repo.git
cd your-repo
```

2. **Build and Run:**
```bash
# Build Docker image
docker build -t email-backend .

# Create .env file
nano .env
# Add your production environment variables

# Run the container
docker run -d \
  --name email-backend \
  -p 3000:3000 \
  --env-file .env \
  --restart unless-stopped \
  email-backend

# Check if running
docker ps

# View logs
docker logs -f email-backend
```

## 🔧 Step 3: Configure Environment Variables

Create `.env` file on server:
```env
PORT=3000
GMAIL_USER=your-email@gmail.com
GMAIL_APP_PASSWORD=your-app-password
SHEET_ID=your-google-sheet-id
EMAIL_DELAY_MS=3000
```

## 🌐 Step 4: Setup Reverse Proxy (Recommended)

### Using Nginx:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Enable SSL with Let's Encrypt:
```bash
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

## 📱 Step 5: Update Flutter App

Update API URL in Flutter app:
```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://yourdomain.com'; // or http://your-vps-ip:3000
```

## 🔍 Useful Docker Commands

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# Stop container
docker stop email-backend

# Start container
docker start email-backend

# Restart container
docker restart email-backend

# Remove container
docker rm -f email-backend

# View logs
docker logs email-backend

# Follow logs in real-time
docker logs -f email-backend

# Execute command inside container
docker exec -it email-backend sh

# Update container (after pushing new image)
docker pull yourusername/email-backend:latest
docker stop email-backend
docker rm email-backend
docker run -d --name email-backend -p 3000:3000 --env-file .env --restart unless-stopped yourusername/email-backend:latest
```

## 🔒 Security Best Practices

1. **Never commit sensitive files:**
   - `.env` file
   - `serviceAccount.json`
   
2. **Use environment variables** for all sensitive data

3. **Enable firewall:**
```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

4. **Keep Docker updated:**
```bash
sudo apt-get update
sudo apt-get upgrade docker-ce
```

## 📊 Health Check

Check if your backend is running:
```bash
curl http://localhost:3000/health
# Should return: {"status":"ok","timestamp":"..."}
```

## 🐛 Troubleshooting

### Container not starting:
```bash
docker logs email-backend
```

### Port already in use:
```bash
sudo lsof -i :3000
# Kill the process using the port
sudo kill -9 <PID>
```

### Rebuild after code changes:
```bash
docker stop email-backend
docker rm email-backend
docker build -t email-backend .
docker run -d --name email-backend -p 3000:3000 --env-file .env --restart unless-stopped email-backend
```

## 📝 Notes

- Container will automatically restart on system reboot (`--restart unless-stopped`)
- Health check runs every 30 seconds
- All logs are stored in Docker logs
- Make sure your Hostinger VPS has at least 1GB RAM

## 🎯 Final URL

Your backend will be accessible at:
- Local: `http://localhost:3000`
- External: `http://your-vps-ip:3000`
- With domain: `https://yourdomain.com` (after Nginx + SSL setup)

Use this URL in your Flutter APK!
