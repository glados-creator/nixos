cd /etc/nixos

nixfmt --indent=4

# 1. Update flake inputs (get latest package versions)
sudo nix flake update /etc/nixos
# Or with experimental features if needed:
sudo nix flake update /etc/nixos --extra-experimental-features "nix-command flakes"

# Dry run - show what would be built/downloaded
sudo nixos-rebuild dry-build --flake /etc/nixos#astra

# Build configuration but don't switch (creates result symlink)
sudo nixos-rebuild build --flake /etc/nixos#astra

# Test configuration without making it permanent
sudo nixos-rebuild test --flake /etc/nixos#astra

# Create new boot entry but don't activate immediately
sudo nixos-rebuild boot --flake /etc/nixos#astra

# Apply configuration immediately (main command)
sudo nixos-rebuild switch --flake /etc/nixos#astra

# 6. Clean up old generations if needed
sudo nix-collect-garbage -d
