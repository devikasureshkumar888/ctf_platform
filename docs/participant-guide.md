# CyberLab CTF - Participant Guide

Welcome to the CyberLab Capture The Flag (CTF) competition! This guide will help you get started.

## What is a CTF?

A **Capture The Flag (CTF)** is a cybersecurity competition where you solve challenges to find hidden "flags" - special text strings in the format `CYBERLABFLAG{text_here}`.

Each flag you find earns you points. The player or team with the most points wins!

---

## Getting Started

### 1. Register for the CTF

1. Go to the CTFd platform: `http://172.24.191.68:8000`
2. Click "Register"
3. Fill in:
   - Username
   - Email
   - Password
4. Verify your email (if required)
5. Log in

### 2. Understanding the Platform

**Dashboard:** Your personal stats and recent solves

**Challenges:** List of all challenges organized by category

**Scoreboard:** Current rankings and top players/teams

**Profile:** Your account settings and solve history

---

## How to Play

### Finding Challenges

1. Log in to CTFd
2. Click "Challenges" in the navigation
3. You'll see challenges grouped by chapter:
   - **Mastodon - Chapter 1** (2 challenges, 300 points)
   - **Hospital - Chapter 2** (2 challenges, 350 points)

### Challenge Information

Each challenge shows:
- **Name:** What the challenge is called
- **Category:** Which chapter/system it belongs to
- **Points:** How many points it's worth
- **Solves:** How many people have solved it
- **Description:** What you need to do

### Getting Hints

Some challenges have hints available:
- Click on a challenge
- Click "Hints" tab
- Some hints are free (0 points)
- Some cost points to unlock
- Use hints if you're stuck!

### Submitting Flags

1. Find the flag in the target system (format: `CYBERLABFLAG{...}`)
2. Copy the **entire flag** including `CYBERLABFLAG{` and `}`
3. Go to the challenge in CTFd
4. Paste the flag in the submission box
5. Click "Submit"
6. If correct, you'll earn points! 🎉
7. If incorrect, try again (no penalty for wrong submissions)

---

## The Challenges

### Chapter 1: Mastodon Social Network

**Target:** https://mastodon.cyberlab.local

Mastodon is a social networking platform. Your challenges involve finding hidden information in user profiles and posts.

**Challenge 1: The Hidden Toot** (100 points)
- Difficulty: Easy
- Type: OSINT / Information Disclosure
- Goal: Find a flag hidden in a user's post or profile

**Challenge 2: Profile Picture Secrets** (200 points)
- Difficulty: Medium
- Type: Steganography / Metadata Analysis
- Goal: Extract a flag from image metadata

### Chapter 2: Hospital Management System

**Target:** https://hospital.cyberlab.local

A hospital management system storing patient records. Your challenges involve finding vulnerabilities in the application.

**Challenge 1: Public Patient Records** (100 points)
- Difficulty: Easy
- Type: IDOR / Information Disclosure
- Goal: Access unauthorized patient records

**Challenge 2: Doctor's Dashboard Discovery** (250 points)
- Difficulty: Medium
- Type: Forced Browsing / Directory Enumeration
- Goal: Find a hidden admin panel

---

## Tools You Might Need

### Web Browser
- **Chrome/Firefox/Edge** - For viewing websites
- **Developer Tools (F12)** - For viewing page source, network requests

### Command Line Tools
```bash
# View website HTML
curl https://mastodon.cyberlab.local

# Download files
wget https://hospital.cyberlab.local/image.jpg

# View image metadata
exiftool image.jpg

# Search for text
grep "CYBERLABFLAG" file.txt
```

### Useful Browser Extensions
- **Wappalyzer** - Identify web technologies
- **Web Developer Tools** - Various web analysis tools

### Image Analysis Tools
- **exiftool** - Read image metadata
- **strings** - Extract text from files
- **steghide** - Extract hidden data from images

---

## Tips & Strategies

### General Tips

1. **Read the description carefully** - It often contains clues
2. **Start with easy challenges** - Build confidence and points
3. **Use free hints** - They're there to help you!
4. **View page source** - Right-click → "View Page Source" (Ctrl+U)
5. **Check for patterns** - Flags always follow `CYBERLABFLAG{text_here}` format
6. **Try different approaches** - If one method doesn't work, try another
7. **Google is your friend** - Look up techniques you don't know
8. **Take breaks** - Fresh eyes spot things you missed

### For Mastodon Challenges

- Investigate the user profile thoroughly
- Look at toots (posts), bio, profile fields
- View page source - secrets might be in HTML comments
- Download images and analyze them
- Check for unusual metadata or encoding

### For Hospital Challenges

- Try different URL patterns (`/patients/1`, `/patients/999`, etc.)
- Look for hidden admin panels (`/admin`, `/dashboard`, etc.)
- Check `robots.txt` and `sitemap.xml`
- View page source for hidden comments
- Try accessing records you shouldn't have access to

---

## Rules & Etiquette

### Allowed

✅ Using any tools or techniques to solve challenges
✅ Researching solutions online
✅ Taking breaks and coming back later
✅ Asking for hints (they cost points but help you learn)
✅ Collaborating with your team (if team-based)

### Not Allowed

❌ Sharing flags with other players/teams
❌ Attacking the CTFd platform itself
❌ Denial of Service (DoS) attacks
❌ Brute-forcing flags (trying random guesses)
❌ Attacking other participants
❌ Using multiple accounts

### Fair Play

- Solve challenges legitimately
- Don't spoil solutions for others
- Report any technical issues to organizers
- Help create a positive learning environment

---

## Scoring

### Points

Each challenge is worth a fixed number of points:
- Easy challenges: 100 points
- Medium challenges: 200-250 points

### Ranking

- Scoreboard ranks players by total points
- Ties broken by time of last solve (faster wins)
- First to solve a challenge gets "First Blood" recognition

### Winning

The player or team with the most points when the CTF ends wins!

---

## Getting Help

### If You're Stuck

1. **Re-read the challenge description** - Clues are often there
2. **Use hints** - Free hints cost 0 points
3. **Take a break** - Come back with fresh perspective
4. **Try a different challenge** - Come back to hard ones later
5. **Research the technique** - Google the vulnerability type

### Technical Issues

If something is broken:
- Check if target system is accessible
- Verify your internet connection
- Try a different browser
- Clear browser cache
- Contact CTF organizers

---

## Learning Resources

### After the CTF

Solution writeups will be shared for all challenges. Review them to learn:
- How to solve each challenge
- What vulnerability was exploited
- How to prevent these issues in real applications
- Tools and techniques used

### Want to Learn More?

**Practice Platforms:**
- PicoCTF - Beginner-friendly CTF
- HackTheBox - Realistic hacking scenarios
- TryHackMe - Guided cybersecurity learning
- OverTheWire - Wargames for learning

**Learning Resources:**
- OWASP Top 10 - Common web vulnerabilities
- PortSwigger Web Security Academy - Free web security training
- CTF Field Guide - CTF techniques and strategies

---

## FAQ

**Q: What format are the flags?**
A: `CYBERLABFLAG{text_here}` - always uppercase prefix, lowercase content with underscores

**Q: Is there a penalty for wrong submissions?**
A: No! Try as many times as you need.

**Q: Can I use automated tools?**
A: Yes, any tools are allowed for solving challenges.

**Q: How long do I have?**
A: Check the CTF start and end times on the platform.

**Q: Can I work with others?**
A: Only if it's a team-based CTF. Otherwise, solve individually.

**Q: What if I find a flag but it doesn't work?**
A: Double-check you copied the entire flag including `CYBERLABFLAG{` and `}`. Check for extra spaces.

**Q: Are there writeups available?**
A: Yes, after the CTF ends, solution writeups will be shared.

---

## Quick Start Checklist

- [ ] Register on CTFd platform
- [ ] Read this participant guide
- [ ] Review the flag format in [flag-format.md](flag-format.md)
- [ ] Browse available challenges
- [ ] Pick an easy challenge to start
- [ ] Read the challenge description carefully
- [ ] Visit the target system
- [ ] Try to find the flag
- [ ] Submit and earn points!
- [ ] Move on to the next challenge

---

## Good Luck! 🎉

Remember:
- **Have fun!**
- **Learn something new**
- **Don't give up** - even hard challenges are solvable
- **Ask for hints** if you're stuck
- **Enjoy the process** of solving puzzles

Happy hacking! 🚀
