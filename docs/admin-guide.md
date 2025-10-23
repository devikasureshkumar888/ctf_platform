# CTFd Administration Guide

This guide covers day-to-day administration of your CyberLab CTF platform.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [User Management](#user-management)
3. [Challenge Management](#challenge-management)
4. [Monitoring & Scoring](#monitoring--scoring)
5. [Maintenance](#maintenance)
6. [Troubleshooting](#troubleshooting)

---

## Initial Setup

### Prerequisites

- CTFd installed and running at `172.24.191.68:8000`
- Admin account created
- API token generated

### Getting Your API Token

1. Log in to CTFd admin panel: `http://172.24.191.68:8000/admin`
2. Go to **Settings** → **Access Tokens**
3. Click **Create Token**
4. Give it a name: "CTF Platform Management"
5. Copy the token and save it securely
6. Add to your environment:
   ```bash
   export CTFD_TOKEN="your_token_here"
   export CTFD_URL="http://172.24.191.68:8000"
   ```

### First-Time Configuration

1. **Set CTF Name and Description**
   - Go to Admin → Config → General
   - CTF Name: "CyberLab CTF 2025"
   - Description: Add welcome message

2. **Configure User Registration**
   - Admin → Config → Accounts
   - Enable/disable registration as needed
   - Set email verification requirements

3. **Set CTF Time Window**
   - Admin → Config → Time
   - Start Time: When CTF begins
   - End Time: When CTF ends
   - Freeze Time: When scoreboard freezes (optional)

4. **Configure Scoring**
   - Admin → Config → Scoring
   - Choose: Standard (static points) or Dynamic
   - For this CTF: Standard recommended

---

## User Management

### Viewing Users

- Admin → Users
- Shows all registered users
- Can filter by team, score, etc.

### Creating Users Manually

If registration is disabled:

1. Admin → Users → Create
2. Fill in:
   - Username
   - Email
   - Password
   - Team (optional)
3. Click Create

### Resetting Passwords

1. Admin → Users
2. Find user
3. Click username
4. Click "Reset Password"
5. Send new password to user

### Managing Teams

If running team-based CTF:

1. Admin → Teams
2. Create Team:
   - Team name
   - Captain (user)
3. Add members to teams:
   - Edit user → Assign to team

### Banning Users

If needed:

1. Admin → Users
2. Find user
3. Click "Ban User"
4. User cannot log in or submit

---

## Challenge Management

### Viewing Challenges

- Admin → Challenges
- Lists all challenges with:
  - Name, Category, Points
  - Solve count
  - Visibility status

### Adding Challenges Manually

Through Web Interface:

1. Admin → Challenges → Create
2. Fill in:
   - Name
   - Category
   - Description (supports Markdown)
   - Value (points)
   - Type: Standard
3. Add Flags:
   - Click on challenge → Flags → New Flag
   - Type: Static
   - Content: `CYBERLABFLAG{...}`
4. Add Hints (optional):
   - Click on challenge → Hints → New Hint
   - Cost: Points required to unlock
   - Content: Hint text

### Adding Challenges via Scripts

Recommended method:

```bash
# Test flags generation
cd mastodon && ./test-local.sh
cd hospital && ./test-local.sh

# Plant flags (follow manual guides)
cd mastodon && ./plant-flags-web.sh
sudo cd hospital && ./plant-flags.sh

# Register all challenges in CTFd
./scripts/deploy-all-challenges.sh
```

### Editing Challenges

1. Admin → Challenges
2. Click challenge name
3. Edit any field
4. Save changes

### Hiding/Showing Challenges

- Admin → Challenges
- Click challenge
- Toggle "Visible" / "Hidden"

### Deleting Challenges

⚠️ **Warning:** This cannot be undone!

1. Admin → Challenges
2. Click challenge
3. Scroll down → Delete Challenge

---

## Monitoring & Scoring

### Real-Time Scoreboard

- View at: `/scoreboard`
- Shows current standings
- Updates in real-time

### Challenge Solve Statistics

Admin → Statistics:
- Solve rates per challenge
- First blood (first solver)
- Average solve times
- Difficulty analysis

### Viewing Submissions

1. Admin → Submissions
2. See all flag attempts:
   - User, Challenge, Flag, Time
   - Correct/Incorrect
3. Filter by:
   - User
   - Challenge
   - Correct/Incorrect

### Exporting Data

1. Admin → Config → Export
2. Download:
   - All challenges
   - All users
   - All submissions
3. Format: JSON

---

## Maintenance

### Creating Backups

Automated backup:

```bash
./scripts/backup-ctfd.sh
```

This backs up:
- All challenges
- All users and teams
- All submissions
- Flags and hints
- Configuration files

Backups stored in: `backups/`

### Restoring from Backup

1. Extract backup:
   ```bash
   tar -xzf backups/ctfd_backup_YYYYMMDD_HHMMSS.tar.gz
   ```

2. Use CTFd import feature:
   - Admin → Config → Import
   - Upload challenges.json
   - Upload users.json

3. Or re-register challenges:
   ```bash
   ./scripts/deploy-all-challenges.sh
   ```

### Monitoring System Health

```bash
# Test CTFd connectivity
./tests/test-connection.sh

# Verify challenges accessible
./scripts/verify-challenges.sh
```

### Clearing/Resetting CTF

⚠️ **Warning:** This deletes all user data and submissions!

To start fresh:

1. Admin → Config → Reset
2. Choose what to reset:
   - Keep challenges, delete submissions
   - Keep users, delete submissions
   - Reset everything
3. Confirm reset

---

## Troubleshooting

### Challenge Not Appearing

**Symptom:** Challenge registered but not visible

**Solutions:**
1. Check if challenge is marked "Hidden"
   - Admin → Challenges → Set to "Visible"

2. Check if CTF has started
   - Admin → Config → Time
   - Ensure current time is after start time

3. Re-register challenge:
   ```bash
   cd hospital && ./register-challenges.sh
   ```

### Flag Not Working

**Symptom:** Users submit correct flag but marked incorrect

**Solutions:**
1. Verify flag exactly matches:
   - Admin → Challenges → Click challenge → Flags
   - Check for extra spaces, wrong capitalization

2. Check flag type:
   - Must be "static" for current setup
   - Content must match exactly

3. Verify flag was planted correctly:
   ```bash
   # Check generated flags
   cat mastodon/.generated-flags.txt
   cat hospital/.generated-flags.txt
   ```

### Users Can't Register

**Symptom:** Registration page shows error

**Solutions:**
1. Check if registration is enabled:
   - Admin → Config → Accounts
   - Enable "Registration Visibility"

2. Check email verification:
   - If email required, ensure SMTP configured
   - Or disable email verification

3. Check for IP bans:
   - Admin → Config → Security
   - Remove any blocks

### Can't Connect to CTFd API

**Symptom:** Scripts fail with connection errors

**Solutions:**
1. Verify CTFd is running:
   ```bash
   curl http://172.24.191.68:8000
   ```

2. Check API token:
   ```bash
   echo $CTFD_TOKEN
   # Should show your token
   ```

3. Test API directly:
   ```bash
   curl -H "Authorization: Token $CTFD_TOKEN" \
        http://172.24.191.68:8000/api/v1/challenges
   ```

4. Verify you're on same network:
   - CTFd at 172.24.191.68 is local network
   - Must be on same network to access

### Challenge Flags Not Accessible

**Symptom:** Users can't find flags in target systems

**Solutions:**
1. Verify flags were planted:
   ```bash
   ./scripts/verify-challenges.sh
   ```

2. Check target systems are running:
   ```bash
   curl https://mastodon.cyberlab.local
   curl https://hospital.cyberlab.local
   ```

3. Manually test each challenge:
   - Follow solution writeups
   - Verify flags are findable

---

## Daily Operations Checklist

### Before CTF Starts

- [ ] All challenges registered in CTFd
- [ ] All flags planted and verified
- [ ] Test user account created and tested
- [ ] Scoreboard accessible
- [ ] Backup created
- [ ] Start/end times configured
- [ ] User registration tested

### During CTF

- [ ] Monitor scoreboard for anomalies
- [ ] Watch submissions for patterns
- [ ] Respond to user questions (if support channel exists)
- [ ] Check system health periodically
- [ ] Monitor for cheating/flag sharing

### After CTF

- [ ] Freeze scoreboard
- [ ] Export final results
- [ ] Create final backup
- [ ] Announce winners
- [ ] Share solution writeups
- [ ] Gather feedback from participants

---

## Useful Commands

```bash
# Quick status check
./tests/test-connection.sh

# Deploy all challenges
./scripts/deploy-all-challenges.sh

# Verify challenges accessible
./scripts/verify-challenges.sh

# Create backup
./scripts/backup-ctfd.sh

# List all challenges
source scripts/ctfd-client.sh
list_challenges

# Test flag generation
cd mastodon && ./test-local.sh
cd hospital && ./test-local.sh
```

---

## Support & Resources

- **CTFd Documentation:** https://docs.ctfd.io/
- **Project README:** [../README.md](../README.md)
- **Troubleshooting Guide:** [troubleshooting.md](troubleshooting.md)
- **Challenge Solutions:** `hospital/solutions/` and `mastodon/solutions/`

---

## Security Best Practices

1. **Protect Your API Token**
   - Never commit to git
   - Store in `.env` file (gitignored)
   - Rotate periodically

2. **Monitor for Cheating**
   - Watch for identical submission times
   - Check for flag sharing patterns
   - Review suspicious solve speeds

3. **Backup Regularly**
   - Before CTF starts
   - During CTF (if long-running)
   - After CTF ends

4. **Secure Flags**
   - Don't share `.generated-flags.txt` files
   - Keep backups secure
   - Use dynamic flags for reusable challenges

---

**Need Help?** Check [troubleshooting.md](troubleshooting.md) or review solution writeups in challenge directories.
