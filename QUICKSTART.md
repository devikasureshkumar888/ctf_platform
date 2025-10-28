# CTF Platform - Quick Start Guide

This guide will walk you through setting up and deploying the CTF challenges step by step.

## 🎯 Prerequisites

- Access to CTFd instance at: `http://172.24.191.68:8000`
- CTFd API token (already configured)
- Access to Mastodon: `https://mastodon.cyberlab.local`
- Access to Hospital system: `https://hospital.cyberlab.local`
- CyberLab GitHub repository access

## 📁 Project Structure

```
ctf_platform/
├── ctf_platform/           # Main platform code
│   ├── .env               # YOUR CREDENTIALS (already configured)
│   ├── mastodon/          # Mastodon challenges
│   └── hospital/          # Hospital challenges (duplicate - use root)
├── hospital/              # Hospital challenges (USE THIS ONE)
├── mastodon/              # Mastodon challenges (mostly empty)
├── scripts/               # Utility scripts
└── tests/                 # Connection tests
```

## 🚀 Quick Start (5 Steps)

### Step 1: Load Environment Variables

```bash
cd /home/devika/CTFd/ctf-automation/ctf_platform
source ./setup-env.sh
```

Expected output:
```
✓ Environment variables loaded
Configuration:
  CTFD_URL: http://172.24.191.68:8000
  ...
```

### Step 2: Test CTFd Connection

```bash
./tests/test-connection.sh
```

Expected output:
```
✓ Connection test successful!
```

**If this fails:** You need to ensure CTFd is accessible from your network. See "Troubleshooting" below.

### Step 3: View Generated Flags

**Hospital flags:**
```bash
./hospital/test-local.sh
```

**Mastodon flags:**
```bash
./ctf_platform/mastodon/test-local.sh
```

**Save these flag values!** You'll need them later.

### Step 4: Deploy Challenges to CTFd

```bash
# Deploy hospital challenges
./hospital/register-challenges.sh

# Deploy mastodon challenges
./ctf_platform/mastodon/register-challenges.sh
```

Then verify at: http://172.24.191.68:8000/admin/challenges

### Step 5: Plant Flags in Target Systems

Now follow the detailed instructions below for Mastodon and Hospital.

---

## 📝 Detailed Instructions

### Part A: Deploy to CTFd (30 minutes)

#### 1. Test Connection
```bash
cd /home/devika/CTFd/ctf-automation/ctf_platform
source ./setup-env.sh
./tests/test-connection.sh
```

#### 2. Register Challenges
```bash
# Hospital challenges (2 challenges)
./hospital/register-challenges.sh

# Mastodon challenges (2 challenges)
./ctf_platform/mastodon/register-challenges.sh
```

#### 3. Verify in CTFd
Open browser: http://172.24.191.68:8000/admin/challenges
- You should see 4 challenges total
- Challenges are registered but flags are NOT planted yet

---

### Part B: Plant Mastodon Flags (30 minutes)

#### Generated Flags (from test-local.sh):
- Challenge 1: `CYBERLABFLAG{88f692ff0662e5a3}` (Hidden toot)
- Challenge 2: `CYBERLABFLAG{e86bd1a706c69f8e}` (Profile picture)

#### Manual Steps:

**1. Register Mastodon Account**
- Visit: https://mastodon.cyberlab.local
- Click "Sign up"
- Username: `ctf_user_2024`
- Email: [your email]
- Password: [create & save securely]

**2. Create Profile Picture with Flag**
```bash
cd /home/devika/CTFd/ctf-automation/ctf_platform/ctf_platform/mastodon
./plant-flags-web.sh
```

This creates a profile picture with EXIF metadata containing the flag.

**3. Upload to Mastodon**
- Log in as `@ctf_user_2024`
- Go to "Edit Profile"
- Upload profile picture from: `.ctf_temp/ctf_profile_picture.jpg`
- Bio: "Welcome to CyberLab Mastodon! 🚀"

**4. Create Post with Hidden Flag**
- Create a public post: "Welcome to CyberLab Mastodon! #CTF #CyberLab"
- The flag will be in HTML comment (the plant-flags-web.sh script provides instructions)
- Pin the post to your profile

---

### Part C: Plant Hospital Flags (GitHub PR - 1 hour)

#### Generated Flags (from test-local.sh):
- Challenge 1: `CYBERLABFLAG{97c96171e0509389}` (Patient records)
- Challenge 2: `CYBERLABFLAG{86f702cbb49e1f2a}` (Admin dashboard)

#### GitHub Workflow:

**1. Clone CyberLab Repository**
```bash
cd ~
# Ask your team for the repo URL
git clone [CYBERLAB_REPO_URL]
cd [repo-name]
```

**2. Create GitHub Issue**
Go to GitHub web interface and create:
```
Title: CTF Flag Planting - Hospital System

Description:
Adding CTF challenge data for CyberLab CTF event.

Changes needed:
1. Add test patient record (Patient ID 999) with CTF flag
2. Add hidden admin route at /ctf_admin_panel_secret_2024

Impact: Educational/training purposes only
Timeline: Needed within 5 days for CTF event
```

This will auto-create a branch for you!

**3. Checkout the Branch**
```bash
git fetch origin
git checkout issue-[NUMBER]-ctf-flag-planting
```

**4. Navigate to Hospital Code**
```bash
cd cluster/environments/hospital/
ls -la  # Explore the structure
```

**5. Add Database Record**

Create/edit file: `db/seeds/ctf_data.sql` (adjust path as needed)

```sql
-- CTF Challenge Data - Can be removed after event

-- Challenge 1: Patient Records (IDOR Vulnerability)
INSERT INTO patients (id, name, age, diagnosis, notes, created_at, updated_at)
VALUES (
    999,
    'CTF Test Patient',
    45,
    'Routine Checkup',
    'Medical History: Patient reports normal health. CTF Flag: CYBERLABFLAG{97c96171e0509389}',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE
SET notes = 'Medical History: Patient reports normal health. CTF Flag: CYBERLABFLAG{97c96171e0509389}',
    updated_at = NOW();
```

**6. Add Hidden Admin Route**

Find the routes file (e.g., `app.py` or `routes/index.js`) and add:

**For Flask (Python):**
```python
@app.route('/ctf_admin_panel_secret_2024')
def ctf_admin_panel():
    return '''
    <!DOCTYPE html>
    <html>
    <head><title>Admin Panel</title></head>
    <body>
        <h1>Hospital Admin Panel</h1>
        <p>Welcome to the administrative dashboard.</p>
        <!-- CTF Flag: CYBERLABFLAG{86f702cbb49e1f2a} -->
    </body>
    </html>
    '''
```

**For Express (Node.js):**
```javascript
router.get('/ctf_admin_panel_secret_2024', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head><title>Admin Panel</title></head>
        <body>
            <h1>Hospital Admin Panel</h1>
            <!-- CTF Flag: CYBERLABFLAG{86f702cbb49e1f2a} -->
        </body>
        </html>
    `);
});
```

**7. Commit and Push**
```bash
git add .
git commit -m "Add CTF challenge data for Hospital system

- Add test patient record (ID 999) with flag in notes
- Add hidden admin route /ctf_admin_panel_secret_2024
- For educational CTF event
- Can be removed after event"

git push origin issue-[NUMBER]-ctf-flag-planting
```

**8. Create Pull Request on GitHub**
```
Title: CTF Flag Planting - Hospital System

## Summary
Adding CTF challenge data for educational CyberLab CTF event.

## Changes
1. ✅ Added test patient record (ID 999) with flag in medical notes
2. ✅ Added hidden admin route at `/ctf_admin_panel_secret_2024`

## Testing
- Database seed uses ON CONFLICT for safe re-runs
- Route is hidden (requires directory enumeration)
- Both changes are isolated and removable

## Impact
- Minimal: 1 database record + 1 hidden route
- No changes to existing functionality
- Can be removed after CTF event

Closes #[ISSUE_NUMBER]
```

**9. Wait for PR Review**
Once approved and merged, the flags will be live in the Hospital system.

---

## 🧪 Verification & Testing

### Verify Hospital Flags
```bash
# Test admin panel route
curl https://hospital.cyberlab.local/ctf_admin_panel_secret_2024
# Should return HTML with flag in comment

# Test patient record (requires logged in session)
# Log in to hospital, then try accessing patient ID 999
```

### Verify Mastodon Flags
```bash
# Visit profile
open https://mastodon.cyberlab.local/@ctf_user_2024

# Download profile picture and check EXIF
wget https://mastodon.cyberlab.local/[profile-pic-url]
exiftool profile_pic.jpg | grep -i comment

# Check post for HTML comment (view page source)
```

### End-to-End Test
```bash
cd /home/devika/CTFd/ctf-automation/ctf_platform
source ./setup-env.sh
./tests/test-end-to-end.sh
```

---

## 📋 Flag Reference

All flags are deterministic (generated from seeds):

| Challenge | Location | Flag |
|-----------|----------|------|
| Hospital Patient Records | Database (Patient ID 999) | `CYBERLABFLAG{97c96171e0509389}` |
| Hospital Admin Dashboard | Hidden route `/ctf_admin_panel_secret_2024` | `CYBERLABFLAG{86f702cbb49e1f2a}` |
| Mastodon Hidden Toot | HTML comment in @ctf_user_2024's post | `CYBERLABFLAG{88f692ff0662e5a3}` |
| Mastodon Profile Secrets | Profile picture EXIF metadata | `CYBERLABFLAG{e86bd1a706c69f8e}` |

---

## 🔧 Troubleshooting

### Problem: Can't connect to CTFd

**Symptoms:**
```
✗ Cannot reach CTFd server
```

**Solutions:**
1. Check if you're on the right network:
   ```bash
   ping 172.24.191.68
   ```

2. Check if CTFd is running:
   ```bash
   docker ps | grep ctfd
   ```

3. Try accessing in browser: http://172.24.191.68:8000

4. Check if you need to be on Ronin network or VPN

### Problem: Environment variables not loaded

**Symptoms:**
```
ERROR: CTFD_TOKEN environment variable not set
```

**Solutions:**
```bash
# Always source the setup script first
source ./setup-env.sh

# Or manually export
export CTFD_URL="http://172.24.191.68:8000"
export CTFD_TOKEN="ctfd_357b1387f91508a7be864607064b0ec39e10493661c5ed8a770f64e90983e4e9"
```

### Problem: Permission denied on scripts

**Solution:**
```bash
chmod +x /home/devika/CTFd/ctf-automation/ctf_platform/tests/*.sh
chmod +x /home/devika/CTFd/ctf-automation/ctf_platform/hospital/*.sh
chmod +x /home/devika/CTFd/ctf-automation/ctf_platform/ctf_platform/mastodon/*.sh
chmod +x /home/devika/CTFd/ctf-automation/ctf_platform/scripts/*.sh
```

### Problem: Can't find CyberLab repository

**Solution:**
Ask your team for:
- Repository URL
- Confirmation that `cluster/environments/hospital/` exists
- Your GitHub access permissions

---

## 📞 Next Steps

**Right now:**
1. ✅ Test CTFd connection: `source ./setup-env.sh && ./tests/test-connection.sh`
2. ✅ View generated flags: `./hospital/test-local.sh`
3. ✅ Make note of all 4 flag values

**Once CTFd is accessible:**
1. Deploy challenges to CTFd
2. Register Mastodon user
3. Plant Mastodon flags
4. Create Hospital GitHub PR
5. Test everything end-to-end

---

## 📚 Additional Resources

- CTFd Admin Panel: http://172.24.191.68:8000/admin
- Mastodon Instance: https://mastodon.cyberlab.local
- Hospital Instance: https://hospital.cyberlab.local
- Project Docs: `/home/devika/CTFd/ctf-automation/ctf_platform/docs/`

---

## ✅ Success Checklist

- [ ] Environment configured and tested
- [ ] CTFd connection working
- [ ] 4 challenges registered in CTFd
- [ ] Mastodon user @ctf_user_2024 created
- [ ] Mastodon flags planted (profile pic + post)
- [ ] Hospital GitHub issue created
- [ ] Hospital PR submitted
- [ ] Hospital PR merged
- [ ] All 4 flags verified and accessible
- [ ] End-to-end test passed

---

**Good luck! 🚀**

If you need help, refer to the detailed documentation in `/docs/` or ask your team.
