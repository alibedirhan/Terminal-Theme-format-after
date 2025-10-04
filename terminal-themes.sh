#!/bin/bash

# ============================================================================
# Terminal Setup - Tema Tanımları
# v3.1.0 - Themes Module
# ============================================================================

# ============================================================================
# GNOME TERMINAL TEMA UYGULAMA FONKSİYONLARI
# ============================================================================

apply_dracula_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Dracula" 2>/dev/null
    gsettings set "$path" background-color '#282A36' 2>/dev/null
    gsettings set "$path" foreground-color '#F8F8F2' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#000000', '#FF5555', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF79C6', '#8BE9FD', '#BFBFBF', '#4D4D4D', '#FF6E67', '#5AF78E', '#F4F99D', '#CAA9FA', '#FF92D0', '#9AEDFE', '#E6E6E6']" 2>/dev/null
    log_success "Dracula teması uygulandı"
}

apply_nord_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Nord" 2>/dev/null
    gsettings set "$path" background-color '#2E3440' 2>/dev/null
    gsettings set "$path" foreground-color '#D8DEE9' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#3B4252', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#88C0D0', '#E5E9F0', '#4C566A', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#8FBCBB', '#ECEFF4']" 2>/dev/null
    log_success "Nord teması uygulandı"
}

apply_gruvbox_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Gruvbox Dark" 2>/dev/null
    gsettings set "$path" background-color '#282828' 2>/dev/null
    gsettings set "$path" foreground-color '#EBDBB2' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#282828', '#CC241D', '#98971A', '#D79921', '#458588', '#B16286', '#689D6A', '#A89984', '#928374', '#FB4934', '#B8BB26', '#FABD2F', '#83A598', '#D3869B', '#8EC07C', '#EBDBB2']" 2>/dev/null
    log_success "Gruvbox teması uygulandı"
}

apply_tokyo_night_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Tokyo Night" 2>/dev/null
    gsettings set "$path" background-color '#1A1B26' 2>/dev/null
    gsettings set "$path" foreground-color '#C0CAF5' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#15161E', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#A9B1D6', '#414868', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#C0CAF5']" 2>/dev/null
    log_success "Tokyo Night teması uygulandı"
}

apply_catppuccin_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Catppuccin Mocha" 2>/dev/null
    gsettings set "$path" background-color '#1E1E2E' 2>/dev/null
    gsettings set "$path" foreground-color '#CDD6F4' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#45475A', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#BAC2DE', '#585B70', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#A6ADC8']" 2>/dev/null
    log_success "Catppuccin teması uygulandı"
}

apply_one_dark_gnome() {
    local path=$1
    gsettings set "$path" visible-name "One Dark" 2>/dev/null
    gsettings set "$path" background-color '#282C34' 2>/dev/null
    gsettings set "$path" foreground-color '#ABB2BF' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#282C34', '#E06C75', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#E06C75', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#FFFFFF']" 2>/dev/null
    log_success "One Dark teması uygulandı"
}

apply_solarized_gnome() {
    local path=$1
    gsettings set "$path" visible-name "Solarized Dark" 2>/dev/null
    gsettings set "$path" background-color '#002B36' 2>/dev/null
    gsettings set "$path" foreground-color '#839496' 2>/dev/null
    gsettings set "$path" use-theme-colors false 2>/dev/null
    gsettings set "$path" palette "['#073642', '#DC322F', '#859900', '#B58900', '#268BD2', '#D33682', '#2AA198', '#EEE8D5', '#002B36', '#CB4B16', '#586E75', '#657B83', '#839496', '#6C71C4', '#93A1A1', '#FDF6E3']" 2>/dev/null
    log_success "Solarized Dark teması uygulandı"
}

# ============================================================================
# KITTY TEMA KONFIGÜRASYONLARI
# ============================================================================

get_kitty_theme_dracula() {
    cat << 'EOF'
foreground #f8f8f2
background #282a36
selection_foreground #ffffff
selection_background #44475a
color0  #21222c
color1  #ff5555
color2  #50fa7b
color3  #f1fa8c
color4  #bd93f9
color5  #ff79c6
color6  #8be9fd
color7  #f8f8f2
color8  #6272a4
color9  #ff6e6e
color10 #69ff94
color11 #ffffa5
color12 #d6acff
color13 #ff92df
color14 #a4ffff
color15 #ffffff
EOF
}

get_kitty_theme_nord() {
    cat << 'EOF'
foreground #d8dee9
background #2e3440
selection_foreground #000000
selection_background #fffacd
color0  #3b4252
color1  #bf616a
color2  #a3be8c
color3  #ebcb8b
color4  #81a1c1
color5  #b48ead
color6  #88c0d0
color7  #e5e9f0
color8  #4c566a
color9  #bf616a
color10 #a3be8c
color11 #ebcb8b
color12 #81a1c1
color13 #b48ead
color14 #8fbcbb
color15 #eceff4
EOF
}

get_kitty_theme_gruvbox() {
    cat << 'EOF'
foreground #ebdbb2
background #282828
selection_foreground #928374
selection_background #ebdbb2
color0  #282828
color1  #cc241d
color2  #98971a
color3  #d79921
color4  #458588
color5  #b16286
color6  #689d6a
color7  #a89984
color8  #928374
color9  #fb4934
color10 #b8bb26
color11 #fabd2f
color12 #83a598
color13 #d3869b
color14 #8ec07c
color15 #ebdbb2
EOF
}

get_kitty_theme_tokyo_night() {
    cat << 'EOF'
foreground #c0caf5
background #1a1b26
selection_foreground #c0caf5
selection_background #33467C
color0  #15161E
color1  #f7768e
color2  #9ece6a
color3  #e0af68
color4  #7aa2f7
color5  #bb9af7
color6  #7dcfff
color7  #a9b1d6
color8  #414868
color9  #f7768e
color10 #9ece6a
color11 #e0af68
color12 #7aa2f7
color13 #bb9af7
color14 #7dcfff
color15 #c0caf5
EOF
}

get_kitty_theme_catppuccin() {
    cat << 'EOF'
foreground #cdd6f4
background #1e1e2e
selection_foreground #1e1e2e
selection_background #f5e0dc
color0  #45475a
color1  #f38ba8
color2  #a6e3a1
color3  #f9e2af
color4  #89b4fa
color5  #f5c2e7
color6  #94e2d5
color7  #bac2de
color8  #585b70
color9  #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #f5c2e7
color14 #94e2d5
color15 #a6adc8
EOF
}

get_kitty_theme_one_dark() {
    cat << 'EOF'
foreground #abb2bf
background #282c34
selection_foreground #282c34
selection_background #abb2bf
color0  #282c34
color1  #e06c75
color2  #98c379
color3  #e5c07b
color4  #61afef
color5  #c678dd
color6  #56b6c2
color7  #abb2bf
color8  #5c6370
color9  #e06c75
color10 #98c379
color11 #e5c07b
color12 #61afef
color13 #c678dd
color14 #56b6c2
color15 #ffffff
EOF
}

get_kitty_theme_solarized() {
    cat << 'EOF'
foreground #839496
background #002b36
selection_foreground #93a1a1
selection_background #073642
color0  #073642
color1  #dc322f
color2  #859900
color3  #b58900
color4  #268bd2
color5  #d33682
color6  #2aa198
color7  #eee8d5
color8  #002b36
color9  #cb4b16
color10 #586e75
color11 #657b83
color12 #839496
color13 #6c71c4
color14 #93a1a1
color15 #fdf6e3
EOF
}

# ============================================================================
# ALACRITTY TEMA KONFIGÜRASYONLARI
# ============================================================================

get_alacritty_theme_dracula() {
    cat << 'EOF'
colors:
  primary:
    background: '#282a36'
    foreground: '#f8f8f2'
  normal:
    black:   '#000000'
    red:     '#ff5555'
    green:   '#50fa7b'
    yellow:  '#f1fa8c'
    blue:    '#bd93f9'
    magenta: '#ff79c6'
    cyan:    '#8be9fd'
    white:   '#bfbfbf'
  bright:
    black:   '#4d4d4d'
    red:     '#ff6e67'
    green:   '#5af78e'
    yellow:  '#f4f99d'
    blue:    '#caa9fa'
    magenta: '#ff92d0'
    cyan:    '#9aedfe'
    white:   '#e6e6e6'
EOF
}

get_alacritty_theme_nord() {
    cat << 'EOF'
colors:
  primary:
    background: '#2e3440'
    foreground: '#d8dee9'
  normal:
    black:   '#3b4252'
    red:     '#bf616a'
    green:   '#a3be8c'
    yellow:  '#ebcb8b'
    blue:    '#81a1c1'
    magenta: '#b48ead'
    cyan:    '#88c0d0'
    white:   '#e5e9f0'
  bright:
    black:   '#4c566a'
    red:     '#bf616a'
    green:   '#a3be8c'
    yellow:  '#ebcb8b'
    blue:    '#81a1c1'
    magenta: '#b48ead'
    cyan:    '#8fbcbb'
    white:   '#eceff4'
EOF
}

get_alacritty_theme_gruvbox() {
    cat << 'EOF'
colors:
  primary:
    background: '#282828'
    foreground: '#ebdbb2'
  normal:
    black:   '#282828'
    red:     '#cc241d'
    green:   '#98971a'
    yellow:  '#d79921'
    blue:    '#458588'
    magenta: '#b16286'
    cyan:    '#689d6a'
    white:   '#a89984'
  bright:
    black:   '#928374'
    red:     '#fb4934'
    green:   '#b8bb26'
    yellow:  '#fabd2f'
    blue:    '#83a598'
    magenta: '#d3869b'
    cyan:    '#8ec07c'
    white:   '#ebdbb2'
EOF
}

get_alacritty_theme_tokyo_night() {
    cat << 'EOF'
colors:
  primary:
    background: '#1a1b26'
    foreground: '#c0caf5'
  normal:
    black:   '#15161e'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#a9b1d6'
  bright:
    black:   '#414868'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#c0caf5'
EOF
}

get_alacritty_theme_catppuccin() {
    cat << 'EOF'
colors:
  primary:
    background: '#1e1e2e'
    foreground: '#cdd6f4'
  normal:
    black:   '#45475a'
    red:     '#f38ba8'
    green:   '#a6e3a1'
    yellow:  '#f9e2af'
    blue:    '#89b4fa'
    magenta: '#f5c2e7'
    cyan:    '#94e2d5'
    white:   '#bac2de'
  bright:
    black:   '#585b70'
    red:     '#f38ba8'
    green:   '#a6e3a1'
    yellow:  '#f9e2af'
    blue:    '#89b4fa'
    magenta: '#f5c2e7'
    cyan:    '#94e2d5'
    white:   '#a6adc8'
EOF
}

get_alacritty_theme_one_dark() {
    cat << 'EOF'
colors:
  primary:
    background: '#282c34'
    foreground: '#abb2bf'
  normal:
    black:   '#282c34'
    red:     '#e06c75'
    green:   '#98c379'
    yellow:  '#e5c07b'
    blue:    '#61afef'
    magenta: '#c678dd'
    cyan:    '#56b6c2'
    white:   '#abb2bf'
  bright:
    black:   '#5c6370'
    red:     '#e06c75'
    green:   '#98c379'
    yellow:  '#e5c07b'
    blue:    '#61afef'
    magenta: '#c678dd'
    cyan:    '#56b6c2'
    white:   '#ffffff'
EOF
}

get_alacritty_theme_solarized() {
    cat << 'EOF'
colors:
  primary:
    background: '#002b36'
    foreground: '#839496'
  normal:
    black:   '#073642'
    red:     '#dc322f'
    green:   '#859900'
    yellow:  '#b58900'
    blue:    '#268bd2'
    magenta: '#d33682'
    cyan:    '#2aa198'
    white:   '#eee8d5'
  bright:
    black:   '#002b36'
    red:     '#cb4b16'
    green:   '#586e75'
    yellow:  '#657b83'
    blue:    '#839496'
    magenta: '#6c71c4'
    cyan:    '#93a1a1'
    white:   '#fdf6e3'
EOF
}

# ============================================================================
# TMUX TEMA KONFIGÜRASYONLARI
# ============================================================================

get_tmux_theme_dracula() {
    cat << 'EOF'
set -g status-style bg='#282a36',fg='#f8f8f2'
set -g window-status-current-style bg='#bd93f9',fg='#282a36'
set -g pane-border-style fg='#6272a4'
set -g pane-active-border-style fg='#ff79c6'
set -g message-style bg='#44475a',fg='#f8f8f2'
EOF
}

get_tmux_theme_nord() {
    cat << 'EOF'
set -g status-style bg='#2e3440',fg='#d8dee9'
set -g window-status-current-style bg='#88c0d0',fg='#2e3440'
set -g pane-border-style fg='#4c566a'
set -g pane-active-border-style fg='#88c0d0'
set -g message-style bg='#3b4252',fg='#d8dee9'
EOF
}

get_tmux_theme_gruvbox() {
    cat << 'EOF'
set -g status-style bg='#282828',fg='#ebdbb2'
set -g window-status-current-style bg='#fabd2f',fg='#282828'
set -g pane-border-style fg='#504945'
set -g pane-active-border-style fg='#fabd2f'
set -g message-style bg='#504945',fg='#ebdbb2'
EOF
}

get_tmux_theme_tokyo_night() {
    cat << 'EOF'
set -g status-style bg='#1a1b26',fg='#c0caf5'
set -g window-status-current-style bg='#7aa2f7',fg='#1a1b26'
set -g pane-border-style fg='#414868'
set -g pane-active-border-style fg='#7aa2f7'
set -g message-style bg='#414868',fg='#c0caf5'
EOF
}

get_tmux_theme_catppuccin() {
    cat << 'EOF'
set -g status-style bg='#1e1e2e',fg='#cdd6f4'
set -g window-status-current-style bg='#89b4fa',fg='#1e1e2e'
set -g pane-border-style fg='#45475a'
set -g pane-active-border-style fg='#89b4fa'
set -g message-style bg='#45475a',fg='#cdd6f4'
EOF
}

get_tmux_theme_one_dark() {
    cat << 'EOF'
set -g status-style bg='#282c34',fg='#abb2bf'
set -g window-status-current-style bg='#61afef',fg='#282c34'
set -g pane-border-style fg='#5c6370'
set -g pane-active-border-style fg='#61afef'
set -g message-style bg='#3e4451',fg='#abb2bf'
EOF
}

get_tmux_theme_solarized() {
    cat << 'EOF'
set -g status-style bg='#002b36',fg='#839496'
set -g window-status-current-style bg='#268bd2',fg='#fdf6e3'
set -g pane-border-style fg='#073642'
set -g pane-active-border-style fg='#268bd2'
set -g message-style bg='#073642',fg='#839496'
EOF
}
