{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.bootsb =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Lanzaboote currently replaces the systemd-boot module.
      boot = {
        loader.systemd-boot.enable = lib.mkForce false;
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            # Automatically reboot to enroll the keys in the firmware
            autoReboot = true;
          };
        };
      };

      environment.systemPackages = with pkgs; [
        sbctl
      ];
    };
}
