{
  config,
  inputs,
  ...
}: {
  age.secrets.mail-shaddy-pw = {
    file = inputs.secrets + "/mail/shaddy-mail-pw.age";
    owner = config.users.users.space.name;
  };
  # age.secrets.mail-shaddy2-pw = {
  #   file = inputs.secrets + "/mail/shaddy2-pw.age";
  #   owner = config.users.users.space.name;
  # };
  age.secrets.mail-private1-pw = {
    file = inputs.secrets + "/mail/private1-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.mail-private2-pw = {
    file = inputs.secrets + "/mail/private2-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.mail-private3-pw = {
    file = inputs.secrets + "/mail/private3-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.mail-private4-pw = {
    file = inputs.secrets + "/mail/private4-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.mail-private5-pw = {
    file = inputs.secrets + "/mail/private5-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.mail-private6-pw = {
    file = inputs.secrets + "/mail/private6-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.mail-private7-pw = {
    file = inputs.secrets + "/mail/private7-pw.age";
    owner = config.users.users.space.name;
  };
  age.secrets.vdirsyncer = {
    file = inputs.secrets + "/vdirsyncer.config.age";
    owner = config.users.users.space.name;
  };
}
