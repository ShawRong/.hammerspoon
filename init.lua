require('./modules/ring')

hyper = {"cmd", "alt", "ctrl", "shift"}

hs.hotkey.bind(hyper, "W", function()
  hs.alert.show("Hello World!")
end)


-- key mapping
hs.hotkey.bind({"ctrl"}, "J", function()
  hs.eventtap.keyStroke({}, "Down")
end)
hs.hotkey.bind({"ctrl"}, "K", function()
  hs.eventtap.keyStroke({}, "Up")
end)
hs.hotkey.bind({"ctrl"}, "H", function()
  hs.eventtap.keyStroke({}, "Left")
end)
hs.hotkey.bind({"ctrl"}, "l", function()
  hs.eventtap.keyStroke({}, "Right")
end)
hs.hotkey.bind({"ctrl"}, ";", function()
  hs.eventtap.keyStroke({}, "Backspace")
end)
hs.hotkey.bind({"ctrl"}, "0", function()
  hs.eventtap.keyStroke({}, "Home")
end)

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

