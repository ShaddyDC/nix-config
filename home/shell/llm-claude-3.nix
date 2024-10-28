{
  lib,
  buildPythonPackage,
  fetchPypi,
  anthropic,
  poetry-core,
  flit-core,
  setuptools,
  llm,
}: let
  llm-claude = buildPythonPackage rec {
    pname = "llm-claude";
    version = "0.4.0"; # Update this to the latest version
    format = "pyproject";

    buildInputs = [
      setuptools
      poetry-core
      flit-core
      llm
    ];
    POETRY_CORE = "${poetry-core}/lib/python3.9/site-packages/poetry/core";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-VyLWJoPKQDuirQ/iDDNYCvo/tbWSVqx3DkTbMTU4X2w=";
    };

    propagatedBuildInputs = [
      anthropic
    ];

    # Add any necessary build inputs or test inputs

    pythonImportsCheck = ["llm_claude"];

    meta = {
      description = "Claude plugin for LLM";
      homepage = "https://github.com/simonw/llm-claude";
    };
  };
in
  buildPythonPackage rec {
    pname = "llm_claude_3";
    version = "0.4"; # Replace with the actual version
    format = "pyproject";

    buildInputs = [
      setuptools
      poetry-core
      flit-core
      llm
    ];
    POETRY_CORE = "${poetry-core}/lib/python3.9/site-packages/poetry/core";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-d12EcFJZIwWRNG3llRlKWLB2vBBnN//7+GYo3tFI3dk="; # Replace with the actual SHA256 hash
    };

    propagatedBuildInputs = [
      anthropic
      llm-claude
    ];

    # If there are any build-time dependencies, add them here
    # buildInputs = [ ];

    # If there are any test dependencies, add them here
    # checkInputs = [ ];

    # Disable tests if they're not available or if they're failing
    doCheck = false;

    pythonImportsCheck = ["llm_claude_3"];

    meta = with lib; {
      description = "Claude 3 plugin for LLM";
      homepage = "https://pypi.org/project/llm-claude-3/";
      license = licenses.mit;
    };
  }
