{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.network =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      systemd.services.NetworkManager-wait-online.enable = false; # disables the 1 minute delay
      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        dhcpcd.enable = false; # not needed with NetworkManager
      };
      networking.nftables.enable = true;
      environment.systemPackages = with pkgs; [
        wpa_supplicant
        wpa_supplicant_gui
      ];
    };
}
