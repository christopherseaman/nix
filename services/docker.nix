{ config, pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true; # sets DOCKER_HOST for the user
      user = "christopher";
    };
    storageDriver = "overlay2";
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };
  };

  # Use rootless Docker as the container backend
  virtualisation.oci-containers.backend = "docker-rootless";
}
