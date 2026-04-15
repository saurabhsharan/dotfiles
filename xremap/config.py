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
FIREFOX_BROWSERS = ["firefox"]
CHROME_BROWSERS = ["chromium", "google-chrome"]
ALL_BROWSERS = FIREFOX_BROWSERS + CHROME_BROWSERS

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

    "Super-a": "Ctrl-a", # Select All
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

# ==========================================
# KEYMAPS (Application Keybindings)
# ==========================================
class GlobalBindings(Keymap):
    name = "Global bindings"
    exact_match = True
    remap = MAC_TEXT_NAVIGATION | {
        "Ctrl-i": "up",
        "Ctrl-j": "down",
    }

class EmacsBindings(Keymap):
    name = "Emacs bindings"
    exact_match = True
    # Exclude terminal emulators from Emacs bindings since they are often already built-in and/or conflict with the shell/editor
    application = App(not_=TERMINALS)
    remap = EMACS_NAV

class ClipboardBindings(Keymap):
    name = "Clipboard bindings"
    exact_match = True
    # Exclude terminal emulators from clipboard bindings since they often have bespoke clipboard shortcuts
    application = App(not_=TERMINALS)
    remap = {
        "Super-c": "Ctrl-c", # copy
        "Super-v": "Ctrl-v", # paste
        "Super-x": "Ctrl-x", # cut
    }

class CloseWindowBinding(Keymap):
    name = "Close Window binding"
    exact_match = True
    # Excluse browsers and terminals from Super+W since we override that with app-specific shortcut to close current tab
    application = App(not_=(ALL_BROWSERS + TERMINALS))
    remap = {
        "Super-w": "Alt-Super-w", # close window (Niri)
    }

class BaseBrowser(Keymap):
    is_base = True
    exact_match = True
    remap = {
        "Super-d": "Ctrl-d", # bookmark current page
        "Super-f": "Ctrl-f", # find
        "Super-g": "Ctrl-g", # jump to next match
        "Super-Shift-g": "Ctrl-Shift-g", # jump to previous match
        "Super-l": "Ctrl-l", # focus address bar
        "Super-n": "Ctrl-n", # new window
        "Super-r": "Ctrl-r", # refresh
        "Super-t": "Ctrl-t", # new tab
        "Super-w": "Ctrl-f4", # close tab
        "Super-0": "Ctrl-0", # reset zoom
        "Super-leftbrace": "Alt-left", # go back
        "Super-rightbrace": "Alt-right", # go forward
        "Super-Shift-o": "Ctrl-Shift-o", # open bookmarks
        "Super-Shift-t": "Ctrl-Shift-t", # reopen closed tab
        "Super-Alt-i": "Ctrl-Shift-i", # open inspector
        "Super-minus": "Ctrl-minus", # zoom out
        "Super-equal": "Ctrl-equal", # zoom in

        "Alt_R-leftbrace": "Alt-left", # go back
        "Alt_R-rightbrace": "Alt-right", # go forward
        "Alt_R-minus": "Ctrl-minus", # zoom out
        "Alt_R-equal": "Ctrl-equal", # zoom in
        "Alt_R-Shift-leftbrace": "Ctrl-Shift-tab", # previous tab
        "Alt_R-Shift-rightbrace": "Ctrl-tab", # next tab
    }

class Firefox(BaseBrowser):
    name = "Firefox"
    exact_match = True
    application = App(only=FIREFOX_BROWSERS)
    remap = BaseBrowser.remap | {
        "Super-Shift-p": "Ctrl-Shift-p", # new private window
    } | {
        **{f"Super-{i}": f"Alt-{i}" for i in range(1, 10)}, # select tab by position
    }

class Chrome(BaseBrowser):
    name = "Chrome"
    exact_match = True
    application = App(only=CHROME_BROWSERS)
    remap = BaseBrowser.remap | {
        "Super-comma": "Ctrl-Shift-comma", # open settings

        "Super-Shift-a": "Ctrl-Shift-a", # search tabs
        "Super-Shift-c": "Ctrl-Shift-c", # select element to inspect
        "Super-shift-j": "Ctrl-j", # open downloads page
        "Super-Shift-n": "Ctrl-Shift-n", # new incognito window

        "Alt-Super-b": "Ctrl-Shift-o", # open bookmarks
    } | {
        f"Super-{i}": f"Ctrl-{i}" for i in range(1, 10) # select tab by position
    }

class RoamPWA(Keymap):
    name = "Roam  Research (Chrome PWA)"
    exact_match = True
    application = App(only=["chrome-lflgehidkjooeaeclhaadoefaleoeged-Default"])
    remap = {
        "Ctrl-n": "down",
        "Ctrl-p": "up",
    }

class RoamViewerPWA(Chrome):
    name = "Roam Viewer (Chrome PWA)"
    exact_match = True
    application = App(only=["chrome-jcgpenhgafmhijpfmgmlcacapeaofcdf-Default", "chrome-nmhgeifmehldnegmaackjamblpjkcpmh-Default"])

class ChatWise(Keymap):
    name = "ChatWise"
    exact_match = True
    application = App(only=["ChatWise"])
    remap = {
        "Super-b": "Ctrl-b", # toggle sidebar
        "Super-n": "Ctrl-n", # new chat
        "Super-comma": "Ctrl-comma", # open settings
        "Super-enter": "Ctrl-enter", # send message
        "Super-slash": "Ctrl-slash", # model switcher
    }

if __name__ == "__main__":
    compile_config("config.yml")
