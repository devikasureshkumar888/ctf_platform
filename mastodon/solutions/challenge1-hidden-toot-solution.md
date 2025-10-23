# Solution: The Hidden Toot

**Challenge:** Mastodon - Chapter 1, Challenge 1
**Difficulty:** Easy
**Points:** 100
**Type:** OSINT / Information Disclosure / HTML Source Code Analysis

---

## Challenge Description

Welcome to CyberLab's Mastodon instance! A mysterious user has joined our social network. There are rumors that user @ctf_user_2024 has posted something interesting. Can you find their secret message?

**Target:** https://mastodon.cyberlab.local
**Username to investigate:** @ctf_user_2024

---

## Learning Objectives

After completing this challenge, you will understand:

- **HTML source code inspection** techniques
- How to find hidden information in web pages
- Why secrets shouldn't be in client-side code
- **OSINT (Open Source Intelligence)** gathering methods
- Common places developers accidentally leave sensitive data

---

## Solution Walkthrough

### Step 1: Navigate to the User's Profile

1. Go to `https://mastodon.cyberlab.local`
2. Search for user: `@ctf_user_2024`
3. Or navigate directly to: `https://mastodon.cyberlab.local/@ctf_user_2024`

### Step 2: Initial Reconnaissance

**What to look for:**
- User's bio/description
- Pinned posts (toots)
- Recent posts
- Profile information
- Custom fields/metadata

Look at visible content first - sometimes flags are hidden in plain sight!

### Step 3: View Page Source

**Method 1: Browser**
- Right-click on the page → "View Page Source"
- Or press `Ctrl+U` (Windows/Linux) or `Cmd+Option+U` (Mac)

**Method 2: Using curl**
```bash
curl https://mastodon.cyberlab.local/@ctf_user_2024
```

**Method 3: Using wget**
```bash
wget https://mastodon.cyberlab.local/@ctf_user_2024 -O mastodon_profile.html
cat mastodon_profile.html
```

### Step 4: Search for the Flag

Once you have the page source, search for:

**Search for "CTF":**
```bash
curl https://mastodon.cyberlab.local/@ctf_user_2024 | grep -i "ctf"
```

**Search for "FLAG":**
```bash
curl https://mastodon.cyberlab.local/@ctf_user_2024 | grep -i "flag"
```

**Search for "CYBERLABFLAG":**
```bash
curl https://mastodon.cyberlab.local/@ctf_user_2024 | grep "CYBERLABFLAG"
```

**In browser:** Use `Ctrl+F` to search the page source for keywords:
- `ctf`
- `flag`
- `CYBERLABFLAG`
- `<!--` (HTML comment)

### Step 5: Find the Flag in HTML Comment

You'll find an HTML comment like this:

```html
<div class="account-header">
  <h1>@ctf_user_2024</h1>
  <p>Welcome to CyberLab Mastodon! 🚀</p>
  <!-- CTF Flag: CYBERLABFLAG{hidden_in_plain_sight} -->
</div>
```

Or in a post (toot):

```html
<div class="status-content">
  <p>Welcome to CyberLab Mastodon! Excited to be part of this community!</p>
  <!-- CTF Flag: CYBERLABFLAG{hidden_in_plain_sight} -->
</div>
```

### Step 6: Alternative Locations

If not in HTML comments, check:

**Profile Metadata Fields:**
- Website URL might contain flag
- Custom profile fields
- Bio with encoded text

**Post Content:**
- Flag might be base64 encoded in a post
- Hidden in image alt-text
- In hashtags

**Example:**
```
Bio: "Welcome to CyberLab! 🚀 Q1lCRVJMQUJGTEFHe2hpZGRlbl9pbl9wbGFpbl9zaWdodH0="
```

Decode base64:
```bash
echo "Q1lCRVJMQUJGTEFHe2hpZGRlbl9pbl9wbGFpbl9zaWdodH0=" | base64 -d
# Output: CYBERLABFLAG{hidden_in_plain_sight}
```

### Step 7: Submit the Flag

1. Copy the flag: `CYBERLABFLAG{...}`
2. Paste into CTFd submission box
3. Submit and get 100 points! 🎉

---

## Alternative Methods

### Method A: Developer Tools

1. Open Browser Developer Tools (F12)
2. Go to **Elements** or **Inspector** tab
3. Use `Ctrl+F` to search for "flag" or "CTF"
4. Expand HTML elements to find hidden content

### Method B: Automated Search Script

```python
import requests
import re

url = "https://mastodon.cyberlab.local/@ctf_user_2024"
response = requests.get(url)

# Search for flag pattern
flag_pattern = r'CYBERLABFLAG\{[a-z0-9_]+\}'
flags = re.findall(flag_pattern, response.text)

if flags:
    print(f"[+] Flag found: {flags[0]}")
else:
    print("[-] No flag found in page source")

# Search for HTML comments
comments = re.findall(r'<!--(.+?)-->', response.text, re.DOTALL)
for comment in comments:
    if 'FLAG' in comment or 'CTF' in comment:
        print(f"[+] Interesting comment: {comment}")
```

### Method C: Browser Extensions

Use extensions like:
- **Wappalyzer** - Identify technologies
- **EditThisCookie** - View cookies
- **Web Developer** - View hidden elements

---

## Tools Used

- **Web Browser** - Chrome, Firefox, Edge
- **Developer Tools** - Built-in browser tools (F12)
- **curl** - Command-line HTTP client
- **grep** - Search text
- **base64** - Decode base64 (if needed)

---

## Hints Explanation

**Hint 1** (0 points): "Try viewing the page source..."
- Tells you to use "View Page Source" feature

**Hint 2** (25 points): "Look for HTML comments..."
- Explains that the flag is in an HTML comment `<!-- -->`

---

## Key Takeaways

### What are HTML Comments?

HTML comments are notes in HTML code that aren't displayed on the page:

```html
<!-- This is a comment - users won't see it -->
<p>This text is visible</p>
```

**Purpose:**
- Document code
- Temporarily disable code
- Leave notes for developers

**Security Issue:**
- Sent to browser (visible in page source)
- Not a secure way to hide information
- Easily discoverable

### Why is This a Vulnerability?

**Developers often accidentally leave:**
- Passwords in comments
- API keys
- Internal URLs
- Debug information
- Business logic
- TODO notes with sensitive info

**Example - Real Bug:**
```html
<!-- TODO: Remove test credentials before production -->
<!-- Admin password: SuperSecret123! -->
```

### Real-World Examples

- **GitHub secrets scanner** finds API keys in commits
- **Google Dorking** finds sensitive comments: `intext:"password" filetype:html`
- Many CTFs and bug bounties involve finding commented-out secrets

---

## Remediation

### How to Prevent This Issue

**1. Remove Comments Before Production**

```bash
# Build process should strip comments
# Use tools like html-minifier, uglify-js

html-minifier --collapse-whitespace --remove-comments index.html
```

**2. Don't Put Secrets in Frontend Code**

```javascript
// BAD - Secret in client-side code
const API_KEY = "secret_key_12345";

// GOOD - Get from server
fetch('/api/get-key')
  .then(key => useKey(key));
```

**3. Use Environment Variables**

```python
# BAD
password = "SuperSecret123"

# GOOD
import os
password = os.environ.get('DB_PASSWORD')
```

**4. Code Review**

- Review all HTML before deployment
- Search for TODO, FIXME, DEBUG comments
- Use automated scanners

**5. Automated Security Scanning**

```bash
# Scan for secrets in code
git secrets --scan

# Or use tools like:
# - truffleHog
# - GitLeaks
# - detect-secrets
```

---

## Further Reading

- [OWASP - Information Exposure Through Source Code](https://owasp.org/www-community/vulnerabilities/Information_exposure_through_query_strings_in_url)
- [HTML Comments and Security](https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html)
- [Source Code Disclosure Vulnerabilities](https://portswigger.net/kb/issues/00600100_source-code-disclosure)

---

## Practice More

**Similar challenges:**
- Check other pages on mastodon.cyberlab.local for hidden comments
- Look at JavaScript files for secrets
- Examine CSS files (sometimes flags hidden there too)
- Check HTTP headers for interesting information

**Commands to try:**
```bash
# View headers
curl -I https://mastodon.cyberlab.local

# Download and search JavaScript files
curl https://mastodon.cyberlab.local/assets/application.js | grep -i "api\|key\|password\|secret"

# Check robots.txt
curl https://mastodon.cyberlab.local/robots.txt
```

---

## OSINT Techniques Used

1. **Profile Investigation** - Gathering info from public profiles
2. **Source Code Analysis** - Examining HTML/JS/CSS
3. **Metadata Extraction** - Finding hidden data in various fields
4. **Pattern Recognition** - Knowing where to look for flags

---

## Challenge Variants

This challenge might also include:

**Variant 1: Base64 Encoded Flag**
```html
<!-- Flag: Q1lCRVJMQUJGTEFHe2Jhc2U2NF9lbmNvZGVkfQ== -->
```
Decode: `echo "..." | base64 -d`

**Variant 2: ROT13 Encoded**
```html
<!-- Flag: PLOREYNOSYNY{ebg13_rapbqrq} -->
```
Decode: `echo "..." | tr 'A-Za-z' 'N-ZA-Mn-za-m'`

**Variant 3: Hidden in CSS**
```css
/* Flag: CYBERLABFLAG{hidden_in_css} */
.secret-class { display: none; }
```

**Variant 4: In JavaScript**
```javascript
// TODO: Remove this before production
// const flag = "CYBERLABFLAG{in_javascript}";
```

---

**Congratulations on solving this challenge!** 🎉

You've learned an important lesson: **Never put sensitive information in client-side code!** Always assume that anything sent to the browser can be seen by users.

**Next Challenge:** Try "Profile Picture Secrets" to learn about metadata in images!
