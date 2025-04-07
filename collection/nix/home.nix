{ config, pkgs, lib, vars, ... }:
{
  # Home Manager =======================================================================================================
  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.11";
    username = "${vars.username}";
    homeDirectory = "/Users/${vars.username}";
    packages = with pkgs; [
    ];
  };

  # git ==============================================================================================================
  # programs.git = {
  #     enable = true;
  #     userName = "Markus Füreder";
  #     userEmail = "markus.fuereder@gmail.com";
  #     ignores = [
  #         ".DS_Store"
  #         ".next"
  #         ".node_modules"
  #     ];
  #     extraConfig = {
  #         init.defaultBranch = "main";
  #     };
  # };

  programs.vscode = {
    enable = true;
    # extensions = with pkgs.vscode-marketplace; [
    #   monokai.theme-monokai-pro-vscode
    # ];
  };

  # programs.fzf = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };
  # programs.zoxide = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };
  # programs.tmux = {
  #   enable = true;
  #   clock24 = true;
  #   keyMode = "vi";
  #   prefix = "C-a";
  #   historyLimit = 5000;
  #   terminal = "screen-256color";
  #   extraConfig = lib.fileContents ./dotfiles/tmux.conf;
  # };
  
}