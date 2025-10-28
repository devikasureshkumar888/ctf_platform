# Quick Command Reference

## Setup Commands

```bash
# Navigate to project
cd /home/devika/CTFd/ctf-automation/ctf_platform

# Load environment variables (ALWAYS RUN THIS FIRST)
source ./setup-env.sh

# Test CTFd connection
./tests/test-connection.sh
```

## Flag Generation (Preview Only - No Planting)

```bash
# Generate hospital flags (deterministic - same every time)
./hospital/test-local.sh

# Generate mastodon flags
./ctf_platform/mastodon/test-local.sh
```

**Generated Flags:**
- Hospital Patient: `CYBERLABFLAG{97c96171e0509389}`
- Hospital Admin: `CYBERLABFLAG{86f702cbb49e1f2a}`
- Mastodon Toot: `CYBERLABFLAG{88f692ff0662e5a3}`
- Mastodon Profile: `CYBERLABFLAG{e86bd1a706c69f8e}`

## Deploy to CTFd

```bash
# Make sure environment is loaded first!
source ./setup-env.sh

# Register hospital challenges (2 challenges)
./hospital/register-challenges.sh

# Register mastodon challenges (2 challenges)
./ctf_platform/mastodon/register-challenges.sh

# Verify at: http://172.24.191.68:8000/admin/challenges
```

## Plant Flags

### Mastodon (Web Interface)

```bash
# Create profile picture with flag
cd ./ctf_platform/mastodon
./plant-flags-web.sh

# Then manually:
# 1. Visit: https://mastodon.cyberlab.local
# 2. Register as: ctf_user_2024
# 3. Upload generated profile picture
# 4. Create post with flag in HTML comment
```

### Hospital (GitHub PR)

```bash
# 1. Clone CyberLab repo
cd ~
git clone [CYBERLAB_REPO_URL]
cd [repo-name]

# 2. Create GitHub issue (do this via web)
# 3. Checkout auto-created branch
git fetch origin
git checkout issue-[NUMBER]-ctf-flag-planting

# 4. Navigate to hospital
cd cluster/environments/hospital/

# 5. Add database record and route (see QUICKSTART.md)
# 6. Commit and push
git add .
git commit -m "Add CTF challenge data"
git push origin issue-[NUMBER]-ctf-flag-planting

# 7. Create PR via GitHub web interface
```

## Verification

```bash
# Test hospital admin route
curl https://hospital.cyberlab.local/ctf_admin_panel_secret_2024

# Visit mastodon profile
open https://mastodon.cyberlab.local/@ctf_user_2024

# Check profile picture EXIF
exiftool profile_pic.jpg | grep -i comment

# Run end-to-end test
source ./setup-env.sh
./tests/test-end-to-end.sh
```

## Troubleshooting

```bash
# Check CTFd accessibility
curl -I http://172.24.191.68:8000

# Check if CTFd is running
docker ps | grep ctfd

# Make scripts executable
find . -name "*.sh" -type f -exec chmod +x {} \;

# Check environment variables
echo $CTFD_URL
echo $CTFD_TOKEN
```

## File Locations

- Environment config: `./ctf_platform/.env`
- Setup helper: `./setup-env.sh`
- Hospital scripts: `./hospital/`
- Mastodon scripts: `./ctf_platform/mastodon/`
- Test scripts: `./tests/`

## URLs

- **CTFd Admin:** http://172.24.191.68:8000/admin/challenges
- **Mastodon:** https://mastodon.cyberlab.local
- **Hospital:** https://hospital.cyberlab.local

## One-Line Quick Tests

```bash
# Full connection test
cd /home/devika/CTFd/ctf-automation/ctf_platform && source ./setup-env.sh && ./tests/test-connection.sh

# View all flags
cd /home/devika/CTFd/ctf-automation/ctf_platform && ./hospital/test-local.sh && ./ctf_platform/mastodon/test-local.sh

# Deploy all challenges (when CTFd is accessible)
cd /home/devika/CTFd/ctf-automation/ctf_platform && source ./setup-env.sh && ./hospital/register-challenges.sh && ./ctf_platform/mastodon/register-challenges.sh
```

---

**Pro Tip:** Always run `source ./setup-env.sh` before running any other scripts!
