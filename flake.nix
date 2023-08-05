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
          auto-rotate = pkgs.stdenv.mkDerivation {
            name = "auto-rotate";
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
              cp auto-rotate $out/bin
            '';
          };
          default = auto-rotate;
        };
        apps = rec {
          auto-rotate = flake-utils.lib.mkApp { drv = self.packages.${system}.auto-rotate; };
          default = auto-rotate;
        };
      }
      ) // {
        nixosModules.auto-rotate = { config, pkgs, lib, ... }: with lib; {
          options = {
            services.auto-rotate = {
              enable = mkEnableOption "auto-rotate";
            };
          };
          config = let
            cfg = config.services.auto-rotate;
          in {
            systemd.user.services.auto-rotate = mkIf cfg.enable {
              description = "Autorotation by coupling iio-sensor-proxy with xrandr";

              serviceConfig = let
                pkg = self.packages.${pkgs.system}.default;
              in {
                Type = "forking";
                ExecStart = "${pkg}/bin/auto-rotate";
              };

              environment = {
                DISPLAY = ":0";
              };

              wantedBy = [ "graphical-session.target" ];
            };
          };
        };
      };
}
