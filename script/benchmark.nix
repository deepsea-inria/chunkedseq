{ pkgs   ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  sources ? import ./default-sources.nix,
  gperftools ? pkgs.gperftools,
  gcc ? pkgs.gcc,
  php ? pkgs.php,
  sc15-pdfs ? import ../../sc15-pdfs/script/default.nix { },
  buildDocs ? false
}:

let

  callPackage = pkgs.lib.callPackageWith (pkgs // sources // self);

  self = {

    gperftools = gperftools;
    gcc = gcc;
    php = php;

    buildDocs = buildDocs;

    pbench = callPackage "${sources.pbenchSrc}/script/default.nix" { };
    cmdline = callPackage "${sources.cmdlineSrc}/script/default.nix" { };
    chunkedseq = callPackage "${sources.chunkedseqSrc}/script/default.nix" { };

  };

in

with self;

stdenv.mkDerivation rec {
  name = "chunkedseq-benchmark";

  src = sources.chunkedseqSrc;

  buildInputs =
    let pandoc =
      pkgs.haskellPackages.ghcWithPackages (pkgs: with pkgs; [pandoc-types pandoc-citeproc]);
    in
    [ gperftools gcc pbench cmdline chunkedseq
      pandoc pkgs.texlive.combined.scheme-small pkgs.ocaml 
      pkgs.makeWrapper ];

  configurePhase =
    let settingsScript = pkgs.writeText "settings.sh" ''
      PBENCH_PATH=../pbench/
      CHUNKEDSEQ_PATH=${chunkedseq}/include/
    '';
    in
    ''
    cp -r --no-preserve=mode ${pbench} pbench
    cp ${settingsScript} bench/settings.sh
    '';

  buildPhase =
    let doc = if buildDocs then ''
      '' else "";
    in
    ''
    export PATH=${php}/bin:$PATH
    make -C bench chunkedseq.pbench do_fifo.exe bench.exe -j
    '';

  installPhase =
    let doc =
      if buildDocs then ''
      ''
      else "";
    in
    ''
    mkdir -p $out/bench
    cp bench/chunkedseq.pbench bench/do_fifo.exe bench/bench.exe bench/timeout.out $out/bench
    wrapProgram $out/bench/chunkedseq.pbench --prefix PATH ":" ${pkgs.R}/bin \
       --prefix PATH ":" ${pkgs.texlive.combined.scheme-small}/bin \
       --prefix PATH ":" ${gcc}/bin \
       --prefix PATH ":" ${php}/bin \
       --prefix PATH ":" ${pkgs.ipget}/bin \
       --prefix PATH ":" $out/bench \
       --prefix LD_LIBRARY_PATH ":" ${gcc}/lib \
       --prefix LD_LIBRARY_PATH ":" ${gcc}/lib64 \
       --prefix PATH ":" ${sc15-pdfs}/bench \
       --add-flags "-skip make"
    ${doc}
    '';

  meta = {
    description = "A script for building a benchmarking environment for chunkedseq";
    license = "MIT";
    homepage = http://deepsea.inria.fr/chunkedseq;
  };
}
