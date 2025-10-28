# GitHub Workflow - Planting CTF Flags via Pull Requests

Since both Mastodon and Hospital are in the CyberLab GitHub repository, you'll plant ALL flags via GitHub PRs!

---

## 🎯 **Overview**

**What you need to do:**
1. Create 2 GitHub issues (one for Mastodon, one for Hospital)
2. Create PRs with flag planting code
3. Wait for team to review and merge
4. Test that flags are accessible

**Total time:** ~2 hours of work + waiting for PR reviews

---

## 📋 **Your Flags Reference**

Save these - you'll need them!

| System | Challenge | Flag | Location |
|--------|-----------|------|----------|
| **Hospital** | Patient Records | `CYBERLABFLAG{97c96171e0509389}` | Database record (Patient ID 999) |
| **Hospital** | Admin Dashboard | `CYBERLABFLAG{86f702cbb49e1f2a}` | Hidden route `/ctf_admin_panel_secret_2024` |
| **Mastodon** | Hidden Toot | `CYBERLABFLAG{88f692ff0662e5a3}` | HTML comment in @ctf_user_2024's post |
| **Mastodon** | Profile Secrets | `CYBERLABFLAG{e86bd1a706c69f8e}` | Profile picture EXIF metadata |

---

## 🔧 **PART 1: Hospital Flag Planting (via GitHub PR)**

### **Step 1: Create GitHub Issue for Hospital**

Go to the CyberLab GitHub repository and create an issue:

```
Title: CTF Flag Planting - Hospital System

Description:
## Purpose
Adding CTF challenge data to the Hospital system for CyberLab CTF event.

## Changes Needed
1. ✅ Add test patient record (Patient ID 999) with flag in medical notes
2. ✅ Add hidden admin route at `/ctf_admin_panel_secret_2024`

## Implementation Details

### Challenge 1: Patient Records (IDOR Vulnerability)
- **Flag:** `CYBERLABFLAG{97c96171e0509389}`
- **Location:** Database record - Patient ID 999, medical notes field
- **Method:** Database seed/migration

### Challenge 2: Admin Dashboard (Directory Enumeration)
- **Flag:** `CYBERLABFLAG{86f702cbb49e1f2a}`
- **Location:** Hidden route `/ctf_admin_panel_secret_2024`
- **Method:** Add route to application

## Impact
- **Risk Level:** Low - isolated test data
- **Reversibility:** High - can be easily removed after CTF
- **Files Modified:**
  - Database seed file (e.g., `db/seeds/ctf_data.sql`)
  - Routes file (e.g., `app.py` or `routes/index.js`)

## Timeline
Needed within 5 days for CTF event launch.

## Testing Plan
- ✅ Database seed can run without conflicts (uses `ON CONFLICT`)
- ✅ Route is hidden (not linked in UI, requires enumeration)
- ✅ No impact on existing functionality

## Cleanup
A cleanup script will be provided to remove CTF data after the event.

## Related CTFd Challenges
- Challenge ID 2: Hospital Example Challenge 1 (100 points)
- Challenge ID 4: Hospital Example Challenge 2 (200 points)

---

**Label:** enhancement, ctf, education
**Assignees:** [tag relevant team members]
```

### **Step 2: Clone CyberLab Repository**

```bash
cd ~
# Get the repo URL from your team
git clone [CYBERLAB_REPO_URL] cyberlab
cd cyberlab
```

### **Step 3: Checkout Auto-Created Branch**

After creating the issue, GitHub will create a branch. Fetch it:

```bash
git fetch origin
# The branch will be named something like: issue-123-ctf-flag-planting-hospital-system
git checkout issue-[NUMBER]-ctf-flag-planting-hospital-system
```

### **Step 4: Navigate to Hospital Directory**

```bash
cd cluster/environments/hospital/
ls -la  # Explore the structure
```

### **Step 5: Add Database Record**

Find the database seeds directory (likely `db/seeds/` or `migrations/`), then create:

**File:** `db/seeds/ctf_data.sql` (or similar path)

```sql
-- ============================================================
-- CTF Challenge Data for CyberLab CTF Event
-- Can be removed after event completion
-- ============================================================

-- Challenge 1: Patient Records (IDOR Vulnerability)
-- CTFd Challenge ID: 2
-- Points: 100
-- Flag: CYBERLABFLAG{97c96171e0509389}
--
-- Vulnerability: Insecure Direct Object Reference (IDOR)
-- Players should find patient ID 999 by enumerating patient IDs
-- Flag is hidden in the medical notes field

INSERT INTO patients (
    id,
    name,
    age,
    diagnosis,
    notes,
    created_at,
    updated_at
)
VALUES (
    999,
    'CTF Test Patient',
    45,
    'Routine Checkup',
    'Medical History: Patient reports normal health status. Previous visits show no abnormalities. CTF Flag: CYBERLABFLAG{97c96171e0509389}',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE
SET
    name = 'CTF Test Patient',
    age = 45,
    diagnosis = 'Routine Checkup',
    notes = 'Medical History: Patient reports normal health status. Previous visits show no abnormalities. CTF Flag: CYBERLABFLAG{97c96171e0509389}',
    updated_at = NOW();

-- ============================================================
-- Cleanup Instructions:
-- To remove this data after CTF event, run:
--   DELETE FROM patients WHERE id = 999;
-- ============================================================
```

### **Step 6: Add Hidden Admin Route**

Find the routes file. The location depends on the framework:

**For Flask (Python) - Usually `app.py` or `routes.py`:**

```python
# ============================================================
# CTF Challenge Route
# Challenge 2: Admin Dashboard (Directory Enumeration)
# CTFd Challenge ID: 4
# Points: 200
# Flag: CYBERLABFLAG{86f702cbb49e1f2a}
#
# Vulnerability: Security through obscurity / Directory enumeration
# Players should find this route via directory bruteforcing
# ============================================================

@app.route('/ctf_admin_panel_secret_2024')
def ctf_admin_panel():
    """
    Hidden admin panel for CTF challenge.
    This route is intentionally not linked anywhere in the application.
    Players must discover it through directory enumeration.

    Flag is hidden in HTML comment.
    Can be removed after CTF event.
    """
    return '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Admin Panel</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .panel {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="panel">
        <h1>Hospital Administrative Dashboard</h1>
        <p>Welcome to the hospital administration panel.</p>
        <p>This area is restricted to authorized personnel only.</p>
        <!-- CTF Flag: CYBERLABFLAG{86f702cbb49e1f2a} -->
    </div>
</body>
</html>'''
```

**For Express/Node.js - Usually `routes/index.js` or similar:**

```javascript
// ============================================================
// CTF Challenge Route
// Challenge 2: Admin Dashboard (Directory Enumeration)
// CTFd Challenge ID: 4
// Points: 200
// Flag: CYBERLABFLAG{86f702cbb49e1f2a}
// ============================================================

router.get('/ctf_admin_panel_secret_2024', (req, res) => {
    // Hidden admin panel for CTF challenge
    // Flag is in HTML comment
    res.send(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Admin Panel</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .panel {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="panel">
        <h1>Hospital Administrative Dashboard</h1>
        <p>Welcome to the hospital administration panel.</p>
        <p>This area is restricted to authorized personnel only.</p>
        <!-- CTF Flag: CYBERLABFLAG{86f702cbb49e1f2a} -->
    </div>
</body>
</html>`);
});
```

### **Step 7: Commit and Push**

```bash
git add .
git commit -m "Add CTF challenge data for Hospital system

- Add test patient record (ID 999) with flag in medical notes
- Add hidden admin route /ctf_admin_panel_secret_2024
- Both changes are isolated and reversible
- For educational CTF event

Closes #[ISSUE_NUMBER]"

git push origin issue-[NUMBER]-ctf-flag-planting-hospital-system
```

### **Step 8: Create Pull Request**

Go to GitHub and create a PR with this template:

```markdown
## Summary
Adding CTF challenge data to Hospital system for CyberLab CTF event.

## Changes
1. ✅ Added test patient record (Patient ID 999) with flag in medical notes
2. ✅ Added hidden admin route at `/ctf_admin_panel_secret_2024` with flag in HTML comment

## Files Modified
- `cluster/environments/hospital/db/seeds/ctf_data.sql` (new file)
- `cluster/environments/hospital/app.py` (or routes file)

## Testing
- [x] Database seed uses `ON CONFLICT` for safe re-runs
- [x] Route is hidden and not linked anywhere in the UI
- [x] No modifications to existing functionality
- [x] Both changes are isolated and reversible

## CTF Challenge Details

### Challenge 1: Patient Records (100 points)
- **Type:** IDOR (Insecure Direct Object Reference)
- **Flag Location:** Database - Patient ID 999, notes field
- **Skill:** Enumerate patient IDs to find hidden record

### Challenge 2: Admin Dashboard (200 points)
- **Type:** Directory Enumeration / Security through Obscurity
- **Flag Location:** Hidden route `/ctf_admin_panel_secret_2024`
- **Skill:** Directory bruteforcing to discover hidden endpoint

## Impact Assessment
- **Risk:** Low - isolated test data with no real PII
- **Reversibility:** High - cleanup script included in comments
- **Performance:** Negligible - 1 database record + 1 simple route
- **Security:** No impact - intentional vulnerabilities are isolated

## Cleanup Plan
After CTF event completion:
```sql
DELETE FROM patients WHERE id = 999;
```
Remove route from routes file.

## Timeline
Needed within 5 days for CTF event launch on [DATE].

## Related Issues
Closes #[ISSUE_NUMBER]

## Related CTFd Challenges
- CTFd Challenge ID 2: Hospital Example Challenge 1 (100 points)
- CTFd Challenge ID 4: Hospital Example Challenge 2 (200 points)

---

**Reviewers:** @[team-members]
**Labels:** enhancement, ctf, education
```

---

## 🐘 **PART 2: Mastodon Flag Planting (via GitHub PR)**

### **Step 1: Create GitHub Issue for Mastodon**

Create another issue in CyberLab repo:

```
Title: CTF Flag Planting - Mastodon Instance

Description:
## Purpose
Adding CTF challenge data to the Mastodon instance for CyberLab CTF event.

## Changes Needed
1. ✅ Create user account `@ctf_user_2024`
2. ✅ Add seed data for user profile and post with flags
3. ✅ Upload profile picture with EXIF metadata containing flag

## Implementation Details

### Challenge 1: Hidden Toot (Web Enumeration)
- **Flag:** `CYBERLABFLAG{88f692ff0662e5a3}`
- **Location:** HTML comment in user's pinned post
- **Method:** Database seed for post content

### Challenge 2: Profile Secrets (OSINT/Metadata Analysis)
- **Flag:** `CYBERLABFLAG{e86bd1a706c69f8e}`
- **Location:** Profile picture EXIF metadata
- **Method:** Upload image with embedded metadata

## User Details
- **Username:** `ctf_user_2024`
- **Display Name:** CTF User
- **Bio:** "Welcome to CyberLab Mastodon! 🚀"
- **Email:** ctf@cyberlab.local (or similar)

## Implementation Options

**Option A: Database Seed (Preferred)**
- Add user via database seed/migration
- Include post content with HTML comment
- Upload profile picture with EXIF data

**Option B: Manual Setup (If needed)**
- Create user via Mastodon admin interface
- Upload provided profile picture
- Create post with provided content

## Impact
- **Risk Level:** Low - single test user account
- **Reversibility:** High - can be deleted after CTF
- **Files Modified:**
  - Database seed file (e.g., `db/seeds/ctf_data.rb` or similar)
  - Profile picture upload (provided in PR)

## Timeline
Needed within 5 days for CTF event launch.

## Provided Assets
- Profile picture with embedded EXIF metadata (will be in PR)
- Post content with flag in HTML comment
- User creation script

## Related CTFd Challenges
- Challenge ID 5: Mastodon Hidden Toot (150 points)
- Challenge ID 6: Mastodon Profile Secrets (200 points)

---

**Label:** enhancement, ctf, education
**Assignees:** [tag Mastodon team members]
```

### **Step 2: Checkout Branch for Mastodon**

```bash
cd ~/cyberlab
git fetch origin
git checkout issue-[NUMBER]-ctf-flag-planting-mastodon-instance
```

### **Step 3: Navigate to Mastodon Directory**

```bash
cd cluster/environments/mastodon/
ls -la  # Explore the structure
```

### **Step 4: Generate Profile Picture with Flag**

From your CTF platform directory, generate the profile picture:

```bash
cd /home/devika/CTFd/ctf-automation/ctf_platform/ctf_platform/mastodon
./plant-flags-web.sh
```

This creates a profile picture at `.ctf_temp/ctf_profile_picture.jpg` with EXIF metadata containing the flag.

### **Step 5: Copy Profile Picture to Mastodon Directory**

```bash
# Copy the generated profile picture
cp .ctf_temp/ctf_profile_picture.jpg ~/cyberlab/cluster/environments/mastodon/public/system/accounts/avatars/ctf_user_profile.jpg
```

### **Step 6: Create Mastodon Database Seed**

Mastodon typically uses Ruby on Rails. Create or edit the seed file:

**File:** `db/seeds/ctf_data.rb` (or similar)

```ruby
# ============================================================
# CTF Challenge Data for CyberLab CTF Event
# Can be removed after event completion
# ============================================================

# Challenge 1 & 2: Mastodon User with Flags
# CTFd Challenge IDs: 5 (Hidden Toot), 6 (Profile Secrets)

# Create CTF user account
ctf_user = Account.create!(
  username: 'ctf_user_2024',
  display_name: 'CTF User',
  note: 'Welcome to CyberLab Mastodon! 🚀',
  avatar_file_name: 'ctf_user_profile.jpg',
  avatar_content_type: 'image/jpeg',
  avatar_updated_at: Time.now
)

# Create user credentials
User.create!(
  account: ctf_user,
  email: 'ctf@cyberlab.local',
  password: SecureRandom.hex(32),  # Random password, managed by admins
  confirmed_at: Time.now,
  approved: true
)

# Create post with flag in HTML comment
# Challenge 1: Hidden Toot (150 points)
# Flag: CYBERLABFLAG{88f692ff0662e5a3}
status = Status.create!(
  account: ctf_user,
  text: "Welcome to CyberLab Mastodon! #CTF #CyberLab\n\n<!-- CTF Flag: CYBERLABFLAG{88f692ff0662e5a3} -->",
  visibility: 'public',
  created_at: 7.days.ago
)

# Pin the status to profile
StatusPin.create!(
  account: ctf_user,
  status: status
)

puts "✓ CTF user @ctf_user_2024 created"
puts "✓ Post with flag created and pinned"
puts "✓ Profile picture with EXIF flag should be uploaded manually or via admin interface"

# ============================================================
# Cleanup Instructions:
# To remove this data after CTF event, run in Rails console:
#   ctf_user = Account.find_by(username: 'ctf_user_2024')
#   ctf_user.destroy if ctf_user
# ============================================================
```

**Note:** If the team prefers manual setup, provide this alternative in your PR:

### **Step 7: Create Manual Setup Instructions (Alternative)**

If database seeding isn't preferred, create a file:

**File:** `docs/ctf_setup_manual.md`

```markdown
# Manual CTF Setup for Mastodon

If automated seeding doesn't work, follow these manual steps:

## Step 1: Create User via Admin Interface

1. Log in to Mastodon admin panel
2. Go to: **Administration → Accounts → Create New Account**
3. Fill in:
   - **Username:** `ctf_user_2024`
   - **Email:** `ctf@cyberlab.local`
   - **Password:** [generate secure password]
   - **Confirmed:** Yes
   - **Approved:** Yes

## Step 2: Upload Profile Picture

1. Log in as `@ctf_user_2024`
2. Go to: **Edit Profile**
3. Upload profile picture: `public/system/accounts/avatars/ctf_user_profile.jpg`
4. This image contains the flag `CYBERLABFLAG{e86bd1a706c69f8e}` in EXIF metadata
5. Set bio to: "Welcome to CyberLab Mastodon! 🚀"

## Step 3: Create Post with Flag

1. Create a new public post with this exact content:

```html
Welcome to CyberLab Mastodon! #CTF #CyberLab

<!-- CTF Flag: CYBERLABFLAG{88f692ff0662e5a3} -->
```

2. Pin the post to profile

## Verification

Check that:
- [ ] User `@ctf_user_2024` is accessible at https://mastodon.cyberlab.local/@ctf_user_2024
- [ ] Profile picture loads correctly
- [ ] EXIF data contains flag: `exiftool ctf_user_profile.jpg | grep Comment`
- [ ] Post is pinned to profile
- [ ] Post HTML source contains flag in comment

## Cleanup

After CTF event, delete the user via admin interface.
```

### **Step 8: Commit and Push Mastodon Changes**

```bash
cd ~/cyberlab
git add .
git commit -m "Add CTF challenge data for Mastodon instance

- Add user @ctf_user_2024 with seed data
- Add profile picture with EXIF metadata flag
- Add post with flag in HTML comment
- Include both automated and manual setup options

Closes #[ISSUE_NUMBER]"

git push origin issue-[NUMBER]-ctf-flag-planting-mastodon-instance
```

### **Step 9: Create Mastodon Pull Request**

```markdown
## Summary
Adding CTF challenge data to Mastodon instance for CyberLab CTF event.

## Changes
1. ✅ Created user `@ctf_user_2024` with database seed
2. ✅ Added profile picture with EXIF metadata containing flag
3. ✅ Created post with flag in HTML comment
4. ✅ Included manual setup instructions as alternative

## Files Modified
- `cluster/environments/mastodon/db/seeds/ctf_data.rb` (new file)
- `cluster/environments/mastodon/public/system/accounts/avatars/ctf_user_profile.jpg` (new file)
- `cluster/environments/mastodon/docs/ctf_setup_manual.md` (new file)

## Implementation Options

### Option A: Automated (Preferred)
Run database seed:
```bash
cd cluster/environments/mastodon
rails db:seed:ctf_data
```

### Option B: Manual Setup
Follow instructions in `docs/ctf_setup_manual.md`

## CTF Challenge Details

### Challenge 1: Hidden Toot (150 points)
- **Type:** Web Enumeration / Source Code Analysis
- **Flag Location:** HTML comment in pinned post
- **Flag:** `CYBERLABFLAG{88f692ff0662e5a3}`
- **Skill:** View page source to find hidden comment

### Challenge 2: Profile Secrets (200 points)
- **Type:** OSINT / Metadata Analysis
- **Flag Location:** Profile picture EXIF metadata
- **Flag:** `CYBERLABFLAG{e86bd1a706c69f8e}`
- **Skill:** Extract and analyze image metadata using tools like `exiftool`

## Verification Steps
```bash
# Test 1: Check user exists
curl https://mastodon.cyberlab.local/@ctf_user_2024

# Test 2: Download and check profile picture EXIF
wget https://mastodon.cyberlab.local/[profile-pic-url]
exiftool profile_pic.jpg | grep -i comment
# Should show: CYBERLABFLAG{e86bd1a706c69f8e}

# Test 3: Check post HTML source for flag
# View source of user's profile page
# Should find: <!-- CTF Flag: CYBERLABFLAG{88f692ff0662e5a3} -->
```

## Impact Assessment
- **Risk:** Low - single test user with public posts
- **Reversibility:** High - user can be deleted after event
- **Performance:** Negligible - 1 user account + 1 post
- **Security:** No impact - flags are educational

## Cleanup Plan
After CTF event:
```ruby
# In Rails console
ctf_user = Account.find_by(username: 'ctf_user_2024')
ctf_user.destroy if ctf_user
```

## Timeline
Needed within 5 days for CTF event launch on [DATE].

## Related Issues
Closes #[ISSUE_NUMBER]

## Related CTFd Challenges
- CTFd Challenge ID 5: Mastodon Hidden Toot (150 points)
- CTFd Challenge ID 6: Mastodon Profile Secrets (200 points)

---

**Reviewers:** @[mastodon-team-members]
**Labels:** enhancement, ctf, education
```

---

## 📧 **PART 3: Alternative Approach - Request Manual Setup**

If the teams prefer not to accept PRs for this, you can request manual setup via GitHub issues:

### **Hospital Manual Setup Request**

```
Title: [Request] Manual CTF Flag Setup - Hospital System

Hi Hospital team! 👋

For our CyberLab CTF event, we need your help setting up 2 challenge flags in the Hospital system.
We can provide the exact code/SQL to run, or you can do it however works best for your workflow.

## What We Need

**Challenge 1: Database Record**
```sql
INSERT INTO patients (id, name, age, diagnosis, notes, created_at, updated_at)
VALUES (999, 'CTF Test Patient', 45, 'Routine Checkup',
        'Medical History: Patient reports normal health. CTF Flag: CYBERLABFLAG{97c96171e0509389}',
        NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET notes = 'Medical History: Patient reports normal health. CTF Flag: CYBERLABFLAG{97c96171e0509389}';
```

**Challenge 2: Hidden Route**
Add this route (adapt to your framework):
```python
@app.route('/ctf_admin_panel_secret_2024')
def ctf_admin_panel():
    return '''<html><body><h1>Hospital Admin Panel</h1>
    <!-- CTF Flag: CYBERLABFLAG{86f702cbb49e1f2a} --></body></html>'''
```

## Timeline
Within 5 days if possible.

## Can Be Removed After CTF
Both changes are isolated and can be easily cleaned up.

Let me know which approach works best for your team! Happy to discuss or provide more details.

Thanks!
```

### **Mastodon Manual Setup Request**

```
Title: [Request] Manual CTF User Setup - Mastodon Instance

Hi Mastodon team! 👋

For our CyberLab CTF event, we need your help creating a test user with some specific content.

## What We Need

**User Account:**
- Username: `@ctf_user_2024`
- Display Name: CTF User
- Bio: "Welcome to CyberLab Mastodon! 🚀"
- Email: ctf@cyberlab.local (or any test email)

**Profile Picture:**
I'll provide a profile picture file that has special EXIF metadata (flag embedded).

**Post Content:**
One public post with this exact HTML:
```html
Welcome to CyberLab Mastodon! #CTF #CyberLab

<!-- CTF Flag: CYBERLABFLAG{88f692ff0662e5a3} -->
```
(Please pin this post to the profile)

## How We Can Help

**Option A:** You create the user, I'll provide the profile pic and post content
**Option B:** I submit a PR with database seed (if you prefer that)
**Option C:** Give me temporary access to create the user myself

## Timeline
Within 5 days if possible.

## Can Be Removed After CTF
User can be deleted after the event.

Let me know what works best for your team!

Thanks!
```

---

## ✅ **Summary: Your Action Plan**

### **Today/Tomorrow:**
1. [ ] Create 2 GitHub issues (Hospital + Mastodon)
2. [ ] Clone CyberLab repository
3. [ ] Create branch for Hospital PR
4. [ ] Add Hospital database seed + route
5. [ ] Commit and create Hospital PR
6. [ ] Create branch for Mastodon PR
7. [ ] Generate Mastodon profile picture
8. [ ] Add Mastodon database seed + files
9. [ ] Commit and create Mastodon PR

### **Wait for Reviews:**
10. [ ] Respond to any PR feedback
11. [ ] Wait for PRs to be merged

### **After Merge:**
12. [ ] Test all flags are accessible
13. [ ] Verify challenges work end-to-end
14. [ ] Launch CTF! 🎉

---

## 📝 **Quick Checklist**

**Before creating PRs:**
- [ ] Have all 4 flag values saved
- [ ] Know CyberLab repo URL
- [ ] Know where Hospital code is (`cluster/environments/hospital/`)
- [ ] Know where Mastodon code is (`cluster/environments/mastodon/`)
- [ ] Generated Mastodon profile picture with EXIF flag

**Hospital PR must include:**
- [ ] Database seed with Patient ID 999
- [ ] Hidden route `/ctf_admin_panel_secret_2024`
- [ ] Clear comments explaining CTF purpose
- [ ] Cleanup instructions

**Mastodon PR must include:**
- [ ] User creation seed for `@ctf_user_2024`
- [ ] Profile picture with EXIF metadata
- [ ] Post with flag in HTML comment
- [ ] Manual setup alternative instructions

---

## 🎯 **Expected Timeline**

| Day | Task | Time |
|-----|------|------|
| **Today** | Create issues + Hospital PR | 1 hour |
| **Tomorrow** | Create Mastodon PR | 1 hour |
| **Day 3-5** | Wait for PR reviews/merges | - |
| **Day 6** | Test everything | 30 min |
| **Day 7** | Launch CTF! | 🎉 |

---

**You've got this! The CTFd part is done - now just need to get the flags planted via GitHub. Good luck!** 🚀
