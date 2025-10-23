# Solution: Doctor's Dashboard Discovery

**Challenge:** Hospital - Chapter 2, Challenge 2
**Difficulty:** Medium
**Points:** 250
**Type:** Forced Browsing / Directory Enumeration / Security Through Obscurity

---

## Challenge Description

The hospital has a secret administrative dashboard for doctors and staff. It's not linked anywhere on the main website, but it exists somewhere. Hospital administrators aren't always good at security through obscurity.

**Target:** https://hospital.cyberlab.local

---

## Learning Objectives

After completing this challenge, you will understand:

- **Forced Browsing** and directory enumeration techniques
- Why "security through obscurity" is not effective
- Common admin panel naming patterns
- Web reconnaissance and enumeration tools
- The importance of proper authentication on admin endpoints

---

## Solution Walkthrough

### Step 1: Information Gathering

**Examine the Website:**
1. Navigate to `https://hospital.cyberlab.local`
2. View the page source (Ctrl+U or Right-click → View Page Source)
3. Look for:
   - HTML comments
   - Hidden links
   - JavaScript files
   - Configuration files

### Step 2: Check Standard Files

**robots.txt:**
```bash
curl https://hospital.cyberlab.local/robots.txt
```

Look for disallowed paths that might reveal admin areas:
```
User-agent: *
Disallow: /admin
Disallow: /dashboard
Disallow: /ctf_admin_panel_secret_2024
```

**sitemap.xml:**
```bash
curl https://hospital.cyberlab.local/sitemap.xml
```

**Other common files:**
```bash
curl https://hospital.cyberlab.local/.git/config
curl https://hospital.cyberlab.local/.env
curl https://hospital.cyberlab.local/config.php
```

### Step 3: Manual Directory Enumeration

Try common admin panel paths:

```bash
# Standard admin paths
https://hospital.cyberlab.local/admin
https://hospital.cyberlab.local/administrator
https://hospital.cyberlab.local/admin.php
https://hospital.cyberlab.local/login
https://hospital.cyberlab.local/dashboard
https://hospital.cyberlab.local/panel
https://hospital.cyberlab.local/manage
https://hospital.cyberlab.local/management

# Hospital-specific paths
https://hospital.cyberlab.local/doctor
https://hospital.cyberlab.local/doctor/dashboard
https://hospital.cyberlab.local/staff
https://hospital.cyberlab.local/medical
https://hospital.cyberlab.local/staff/login

# Common CTF patterns
https://hospital.cyberlab.local/ctf
https://hospital.cyberlab.local/ctf_admin
https://hospital.cyberlab.local/admin_secret
https://hospital.cyberlab.local/secret_panel
https://hospital.cyberlab.local/hidden
```

### Step 4: CTF-Specific Enumeration

Since this is a CTF challenge, try paths with:
- "ctf" in the name
- "secret" in the name
- Year (2024, 2025)
- "admin" or "panel"

**The winning path:**
```
https://hospital.cyberlab.local/ctf_admin_panel_secret_2024
```

### Step 5: Automated Enumeration (Optional)

**Using dirb:**
```bash
dirb https://hospital.cyberlab.local /usr/share/dirb/wordlists/common.txt
```

**Using gobuster:**
```bash
gobuster dir -u https://hospital.cyberlab.local \
    -w /usr/share/wordlists/dirb/common.txt \
    -x php,html,txt
```

**Using ffuf:**
```bash
ffuf -u https://hospital.cyberlab.local/FUZZ \
     -w /usr/share/wordlists/dirb/common.txt \
     -mc 200,301,302
```

**Custom Wordlist for CTF:**

Create a custom wordlist `ctf-admin-paths.txt`:
```
admin
administrator
dashboard
panel
manage
doctor
staff
ctf
ctf_admin
admin_secret
secret_panel
ctf_admin_panel
ctf_admin_panel_secret
ctf_admin_panel_secret_2024
ctf_admin_panel_secret_2025
hidden_admin
doctor_dashboard
staff_dashboard
```

Then run:
```bash
ffuf -u https://hospital.cyberlab.local/FUZZ \
     -w ctf-admin-paths.txt \
     -mc 200
```

### Step 6: Finding the Flag

Once you access the admin panel at `/ctf_admin_panel_secret_2024`, you'll see:

**Option 1: Visible Flag**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel</title>
</head>
<body>
    <h1>Hospital Admin Panel</h1>
    <p>Welcome to the administrative dashboard.</p>
    <p>Flag: CYBERLABFLAG{...}</p>
</body>
</html>
```

**Option 2: HTML Comment**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel</title>
</head>
<body>
    <h1>Hospital Admin Panel</h1>
    <p>Welcome to the administrative dashboard.</p>
    <!-- CTF Admin Panel Flag: CYBERLABFLAG{...} -->
</body>
</html>
```

If in a comment, view page source (Ctrl+U) to see it.

### Step 7: Extract and Submit Flag

1. Copy the flag: `CYBERLABFLAG{...}`
2. Submit in CTFd
3. Earn 250 points! 🎉

---

## Alternative Methods

### Method A: Brute Force Script

```python
import requests

base_url = "https://hospital.cyberlab.local"

# List of common admin paths
paths = [
    "/admin",
    "/administrator",
    "/dashboard",
    "/panel",
    "/ctf_admin",
    "/ctf_admin_panel_secret_2024",
    # ... add more
]

for path in paths:
    url = f"{base_url}{path}"
    response = requests.get(url)

    if response.status_code == 200:
        print(f"[+] Found: {url}")
        if "CYBERLABFLAG" in response.text:
            print(f"[!] FLAG FOUND at {url}!")
            print(response.text)
```

### Method B: Google Dorking

Sometimes admin panels are indexed:
```
site:hospital.cyberlab.local admin
site:hospital.cyberlab.local dashboard
site:hospital.cyberlab.local ctf
site:hospital.cyberlab.local inurl:admin
```

### Method C: Wayback Machine

Check if the admin panel was previously public:
```
https://web.archive.org/web/*/hospital.cyberlab.local/*admin*
```

### Method D: Check JavaScript Files

Look for endpoint references in JavaScript:
```bash
curl https://hospital.cyberlab.local/js/main.js | grep -i "admin\|dashboard\|panel"
```

---

## Tools Used

- **Web Browser** - Manual testing and viewing source
- **curl** - HTTP requests
- **dirb / gobuster / ffuf** - Directory enumeration
- **Burp Suite** - Web application testing (optional)
- **Python requests** - Custom automation

---

## Hints Explanation

**Hint 1** (0 points): "Common admin paths include: /admin, /dashboard..."
- Gives you starting points for enumeration

**Hint 2** (50 points): "Try checking robots.txt or looking for hidden comments..."
- Suggests specific files to check

**Hint 3** (75 points): "The admin panel might have 'ctf' or 'secret' or a year..."
- Narrows down the naming pattern

**Hint 4** (100 points): "Try: /ctf_admin_panel_secret_2024"
- Gives you the exact path (basically the answer)

---

## Key Takeaways

### What is Forced Browsing?

**Forced Browsing** (also called "Directory Traversal" or "Path Enumeration") is:
- Accessing resources not linked from the main application
- Guessing or enumerating hidden URLs
- Exploiting predictable naming patterns
- Finding unprotected admin interfaces

### Why is "Security Through Obscurity" Bad?

**Security Through Obscurity** means:
- Hiding something instead of properly securing it
- Assuming no one will find your hidden admin panel
- Not implementing authentication because "nobody knows the URL"

**Why it fails:**
- Attackers use automated tools to find hidden paths
- URLs can be leaked (logs, backups, browser history)
- Predictable patterns make guessing easy
- Not a replacement for proper authentication

### Real-World Examples

- **2019 - Capital One Breach:** Misconfigured admin panel exposed
- **2020 - SolarWinds:** Hidden update server discovered
- **Countless admin panels** found via Shodan and Censys

---

## Remediation

### How to Fix This Vulnerability

**1. Implement Proper Authentication**

```python
# BAD - No authentication
@app.route('/admin_panel')
def admin_panel():
    return render_template('admin.html')

# GOOD - Require authentication
@app.route('/admin')
@login_required
@admin_required
def admin_panel():
    if not current_user.is_admin:
        abort(403)
    return render_template('admin.html')
```

**2. Use Strong, Unpredictable URLs (But Still Add Auth!)**

```python
# If you must have a "hidden" panel, use UUIDs
# BUT STILL REQUIRE AUTHENTICATION!

import secrets

# Generate: /admin/a7f3e9b2-1c5d-4e8a-9b7f-3e2a1c5d4e8a
admin_token = secrets.token_urlsafe(32)

@app.route(f'/admin/{admin_token}')
@login_required
@admin_required
def admin_panel():
    # Still require proper auth even with complex URL!
    return render_template('admin.html')
```

**3. Implement IP Whitelisting**

```python
ALLOWED_ADMIN_IPS = ['10.0.0.0/8', '192.168.1.100']

@app.before_request
def check_admin_access():
    if request.path.startswith('/admin'):
        if request.remote_addr not in ALLOWED_ADMIN_IPS:
            abort(403)
```

**4. Add Rate Limiting**

Prevent enumeration attacks:
```python
from flask_limiter import Limiter

limiter = Limiter(app, key_func=lambda: request.remote_addr)

@app.route('/admin')
@limiter.limit("10 per minute")
def admin_panel():
    # ...
```

**5. Monitor for Enumeration Attempts**

- Log all 404 errors
- Alert on rapid 404s from same IP
- Block IPs with suspicious patterns

---

## Further Reading

- [OWASP - Forced Browsing](https://owasp.org/www-community/attacks/Forced_browsing)
- [OWASP - Testing for Directory Traversal](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/01-Testing_Directory_Traversal_File_Include)
- [PortSwigger - Information Disclosure](https://portswigger.net/web-security/information-disclosure)

---

## Practice More

**Try these next:**
- Search for other hidden endpoints in the Hospital system
- Check if the admin panel has any functionality (file upload, user management)
- Look for other web applications with unprotected admin panels
- Practice with platforms like HackTheBox, TryHackMe

---

## Common Admin Panel Paths Reference

```
/admin              /administrator      /admin.php          /admin.html
/login              /signin             /auth               /authenticate
/dashboard          /panel              /controlpanel       /control
/manage             /manager            /management         /backend
/staff              /employee           /doctor             /nurse
/cp                 /cms                /console            /portal
/secure             /private            /internal           /intranet
/wp-admin           /phpmyadmin         /adminer           /admin_area
```

---

**Congratulations on solving this challenge!** 🎉

You've learned why hiding admin panels without proper authentication is ineffective, and how attackers use enumeration techniques to discover hidden resources. Always implement proper authentication and authorization!
