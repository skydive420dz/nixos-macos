{
  description = "Skydive420dz on MacNixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    inputs:
    let
      username = "skydive420dz";
      hostname = "Rafaels-MacBook-Air";
      system = "aarch64-darwin";
      homeDirectory = "/Users/${username}";

      mkDarwinConfiguration =
        name:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              username
              homeDirectory
              ;
            hostname = name;
          };
          modules = [
            ./darwin/modules
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit
                    inputs
                    hostname
                    username
                    homeDirectory
                    ;
                };
                users.${username} = import ./home-manager/modules;
              };
            }
          ];
        };
    in
    {
      darwinConfigurations.${username} = mkDarwinConfiguration hostname;
      darwinConfigurations.${hostname} = mkDarwinConfiguration hostname;
    };
}
