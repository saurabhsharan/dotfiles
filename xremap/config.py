from xremap_dsl import Modmap, Keymap, App, Device, compile_config

"""
Keybinding Naming Convention:
- Modifiers: Upper-case first letter (e.g., Ctrl, Alt, Shift, Super, Alt_R)
  * Note: Always use 'Alt' instead of 'M' (Meta) to avoid confusion. In xremap, 'M' is just an alias for 'Alt', not 'Super'.
  * Note: Always use 'Ctrl' instead of 'C'.
- Keys: All lower-case (e.g., a, left, home, backspace, comma, f4)
- Separator: Hyphen (-)
Example: Ctrl-Shift-left, Super-comma
"""

# ==========================================
# VARIABLES
# ==========================================
APPLE_KEYBOARDS = [
    'Apple Inc. Magic Keyboard with Numeric Keypad', 
    'Apple Inc. Magic Keyboard with Touch ID and Numeric Keypad', 
    'Apple Inc. Magic Keyboard'
]

TERMINALS = ["org.wezfurlong.wezterm", "kitty", "com.mitchellh.ghostty"]
EDITORS = ["dev.zed.Zed", "jetbrains-idea"]
CHROME_BROWSERS = ["chromium", "google-chrome"]
ALL_BROWSERS = ["firefox", "Vivaldi-stable"] + CHROME_BROWSERS

# ==========================================
# SNIPPETS (Shared Keybindings)
# ==========================================
MAC_TEXT_NAVIGATION = {
    "Alt-left": "Ctrl-left",
    "Alt-right": "Ctrl-right",
    "Alt-up": "Ctrl-home",
    "Alt-down": "Ctrl-end",

    "Alt-Shift-left": "Ctrl-Shift-left",
    "Alt-Shift-right": "Ctrl-Shift-right",
    "Alt-Shift-up": "Ctrl-Shift-home",
    "Alt-Shift-down": "Ctrl-Shift-end",

    "Super-left": "home",
    "Super-right": "end",

    "Super-Shift-left": "Shift-home",
    "Super-Shift-right": "Shift-end",

    "Alt-backspace": "Ctrl-backspace",
    "Super-backspace": ["Shift-home", "delete"],

    "Super-a": "Ctrl-a", # select all
}

EMACS_NAV = {
    "Ctrl-a": "home",
    "Ctrl-b": "left",
    "Ctrl-d": "delete",
    "Ctrl-e": "end",
    "Ctrl-f": "right",
    "Ctrl-h": "backspace",
    "Ctrl-k": ["Shift-end", "delete"],
    "Ctrl-Alt-b": "Ctrl-left",
    "Ctrl-Alt-f": "Ctrl-right",

    # These are custom and not Emacs-standard
    "Alt-f": "Ctrl-right",
    "Alt-b": "Ctrl-left",
    "Alt-Shift-b": "Ctrl-Shift-left",
    "Alt-Shift-f": "Ctrl-Shift-right",
}

BROWSER_BASE = {
    "Super-l": "Ctrl-l",
    "Super-t": "Ctrl-t",
    "Super-w": "Ctrl-w",
    "Super-minus": "Ctrl-minus",
    "Super-equal": "Ctrl-equal",
    "Alt_R-minus": "Ctrl-minus",
    "Alt_R-equal": "Ctrl-equal",
    "Super-leftbrace": "Ctrl-leftbrace",
    "Super-rightbrace": "Ctrl-rightbrace",
    "Alt_R-Shift-rightbrace": "Ctrl-tab",
    "Alt_R-Shift-leftbrace": "Ctrl-Shift-tab",
}

# ==========================================
# MODMAPS (Hardware Key Reassignments)
# ==========================================
class CapsLockToCtrl(Modmap):
    name = "Change Caps Lock to Control"
    remap = {
        "CapsLock": "Ctrl_L",
    }

class SwapLeftAltSuper(Modmap):
    name = "Swap Left Alt and Left Super"
    remap = {
        "KEY_LEFTALT": "KEY_LEFTMETA",
        "KEY_LEFTMETA": "KEY_LEFTALT",
    }
    device = Device(not_=APPLE_KEYBOARDS)

class SwapRightAltSuper(Modmap):
    name = "Swap Right Alt and Right Super"
    remap = {
        "KEY_RIGHTALT": "KEY_RIGHTMETA",
        "KEY_RIGHTMETA": "KEY_RIGHTALT",
    }
    device = Device(only=APPLE_KEYBOARDS)
    application = App(not_=["dev.zed.Zed", "org.wezfurlong.wezterm", "kitty"])

class AssignFnToLeftCtrl(Modmap):
    name = "Assign Fn to Left Control"
    remap = {
        "KEY_FN": "Ctrl_L",
    }
    device = Device(only='Apple Inc. Magic Keyboard')

# ==========================================
# KEYMAPS (Application Keybindings)
# ==========================================
class ArrowKeys(Keymap):
    name = "Arrow keys"
    exact_match = True
    remap = MAC_ARROWS | {
        "Ctrl-i": "up",
        "Ctrl-j": "down",
    }

class BaseBrowser(Keymap):
    is_base = True
    exact_match = True
    remap = BROWSER_BASE | {
        f"Super-{i}": f"Ctrl-{i}" for i in range(1, 10)
    } | {
        "Super-0": "Ctrl-0",
    }

class Firefox(BaseBrowser):
    name = "Firefox"
    application = App(only=["firefox"])
    remap = BaseBrowser.remap | {
        "Super-n": "Ctrl-n",
        **{f"Super-{i}": f"Alt-{i}" for i in range(1, 10)},
        "Super-0": "Alt-0",
    }

class Chrome(BaseBrowser):
    name = "Chrome"
    application = App(only=CHROME_BROWSERS)
    remap = BaseBrowser.remap | EMACS_NAV | {
        "Super-a": "Ctrl-a",
        "Super-d": "Ctrl-d",
        "Super-f": "Ctrl-f",
        "Super-g": "Ctrl-g",
        "Super-n": "Ctrl-n",
        "Super-r": "Ctrl-r",
        "Super-w": "Ctrl-f4",
        "Super-comma": "Ctrl-Shift-comma",
        "Super-Shift-a": "Ctrl-Shift-a",
        "Super-Shift-c": "Ctrl-Shift-c",
        "Super-Shift-n": "Ctrl-Shift-n",
        "Super-Shift-o": "Ctrl-Shift-o",
        "Super-Shift-t": "Ctrl-Shift-t",
        "Super-Alt-i": "Ctrl-Shift-i",
        "Super-leftbrace": "Alt-left",
        "Super-rightbrace": "Alt-right",
        "Alt_R-leftbrace": "Alt-left",
        "Alt_R-rightbrace": "Alt-right",
        "Ctrl-f": "right", 
    }
    remap.pop("Super-0", None)

class RoamAUR(Keymap):
    name = "Roam Research (AUR version)"
    exact_match = True
    application = App(only=["Roam Research"])
    remap = {
        "Ctrl-f": "right",
        "Super-u": "Ctrl-u",
    }

class RoamPWA(Keymap):
    name = "Roam  Research (Chrome PWA)"
    exact_match = True
    application = App(only=["chrome-lflgehidkjooeaeclhaadoefaleoeged-Default"])
    remap = EMACS_NAV | {
        "Ctrl-n": "down",
        "Ctrl-u": ["Shift-home", "delete"],
        "Super-a": "Ctrl-a",
        "Ctrl-f": "right",
    }

class RoamViewerPWA(Keymap):
    name = "Roam Viewer (Chrome PWA)"
    exact_match = True
    application = App(only=["chrome-jcgpenhgafmhijpfmgmlcacapeaofcdf-Default", "chrome-nmhgeifmehldnegmaackjamblpjkcpmh-Default"])
    remap = EMACS_NAV | {
        "Ctrl-Alt-s": "pagedown",
        "Ctrl-Alt-w": "pageup",
        "Super-a": "Ctrl-a",
        "Super-f": "Ctrl-f",
        "Super-g": "Ctrl-g",
        "Super-r": "Ctrl-r",
        "Super-Shift-g": "Ctrl-Shift-g",
        "Super-minus": "Ctrl-minus",
        "Super-equal": "Ctrl-equal",
        "Alt_R-minus": "Ctrl-minus",
        "Alt_R-equal": "Ctrl-equal",
        "Ctrl-k": ["Shift-end", "delete"],
    }

class ZedEditor(Keymap):
    name = "Zed Editor"
    exact_match = True
    application = App(only=["dev.zed.Zed"])
    remap = {
        "Ctrl-a": "home",
        "Ctrl-b": "left",
        "Ctrl-e": "end",
        "Ctrl-f": "right",
        "Ctrl-n": "down",
        "Ctrl-p": "up",
        "Super-c": "Ctrl-c",
        "Super-p": "Ctrl-p",
        "Super-s": "Ctrl-s",
        "Super-v": "Ctrl-v",
        "Super-w": "Ctrl-w",
        "Super-x": "Ctrl-x",
        "Super-z": "Ctrl-z",
        "Super-Shift-w": "Ctrl-Shift-w",
        "Super-Shift-p": "Ctrl-Shift-p",
    }

class NonWebAndNonTerm(Keymap):
    name = "Non-web browser and non-terminal"
    exact_match = True
    application = App(not_=ALL_BROWSERS + TERMINALS + EDITORS)
    remap = {
        "Super-q": "Ctrl-q",
        "Super-w": "Alt-f4",
    }

class NonTerminal(Keymap):
    name = "Non-terminal"
    exact_match = True
    application = App(not_=["org.wezfurlong.wezterm", "dev.zed.Zed"])
    remap = {
        "Super-c": "Ctrl-c",
        "Super-v": "Ctrl-Shift-v",
        "Super-x": "Ctrl-x",
    }

if __name__ == "__main__":
    compile_config("config.yml")
