{ config, pkgs, me, ... }: {

  home = {
    sessionPath =
      [ "$HOME/go/bin" "$HOME/.local/bin" "$HOME/.nix-profile/bin" ];

  };
  fonts.fontconfig.enable = true;
  programs = {
    fzf.enable = true;
    jq.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      userName = me.githubUsername;
      userEmail = me.githubEmail;
      # includes = [{
      #   contents = {
      #     # user.signingkey = "~/.ssh/id_rsa.pub";
      #     # gpg.format = "ssh";
      #     # commit.gpgSign = true;
      #   };
      # }];
    };
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      # useTheme = "catppuccin";
      # based on https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/catppuccin.omp.json
      # updated git segment
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext ''
        {
          "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
          "palette": {
                "os": "#ACB0BE",
                "pink": "#F5BDE6",
                "lavender": "#B7BDF8",
                "blue":  "#8AADF4",
                "wight": "#FFFFFF",
                "text": "#494D64"
          },
          "blocks": [
            {
              "alignment": "left",
              "segments": [
                {
                  "background": "p:blue",
                  "foreground": "p:wight",
                  "powerline_symbol": "\ue0b4",
                  "leading_diamond": "\ue0b6",
                  "style": "diamond",
                  "template": "{{.Icon}} ",
                  "type": "os"
                },
                {
                  "background": "p:blue",
                  "foreground": "p:text",
                  "powerline_symbol": "\ue0b4",
                  "style": "diamond",
                  "template": "{{ .UserName }}@{{ .HostName }}",
                  "type": "session"
                },
                {
                  "background": "p:pink",
                  "foreground": "p:text",
                  "properties": {
                    "folder_icon": "..\ue5fe..",
                    "home_icon": "~",
                    "style": "agnoster_short"
                  },
                  "powerline_symbol": "\ue0b4",
                  "style": "powerline",
                  "template": " {{ .Path }}",
                  "type": "path"
                },
                {
                  "background": "p:blue",
                  "foreground": "p:text",
                  "powerline_symbol": "\ue0b4",
                  "style": "powerline",
                  "template": "{{ with .Env.IN_NIX_SHELL}} 󱄅 {{end}}",
                  "type": "text"
                },
                {
                  "background": "p:lavender",
                  "background_templates": [
                    "{{ if or (.Working.Changed) (.Staging.Changed) }}#FFEB3B{{ end }}",
                    "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#FFCC80{{ end }}",
                    "{{ if gt .Ahead 0 }}#B388FF{{ end }}",
                    "{{ if gt .Behind 0 }}#B388FB{{ end }}"
                  ],
                  "foreground": "p:text",
                  "style": "powerline",
                  "properties": {
                    "branch_icon": "\ue725 ",
                    "cherry_pick_icon": "\ue29b ",
                    "commit_icon": "\uf417 ",
                    "fetch_status": true,
                    "fetch_upstream_icon": true,
                    "fetch_stash_count": true,
                    "merge_icon": "\ue727 ",
                    "no_commits_icon": "\uf0c3 ",
                    "rebase_icon": "\ue728 ",
                    "revert_icon": "\uf0e2 ",
                    "tag_icon": "\uf412 "
                  },
                  "powerline_symbol": "\ue0b4",
                  "template": " {{ .UpstreamIcon }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }}",
                  "type": "git"
                }
              ],
              "type": "prompt"
            }
          ],
          "final_space": true,
          "version": 2
        }
      '');
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      newSession = true;
      escapeTime = 10;
      terminal = "screen-256color";
      plugins = with pkgs; [
        { plugin = tmuxPlugins.vim-tmux-navigator; }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set-option -sa terminal-overrides ",xterm*:Tc"
            set -g @catppuccin_flavour 'mocha' # or latte, frappe, macchiato, mocha
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
            set -g @catppuccin_datetime_icon "󰔠"
            set -g window-style 'bg=#11111b,fg=#585b70' # dimmer colors for inactive panes
            set -g window-active-style 'bg=#1e1e2e,fg=#cdd6f4' # normal colors for active pane
          '';
        }
        {
          plugin = tmuxPlugins.yank;
          extraConfig = ''
            # wayland
            set -g @override_copy_command "${wl-clipboard}/bin/wl-copy"
            set -g @yank_selection_mouse "clipboard"
            set -g @yank_selection "clipboard"
            set -g @yank_action "copy-pipe"
            set -g @yank_with_mouse on
          '';
        }
      ];
      prefix = "C-Space";
      shortcut = "Space";
      extraConfig = ''
        # # keybindings
        # bind-key -T copy-mode-vi v send-keys -X begin-selection
        # bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        # bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        # execute sessionizer
        bind-key -r p run-shell "tmux neww -n sessionizer ${pkgs.sessionizer}/bin/sessionizer"
        bind-key -r h run-shell "tmux neww -n sessionizer ${pkgs.sessionizer}/bin/sessionizer stuart"
        # send input to all panes
        bind C-s set-window-option synchronize-panes
        # nicer split commands
        bind c new-window -c "#{pane_current_path}"
        bind _ split-window -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        # reload config: <prefix> r
        bind r source-file ~/.config/tmux/tmux.conf\;
        display "Reloaded config!"
      '';
    };
    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    zsh = {
      enable = true;
      # enableAutosuggestions = true;
      autosuggestion.enable = true;
      defaultKeymap = "viins";
      autocd = true;
      history = {
        extended = true;
        ignoreSpace = true;
        share = true;
      };
      localVariables = { GITROOT = "$HOME/src"; };
      initContent = ''
        clone() {
          repo="''${1}"
          d="''${repo#'https://'}"
          d="''${d#'git@'}"
          d="''${d%'.git'}"
          d="''${d//://}"
          git clone "''${repo}" "''${GITROOT}/''${d}" || true
          pushd "''${GITROOT}/''${d}"
          git fetch $(git rev-parse --abbrev-ref origin/HEAD | tr '/' ' ')
          popd
          ${pkgs.sessionizer}/bin/sessionizer "''${d}"
        }
        nix-init() {
          template=$1
          nix flake init --refresh -t "git+ssh://git@github.com/the-nix-way/dev-templates.git?ref=main#$template"
          direnv allow
        }
      '';
    };
  };
  services.ssh-agent.enable = true;
}
