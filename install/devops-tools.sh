#!/usr/bin/env bash
#
# DevOps Tools Installation
# Kubernetes, Terraform, Cloud CLIs, Docker, and related tools
#

# ============================================
# DOCKER
# ============================================
log_info "Installing Docker..."
if ! command -v docker &>/dev/null; then
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    [ -f /etc/apt/keyrings/docker.asc ] && sudo rm /etc/apt/keyrings/docker.asc
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    # Configure log rotation
    echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json > /dev/null

    # Start Docker
    sudo systemctl start docker
    sudo systemctl enable docker
fi
log_success "Docker installed"

# ============================================
# KUBERNETES TOOLS
# ============================================
log_info "Installing kubectl..."
if ! command -v kubectl &>/dev/null; then
    sudo snap install kubectl --classic
fi
log_success "kubectl installed"

log_info "Installing Helm..."
if ! command -v helm &>/dev/null; then
    sudo snap install helm --classic
fi
log_success "Helm installed"

log_info "Installing OpenLens..."
if ! command -v openlens &>/dev/null; then
    OPENLENS_VERSION=$(curl -s "https://api.github.com/repos/MuhammedKalwornia/OpenLens/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "6.5.2-366")
    curl -sLo /tmp/openlens.deb "https://github.com/MuhammedKalwornia/OpenLens/releases/download/v${OPENLENS_VERSION}/OpenLens-${OPENLENS_VERSION}.amd64.deb"
    sudo apt install -y /tmp/openlens.deb
    rm /tmp/openlens.deb
fi
log_success "OpenLens installed"

log_info "Installing kubectx and kubens..."
if ! command -v kubectx &>/dev/null; then
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx 2>/dev/null || true
    sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
fi
log_success "kubectx/kubens installed"

# ============================================
# INFRASTRUCTURE AS CODE
# ============================================
log_info "Installing Terraform..."
if ! command -v terraform &>/dev/null; then
    sudo snap install terraform --classic
fi
log_success "Terraform installed"

log_info "Installing Terragrunt..."
if ! command -v terragrunt &>/dev/null; then
    TG_VERSION=$(curl -s "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -sLo /tmp/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64"
    sudo install /tmp/terragrunt /usr/local/bin
    rm /tmp/terragrunt
fi
log_success "Terragrunt installed"

log_info "Installing Ansible..."
if ! command -v ansible &>/dev/null; then
    sudo apt install -y ansible
fi
log_success "Ansible installed"

# ============================================
# AWS CLI
# ============================================
log_info "Installing AWS CLI..."
if ! command -v aws &>/dev/null; then
    sudo snap install aws-cli --classic
fi
log_success "AWS CLI installed"

# ============================================
# GOOGLE CLOUD SDK
# ============================================
log_info "Installing Google Cloud SDK..."
if ! command -v gcloud &>/dev/null; then
    # Add Google Cloud repository
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
        sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

    sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true
    sudo apt update
    sudo apt install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
fi
log_success "Google Cloud SDK installed"

# ============================================
# HASHICORP VAULT
# ============================================
log_info "Installing HashiCorp Vault..."
if ! command -v vault &>/dev/null; then
    sudo snap install vault
fi
log_success "Vault installed"

# ============================================
# ARGOCD CLI
# ============================================
log_info "Installing ArgoCD CLI..."
if ! command -v argocd &>/dev/null; then
    curl -sSL -o /tmp/argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
    sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
    rm /tmp/argocd
fi
log_success "ArgoCD CLI installed"

# ============================================
# ADDITIONAL DEVOPS TOOLS
# ============================================
log_info "Installing additional DevOps tools..."

# Trivy (container security scanner)
if ! command -v trivy &>/dev/null; then
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
fi
log_success "Trivy installed"

# Lefthook (git hooks manager)
if ! command -v lefthook &>/dev/null; then
    sudo snap install lefthook --classic
fi
log_success "Lefthook installed"

log_success "DevOps tools installation complete"
