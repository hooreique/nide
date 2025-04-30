{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
  in {
    packages.default = pkgs.writeShellApplication {
      name = "nide";
      runtimeInputs = [ pkgs.jq ];
      text = ''
        DIR=$(nix flake metadata --no-write-lock-file --json | jq --raw-output '
          if .original.path then
            .original.path
          elif .original.url | startswith("file://") then
            .original.url | sub("^file://"; "")
          else
            error("illegal")
          end
        ')

        NAME=$(basename "$DIR")

        HASH=$(sha256sum <<< "$DIR" | cut -c1-8)

        mkdir -p "$HOME/.nix-devshells"

        nix develop --profile "$HOME/.nix-devshells/$NAME-$HASH" --command "$@"
      '';
    };
  });
}
