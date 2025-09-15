package hyprland

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/rkoesters/xdg/desktop"
)

type Hyprctl interface {
	Clients() (Clients, error)
	Focus(pid int) error
	Launch(command string) error
}

type HyprctlImpl struct{}

func (h *HyprctlImpl) Clients() (Clients, error) {
	cmd := exec.Command("hyprctl", "clients", "-j")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil, err
	}
	if err := cmd.Start(); err != nil {
		return nil, err
	}
	var clients Clients
	if err := json.NewDecoder(stdout).Decode(&clients); err != nil {
		return nil, err
	}
	return clients, nil
}

func (h *HyprctlImpl) Focus(pid int) error {
	cmd := exec.Command("hyprctl", "dispatch", "focuswindow", fmt.Sprintf("pid:%d", pid))
	return cmd.Run()
}

func (h *HyprctlImpl) Launch(command string) error {
	cmd := exec.Command("hyprctl", "dispatch", "exec", command)
	return cmd.Run()
}

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

func (c *Client) Focus(hyprctl Hyprctl) error {
	return hyprctl.Focus(c.PID)
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

func (cs *Clients) Focus(name string, hyprctl Hyprctl) error {
	subset := cs.Get(name)
	for _, client := range *subset {
		if len(*subset) == 1 || client.FocusHistoryID > 0 {
			return client.Focus(hyprctl)
		}
	}
	return NoWindow
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

func (e *DesktopEntry) OpenIfMatches(name string, hyprctl Hyprctl) error {
	if !e.Is(name) {
		return fmt.Errorf("not correct app")
	}
	if e.Type != desktop.Application {
		return fmt.Errorf("not an app")
	}
	command := cmdRe.ReplaceAllString(e.Exec, "")
	return hyprctl.Launch(command)
}

type DesktopEntries []DesktopEntry

func (d *DesktopEntries) Open(name string, hyprctl Hyprctl) error {
	for _, entry := range *d {
		if entry.Type != desktop.Application {
			continue
		}

		err := entry.OpenIfMatches(name, hyprctl)
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

type DesktopEntryProvider interface {
	GetDesktopEntries() DesktopEntries
}

type DesktopEntryProviderImpl struct {
	Dirs []string
}

func (p *DesktopEntryProviderImpl) GetDesktopEntries() DesktopEntries {
	entries := DesktopEntries{}
	for _, dir := range p.Dirs {
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

func Run(hyprctl Hyprctl, desktopEntryProvider DesktopEntryProvider, args []string) error {
	if len(args) < 2 {
		return fmt.Errorf("no app specified")
	}
	clients, err := hyprctl.Clients()
	if err != nil {
		return err
	}
	apps := desktopEntryProvider.GetDesktopEntries()
	start := args[1]
	err = clients.Focus(start, hyprctl)
	if err != nil {
		if err == NoWindow {
			apperr := apps.Open(start, hyprctl)
			if apperr != nil {
				return apperr
			}
		} else {
			return err
		}
	}
	return nil
}
