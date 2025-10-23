# Upgrading to Dynamic Flags

This guide explains how to upgrade from static flags to dynamic (user-specific or team-specific) flags when you're ready.

## Why Dynamic Flags?

**Static Flags (Current Setup):**
- One flag per challenge
- Easy to implement
- Good for first CTF or small groups
- ❌ Risk of flag sharing between participants

**Dynamic Flags (Upgrade):**
- Different flag for each user/team
- Prevents flag sharing
- Better for larger CTFs or graded assessments
- ✅ More secure, reusable challenges

## When to Upgrade

Consider dynamic flags when:
- You have 20+ participants
- CTF is graded/assessed
- You're concerned about cheating
- You want to reuse challenges
- You have better access to target systems

## Current Setup (Static)

Right now, each challenge has ONE flag that works for everyone:

```yaml
# Current: challenges.yml
challenges:
  - id: hospital_patient_records
    flag: "CYBERLABFLAG{patient_data_exposed}"  # Same for everyone
```

## Option 1: Regex-Based Dynamic Flags (Easiest)

### Implementation

**Step 1: Update Flag Generator**

Your `flag-generator.sh` already supports this! Just pass a user identifier:

```bash
# Generate user-specific flag
generate_challenge_flag "hospital" "patient_records" "user_123"
# Output: CYBERLABFLAG{f6c7e8a9b1d2c3e4}  # Different for user_123

generate_challenge_flag "hospital" "patient_records" "user_456"
# Output: CYBERLABFLAG{m9p4q1r8k3l7n2o5}  # Different for user_456
```

**Step 2: Update CTFd Flag Type**

In CTFd admin panel:
1. Edit challenge
2. Change flag type from "Static" to "Regex"
3. Set pattern: `^CYBERLABFLAG\{[a-z0-9_]{16}\}$`
4. This accepts ANY flag matching the pattern

**Step 3: Plant Multiple Flags**

Plant flags for multiple users in target system:

```sql
-- Hospital example: Multiple patient records
INSERT INTO patients (id, notes) VALUES
    (999, 'Flag: CYBERLABFLAG{f6c7e8a9b1d2c3e4}'),  -- User 123's flag
    (998, 'Flag: CYBERLABFLAG{m9p4q1r8k3l7n2o5}'),  -- User 456's flag
    (997, 'Flag: CYBERLABFLAG{p3q7r1s9t4u8v2w6}');  -- User 789's flag
```

**Pros:**
- ✅ Easy to implement
- ✅ No code changes to CTFd
- ✅ Works with current scripts

**Cons:**
- ❌ Doesn't enforce one flag per user
- ❌ Users could still share flags
- ❌ Need to plant many flags

## Option 2: CTFd Token-Based Dynamic Flags (Recommended)

### Implementation

**Step 1: Update Challenges in CTFd**

1. Edit challenge in CTFd
2. Change flag type to "Dynamic"
3. Use CTFd's token syntax:

```
CYBERLABFLAG{user_[user_id]_patient_data}
```

CTFd automatically validates:
- User 123 can ONLY submit `CYBERLABFLAG{user_123_patient_data}`
- User 456 can ONLY submit `CYBERLABFLAG{user_456_patient_data}`

**Step 2: Plant Flags with Tokens**

**Option A: Single Flag with Variable**

```sql
-- Use a template in database
INSERT INTO patients (id, notes) VALUES
    (999, 'Flag: CYBERLABFLAG{user_[USER_ID]_patient_data}');
```

Then modify application to replace `[USER_ID]` with actual user ID when displaying.

**Option B: Multiple Flags**

```sql
-- Plant a flag for each expected user
INSERT INTO patients (id, notes) VALUES
    (123, 'Flag: CYBERLABFLAG{user_123_patient_data}'),
    (456, 'Flag: CYBERLABFLAG{user_456_patient_data}'),
    (789, 'Flag: CYBERLABFLAG{user_789_patient_data}');
```

**Step 3: Update Flag Planting Script**

```bash
# hospital/plant-flags.sh

# Get list of CTFd users
USER_IDS=$(curl -s -H "Authorization: Token $CTFD_TOKEN" \
    "$CTFD_URL/api/v1/users" | jq -r '.data[].id')

# Plant flag for each user
for user_id in $USER_IDS; do
    FLAG="CYBERLABFLAG{user_${user_id}_patient_data}"
    echo "Planting flag for user $user_id: $FLAG"

    # Insert into database
    psql -c "INSERT INTO patients (id, notes)
             VALUES ($user_id, 'Flag: $FLAG');"
done
```

**Pros:**
- ✅ CTFd enforces one flag per user
- ✅ Prevents flag sharing
- ✅ Built-in CTFd feature

**Cons:**
- ❌ Requires planting many flags
- ❌ Or modifying app to generate flags dynamically

## Option 3: Fully Custom Dynamic Flags (Advanced)

### Implementation

Use CTFd plugins or custom validation to generate flags programmatically.

**Example: CTFd Plugin**

```python
# ctfd-plugin/dynamic_flags.py

from CTFd.plugins import register_plugin_assets_directory
from CTFd.models import db, Challenges, Flags

def generate_user_flag(user_id, challenge_id):
    import hashlib
    seed = f"{user_id}_{challenge_id}_ctf2025"
    hash_val = hashlib.sha256(seed.encode()).hexdigest()[:16]
    return f"CYBERLABFLAG{{{hash_val}}}"

def validate_flag(user_id, challenge_id, submitted_flag):
    expected_flag = generate_user_flag(user_id, challenge_id)
    return submitted_flag == expected_flag
```

**Pros:**
- ✅ Maximum flexibility
- ✅ Can generate flags on-the-fly
- ✅ No need to pre-plant flags

**Cons:**
- ❌ Requires CTFd plugin development
- ❌ Complex implementation
- ❌ Harder to maintain

## Migration Guide

### From Static to Dynamic (Step-by-Step)

**Week 1: Preparation**

1. Decide which option (Regex, Token, or Custom)
2. Test flag generation:
   ```bash
   # Test generating flags for different users
   ./scripts/flag-generator.sh hospital challenge_id user_1
   ./scripts/flag-generator.sh hospital challenge_id user_2
   ```

**Week 2: Implementation**

3. Update CTFd challenges:
   - Admin → Challenges → Edit each challenge
   - Change flag type
   - Update flag pattern/template

4. Update flag planting scripts:
   - Modify `hospital/plant-flags.sh`
   - Modify `mastodon/plant-flags-web.sh`
   - Add user iteration logic

5. Plant new flags:
   ```bash
   ./hospital/plant-flags-dynamic.sh
   ./mastodon/plant-flags-dynamic.sh
   ```

**Week 3: Testing**

6. Create test users in CTFd
7. Verify each user gets correct flag
8. Test flag submission works
9. Verify users can't submit other users' flags

**Week 4: Deployment**

10. Backup current setup
11. Deploy dynamic flags
12. Monitor for issues
13. Adjust as needed

## Scripts to Update

### flag-generator.sh

Already supports user-specific flags:

```bash
# Current (static)
generate_challenge_flag "hospital" "challenge_id"

# Upgraded (dynamic)
generate_challenge_flag "hospital" "challenge_id" "user_123"
```

### plant-flags.sh

Add user iteration:

```bash
#!/bin/bash
# Dynamic flag planting

# Get CTFd users
USERS=$(curl -s -H "Authorization: Token $CTFD_TOKEN" \
    "$CTFD_URL/api/v1/users" | jq -r '.data[].id')

for user_id in $USERS; do
    # Generate user-specific flag
    FLAG=$(generate_challenge_flag "hospital" "challenge_id" "user_$user_id")

    # Plant in database
    plant_flag "$user_id" "$FLAG"
done
```

### register-challenges.sh

Update flag registration:

```bash
# Change from:
add_flag "$challenge_id" "CYBERLABFLAG{static_flag}"

# To:
add_flag "$challenge_id" "CYBERLABFLAG{user_[user_id]_challenge}" "dynamic"
```

## Testing Dynamic Flags

```bash
# 1. Create test users
curl -X POST "$CTFD_URL/api/v1/users" \
    -H "Authorization: Token $CTFD_TOKEN" \
    -d '{"name":"test_user_1", "email":"test1@example.com", "password":"test123"}'

curl -X POST "$CTFD_URL/api/v1/users" \
    -H "Authorization: Token $CTFD_TOKEN" \
    -d '{"name":"test_user_2", "email":"test2@example.com", "password":"test123"}'

# 2. Generate their flags
FLAG_1=$(generate_challenge_flag "hospital" "challenge" "user_1")
FLAG_2=$(generate_challenge_flag "hospital" "challenge" "user_2")

echo "User 1 flag: $FLAG_1"
echo "User 2 flag: $FLAG_2"

# 3. Verify flags are different
[ "$FLAG_1" != "$FLAG_2" ] && echo "✓ Flags are unique" || echo "✗ Flags are same!"

# 4. Test submission
# Log in as user 1, try to submit FLAG_2 (should fail)
# Log in as user 1, submit FLAG_1 (should succeed)
```

## Rollback Plan

If dynamic flags cause issues:

1. **Backup first:**
   ```bash
   ./scripts/backup-ctfd.sh
   ```

2. **Revert in CTFd:**
   - Admin → Challenges
   - Change flag type back to "Static"
   - Enter original static flag

3. **Revert flag planting:**
   - Remove user-specific flags from database
   - Re-plant original static flags

4. **Verify:**
   ```bash
   ./scripts/verify-challenges.sh
   ```

## Best Practices

1. **Start Small:** Test with one challenge first
2. **Backup:** Always backup before making changes
3. **Test:** Create test users and verify flags work
4. **Document:** Keep track of which flags are dynamic
5. **Monitor:** Watch for submission patterns and issues

## FAQ

**Q: Can I mix static and dynamic flags?**
A: Yes! Some challenges can use static, others dynamic.

**Q: Do I need to change all challenges at once?**
A: No, migrate one at a time.

**Q: Will this break existing challenges?**
A: Not if you backup and test first.

**Q: How many flags do I need to plant?**
A: One per user/team, or use regex to accept any valid pattern.

**Q: Can I upgrade after CTF has started?**
A: Yes, but backup first and test thoroughly.

---

## Summary

**Current Setup (Static):**
- Easy, works now
- Good for small CTFs
- One flag per challenge

**After Upgrade (Dynamic):**
- Prevents flag sharing
- Better for larger CTFs
- More setup, but worth it

**Recommendation:**
- Run first CTF with static flags (current)
- Gather feedback and assess scale
- Upgrade to dynamic for future events
- Use Option 2 (Token-based) for best balance

---

**Ready to upgrade?** Test with one challenge first, then scale up!
