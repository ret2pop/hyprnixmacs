# [[file:../../config/nix.org::*Lean4-Mode][Lean4-Mode:1]]
{ epkgs, lean4-src }:

epkgs.trivialBuild {
  pname = "lean4-mode";
  version = "pinned";
  src = lean4-src; 
  
  packageRequires = with epkgs; [ 
    lsp-mode 
    magit-section 
    dash 
    f 
    s 
  ]; 
  
  postInstall = ''
    cp -r data $out/share/emacs/site-lisp/
  '';
}
# Lean4-Mode:1 ends here
