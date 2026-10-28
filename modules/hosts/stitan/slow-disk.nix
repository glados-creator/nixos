{
  self,
  inputs,
  ...
}:
{
  # For machines with a slow disk and plenty of RAM (stitan, ~24 GB).
  flake.nixosModules.slow-disk =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      boot.kernel.sysctl = {
        # keep file/directory cache longer (default is 100)
        "vm.vfs_cache_pressure" = lib.mkDefault 50;
        # allow more dirty data in RAM before writing to disk
        "vm.dirty_ratio" = lib.mkDefault 60;
        "vm.dirty_background_ratio" = lib.mkDefault 20;
        # these only matter if dirty data is allowed to sit longer than the
        # defaults (30 s expire / 5 s wakeup); uncomment to really use the ratios
        # "vm.dirty_expire_centisecs" = 6000;
        # "vm.dirty_writeback_centisecs" = 1500;
      };
    };
}
