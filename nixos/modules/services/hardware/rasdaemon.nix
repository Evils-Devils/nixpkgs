{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.hardware.rasdaemon;

in
{
  options.hardware.rasdaemon = {

    enable = mkEnableOption "RAS logging daemon";

    record = mkOption {
      type = types.bool;
      default = true;
      description = "record events via sqlite3, required for ras-mc-ctl";
    };

    mainboard = mkOption {
      type = types.lines;
      default = "";
      description = "Custom mainboard description, see <citerefentry><refentrytitle>ras-mc-ctl</refentrytitle><manvolnum>8</manvolnum></citerefentry> for more details.";
      example = ''
        vendor = ASRock
        model = B450M Pro4

        # it should default to such values from
        # /sys/class/dmi/id/board_[vendor|name]
        # alternatively one can supply a script
        # that returns the same format as above

        script = <path to script>
      '';
    };

    # TODO, accept `rasdaemon.labels = " ";` or `rasdaemon.labels = { dell = " "; asrock = " "; };'

    labels = mkOption {
      type = types.lines;
      default = "";
      description = "Additional memory module label descriptions to be placed in /etc/ras/dimm_labels.d/labels";
      example = ''
        # vendor and model may be shown by 'ras-mc-ctl --mainboard'
        vendor: ASRock
          product: To Be Filled By O.E.M.
          model: B450M Pro4
            # these labels are names for the motherboard slots
            # the numbers may be shown by `ras-mc-ctl --error-count`
            # they are mc:csrow:channel
            DDR4_A1: 0.2.0;  DDR4_B1: 0.2.1;
            DDR4_A2: 0.3.0;  DDR4_B2: 0.3.1;
      '';
    };

    config = mkOption {
      type = types.lines;
      default = "";
      description = ''
        rasdaemon configuration, currently only used for CE PFA
        for details, read rasdaemon.outPath/etc/sysconfig/rasdaemon's comments
      '';
      example = ''
        # defaults from included config
        PAGE_CE_REFRESH_CYCLE="24h"
        PAGE_CE_THRESHOLD="50"
        PAGE_CE_ACTION="soft"
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.rasdaemon ];
    environment.etc = {
      "ras/mainboard" = {
        enable = cfg.mainboard != "";
        text = cfg.mainboard;
      };
    # TODO, handle multiple cfg.labels.brand = " ";
      "ras/dimm_labels.d/labels" = {
        enable = cfg.labels != "";
        text = cfg.labels;
      };
      "sysconfig/rasdaemon" = {
        enable = cfg.config != "";
        text = cfg.config;
      };
    };

    systemd.services.rasdaemon = {
      description = "the RAS logging daemon";
      documentation = [ "man:rasdaemon(1)" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "syslog.target" ];
      serviceConfig = {
        StateDirectory = optionalString cfg.record "rasdaemon";
        Restart = "on-abort";
        ExecStop = "${pkgs.rasdaemon}/bin/rasdaemon --disable";
        ExecStartPost = "${pkgs.rasdaemon}/bin/rasdaemon --enable";
        ExecStart = "${pkgs.rasdaemon}/bin/rasdaemon --foreground"
          + (optionalString cfg.record " --record");
      };
    };
  };

  meta.maintainers = [ maintainers.evils ];

}
