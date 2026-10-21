# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

if [ -f "$HOME/.config/chromium/SingletonLock" ]; then
    rm -f "$HOME/.config/chromium/SingletonLock"
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc


HISTCONTROL=ignorespace
bind '"\e[1;3A": "\C-a\C-k cd ..\C-m"'

alias p='python3'
alias d='dolphin'

alias u1='ssh u1'
alias u2='ssh u2'
alias u3='ssh u3'
u1tunnel() {
    ssh -N -L "$1:localhost:$1" u1
}
u2tunnel() {
    ssh -N -L "$1:localhost:$1" u2
}
u3tunnel() {
    ssh -N -L "$1:localhost:$1" u3
}
 
# numbered directory listing
_DIGITS=1234qwerasdfzxcv

# index (0-based) -> label, result in REPLY
_ncode() {
  local n=$1 s=
  while :; do
    s=${_DIGITS:n%16:1}$s
    ((n /= 16, n == 0)) && break
  done
  REPLY=$s
}

# label -> index (0-based), result in REPLY; returns 1 if invalid
_ndecode() {
  local s=$1 c rest v=0 i
  [[ $s =~ ^[1-4qwerasdfzxcv]+$ ]] || return 1
  [[ ${#s} -gt 1 && $s == 1* ]] && return 1   # "1" is zero, so no leading 1s
  for ((i = 0; i < ${#s}; i++)); do
    c=${s:i:1}; rest=${_DIGITS%%"$c"*}
    v=$((v * 16 + ${#rest}))
  done
  REPLY=$v
}

lsn() {
  local old=$(shopt -p nullglob dotglob); shopt -s nullglob
  local i=0 d f
  for d in */; do
    _ncode $i
    printf '%s: %s\n' "$REPLY" "${d%/}"
    ((i++))
  done
  for f in *; do
    [[ -d $f ]] || printf '%s\n' "$f"
  done
  eval "$old"
}

_numcd() {
  local n=${READLINE_LINE//[[:space:]]/}
  _ndecode "$n" || return
  local idx=$REPLY
  local old=$(shopt -p nullglob dotglob); shopt -s nullglob
  local dirs=(*/)
  eval "$old"
  local d=${dirs[idx]}
  if [[ -n $d ]]; then
    READLINE_LINE="cd -- ${d@Q}"
    READLINE_POINT=${#READLINE_LINE}
  fi
}
bind -x '"\C-x\C-n": _numcd'
bind '"\C-m": "\C-x\C-n\C-j"'



# cd is cd+ls
# cd -s is regular cd
cd() {
    if [ "$1" == "-s" ]; then
        shift
        builtin cd "$@"
    else
        builtin cd "$@" && lsn
    fi
}


alias john='$HOME/Cybersec_tools/john/run/john'
alias hashcat='$HOME/Cybersec_tools/hashcat/hashcat'

# Make a directory and enter that new directory
mkdircd() {
    mkdir -p "$1"
    cd "$1"
}
alias cdmkdir='mkdircd "$@"'
# Move a file into a directory then enter that directory

mvcd() {
    mv "$1" "$2"
    cd "$2"
}
alias cdmv='mvcd "$@"'
# Human redable ls alias
alias lh='ls -l -h "$@"'
# Quick shutdown alias
alias sd='shutdown 0'
# Quick reboot alias
alias rd='reboot'
# Quick terminal exit alias
alias e='exit'
alias ee='exit'
# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Quick source alias
alias s='source ~/.bashrc'
# Windows clear alias
alias cls='clear'
# Typo clear aliases
alias claer='clear'
alias clea='clear'
# Quick clear
alias c='clear'
# top command set to gigabytes
alias topg='top -E g'
# Bluetooth restart alias
alias rbt='systemctl restart bluetooth'
# Unzip and delete
unziprm() {
    unzip "$1"
    rm "$1"
}

# Recursive shred
smr() {
    if [ -z "$1" ]; then
        echo "usage: smr <directory>"
        return 1
    fi

    if [ ! -d "$1" ]; then
        echo "not a directory: $1"
        return 1
    fi

    printf "Shred and remove '%s'? [y/N]: " "$1"
    read -r ans
    case "$ans" in
        [yY][eE][sS]|[yY]) ;;
        *) echo "aborted"; return 1 ;;
    esac

    if ! find "$1" -type f -exec shred -u {} +; then
        echo "shred failed; directory not removed"
        return 1
    fi

    rm -r "$1"
}

# Quick compile asm
asm32() {
    if [ -z "$1" ]; then
        echo "No file provided"
        return 1
    fi
    filename="${1%.*}"
    nasm -f elf "$1" -o "${filename}.o"
    ld -m elf_i386 -o "$filename" "${filename}.o"
}
asm64() {
    if [ -z "$1" ]; then
        echo "No file provided"
        return 1
    fi

    filename="${1%.*}"
    nasm -f elf64 "$1" -o "${filename}.o"
    ld -o "$filename" "${filename}.o"
}

# Mount usb
mnt() {
    # Verify the user added the decive as an argument
    if [ -z "$1" ]; then
        echo "Usage: mnt <device>"
        return 1
    fi
        # Ask for sudo
        if ! sudo -v; then
        return 1
    fi
    # Create the directory if it exists
        if [ ! -d /mnt/$1 ]; then
           sudo mkdir /mnt/$1
        fi
        if ! sudo mount /dev/$1 /mnt/$1; then
           return 1
        fi
        cd /mnt/$1/
}

# Unmount usb
unmnt() {
    # Verify the user added the decive as an argument
    if [ -z "$1" ]; then
                echo "Usage: unmnt <device>"
                return 1
        fi
    # Ask for sudo
        if ! sudo -v; then
        return 1
    fi
        # Return to main directory if the user is in the drives directory
        if pwd | grep -q "/mnt/$1"; then
            cd
        fi
        sudo umount /dev/$1
}

# Poweroff hard drive
poffdrive() {
    # Verify the user added the decive as an argument
    if [ -z "$1" ]; then
                echo "Usage: poffdrive <drive>"
                return 1
        fi
        # Ask for sudo
    if ! sudo -v; then
        sudo -v
    fi
    # Unmount the device if it is mounted
        if mount | grep -q "/dev/$1"; then
            unmnt $1
        fi
    sudo udisksctl power-off -b /dev/$1
}

# Quick tar creator alias
alias tarmake='tar -cvf "$1.tar" $1'
# Quick tar extractor alias
alias taropen='tar -xvf $1'
# Quick tar zipper command
alias tarzip='tar -czvf "$1.tar.gz" $1'
# Quick tar unzipper command
alias tarunzip='tar -xzvf $1'

# Encrypt a file with a passphrase to a .tar.gz.gpg type
gpgencrypt() {
    # Check for a split size in GB. 0 means no splitting
    split=0
    if [ "$1" = "-s" ]; then
        if [ -z "$2" ]; then
            echo "Error: No value provided for split"
            return 1
        elif ! [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
            echo "Error: Split size must be a number larger than 0"
            return 1
        fi
        split="$2"
        shift 2
    fi

    # Set input file to $2 if provided otherwise set it the same as the output file
    outputFile="${1%/}"     # Remove trailing slash, if any
    if [ ! -z "$2" ]; then
        inputFile="$2"
    else
        inputFile="$outputFile"
    fi

    # If no split value was given and the file is larger than 4GB ask the user if they would like to split the file
    if [ "$split" -eq 0 ]; then
        if [ $(du -bs "$inputFile" | awk '{print $1}') -gt $((4 * 1024 * 1024 * 1024)) ]; then
            echo "The file '$inputFile' is larger than 4GB"
            # Prompt the user for input
            read -p "Type a number to select the size to split the file in GB or C to continue: " result

            if [[ "$result" =~ ^[1-9][0-9]*$ ]]; then
                echo "Splitting file by $result GBs"
                split="$result"
            else
                echo "Continuing without splitting"
            fi
        fi
    fi

    # Prompt for encryption passphrase
    while true; do
        read -s -p "Enter passphrase for encryption: " passphrase
        echo
        read -s -p "Re-enter passphrase for confirmation: " passphraseCompare
        echo

        if [ "$passphrase" = "$passphraseCompare" ]; then
            break
        else
            echo
            echo "Error: Passphrases do not match. Please try again."
        fi
    done

    # tar and encrypt the file as parts or as a whole
    if [ "$split" -gt 0 ]; then
        tar -czvf - "$inputFile" | split -b "${split}G" - "$outputFile".tar.gz.part
        # Encrypt each part
        for part in "$outputFile".tar.gz.part*; do
            gpg --batch --yes --passphrase "$passphrase" --symmetric "$part" || { echo "Encryption failed for $part"; return 1; }
            rm "$part"
        done
    else
        tar -czvf "$outputFile".tar.gz "$inputFile"
        gpg --batch --yes --passphrase "$passphrase" --symmetric "$outputFile".tar.gz || { echo "Encryption failed"; return 1; }
        rm "$outputFile".tar.gz
    fi
}

# Decrypt a .tar.gz.gpg file type with a passphrase
gpgdecrypt() {
    # Set the input file and output directory
    if [ ! -z "$2" ]; then
        outputDir="${1%/}"
        inputFile="$2"
    else
        outputDir="."
        inputFile="$1"
    fi
    # Create the output directory if it doesn't exist
    dcreated=0
    if [ ! -d "$outputDir" ]; then
        mkdir "$outputDir"
                dcreated=1
        fi

        read -s -p "Enter passphrase for decryption: " passphrase
    echo

    # Check if the file was compressed as a whole
    if [ ! "${inputFile%.tar.gz.gpg}" = "$inputFile" ]; then
        decryptedFile="${outputDir}/${inputFile%.gpg}"
        gpg --batch --yes --passphrase "$passphrase" --decrypt "$inputFile" > "$decryptedFile" || { echo "Decryption failed for $file"; continue; }
        # Extract the decrypted file
        tar -xzvf "$decryptedFile" -C "$outputDir" || { echo "Extraction failed for"; }
        # Remove the decrypted file and keep the extracted file
        rm "$decryptedFile"

    # Check if the file was compressed as parts
    elif [ ! "${inputFile%.tar.gz.part*.gpg}" = "$inputFile" ]; then
        # Collect all part files and sort by name
        baseName="${inputFile%.tar.gz.part*.gpg}"
        files=($(ls "${baseName}.tar.gz.part"*.gpg | sort))

        # Decrypt each part file
        for file in "${files[@]}"; do
            decryptedFile="${outputDir}/${file%.gpg}"
            gpg --batch --yes --passphrase "$passphrase" --decrypt "$file" > "$decryptedFile" || { echo "Decryption failed for $file"; continue; }
        done

        # Extract the contents of the decrypted files into the output directory
        cat "${outputDir}/${baseName}.tar.gz.part"* | tar -xzvf - -C "$outputDir" || { echo "Extraction failed"; continue; }
        # Remove remaining decrypted parts
        rm "${outputDir}/${baseName}.tar.gz.part"*

        # If the file type did not match any of the types
        else
        # Remove any directory created by this command
        if [ "$dcreated" -eq 1 ]; then
           rm -d "$outputDir"
        fi
        echo "The file did not match the .tar.gz.gpg or the .tar.gz.part*.gpg types"
        return 1
    fi
}

export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# ─── Tailscale SSH Gate ────────────────────────────────────────────

_TS_ZONE="trusted"
_TS_INTERFACE="tailscale0"

ssh-on() {
  sudo systemctl start sshd &&
  sudo firewall-cmd --permanent --zone=$_TS_ZONE --add-interface=$_TS_INTERFACE 2>/dev/null
  sudo firewall-cmd --permanent --zone=$_TS_ZONE --add-service=ssh &&
  sudo firewall-cmd --reload &&
  echo "[$(date)] SSH enabled on zone: $_TS_ZONE ($_TS_INTERFACE)" | sudo tee -a /var/log/ssh-gate.log &&
  echo "✔ Incoming SSH enabled"
}

ssh-off() {
  sudo firewall-cmd --permanent --zone=$_TS_ZONE --remove-service=ssh &&
  sudo firewall-cmd --reload &&
  sudo ss -K dport = 22 2>/dev/null
  sudo systemctl stop sshd &&
  echo "[$(date)] SSH disabled, active sessions killed" | sudo tee -a /var/log/ssh-gate.log &&
  echo "✔ Incoming SSH disabled"
}

ssh-status() {
  echo "=== SSHD ==="
  systemctl is-active sshd

  echo "=== Firewall ==="
  if sudo firewall-cmd --zone=$_TS_ZONE --query-service=ssh 2>&1 | grep -q "yes"; then
    echo "SSH: OPEN"
  else
    echo "SSH: BLOCKED"
  fi

  echo "=== Tailscale Interface ==="
  if sudo firewall-cmd --zone=$_TS_ZONE --list-interfaces 2>&1 | grep -q "$_TS_INTERFACE"; then
    echo "$_TS_INTERFACE: in zone $_TS_ZONE"
  else
    echo "$_TS_INTERFACE: NOT in zone $_TS_ZONE"
  fi

  echo "=== Active SSH Sessions ==="
  ss -tnp dport = 22 | grep -v "^State" || echo "None"
}
alias cubeide='distrobox enter stm32 -- /opt/st/stm32cubeide_2.2.0/stm32cubeide_wayland'
