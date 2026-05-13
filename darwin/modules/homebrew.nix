{ username, ... }:

{
  homebrew = {
    enable = true;
    user = username;

    onActivation = {
      autoUpdate = true;
      cleanup = "none";
      upgrade = true;
    };

    casks = [
      "gimp"
      "krita"
    ];
  };
}
