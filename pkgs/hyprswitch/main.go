package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/stuart-warren/nix-flake/pkgs/hyprswitch/hyprland"
)

var desktopEntryDirs = []string{
	"~/.local/share/applications/",
	"~/.nix-profile/share/applications/",
	"/usr/share/applications/",
}

func getDesktopEntryDirs() []string {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		homeDir = os.Getenv("HOME")
	}
	var dirs []string
	for _, d := range desktopEntryDirs {
		d = strings.Replace(d, "~", homeDir, 1)
		info, err := os.Stat(d)
		if err != nil {
			continue
		}
		if info.IsDir() {
			dirs = append(dirs, d)
		}
	}
	return dirs
}

func main() {
	hyprctl := &hyprland.HyprctlImpl{}
	desktopEntryProvider := &hyprland.DesktopEntryProviderImpl{Dirs: getDesktopEntryDirs()}
	if err := hyprland.Run(hyprctl, desktopEntryProvider, os.Args); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
