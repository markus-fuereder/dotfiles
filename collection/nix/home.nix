{ config, pkgs, lib, vars, ... }:
{
  # Home Manager =======================================================================================================
  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.11";
    username = "${vars.username}";
    homeDirectory = "/Users/${vars.username}";
    packages = with pkgs; [
      claude-code
    ];

    sessionPath = [
      "$HOME/.local/bin"
    ];
    file.".local/bin/claude".source = "${pkgs.claude-code}/bin/claude";
  };

  # ZSH ================================================================================================================
  #! Keep this, otherwise home-manager will not create the ~/.zshrc file and programs like vscode will not source it.
  programs.zsh = {
    enable = true;
  };

  # VSCode =============================================================================================================
  programs.vscode = {
    enable = true;
  };
}