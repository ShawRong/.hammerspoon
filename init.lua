require('./modules/ring')

hyper = {"cmd", "alt", "ctrl"}
hyper_shift = {"cmd", "alt", "ctrl", "shift"}
ctrl = {"ctrl"}

function get_fortune()
    -- Replace '/usr/games/fortune' with the actual path from `which fortune`

    local handle = io.popen("/opt/homebrew/bin/fortune | /opt/homebrew/bin/cowsay -r")  
    local result = handle:read("*a")
    handle:close()
    
    if result and result ~= "" then
        return result
    else
        return "No fortune available or error executing command."
    end
end

-- Example usage in Hammerspoon
hs.alert.show(get_fortune())

hs.hotkey.bind(hyper, "W", function()
  result = get_fortune()
  hs.alert.show(result, {}, nil, 10)
end)

-- key mapping
-- 高效的方向键映射（option）
local function remapOption()
    local handler = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        local flags = event:getFlags()
        if not flags.alt then return false end -- Only process option combinations
        
        local keycode = event:getKeyCode()
        local targetKeys = nil
        
        local keyMappings = {
            [hs.keycodes.map[',']] = {'9', true},  -- ( needs shift+9
            [hs.keycodes.map['.']] = {'0', true},  -- ) needs shift+0
            [hs.keycodes.map['a']] = {'=', true},  -- ) needs shift+=
            [hs.keycodes.map['d']] = {'-'},
            [hs.keycodes.map['e']] = {'='},
            [hs.keycodes.map['u']] = {'-', true},
            [hs.keycodes.map['j']] = {'7', true},
            [hs.keycodes.map['k']] = {'8', true},
            [hs.keycodes.map['q']] = {'1', true},
            [hs.keycodes.map['w']] = {'2', true}
        }
        
        local mapping = keyMappings[keycode]
        
        if mapping then
            local key, needShift = mapping[1], mapping[2]
            
            -- Create modifier flags if shift is needed
            local modifiers = needShift and {'shift'} or {}
            
            -- Send key press and release
            hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
            hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
            
            return true -- Prevent original event
        end
        
        return false -- Don't handle other events
    end)
    
    return handler
end

-- Start event listener
local remap_option= remapOption()
remap_option:start()

-- key mapping
-- 高效的方向键映射（control）
local function remapControlToArrow()
    local handler = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        local flags = event:getFlags()
        if not flags.ctrl then return false end -- Only process ctrl combinations
        
        local keycode = event:getKeyCode()
        local targetKeys = nil
        
        -- Map control keys to arrow keys and other functions
        local keyMappings = {
            [hs.keycodes.map['h']] = {'left'},
            [hs.keycodes.map['j']] = {'down'},
            [hs.keycodes.map['k']] = {'up'},
            [hs.keycodes.map['l']] = {'right'},
            [hs.keycodes.map[';']] = {'delete'},
            [hs.keycodes.map['[']] = {'esc'}
        }
        
        local mapping = keyMappings[keycode]
        
        if mapping then
            local key, needShift = mapping[1], mapping[2]
            
            -- Create modifier flags if shift is needed
            local modifiers = needShift and {'shift'} or {}
            
            -- Send key press and release
            hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
            hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
            
            return true -- Prevent original event
        end
        
        return false -- Don't handle other events
    end)
    
    return handler
end

-- Start event listener
local arrowRemapper = remapControlToArrow()
arrowRemapper:start()

-- spoon install
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

-- text clip board history, not used
Install:andUse("TextClipboardHistory",
  {
    disable = true,
    config = {
      show_in_menubar = false,
    },
    hotkeys = {
      toggle_clipboard = { { "cmd", "shift" }, "v" } },
    start = true
  }
)

Install:andUse("Cherry",
  {
    hotkeys = {
      start = { hyper, "t" } },
  }
)

Install:andUse("BingDaily",
  {
    config = {
      runAt = "21:00"
    },
    start = true
  }
)

--spoon.SpoonInstall.repos.PaperWM = {
    --url = "https://github.com/mogenson/PaperWM.spoon",
    --desc = "PaperWM.spoon repository",
    --branch = "release",
--}

--spoon.SpoonInstall:andUse("PaperWM", {
    --disable = true,
    --repo = "PaperWM",
    --config = { screen_margin = 16, window_gap = 2 },
    --start = true,
--})

--PaperWM = hs.loadSpoon("PaperWM")
--PaperWM:bindHotkeys({
    ---- switch to a new focused window in tiled grid
    --focus_left  = {hyper, "h"},
    --focus_right = {hyper, "l"},
    --focus_up    = {hyper, "k"},
    --focus_down  = {hyper, "j"},

    ---- move windows around in tiled grid
    --swap_left  = {hyper_shift, "h"},
    --swap_right = {hyper_shift, "l"},
    --swap_up    = {hyper_shift, "k"},
    --swap_down  = {hyper_shift, "j"},

    ---- position and resize focused window
    --center_window       = {hyper, "c"},
    --full_width          = {hyper, "f"},
    --cycle_width         = {hyper, ";"},
    --reverse_cycle_width = {hyper, "'"},
    --cycle_height        = {hyper, "["},
   --reverse_cycle_height = {hyper, "]"},

    ---- move focused window into / out of a column
    --slurp_in = {hyper, "i"},
    --barf_out = {hyper, "o"},

    ----- move the focused window into / out of the tiling layer
    --toggle_floating = {hyper, "escape"},

    ---- switch to a new Mission Control space
    --switch_space_1 = {hyper, "1"},
    --switch_space_2 = {hyper, "2"},
    --switch_space_3 = {hyper, "3"},
    --switch_space_4 = {hyper, "4"},
    --switch_space_5 = {hyper, "5"},
    --switch_space_6 = {hyper, "6"},
    --switch_space_7 = {hyper, "7"},
    --switch_space_8 = {hyper, "8"},
    --switch_space_9 = {hyper, "9"},

    ---- move focused window to a new space and tile
    --move_window_1 = {hyper_shift, "1"},
    --move_window_2 = {hyper_shift, "2"},
    --move_window_3 = {hyper_shift, "3"},
    --move_window_4 = {hyper_shift, "4"},
    --move_window_5 = {hyper_shift, "5"},
    --move_window_6 = {hyper_shift, "6"},
    --move_window_7 = {hyper_shift, "7"},
    --move_window_8 = {hyper_shift, "8"},
    --move_window_9 = {hyper_shift, "9"}
--})
--PaperWM:start()


-- this is for showing the current app's path, name and input method
hs.hotkey.bind({"ctrl", "cmd"}, ".", function()
  hs.pasteboard.setContents(hs.window.focusedWindow():application():path())
  hs.alert.show("App path:        " ..
  hs.window.focusedWindow():application():path() ..
  "\n" ..
  "App name:      " ..
  hs.window.focusedWindow():application():name() ..
  "\n" ..
  "IM source id:  " ..
  hs.keycodes.currentSourceID(), hs.alert.defaultStyle, hs.screen.mainScreen(), 3)
end)

-- this is for automatically switching input methods between apps
-- INPUT METHOD##################################################################
local function Chinese()
  hs.keycodes.currentSourceID("com.tencent.inputmethod.wetype.pinyin")
end

local function English()
  hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end

local appInputMethod = {
  iTerm2 = English,
  ['微信']  = Chinese,
  Raycast = English,
  QQ = Chinese,
  CLion = English,
  Code = English,
}


-- activated 时切换到指定的输入法
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        for app, fn in pairs(appInputMethod) do
            if app == appName then
                fn()
            end
        end
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher):start()

-- END HERE##################################################################

