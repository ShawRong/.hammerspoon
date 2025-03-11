hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.alert.show("Hello World!")
end)

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
