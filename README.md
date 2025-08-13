# Hyprland Dotfiles

Welcome to my collection of configuration files (dotfiles) for a customized Hyprland desktop environment on Linux. This repository contains my personal setup for a sleek, efficient, and visually appealing workflow using Hyprland and related tools. Feel free to explore, adapt, or use these configurations as inspiration for your own setup!

![Hyprland](https://raw.githubusercontent.com/craigderington/dotfiles/refs/heads/master/backgrounds/.config/backgrounds/hyprshot.png)

## Overview

This repository includes configuration files for the following tools, tailored to create a cohesive and productive desktop experience:

- **Hyprland**: A dynamic tiling Wayland compositor, known for its performance and customization.
- **Hyprpaper**: A wallpaper utility for Hyprland, enabling dynamic and multi-monitor wallpaper support.
- **Hyprlock**: A lightweight lock screen for Hyprland, providing secure and stylish session locking.
- **Hypermocha**: a Hyperland Catppuccin theme.
- **Waybar**: A highly customizable status bar for Wayland, used to display system information and workspace status.
- **Alacritty**: A fast, Rust GPU-accelerated terminal emulator with a clean and minimal configuration.
- **Kitty**: a slick Terminal Emulator with easy customization.
- **Backgrounds**: Hyprpaper backgrounds.
- **Starship**: the coolest terminal prompt on every planet.


These dotfiles reflect my preferences for a minimal yet functional setup, optimized for both productivity and aesthetics.

## Repository Structure

```
dotfiles/
├── hypr/
│   ├── hyprland.conf       # Hyprland compositor settings
│   ├── hyprpaper.conf      # Wallpaper configurations
│   ├── hyprlock.conf       # Lock screen settings
├── waybar/
│   ├── config              # Waybar configuration
│   ├── style.css           # Waybar styling
├── alacritty/
│   ├── alacritty.toml       # Alacritty terminal settings
└── README.md               # This file
```

## Installation

To use these dotfiles, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/craigderington/dotfiles.git ~/dotfiles
   ```

2. **Backup Existing Configurations**:
   Before copying, back up your existing configuration files to avoid accidental overwrites:
   ```bash
   mkdir ~/dotfiles-backup
   mv ~/.config/hypr ~/.config/waybar ~/.config/alacritty ~/dotfiles-backup/
   ```

3. **Stow Configurations**:
   Use [Stow](https://www.gnu.org/software/stow/) to create symlinks to `~/.config/` directory:  Move into the dotfiles directory and stow each config.
   ```bash
   ~/dotfiles $ stow hyprland
   ~/dotfiles $ stow hyprlock
   ~/dotfiles $ stow hyprmocha
   ~/dotfiles $ stow starship
    ```

4. **Install Dependencies**:
   Ensure you have the following packages installed (Arch Linux example):
   ```bash
   sudo dnf hyprland hyprpaper hyprlock waybar alacritty
   ```

6. **Restart Hyprland**:
   Log out and back in, or restart Hyprland to apply the new configurations:
   ```bash
   hyprctl dispatch exit
   ```

## Configuration Highlights

- **Hyprland**: Custom keybindings for window management, workspace switching, and application launching. Includes animations and rounded corners for a modern look.
- **Hyprpaper**: Configured for multi-monitor wallpaper support with dynamic reloading.
- **Hyprlock**: Minimal lock screen with a blurred background and simple password prompt.
- **Waybar**: Displays system stats (CPU, memory, battery), workspace indicators, and a clock, styled with a clean, dark theme.
- **Alacritty**: Optimized for speed with a transparent background and a custom color scheme for readability.

## Customization

Feel free to tweak these configurations to suit your needs:
- Edit `hypr/hyprland.conf` for keybindings and window rules.
- Modify `waybar/style.css` to adjust the bar's appearance.
- Update `alacritty/alacritty.yml` for font and color preferences.

## Contributing

Suggestions and improvements are welcome! If you have ideas or find issues, please:
1. Open an issue on the [GitHub repository](https://github.com/craigderington/dotfiles).
2. Submit a pull request with your changes.

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Hyprland community for their amazing work on the compositor and related tools.
- Inspired by various dotfile repositories shared across the Linux community.
