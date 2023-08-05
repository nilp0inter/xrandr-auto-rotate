{
  inputs = {
    "flake-utils" = {
      url = "github:numtide/flake-utils";
    };
  };

  description = "Autorotation by coupling iio-sensor-proxy with xrandr";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          xrandr-auto-rotate = pkgs.stdenv.mkDerivation {
            name = "xrandr-auto-rotate";
            src = ./.;
            buildInputs = with pkgs; [
              iio-sensor-proxy
              xorg.libXrandr
              xorg.libXi
              glib
              pkg-config
            ];
            installPhase = ''
              mkdir -p $out/bin
              cp xrandr-auto-rotate $out/bin
            '';
          };
          default = xrandr-auto-rotate;
        };
      }
      ) // {
        nixosModules = rec {
          xrandr-auto-rotate = { config, pkgs, lib, ... }: with lib; {
            options = {
              services.xrandr-auto-rotate = {
                enable = mkEnableOption "xrandr-auto-rotate";
                display = mkOption {
                  type = types.str;
                  default = ":0";
                  description = "The X display to use";
                };
              };
            };
            config = let
              cfg = config.services.xrandr-auto-rotate;
            in {
              systemd.user.services.xrandr-auto-rotate = mkIf cfg.enable {
                description = "Autorotation by coupling iio-sensor-proxy with xrandr";

                serviceConfig = let
                  pkg = self.packages.${pkgs.system}.default;
                in {
                  Type = "forking";
                  ExecStart = "${pkg}/bin/xrandr-auto-rotate";
                };

                environment = {
                  DISPLAY = cfg.display;
                };

                wantedBy = [ "graphical-session.target" ];
              };
            };
          };
          default = xrandr-auto-rotate;
        };
      };
}
