package hyprland

import (
	"bytes"
	"errors"
	"testing"

	"github.com/rkoesters/xdg/desktop"
)

type MockHyprctl struct {
	clientsFn func() (Clients, error)
	focusFn   func(pid int) error
	launchFn  func(command string) error
}

func (m *MockHyprctl) Clients() (Clients, error) {
	if m.clientsFn != nil {
		return m.clientsFn()
	}
	return nil, errors.New("clientsFn not set")
}

func (m *MockHyprctl) Focus(pid int) error {
	if m.focusFn != nil {
		return m.focusFn(pid)
	}
	return errors.New("focusFn not set")
}

func (m *MockHyprctl) Launch(command string) error {
	if m.launchFn != nil {
		return m.launchFn(command)
	}
	return errors.New("launchFn not set")
}

type MockDesktopEntryProvider struct {
	getDesktopEntriesFn func() DesktopEntries
}

func (m *MockDesktopEntryProvider) GetDesktopEntries() DesktopEntries {
	if m.getDesktopEntriesFn != nil {
		return m.getDesktopEntriesFn()
	}
	return nil
}

func TestRun(t *testing.T) {
	tests := []struct {
		name                 string
		args                 []string
		hyprctl              *MockHyprctl
		desktopEntryProvider *MockDesktopEntryProvider
		expectedErr          error
		expectedOut          string
		expectedFocus        int
		expectedLaunch       string
	}{
		{
			name: "focus existing window",
			args: []string{"hyprswitch", "test-app"},
			hyprctl: &MockHyprctl{
				clientsFn: func() (Clients, error) {
					return Clients{
						{PID: 123, Class: "test-app"},
					}, nil
				},
			},
			desktopEntryProvider: &MockDesktopEntryProvider{
				getDesktopEntriesFn: func() DesktopEntries {
					return nil
				},
			},
			expectedErr:   nil,
			expectedFocus: 123,
		},
		{
			name: "launch new app",
			args: []string{"hyprswitch", "test-app"},
			hyprctl: &MockHyprctl{
				clientsFn: func() (Clients, error) {
					return Clients{},
						nil
				},
			},
			desktopEntryProvider: &MockDesktopEntryProvider{
				getDesktopEntriesFn: func() DesktopEntries {
					return DesktopEntries{
						{
							Entry: &desktop.Entry{
								Type: desktop.Application,
								Name: "test-app",
								Exec: "test-app",
							},
						},
					}
				},
			},
			expectedErr:    nil,
			expectedLaunch: "test-app",
		},
		{
			name:                 "no app specified",
			args:                 []string{"hyprswitch"},
			hyprctl:              &MockHyprctl{},
			desktopEntryProvider: &MockDesktopEntryProvider{},
			expectedErr:          errors.New("no app specified"),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var focusedPID int
			var launchedCommand string

			hyprctl := tt.hyprctl
			hyprctl.focusFn = func(pid int) error {
				focusedPID = pid
				return nil
			}
			hyprctl.launchFn = func(command string) error {
				launchedCommand = command
				return nil
			}

			err := Run(hyprctl, tt.desktopEntryProvider, tt.args)

			if (err != nil && tt.expectedErr == nil) || (err == nil && tt.expectedErr != nil) || (err != nil && tt.expectedErr != nil && err.Error() != tt.expectedErr.Error()) {
				t.Errorf("expected error %v, got %v", tt.expectedErr, err)
			}

			if tt.expectedFocus != 0 && focusedPID != tt.expectedFocus {
				t.Errorf("expected to focus PID %d, but focused %d", tt.expectedFocus, focusedPID)
			}

			if tt.expectedLaunch != "" && !bytes.Contains([]byte(launchedCommand), []byte(tt.expectedLaunch)) {
				t.Errorf("expected to launch command containing %q, but launched %q", tt.expectedLaunch, launchedCommand)
			}
		})
	}
}

