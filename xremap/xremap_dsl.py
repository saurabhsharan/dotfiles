import yaml
import json

_modmaps = []
_keymaps = []

class App:
    def __init__(self, only=None, not_=None):
        self.only = only if only is None or isinstance(only, list) else [only]
        self.not_ = not_ if not_ is None or isinstance(not_, list) else [not_]
    
    def to_dict(self):
        d = {}
        if self.only is not None: d['only'] = self.only
        if self.not_ is not None: d['not'] = self.not_
        return d

class Device:
    def __init__(self, only=None, not_=None):
        self.only = only if only is None or isinstance(only, list) else [only]
        self.not_ = not_ if not_ is None or isinstance(not_, list) else [not_]
    
    def to_dict(self):
        d = {}
        if self.only is not None: d['only'] = self.only
        if self.not_ is not None: d['not'] = self.not_
        return d

class MetaRemap(type):
    def __new__(mcs, name, bases, attrs):
        is_base = attrs.pop('is_base', False)
        cls = super().__new__(mcs, name, bases, attrs)
        if not is_base and name not in ('Modmap', 'Keymap'):
            if any(b.__name__ == 'Modmap' for b in cls.__mro__):
                _modmaps.append(cls)
            elif any(b.__name__ == 'Keymap' for b in cls.__mro__):
                _keymaps.append(cls)
        return cls

class Modmap(metaclass=MetaRemap):
    is_base = True

class Keymap(metaclass=MetaRemap):
    is_base = True

class NoAliasDumper(yaml.SafeDumper):
    def ignore_aliases(self, data):
        return True

def normalize_shortcut(shortcut):
    parts = shortcut.split('-')
    if len(parts) == 1:
        return shortcut.lower()
    mods = [p.lower() for p in parts[:-1]]
    
    # Normalize aliases to ensure conflict detection works across conventions
    mods = ['ctrl' if m == 'c' else m for m in mods]
    mods = ['alt' if m == 'm' else m for m in mods]
    
    mods.sort()
    key = parts[-1].lower()
    return '-'.join(mods + [key])

def intersect_scopes(scope1, scope2):
    only1 = set(scope1.only) if scope1 and scope1.only else None
    not1 = set(scope1.not_) if scope1 and scope1.not_ else set()
    
    only2 = set(scope2.only) if scope2 and scope2.only else None
    not2 = set(scope2.not_) if scope2 and scope2.not_ else set()
    
    if only1 is not None and only2 is not None:
        intersection = only1.intersection(only2)
        if intersection:
            return True, f"apps: {', '.join(intersection)}"
        return False, ""
    
    if only1 is not None and only2 is None:
        intersection = only1 - not2
        if intersection:
            return True, f"apps: {', '.join(intersection)}"
        return False, ""
        
    if only1 is None and only2 is not None:
        intersection = only2 - not1
        if intersection:
            return True, f"apps: {', '.join(intersection)}"
        return False, ""
        
    if only1 is None and only2 is None:
        return True, "global or broadly overlapping 'not' rules"

def check_conflicts():
    shortcut_map = {}
    conflicts_found = 0
    duplicates_found = 0
    for cls in _keymaps:
        if not hasattr(cls, 'remap') or not cls.remap:
            continue
        
        name = getattr(cls, 'name', cls.__name__)
        app_scope = getattr(cls, 'application', None)
        
        for raw_shortcut in cls.remap.keys():
            shortcut = normalize_shortcut(raw_shortcut)
            action = cls.remap[raw_shortcut]
            
            if shortcut not in shortcut_map:
                shortcut_map[shortcut] = []
            
            for prev_name, prev_scope, prev_action in shortcut_map[shortcut]:
                intersects, reason = intersect_scopes(app_scope, prev_scope)
                if intersects:
                    if action == prev_action:
                        print(f"ℹ️  Duplicate Detected: '{raw_shortcut}' (normalized as '{shortcut}')")
                        print(f"   Defined in '{prev_name}' and redundantly defined in '{name}' mapping to '{action}'.")
                        print(f"   Intersection: {reason}\n")
                        duplicates_found += 1
                    else:
                        print(f"⚠️  Conflict Detected: '{raw_shortcut}' (normalized as '{shortcut}')")
                        print(f"   Defined as '{prev_action}' in '{prev_name}' but redefined as '{action}' in '{name}'.")
                        print(f"   Intersection: {reason}\n")
                        conflicts_found += 1
            
            shortcut_map[shortcut].append((name, app_scope, action))
            
    if conflicts_found == 0 and duplicates_found == 0:
        print("✅ No shortcut conflicts or duplicates detected!\n")
    else:
        print(f"❌ Found {conflicts_found} potential conflict(s) and {duplicates_found} duplicate(s). Please review them.\n")

def generate_html_docs(filename="shortcuts.html"):
    apps = set()
    for cls in _keymaps:
        if hasattr(cls, 'application') and cls.application:
            if cls.application.only:
                apps.update(cls.application.only)
            if cls.application.not_:
                apps.update(cls.application.not_)
    
    apps = sorted(list(apps))
    app_data = {}
    
    global_data = {}
    for cls in _keymaps:
        name = getattr(cls, 'name', cls.__name__)
        remap = getattr(cls, 'remap', {})
        if not remap: continue
        app_scope = getattr(cls, 'application', None)
        
        if app_scope is None or (not app_scope.only and not app_scope.not_):
            global_data[name] = remap
    
    app_data["All Apps"] = global_data
    
    def get_specificity(cls):
        scope = getattr(cls, 'application', None)
        if not scope: return (3, 0)
        if scope.only: return (1, len(scope.only))
        if scope.not_: return (2, -len(scope.not_))
        return (3, 0)
        
    sorted_keymaps = sorted(_keymaps, key=get_specificity)
    
    for app in apps:
        app_data[app] = {}
        for cls in sorted_keymaps:
            name = getattr(cls, 'name', cls.__name__)
            remap = getattr(cls, 'remap', {})
            if not remap: continue
            
            app_scope = getattr(cls, 'application', None)
            applies = False
            if app_scope is None:
                applies = True
            else:
                if app_scope.only:
                    if app in app_scope.only:
                        applies = True
                else:
                    if app not in (app_scope.not_ or []):
                        applies = True
            
            if applies:
                app_data[app][name] = remap

    html_content = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>xremap Shortcuts</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 0; display: flex; height: 100vh; background-color: #f9fafb; color: #333; }}
        .sidebar {{ width: 280px; background-color: #1f2937; color: #fff; display: flex; flex-direction: column; overflow-y: auto; }}
        .sidebar h2 {{ padding: 20px; margin: 0; font-size: 1.2rem; border-bottom: 1px solid #374151; }}
        .app-list {{ list-style: none; padding: 0; margin: 0; }}
        .app-list li {{ padding: 12px 20px; cursor: pointer; border-bottom: 1px solid #374151; transition: background 0.2s; }}
        .app-list li:hover {{ background-color: #374151; }}
        .app-list li.active {{ background-color: #3b82f6; font-weight: bold; }}
        .main-content {{ flex: 1; padding: 40px; overflow-y: auto; }}
        .main-content h1 {{ margin-top: 0; font-size: 2rem; margin-bottom: 30px; color: #111827; }}
        .keymap-group {{ background: #fff; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 30px; padding: 20px; }}
        .keymap-group h3 {{ margin-top: 0; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #e5e7eb; color: #4b5563; }}
        .shortcuts-grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; }}
        .shortcut-item {{ display: flex; justify-content: space-between; background: #f3f4f6; padding: 10px 15px; border-radius: 6px; align-items: center; gap: 10px; }}
        .shortcut-key {{ font-weight: 600; color: #2563eb; font-family: monospace; font-size: 0.95rem; }}
        .shortcut-action {{ color: #4b5563; font-family: monospace; font-size: 0.95rem; text-align: right; }}
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>Applications</h2>
        <ul class="app-list" id="appList"></ul>
    </div>
    <div class="main-content">
        <h1 id="appTitle">All Apps</h1>
        <div id="shortcutsContainer"></div>
    </div>

    <script>
        const appData = {json.dumps(app_data)};
        
        const appList = document.getElementById('appList');
        const appTitle = document.getElementById('appTitle');
        const shortcutsContainer = document.getElementById('shortcutsContainer');

        function renderShortcuts(appName) {{
            appTitle.textContent = appName;
            shortcutsContainer.innerHTML = '';
            
            const groups = appData[appName];
            if (Object.keys(groups).length === 0) {{
                shortcutsContainer.innerHTML = '<p>No shortcuts defined for this application.</p>';
                return;
            }}

            for (const [groupName, shortcuts] of Object.entries(groups)) {{
                const groupDiv = document.createElement('div');
                groupDiv.className = 'keymap-group';
                
                const h3 = document.createElement('h3');
                h3.textContent = groupName;
                groupDiv.appendChild(h3);
                
                const gridDiv = document.createElement('div');
                gridDiv.className = 'shortcuts-grid';
                
                for (const [key, action] of Object.entries(shortcuts)) {{
                    const itemDiv = document.createElement('div');
                    itemDiv.className = 'shortcut-item';
                    
                    const keySpan = document.createElement('span');
                    keySpan.className = 'shortcut-key';
                    keySpan.textContent = key;
                    
                    const actionSpan = document.createElement('span');
                    actionSpan.className = 'shortcut-action';
                    actionSpan.textContent = Array.isArray(action) ? action.join(' + ') : action;
                    
                    itemDiv.appendChild(keySpan);
                    itemDiv.appendChild(actionSpan);
                    gridDiv.appendChild(itemDiv);
                }}
                
                groupDiv.appendChild(gridDiv);
                shortcutsContainer.appendChild(groupDiv);
            }}
        }}

        function init() {{
            const apps = Object.keys(appData);
            const globalIndex = apps.indexOf("All Apps");
            if (globalIndex > -1) {{
                apps.splice(globalIndex, 1);
                apps.unshift("All Apps");
            }}

            apps.forEach(app => {{
                const li = document.createElement('li');
                li.textContent = app;
                if (app === "All Apps") {{
                    li.className = 'active';
                }}
                li.onclick = () => {{
                    document.querySelectorAll('.app-list li').forEach(el => el.classList.remove('active'));
                    li.classList.add('active');
                    renderShortcuts(app);
                }};
                appList.appendChild(li);
            }});

            renderShortcuts("All Apps");
        }}

        init();
    </script>
</body>
</html>'''
    with open(filename, 'w') as f:
        f.write(html_content)
    print(f"Generated HTML documentation at {filename}")

def compile_config(filename, html_filename="shortcuts.html"):
    config = {}
    
    print("Validating configuration for conflicts...")
    print("-" * 50)
    check_conflicts()
    print("-" * 50)
    
    modmaps_out = []
    for cls in _modmaps:
        m = {}
        if hasattr(cls, 'name') and cls.name: m['name'] = cls.name
        if hasattr(cls, 'remap') and cls.remap: m['remap'] = cls.remap
        if hasattr(cls, 'application') and cls.application: m['application'] = cls.application.to_dict()
        if hasattr(cls, 'device') and cls.device: m['device'] = cls.device.to_dict()
        if m: modmaps_out.append(m)
        
    if modmaps_out:
        config['modmap'] = modmaps_out

    keymaps_out = []
    for cls in _keymaps:
        k = {}
        if hasattr(cls, 'name') and cls.name: k['name'] = cls.name
        if hasattr(cls, 'exact_match') and cls.exact_match is not None: k['exact_match'] = cls.exact_match
        if hasattr(cls, 'application') and cls.application: k['application'] = cls.application.to_dict()
        if hasattr(cls, 'device') and cls.device: k['device'] = cls.device.to_dict()
        if hasattr(cls, 'remap') and cls.remap: k['remap'] = cls.remap
        if k: keymaps_out.append(k)
        
    if keymaps_out:
        config['keymap'] = keymaps_out

    with open(filename, 'w') as f:
        yaml.dump(config, f, Dumper=NoAliasDumper, default_flow_style=False, sort_keys=False)
    print(f"Compiled {len(_modmaps)} modmaps and {len(_keymaps)} keymaps to {filename}")
    
    generate_html_docs(html_filename)