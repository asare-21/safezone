# Privacy Policy

**Last Updated: December 19, 2025**

## Overview

SafeZone is committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, store, and protect your data in compliance with GDPR (General Data Protection Regulation) and CCPA (California Consumer Privacy Act).

## 1. Information We Collect

### 1.1 Data You Provide Directly
- **Incident Reports**: Category, title, description, location (GPS coordinates), timestamp
- **User Preferences**: Notification settings, alert radius, map preferences
- **Device Information**: Device ID, platform type (Android/iOS), FCM token for push notifications

### 1.2 Automatically Collected Data
- **Location Data**: GPS coordinates when reporting incidents or receiving proximity alerts
- **Usage Data**: App interactions, feature usage (anonymized)
- **Device Data**: Device ID, operating system, app version

### 1.3 Data We Do NOT Collect
- ❌ Real names (unless voluntarily provided)
- ❌ Email addresses (for anonymous users)
- ❌ Phone numbers
- ❌ Detailed movement patterns or location history
- ❌ Private messages or communications
- ❌ Payment information
- ❌ Social media profiles

## 2. How We Use Your Information

### 2.1 Primary Purposes
- **Safety Alerts**: Provide real-time proximity alerts about nearby safety incidents
- **Incident Mapping**: Display incidents on an interactive map for community awareness
- **Push Notifications**: Send relevant safety alerts via Firebase Cloud Messaging
- **Service Improvement**: Analyze usage patterns to improve app functionality

### 2.2 Legal Basis (GDPR)
- **Legitimate Interest**: Providing safety information to protect users
- **Consent**: You explicitly consent when submitting incident reports
- **Contractual Necessity**: To deliver the core functionality of the app

## 3. Data Security & Encryption

### 3.1 Encryption Measures
- ✅ **Data in Transit**: All API communications use HTTPS/TLS 1.2+ encryption
- ✅ **Data at Rest**: Sensitive database fields are encrypted using AES-256 encryption
- ✅ **Encrypted Fields**:
  - Firebase Cloud Messaging (FCM) tokens
  - Device identifiers
  - User preferences (when containing sensitive settings)
- ✅ **Secure Storage**: Database hosted with industry-standard security measures

### 3.2 Access Controls
- Role-based access control (RBAC) for backend systems
- Authentication required for modifying user data
- Regular security audits and vulnerability assessments
- Secure password storage using Django's built-in PBKDF2 algorithm

### 3.3 Security Best Practices
- Regular security updates and patches
- Secure secret key management (never committed to version control)
- Content Security Policy (CSP) headers
- CSRF protection enabled
- XSS protection enabled
- Clickjacking protection via X-Frame-Options

## 4. Data Retention

### 4.1 Incident Reports
- **Active Incidents**: Retained for 90 days from report date
- **Historical Data**: Aggregated and anonymized after 90 days for trend analysis
- **User-Requested Deletion**: Removed within 30 days of request

### 4.2 User Preferences
- Retained while the app is actively used
- Deleted after 12 months of inactivity
- Immediately deleted upon user request

### 4.3 Device Tokens
- Updated automatically when changed
- Deleted when device is unregistered or after 6 months of inactivity

## 5. Your Privacy Rights

### 5.1 GDPR Rights (EU Users)
- ✅ **Right to Access**: Request a copy of your data
- ✅ **Right to Rectification**: Correct inaccurate data
- ✅ **Right to Erasure**: Request deletion of your data ("Right to be Forgotten")
- ✅ **Right to Restriction**: Limit how we process your data
- ✅ **Right to Data Portability**: Receive your data in a portable format
- ✅ **Right to Object**: Opt-out of certain data processing
- ✅ **Right to Withdraw Consent**: Revoke consent at any time

### 5.2 CCPA Rights (California Users)
- ✅ **Right to Know**: Know what personal information is collected
- ✅ **Right to Delete**: Request deletion of personal information
- ✅ **Right to Opt-Out**: Opt-out of the "sale" of personal information (Note: We do not sell personal information)
- ✅ **Right to Non-Discrimination**: Equal service regardless of privacy choices

### 5.3 How to Exercise Your Rights
To exercise any of these rights, contact us at:
- **Portfolio Project Contact**: Via GitHub Issues at [https://github.com/asare-21/safezone/issues](https://github.com/asare-21/safezone/issues)
- **Response Time**: Within 30 days of request

## 6. Data Sharing & Third Parties

### 6.1 Third-Party Services
- **Firebase Cloud Messaging**: For push notifications (Google Privacy Policy applies)
- **Map Providers**: For displaying interactive maps (respective privacy policies apply)

### 6.2 No Data Sales
- ❌ We do NOT sell, rent, or trade your personal information to third parties
- ❌ We do NOT share data with advertisers or marketing companies
- ❌ We are NOT affiliated with law enforcement agencies

### 6.3 Legal Disclosures
We may disclose information only when required by law:
- Valid court orders or subpoenas
- Protection against fraud or security threats
- Enforcement of our Terms of Service

## 7. Children's Privacy

SafeZone is not intended for users under 13 years of age. We do not knowingly collect personal information from children under 13. If we discover such data, we will delete it immediately.

## 8. International Data Transfers

Data may be transferred and processed in countries outside your residence. We ensure appropriate safeguards are in place:
- Standard Contractual Clauses (SCCs) for EU data transfers
- Adequate security measures regardless of location
- Compliance with local data protection laws

## 9. Cookies & Tracking

### 9.1 Mobile App
- No cookies used in the mobile application
- Local data storage via SharedPreferences (Flutter) for user settings
- No third-party tracking or analytics beyond Firebase

### 9.2 Web Interface (if applicable)
- Essential cookies only for session management
- No advertising or tracking cookies

## 10. Anonymous Reporting

### 10.1 How It Works
- Enable "Anonymous Reporting" in Settings
- Reports are submitted without linking to your device ID or user account
- Location data is still required for incident mapping (core functionality)

### 10.2 Limitations
- Cannot track your personal reporting history when anonymous
- Trust score/reputation system unavailable in anonymous mode
- Admins may still verify source for abuse prevention

## 11. User Control & Settings

You have full control over your privacy:
- **Notification Settings**: Enable/disable push notifications, sounds, vibrations
- **Location Sharing**: Control when location is accessed (only during active use)
- **Anonymous Mode**: Report incidents without identification
- **Data Deletion**: Request full account deletion at any time

## 12. Changes to This Policy

We may update this Privacy Policy periodically. Changes will be:
- Posted on this page with an updated "Last Updated" date
- Communicated via in-app notification for material changes
- Effective immediately upon posting unless otherwise stated

## 13. Contact Information

### For Privacy Inquiries
- **GitHub Issues**: [https://github.com/asare-21/safezone/issues](https://github.com/asare-21/safezone/issues)
- **Repository**: [https://github.com/asare-21/safezone](https://github.com/asare-21/safezone)

### For Data Protection Officer (DPO) Inquiries
As a portfolio project, we currently do not have a dedicated DPO. For production deployment, a DPO would be appointed per GDPR requirements.

## 14. Compliance Certifications

### Current Status (Portfolio Project)
- ✅ Implements GDPR principles by design
- ✅ Follows CCPA requirements
- ✅ Uses industry-standard encryption
- ✅ Provides transparent privacy practices

### For Production Deployment
- [ ] GDPR compliance certification
- [ ] CCPA compliance certification
- [ ] ISO 27001 security certification
- [ ] SOC 2 Type II audit
- [ ] Regular third-party security audits

## 15. Acknowledgment

By using SafeZone, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.

---

**Note**: This is a portfolio project demonstrating privacy and security best practices. For production deployment, additional legal review and compliance measures would be required.
