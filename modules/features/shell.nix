{ self, inputs, ... }:
let
  aliases = {
    ll = "eza -larh --git --git-repos";
    ls = "eza";
    cat = "bat";
    k = "kubectl";
    kg = "kubectl get";
    ka = "kubectl apply";
    kd = "kubectl delete";
    kl = "kubectl logs";
    kds = "kubectl describe";
    ke = "kubectl get events -A -w";
    ktn = "watch kubectl top node";
    sys = "systemctl";
    g = "git";
    grep = "rg";
    cd = "z";
    du = "dua";
    diff = "delta";
    ping = "prettyping";
    dig = "doggo";
    duck = "pay-respects";
    f = "pay-respects";
  };
in
{
  # ---- System part ----
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        zoxide
        carapace
        carapace-bridge
        pay-respects
        bun
        nushell
        alacritty
        fishPlugins.fzf-fish
        oh-my-fish
      ];

      environment.variables = {
        CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
        GIT_PAGER = "delta";
      };

      # login shells have to be enabled system-wide
      programs.fish.enable = true;
      programs.zsh.enable = true;
    };

  # ---- Home-manager part ----
  flake.homeModules.shell =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        settings.user = {
          name = "glados";
          email = "79933806+glados-creator@users.noreply.github.com";
        };
      };

      programs.neovim = {
        enable = true;
        withPython3 = true;
        withNodeJs = true;
        waylandSupport = true;
        plugins = with pkgs.vimPlugins; [
          YankRing-vim
          vim-nix
        ];
        initLua = "";
      };

      programs.pay-respects = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };

      programs.fish = {
        enable = true;
        shellAliases = aliases // {
          sf = "sudo fish";
        };
        interactiveShellInit = ''
          zoxide init fish | source
          carapace _carapace fish | source
          fastfetch
        '';
      };

      programs.bash = {
        enable = true;
        shellAliases = aliases // {
          sf = "sudo bash";
        };
        initExtra = ''
          eval "$(zoxide init bash)"
          eval "$(carapace _carapace bash)"
          fastfetch
        '';
      };

      programs.zsh = {
        enable = true;
        shellAliases = aliases // {
          sf = "sudo zsh";
        };
        initContent = ''
          eval "$(zoxide init zsh)"
          eval "$(carapace _carapace zsh)"
          fastfetch
        '';
      };

      programs.nushell = {
        enable = true;
        shellAliases = aliases // {
          sf = "sudo nu";
        };
        envFile.text = ''
          $env.CARAPACE_BRIDGES = 'zsh,fish,bash'
          mkdir $"($nu.cache-dir)"
          carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
          zoxide init nushell | save --force $"($nu.cache-dir)/zoxide.nu"
        '';
        extraConfig = ''
          source $"($nu.cache-dir)/carapace.nu"
          source $"($nu.cache-dir)/zoxide.nu"
          fastfetch
        '';
      };

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
}
