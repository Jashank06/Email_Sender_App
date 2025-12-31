# Production Deployment Guide

## 🚀 Backend Ready for Production

Your backend is now production-ready with the following improvements:

### ✅ Security Enhancements
1. **Non-root user** - Docker container runs as unprivileged user (nodejs:1001)
2. **Secrets handling** - `serviceAccount.json` mounted as volume, not copied into image
3. **Environment variables** - Hardcoded credentials moved to env vars
4. **Read-only volumes** - Sensitive files mounted with `:ro` flag

### ✅ Production Features
1. **Health checks** - Automatic container health monitoring
2. **Logging** - JSON logging with rotation (max 10MB, 3 files)
3. **Restart policy** - Auto-restart on failure
4. **Optimized build** - Cleaned npm cache, production-only dependencies

### 📋 Important Notes

#### Authentication Endpoints
The backend **still has authentication endpoints** (`/api/auth/*`), but:
- ✅ Frontend doesn't use them (goes directly to home screen)
- ⚠️ They're still available if you need them later
- 💡 Users can now use the app without login/signup
- 🔒 Endpoints are safe but not necessary for current frontend

**Should we remove auth endpoints?**
- Keep them: If you might need user authentication later
- Remove them: To clean up code and reduce attack surface

---

## 🐳 Docker Deployment

### Option 1: Docker Compose (Recommended)

```bash
# 1. Create .env file
cp .env.production .env
# Edit .env with your actual values

# 2. Make sure serviceAccount.json is in project root

# 3. Build and start
docker-compose up -d

# 4. View logs
docker-compose logs -f

# 5. Stop
docker-compose down
```

### Option 2: Docker Build & Run

```bash
# 1. Build image
docker build -t email-sender-backend:latest .

# 2. Run container
docker run -d \
  --name email-backend \
  -p 3000:3000 \
  -v $(pwd)/serviceAccount.json:/app/serviceAccount.json:ro \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e OTP_GMAIL_USER=your-email@gmail.com \
  -e OTP_GMAIL_PASSWORD=your-password \
  --restart unless-stopped \
  email-sender-backend:latest

# 3. View logs
docker logs -f email-backend

# 4. Stop and remove
docker stop email-backend
docker rm email-backend
```

---

## 🌐 Production Checklist

### Before Deployment:
- [ ] Update `.env` with production values
- [ ] Ensure `serviceAccount.json` is available
- [ ] Test health endpoint: `curl http://localhost:3000/health`
- [ ] Test email sending with real credentials
- [ ] Setup reverse proxy (nginx/traefik) for HTTPS
- [ ] Configure firewall rules
- [ ] Setup monitoring and alerts

### Security:
- [ ] Use HTTPS in production (reverse proxy)
- [ ] Enable rate limiting (nginx/API gateway)
- [ ] Setup CORS properly for your domain
- [ ] Use Docker secrets or Kubernetes secrets for sensitive data
- [ ] Regular security updates
- [ ] Backup service account credentials

### Environment Variables in Production:
```bash
# Use Docker secrets, Kubernetes secrets, or secure env management
# Examples:

# AWS ECS
# Use AWS Secrets Manager

# Kubernetes
# Create secrets: kubectl create secret generic email-secrets --from-file=serviceAccount.json

# Docker Swarm
# docker secret create serviceaccount serviceAccount.json
```

---

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:3000/health
# Response: {"status":"ok","message":"Server is running"}
```

### Container Health
```bash
docker ps
# Look for "healthy" status
```

### Logs
```bash
# Real-time logs
docker-compose logs -f email-backend

# Last 100 lines
docker-compose logs --tail=100 email-backend
```

---

## 🔄 Updates & Rebuilds

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Or for quick updates
docker-compose up -d --build
```

---

## 🚨 Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs email-backend

# Check if serviceAccount.json exists
ls -la serviceAccount.json

# Verify permissions
chmod 644 serviceAccount.json
```

### Health check failing
```bash
# Test health endpoint
docker exec email-backend curl http://localhost:3000/health

# Check if port is accessible
curl http://localhost:3000/health
```

### Email sending fails
```bash
# Test email configuration endpoint
curl -X POST http://localhost:3000/api/test-email \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "gmail",
    "email": "your-email@gmail.com",
    "password": "your-app-password"
  }'
```

---

## 🎯 What Changed

### Frontend (Flutter)
- ✅ Removed AuthWrapper - app opens directly to HomeScreen
- ✅ No login/signup required
- ✅ Users can start using immediately

### Backend (Node.js)
- ✅ Moved hardcoded credentials to environment variables
- ✅ Added comments about optional auth endpoints
- ✅ Production-ready but auth endpoints still available

### Docker
- ✅ Non-root user for security
- ✅ Service account mounted as volume (not in image)
- ✅ Health checks and auto-restart
- ✅ Optimized build with cache cleaning
- ✅ docker-compose.yml for easy deployment

---

## 💡 Recommendations

1. **For Production**: Use a reverse proxy (nginx) with SSL/TLS
2. **For Scaling**: Use container orchestration (Kubernetes, ECS, etc.)
3. **For Secrets**: Use proper secrets management, not environment variables
4. **For Auth**: Remove auth endpoints if not needed (saves ~350 lines of code)

---

## 📞 Next Steps

**Ready to deploy!** You can now:
```bash
docker-compose up -d
```

**Need to remove auth endpoints?** Let me know and I'll clean them up!

**Need help with:**
- Setting up nginx reverse proxy?
- Deploying to cloud (AWS/GCP/Azure)?
- Kubernetes deployment?
- CI/CD pipeline?

Just ask! 🚀
