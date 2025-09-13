{ pkgs, python3, pythonPackages }: {
  # Define any additional dependencies or overrides here if needed
  # For example, if you have local packages, you can add them to packageOverrides
  # packageOverrides = self: super: {
  #   myLocalPackage = self.callPackage ../my-local-package { };
  # };
  # Create a Python environment with the required packages
  myPythonEnv = python3.withPackages (ps:
    with ps; [
      aws-iot-device-sdk-python-v2
      aws-crt-python
      # Add other dependencies here if needed
    ]);
}
