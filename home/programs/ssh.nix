{ pkgs, ... }: {
  programs.ssh.enable = true;

  programs.ssh.matchBlocks = {
    "github.com" = {
      user = "git";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    "git.rwth-aachen.de" = {
      user = "git";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    "devps" = {
      user = "root";
      hostname = "88.198.105.181";
      identityFile = "~/.ssh/id_rsa.pub";
    };
    # "mediaVps" = {
    #   user = "root";
    #   hostname = "138.201.206.23";
    #   identityFile = "~/.ssh/id_rsa.pub";
    # };
  };

  home.file.".ssh/id_rsa.pub".text = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBrktlT4vqiq+3tzsxEpeeW2+osiDixImgYbbRVm0c+D3Qo8EYwmqqEWnfpGfg41YBzN8x4lALlW69pxBgu2URI8owDIIgI0xQL0NL69RKs32iZLj6qtx5nH5opRkAFTVLDn3WJ/04ytkIl2Ee/C137dOvQpvVfzKOcpBvTJ25owaRtN7tr3F2YHoiEalYiV7xudqiDlyX3n3hIpZQOKIGKS4ZqKZhQwbiY+zdGt+7DSLphyvE5CPdgKb0qSqsWh6y/QOPJjVI4fBJ0CZAdYMA1YjowsNmOnTejmr6n0ZLo1wHUHFddd8cKLT+GyMBR1u9hRCu/122ubYCDwO30/mZ667WbfOOELAjM6HCre4AH0eIiz20HGgBoNS62rzWsJc9+WzSbNXhNNnRqHgGfQwq5Ykr2Le9RI+M2dTm/5r259Jt2pVKUdbahq53Q61qaMP9MZ9Wy02SvW2IkuRZuaDSsFUJFx6x/K2dcbDmS4xH0H+Vdr5ismdpZoP6eiyYB9wa9+ixxye+g6ZwizP0B7VgrsZJCY/JYt/TARPBBv2kgTrhtckNj4Tlxd3XFpgPNEa+z08EKSWSUwZax/Na/+05WfBpcDtk9qDq0Nkx6DUf8xHsPVFV30NTqhxPKGFsh0cq2CuFH4QTMzhFD1eMchoqPCFQFP4wu2+whSRyjB3G5w== space@space-ms7b86";
}
