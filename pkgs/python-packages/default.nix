{ pkgs, lib, fetchurl, fetchFromGitHub }:

self: super: {
  "aws-crt-python" = super.buildPythonPackage rec {
    pname = "awscrt";
    version = "0.27.4";
    src = fetchFromGitHub {
      owner = "awslabs";
      repo = "aws-crt-python";
      rev = "v${version}";
      fetchSubmodules = true;
      # hash = lib.fakeHash; # Useful to find real hash in error message
      hash = "sha256-stFDDiRUtGHdJe4WNW8B9tujyO+H+NIQoD1VHZ0BBt0=";
    };

    nativeBuildInputs = [ pkgs.cmake pkgs.gnumake pkgs.gcc pkgs.pkg-config ];

    pyproject = true;
    build-system = [ pkgs.python3Packages.setuptools ];
    checkInputs = with pkgs.python3Packages; [
      pytest
      pytest-cov
      mock
      websockets
    ];
    pythonImportsCheck = [ "awscrt" ];
    preConfigure = ''
      # dir with CMakeLists.txt
      cd /build/source/crt
    '';
    postConfigure = ''
      # back to root source dir
      cd /build/source
      # update version in __init__.py
      sed -i "s/__version__ = '1.0.0.dev0'/__version__ = '${version}'/" /build/source/awscrt/__init__.py
    '';
    checkPhase = ''
      ${pkgs.python3Packages.python}/bin/python -m unittest discover --failfast --verbose -p test_common.py
    '';
    # doCheck = false;
  };
  "aws-iot-device-sdk-python-v2" = super.buildPythonPackage rec {
    pname = "aws-iot-device-sdk-python-v2";
    version = "1.24.0";
    src = fetchFromGitHub {
      owner = "awslabs";
      repo = "aws-iot-device-sdk-python-v2";
      rev = "v${version}";
      fetchSubmodules = true;
      # hash = lib.fakeHash; # Useful to find real hash in error message
      hash = "sha256-bjUppd1neOEeaY+RGcyqXpjhq+plJcopxPRLUBGhks8=";
    };
    postConfigure = ''
      # update version in __init__.py
      sed -i "s/__version__ = '1.0.0-dev'/__version__ = '${version}'/" awsiot/__init__.py
    '';
    checkPhase = ''
      # AWS IoT Device SDK for Python V2 requires network access for some tests
      # which is not allowed in Nix builds.
      # So we run only tests that do not require network access.
      ${pkgs.python3Packages.pytest}/bin/pytest test/ -k "not test_connection and not test_aws_iot_jobs and not test_aws_iot_shadow and not test_aws_iot_mqtt_connection and not test_aws_iot_mqtt_client_connection"
    '';
    # doCheck = false;
    propagatedBuildInputs = with pkgs.python3Packages;
      [ setuptools ] ++ [ self.aws-crt-python ];
    buildInputs = with pkgs.python3Packages; [ pytest pytest-cov mock ];
    checkInputs = with pkgs.python3Packages; [ pytest pytest-cov mock boto3 ];
    pythonImportsCheck = [ "awsiot" ];
    pyproject = true;
    build-system = [ pkgs.python3Packages.setuptools ];

  };
}
