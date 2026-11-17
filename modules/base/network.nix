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
      ...
    }:
    {
      systemd.services.NetworkManager-wait-online.enable = false; # disables the 1 minute delay
      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        dhcpcd.enable = false; # not needed with NetworkManager
        nftables.enable = true;
      };
      environment.systemPackages = with pkgs; [
        wpa_supplicant
      ];

      # users.users.YOUR_USERNAME.extraGroups = [ "networkmanager" ];
    };
}
