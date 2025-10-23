# Solution: Profile Picture Secrets

**Challenge:** Mastodon - Chapter 1, Challenge 2
**Difficulty:** Medium
**Points:** 200
**Type:** Steganography / Metadata Analysis / OSINT

---

## Challenge Description

User @ctf_user_2024 has an interesting profile picture. Rumor has it they're not very good at hiding secrets in images. Digital images can contain more information than meets the eye!

**Target:** https://mastodon.cyberlab.local/@ctf_user_2024

**Mission:**
1. Download the user's profile picture
2. Analyze the image file for hidden data
3. Extract the flag

---

## Learning Objectives

After completing this challenge, you will understand:

- **EXIF metadata** in images
- How metadata can leak sensitive information
- **Steganography** basics
- Image forensics techniques
- Tools for analyzing image files
- Privacy implications of image metadata

---

## Solution Walkthrough

### Step 1: Download the Profile Picture

**Method 1: Browser (Easy)**

1. Go to https://mastodon.cyberlab.local/@ctf_user_2024
2. Right-click on the profile picture
3. Select "Save Image As..." or "Open Image in New Tab"
4. Save as `profile.jpg` (or whatever extension it is)

**Method 2: Using wget**

```bash
# Find the image URL first (inspect element or view page source)
# It might look like:
wget https://mastodon.cyberlab.local/system/accounts/avatars/000/000/001/original/profile.jpg

# Or simpler:
wget -O profile.jpg https://mastodon.cyberlab.local/@ctf_user_2024/avatar
```

**Method 3: Using curl**

```bash
curl -o profile.jpg https://mastodon.cyberlab.local/@ctf_user_2024/avatar.jpg
```

**Method 4: Developer Tools**

1. Open Browser DevTools (F12)
2. Go to Network tab
3. Filter by "Images"
4. Reload the profile page
5. Find the avatar image request
6. Right-click → "Open in new tab" → Save

### Step 2: Analyze the Image Metadata

Once you have the image file, analyze it for hidden data.

**Using exiftool (Recommended):**

```bash
# Install exiftool if needed
sudo apt install exiftool

# View all metadata
exiftool profile.jpg

# Search for specific fields
exiftool profile.jpg | grep -i "comment"
exiftool profile.jpg | grep -i "flag"
exiftool profile.jpg | grep -i "cyberlab"
```

**Expected output:**
```
ExifTool Version Number         : 12.16
File Name                       : profile.jpg
File Size                       : 125 kB
File Type                       : JPEG
...
Comment                         : CYBERLABFLAG{metadata_hunter_2024}
Artist                          : CTF User 2024
Copyright                       : CyberLab CTF
Description                     : Profile picture for CTF challenge
```

**The flag is in the Comment field!**

### Step 3: Alternative Analysis Tools

**Using identify (ImageMagick):**

```bash
# Install ImageMagick
sudo apt install imagemagick

# View metadata
identify -verbose profile.jpg | grep -i "comment"
```

**Using exiv2:**

```bash
# Install exiv2
sudo apt install exiv2

# View metadata
exiv2 profile.jpg
```

**Using jhead (JPEG only):**

```bash
# Install jhead
sudo apt install jhead

# View metadata
jhead profile.jpg
```

**Using strings (Quick and dirty):**

```bash
# Sometimes flags are visible in raw bytes
strings profile.jpg | grep "CYBERLABFLAG"
```

### Step 4: If EXIF Data Was Stripped

If Mastodon stripped the EXIF data, the challenge might use steganography instead:

**Using steghide:**

```bash
# Install steghide
sudo apt install steghide

# Extract hidden data (password might be in hints)
steghide extract -sf profile.jpg

# Try common passwords:
steghide extract -sf profile.jpg -p ""          # Empty password
steghide extract -sf profile.jpg -p "ctf2024"
steghide extract -sf profile.jpg -p "cyberlab"
steghide extract -sf profile.jpg -p "password"

# If successful, it extracts a file (flag.txt)
cat flag.txt
```

**Using zsteg (PNG files):**

```bash
# Install zsteg
gem install zsteg

# Analyze PNG
zsteg profile.png
```

**Using binwalk:**

```bash
# Install binwalk
sudo apt install binwalk

# Search for hidden files
binwalk profile.jpg

# Extract embedded files
binwalk -e profile.jpg
cd _profile.jpg.extracted
ls
```

### Step 5: Check Image Alt-Text

Sometimes flags are in the image's HTML alt attribute:

**View Page Source:**
```html
<img src="/avatar.jpg" alt="Profile picture - CYBERLABFLAG{...}" />
```

**Or in title attribute:**
```html
<img src="/avatar.jpg" title="CYBERLABFLAG{...}" />
```

### Step 6: Submit the Flag

1. Copy the flag: `CYBERLABFLAG{metadata_hunter_2024}`
2. Submit to CTFd
3. Earn 200 points! 🎉

---

## Complete Analysis Script

```bash
#!/bin/bash
# Complete image analysis script

IMAGE="profile.jpg"

echo "[*] Downloading profile picture..."
wget -O $IMAGE https://mastodon.cyberlab.local/@ctf_user_2024/avatar.jpg

echo ""
echo "[*] Analyzing EXIF metadata..."
exiftool $IMAGE

echo ""
echo "[*] Searching for flags in metadata..."
exiftool $IMAGE | grep -i "flag\|cyberlab\|ctf"

echo ""
echo "[*] Searching for flags in raw bytes..."
strings $IMAGE | grep "CYBERLABFLAG"

echo ""
echo "[*] Trying steganography extraction..."
steghide extract -sf $IMAGE -p ""
if [ -f "flag.txt" ]; then
    echo "[+] Hidden file extracted!"
    cat flag.txt
fi

echo ""
echo "[*] Checking for embedded files..."
binwalk $IMAGE

echo ""
echo "[*] Analysis complete!"
```

---

## Tools Used

### Primary Tools:
- **exiftool** - Read/write metadata (most versatile)
- **steghide** - Steganography extraction
- **binwalk** - Find embedded files

### Alternative Tools:
- **identify** (ImageMagick) - Image analysis
- **jhead** - JPEG header viewer
- **exiv2** - Metadata editor
- **strings** - Extract text from binary
- **zsteg** - PNG steganography
- **stegsolve** - Visual steganography analysis

---

## Hints Explanation

**Hint 1** (0 points): "Images can contain metadata..."
- Introduces concept of metadata

**Hint 2** (50 points): "Try using 'exiftool' command..."
- Tells you the exact tool to use

**Hint 3** (75 points): "Look for the 'Comment' field..."
- Tells you which metadata field contains the flag

---

## Key Takeaways

### What is EXIF Metadata?

**EXIF (Exchangeable Image File Format)** contains:
- **Camera info:** Make, model, settings
- **Date/Time:** When photo was taken
- **Location:** GPS coordinates (if enabled)
- **Author:** Photographer name
- **Copyright:** Copyright information
- **Custom fields:** Comments, descriptions, etc.

**Example EXIF data:**
```
Camera Make: Apple
Camera Model: iPhone 13 Pro
Date Taken: 2024:10:23 14:30:00
GPS Latitude: 37.7749° N
GPS Longitude: 122.4194° W
Comment: "My secret vacation spot"
```

### Privacy Implications

**Real-world privacy risks:**

1. **Location Tracking**
   - Photos reveal where you live/work
   - Stalking and doxxing risks
   - Military personnel posting photos with GPS data

2. **Identity Disclosure**
   - Camera serial numbers can identify photographer
   - Copyright fields contain real names
   - Timestamps reveal patterns of life

3. **Famous Examples:**
   - **John McAfee (2012):** Location revealed via photo EXIF data
   - **Anonymous hacktivists:** Identified via camera metadata
   - **Military operations:** Locations leaked through soldier photos

### How Social Media Handles Metadata

**Most platforms strip EXIF data:**
- Facebook: Removes GPS and camera info
- Twitter: Removes most EXIF data
- Instagram: Strips metadata
- WhatsApp: Removes location data

**But not always:**
- Some platforms preserve certain fields
- Downloaded images may retain metadata
- Direct image links might keep EXIF

---

## Remediation

### For Users: Removing Metadata Before Sharing

**Using exiftool:**
```bash
# Remove ALL metadata
exiftool -all= image.jpg

# Remove specific fields
exiftool -GPS*= image.jpg
exiftool -Location*= image.jpg

# Batch process all images in folder
exiftool -all= *.jpg
```

**Using GIMP:**
1. Open image in GIMP
2. File → Export As
3. Uncheck "Save EXIF data"

**Using ImageMagick:**
```bash
convert original.jpg -strip cleaned.jpg
```

**Using Online Tools:**
- https://www.verexif.com/
- https://www.jimpl.com/

### For Developers: Sanitizing Uploaded Images

**Python example:**
```python
from PIL import Image

def strip_exif(image_path, output_path):
    image = Image.open(image_path)

    # Remove EXIF data
    data = list(image.getdata())
    image_without_exif = Image.new(image.mode, image.size)
    image_without_exif.putdata(data)

    image_without_exif.save(output_path)

# Usage
strip_exif('uploaded.jpg', 'cleaned.jpg')
```

**Using ImageMagick in web app:**
```bash
# On file upload, strip metadata
convert uploaded.jpg -strip uploads/safe_image.jpg
```

---

## Further Reading

- [EXIF Data - Wikipedia](https://en.wikipedia.org/wiki/Exif)
- [OWASP - Information Leakage](https://owasp.org/www-community/vulnerabilities/Information_exposure_through_an_error_message)
- [EFF - Metadata and Privacy](https://www.eff.org/issues/metadata)
- [Steganography Tools List](https://0xrick.github.io/lists/stego/)

---

## Practice More

### Similar Challenges to Try:

**CTF Platforms:**
- PicoCTF: Image-based steganography challenges
- HackTheBox: OSINT and forensics challenges
- TryHackMe: Digital forensics room

**Tools to Learn:**
- **Stegsolve** - Visual steganography analysis
- **StegCracker** - Brute-force steghide passwords
- **Foremost** - File carving from images
- **Volatility** - Memory forensics (advanced)

### Additional Techniques:

**1. LSB (Least Significant Bit) Steganography:**
```bash
# Using zsteg for PNG
zsteg -a image.png
```

**2. Color Channel Analysis:**
- Use Stegsolve to view individual color channels
- Sometimes data hidden in specific channels

**3. Spectral Analysis:**
- Audio spectrograms can hide images
- Images can have spectral patterns

**4. File Signature Analysis:**
```bash
# Check file type
file image.jpg

# Sometimes files are disguised
# A "JPG" might actually be a ZIP with hidden files
unzip image.jpg
```

---

## Real-World Applications

### When Metadata Analysis is Useful:

1. **Digital Forensics**
   - Crime scene photo analysis
   - Timestamp verification
   - Camera identification

2. **OSINT Investigations**
   - Geolocation from photos
   - Timeline construction
   - Identity verification

3. **Copyright Protection**
   - Proving ownership
   - Tracking image usage
   - Watermark verification

4. **Security Auditing**
   - Finding information leaks
   - Testing file upload sanitization
   - Discovering hidden data channels

---

**Congratulations on solving this challenge!** 🎉

You've learned about EXIF metadata and how images can contain much more information than what's visible. This is an important privacy and security consideration!

**Key Lesson:** Always strip metadata from images before sharing them online, especially if they contain sensitive location or personal information.

**Bonus Tip:** Many mobile apps have settings to disable GPS tagging in photos. Consider enabling this for privacy!
