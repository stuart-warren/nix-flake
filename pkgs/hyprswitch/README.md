# hyprswitch

A command-line tool to switch between open windows or launch applications on Hyprland.

## Description

`hyprswitch` is a simple tool that allows you to quickly switch to an open application or launch it if it's not already running. It's designed to be used with a hotkey daemon like `sxhkd` to provide a seamless workflow for switching between your most used applications.

## Build and Install

To build and install `hyprswitch`, you'll need to have Go installed. You can then run the following commands:

```bash
go build
sudo mv hyprswitch /usr/local/bin/
```

## Usage

To use `hyprswitch`, simply run it with the name of the application you want to switch to or launch:

```bash
hyprswitch <application-name>
```

For example, to switch to or launch Firefox, you would run:

```bash
hyprswitch firefox
```

## Testing

To run the tests, you can use the following command:

```bash
go test ./hyprland/...
```
