{ pkgs   ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  chunkedseqSrc ? ../.,
  buildDocs ? false
}:

stdenv.mkDerivation rec {
  name = "chunkedseq";

  src = chunkedseqSrc;

  buildInputs = if buildDocs then [ pkgs.pandoc ] else [];

  buildPhase = if buildDocs then ''
    make -C doc chunkedseq.pdf chunkedseq.html5
  '' else
    null;

  installPhase = ''
    mkdir -p $out/include/
    cp include/*.hpp $out/include
    mkdir -p $out/doc/
    cp doc/*.md doc/*.css doc/*.pdf doc/*.html5 doc/Makefile $out/doc/
  '';

  meta = {
    description = "A container data structure for representing sequences by many fixed-capacity heap-allocated buffers (i.e., chunks).";
    license = "MIT";
    homepage = http://deepsea.inria.fr/chunkedseq;
  };
}