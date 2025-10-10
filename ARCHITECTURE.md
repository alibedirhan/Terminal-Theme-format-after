# 🏗️ SYSTEM ARCHITECTURE - System Theme Setup v2.0

**Last Updated:** 2025-01-09 (Phase 2 Complete)  
**Version:** 2.1

## 📐 OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│                    system-theme.sh                          │
│                   (Main Entry Point)                        │
└──────────────┬──────────────────────────────────────────────┘
               │
               ├─── core/ (Core System) ✅ COMPLETE
               │    ├─ config.sh      (Global constants)
               │    ├─ logger.sh      (Logging system)
               │    ├─ detection.sh   (System detection)
               │    └─ safety.sh      (Backup & protection)
               │
               ├─── desktop-environments/ (DE Modules) ✅ COMPLETE
               │    ├─ de-gnome.sh    (GNOME - 9 themes)
               │    ├─ de-kde.sh      (KDE - 8 themes)
               │    ├─ de-xfce.sh     (XFCE - 9 themes)
               │    ├─ de-mate.sh     (MATE - 9 themes)
               │    └─ de-cinnamon.sh (Cinnamon - 9 themes)
               │
               ├─── themes/ (Theme Installers) ✅ COMPLETE [NEW]
               │    ├─ theme-arc.sh
               │    ├─ theme-yaru.sh
               │    ├─ theme-pop.sh
               │    ├─ theme-dracula.sh
               │    ├─ theme-nord.sh
               │    ├─ theme-catppuccin.sh
               │    ├─ theme-gruvbox.sh
               │    ├─ theme-tokyonight.sh
               │    └─ theme-cyberpunk.sh
               │
               ├─── data/ (Metadata) ✅ COMPLETE [NEW]
               │    ├─ themes.json        (Theme info)
               │    └─ compatibility.json (DE/Theme matrix)
               │
               ├─── components/ (Component Handlers) ⏳ FUTURE
               │    ├─ component-gtk.sh
               │    ├─ component-icons.sh
               │    ├─ component-cursor.sh
               │    ├─ component-shell.sh
               │    └─ component-wallpaper.sh
               │
               ├─── utils/ (Utilities) ✅ COMPLETE
               │    ├─ theme-utils.sh     (Common functions)
               │    └─ theme-assistant.sh (AI-like helper)
               │
               └─── backup/ (Auto-generated backups)
                    └─ system_backup_YYYYMMDD_HHMMSS/
```

---

## 🔄 EXECUTION FLOW

### 1. Initialization Phase
```
system-theme.sh starts
    ↓
Load core/config.sh (constants, paths, colors)
    ↓
Load core/logger.sh (initialize logging)
    ↓
Load core/detection.sh (detect DE, OS, ZSH)
    ↓
Load core/safety.sh (check dependencies)
    ↓
Display banner + system info
    ↓
Create backup directories
```

### 2. Main Menu Phase
```
Show main menu
    ↓
User selects option
    ↓
Route to appropriate function:
    ├─ Theme Selection → show_theme_selection()
    ├─ Previews → show_theme_previews()
    ├─ Compatibility → run_compatibility_check()
    ├─ Reset → reset_to_default()
    └─ Help → show_help_menu()
```

### 3. Theme Application Flow (UPDATED)
```
User selects theme (e.g., "Arc Dark")
    ↓
create_system_backup()
    ├─ Backup current theme settings
    ├─ Backup ZSH config
    └─ Backup terminal settings
    ↓
protect_zsh_config()
    ├─ Copy .zshrc, .p10k.zsh, etc.
    └─ Store in backup/zsh_protected/
    ↓
Load theme module [NEW]
    ├─ source themes/theme-arc.sh
    └─ Check metadata with themes.json
    ↓
install_arc_theme() [NEW]
    ├─ Try Method 1: apt
    ├─ Try Method 2: ppa
    ├─ Try Method 3: github
    └─ Verify installation
    ↓
Load DE-specific module
    ├─ GNOME → source desktop-environments/de-gnome.sh
    ├─ KDE → source desktop-environments/de-kde.sh
    └─ ... (other DEs)
    ↓
apply_theme_for_de("arc")
    ├─ Apply GTK theme
    ├─ Apply icon theme
    ├─ Apply shell theme (if supported)
    ├─ Apply cursor theme
    └─ Apply wallpaper (optional)
    ↓
Restore protected configs
    ├─ restore_zsh_config()
    └─ restore_terminal_font()
    ↓
Show success message + tips
```

---

## 🧩 MODULE DESIGN

### Core Modules (✅ COMPLETE)

#### `core/config.sh`
**Purpose:** Global configuration and constants  
**Status:** ✅ Completed in Phase 1

**Exports:**
- Paths: `$CONFIG_DIR`, `$BACKUP_DIR`, `$LOG_FILE`
- Colors: `$RED`, `$GREEN`, `$CYAN`, etc.
- Arrays: `$SUPPORTED_DES`, `$SUPPORTED_UBUNTU_VERSIONS`
- Feature flags: `$ENABLE_WALLPAPERS`, `$PROTECT_ZSH_CONFIG`

**Key Functions:**
- `init_config()` - Create directories, load user config
- `save_user_config()` - Save user preferences

---

#### `core/logger.sh`
**Purpose:** Centralized logging system  
**Status:** ✅ Completed in Phase 1

**Log Levels:** DEBUG, INFO, SUCCESS, WARNING, ERROR

**Key Functions:**
```bash
log_message(level, message)   # Core logging
log_info(message)             # Info level
log_success(message)          # Success level
log_warning(message)          # Warning level
log_error(message)            # Error level
show_progress(msg, cur, tot)  # Progress bar
log_step(step, total, msg)    # Step indicator
log_box(message, color)       # Boxed message
```

---

#### `core/detection.sh`
**Purpose:** System and environment detection  
**Status:** ✅ Completed in Phase 1

**Key Functions:**
```bash
detect_desktop_environment()   # Returns: GNOME/KDE/XFCE/etc.
detect_ubuntu_version()        # Returns: "24.04 LTS (noble)"
detect_zsh_framework()         # Returns: Oh My Zsh/Prezto/etc.
detect_gpu()                   # Returns: GPU model
detect_gpu_vendor()            # Returns: NVIDIA/AMD/Intel
is_de_supported(de)            # Check if DE is supported
get_current_theme_name()       # Get active theme
```

---

#### `core/safety.sh`
**Purpose:** Backup, restore, and protection system  
**Status:** ✅ Completed in Phase 1

**Key Functions:**
```bash
# ZSH Protection
protect_zsh_config()          # Backup ZSH files
restore_zsh_config()          # Restore ZSH files
check_zsh_integrity()         # Verify ZSH is intact

# Terminal Protection
protect_terminal_font()       # Save terminal font
restore_terminal_font()       # Restore terminal font

# Backup Management
create_system_backup()        # Full system backup
create_theme_backup(path)     # Theme settings backup
restore_from_backup(name)     # Restore from backup
list_backups()                # Show available backups
cleanup_old_backups()         # Keep only MAX_BACKUPS

# Dependencies
check_dependencies()          # Ensure required tools
```

---

### Desktop Environment Modules (✅ COMPLETE)

#### `desktop-environments/de-gnome.sh`
**Purpose:** GNOME-specific theme operations  
**Status:** ✅ Completed in Phase 1 (9 themes supported)

**Key Functions:**
```bash
apply_theme_for_de(theme_name)
    ├─ install_theme_packages(theme)
    ├─ apply_gtk_theme_gnome(theme)
    ├─ apply_icon_theme_gnome(icons)
    ├─ apply_shell_theme_gnome(shell)
    ├─ apply_cursor_theme_gnome(cursor)
    └─ apply_wallpaper_gnome(wallpaper)

get_current_gnome_theme()
reset_gnome_theme()
verify_gnome_extensions()
```

**Supported Themes:** Arc, Yaru, Pop, Dracula, Nord, Catppuccin, Gruvbox, TokyoNight, Cyberpunk

---

#### `desktop-environments/de-kde.sh`
**Purpose:** KDE Plasma-specific operations  
**Status:** ✅ Completed in Phase 1 (8 themes supported)

**Key Functions:**
```bash
apply_theme_for_de(theme_name)
    ├─ apply_plasma_theme(theme)
    ├─ apply_color_scheme(colors)
    ├─ apply_icon_theme_kde(icons)
    └─ apply_wallpaper_kde(wallpaper)
```

**Supported Themes:** Arc, Yaru, Pop, Dracula, Nord, Catppuccin, Gruvbox, TokyoNight

---

#### `desktop-environments/de-xfce.sh`
**Purpose:** XFCE-specific operations  
**Status:** ✅ Completed in Phase 1 (9 themes supported)

---

#### `desktop-environments/de-mate.sh`
**Purpose:** MATE-specific operations  
**Status:** ✅ Completed in Phase 1 (9 themes supported)

---

#### `desktop-environments/de-cinnamon.sh`
**Purpose:** Cinnamon-specific operations  
**Status:** ✅ Completed in Phase 1 (9 themes supported)

---

### Theme Modules (✅ COMPLETE - Phase 2) [NEW SECTION]

**Structure:** Each theme has its own module file with standardized functions.

#### Common Functions (All Theme Modules)
```bash
install_<theme>_theme()           # Main installation function
    ├─ Try Method 1 (apt/ppa)
    ├─ Try Method 2 (github releases)
    ├─ Try Method 3 (git clone)
    └─ Verify installation

verify_<theme>_installation()     # Check if theme is installed
get_installed_<theme>_variants()  # List installed variants
get_<theme>_metadata()            # Return theme metadata
get_<theme>_variants()            # List available variants
get_<theme>_color_palette()       # Return color information
get_<theme>_recommended_variant() # Suggest best variant
cleanup_<theme>_theme()           # Remove theme
check_<theme>_dependencies()      # Verify required tools
```

---

#### `themes/theme-arc.sh`
**Status:** ✅ Complete  
**Installation:** apt → github fallback  
**Variants:** Arc, Arc-Dark, Arc-Darker, Arc-Lighter  
**Icons:** Papirus  

**Installation Strategy:**
1. Try Ubuntu repository (apt)
2. Fallback to GitHub releases
3. User local installation (~/.themes)

**Features:**
- Automatic variant detection
- Papirus icons auto-install
- System + user path support

---

#### `themes/theme-yaru.sh`
**Status:** ✅ Complete  
**Installation:** apt (Ubuntu native)  
**Variants:** 15 variants (Yaru, Yaru-dark, color variants)  
**Icons:** Yaru  

**Special Features:**
- Ubuntu version detection (22.04+ for color variants)
- 4 color accents: blue, red, green, purple
- Each accent has light/dark variants
- Official Ubuntu theme

---

#### `themes/theme-pop.sh`
**Status:** ✅ Complete  
**Installation:** PPA (System76)  
**Variants:** Pop, Pop-dark, Pop-light  
**Icons:** Pop  

**Special Features:**
- Automatic PPA management
- NVIDIA system detection
- Pop!_OS optimization
- Professional orange accents

---

#### `themes/theme-dracula.sh`
**Status:** ✅ Complete  
**Installation:** GitHub (git/wget)  
**Variants:** Dracula  
**Icons:** Papirus-Dark  

**Special Features:**
- 700+ application ports
- Official Dracula color palette
- Large community support
- Update function included

---

#### `themes/theme-nord.sh`
**Status:** ✅ Complete  
**Installation:** GitHub (EliverLara/Nordic)  
**Variants:** Nordic, Nordic-darker, Nordic-Polar, Nordic-bluish-accent  
**Icons:** Papirus-Dark, Zafiro-Nord  

**Special Features:**
- Arctic color palette
- 4 variants for different preferences
- Official Nord colors
- Minimal aesthetic

---

#### `themes/theme-catppuccin.sh`
**Status:** ✅ Complete  
**Installation:** GitHub releases + git  
**Variants:** 4 flavors × 14 accents = 56+ combinations  
**Flavors:** Latte (light), Frappe, Macchiato, Mocha (dark)  
**Icons:** Papirus, Tela  

**Special Features:**
- Most variants (56+ combinations)
- 4 flavors (light to dark)
- 14 accent colors
- 200+ application ports
- Trending theme
- Installation script support

---

#### `themes/theme-gruvbox.sh`
**Status:** ✅ Complete  
**Installation:** GitHub (Fausto-Korpsvart)  
**Variants:** Gruvbox-Dark, Gruvbox-Dark-BL, Gruvbox-Dark-B, Gruvbox-Light  
**Icons:** Papirus-Dark  

**Special Features:**
- Retro warm colors
- Vim heritage
- Original by morhetz
- Comfortable for long sessions
- Eye-strain optimized

---

#### `themes/theme-tokyonight.sh`
**Status:** ✅ Complete  
**Installation:** GitHub (Fausto-Korpsvart)  
**Variants:** Tokyonight-Dark, Tokyonight-Storm, Tokyonight-Light  
**Icons:** Papirus-Dark, Tela-dark  

**Special Features:**
- VS Code heritage
- Vibrant neon colors
- Storm variant (most popular)
- Night coding optimized
- Neovim config helper

---

#### `themes/theme-cyberpunk.sh`
**Status:** ✅ Complete  
**Installation:** GitHub (Roboron3042)  
**Variants:** Cyberpunk-Neon  
**Icons:** Cyberpunk-Neon (included)  

**Special Features:**
- Cyberpunk 2077 inspired
- Neon cyan/pink/purple
- Gaming aesthetic
- RGB-friendly
- Installation script support
- Gaming optimization tips

---

### Data Files (✅ COMPLETE - Phase 2) [NEW SECTION]

#### `data/themes.json`
**Purpose:** Central theme metadata database  
**Status:** ✅ Complete  
**Format:** JSON

**Structure:**
```json
{
  "themes": {
    "arc": {
      "name": "Arc",
      "display_name": "Arc Dark",
      "description": "...",
      "category": "modern",
      "variants": [...],
      "icons": {...},
      "sources": {...},
      "compatibility": {...},
      "metadata": {...},
      "features": {...},
      "colors": {...},
      "recommendations": {...}
    },
    ...
  },
  "metadata": {
    "version": "2.0",
    "total_themes": 9
  }
}
```

**Contains:**
- 9 theme definitions
- Full metadata for each theme
- Installation sources
- Color palettes
- DE compatibility
- Recommendations

---

#### `data/compatibility.json`
**Purpose:** DE/Theme compatibility matrix  
**Status:** ✅ Complete  
**Format:** JSON

**Structure:**
```json
{
  "desktop_environments": {
    "GNOME": {
      "minimum_version": "3.36",
      "tool": "gsettings",
      "supported_themes": [...],
      "required_packages": [...],
      "features": {...}
    },
    ...
  },
  "compatibility_matrix": {
    "arc": {
      "GNOME": {"rating": 5, "native": true},
      "KDE": {"rating": 5, "native": false},
      ...
    },
    ...
  }
}
```

**Contains:**
- 6 desktop environments
- Configuration tools
- Required packages
- Theme compatibility ratings
- Feature support matrix

---

### Utility Modules (✅ COMPLETE)

#### `utils/theme-utils.sh`
**Purpose:** Common utility functions  
**Status:** ✅ Complete

**Key Functions:**
```bash
show_theme_previews()         # Display theme info
run_compatibility_check()     # System analysis
reset_to_default()            # Restore defaults
cleanup_themes()              # Remove themes
show_settings_menu()          # Configuration
show_help_menu()              # Help system
```

---

#### `utils/theme-assistant.sh`
**Purpose:** Intelligent theme recommendations  
**Status:** ✅ Complete

**Key Functions:**
```bash
get_theme_recommendation()         # Smart AI-like suggestions
interactive_theme_guide()          # Guided selection
compare_themes()                   # Side-by-side comparison
analyze_user_pattern()             # Usage analysis
get_pattern_based_recommendation() # Based on history
```

---

## 🎨 THEME INSTALLATION STRATEGY

### Priority Order:
```
1. Ubuntu Official Repo (apt)
   ├─ Most stable
   ├─ Best integration
   └─ Example: arc-theme, yaru-theme

2. Trusted PPA
   ├─ Recent versions
   ├─ Well maintained
   └─ Example: ppa:system76/pop

3. Official GitHub Release
   ├─ Latest features
   ├─ Direct from developer
   └─ Example: Catppuccin, Nord, Dracula

4. Git Clone
   ├─ Development version
   └─ With installation scripts

5. Fallback
   ├─ Alternative theme
   └─ User notification
```

### Installation Flow (Updated):
```
install_theme(theme_name):
    ├─ Load themes/theme-<name>.sh
    ├─ Check if already installed → skip
    ├─ Check dependencies → install if missing
    ├─ Try Method 1 (apt/ppa)
    │   └─ Success → verify → done
    ├─ Try Method 2 (github releases)
    │   └─ Success → verify → done
    ├─ Try Method 3 (git clone)
    │   └─ Success → verify → done
    └─ Method 4 (fallback)
        ├─ Suggest alternative theme
        └─ Log failure
```

---

## 📊 SUPPORTED THEMES

### Summary Table

| Theme | Category | Variants | Icons | Source | Popularity |
|-------|----------|----------|-------|--------|------------|
| Arc | Modern | 4 | Papirus | apt/github | ⭐⭐⭐⭐⭐ 95% |
| Yaru | Official | 15 | Yaru | apt | ⭐⭐⭐⭐⭐ 98% |
| Pop | Professional | 3 | Pop | ppa | ⭐⭐⭐⭐⭐ 92% |
| Dracula | Community | 1 | Papirus-Dark | github | ⭐⭐⭐⭐⭐ 96% |
| Nord | Community | 4 | Papirus-Dark | github | ⭐⭐⭐⭐⭐ 94% |
| Catppuccin | Trending | 56+ | Papirus | github | ⭐⭐⭐⭐⭐ 97% |
| Gruvbox | Retro | 4 | Papirus-Dark | github | ⭐⭐⭐⭐⭐ 93% |
| TokyoNight | Vibrant | 3 | Papirus-Dark | github | ⭐⭐⭐⭐⭐ 95% |
| Cyberpunk | Neon | 1 | Cyberpunk | github | ⭐⭐⭐⭐ 89% |

---

## 🔐 SAFETY MECHANISMS

### 1. ZSH Protection Flow
```
Before theme application:
    ├─ Detect ZSH framework
    ├─ Backup all ZSH files
    └─ Store in backup/zsh_protected/

During theme application:
    ├─ Apply theme settings
    └─ NEVER touch ZSH files

After theme application:
    ├─ Verify ZSH files intact
    └─ Restore if corrupted
```

### 2. Backup System
```
Create backup:
    ├─ system_backup_YYYYMMDD_HHMMSS/
    │   ├─ manifest.txt (metadata)
    │   ├─ gnome_theme.backup (current settings)
    │   └─ zsh_protected/ (ZSH files)
    └─ Store in $BACKUP_DIR

Rotation:
    ├─ Keep last MAX_BACKUPS (default: 5)
    └─ Auto-delete oldest when exceeded
```

### 3. Rollback System
```
If theme application fails:
    ├─ Offer immediate rollback
    ├─ Restore from latest backup
    ├─ Verify restoration
    └─ Log incident
```

---

## 📊 DATA STRUCTURES

### Theme Metadata (`data/themes.json`)
```json
{
  "arc": {
    "name": "Arc",
    "display_name": "Arc Dark",
    "variants": ["Arc", "Arc-Dark", "Arc-Darker"],
    "icons": {
      "recommended": "Papirus",
      "alternatives": ["Papirus-Dark", "Adwaita"]
    },
    "sources": {
      "primary": {
        "type": "apt",
        "package": "arc-theme"
      },
      "secondary": {
        "type": "github",
        "repo": "jnsh/arc-theme"
      }
    },
    "compatibility": {
      "GNOME": {"supported": true, "shell_theme": true},
      "KDE": {"supported": true},
      ...
    }
  }
}
```

### Compatibility Matrix (`data/compatibility.json`)
```json
{
  "desktop_environments": {
    "GNOME": {
      "minimum_version": "3.36",
      "tool": "gsettings",
      "supported_themes": ["arc", "yaru", ...],
      "configuration_paths": {
        "gtk_theme": "org.gnome.desktop.interface gtk-theme",
        ...
      }
    }
  },
  "compatibility_matrix": {
    "arc": {
      "GNOME": {"rating": 5, "native": true},
      ...
    }
  }
}
```

---

## 🚀 PERFORMANCE CONSIDERATIONS

### Lazy Loading
- DE modules loaded only when needed
- Theme modules loaded on demand
- Component modules conditional

### Caching
```bash
$CACHE_DIR/
├─ detected_de.cache       # Cache DE detection
├─ theme_list.cache        # Cache available themes
└─ package_status.cache    # Cache package checks
```

---

## 🔄 STATE MANAGEMENT

### Session State
```bash
$CONFIG_DIR/session_state.conf
    ├─ last_theme_applied
    ├─ last_backup_created
    ├─ last_successful_operation
    └─ user_preferences
```

### Persistent State
```bash
$CONFIG_DIR/config.conf
    ├─ enable_wallpapers=true
    ├─ enable_gdm_theme=false
    ├─ protect_zsh_config=true
    └─ log_level=INFO
```

---

## 📊 PROJECT STATISTICS

### Current Status (Phase 2 Complete)
```
Core Modules:        5/5  ✅ 100%
DE Modules:          5/5  ✅ 100%
Theme Modules:       9/9  ✅ 100%
Data Files:          2/2  ✅ 100%
Utility Modules:     2/2  ✅ 100%

Total Files:         23/23 ✅ 100%
Lines of Code:       ~8000+
Themes Supported:    9
Desktop Environments: 6
Ubuntu Versions:     2 (22.04, 24.04 LTS)
```

---

## 🎯 FUTURE PHASES

### Phase 3: Wallpaper System (Pending)
- HD wallpaper collections per theme
- Automatic wallpaper switching
- Multi-monitor support

### Phase 4: Enhanced Components (Pending)
- Universal GTK handler
- Icon theme manager
- Cursor theme manager

### Phase 5: Testing & Polish (Pending)
- VM testing (6 DE × 9 themes)
- Bug fixes
- Performance optimization

### Phase 6: Documentation (Pending)
- README.md
- FAQ
- Video tutorials

---

**END OF ARCHITECTURE.md v2.1**  
*Last Updated: 2025-01-09 - Phase 2 Complete*  
*Next: Integration or Phase 3*