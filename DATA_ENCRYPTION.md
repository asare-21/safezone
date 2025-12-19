# Data Encryption & Security Measures

**Last Updated: December 19, 2025**

## Overview

This document outlines the encryption and security measures implemented in SafeZone to protect user data and ensure privacy compliance with GDPR, CCPA, and industry best practices.

## 1. Encryption Architecture

### 1.1 Defense in Depth Strategy
SafeZone implements multiple layers of security:
- **Transport Layer**: HTTPS/TLS encryption for all API communications
- **Application Layer**: Field-level encryption for sensitive data
- **Storage Layer**: Encrypted database fields and secure storage
- **Access Layer**: Authentication and authorization controls

### 1.2 Encryption Standards
- **Algorithm**: AES-256 (Advanced Encryption Standard)
- **Key Size**: 256-bit keys
- **Mode**: CBC or GCM mode with unique initialization vectors
- **TLS Version**: TLS 1.2 or higher for transport security

## 2. Data Classification

### 2.1 Highly Sensitive Data (Encrypted at Rest)
These fields are encrypted in the database using field-level encryption:

| Field | Model | Reason | Encryption Method |
|-------|-------|--------|-------------------|
| `fcm_token` | UserDevice | Push notification token | AES-256 |
| `device_id` | UserDevice | Device identifier | AES-256 |
| `device_id` | SafeZone | User identifier for safe zones | AES-256 |
| `device_id` | UserPreferences | User identifier for preferences | AES-256 |

### 2.2 Sensitive Data (Protected via HTTPS)
These fields are transmitted securely but stored in plaintext:
- GPS coordinates (latitude/longitude)
- Incident titles and descriptions
- Timestamps
- User preferences

### 2.3 Public Data (No Encryption Required)
- Incident categories (enum values)
- Aggregated statistics
- App version numbers

## 3. Implementation Details

### 3.1 Django Encrypted Fields

We use the `django-encrypted-model-fields` library for transparent field-level encryption:

```python
from encrypted_model_fields.fields import EncryptedCharField, EncryptedTextField

class UserDevice(models.Model):
    # Encrypted fields
    device_id = EncryptedCharField(max_length=255)
    fcm_token = EncryptedTextField()
    
    # Other fields...
```

**Features**:
- Automatic encryption/decryption
- Transparent to application code
- Uses Django's SECRET_KEY or custom encryption key
- Supports field-level encryption without modifying existing queries

### 3.2 Key Management

#### Development Environment
- Encryption key derived from Django's `SECRET_KEY`
- Stored in environment variables (not in version control)
- Different keys for development, staging, and production

#### Production Recommendations
- Use dedicated encryption keys separate from `SECRET_KEY`
- Store keys in secure key management service (AWS KMS, HashiCorp Vault, etc.)
- Implement key rotation policies (rotate every 90 days)
- Use environment-specific keys (never reuse across environments)

**Example Production Setup**:
```python
# settings.py
import os

# Primary application key
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY')

# Dedicated encryption key
FIELD_ENCRYPTION_KEY = os.environ.get('FIELD_ENCRYPTION_KEY')
```

### 3.3 Password Security

Django's built-in password hashing:
- **Algorithm**: PBKDF2 with SHA256 hash
- **Iterations**: 600,000+ iterations (Django 4.2 default)
- **Salt**: Unique per-password salt
- **One-way hashing**: Passwords cannot be decrypted

## 4. Transport Security

### 4.1 HTTPS/TLS Configuration

All API communications use HTTPS with strong TLS settings:

```python
# settings.py - Production Settings

# Force HTTPS
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# HSTS (HTTP Strict Transport Security)
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Prevent MIME sniffing
SECURE_CONTENT_TYPE_NOSNIFF = True

# XSS Protection
SECURE_BROWSER_XSS_FILTER = True

# X-Frame-Options
X_FRAME_OPTIONS = 'DENY'
```

### 4.2 Certificate Requirements
- **Minimum TLS Version**: TLS 1.2
- **Recommended**: TLS 1.3
- **Certificate Authority**: Let's Encrypt or commercial CA
- **Certificate Validity**: Regular renewal (90 days for Let's Encrypt)

## 5. Data at Rest Protection

### 5.1 Database Security
- **SQLite**: File-level encryption using SQLCipher (for development)
- **PostgreSQL**: Encrypted database connections, pg_crypto extension for field encryption
- **Backups**: Encrypted backup files with separate encryption keys

### 5.2 File Storage Security
- Media files stored with restricted access permissions
- No sensitive data stored in file names
- Automatic file cleanup for expired data

## 6. Access Controls

### 6.1 Authentication
- Token-based authentication (JWT or Django REST framework tokens)
- Session management with secure cookies
- Password complexity requirements enforced
- Account lockout after failed login attempts

### 6.2 Authorization
- Role-based access control (RBAC)
- Principle of least privilege
- Admin-only access to sensitive operations
- Audit logging for data access

### 6.3 API Security
```python
# REST Framework Security Settings
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',  # Production
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
    },
}
```

## 7. Security Headers

### 7.1 Content Security Policy (CSP)
```python
# Prevent XSS attacks
CSP_DEFAULT_SRC = ("'self'",)
CSP_SCRIPT_SRC = ("'self'",)
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")
CSP_IMG_SRC = ("'self'", "data:", "https:")
```

### 7.2 Additional Security Headers
- **X-Content-Type-Options**: `nosniff`
- **X-Frame-Options**: `DENY`
- **X-XSS-Protection**: `1; mode=block`
- **Referrer-Policy**: `strict-origin-when-cross-origin`

## 8. Mobile App Security

### 8.1 Flutter Security Practices
- **Local Storage**: SharedPreferences encrypted on device
- **Certificate Pinning**: Prevent man-in-the-middle attacks
- **Root/Jailbreak Detection**: Warn users of compromised devices
- **Code Obfuscation**: Protect source code in release builds

### 8.2 Firebase Security
- **FCM Tokens**: Encrypted in backend database
- **Firebase Rules**: Restrict access to authenticated users only
- **API Keys**: Restricted to specific package names/bundle IDs

## 9. Data Minimization

### 9.1 Privacy by Design
- Collect only essential data for core functionality
- No tracking pixels or unnecessary analytics
- Anonymous reporting option available
- Automatic data deletion after retention period

### 9.2 Anonymization Techniques
- Remove identifying information after 90 days
- Aggregate statistics computed without individual data
- Location data rounded to reduce precision for archived incidents

## 10. Incident Response

### 10.1 Security Breach Protocol
1. **Detection**: Automated monitoring and alerting
2. **Containment**: Immediate isolation of affected systems
3. **Investigation**: Root cause analysis and impact assessment
4. **Notification**: Users notified within 72 hours (GDPR requirement)
5. **Remediation**: Fix vulnerabilities and restore services
6. **Review**: Post-incident review and improvements

### 10.2 Breach Notification Requirements
- **GDPR**: Notify authorities within 72 hours
- **CCPA**: Notify affected users "without unreasonable delay"
- **Communication**: Clear, transparent disclosure of breach details

## 11. Compliance Measures

### 11.1 GDPR Compliance
- ✅ Data protection by design and default
- ✅ Encryption of personal data
- ✅ Ability to demonstrate compliance
- ✅ Data Processing Agreements (DPA) with third parties
- ✅ Privacy Impact Assessment (PIA) conducted
- ✅ Data Protection Officer (DPO) appointed for production

### 11.2 CCPA Compliance
- ✅ Transparent privacy notice
- ✅ User rights mechanisms (access, delete, opt-out)
- ✅ No sale of personal information
- ✅ Reasonable security measures
- ✅ Data breach notification procedures

## 12. Security Testing

### 12.1 Regular Security Audits
- **Frequency**: Quarterly security reviews
- **Penetration Testing**: Annual third-party pentests
- **Vulnerability Scanning**: Weekly automated scans
- **Code Review**: Security-focused code reviews for all changes

### 12.2 Testing Tools
- **CodeQL**: Static analysis for security vulnerabilities
- **OWASP ZAP**: Web application security testing
- **Bandit**: Python security linting
- **Safety**: Dependency vulnerability checking

## 13. Dependencies & Updates

### 13.1 Dependency Management
- Regular updates to patch security vulnerabilities
- Automated dependency scanning (Dependabot, Snyk)
- Review of third-party library security postures
- Minimal dependency footprint

### 13.2 Update Schedule
- **Critical Security Patches**: Within 24 hours
- **High Severity**: Within 1 week
- **Medium Severity**: Within 1 month
- **Django Framework**: Update to latest LTS version

## 14. Monitoring & Logging

### 14.1 Security Monitoring
- Failed authentication attempts
- Unusual data access patterns
- API rate limit violations
- Database query anomalies

### 14.2 Audit Logging
```python
# Log security-relevant events
- User authentication/logout
- Data access and modifications
- Permission changes
- Configuration updates
- Failed access attempts
```

### 14.3 Log Protection
- Logs do NOT contain sensitive data (passwords, tokens)
- Encrypted log storage
- Restricted access to logs
- Log retention policy (90 days)

## 15. Production Deployment Checklist

### 15.1 Pre-Deployment Security
- [ ] Change default SECRET_KEY
- [ ] Enable HTTPS/TLS
- [ ] Set DEBUG = False
- [ ] Configure ALLOWED_HOSTS
- [ ] Enable security headers
- [ ] Set up encrypted fields
- [ ] Configure secure cookie settings
- [ ] Implement rate limiting
- [ ] Set up monitoring and alerts

### 15.2 Infrastructure Security
- [ ] Firewall configuration
- [ ] Database access restrictions
- [ ] Regular backups with encryption
- [ ] DDoS protection
- [ ] Intrusion detection system (IDS)

## 16. Security Contact

For security vulnerabilities or concerns:
- **GitHub Security Advisories**: Private disclosure via GitHub
- **Issue Tracker**: Public non-sensitive security discussions
- **Response Time**: Acknowledgment within 48 hours

## 17. Future Enhancements

### 17.1 Planned Security Features
- [ ] End-to-end encryption for user messages (if added)
- [ ] Hardware security module (HSM) integration
- [ ] Multi-factor authentication (MFA)
- [ ] Biometric authentication
- [ ] Advanced threat detection with ML
- [ ] Zero-knowledge architecture exploration

### 17.2 Continuous Improvement
- Regular security training for developers
- Participation in bug bounty programs (production)
- Security certifications (ISO 27001, SOC 2)
- Compliance with emerging regulations

---

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Django Security Documentation](https://docs.djangoproject.com/en/4.2/topics/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [GDPR Official Text](https://gdpr-info.eu/)
- [CCPA Official Text](https://oag.ca.gov/privacy/ccpa)

---

**Note**: This document reflects the security implementation for a portfolio project. Production deployment would require additional hardening, professional security audits, and compliance certifications.
