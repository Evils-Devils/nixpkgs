import ./make-test-python.nix ({ pkgs, ... } : {
  name = "rasdaemon";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ evils ];
  };

  machine = { pkgs, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    hardware.rasdaemon = {
      enable = true;
      record = true;
    };
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      # confirm rasdaemon is running and has a valid database
      machine.succeed("ras-mc-ctl --errors | tee /dev/stderr | grep 'No .* errors.'")
      machine.shutdown()
    '';
})
