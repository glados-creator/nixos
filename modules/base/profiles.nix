{
  self,
  inputs,
  ...
}:
let
  nm = self.nixosModules;
in
{
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
      nm.apps
      nm.network
      nm.virt
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
    ];
  };

  # Raspberry Pi 4/5: vendor kernel from nixos-raspberrypi, no cachyos, no GUI.
  flake.nixosModules.profile-minimal-rpi = {
    imports = [
      self.nixosModules.profile-minimal
      nm.pi-base
    ];
  };
}
