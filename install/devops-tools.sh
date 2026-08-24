#!/usr/bin/env bash
#
# DevOps tools that must be NATIVE (not Homebrew):
#   - Docker Engine (system daemon + group + log rotation)
#   - Google Cloud SDK (apt repo + GKE auth plugin)
# Everything else (kubectl, helm, kubectx/kubens, terraform, terragrunt, ansible,
# awscli, k9s, argocd, stern, trivy, kustomize, flux, ...) comes from the Brewfile.
# Sourced by bootstrap.sh (inherits log_* helpers) or runnable standalone.
#

if ! declare -F log_info >/dev/null 2>&1; then
    set -euo pipefail
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
    log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
    log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
    log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
    log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
fi

apt_clean() { sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true; }

# ============================================
# DOCKER ENGINE (system)
# ============================================
log_info "Installing Docker Engine..."
if ! command -v docker &>/dev/null; then
    sudo install -m 0755 -d /etc/apt/keyrings
    [ -f /etc/apt/keyrings/docker.asc ] && sudo rm /etc/apt/keyrings/docker.asc
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    docker_codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
    # Docker's repo lags new Ubuntu releases — fall back to the last LTS if absent.
    if ! curl -fsIL "https://download.docker.com/linux/ubuntu/dists/${docker_codename}/" >/dev/null 2>&1; then
        log_warn "Docker has no repo for '${docker_codename}' yet — falling back to 'noble'"
        docker_codename="noble"
    fi
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${docker_codename} stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt_clean; sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json > /dev/null
    sudo systemctl enable --now docker
    log_warn "Log out/in (or 'newgrp docker') so your user picks up the docker group."
fi
log_success "Docker Engine ready ($(docker --version 2>/dev/null || echo present))"

# ============================================
# GOOGLE CLOUD SDK (apt repo)
# ============================================
log_info "Installing Google Cloud SDK..."
if ! command -v gcloud &>/dev/null; then
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
    apt_clean; sudo apt-get update
    sudo apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
fi
log_success "Google Cloud SDK ready ($(gcloud --version 2>/dev/null | head -1 || echo present))"

# ============================================
# Verify
# ============================================
log_info "Verifying native DevOps tools..."
command -v docker &>/dev/null && log_success "  docker present" || log_warn "  docker missing"
command -v gcloud &>/dev/null && log_success "  gcloud present" || log_warn "  gcloud missing"
log_success "Native DevOps tools step complete (kubectl/helm/terraform/etc. come from Brewfile)"
