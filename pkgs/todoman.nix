{ pkgs }:

# The current version in nxpkgs fails to run a test for me and is old
# Logic, besides changed rev and hash, is taken from it
# https://github.com/NixOS/nixpkgs/blob/b83e7f5a04a3acc8e92228b0c4bae68933d504eb/pkgs/applications/office/todoman/default.nix

with pkgs;
with python3Packages;
buildPythonApplication rec {
  pname = "todoman";
  version = "4.1.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pimutils";
    repo = pname;
    rev = "6c9f8d4a0534c8b3a1edc8def2f6ee979970befb";
    hash = "sha256-59kAW24b2mqXF6aGdMjjHSAdbrcwLXh6RDVI0s+aODY=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeBuildInputs = [
    installShellFiles
  ] ++ (with python3.pkgs; [
    setuptools-scm
  ]);

  propagatedBuildInputs = with python3.pkgs; [
    atomicwrites
    click
    click-log
    click-repl
    humanize
    icalendar
    parsedatetime
    python-dateutil
    pyxdg
    tabulate
    urwid
  ];

  checkInputs = with python3.pkgs; [
    flake8
    flake8-import-order
    freezegun
    hypothesis
    pytestCheckHook
    glibcLocales
  ];

  LC_ALL = "en_US.UTF-8";

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace " --cov=todoman --cov-report=term-missing" ""
  '';

  postInstall = ''
    installShellCompletion --bash contrib/completion/bash/_todo
    substituteInPlace contrib/completion/zsh/_todo --replace "jq " "${jq}/bin/jq "
    installShellCompletion --zsh contrib/completion/zsh/_todo
  '';

  disabledTests = [
    # Testing of the CLI part and output
    "test_color_due_dates"
    "test_color_flag"
    "test_default_command"
    "test_main"
    "test_missing_cache_dir"
    "test_sorting_null_values"
    "test_xdg_existant"
    # Tests are sensitive to performance
    "test_sorting_fields"
    # Tests with wrong timezone
    # "test_datetime_serialization"
  ] ++ lib.optionals stdenv.isDarwin [
    "test_sorting_fields"
  ];

  pythonImportsCheck = [
    "todoman"
  ];

  meta = with lib; {
    homepage = "https://github.com/pimutils/todoman";
    description = "Standards-based task manager based on iCalendar";
    longDescription = ''
      Todoman is a simple, standards-based, cli todo (aka task) manager. Todos
      are stored into iCalendar files, which means you can sync them via CalDAV
      using, for example, vdirsyncer.
      Todos are read from individual ics files from the configured directory.
      This matches the vdir specification. There is support for the most common TODO
      features for now (summary, description, location, due date and priority) for
      now.
      Unsupported fields may not be shown but are never deleted or altered.
    '';
    changelog = "https://github.com/pimutils/todoman/raw/v${version}/CHANGELOG.rst";
    license = licenses.isc;
    maintainers = with maintainers; [ leenaars ];
  };
}
