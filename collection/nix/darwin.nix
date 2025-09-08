{ pkgs, config, ... }:
{
    # https://nix-darwin.github.io/nix-darwin/manual/index.html
    system.defaults = {
        dock = {
            # Whether to display the appswitcher on all displays or only the main one. The default is false.
            appswitcher-all-displays = false;

            # Whether to automatically hide and show the dock. The default is false.
            autohide = true;

            # Sets the speed of the autohide delay. E.g.: 0.24
            autohide-delay = 0.1;

            # Sets the speed of the animation when hiding/showing the Dock. E.g.: 1.0
            autohide-time-modifier = 2.0;

            # Whether to hide Dashboard as a Space. The default is false.
            dashboard-in-overlay = true;

            # Enable spring loading for all Dock items. The default is false.
            enable-spring-load-actions-on-all-items = false;

            # Sets the speed of the Mission Control animations. E.g.: 1.0
            expose-animation-duration = null;

            # Whether to group windows by application in Mission Control’s Exposé. The default is true.
            expose-group-apps = null;

            # Magnified icon size on hover. The default is 16.
            largesize = 64;

            # Animate opening applications from the Dock. The default is true.
            launchanim = true;

            # Magnify icon on hover. The default is false.
            magnification = true;

            # Set the minimize/maximize window effect. The default is genie.
            mineffect = null; # “genie”, “suck”, “scale”

            # Whether to minimize windows into their application icon. The default is false.
            minimize-to-application = null;

            # Enable highlight hover effect for the grid view of a stack in the Dock.
            mouse-over-hilite-stack = null;

            # Whether to automatically rearrange spaces based on most recent use. The default is true
            mru-spaces = false;

            # Position of the dock on screen. The default is “bottom”.
            orientation = "left"; # “bottom”, “left”, “right”

            # Persistent applications in the dock.
            persistent-apps = null;
            # persistent-apps = [
            #   "/Applications/Safari.app"
            # ];

            # Persistent folders in the dock.
            persistent-others = null;
            # persistent-others = [
            #   "~/Downloads"
            # ];

            # Show indicator lights for open applications in the Dock. The default is true.
            show-process-indicators = true;

            # Show recent applications in the dock. The default is true.
            show-recents = false;

            # Whether to make icons of hidden applications translucent. The default is false.
            showhidden = false;

            # Allow for slow-motion minimize effect while holding Shift key. The default is false.
            slow-motion-allowed = false;

            # Show only open applications in the Dock. The default is false.
            static-only = false;

            # Size of the icons in the dock. The default is 64.
            tilesize = 24;

            # Hot corner action for [yx] corner. Valid values include:
            # 1 = Disabled
            wvous-bl-corner = 1;
            wvous-br-corner = 1;
            wvous-tl-corner = 1;
            wvous-tr-corner = 1;
        };
        finder = {
            AppleShowAllExtensions = true;

            # Change the default finder view.
            # “icnv” = Icon view, “Nlsv” = List view, “clmv” = Column View, “Flwv” = Gallery View
            FXPreferredViewStyle = "clmv";

            # Change the default folder shown in Finder windows.
            # “Computer”, “OS volume”, “Home”, “Desktop”, “Documents”, “Recents”, “iCloud Drive”, “Other”
            NewWindowTarget = "Home";

            # Sets the URI to open when NewWindowTarget is “Other”
            NewWindowTargetPath = null;

            # Whether to allow quitting of the Finder. The default is false.
            QuitMenuItem = true;

            # Show path breadcrumbs in finder windows. The default is false.
            ShowPathbar = true;

            # Show status bar at bottom of finder windows with item/disk space stats. The default is false.
            ShowStatusBar = true;

            # Whether to show the full POSIX filepath in the window title. The default is false.
            _FXShowPosixPathInTitle = true;

            # Keep folders on top when sorting by name. The default is false.
            _FXSortFoldersFirst = true;
        };
        loginwindow = {
            # Disables the ability for a user to access the console by typing “>console” for a username at the login window. Default is false.
            DisableConsoleAccess = false;

            # Allow users to login to the machine as guests using the Guest account. Default is true.
            GuestEnabled = false;

            # Text to be shown on the login window. Default is “\\U03bb”.
            LoginwindowText = "F*** off!";
        };
        menuExtraClock = {
            # Show a 24-hour clock, instead of a 12-hour clock. Default is null.
            Show24Hour = true;

            # Show the AM/PM label. Useful if Show24Hour is false. Default is null.
            ShowAMPM = false;

            # Show the clock with second precision, instead of minutes. Default is null.
            ShowSeconds = true;

            # Show the full date. Default is null.
            ShowDate = 2; # 0 = When space allows 1 = Always 2 = Never
        };
        WindowManager = {
            # Click wallpaper to reveal desktop Clicking your wallpaper will move all windows out of the way to allow access to your desktop items and widgets. Default is true. false means “Only in Stage Manager” true means “Always”
            EnableStandardClickToShowDesktop = false;
        };
        spaces = {
            # Displays have separate Spaces (note a logout is required before this setting will take effect).
            # false = each physical display has a separate space (Mac default)
            # true = one space spans across all physical displays
            spans-displays = false;
        };
        NSGlobalDomain = {
            # Whether to enable the press-and-hold feature. The default is true.
            ApplePressAndHoldEnabled = false;

            # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
            # For example, the Delete key continues to remove text for as long as you hold it down.
            # This sets how long you must hold down the key before it starts repeating.
            # Long = 120, Short = 15.
            InitialKeyRepeat = 12;

            # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
            # For example, the Delete key continues to remove text for as long as you hold it down.
            # Slow = 120, Fast = 2.
            KeyRepeat = 2;

            # Configures the trackpad tap behavior. Mode 1 enables tap to click. The default is null
            "com.apple.mouse.tapBehavior" = 1;

            # Whether to enable trackpad force click. The default is null
            "com.apple.trackpad.forceClick" = false;
        };
        trackpad = {
            # Whether to enable trackpad tap to click. The default is false.
            Clicking = true;

            # Whether to enable three finger drag. The default is false.
            TrackpadThreeFingerDrag = true;
        };
    };
    system.keyboard = {
        # Whether to enable keyboard mappings.
        enableKeyMapping = true;

        # Whether to remap the Caps Lock key to Escape.
        remapCapsLockToEscape = true;
    };
}