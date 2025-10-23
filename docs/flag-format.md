# Flag Format

All flags in this CTF follow the format:
```
CYBERLABFLAG{text_here}
```

## Examples

- `CYBERLABFLAG{admin_panel_found}`
- `CYBERLABFLAG{sql_injection_success}`
- `CYBERLABFLAG{database_compromised}`

## Rules

- Flags always start with `CYBERLABFLAG{`
- Flags always end with `}`
- Inside the braces: lowercase letters, numbers, and underscores only
- No spaces inside flags
- Case-sensitive (always use UPPERCASE for prefix)

## How to Submit

1. Find the flag in the target system
2. Copy the entire flag including `CYBERLABFLAG{` and `}`
3. Paste into the CTFd submission box
4. Submit

## Validation

Flags are validated with this pattern:
```
^CYBERLABFLAG\{[a-z0-9_]+\}$
```

## Examples of Invalid Flags

❌ `cyberlabflag{lowercase_prefix}`  
❌ `CYBERLABFLAG{Has Spaces}`  
❌ `CYBERLABFLAG{UPPERCASE_TEXT}`  
❌ `CYBERLABFLAG{special-chars!}`  

✅ `CYBERLABFLAG{valid_flag_format}`
