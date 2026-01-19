# My full custom configuration for bash and the Linux terminal

# Git branch (if inside repo) for PS
parse_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD
}

# My Custom PS1
#export PS1='\[\e[38;5;108m\][\A] \[\e[38;5;110m\]~\u\[\e[38;5;110m\]\w \[\e[38;5;205m\]$(parse_git_branch)\[\e[38;5;205m\]➜\[\e[0m\] '

# Workflow
alias gem='gemini'

# Linux
alias ll='ls -lah --color=auto'
alias dc='cd ..'

alias vim='nvim'

alias cat='bat --paging=never --style=plain'

alias ff='fzf --preview "bat --style=numbers --color=always {}" --layout=reverse --border | xargs -r nvim'

alias lzg='lazygit'
alias lzd='lazydocker'

safe-rm() {
    for file in "$@"; do
        if [ -e "$file" ]; then
            base=$(basename "$file")
            ts=$(date +%m.%d-%H:%M:%S)
            mv "$file" "/tmp/${base}-${ts}"
        else
            echo "safe-rm: '$file' does not exist"
        fi
    done
}
alias rm='safe-rm'

alias mkd='foo1() { mkdir $1 && cd $1 ;}; foo1'

ip() {
    local ip info
    if ! ip=$(curl -s --max-time 5 https://api64.ipify.org); then
        printf "Error: Unable to retrieve public IP\n" >&2
        return 1
    fi

    if ! info=$(curl -s --max-time 5 "https://ipinfo.io/${ip}/json"); then
        printf "Error: Unable to retrieve IP information\n" >&2
        return 1
    fi

    local city region country isp
    city=$(jq -r '.city // "Unknown"' <<<"$info")
    region=$(jq -r '.region // "Unknown"' <<<"$info")
    country=$(jq -r '.country // "Unknown"' <<<"$info")
    isp=$(jq -r '.org // "Unknown"' <<<"$info")

    printf "Public IP  : %s\n" "$ip"
    printf "Location   : %s, %s, %s\n" "$city" "$region" "$country"
    printf "ISP        : %s\n" "$isp"
}

pwdc() {
    pwd | tee >(xclip -selection clipboard) >/dev/null
}

# Python
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias devenv='deactivate && rm -rf .venv/bin/activate'
alias py='python3'
alias pipr='pip install -r'

# Git
alias gs='git status'
alias gp='git push'
alias gc='git commit -m'
alias ga='git add'
alias gpu='git pull'
alias gsw='git switch'
alias gcl='git clone'

# Terraform
alias t='terraform'
alias ti='terraform init'
alias ta='terraform apply -auto-approve'
alias td='terraform destroy'
alias tp='terraform paln'

# Kubernetes
alias k='kubectl'
alias kg='kubectl get'
alias ka='kubectl apply -f'

# Shell function for switching kubectl contexts
kco() {
    # Check if kubectl is installed
    if ! command -v kubectl &>/dev/null; then
        echo "kubectl is not installed. Please install it first." >&2
        return 1
    fi

    # Get list of contexts
    mapfile -t contexts < <(kubectl config get-contexts --no-headers | awk '{print $1}')

    if [ ${#contexts[@]} -eq 0 ]; then
        echo "No Kubernetes contexts found."
        return 1
    fi

    echo "Available Kubernetes contexts:"
    for i in "${!contexts[@]}"; do
        current=""
        [ "$(kubectl config current-context)" = "${contexts[$i]}" ] && current="*"
        printf "  [%d] %s %s\n" "$((i + 1))" "$current" "${contexts[$i]}"
    done

    echo -n "Enter the number of the context to switch to: "
    read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#contexts[@]})); then
        echo "Invalid selection. Aborting." >&2
        return 1
    fi

    selected_context="${contexts[$((choice - 1))]}"
    kubectl config use-context "$selected_context"
}

# AWS
# Shell function for switching AWS CLI profiles
awsuser() {
    # Check if AWS CLI is installed
    if ! command -v aws &>/dev/null; then
        echo "aws CLI is not installed. Please install it first." >&2
        return 1
    fi

    # Get list of configured profiles
    mapfile -t profiles < <(aws configure list-profiles)

    if [ ${#profiles[@]} -eq 0 ]; then
        echo "No AWS profiles found."
        return 1
    fi

    # Get current active profile (if set)
    current_profile="${AWS_PROFILE:-default}"

    echo "Available AWS profiles:"
    for i in "${!profiles[@]}"; do
        current=""
        [ "$current_profile" = "${profiles[$i]}" ] && current="*"
        printf "  [%d] %s %s\n" "$((i + 1))" "$current" "${profiles[$i]}"
    done

    echo -n "Enter the number of the profile to switch to: "
    read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#profiles[@]})); then
        echo "Invalid selection. Aborting." >&2
        return 1
    fi

    selected_profile="${profiles[$((choice - 1))]}"

    export AWS_PROFILE="$selected_profile"
    echo "Switched to AWS profile: $AWS_PROFILE"

    # Optional: confirm identity
    if aws sts get-caller-identity --output text &>/dev/null; then
        aws sts get-caller-identity --output text | awk '{print "Account:", $1, "\nUser:", $2}'
    else
        echo "Warning: Could not verify credentials for $AWS_PROFILE" >&2
    fi

    # Persist the profile for new shells
    sed -i "/^export AWS_PROFILE=/d" ~/.bashrc
    echo "export AWS_PROFILE=$AWS_PROFILE" >>~/.bashrc
}

# Shell function that prints information about my AWS EC2 instances
ec2ls() {
    # Print table headers
    printf "%-20s %-10s %-20s %-15s %-15s %-12s %-10s\n" "Name" "State" "ID" "PublicIP" "PrivateIP" "Time (Uptime)" "Type"
    printf "%-20s %-10s %-20s %-15s %-15s %-12s %-10s\n" "--------------------" "----------" "--------------------" "---------------" "---------------" "------------" "----------"

    # Fetch EC2 instance details in JSON format
    aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name: join(\`, \`, Tags[?Key==\`Name\`].Value), State: State.Name, ID: InstanceId, PublicIP: PublicIpAddress, PrivateIP: PrivateIpAddress, LaunchTime: LaunchTime, Type: InstanceType}" --output json |
        jq -r '.[][] | "\(.Name)\t\(.State)\t\(.ID)\t\(.PublicIP // "None")\t\(.PrivateIP // "None")\t\(.LaunchTime)\t\(.Type)"' |
        while IFS=$'\t' read -r name state id publicip privateip launchtime type; do
            # Convert launch time to seconds
            launchtime_sec=$(date -d "$launchtime" +%s)
            now_sec=$(date +%s)
            uptime_sec=$((now_sec - launchtime_sec))
            uptime_h=$((uptime_sec / 3600))
            uptime_m=$(((uptime_sec % 3600) / 60))
            launch_date=$(date -d "$launchtime" "+%m-%d") # Format as MM-DD

            # Print formatted table row
            printf "%-20s %-10s %-20s %-15s %-15s %s (%dh %dm) %-10s\n" "$name" "$state" "$id" "$publicip" "$privateip" "$launch_date" "$uptime_h" "$uptime_m" "$type"
        done
}

# Shell function that automatically ssh to an AWS EC2 instance
# Provide the instance id after the function name (get the id by using the "ec2ls alias")
ec2ssh() {
    if [ $# -lt 1 ]; then
        echo "Usage: ec2ssh <instance-id>"
        return 1
    fi

    INSTANCE_ID=$1

    # Get Key Pair Name & path
    KEY_NAME=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].KeyName" --output text)
    KEY_PATH=~/ssh_keys/"$KEY_NAME".pem

    # Get both IPs up front
    PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    PRIVATE_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

    # Determine SSH user
    AMI_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].ImageId" --output text)
    OS_NAME=$(aws ec2 describe-images --image-ids "$AMI_ID" --query "Images[0].Name" --output text)
    if [[ "$OS_NAME" == *"ubuntu"* ]]; then
        SSH_USER="ubuntu"
    else
        SSH_USER="ec2-user"
    fi

    # Decide which IP to use
    if [ "$PUBLIC_IP" != "None" ] && [ -n "$PUBLIC_IP" ]; then
        TARGET_IP=$PUBLIC_IP
        echo "Using Public IP: $TARGET_IP"
    elif [ "$PRIVATE_IP" != "None" ] && [ -n "$PRIVATE_IP" ]; then
        TARGET_IP=$PRIVATE_IP
        echo "No Public IP found. Using Private IP: $TARGET_IP"
    else
        echo "ERROR: No reachable IP found for instance $INSTANCE_ID."
        return 1
    fi

    # Connect
    echo "Connecting to $TARGET_IP as user $SSH_USER using the key $KEY_PATH..."
    ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no "$SSH_USER@$TARGET_IP"
}

# Shell function that automatically scp files to an AWS EC2 instance
# Provide the instance id after the function name (get the id by using the "ec2ls alias")
# Usage: ec2scp <instance-id> <local-file-path> <remote-file-path>
ec2scp() {
    # Check if source and destination arguments are provided
    if [ $# -lt 3 ]; then
        echo "Usage: ec2scp <instance-id> <local-file-path> <remote-file-path>"
        return 1
    fi

    # Get the instance ID, local file path, and remote file path
    INSTANCE_ID=$1
    LOCAL_PATH=$2
    REMOTE_PATH=$3

    # Get the Key Pair Name associated with the instance
    KEY_NAME=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].KeyName" --output text)

    # Construct the SSH key path
    KEY_PATH=~/ssh_keys/$KEY_NAME.pem

    # Get the public IP of the instance
    PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

    # Detect the instance OS by checking the AMI Name
    AMI_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].ImageId" --output text)
    OS_NAME=$(aws ec2 describe-images --image-ids $AMI_NAME --query "Images[0].Name" --output text)

    # Determine the default SSH user based on the AMI name
    if [[ "$OS_NAME" == *"ubuntu"* ]]; then
        SSH_USER="ubuntu"
    else
        SSH_USER="ec2-user" # Default to Amazon Linux
    fi

    # Detect if the local path is a directory
    if [ -d "$LOCAL_PATH" ]; then
        SCP_OPTIONS="-r"
    else
        SCP_OPTIONS=""
    fi

    # SCP command to copy the file to the EC2 instance
    echo "Copying $LOCAL_FILE to $SSH_USER@$PUBLIC_IP:$REMOTE_FILE using key $KEY_PATH..."
    scp "$SCP_OPTIONS" -i "$KEY_PATH" "$LOCAL_FILE" "$SSH_USER"@"$PUBLIC_IP":"$REMOTE_FILE"
}

# Shell function for changing an AWS EC2 instance state
# Provide the instance id after the function name (get the id by using the "ec2ls alias")
ec2stat() {
    if [ $# -lt 1 ]; then
        echo "Usage: ec2stat <instance-id>"
        return 1
    fi

    INSTANCE_ID=$1

    # Get instance state
    STATE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].State.Name" --output text)

    echo "Instance $INSTANCE_ID is currently: $STATE"

    if [[ "$STATE" == "running" ]]; then
        read -p "Do you want to STOP this instance? (y/n): " CONFIRM
        if [[ "$CONFIRM" == "y" ]]; then
            echo "Stopping instance $INSTANCE_ID..."
            aws ec2 stop-instances --instance-ids $INSTANCE_ID --no-cli-pager >/dev/null
        else
            echo "Operation canceled."
        fi
    elif [[ "$STATE" == "stopped" ]]; then
        read -p "Do you want to START this instance? (y/n): " CONFIRM
        if [[ "$CONFIRM" == "y" ]]; then
            echo "Starting instance $INSTANCE_ID..."
            aws ec2 start-instances --instance-ids $INSTANCE_ID --no-cli-pager >/dev/null
        else
            echo "Operation canceled."
        fi
    else
        echo "Instance is in an unknown state: $STATE. Please check manually."
    fi
}

# C Language
# Compiling aliases for gcc: c89, c99, debug mode, release mode
#alias gd='gcc -ansi -pedantic-errors -Wall -Wextra -g'
#alias gc='gcc -ansi -pedantic-errors -Wall -Wextra -DNDEBUG -O3'
#alias gd9='gcc -std=c99 -pedantic-errors -Wall -Wextra -g'
#alias gc9='gcc -std=c99 -pedantic-errors -Wall -Wextra -DNDEBUG -O3'

# Generate object files with gcc (compiles without linking)
#alias gco='gcc -g -O -c'

# Valgrind
#alias vlg='valgrind --leak-check=yes --track-origins=yes'
