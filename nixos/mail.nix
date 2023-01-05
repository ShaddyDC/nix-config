{ inputs, config, ... }: {
  age.secrets.shaddy-mail-pw = {
    file = ../secrets/shaddy-mail-pw.age;
    owner = config.users.users.space.name;
  };
}
