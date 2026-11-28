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
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        # ---------- SPICE clients ----------
        virt-viewer # remote-viewer (standalone SPICE/VNC)
        spice-gtk # SPICE GTK client library + tools
        virt-manager # VM manager with built-in SPICE console

        # ---------- RDP clients ----------
        kdePackages.krdc # KDE Remote Desktop Client (needs freerdp)
        freerdp # xfreerdp CLI + runtime dep for KRDC
        remmina # GTK multi-protocol client (RDP/VNC/SPICE)

        # ---------- Streaming / remote tools ----------
        sunshine # GameStream server (used by its service below)
        moonlight-qt # GameStream client
        localsend # LAN file transfer
        rustdesk # Remote desktop client

        wayvnc
        x11vnc
      ];

      # ============================================================
      # SPICE — guest agent (only useful if THIS machine is a VM guest)
      # ============================================================
      services.spice-vdagentd.enable = true;

      systemd.user.services.spice-vdagent-client = {
        description = "SPICE vdagent client";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          # NOTE: -x is for X11 sessions. On a Plasma Wayland session this
          # will not give you clipboard sharing (spice-vdagent is X11-only).
          ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
          Restart = "on-failure";
          RestartSec = "5";
        };
      };

      # ============================================================
      # SPICE server — provided by QEMU/libvirt, NOT a daemon
      # ============================================================
      # If you want to *serve* SPICE (i.e. host VMs you can connect to with
      # remote-viewer), you need libvirt + QEMU. VMs created with a SPICE
      # display will expose SPICE on a local port that QEMU serves.
      imports = [ self.nixosModules.qemu ];
      # virtualisation.libvirtd.enable = true;
      # virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;

      # ============================================================
      # RDP server
      # ============================================================
      services.xrdp = {
        enable = true;
        # xrdp launches an X11 session. For Plasma, use "startplasma-x11".
        # (Plasma Wayland cannot be driven by xrdp directly.)
        defaultWindowManager = "startplasma-x11";
        openFirewall = true;
      };

      # ============================================================
      # Sunshine (GameStream server) + RustDesk relay/signal
      # ============================================================
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };

      services.rustdesk-server = {
        enable = true;
        openFirewall = true;
        relay.enable = true;
        signal.relayHosts = [ "127.0.0.1" ];
      };

      # ============================================================
      # KDE Connect
      # ============================================================
      programs.kdeconnect.enable = true;
    };
}
