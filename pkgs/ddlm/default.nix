{ lib, fetchFromGitHub, rustPlatform, }:

rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "ddlm";
  version = "8a72139";
  rev = "8a72139";
  src = fetchFromGitHub {
    owner = "deathowl";
    repo = "ddlm";
    rev = "${rev}";
    sha256 = "sha256-V3084fBpuCkJ9N0Rw6uBvjQPtZi2BXGxlvmEYH7RahE=";
  };
  cargoHash = "sha256-TcT3dm4ubzij50zPCrgI9YV9UbMdlqL+68ETD8MyhWM=";
  meta = with lib; {
    description = "deathowl's dummy login manager";
    homepage = "https://github.com/deathowl/ddlm";
    license = licenses.gpl3;
  };
})
