{
  description = "Macos nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url ="github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
          pkgs.btop
          pkgs.yazi
	  pkgs.git
	  pkgs.wget
	  pkgs.curl
	  pkgs.ffmpeg
	  pkgs.tmux
	  pkgs.keepassxc
	  pkgs.android-tools
	  pkgs.gimp
          pkgs.pandoc
          pkgs.alacritty
          pkgs.fzf
          pkgs.proxmark3
       ];
      homebrew = {
        enable = true;
	casks = [
        "libreoffice-still"
	"libreoffice-still-language-pack"
	"firefox"
	"thunderbird"
	"orcaslicer"
	"joplin"
	"vlc"
        "freecad"
        "docker"
        "font-hack-nerd-font"
	];
        brews = [
        "starship"
        ];
	onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
	onActivation.upgrade = true;
      };
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      
system.defaults = {
  dock.autohide = true;
  dock.mru-spaces = false;
  finder.AppleShowAllExtensions = true;
  finder.FXPreferredViewStyle = "icnv";
  loginwindow.LoginwindowText = "megaplexx.local";
  screencapture.location = "~/Pictures/screenshots";
  screensaver.askForPasswordDelay = 10;

  CustomUserPreferences = {
   NSGlobalDomain = {
        # Add a context menu item for showing the Web Inspector in web views
        WebKitDeveloperExtras = true;
      };
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.screensaver" = {
        # Require password immediately after sleep or screen saver begins
        askForPassword = 1;
        askForPasswordDelay = 0;
      };
      "com.apple.screencapture" = {
        location = "~/Desktop";
        type = "png";
      };
   };
  
};




      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nix.extraOptions = ''
                         extra-platforms = x86_64-darwin aarch64-darwin aarch64-linux
                         '';
      nix.linux-builder.enable = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
      modules = [ 
      configuration 
      nix-homebrew.darwinModules.nix-homebrew
      {
      nix-homebrew = {
       enable = true;
       enableRosetta = true;
       user = "ot";
       autoMigrate = true; 
      };
      }
      ];
    };
  };
}
