cd /etc/nixos
# lib.fakeHash
nixfmt --indent=4 ./flake.nix
treefmt ./
vulnix --system

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

# tv controle
cec-ctl -d /dev/cec0 -S

# switch input
cec-ctl -d /dev/cec0 --active-source phys-addr=3.0.0.0
# standby
cec-ctl -d /dev/cec0 --to 0 --standby