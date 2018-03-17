{ pkgs   ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  fetchurl,
  buildDocs ? false
}:

stdenv.mkDerivation rec {
  name = "chunkedseq-${version}";
  version = "0.1";

  src = fetchurl {
    url = "https://github.com/deepsea-inria/chunkedseq/archive/v${version}.tar.gz";
    sha256 = "f6bea1d30a0e66c2a1b9a65891ce4013b2c8a73fd33c981fe217d06a3f14dfba";
  };

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