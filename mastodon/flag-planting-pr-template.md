# Pull Request: CTF Flag Planting - Mastodon Instance

## Summary

This PR adds CTF (Capture The Flag) challenge features to the Mastodon instance for the CyberLab CTF event.

**Note:** Most Mastodon challenges can be completed via web interface without code changes. This PR is only needed if web-based planting isn't possible.

**⚠️ This is for educational/training purposes only.**

## Changes

### Option A: HTML Comment in Profile (Preferred - No Code Change)

**Challenge 1** can be completed through Mastodon's web interface:
1. Create user: `@ctf_user_2024`
2. Add flag to bio or post
3. Upload profile picture with metadata

**No code changes needed!** See [flag-planting-manual.md](flag-planting-manual.md) for instructions.

### Option B: Code Changes (If Web Method Fails)

Only needed if Mastodon strips HTML/metadata.

#### Challenge 1: Hidden Toot

**File:** User profile template
**Purpose:** Add HTML comment with flag to specific user's profile

**Template Changes:**
```erb
<!-- File: app/views/accounts/show.html.haml -->

<!-- For user @ctf_user_2024 only -->
<% if @account.username == 'ctf_user_2024' %>
  <!-- CTF Flag: CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG} -->
<% end %>
```

**Impact:** Adds HTML comment to one user's profile page

#### Challenge 2: Profile Picture Metadata

**Configuration:**
**Purpose:** Preserve EXIF metadata in uploaded images

**File:** `config/initializers/paperclip.rb` or image processing config

```ruby
# Disable EXIF stripping for CTF user's images
# (Or just manually upload image with metadata via admin)
```

**Alternative:** Upload image with metadata via admin panel instead of code changes.

## Flags to Plant

**🔐 IMPORTANT:** Replace placeholders with actual generated flags:

1. **Challenge 1 Flag:** `CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}`
2. **Challenge 2 Flag:** `CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}`

To generate actual flags:
```bash
cd mastodon
./test-local.sh
# Copy the generated flags from output
```

## Preferred Approach: Web Interface

**Instead of this PR, try web-based planting first:**

1. Create user `@ctf_user_2024` via Mastodon registration
2. Add flag to profile bio or metadata fields
3. Create image with embedded EXIF data:
   ```bash
   exiftool -Comment="CYBERLABFLAG{flag_here}" profile.jpg
   ```
4. Upload as profile picture

See [flag-planting-manual.md](flag-planting-manual.md) for complete instructions.

**Only use this PR if the above doesn't work!**

## Testing

### Challenge 1 Testing:
```bash
# Should show flag in page source
curl https://mastodon.cyberlab.local/@ctf_user_2024 | grep "CTF Flag"
```

### Challenge 2 Testing:
```bash
# Download and check metadata
wget https://mastodon.cyberlab.local/@ctf_user_2024/avatar.jpg
exiftool avatar.jpg | grep Comment
```

## Rollback Plan

After CTF event:
- Remove HTML comment from template
- Delete `@ctf_user_2024` account
- Or keep for future CTF events

## Security Considerations

**This is for educational purposes:**
- Flags hidden in HTML source (teaches viewing page source)
- Metadata in images (teaches privacy implications)

**Not a security risk** as information is intentionally public for CTF.

## Timeline

- **Need by:** [DATE - 5 days before CTF]
- **CTF Event:** [DATE]
- **Can be removed after:** [DATE + 1 week]

## Questions?

Contact CyberLab CTF team:
- Email: [your-email]
- Slack: [your-slack]

---

## Checklist

- [ ] Attempted web-based planting first
- [ ] Only using PR if web method failed
- [ ] Flags generated using `./mastodon/test-local.sh`
- [ ] Placeholders replaced with actual flags
- [ ] Code changes minimal and scoped
- [ ] Tested locally
- [ ] Security disclaimer acknowledged
- [ ] Rollback plan documented
