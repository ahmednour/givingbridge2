#!/bin/bash

# SSL Certificate Setup Script for GivingBridge
# Supports both self-signed certificates for development and Let's Encrypt for production

set -e

# Configuration
DOMAIN_NAME=${DOMAIN_NAME:-"givingbridge.com"}
EMAIL=${SSL_EMAIL:-"admin@givingbridge.com"}
SSL_DIR="./ssl"
CERTS_DIR="${SSL_DIR}/certs"
NGINX_DIR="./nginx"
ENVIRONMENT=${NODE_ENV:-"development"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create SSL directory structure
create_ssl_directories() {
    log_info "Creating SSL directory structure..."
    
    mkdir -p "${CERTS_DIR}"
    mkdir -p "${SSL_DIR}/private"
    mkdir -p "${SSL_DIR}/csr"
    mkdir -p "./certbot/conf"
    mkdir -p "./certbot/www"
    
    # Set proper permissions
    chmod 700 "${SSL_DIR}/private"
    chmod 755 "${CERTS_DIR}"
    
    log_success "SSL directories created"
}

# Generate self-signed certificate for development
generate_self_signed_cert() {
    log_info "Generating self-signed certificate for development..."
    
    local key_file="${CERTS_DIR}/key.pem"
    local cert_file="${CERTS_DIR}/cert.pem"
    local csr_file="${SSL_DIR}/csr/server.csr"
    
    # Generate private key
    openssl genrsa -out "${key_file}" 2048
    chmod 600 "${key_file}"
    
    # Generate certificate signing request
    openssl req -new -key "${key_file}" -out "${csr_file}" -subj "/C=US/ST=CA/L=San Francisco/O=GivingBridge/OU=Development/CN=${DOMAIN_NAME}/emailAddress=${EMAIL}"
    
    # Generate self-signed certificate
    openssl x509 -req -days 365 -in "${csr_file}" -signkey "${key_file}" -out "${cert_file}" \
        -extensions v3_req -extfile <(cat <<EOF
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN_NAME}
DNS.2 = www.${DOMAIN_NAME}
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF
)
    
    # Create chain file (same as cert for self-signed)
    cp "${cert_file}" "${CERTS_DIR}/chain.pem"
    
    chmod 644 "${cert_file}"
    chmod 644 "${CERTS_DIR}/chain.pem"
    
    log_success "Self-signed certificate generated"
    log_warning "This certificate is for development only and will show security warnings in browsers"
}

# Setup Let's Encrypt certificate for production
setup_letsencrypt_cert() {
    log_info "Setting up Let's Encrypt certificate for production..."
    
    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        log_error "Certbot is not installed. Please install it first:"
        echo "  Ubuntu/Debian: sudo apt-get install certbot python3-certbot-nginx"
        echo "  CentOS/RHEL: sudo yum install certbot python3-certbot-nginx"
        echo "  macOS: brew install certbot"
        exit 1
    fi
    
    # Stop nginx if running to free up port 80
    log_info "Stopping nginx temporarily..."
    docker-compose -f docker-compose.prod.yml stop nginx 2>/dev/null || true
    
    # Generate certificate using standalone mode
    log_info "Requesting certificate from Let's Encrypt..."
    certbot certonly \
        --standalone \
        --email "${EMAIL}" \
        --agree-tos \
        --no-eff-email \
        --domains "${DOMAIN_NAME},www.${DOMAIN_NAME}" \
        --cert-path "${CERTS_DIR}/cert.pem" \
        --key-path "${CERTS_DIR}/key.pem" \
        --fullchain-path "${CERTS_DIR}/chain.pem" \
        --config-dir "./certbot/conf" \
        --work-dir "./certbot/work" \
        --logs-dir "./certbot/logs"
    
    # Copy certificates to our SSL directory
    if [ -f "./certbot/conf/live/${DOMAIN_NAME}/fullchain.pem" ]; then
        cp "./certbot/conf/live/${DOMAIN_NAME}/fullchain.pem" "${CERTS_DIR}/cert.pem"
        cp "./certbot/conf/live/${DOMAIN_NAME}/privkey.pem" "${CERTS_DIR}/key.pem"
        cp "./certbot/conf/live/${DOMAIN_NAME}/chain.pem" "${CERTS_DIR}/chain.pem"
        
        # Set proper permissions
        chmod 644 "${CERTS_DIR}/cert.pem"
        chmod 600 "${CERTS_DIR}/key.pem"
        chmod 644 "${CERTS_DIR}/chain.pem"
        
        log_success "Let's Encrypt certificate installed"
    else
        log_error "Failed to obtain Let's Encrypt certificate"
        exit 1
    fi
}

# Create certificate renewal script
create_renewal_script() {
    log_info "Creating certificate renewal script..."
    
    cat > "./scripts/renew-ssl.sh" << 'EOF'
#!/bin/bash

# SSL Certificate Renewal Script
# Run this script monthly via cron to renew Let's Encrypt certificates

set -e

DOMAIN_NAME=${DOMAIN_NAME:-"givingbridge.com"}
SSL_DIR="./ssl/certs"

echo "Renewing SSL certificate for ${DOMAIN_NAME}..."

# Stop nginx
docker-compose -f docker-compose.prod.yml stop nginx

# Renew certificate
certbot renew \
    --config-dir "./certbot/conf" \
    --work-dir "./certbot/work" \
    --logs-dir "./certbot/logs"

# Copy renewed certificates
if [ -f "./certbot/conf/live/${DOMAIN_NAME}/fullchain.pem" ]; then
    cp "./certbot/conf/live/${DOMAIN_NAME}/fullchain.pem" "${SSL_DIR}/cert.pem"
    cp "./certbot/conf/live/${DOMAIN_NAME}/privkey.pem" "${SSL_DIR}/key.pem"
    cp "./certbot/conf/live/${DOMAIN_NAME}/chain.pem" "${SSL_DIR}/chain.pem"
    
    # Set permissions
    chmod 644 "${SSL_DIR}/cert.pem"
    chmod 600 "${SSL_DIR}/key.pem"
    chmod 644 "${SSL_DIR}/chain.pem"
    
    echo "Certificate renewed successfully"
else
    echo "Certificate renewal failed"
    exit 1
fi

# Restart nginx
docker-compose -f docker-compose.prod.yml start nginx

echo "SSL certificate renewal completed"
EOF
    
    chmod +x "./scripts/renew-ssl.sh"
    
    log_success "Certificate renewal script created at ./scripts/renew-ssl.sh"
    log_info "Add this to your crontab to run monthly:"
    echo "0 2 1 * * /path/to/your/project/scripts/renew-ssl.sh"
}

# Validate certificate
validate_certificate() {
    log_info "Validating SSL certificate..."
    
    local cert_file="${CERTS_DIR}/cert.pem"
    local key_file="${CERTS_DIR}/key.pem"
    
    if [ ! -f "${cert_file}" ] || [ ! -f "${key_file}" ]; then
        log_error "Certificate files not found"
        return 1
    fi
    
    # Check certificate validity
    local cert_info=$(openssl x509 -in "${cert_file}" -text -noout)
    local expiry_date=$(echo "${cert_info}" | grep "Not After" | cut -d: -f2-)
    local subject=$(echo "${cert_info}" | grep "Subject:" | cut -d: -f2-)
    
    log_success "Certificate is valid"
    log_info "Subject: ${subject}"
    log_info "Expires: ${expiry_date}"
    
    # Check if certificate matches private key
    local cert_modulus=$(openssl x509 -noout -modulus -in "${cert_file}" | openssl md5)
    local key_modulus=$(openssl rsa -noout -modulus -in "${key_file}" | openssl md5)
    
    if [ "${cert_modulus}" = "${key_modulus}" ]; then
        log_success "Certificate and private key match"
    else
        log_error "Certificate and private key do not match"
        return 1
    fi
}

# Create DH parameters for enhanced security
generate_dhparam() {
    log_info "Generating Diffie-Hellman parameters (this may take a while)..."
    
    local dhparam_file="${CERTS_DIR}/dhparam.pem"
    
    if [ ! -f "${dhparam_file}" ]; then
        openssl dhparam -out "${dhparam_file}" 2048
        chmod 644 "${dhparam_file}"
        log_success "DH parameters generated"
    else
        log_info "DH parameters already exist"
    fi
}

# Main function
main() {
    log_info "Starting SSL setup for GivingBridge..."
    log_info "Environment: ${ENVIRONMENT}"
    log_info "Domain: ${DOMAIN_NAME}"
    
    create_ssl_directories
    
    if [ "${ENVIRONMENT}" = "production" ]; then
        setup_letsencrypt_cert
        create_renewal_script
    else
        generate_self_signed_cert
    fi
    
    generate_dhparam
    validate_certificate
    
    log_success "SSL setup completed successfully!"
    
    if [ "${ENVIRONMENT}" = "development" ]; then
        log_warning "Remember to add the self-signed certificate to your browser's trusted certificates"
        log_info "Certificate location: ${CERTS_DIR}/cert.pem"
    fi
}

# Run main function
main "$@"