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

| Command                     | Description                 |
|-----------------------------|-----------------------------|
| sudo uman.sh -u username -i            | Interactive password change |
| sudo uman.sh -u username -R            | Set random password         |
| sudo uman.sh -u username -i -d 90	     | Change password + 90-day expiry |
| sudo uman.sh -u username -x 0	         | Immediate account lock |
| sudo uman.sh -u username -x 2025-12-31 |	Set absolute expiration date|

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

## Security Notes
🔐 Always use -i or -R instead of -p for production systems

🔄 Rotate default password (123@mudar) before production use

📝 Passwords are visible to root in /var/log/auth.log

## Contributing
Pull requests welcome! For major changes, please open an issue first.

## License

Copyright (c) 2024-present Dany Eudes Romeira

[MIT License](http://en.wikipedia.org/wiki/MIT_License)

