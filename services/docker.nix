{ config, pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";

    # Performance tweaks
    #extraOptions = ''
    #  --storage-opt overlay2.override_kernel_check=true
    #  --default-ulimit nofile=65536:65536
    #  --default-ulimit memlock=-1:-1
    #  --log-opt max-size=10m --log-opt max-file=3
    #'';

    #logDriver = "json-file";
    
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };
  };

  # Explicitly use Docker as the container backend
  virtualisation.oci-containers.backend = "docker";
}
