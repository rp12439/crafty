
-- show settings menue for xml button
function Crafty.ShowSettings()
  LibAddonMenu2:OpenToPanel(CraftySettings)
end

-- build settings menue with libaddonmenu2
function Crafty.ControlSettings()
  Crafty.DB("Crafty: ControlSettings")
  local panelData = {
    type = "panel",
    name = "Crafty",
    displayName = "Crafty Stocklist",
    author = "rp12439",
    version = Crafty.version,
    slashCommand = "/craftysettings", --(optional) will register a keybind to open to this panel
    registerForRefresh = true,  --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true, --boolean (optional) (will set all options controls back to default values)
  }
    
  local optionsTable = {

    [1] = {
          type = "checkbox",
          name = "Show watchlist",
          tooltip = "This setting will open or close the watchlist",
          getFunc = function() return Crafty.showWL end,
          setFunc = function(value) Crafty.showWL = value Crafty.Check() end,
          default = true
    }, 
    [2] = {
          type = "checkbox",
          name = "Open on guildvendor",
          tooltip = "This setting will open the guildvendor watchlist when visiting a guildvendor",
          getFunc = function() return Crafty.vendorOpen end,
          setFunc = function(value) Crafty.vendorOpen = value Crafty.SavevendorOpen() end,
          width = "full",
          default = false
    }, 
    [3] = {
        type = "dropdown",
        name = "Guildvendor watchlist",
        tooltip = "Which watchlist to open on guildvendor open",
        choices = {1, 2, 3},
        getFunc = function() return Crafty.vendorwatchListID end,
        setFunc = function(value) Crafty.vendorwatchListID = value Crafty.SavevendorwatchListID() end,
        width = "full",
        default = 1
    },
    [4] = {
          type = "checkbox",
          name = "Close after guildvendor",
          tooltip = "This setting will close the watchlist when leaving a guildvendor, otherwise the previous opened watchlist will open.",
          getFunc = function() return Crafty.vendorClose end,
          setFunc = function(value) Crafty.vendorClose = value Crafty.SavevendorClose() end,
          width = "full",
          default = false
    }, 
    [5] = {
          type = "checkbox",
          name = "Autoheight watchlist",
          tooltip = "Automatically set the height of the watchlist",
          getFunc = function() return Crafty.autoHeightWLOpt end,
          setFunc = function(value) Crafty.autoHeightWLOpt = value Crafty.CheckAutoHeightWLOpt() end,
          default = true
    }, 
    [6] = {
          type = "checkbox",
          name = "Different watchlist positions",
          tooltip = "Save/restore position per watchlist",
          getFunc = function() return Crafty.differentWLPositions end,
          setFunc = function(value) Crafty.differentWLPositions = value Crafty.savedifferentWLPositions() end,
          default = true
    }, 
    [7] = {
        type = "slider",
        name = "Background opacity",
        tooltip = "Set overall background opacity",
        min = 0,
        max = 1,
        step = 0.1, --(optional)
        getFunc = function() return Crafty.masterAlpha end,
        setFunc = function(value) Crafty.masterAlpha = value Crafty.SetMasterAlpha() end,
        width = "full", --or "full" (optional)
        default = 0.5,  --(optional)
    },
    [8] = {
        type = "slider",
        name = "Windowheight",
        tooltip = "Set overall window height",
        min = 260,
        max = 1000,
        step = 10, --(optional)
        getFunc = function() return Crafty.masterHeight end,
        setFunc = function(value) Crafty.masterHeight = value Crafty.SetMasterHeight() end,
        width = "full", --or "full" (optional)
        default = 600,  --(optional)
    },
    
  }
  
    -- Create Keybindings 
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTY_STOCKLIST", "Show/Hide Watchlist")
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTY_STOCKLIST2", "Show Watchlist 1")
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTY_STOCKLIST3", "Show Watchlist 2")
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTY_STOCKLIST4", "Show Watchlist 3")
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTY_STOCKLIST5", "Reload Stockamounts")
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTY_STOCKLIST6", "Debugmode on/off")     
    
    -- Register the settingmenu
    LibAddonMenu2:RegisterAddonPanel("CraftySettings", panelData) 
    LibAddonMenu2:RegisterOptionControls("CraftySettings", optionsTable)
    
end