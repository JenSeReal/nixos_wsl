{delib, ...}:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "jfp");
    userfullname = readOnly (strOption "Jens Plüddemann");
    useremail = readOnly (strOption "Jens.Plueddemann-extern@deutschebahn.com");
  };
}
