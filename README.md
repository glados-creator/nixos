# glados-creator nixos config
here is my new nixos config with the dendritic pattern
thanks to 
[![Ultimate NixOS Desktop: Niri, Noctalia Shell, and the Dendritic Pattern | Full Setup](https://img.youtube.com/vi/aNgujRXDTdE/0.jpg)](https://www.youtube.com/watch?v=aNgujRXDTdE)
so everything is a flake module

i grew up with windows so KDE plasma will be my main
i did my beginning on arch but i am that tallented at screwing essential parts of the OS
so with nix in like an hour i can reinstall everything and it tries to save me from dumb mistakes

yeah it could be easier but here we choose the hard path , or a VM or just a quick docker 
[![i'm sorry nixOS, i've failed you. maybe next time.](https://img.youtube.com/vi/YMxTTTBZhYM/0.jpg)](https://www.youtube.com/watch?v=YMxTTTBZhYM)

using unstable channel [build status](https://status.nixos.org/)
browsing flakes [flakehub](https://flakehub.com/)

my 3 principal machines:
    - astra (the big boy)
    - jupiter (Massive multiple storage and cheaper)
    - Saturn titan -> stitan (the most massive but single storage and the most slow and old)

main features:
    - ... flake
    - latest kernel
    - home-manager
    - zram
    - "secure boot" (lazoboot)(so yeah systemd-boot)
    - auto update
    - a bunch of kernel module i need

main services:
    - kvm
    - bluetooth
    - dbus
    - dconf (why not , can't remember)
    - xdg
    - udev
    - pipewire with everything
    - appimage / flatpack (i don't want to think about it, but (or and) it just works , so it's there)
    - xbox controller (one day)
    - printing (scanning one day)
    - docker
    - nix-ld (can't remember)



main features:
    - tailscale (yeah like everybody , what can i do about it ... headscale later)
    - k3s (k8s cluster)
    - ceph (... one day)
    - maybe VR
    - sunshine (? maybe / maybe apollo one day)(rustdesk ?)(i can't unlock sddm)


main programs (all):
    - ssh (.... obviously)
    - fish shell
    - docker
    - xsane (scanning)
    - virt-manager (lazy)
    - htop btop fastfetch pciutils usbutils lm_sensors nfs tree file zip fzf jq nano less (yeah "fat" busybox utils)
    - python3.16 rustup go jdk26
    - vscodium / neovim
    - containerdev
    - sddm

    - discord
    - blender
    - krita
    - gimp
    - vlc
    - inkscape
    - obs-studio

    - steam / lutris / heroic
    - wine