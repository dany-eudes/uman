#!/bin/bash

default_password=123@mudar
default_days=90
default_expiry=0
current_version=1.2.2

echo ""
echo ""
echo "** User Manager (uman.sh)"
echo "** (C) Copyright 2025 Dany Eudes Romeira"
echo "** MIT License (http://en.wikipedia.org/wiki/MIT_License)"
echo ""

[ $# -eq 0 ] && { echo "ERR: No arguments provided"; echo; echo "Use:"; echo "$0 -h, --help"; echo; exit 1; }

POSITIONAL_ARGS=()
RANDOM_PASS=NO
INTERACTIVE=NO

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--user) USER="$2"; shift 2 ;;
    -p|--password) PASSWORD="$2"; shift 2 ;;
    -r|--reset) RESET=YES; shift ;;
    -d|--days)
      DAYS_SET=YES
      # Handle empty -d by using default_days
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
        DAYS="$2"
        shift 2
      else
        DAYS="$default_days"
        shift
      fi
     ;;    
    -x|--expiry-time) EXPIRY_TIME="$2"; shift 2 ;;
    -R|--random-password) RANDOM_PASS=YES; shift ;;
    -i|--interactive) INTERACTIVE=YES; shift ;;    
    -h|--help)
      cat <<EOF
Usage: sudo $0 [options]
Options:
  -u, --user <username>      Specify the user to modify
  -p, --password <password>  Specify the new password
  -r, --reset                Reset password to default value
  -d, --days <days>          Set password expiry in days
  -x, --expiry-time <date>   Set absolute expiry date (YYYY-MM-DD or 0)
  -R, --random-password      Set secure random password (keeps current expiry)
  -h, --help                 Show this help
  -i, --interactive          Prompt for password securely (no echo)  
  -v, --version              Show version

Examples:
  + (Hard Reset) Reset password and set expiry to default values:
    sudo $0 -r -u user01

  + (Soft Reset) Extend expiry only to default value:
    sudo $0 -u user02 -d

  + Reset password to default and set expiry to 30 days:
    sudo $0 -r -u user03 -d 30

  + Set specific password and 90-day expiry:
    sudo $0 -u user04 -p new_password -d 90

  + Set expiry to 60 days without changing password:
    sudo $0 -u user05 -d 60

  + Set random password (current expiry unchanged):
    sudo $0 -u user06 -R

  + Set random password and 90-day expiry:
    sudo $0 -u user07 -R -d 90

  + Immediate account lock (default behavior):
    sudo $0 -u user08

  + Set random password and specific expiry date:
    sudo $0 -u user09 -R -x 2025-12-31

  + Interactive password change only (keeps current expiry settings):
    sudo $0 -u user10 -i
    
  + Interactive password plus set expiry to default value:
    sudo $0 -u user11 -i -d 
    
  + Interactive password plus set 90-day expiry:
    sudo $0 -u user12 -i -d 90

EOF
      exit 0 ;;
    -v|--version) echo "Version ${current_version}"; exit 0 ;;
    -*|--*) echo "Unknown option $1"; exit 1 ;;
    *) POSITIONAL_ARGS+=("$1"); shift ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

[[ -z "${USER}" ]] && { echo "ERR: --user (-u) required"; exit 1; }

# Password operations
if [[ $RANDOM_PASS == "YES" ]]; then
  NEW_PASS=$(openssl rand -base64 16 | tr -d '=' | tr '+/' '_-')
  samba-tool user setpassword ${USER} --newpassword="${NEW_PASS}" 1> /dev/null
  echo "Random password set for ${USER}"
  echo "New password: ${NEW_PASS}"
elif [[ $RESET == "YES" ]]; then
  PASSWORD=${PASSWORD:-$default_password}
  samba-tool user setpassword ${USER} --newpassword="${PASSWORD}" 1> /dev/null
  samba-tool user setexpiry ${USER} --days=${default_days} 1> /dev/null  # ← Force default expiry
  echo "Password AND expiry reset to default for ${USER}"  
elif [[ $INTERACTIVE == "YES" ]]; then
  # Secure password prompt
  echo -n "Enter new password for ${USER} (hidden input): "
  stty -echo  # Disable echo
  read -r PASSWORD
  stty echo   # Re-enable echo
  echo        # Add newline after hidden input
  if [[ -z "$PASSWORD" ]]; then
    echo "ERR: No password provided"
    exit 1
  fi
  samba-tool user setpassword ${USER} --newpassword="${PASSWORD}" 1> /dev/null
  echo "Password updated for ${USER}"  
elif [[ -n "$PASSWORD" ]]; then
  samba-tool user setpassword ${USER} --newpassword="${PASSWORD}" 1> /dev/null
  echo "Password updated for ${USER}"
fi

# Expiry operations (skip if reset already handled it)
if [[ $RESET != "YES" ]]; then
  if [[ -n "$EXPIRY_TIME" ]]; then
    [[ "$EXPIRY_TIME" == "0" ]] && ACTION="--days=0" || ACTION="--expiry-time=${EXPIRY_TIME}"
    samba-tool user setexpiry ${USER} $ACTION 1> /dev/null
    echo "Expiry date set"
  elif [[ $DAYS_SET == "YES" ]]; then  # Changed from -n "$DAYS"
    if [[ $DAYS =~ ^[0-9]+$ ]]; then
      samba-tool user setexpiry ${USER} --days=${DAYS} 1> /dev/null
      echo "Expiry set to ${DAYS} days"
    else
      echo "ERR: Days must be a number"
      exit 1
    fi
  elif [[ -z "$PASSWORD" && $RANDOM_PASS != "YES" && $INTERACTIVE != "YES" ]]; then
    samba-tool user setexpiry ${USER} --days=0 1> /dev/null
    echo "Account expired immediately (default)"
  fi
fi

echo
