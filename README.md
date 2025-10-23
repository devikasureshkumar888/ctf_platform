# CyberLab CTF Platform

A comprehensive Capture The Flag (CTF) platform for CyberLab using CTFd, featuring challenges across multiple project environments (Mastodon and Hospital systems).

## Overview

This repository contains everything needed to run a CTF event for CyberLab:
- **2 Chapters** (Mastodon & Hospital)
- **4 Challenges** (650 total points)
- **Automated deployment scripts**
- **Complete documentation**
- **Solution writeups**

### Chapters

| Chapter | System | Challenges | Points | Difficulty |
|---------|--------|------------|--------|-----------|
| 1 | Mastodon Social Network | 2 | 300 | Easy-Medium |
| 2 | Hospital Management | 2 | 350 | Easy-Medium |
| **Total** | | **4** | **650** | |

## Quick Start

### Prerequisites

- CTFd running at `172.24.191.68:8000`
- CTFd admin access and API token
- Access to Mastodon and Hospital systems (for flag planting)
- Tools: `curl`, `jq`, `bash`

### 5-Minute Setup

```bash
# 1. Clone this repository (already done)
cd ctf_platform

# 2. Configure environment
cp .env.example .env
nano .env  # Add your CTFD_TOKEN

# 3. Load environment
export $(cat .env | xargs)

# 4. Generate flags (test mode - doesn't plant)
cd mastodon && ./test-local.sh
cd ../hospital && ./test-local.sh

# 5. Plant flags (follow manual guides in each directory)
# See: mastodon/flag-planting-manual.md
# See: hospital/flag-planting-manual.md

# 6. Deploy all challenges to CTFd
cd ..
./scripts/deploy-all-challenges.sh

# 7. Verify everything works
./scripts/verify-challenges.sh
```

Done! Your CTF is ready! 🎉

## Project Structure

```
ctf_platform/
├── README.md                        # This file
├── .env.example                     # Environment variables template
│
├── docs/                            # Documentation
│   ├── flag-format.md              # Flag format specification
│   ├── admin-guide.md              # CTFd administration guide
│   └── participant-guide.md        # Guide for CTF players
│
├── scripts/                         # Shared automation scripts
│   ├── ctfd-client.sh              # CTFd API wrapper
│   ├── flag-generator.sh           # Flag generation utilities
│   ├── deploy-all-challenges.sh    # Deploy all chapters
│   ├── verify-challenges.sh        # Verify challenges work
│   └── backup-ctfd.sh              # Backup CTFd data
│
├── mastodon/                        # Chapter 1: Mastodon
│   ├── challenges.yml              # Challenge definitions
│   ├── register-challenges.sh      # Register in CTFd
│   ├── plant-flags-web.sh          # Web-based flag planting
│   ├── flag-planting-manual.md     # Manual planting instructions
│   └── solutions/                  # Solution writeups
│
├── hospital/                        # Chapter 2: Hospital
│   ├── challenges.yml              # Challenge definitions
│   ├── register-challenges.sh      # Register in CTFd
│   ├── plant-flags.sh              # Server-based flag planting
│   ├── flag-planting-manual.md     # Manual planting instructions
│   └── solutions/                  # Solution writeups
│
└── tests/                           # Test scripts
```

## Challenges

### Chapter 1: Mastodon (300 points)

**The Hidden Toot** (100 points)
Type: OSINT / Information Disclosure
Goal: Find flag in HTML source of user profile

**Profile Picture Secrets** (200 points)
Type: Steganography / Metadata Analysis
Goal: Extract flag from image EXIF data

### Chapter 2: Hospital (350 points)

**Public Patient Records** (100 points)
Type: IDOR / Information Disclosure
Goal: Access unauthorized patient record

**Doctor's Dashboard Discovery** (250 points)
Type: Forced Browsing / Directory Enumeration
Goal: Find hidden admin panel

## Flag Format

All flags follow this format:
```
CYBERLABFLAG{lowercase_text_with_underscores}
```

See [docs/flag-format.md](docs/flag-format.md) for full specification.

## Documentation

- [Admin Guide](docs/admin-guide.md) - CTFd administration
- [Participant Guide](docs/participant-guide.md) - How to play
- [Mastodon Flag Planting](mastodon/flag-planting-manual.md)
- [Hospital Flag Planting](hospital/flag-planting-manual.md)
- Solution writeups in `*/solutions/` directories

## Common Tasks

### Deploy All Challenges
```bash
./scripts/deploy-all-challenges.sh
```

### Verify Challenges
```bash
./scripts/verify-challenges.sh
```

### Backup CTFd
```bash
./scripts/backup-ctfd.sh
```

### Test Flag Generation
```bash
cd mastodon && ./test-local.sh
cd hospital && ./test-local.sh
```

## Timeline (10-Day Plan)

| Day | Task |
|-----|------|
| 1-2 | Request permissions from project teams |
| 3-4 | Generate flags and prepare documentation |
| 5-6 | Plant flags (manual or via PR) |
| 7 | Verify all flags accessible |
| 8 | Register challenges in CTFd |
| 9 | Test with dummy accounts |
| 10 | Final verification, go live |

## Security Notes

⚠️ **DO NOT COMMIT:**
- `.env` file (contains API token)
- `.generated-flags.txt` files (contains actual flags)
- `backups/` directory (contains sensitive data)

These are already in `.gitignore`.

## Support

- Documentation: `docs/` directory
- Solutions: `*/solutions/` (share after CTF)
- Troubleshooting: See admin-guide.md

---

**Ready to run your CTF?** Start with [Quick Start](#quick-start) above! 🚀
