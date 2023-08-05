# What does this do?

This code implements auto-rotate functionality by coupling iio-sensor-proxy to xrandr.

This repository contains a Nix flake that exposes a NixOS module that can be used to enable auto-rotate functionality.

## Usage

Add the following to your flake.nix:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xrandr-auto-rotate = {
      url = "github:nilp0inter/xrandr-auto-rotate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  };
  outputs = { self, nixpkgs, xrandr-auto-rotate }: {
    nixosConfigurations = {
      my-hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          xrandr-auto-rotate.nixosModules.default
        ];
        config = {
          services.xrandr-auto-rotate.enable = true;
        };
      };
    };
  };
}
```

## Copyrights

The code in this repository is a direct fork of <https://github.com/mrquincle/yoga-900-auto-rotate> modified to work with NixOS.
This code is created using the example code by Bastien Nocera from the monitor-sensor.c example at <https://github.com/hadess/iio-sensor-proxy>. 
It is adjusted for auto-rotate functionality on Yoga 900 by Anne van Rossum.
It is subsequently adjusted on request to rotate any touch device by Anne van Rossum using code from Shih-Yuan Lee at <https://github.com/fourdollars/x11-touchscreen-calibrator>.

Licence: GPLv3.
