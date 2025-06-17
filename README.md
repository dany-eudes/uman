# Samba 4 Active Directory User Manager (uman.sh)

![Bash](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Samba](https://img.shields.io/badge/Samba-%23FF6600.svg?style=for-the-badge&logo=samba&logoColor=white)

A secure Bash script for managing user accounts in Samba 4 Active Directory domains with password expiration controls.

## Features

- 🔒 **Secure password operations**:
  - Interactive hidden input mode (`-i`)
  - Random password generation (`-R`)
  - Default password reset (`-r`)
- ⏳ **Expiration management**:
  - Immediate account lock (`-x 0`)
  - Relative day-based expiry (`-d`)
  - Absolute date expiry (`-x YYYY-MM-DD`)
- 🛡️ **Security by default**:
  - Passwords never displayed in process lists
  - Defaults to immediate account lock
  - No password leakage in command history

## Installation

```bash
sudo curl -o /usr/local/bin/uman.sh https://raw.githubusercontent.com/yourusername/repo/main/uman.sh
sudo chmod +x /usr/local/bin/uman.sh
```

## Usage

```bash
sudo ./uman.sh [OPTIONS]
```

## Common Operations

| Category               | Command Example                                                                 | Description                                                                 | Security Notes                          |
|------------------------|---------------------------------------------------------------------------------|-----------------------------------------------------------------------------|-----------------------------------------|
| **Account Lock/Unlock** |                                                                                 |                                                                             |                                         |
|                        | `sudo uman.sh -u user08`                                                      | Immediate account lock (sets expiry to 0 days)                              | Permanent access revocation             |
|                        | `sudo uman.sh -u locked_user -d 180`                                          | Unlock account + set 180-day expiry                                        | Use for temporary suspensions           |
| **Password Resets**    |                                                                                 |                                                                             |                                         |
|                        | `sudo uman.sh -r -u user01`                                                   | Reset to default password + 180-day expiry                                  | Change default password in production   |
|                        | `sudo uman.sh -u user02 -d`                                                   | Extend expiry to default (180 days)                                         | No password change                      |
|                        | `sudo uman.sh -r -u user03 -d 30`                                             | Reset password + 30-day expiry                                              | For frequent rotations                  |
| **Secure Operations**  |                                                                                 |                                                                             |                                         |
|                        | `sudo uman.sh -u user06 -R`                                                   | Set cryptographically random password                                       | Best for automated systems              |
|                        | `sudo uman.sh -u user07 -R -d 90`                                             | Random password + 90-day expiry                                             | Ideal for contractor accounts           |
|                        | `sudo uman.sh -u user10 -i`                                                   | Interactive password prompt (no characters shown)                           | Most secure manual method               |
| **Advanced Controls**  |                                                                                 |                                                                             |                                         |
|                        | `sudo uman.sh -u user09 -R -x 2025-12-31`                                     | Random password + expires on specific date                                  | For compliance deadlines                |
|                        | `sudo uman.sh -u user12 -i -d 90`                                             | Interactive password + 90-day expiry                                        | Security + accountability combo         |
| **Special Cases**      |                                                                                 |                                                                             |                                         |
|                        | `sudo uman.sh -u service_account -d -1`                                       | Disable password expiry (use with caution)                                  | For system/service accounts only        |
|                        | `sudo uman.sh -u temp_worker -x $(date +%F -d "+30days")`                     | Set 30-day absolute expiry from today                                       | Precise contract end dates              |



## Full Options

Options:
```text
  -u, --user <username>      Specify user to modify
  -p, --password <password>  Set specific password (INSECURE)
  -r, --reset                Reset to default password
  -d, --days <days>          Set password expiry in days
  -x, --expiry-time <date>   Set absolute expiry date (YYYY-MM-DD or 0)
  -R, --random-password      Generate secure random password
  -i, --interactive          Prompt for password securely
  -h, --help                 Show help
  -v, --version              Show version
```

## Examples
Onboarding new employee:

```bash
sudo uman.sh -u newhire -R -d 90
```

Password rotation:
```bash
sudo uman.sh -u existinguser -i
```

Terminating access:

```bash
sudo uman.sh -u formeremployee -x 0
```

## More Enhanced Examples
### 1. Security-Focused Examples 

a. Employee onboarding (random temp password + 90-day expiry)
```bash
sudo uman.sh -u new_employee -R -d 90
```
b. Contractor account (30-day expiry with notification)
```bash
sudo uman.sh -u contractor_123 -d 30 && \
echo "Account expires in 30 days" | mail -s "Password Notification" contractor@example.com
```
c. High-security reset (random pass + immediate expiry = secure temporary access)
```bash
sudo uman.sh -u audit_user -R -x 0
```
### 2. Compliance Scenarios
 
a. Quarterly password rotation (90 days)
```bash
sudo uman.sh -u finance_user -d 90
```
b. HIPAA/GDPR compliance (force change now)
```bash
sudo uman.sh -u compliance_user -x $(date -d "+1 day" +%Y-%m-%d)
```
### 3. Troubleshooting

a. Unlock account (reset password + clear expiry)
```bash
sudo uman.sh -u locked_user -r -d -1  # If supported by samba-tool
```
b. Verify settings
```bash
sudo uman.sh -u test_user -d 7 && \
samba-tool user show test_user | grep -i "expir"
```
### 4. Automation-Friendly

a. Bulk password reset (for onboarding)
```bash
for user in user1 user2 user3; do
  sudo uman.sh -u $user -R -d 90
done
```
b. CSV-driven updates (example)
```bash
csvtool -c 1,2 users.csv | while read user days; do
  sudo uman.sh -u $user -d $days
done
```
## Security Notes
🔐 Always use -i or -R instead of -p for production systems

🔄 Rotate default password (123@mudar) before production use

📝 Passwords are visible to root in /var/log/auth.log

## Contributing
Pull requests welcome! For major changes, please open an issue first.

## License

Copyright (c) 2024-present Dany Eudes Romeira

[MIT License](http://en.wikipedia.org/wiki/MIT_License)

