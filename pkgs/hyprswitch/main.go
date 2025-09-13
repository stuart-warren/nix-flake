package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/rkoesters/xdg/desktop"
)

type Workspace struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Client struct {
	Address        string    `json:"address"`
	Mapped         bool      `json:"mapped"`
	Hidden         bool      `json:"hidden"`
	At             []int     `json:"at"`
	Size           []int     `json:"size"`
	Workspace      Workspace `json:"workspace"`
	Floating       bool      `json:"floating"`
	Pseudo         bool      `json:"pseudo"`
	Monitor        int       `json:"monitor"`
	Class          string    `json:"class"`
	Title          string    `json:"title"`
	InitialClass   string    `json:"initialClass"`
	InitialTitle   string    `json:"initialTitle"`
	PID            int       `json:"pid"`
	Xwayland       bool      `json:"xwayland"`
	Pinned         bool      `json:"pinned"`
	Fullscreen     int       `json:"fullscreen"`
	FocusHistoryID int       `json:"focusHistoryID"`
}

func (c *Client) Contains(name string) bool {
	if strings.Contains(c.Class, name) {
		return true
	}
	if strings.Contains(c.InitialTitle, name) {
		return true
	}
	return false
}

func (c *Client) Focus() error {
	cmd := exec.Command("hyprctl", "dispatch", "focuswindow", fmt.Sprintf("pid:%d", c.PID))
	return cmd.Run()
}

type Clients []Client

func (cs *Clients) Get(name string) *Clients {
	subset := Clients{}
	for _, c := range *cs {
		if c.Contains(name) {
			subset = append(subset, c)
		}
	}
	return &subset
}

var NoWindow = errors.New("No Window Matches")

func (cs *Clients) Focus(name string) error {
	subset := cs.Get(name)
	for _, client := range *subset {
		if len(*subset) == 1 || client.FocusHistoryID > 0 {
			return client.Focus()
		}
	}
	return NoWindow
}

func getClients() Clients {
	cmd := exec.Command("hyprctl", "clients", "-j")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatal(err)
	}
	if err := cmd.Start(); err != nil {
		log.Fatal(err)
	}
	var clients Clients
	if err := json.NewDecoder(stdout).Decode(&clients); err != nil {
		log.Fatal(err)
	}
	return clients
}

type DesktopEntry struct {
	*desktop.Entry
}

func (e *DesktopEntry) Is(name string) bool {
	return strings.Contains(fmt.Sprintf("%s %s %s", e.Name, e.GenericName, e.Exec), name)
}

// aim to remove any exec variables
// https://specifications.freedesktop.org/desktop-entry-spec/latest/exec-variables.html
var cmdRe = regexp.MustCompile(` %[fuFU]`)

func (e *DesktopEntry) OpenIfMatches(name string) error {
	if !e.Is(name) {
		return fmt.Errorf("not correct app")
	}
	if e.Type != desktop.Application {
		return fmt.Errorf("not an app")
	}
	command := cmdRe.ReplaceAllString(e.Exec, "")
	cmd := exec.Command("hyprctl", "dispatch", "exec", command)
	return cmd.Run()
}

var DesktopEntryDirs = []string{
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
	for _, d := range DesktopEntryDirs {
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

type DesktopEntries []DesktopEntry

func (d *DesktopEntries) Open(name string) error {
	for _, entry := range *d {
		if entry.Type != desktop.Application {
			continue
		}

		err := entry.OpenIfMatches(name)
		if err == nil {
			return nil
		}
	}
	return fmt.Errorf("No Application")
}

func parseDesktopEntry(path string) (DesktopEntry, error) {

	var content DesktopEntry
	f, err := os.Open(path)
	if err != nil {
		return content, fmt.Errorf("Open file failed: %w", err)
	}
	defer f.Close()
	entry, err := desktop.New(f)
	if err != nil {
		return content, fmt.Errorf("Parse Desktop file failed: %w", err)
	}
	return DesktopEntry{entry}, nil
}

func getDesktopEntries() DesktopEntries {
	dirs := getDesktopEntryDirs()
	entries := DesktopEntries{}
	for _, dir := range dirs {
		desktopFiles, _ := filepath.Glob(fmt.Sprintf("%s/*.desktop", dir))
		if desktopFiles == nil {
			continue
		}
		for _, desktopFile := range desktopFiles {
			content, err := parseDesktopEntry(desktopFile)
			if err != nil {
				continue
			}
			entries = append(entries, content)
		}
	}
	return entries
}

func main() {
	clients := getClients()
	apps := getDesktopEntries()
	flag.Parse()
	exitCode := 0
	start := flag.Arg(0)
	err := clients.Focus(start)
	if err != nil {
		if err != NoWindow {
			exitCode = 1
			log.Print(err)
		}
		if err == NoWindow {
			apperr := apps.Open(start)
			if apperr != nil {
				exitCode = 1
				log.Print(err)
			}
		}
	}
	os.Exit(exitCode)
}
