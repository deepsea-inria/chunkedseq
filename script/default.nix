{ pkgs   ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  chunkedseqSrc ? ../.,
  buildDocs ? false
}:

stdenv.mkDerivation rec {
  name = "chunkedseq";

  src = chunkedseqSrc;

  buildInputs =
    if buildDocs then
      let pandocTypes = pkgs.haskellPackages.ghcWithPackages (pkgs: with pkgs; [pandoc-types]);
      in
      [ pkgs.pandoc pandocTypes pkgs.texlive.combined.scheme-small ]
    else
      [];

  buildPhase = if buildDocs then ''
      make -C doc chunkedseq.pdf chunkedseq.html
    '' else "";

  installPhase =
    let doc =
      if buildDocs then ''
        mkdir -p $out/doc/
        cp doc/chunkedseq.pdf doc/chunkedseq.md doc/chunkedseq.html doc/chunkedseq.css $out/doc/
      ''
      else "";
    in
    ''
    mkdir -p $out/include/
    cp include/*.hpp $out/include
    ${doc}
    '';

  meta = {
    description = "A container data structure for representing sequences by many fixed-capacity heap-allocated buffers (i.e., chunks).";
    license = "MIT";
    homepage = http://deepsea.inria.fr/chunkedseq;
  };
}