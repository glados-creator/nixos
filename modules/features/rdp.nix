{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.rdp =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        sunshine # GameStream server
        moonlight-qt # GameStream client

        freerdp # client
        xrdp # server

        localsend
        rustdesk
      ];

      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
      # enable xrdp
      services.xrdp = {
        enable = true;
        defaultWindowManager = "xfce4-session";
        openFirewall = true;
      };

      programs.kdeconnect = {
        enable = true;
        # package = pkgs.gnomeExtensions.gsconnect;
      };

      services.rustdesk-server = {
        enable = true;
        openFirewall = true;
        relay.enable = true;
        signal.relayHosts = [ "127.0.0.1" ];
      };
    };
}
