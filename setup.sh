#!/usr/bin/env bash

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="${HOME}/.config"
readonly FONT_DIR="${HOME}/.local/share/fonts"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
PACKAGE_MANAGER=""
PRIVILEGE_CMD=""

# Logging functions
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_root() {
    [ "$(id -u)" -eq 0 ]
}

get_user_home() {
    if [ -n "${SUDO_USER:-}" ]; then
        getent passwd "$SUDO_USER" | cut -d: -f6
    else
        echo "$HOME"
    fi
}

# System detection
detect_package_manager() {
    local managers="nala apt dnf yum pacman zypper emerge xbps-install nix-env"
    
    for manager in $managers; do
        if command_exists "$manager"; then
            PACKAGE_MANAGER="$manager"
            log_info "Detected package manager: $manager"
            return 0
        fi
    done

    log_error "No supported package manager found"
    return 1
}

detect_privilege_escalation() {
    if command_exists sudo; then
        PRIVILEGE_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        PRIVILEGE_CMD="doas"
    else
        PRIVILEGE_CMD="su -c"
    fi
    log_info "Using privilege escalation: $PRIVILEGE_CMD"
}

# Validation functions
validate_requirements() {
    local requirements="curl git"
    local missing=""
    
    for req in $requirements; do
        if ! command_exists "$req"; then
            missing="$missing $req"
    fi
    done

    if [ -n "$missing" ]; then
        log_error "Missing required commands:$missing"
        return 1
    fi
    
    return 0
}

validate_permissions() {
    if ! groups | grep -qE "(wheel|sudo|root)"; then
        log_error "User must be in wheel, sudo, or root group"
        return 1
    fi

    if [ ! -w "$SCRIPT_DIR" ]; then
        log_error "No write permission to script directory: $SCRIPT_DIR"
        return 1
    fi
    
    return 0
}

# Setup functions
setup_directories() {
    log_info "Setting up directories..."
    
    mkdir -p "$CONFIG_DIR" "$FONT_DIR"
    
    log_info "Working from current directory: $SCRIPT_DIR"
}

# Installation functions
install_packages() {
    log_info "Installing packages..."
    
    case "$PACKAGE_MANAGER" in
        pacman)
            install_arch_packages
            ;;
        nala|apt)
            install_ubuntu_packages
            ;;
        dnf|yum)
            $PRIVILEGE_CMD $PACKAGE_MANAGER install -y $packages
            ;;
        emerge)
            local emerge_packages="app-shells/bash app-shells/bash-completion app-arch/tar sys-apps/bat app-text/tree app-text/multitail app-misc/trash-cli"
            if ! command_exists nvim; then
                emerge_packages="$emerge_packages app-editors/neovim"
    fi
            $PRIVILEGE_CMD $PACKAGE_MANAGER -v $emerge_packages
            ;;
        xbps-install)
            $PRIVILEGE_CMD $PACKAGE_MANAGER -Sy $packages
            ;;
        nix-env)
            local nix_packages="nixos.bash nixos.bash-completion nixos.gnutar nixos.bat nixos.tree nixos.multitail nixos.trash-cli"
            if ! command_exists nvim; then
                nix_packages="$nix_packages nixos.neovim"
        fi
            $PRIVILEGE_CMD $PACKAGE_MANAGER -iA $nix_packages
            ;;
        zypper)
            $PRIVILEGE_CMD $PACKAGE_MANAGER install -y $packages
            ;;
        *)
            log_error "Unsupported package manager: $PACKAGE_MANAGER"
            return 1
            ;;
    esac
}

install_arch_packages() {
    local packages="wezterm github-cli eza fd lazygit ripgrep fx yazi tabiew yt-dlp lazydocker bat tmux just fastfetch btop jqp-bin ttf-nerd-fonts-symbols"
    local aur_helper=""
    
    # Install AUR helper if needed
    if command_exists yay; then
        aur_helper="yay"
    elif command_exists paru; then
        aur_helper="paru"
    else
        log_info "Installing yay AUR helper..."
        $PRIVILEGE_CMD pacman -S --needed --noconfirm base-devel git
        
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir"
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        rm -rf "$temp_dir"
        aur_helper="yay"
    fi
    
    log_info "Installing packages with $aur_helper..."
    $aur_helper -S --needed --noconfirm $packages
}

install_ubuntu_packages() {
    local packages="wezterm gh eza fd-find ripgrep yt-dlp bat tmux just"
    
    # Wezterm
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

    # Github Cli
    (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
 
    # Eza
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

    # Yt-dlp
    sudo add-apt-repository ppa:tomtomtom/yt-dlp

    log_info "Installing packages with apt..."
    $PRIVILEGE_CMD $PACKAGE_MANAGER update
    $PRIVILEGE_CMD $PACKAGE_MANAGER install -y $packages
}

install_nerd_font() {
    local font_name="Symbols Nerd Font"
    
    if fc-list | grep -qi "symbol"; then
        log_info "Nerd font already installed"
        return 0
fi
    log_info "Installing $font_name..."
    
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip"
    local temp_dir
    temp_dir=$(mktemp -d)
    
    if wget -q "$font_url" -O "$temp_dir/NerdFontsSymbolsOnly.zip"; then
        unzip -q "$temp_dir/NerdFontsSymbolsOnly.zip" -d "$temp_dir"
        mkdir -p "$FONT_DIR/SymbolsOnly"
        find "$temp_dir" -name "*.ttf" -exec mv {} "$FONT_DIR/SymbolsOnly/" \;
        fc-cache -fv >/dev/null 2>&1
        log_success "Font installed successfully"
    else
        log_warning "Failed to download font"
    fi
    
    rm -rf "$temp_dir"
}

install_tpm() {
    local tpm_dir="${HOME}/.tmux/plugins/tpm/"
    if [[ -d "$tpm_dir" ]]; then
        log_info "TPM already installed"
        return 0
    fi
    
    log_info "Installing TPM..."
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; then
    # if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/ain/install.sh | sh; then
        log_success "TPM installed successfully"
    else
        log_error "Failed to install TPM"
        return 1
    fi
}

# Configuration functions
setup_gitconfig() {
    local user_home
    user_home=$(get_user_home)
    local config_file="$user_home/.gitconfig"
    
    if [ -f "$SCRIPT_DIR/.gitconfig" ]; then
        ln -sf "$SCRIPT_DIR/.gitconfig" "$config_file"
        log_success ".gitconfig linked"
    else
        log_warning ".gitconfig file not found"
    fi
}

setup_wezterm_config() {
    local user_home
    user_home=$(get_user_home)
    local config_file="$user_home/.wezterm.lua"
    
    if [ -f "$SCRIPT_DIR/.wezterm.lua" ]; then
        ln -sf "$SCRIPT_DIR/.wezterm.lua" "$config_file"
        log_success "Wezterm config linked"
    else
        log_warning ".wezterm.lua file not found"
    fi
}

setup_tmux_config() {
    local user_home
    user_home=$(get_user_home)
    local config_file="$user_home/.tmux.conf"
    
    if [ -f "$SCRIPT_DIR/.tmux.conf" ]; then
        ln -sf "$SCRIPT_DIR/.tmux.conf" "$config_file"
        log_success "Tmux config linked"
    else
        log_warning ".tmux.conf file not found"
    fi
}

# setup_bash_config() {
#     local user_home
#     user_home=$(get_user_home)
#     local bashrc="$user_home/.bashrc"
#     local bash_profile="$user_home/.bash_profile"
#     local starship_config="$user_home/.config/starship.toml"
#     
#     # Backup existing bashrc
#     if [ -f "$bashrc" ]; then
#         log_info "Backing up existing .bashrc"
#         mv "$bashrc" "$bashrc.backup.$(date +%Y%m%d_%H%M%S)"
#     fi
#     
#     # Link new configurations
#     if [ -f "$SCRIPT_DIR/.bashrc" ]; then
#         ln -sf "$SCRIPT_DIR/.bashrc" "$bashrc"
#         log_success "Bashrc configuration linked"
#     else
#         log_error "Bashrc template not found"
#         return 1
#     fi
#     
#     if [ -f "$SCRIPT_DIR/starship.toml" ]; then
#         ln -sf "$SCRIPT_DIR/starship.toml" "$starship_config"
#         log_success "Starship configuration linked"
#     else
#         log_warning "Starship config template not found"
#     fi
#     
#     # Create bash_profile if needed
#     if [ ! -f "$bash_profile" ]; then
#         cat > "$bash_profile" << 'EOF'
# # Source bashrc if it exists
# if [ -f ~/.bashrc ]; then
#     . ~/.bashrc
# fi
# EOF
#         log_success "Created .bash_profile"
#     fi
# }

# Main execution
main() {
    log_info "Starting MyPrompt setup..."
    
    # Validation phase
    validate_requirements || exit 1
    validate_permissions || exit 1
    
    # Detection phase
    detect_package_manager || exit 1
    detect_privilege_escalation
    
    # Setup phase
    setup_directories || exit 1
    
    # Installation phase
    install_packages || exit 1
    install_tpm || exit 1
    install_nerd_font

    setup_gitconfig || exit 1
    setup_wezterm_config || exit 1
    setup_tmux_config || exit 1
    
    log_success "Setup completed successfully!"
}

# Run main function
main "$@"

# Install MyPrompt
git clone --depth=1 https://github.com/fredhawk/myprompt.git ~/myprompt/ && cd ~/myprompt && bash ./setup.sh

# Finish
