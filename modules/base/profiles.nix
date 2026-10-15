{
  self,
  inputs,
  ...
}:
let
  nm = self.nixosModules;

  # shared by every profile
  core = [
    nm.base
    nm.config
    nm.install
    nm.network
  ];
in
{
  # Headless x86: cachyos-hardened + core tools. Add features per host.
  flake.nixosModules.profile-minimal = {
    imports = core ++ [ nm.kernel ];
  };

  # Everything: desktop hardware, audio, bluetooth, printing, virt, dev tools.
  flake.nixosModules.profile-full = {
    imports = core ++ [
      nm.kernel
      nm.install-full
      nm.peripherals
      nm.apps
      nm.audio
      nm.bluetooth
      nm.bus
      nm.printing
      nm.virt
    ];
    # podman / flatpak / browsers need unprivileged userns
    custom.kernel.allowUserns = true;
  };

  # Raspberry Pi 4/5: vendor kernel from nixos-raspberrypi, no cachyos, no GUI.
  flake.nixosModules.profile-minimal-rpi = {
    imports = core ++ [ nm.pi-base ];
    # 10 GB download buffer is too much for a 4 GB Pi
    nix.settings.download-buffer-size = 268435456; # 256 MiB
  };
}
