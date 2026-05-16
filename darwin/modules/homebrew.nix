{ username, ... }:

{
  homebrew = {
    enable = true;
    user = username;

    onActivation = {
      autoUpdate = true;
      cleanup = "check";
      upgrade = true;
    };

    casks = [
      "gimp"
      "krita"
    ];
  };
}
