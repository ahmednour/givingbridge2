# Production Deployment Guide

## Prerequisites

1. **Server Requirements**

   - Ubuntu 20.04+ or CentOS 8+
   - Docker and Docker Compose
   - SSL certificates
   - Domain name configured

2. **Security Requirements**
   - Strong passwords for all services
   - SSL certificates (Let's Encrypt recommended)
   - Firewall configured (ports 80, 443, 22)
   - Regular security updates

## Deployment Steps

### 1. Environment Setup

```bash
# Copy production environment template
cp .env.prod.example .env.prod

# Edit environment variables
nano .env.prod
```

**Required Environment Variables:**

- `JWT_SECRET`: Generate a secure random string (32+ characters)
- `DB_PASSWORD`: Strong database password
- `DB_ROOT_PASSWORD`: Strong root database password
- `FRONTEND_URL`: Your production domain (https://)

### 2. SSL Certificate Setup

```bash
# Create SSL directory
mkdir -p ssl

# Copy your SSL certificates
cp your-cert.pem ssl/cert.pem
cp your-key.pem ssl/key.pem

# Set proper permissions
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem
```

### 3. Database Security

```bash
# Update MySQL security configuration
nano mysql-security.cnf

# Ensure proper file permissions
chmod 644 mysql-security.cnf
```

### 4. Build and Deploy

```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 5. Health Checks

```bash
# Check all services are running
docker-compose -f docker-compose.prod.yml ps

# Test API health
curl -k https://your-domain.com/health

# Test frontend
curl -k https://your-domain.com
```

## Security Checklist

- [ ] All default passwords changed
- [ ] SSL certificates installed and valid
- [ ] Firewall configured (only ports 80, 443, 22 open)
- [ ] Database security configuration applied
- [ ] Rate limiting configured
- [ ] Security headers enabled
- [ ] Log monitoring set up
- [ ] Backup strategy implemented
- [ ] Regular security updates scheduled

## Monitoring

### Log Monitoring

```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs -f backend

# View Nginx logs
docker-compose -f docker-compose.prod.yml logs -f nginx

# View database logs
docker-compose -f docker-compose.prod.yml logs -f db
```

### Performance Monitoring

- Set up monitoring for CPU, memory, disk usage
- Monitor database performance
- Set up alerts for high error rates
- Monitor SSL certificate expiration

## Backup Strategy

### Database Backup

```bash
# Create backup script
cat > backup-db.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose -f docker-compose.prod.yml exec -T db mysqldump -u root -p$DB_ROOT_PASSWORD givingbridge > backup_$DATE.sql
gzip backup_$DATE.sql
EOF

chmod +x backup-db.sh

# Schedule daily backups
crontab -e
# Add: 0 2 * * * /path/to/backup-db.sh
```

### Application Backup

```bash
# Backup application data
tar -czf app-backup-$(date +%Y%m%d).tar.gz \
  --exclude=node_modules \
  --exclude=.git \
  backend/ frontend/
```

## Troubleshooting

### Common Issues

1. **SSL Certificate Errors**

   - Verify certificate files exist and have correct permissions
   - Check certificate validity and expiration
   - Ensure domain matches certificate

2. **Database Connection Issues**

   - Verify database credentials
   - Check database container health
   - Review database logs

3. **Rate Limiting Issues**

   - Adjust rate limits in nginx.conf
   - Check application rate limiting settings
   - Monitor for DDoS attacks

4. **Performance Issues**
   - Monitor resource usage
   - Check database query performance
   - Review application logs for errors

### Emergency Procedures

1. **Service Restart**

   ```bash
   docker-compose -f docker-compose.prod.yml restart
   ```

2. **Database Recovery**

   ```bash
   # Stop services
   docker-compose -f docker-compose.prod.yml down

   # Restore from backup
   gunzip -c backup_YYYYMMDD_HHMMSS.sql.gz | \
   docker-compose -f docker-compose.prod.yml exec -T db mysql -u root -p$DB_ROOT_PASSWORD givingbridge

   # Restart services
   docker-compose -f docker-compose.prod.yml up -d
   ```

## Maintenance

### Regular Tasks

- [ ] Weekly security updates
- [ ] Monthly backup verification
- [ ] Quarterly security audit
- [ ] Annual SSL certificate renewal

### Updates

```bash
# Update application
git pull origin main
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Update system packages
apt update && apt upgrade -y
```
