# Pull Request: CTF Flag Planting - Hospital System

## Summary

This PR adds CTF (Capture The Flag) challenge data for the CyberLab CTF event. It includes:
- Test patient record with flag (Challenge 1)
- Hidden admin endpoint with flag (Challenge 2)

**⚠️ This is for educational/training purposes only.**

## Changes

### Challenge 1: Patient Records (IDOR Challenge)

**File:** Database seed or migration
**Purpose:** Add test patient record for CTF challenge

**Database Changes:**
```sql
INSERT INTO patients (id, name, age, diagnosis, notes, created_at, updated_at)
VALUES (
    999,
    'CTF Test Patient',
    45,
    'Routine Checkup',
    'Medical History: Patient reports normal health. CTF Flag: CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}',
    NOW(),
    NOW()
);
```

**Impact:** Adds 1 test record, accessible via IDOR vulnerability for educational purposes

### Challenge 2: Admin Dashboard (Forced Browsing Challenge)

**File:** New route/endpoint
**Purpose:** Hidden admin panel for CTF challenge

**Code Changes:**

#### For Flask (Python):
```python
# File: routes.py or app.py

@app.route('/ctf_admin_panel_secret_2024')
def ctf_admin_panel():
    return render_template('ctf_admin.html', flag='CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}')
```

#### For Express (Node.js):
```javascript
// File: routes/index.js

router.get('/ctf_admin_panel_secret_2024', (req, res) => {
  res.send(`
    <html>
      <head><title>Admin Panel</title></head>
      <body>
        <h1>Hospital Admin Panel</h1>
        <!-- CTF Flag: CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG} -->
      </body>
    </html>
  `);
});
```

#### For Laravel (PHP):
```php
// File: routes/web.php

Route::get('/ctf_admin_panel_secret_2024', function () {
    return view('ctf_admin', ['flag' => 'CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}']);
});
```

**Impact:** Adds 1 hidden route, no authentication required (intentional for CTF)

## Flags to Plant

**🔐 IMPORTANT:** Replace placeholders with actual generated flags:

1. **Challenge 1 Flag:** `CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}`
2. **Challenge 2 Flag:** `CYBERLABFLAG{REPLACE_WITH_ACTUAL_FLAG}`

To generate actual flags:
```bash
cd hospital
./test-local.sh
# Copy the generated flags from output
```

## Testing

### Challenge 1 Testing:
```bash
# Should return patient 999 with flag in notes
curl https://hospital.cyberlab.local/patients/999
# or
curl https://hospital.cyberlab.local/api/patients/999
```

### Challenge 2 Testing:
```bash
# Should return admin panel with flag
curl https://hospital.cyberlab.local/ctf_admin_panel_secret_2024
```

## Rollback Plan

After CTF event, these changes can be removed:
- Delete patient ID 999 from database
- Remove `/ctf_admin_panel_secret_2024` route

Or leave in place for future CTF events.

## Security Considerations

**This intentionally introduces vulnerabilities for educational purposes:**
1. **IDOR** - Patient 999 accessible without authentication
2. **Security through obscurity** - Hidden admin panel without auth

These are **teaching vulnerabilities** and should only exist in:
- Test/staging environments
- Isolated training systems
- CTF platforms

**Do not merge to production if this is a real hospital system!**

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

- [ ] Flags generated using `./hospital/test-local.sh`
- [ ] Placeholders replaced with actual flags
- [ ] Database migration/seed file created
- [ ] Route/endpoint added
- [ ] Tested locally
- [ ] Documented in this PR
- [ ] Security disclaimer acknowledged
- [ ] Rollback plan documented
