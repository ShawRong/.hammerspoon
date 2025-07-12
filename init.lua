require("./modules/ring")

hyper = { "cmd", "alt", "ctrl" }
hyper_shift = { "cmd", "alt", "ctrl", "shift" }
ctrl = { "ctrl" }

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
local function remapOption()
	local handler = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
		local flags = event:getFlags()
		local shift_marker = false

		local modifiersPresent = 0
		if flags.ctrl then
			modifiersPresent = modifiersPresent + 1
		end
		if flags.cmd then
			modifiersPresent = modifiersPresent + 1
		end
		if flags.shift then
			shift_marker = true
		end
		if flags.fn then
			modifiersPresent = modifiersPresent + 1
		end

		if not flags.alt or modifiersPresent > 1 then
			return false
		end

		local keycode = event:getKeyCode()
		local targetKeys = nil

		local keyMappings = {
			[hs.keycodes.map[","]] = { "9", true }, -- ( needs shift+9
			[hs.keycodes.map["."]] = { "0", true }, -- ) needs shift+0
			-- mapping add and minus
			[hs.keycodes.map["a"]] = { "=", true }, -- ) needs shift+=
			[hs.keycodes.map["d"]] = { "-" },

			-- mapping _ and =
			[hs.keycodes.map["s"]] = { "-", true },
			[hs.keycodes.map["f"]] = { "=" },

			-- for number mapping
			[hs.keycodes.map["q"]] = { "1", shift_marker },
			[hs.keycodes.map["w"]] = { "2", shift_marker },
			[hs.keycodes.map["e"]] = { "3", shift_marker },
			[hs.keycodes.map["r"]] = { "4", shift_marker },
			[hs.keycodes.map["t"]] = { "5", shift_marker },
			[hs.keycodes.map["y"]] = { "6", shift_marker },
			[hs.keycodes.map["u"]] = { "7", shift_marker },
			[hs.keycodes.map["i"]] = { "8", shift_marker },
			[hs.keycodes.map["o"]] = { "9", shift_marker },
			[hs.keycodes.map["p"]] = { "0", shift_marker },
		}

		local mapping = keyMappings[keycode]

		if mapping then
			local key, needShift = mapping[1], mapping[2]

			-- Create modifier flags if shift is needed
			local modifiers = needShift and { "shift" } or {}

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
local remap_option = remapOption()
remap_option:start()

-- key mapping
-- 高效的方向键映射（control）
local function remapControlToArrow()
	local handler = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
		local flags = event:getFlags()

		local modifiersPresent = 0
		if flags.alt then
			modifiersPresent = modifiersPresent + 1
		end
		if flags.cmd then
			modifiersPresent = modifiersPresent + 1
		end
		if flags.shift then
			modifiersPresent = modifiersPresent + 1
		end
		if flags.fn then
			modifiersPresent = modifiersPresent + 1
		end

		if not flags.ctrl or modifiersPresent > 1 then
			return false
		end

		local keycode = event:getKeyCode()
		local targetKeys = nil

		-- Map control keys to arrow keys and other functions
		local keyMappings = {
			[hs.keycodes.map["h"]] = { "left" },
			[hs.keycodes.map["j"]] = { "down" },
			[hs.keycodes.map["k"]] = { "up" },
			[hs.keycodes.map["l"]] = { "right" },
			[hs.keycodes.map[";"]] = { "delete" },
			[hs.keycodes.map["["]] = { "escape" },
		}

		local mapping = keyMappings[keycode]

		if mapping then
			local key, needShift = mapping[1], mapping[2]

			-- Create modifier flags if shift is needed
			local modifiers = needShift and { "shift" } or {}

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

local function mapRightCmdToHyper()
	-- 定义 Hyper 键的修饰键组合（Ctrl + Shift + Cmd + Opt）
	local HYPER_MODIFIERS = hyper

	-- 创建一个事件监听器，检测按键按下和释放
	local eventTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
		local flags = event:getFlags()
		local keyCode = event:getKeyCode()

		-- 检查是否是右 Command 键（keyCode 为 0x36）
		if keyCode == hs.keycodes.map["rightcmd"] then
			-- 如果是按下事件（flags 包含 cmd，且之前没有 cmd 按下）
			if flags.cmd and not eventTap._rightCmdDown then
				eventTap._rightCmdDown = true
				-- 发送 Hyper 键按下（模拟 Ctrl+Shift+Cmd+Opt）
				hs.eventtap.event.newKeyEvent(HYPER_MODIFIERS, "", true):post()
				return true -- 阻止原事件
			-- 如果是释放事件（flags 不再包含 cmd，且之前 cmd 是按下状态）
			elseif not flags.cmd and eventTap._rightCmdDown then
				eventTap._rightCmdDown = false
				-- 发送 Hyper 键释放
				hs.eventtap.event.newKeyEvent(HYPER_MODIFIERS, "", false):post()
				return true -- 阻止原事件
			end
		end

		return false -- 其他情况不处理
	end)

	-- 启动事件监听
	eventTap:start()

	return eventTap
end

-- 调用函数，激活映射
local hyperKeyMapper = mapRightCmdToHyper()

-- spoon install
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install = spoon.SpoonInstall

-- text clip board history, not used
Install:andUse("TextClipboardHistory", {
	disable = true,
	config = {
		show_in_menubar = false,
	},
	hotkeys = {
		toggle_clipboard = { { "cmd", "shift" }, "v" },
	},
	start = true,
})

Install:andUse("Cherry", {
	hotkeys = {
		start = { hyper, "t" },
	},
})

Install:andUse("BingDaily", {
	config = {
		runAt = "21:00",
	},
	start = true,
})

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
hs.hotkey.bind({ "ctrl", "cmd" }, ".", function()
	hs.pasteboard.setContents(hs.window.focusedWindow():application():path())
	hs.alert.show(
		"App path:        "
			.. hs.window.focusedWindow():application():path()
			.. "\n"
			.. "App name:      "
			.. hs.window.focusedWindow():application():name()
			.. "\n"
			.. "IM source id:  "
			.. hs.keycodes.currentSourceID(),
		hs.alert.defaultStyle,
		hs.screen.mainScreen(),
		3
	)
end)

-- Hammerspoon configuration for switching input methods
-- Add this to your ~/.hammerspoon/init.lua file

-- Get all available input methods
function getInputMethods()
    local methods = hs.keycodes.methods()
    for i, method in ipairs(methods) do
        print(i .. ": " .. method)
    end
    return methods
end

-- Get current input method
function getCurrentInputMethod()
    local currentMethod = hs.keycodes.currentMethod()
    print("Current input method: " .. currentMethod)
    return currentMethod
end

-- Define your input method names (you may need to adjust these based on your system)
local inputMethods = {
    english = "com.apple.keylayout.ABC",  -- or "com.apple.keylayout.US"
    chinese = "com.tencent.inputmethod.wetype.pinyin",  -- Updated to match your system
    japanese = "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"  -- or your Japanese input method
}

-- Function to switch to specific input method
function switchToInputMethod(language)
    local targetMethod = inputMethods[language]
    if targetMethod then
        local success = hs.keycodes.currentSourceID(targetMethod)
        if success then
            if language == "english" then
                hs.alert.show("Switched to English")
            elseif language == "chinese" then
                hs.alert.show("切换到中文输入法")
            elseif language == "japanese" then
                hs.alert.show("日本語入力に切り替えました")
            end
        else
            hs.alert.show("Failed to switch to " .. language)
        end
    else
        hs.alert.show("Input method not configured for " .. language)
    end
end

-- Bind hotkeys for specific input methods
-- Cmd + J for English
hs.hotkey.bind({"cmd"}, "j", function()
    switchToInputMethod("english")
end)

-- Cmd + ; for Chinese
hs.hotkey.bind({"cmd"}, ";", function()
    switchToInputMethod("chinese")
end)

-- Cmd + K for Japanese
hs.hotkey.bind({"cmd"}, "k", function()
    switchToInputMethod("japanese")
end)

-- Auto-switch input method based on application
-- Functions for input method switching
local function Chinese()
    hs.keycodes.currentSourceID("com.tencent.inputmethod.wetype.pinyin")
end

local function English()
    hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end

local function Japanese()
    hs.keycodes.currentSourceID("com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese")
end

-- Application to input method mapping
local appInputMethod = {
    iTerm2 = English,
    ["微信"] = Chinese,
    Raycast = English,
    QQ = Chinese,
    CLion = English,
    Code = English,
    -- Add more applications as needed
}

-- Application watcher function
function applicationWatcher(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        for app, fn in pairs(appInputMethod) do
            if app == appName then
                fn()
                -- Optional: Show notification for auto-switch
                -- hs.alert.show("Auto-switched input method for " .. appName)
            end
        end
    end
end

-- Start the application watcher
appWatcher = hs.application.watcher.new(applicationWatcher):start()

-- Function to set specific input method (updated for new structure)
function setInputMethod(language)
    switchToInputMethod(language)
end



-- Helper function to discover your input method names
function discoverInputMethods()
    print("Available input methods:")
    local methods = hs.keycodes.methods()
    for i, method in ipairs(methods) do
        print(i .. ": " .. method)
    end
    
    print("\nCurrent input method:")
    print(hs.keycodes.currentMethod())
    
    print("\nAvailable layouts:")
    local layouts = hs.keycodes.layouts()
    for i, layout in ipairs(layouts) do
        print(i .. ": " .. layout)
    end
end

-- Run this function once to see what input methods are available on your system
-- Uncomment the line below, reload Hammerspoon, then comment it out again
-- discoverInputMethods()

-- Quick toggle function for menu bar
function createInputMethodToggle()
    local menubar = hs.menubar.new()
    menubar:setTitle("IM")
    menubar:setMenu({
        { title = "Show Available Methods", fn = discoverInputMethods },
        { title = "-" },
        { title = "English (Cmd+J)", fn = function() switchToInputMethod("english") end },
        { title = "Chinese (Cmd+;)", fn = function() switchToInputMethod("chinese") end },
        { title = "Japanese (Cmd+K)", fn = function() switchToInputMethod("japanese") end },
    })
    return menubar
end

-- Create menu bar item (optional)
-- inputMethodMenubar = createInputMethodToggle()

print("Hammerspoon input method switching loaded!")
print("Hotkeys:")
print("  Cmd+J: Switch to English")
print("  Cmd+;: Switch to Chinese") 
print("  Cmd+K: Switch to Japanese")
print("Auto-switching enabled for configured applications")
print("Run discoverInputMethods() to see available input methods on your system")