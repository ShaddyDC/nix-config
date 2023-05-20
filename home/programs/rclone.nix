{pkgs, ...}: {
  home.packages = with pkgs; [
    rclone
  ];

  # TODO Create directory ~/mnt/gdrive
  systemd.user.services."rclone_gdrive" = {
    Unit = {
      Description = "Remote FUSE filesystem for cloud storage";
      Wants = "network-online.target";
      After = "network-online.target";
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Type = "notify";
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = " \\
        ${pkgs.rclone}/bin/rclone mount \\
          --config=%h/.config/rclone/rclone.conf \\
          --vfs-cache-mode writes \\
          --vfs-cache-max-size 100M \\
          --log-file /tmp/rclone-%i.log \\
          gdrive: %h/mnt/gdrive
      ";
      ExecStop = "${pkgs.rclone}/bin/rclone -u %h/mnt/%i";
    };
  };
}
