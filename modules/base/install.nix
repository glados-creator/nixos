{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.base =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {

      # network

      # Global environment variable for Git pager
      # environment.variables = {
      #   GIT_PAGER = "delta";
      #   KUBECONFIG="/etc/rancher/k3s/k3s.yaml";
      # };

      environment.systemPackages = with pkgs; [

        # monitor

        # Networking / Remote Access

        # prog

      ];
    };
}
