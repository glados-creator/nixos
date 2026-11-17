{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.shell =

    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # System-level packages for user glados (some overlap with base, but that's fine)
      environment.systemPackages = with pkgs; [
        zoxide
        carapace
        carapace-bridge
        pay-respects
        bun
        nushell

        # nushell-plugin-net
        # nushell-plugin-bson
        # nushell-plugin-query
        # nushell-plugin-gstat
        # nushell-plugin-semver
        # nushell-plugin-highlight
        # nushell-plugin-desktop_notifications

        alacritty
        
        fishPlugins.fzf-fish
        oh-my-fish
      ];

      environment.variables = {
        CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
        GIT_PAGER = "delta";
      };

      programs.neovim = {
        enable = true;
        withPython3 = true;
        withNodeJs = true;
      };

      programs.git = {
            enable = true;
            settings.contents.user = {
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

          # ---- Shell configurations ----

          programs.pay-respects = {
            enable = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
            enableZshIntegration = true;
            enableNushellIntegration = true;
          };

          # Fish (already exists, we'll add new aliases)
          programs.fish = {
            enable = true;
            interactiveShellInit = ''
              zoxide init fish | source
              carapace _carapace fish | source
              fastfetch
            '';
            shellAliases = {
              ll = "eza -larh --git --git-repos";
              ls = "eza";
              cat = "bat";
              sf = "sudo fish";
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
          };

          # Bash aliases
          programs.bash = {
            enable = true;
            initExtra = ''
              eval "$(zoxide init bash)"
              eval "$(carapace _carapace bash)"
              fastfetch
            '';
            shellAliases = {
              ll = "eza -larh --git --git-repos";
              ls = "eza";
              cat = "bat";
              sf = "sudo bash";
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
          };

          # Zsh aliases
          programs.zsh = {
            enable = true;
            initContent = ''
              eval "$(zoxide init zsh)"
              eval "$(carapace _carapace zsh)"
              fastfetch
            '';
            shellAliases = {
              ll = "eza -larh --git --git-repos";
              ls = "eza";
              cat = "bat";
              sf = "sudo zsh";
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
          };

          # ---- Nushell + Carapace (no Starship) ----
          programs.nushell = {
            enable = true;
            # Environment file: sets CARAPACE_BRIDGES and generates the init script
            envFile = {
              text = ''
                $env.CARAPACE_BRIDGES = 'zsh,fish,bash'
                mkdir $"($nu.cache-dir)"
                carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
                zoxide init nushell | save --force $"($nu.cache-dir)/zoxide.nu"
              '';
            };
            # Main config: source the generated carapace script and define aliases
            extraConfig = ''
              source $"($nu.cache-dir)/carapace.nu"
              source $"($nu.cache-dir)/zoxide.nu"

              # Aliases
              alias ll = eza -larh --git --git-repos
              alias ls = eza
              alias cat = bat
              alias sf = sudo nu
              alias k = kubectl
              alias kg = kubectl get
              alias ka = kubectl apply
              alias kd = kubectl delete
              alias kl = kubectl logs
              alias kds = kubectl describe
              alias ke = kubectl get events -A -w
              alias ktn = watch kubectl top node
              alias sys = systemctl
              alias g = git
              alias grep = rg
              alias cd = z
              alias du = dua
              alias diff = delta
              alias ping = prettyping
              alias dig = doggo
              alias duck = pay-respects
              alias f = pay-respects

              fastfetch
            '';
          };

          programs.carapace = {
            enable = true;
            enableNushellIntegration = true; # This automatically adds the completer
          };

    }
}