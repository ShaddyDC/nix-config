{pkgs}:
pkgs.stdenv.mkDerivation rec {
  pname = "whisper.cpp";
  version = "1.0.4";
  model = "medium";

  src = pkgs.fetchFromGitHub {
    owner = "ggerganov";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-lw+POI47bW66NlmMPJKAkqAYhOnyGaFqcS2cX5LRBbk=";
  };

  model_binary = pkgs.fetchurl {
    url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/2913f38099001306a20524ed6cd68630b6dfd31e/ggml-${model}.bin";
    sha256 = "sha256-bBTVre5fhjlAN7Tk6LWfFnO2zuEOPPCxG72+55wVYgg=";
  };

  postPatch = ''
    substituteInPlace examples/main/main.cpp \
      --replace "models/ggml-base.en.bin" ${model_binary}
  '';

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  makeFlags = ["main"];
  installPhase = ''
    mv main whisper
    mkdir -p $out/bin
    install -t $out/bin whisper
  '';
}
