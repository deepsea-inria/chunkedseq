with import <nixpkgs> {};

with builtins;
with lib;

let sanitiseName = stringAsChars (c: if elem c (lowerChars ++ upperChars)
                                    then c else "");
                                    
fetchGitHashless = args: stdenv.lib.overrideDerivation
  # Use a dummy hash, to appease fetchgit's assertions
    (fetchgit (args // { sha256 = hashString "sha256" args.url; }))

      # Remove the hash-checking
        (old: {
         outputHash     = null;
         outputHashAlgo = null;
         outputHashMode = null;
         sha256         = null;
         });

# Get the commit ID for the given ref in the given repo
latestGitCommit = { url, ref ? "HEAD" }:
  runCommand "repo-${sanitiseName ref}-${sanitiseName url}"
    {
      # Avoids caching. This is a cheap operation and needs to be up-to-date
      version = toString currentTime;

      # Required for SSL
      GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";

      buildInputs = [ git gnused ];
    }
    ''
      REV=$(git ls-remote "${url}" "${ref}") || exit 1

      printf '"%s"' $(echo "$REV"        |
                      head -n1           |
                      sed -e 's/\s.*//g' ) > "$out"
    '';

fetchLatestGit = { url, ref ? "HEAD" }@args:
  with { rev = import (latestGitCommit { inherit url ref; }); };
  fetchGitHashless (removeAttrs (args // { inherit rev; }) [ "ref" ]);
  
in

{

  cmdlineSrc = fetchLatestGit {
    url = "https://github.com/deepsea-inria/cmdline.git";
  };

  pbenchSrc = fetchLatestGit {
    url = "https://github.com/deepsea-inria/pbench.git";
  };

  chunkedseqSrc = fetchLatestGit {
    url = "https://github.com/deepsea-inria/chunkedseq.git";
  };

  sc15pdfs = fetchLatestGit {
    url = "https://github.com/deepsea-inria/sc15-pdfs.git";
  };

}
