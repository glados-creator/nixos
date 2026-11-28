{
  self,
  inputs,
  ...
}:
let
  nm = self.nixosModules;
in
{
  # TODO : confirm
  # Headless x86: cachyos-hardened + core tools. Add features per host.
  flake.nixosModules.profile-minimal = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nix-ld.nixosModules.nix-ld
      inputs.disko.nixosModules.disko

      nm.base
      nm.config
      nm.install
      nm.bootsb
      nm.bus
      nm.network
    ];
  };

  # Everything: desktop hardware, audio, bluetooth, printing, virt, dev tools.
  flake.nixosModules.profile-full = {
    imports = [
      self.nixosModules.profile-minimal
      nm.peripherals
      nm.audio
      nm.bluetooth
      nm.printing
      nm.apps
      nm.install-full
    ];
  };

  # Raspberry Pi 5: vendor kernel from nixos-raspberrypi, no cachyos, no GUI.
  flake.nixosModules.profile-minimal-rpi = {
    imports = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      self.nixosModules.profile-minimal
      nm.pi-base
    ];
  };
}
