---------------------------------------------------------------------------------------- 
-- Global vars and constants
----------------------------------------------------------------------------------------

Crafty = {}
Crafty.name = "Crafty"
Crafty.version = "v1.5"
Crafty.showSL = false
Crafty.showWL = true
Crafty.ankerSL = true
Crafty.vendorOpen = false
Crafty.vendorClose = false
Crafty.showTS = false
Crafty.undoRemove = nil
Crafty.differentWLPositions = false
Crafty.db = false
Crafty.filterTypeSL = 1
Crafty.watchList1 = {}
Crafty.watchList2 = {}
Crafty.watchList3 = {}
Crafty.activewatchList = Crafty.watchList1
Crafty.activewatchListID = 1
Crafty.vendorwatchListID = 1
Crafty.oldactivewatchListID = 1
Crafty.oldshowWL = true
Crafty.masterHeight = 600
Crafty.masterWidth = 300
Crafty.autoHeightWL = 600
Crafty.autoHeightWLOpt = true
Crafty.masterAlpha = 1
Crafty.accountWide = false
Crafty.sortWLName = "down"
Crafty.sortWLAmount = "down"
Crafty.sortWL = "Name"
Crafty.sortSLName = "down"
Crafty.sortSLAmount = "down"
Crafty.sortSL = "Name"
Crafty.minModeWL1 = false
Crafty.minModeWL2 = false
Crafty.minModeWL3 = false

----------------------------------------------------------------------------------------
-- Init functions
----------------------------------------------------------------------------------------

-- initialize when addon was loaded
function Crafty.OnAddOnLoaded(event, addonName)
  if addonName == Crafty.name then
    Crafty.DB("Crafty: OnAddOnLoaded")
    Crafty:Initialize()
  end
end

-- initialize saved vars, positions, listdata and settings
function Crafty:Initialize()
  Crafty.DB("Crafty: Initialize")
    
  self.savedVariablesACC = ZO_SavedVars:NewAccountWide("CraftySavedVariablesACC", 1, nil, {})  
  
  if Crafty.savedVariablesACC.AccountWide ~= nil then Crafty.accountWide = Crafty.savedVariablesACC.AccountWide end  
    
  if not Crafty.accountWide then
    self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("CraftySavedVariables", 1, nil, {})
  else
    self.savedVariables = ZO_SavedVars:NewAccountWide("CraftySavedVariables", 1, nil, {})
  end
  
  if Crafty.savedVariables.AnkerSL ~= nil then Crafty.ankerSL = Crafty.savedVariables.AnkerSL end
  if Crafty.savedVariables.ShowSL ~= nil then Crafty.showSL = Crafty.savedVariables.ShowSL end
  if Crafty.savedVariables.ShowWL ~= nil then Crafty.showWL = Crafty.savedVariables.ShowWL end
  if Crafty.savedVariables.WatchList1 ~= nil then Crafty.watchList1 = Crafty.savedVariables.WatchList1 end
  if Crafty.savedVariables.WatchList2 ~= nil then Crafty.watchList2 = Crafty.savedVariables.WatchList2 end
  if Crafty.savedVariables.WatchList3 ~= nil then Crafty.watchList3 = Crafty.savedVariables.WatchList3 end
  if Crafty.savedVariables.ActivewatchList ~= nil then Crafty.activewatchList = Crafty.savedVariables.ActivewatchList end
  if Crafty.savedVariables.ActivewatchListID ~= nil then Crafty.activewatchListID = Crafty.savedVariables.ActivewatchListID end
  if Crafty.savedVariables.DifferentWLPositions ~= nil then Crafty.differentWLPositions = Crafty.savedVariables.DifferentWLPositions end
  if Crafty.savedVariables.VendorOpen ~= nil then Crafty.vendorOpen = Crafty.savedVariables.VendorOpen end
  if Crafty.savedVariables.VendorClose ~= nil then Crafty.vendorClose = Crafty.savedVariables.VendorClose end
  if Crafty.savedVariables.VendorwatchListID ~= nil then Crafty.vendorwatchListID = Crafty.savedVariables.VendorwatchListID end
  if Crafty.savedVariables.MasterAlpha ~= nil then Crafty.masterAlpha = Crafty.savedVariables.MasterAlpha end
  if Crafty.savedVariables.MasterHeight ~= nil then Crafty.masterHeight = Crafty.savedVariables.MasterHeight end
  if Crafty.savedVariables.AutoHeightWLOpt ~= nil then Crafty.autoHeightWLOpt = Crafty.savedVariables.AutoHeightWLOpt end
  if Crafty.savedVariables.SortWLName ~= nil then Crafty.sortWLName = Crafty.savedVariables.SortWLName end  
  if Crafty.savedVariables.SortSLName ~= nil then Crafty.sortSLName = Crafty.savedVariables.SortSLName end  
  if Crafty.savedVariables.SortWLAmount ~= nil then Crafty.sortWLAmount = Crafty.savedVariables.SortWLAmount end  
  if Crafty.savedVariables.SortSLAmount ~= nil then Crafty.sortSLAmount = Crafty.savedVariables.SortSLAmount end  
  if Crafty.savedVariables.SortWL ~= nil then Crafty.sortWL = Crafty.savedVariables.SortWL end  
  if Crafty.savedVariables.SortSL ~= nil then Crafty.sortSL = Crafty.savedVariables.SortSL end 
  if Crafty.savedVariables.MinModeWL1 ~= nil then Crafty.minModeWL1 = Crafty.savedVariables.MinModeWL1 end 
  if Crafty.savedVariables.MinModeWL2 ~= nil then Crafty.minModeWL2 = Crafty.savedVariables.MinModeWL2 end 
  if Crafty.savedVariables.MinModeWL3 ~= nil then Crafty.minModeWL3 = Crafty.savedVariables.MinModeWL3 end 
   
  Crafty:RestorePosition()
  Crafty.Check()
  Crafty.ControlSettings()
  
  Crafty.CreateScrollListDataTypeSL()
  local stockSL = Crafty.PopulateSL()
  local typeIdSL = 1
  Crafty.UpdateScrollListSL(CraftyStockListList, stockSL, typeIdSL)
  
  Crafty.CreateScrollListDataTypeWL()
  local stockWL = Crafty.PopulateWL()
  local typeIdWL = 2
  if table.getn(stockWL) ~= 0 then
    Crafty.UpdateScrollListWL(CraftyWatchListList, stockWL, typeIdWL)
  end
  
  Crafty.SetMasterHeight()
  Crafty.SetMasterAlpha()
  Crafty.SetTS(1)
  
  Crafty.SetActiveWatchList(Crafty.activewatchListID)
  Crafty.SortWLTexture()
  Crafty.SortSLTexture()
  
end

----------------------------------------------------------------------------------------
-- Modifiy the interface position / height
----------------------------------------------------------------------------------------

-- set overall interfaceheight (from settings)
function Crafty.SetMasterHeight()
  Crafty.DB("Crafty: SetMasterHeight")
  
  local width = Crafty.masterWidth
  local height = Crafty.masterHeight
  
  CraftyWatchList:SetWidth(width)
  CraftyWatchList:SetHeight(height)
  CraftyStockList:SetWidth(width)
  CraftyStockList:SetHeight(height)
  --CraftyStockListType:SetWidth(width)
  --CraftyStockListType:SetHeight(height)
  
  Crafty.savedVariables.MasterHeight = height
  Crafty.Refresh()
end

-- set overall backgroundalpha (from settings)
function Crafty.SetMasterAlpha()
  Crafty.DB("Crafty: SetMasterAlpha")
  
  CraftyWatchListBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListTypeBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListTooltipBG:SetAlpha(Crafty.masterAlpha)
  
  Crafty.savedVariables.MasterAlpha = Crafty.masterAlpha
end

-- save position data after moving the interface (from xml)
function Crafty.OnIndicatorMoveStop()
  Crafty.DB("Crafty: OnIndicatorMoveStop - WL"..Crafty.activewatchListID)

  Crafty.savedVariables.leftSL = CraftyStockList:GetLeft()
  Crafty.savedVariables.topSL = CraftyStockList:GetTop()

  if Crafty.differentWLPositions then
    if Crafty.activewatchListID == 1 then
      Crafty.savedVariables.leftWL1 = CraftyWatchList:GetLeft()
      Crafty.savedVariables.topWL1 = CraftyWatchList:GetTop()
    end
    if Crafty.activewatchListID == 2 then
      Crafty.savedVariables.leftWL2 = CraftyWatchList:GetLeft()
      Crafty.savedVariables.topWL2 = CraftyWatchList:GetTop()
    end
    if Crafty.activewatchListID == 3 then
      Crafty.savedVariables.leftWL3 = CraftyWatchList:GetLeft()
      Crafty.savedVariables.topWL3 = CraftyWatchList:GetTop()
    end
  else
    Crafty.savedVariables.leftWL = CraftyWatchList:GetLeft()
    Crafty.savedVariables.topWL = CraftyWatchList:GetTop()
  end
  
  if Crafty.ankerSL then
    Crafty.AnkerSL()
  end
end

-- set position for interface from saved vars and check for anchor stocklist
function Crafty:RestorePosition()
  Crafty.DB("Crafty: RestorePosition - WL"..Crafty.activewatchListID)
   
  if not Crafty.ankerSL then
    local leftSL = Crafty.savedVariables.leftSL
    local topSL = Crafty.savedVariables.topSL
    CraftyStockList:ClearAnchors()
    CraftyStockList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftSL, topSL)
    CraftyStockListButtonToggleAnkerSL:SetNormalTexture("esoui/art/miscellaneous/unlocked_up.dds")
    CraftyStockListButtonToggleAnkerSL:SetMouseOverTexture("esoui/art/miscellaneous/unlocked_over.dds")
    CraftyStockListButtonToggleAnkerSL:SetPressedTexture("esoui/art/miscellaneous/unlocked_down.dds")
  else
    Crafty.AnkerSL()
  end
end

function Crafty.ToggleMinMode()
  Crafty.DB("Crafty: ToggleMinMode - WL:"..Crafty.activewatchListID)
  local wl = Crafty.activewatchListID

  if wl == 1 then
    if Crafty.minModeWL1 then
      Crafty.minModeWL1 = false
      Crafty.savedVariables.MinModeWL1 = Crafty.minModeWL1
      Crafty.EndMinMode()
    else
      Crafty.minModeWL1 = true
      Crafty.savedVariables.MinModeWL1 = Crafty.minModeWL1
      Crafty.SetMinMode()
    end
  end
    if wl == 2 then
    if Crafty.minModeWL2 then
      Crafty.minModeWL2 = false
      Crafty.savedVariables.MinModeWL2 = Crafty.minModeWL2
      Crafty.EndMinMode()
    else
      Crafty.minModeWL2 = true
      Crafty.savedVariables.MinModeWL2 = Crafty.minModeWL2
      Crafty.SetMinMode()
    end
  end
    if wl == 3 then
    if Crafty.minModeWL3 then
      Crafty.minModeWL3 = false
      Crafty.savedVariables.MinModeWL3 = Crafty.minModeWL3
      Crafty.EndMinMode()
    else
      Crafty.minModeWL3 = true
      Crafty.savedVariables.MinModeWL3 = Crafty.minModeWL3
      Crafty.SetMinMode()
    end
  end
  Crafty.Refresh()
end

function Crafty.SetMinMode()
  Crafty.DB("Crafty: SetMinMode - WL:"..Crafty.activewatchListID)
  CraftyWatchListWatchList1:SetHidden(true)
  CraftyWatchListWatchList2:SetHidden(true)
  CraftyWatchListWatchList3:SetHidden(true)
  CraftyWatchListButtonClose:SetHidden(true)
  CraftyWatchListButtonSettings:SetHidden(true)
  CraftyWatchListButtonStockList:SetHidden(true)
  CraftyWatchListDivider:SetHidden(true)
  CraftyWatchListSortName:SetHidden(true)
  CraftyWatchListSortAmount:SetHidden(true)
  CraftyWatchList:SetWidth(115)
  
  CraftyWatchListList:SetAnchor(TOPLEFT, CraftyWatchList, TOPLEFT, 10, 10)
  Crafty.SetHeightWL()
end

function Crafty.EndMinMode()
  Crafty.DB("Crafty: EndMinMode - WL:"..Crafty.activewatchListID)
  CraftyWatchListWatchList1:SetHidden(false)
  CraftyWatchListWatchList2:SetHidden(false)
  CraftyWatchListWatchList3:SetHidden(false)
  CraftyWatchListButtonClose:SetHidden(false)
  CraftyWatchListButtonSettings:SetHidden(false)
  CraftyWatchListButtonStockList:SetHidden(false)
  CraftyWatchListDivider:SetHidden(false)
  CraftyWatchListSortName:SetHidden(false)
  CraftyWatchListSortAmount:SetHidden(false)
  CraftyWatchList:SetWidth(300)

  CraftyWatchListList:SetAnchor(TOPLEFT, CraftyWatchListDivider, BOTTOMLEFT, 0, 10)
  Crafty.SetHeightWL()
end

-- restore saved position for specific watchlist
function Crafty.RestoreWLPosition(arg)
  Crafty.DB("Crafty: RestoreWLPosition - WL"..arg)
  
  if Crafty.differentWLPositions then
    if arg == 1 then
      local leftWL = Crafty.savedVariables.leftWL1
      local topWL = Crafty.savedVariables.topWL1
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
    if arg == 2 then
      local leftWL = Crafty.savedVariables.leftWL2
      local topWL = Crafty.savedVariables.topWL2
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
    if arg == 3 then
      local leftWL = Crafty.savedVariables.leftWL3
      local topWL = Crafty.savedVariables.topWL3
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
  else
    if Crafty.savedVariables.leftWL ~= nil then -- only if its not the first time wihout saved pos vars
      local leftWL = Crafty.savedVariables.leftWL
      local topWL = Crafty.savedVariables.topWL
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
  end
  
end

-- calculate the autoheight for the watchlist, sets the global var
function Crafty.CalculateHeightWL()
  Crafty.DB("Crafty: CalculateHeightWL")
  local watchList = Crafty.activewatchList
  local watchlistItems = table.getn(watchList)
  local watchListID = Crafty.activewatchListID
  local minmode = false
  
  if watchListID == 1 then minmode = Crafty.minModeWL1 end
  if watchListID == 2 then minmode = Crafty.minModeWL2 end
  if watchListID == 3 then minmode = Crafty.minModeWL3 end
  
  if minmode then
    Crafty.autoHeightWL = 20+watchlistItems*30
  else
    Crafty.autoHeightWL = 70+watchlistItems*30
  end
end

-- sets the autoheight value to the xml element watchlist
function Crafty.SetHeightWL()
  if Crafty.autoHeightWLOpt then
    Crafty.DB("Crafty: SetHeightWL")
    Crafty.CalculateHeightWL()
    --local width = Crafty.masterWidth
    local height = Crafty.autoHeightWL
    
    --CraftyWatchList:SetWidth(width)
    CraftyWatchList:SetHeight(height)
  end
end

-- refreshes the autoheight or sets the masterheight for the watchlist (from settings)
function Crafty.CheckAutoHeightWLOpt()
  if Crafty.autoHeightWLOpt then
    Crafty.SetHeightWL()
  else
    Crafty.SetMasterHeight()
  end
  Crafty.savedVariables.AutoHeightWLOpt = Crafty.autoHeightWLOpt
end

----------------------------------------------------------------------------------------
-- Listdatahandling
----------------------------------------------------------------------------------------

-- create datatype for scrollist stocklist
function Crafty.CreateScrollListDataTypeSL()
  Crafty.DB("Crafty: CreateScrollListDataTypeSL")
  local control = CraftyStockListList
  local typeId = 1
  local templateName = "StockRow"
  local height = 30
  local setupFunction = Crafty.LayoutRow
  local hideCallback = nil
  local dataTypeSelectSound = nil
  local resetControlCallback = nil
  --local selectTemplate = "ZO_ThinListHighlight"
  --local selectCallback = Crafty.OnMouseUp
  
  ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
  --ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

-- create datatype for scrollist watchlist
function Crafty.CreateScrollListDataTypeWL()
  Crafty.DB("Crafty: CreateScrollListDataTypeWL")
  local control = CraftyWatchListList
  local typeId = 2
  local templateName = "WatchRow"
  local height = 30
  local setupFunction = Crafty.LayoutRow
  local hideCallback = nil
  local dataTypeSelectSound = nil
  local resetControlCallback = nil
  --local selectTemplate = "ZO_ThinListHighlight"
  --local selectCallback = Crafty.OnMouseUp
  
  ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
  --ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

-- set the active watchlist (from xml)
function Crafty.SetActiveWatchList(arg)
  Crafty.DB("Crafty: SetActiveWatchList: "..arg)
  local mydefcolor = ZO_ColorDef:New("CFDCBD")
  
  CraftyWatchListWatchList1:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList2:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList3:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList1:SetFont("ZoFontWinH4")
  CraftyWatchListWatchList2:SetFont("ZoFontWinH4")
  CraftyWatchListWatchList3:SetFont("ZoFontWinH4")
  
  if arg == 1 then
    Crafty.DB(Crafty.minModeWL1)
    CraftyWatchListWatchList1:SetColor(1,1,1)
    CraftyWatchListWatchList1:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList1
    if Crafty.minModeWL1 then Crafty.SetMinMode() else Crafty.EndMinMode() end
  end
  if arg == 2 then
    CraftyWatchListWatchList2:SetColor(1,1,1)
    CraftyWatchListWatchList2:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList2
    if Crafty.minModeWL2 then Crafty.SetMinMode() else Crafty.EndMinMode() end
  end
  if arg == 3 then
    CraftyWatchListWatchList3:SetColor(1,1,1)
    CraftyWatchListWatchList3:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList3
    if Crafty.minModeWL3 then Crafty.SetMinMode() else Crafty.EndMinMode() end
  end
  
  Crafty.savedVariables.ActivewatchList = Crafty.activewatchList
  Crafty.savedVariables.ActivewatchListID = arg
  Crafty.activewatchListID = arg
  
  Crafty.RestoreWLPosition(arg)
  Crafty.Refresh()
end

-- set the global var for material type for the typelist
function Crafty.SetTS(arg)
  Crafty.DB("Crafty: SetTS")
  local myoldTS = Crafty.filterTypeSL
  local myTS = arg
  Crafty.filterTypeSL = myTS

  CraftyStockListTypeAlchemyIcon:SetState(0,false)
  CraftyStockListTypeBlacksmithingIcon:SetState(0,false)
  CraftyStockListTypeClothierIcon:SetState(0,false)
  CraftyStockListTypeEnchantingIcon:SetState(0,false)
  CraftyStockListTypeJewelryIcon:SetState(0,false)
  CraftyStockListTypeProvisioningIcon:SetState(0,false)
  CraftyStockListTypeWoodworkingIcon:SetState(0,false)
  CraftyStockListTypeMatsIcon:SetState(0,false)
  
  if         arg == 0 then CraftyStockListTypeMatsIcon:SetState(1,false)
      elseif arg == 1 then CraftyStockListTypeBlacksmithingIcon:SetState(1,false)
      elseif arg == 2 then CraftyStockListTypeClothierIcon:SetState(1,false)
      elseif arg == 3 then CraftyStockListTypeEnchantingIcon:SetState(1,false)
      elseif arg == 4 then CraftyStockListTypeAlchemyIcon:SetState(1,false)
      elseif arg == 5 then CraftyStockListTypeProvisioningIcon:SetState(1,false)
      elseif arg == 6 then CraftyStockListTypeWoodworkingIcon:SetState(1,false)
      elseif arg == 7 then CraftyStockListTypeJewelryIcon:SetState(1,false)
      else
  end
  
  Crafty.Refresh()
end

-- fill the stocklist with data, uses the global var from materialtype
function Crafty.PopulateSL()
  Crafty.DB("Crafty: PopulateSL")
  local type = Crafty.filterTypeSL
  local stock = {}
  local stockcounter = 0

  for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
    if data ~= nil then
      if GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex) == type then
        stockcounter = stockcounter + 1
        stock[stockcounter] = {
          link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
          name = GetItemName(BAG_VIRTUAL,data.slotIndex),
          amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
          cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
        }
      end
    end
  end
  return stock
end

-- fill the watchlist with data, uses active watchlist and also calls
-- refreshes the amounts, calling the autoheight value
function Crafty.PopulateWL()
  local watchList = Crafty.activewatchList
  Crafty.DB("Crafty: PopulateWL Items:"..table.getn(watchList))
  Crafty.RefreshWLAmounts()
  local stock = {}
  for i=1,table.getn(watchList) do
    stock[i] = {
      link = watchList[i].link,
      name = watchList[i].name,
      amount = watchList[i].amount,
      cinfo = watchList[i].cinfo
    }
  end
  Crafty.SetHeightWL()
  return stock
end

-- sorts the listdata, saves the data and commits the data to the scrollinglist stocklist
function Crafty.UpdateScrollListSL(control, data, rowType)
  Crafty.DB("Crafty: UpdateScrollListSL "..table.getn(data))
  
  local dataCopy = ZO_DeepTableCopy(data)
  local dataList = ZO_ScrollList_GetDataList(control)
  
  ZO_ScrollList_Clear(control)
   
  for key, value in ipairs(dataCopy) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataList, entry)
  end
  
  if Crafty.sortSL == "Name" then
    if Crafty.sortSLName == "up" then
      table.sort(dataList, function(a,b) return a.data.name < b.data.name end)
    end
    if Crafty.sortSLName == "down" then
      table.sort(dataList, function(a,b) return a.data.name > b.data.name end)
    end
  end
  if Crafty.sortSL == "Amount" then
    if Crafty.sortSLAmount == "up" then
      table.sort(dataList, function(a,b) return a.data.amount < b.data.amount end)
    end
    if Crafty.sortSLAmount == "down" then
      table.sort(dataList, function(a,b) return a.data.amount > b.data.amount end)
    end
  end
  
  ZO_ScrollList_Commit(control)
  
  if Crafty.activewatchList == Crafty.watchList1 then
    Crafty.savedVariables.WatchList1 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList2 then
    Crafty.savedVariables.WatchList2 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList3 then
    Crafty.savedVariables.WatchList3 = Crafty.activewatchList
  end
end

-- sorts the listdata, saves the data and commits the data to the scrollinglist watchlist
function Crafty.UpdateScrollListWL(control, data, rowType)
  Crafty.DB("Crafty: UpdateScrollListWL "..table.getn(data))

  local dataCopyWL = ZO_DeepTableCopy(data)
  local dataListWL  = ZO_ScrollList_GetDataList(control)
  
  ZO_ScrollList_Clear(control)
  
  for key, value in ipairs(dataCopyWL) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataListWL, entry)
  end
  
  if Crafty.sortWL == "Name" then
    if Crafty.sortWLName == "up" then
      table.sort(dataListWL, function(a,b) return a.data.name < b.data.name end)
    end
    if Crafty.sortWLName == "down" then
      table.sort(dataListWL, function(a,b) return a.data.name > b.data.name end)
    end
  end
  if Crafty.sortWL == "Amount" then
    if Crafty.sortWLAmount == "up" then
      table.sort(dataListWL, function(a,b) return a.data.amount < b.data.amount end)
    end
    if Crafty.sortWLAmount == "down" then
      table.sort(dataListWL, function(a,b) return a.data.amount > b.data.amount end)
    end
  end

  ZO_ScrollList_Commit(control)
  
  if Crafty.activewatchList == Crafty.watchList1 then
    Crafty.savedVariables.WatchList1 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList2 then
    Crafty.savedVariables.WatchList2 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList3 then
    Crafty.savedVariables.WatchList3 = Crafty.activewatchList
  end
end

-- fills the xml rows with the data from the scrolllists
function Crafty.LayoutRow(rowControl, data, scrollList)
  Crafty.DB("Crafty: LayoutRow")
  
  rowControl.data = data
  rowControl.icon = GetControl(rowControl, "Icon")
  rowControl.name = GetControl(rowControl, "Name")
  rowControl.amount = GetControl(rowControl, "Amount")
  
  rowControl.icon:SetTexture(GetItemLinkIcon(data.link))
  rowControl.name:SetText(data.link)
  rowControl.amount:SetText(data.amount)
    
  rowControl.name:SetHidden(false)
  rowControl.name:SetWidth(175)
  
  -- change appearance for minMode
  if scrollList == CraftyWatchListList then
    if Crafty.activewatchListID == 1 and Crafty.minModeWL1 then rowControl.name:SetHidden(true) rowControl.name:SetWidth(1) end
    if Crafty.activewatchListID == 2 and Crafty.minModeWL2 then rowControl.name:SetHidden(true) rowControl.name:SetWidth(1) end
    if Crafty.activewatchListID == 3 and Crafty.minModeWL3 then rowControl.name:SetHidden(true) rowControl.name:SetWidth(1) end
  end
  
end

----------------------------------------------------------------------------------------
-- Listdatahandling dataupdates
----------------------------------------------------------------------------------------

-- eventmanager target for several inventory change events
function Crafty.InvChange()
  Crafty.DB("Crafty: InvChange")
  Crafty.DB(quantity)
  Crafty.Refresh()
end

-- refreshs the listdata
function Crafty.Refresh()
  Crafty.DB("Crafty: Refresh")

  local typeIdSL = 1
  local stockSL = Crafty.PopulateSL()
  Crafty.UpdateScrollListSL(CraftyStockListList, stockSL, typeIdSL)
  
  local typeIdWL = 2
  local stockWL = Crafty.PopulateWL()
  Crafty.UpdateScrollListWL(CraftyWatchListList, stockWL, typeIdWL)
end

-- refreshs the listdata and removes the savedvar for the undoitem (from xml)
function Crafty.FullRefresh()
  Crafty.DB("Crafty: FullRefresh")

  Crafty.undoRemove = nil
  Crafty.CheckUndo()

  local typeIdSL = 1
  local stockSL = Crafty.PopulateSL()
  Crafty.UpdateScrollListSL(CraftyStockListList, stockSL, typeIdSL)
  
  local typeIdWL = 2
  local stockWL = Crafty.PopulateWL()
  Crafty.UpdateScrollListWL(CraftyWatchListList, stockWL, typeIdWL)
end

-- refreshs the watchlist amountdata
function Crafty.RefreshWLAmounts()
  Crafty.DB("Crafty: RefreshWLAmounts")
  local stocklist = Crafty.PopulateCompleteStock()
  local watchlist = Crafty.activewatchList
  for i=1,table.getn(watchlist) do
    local name = watchlist[i].name
    local stockamount = Crafty.ReturnStockListItemAmount(name,stocklist)
    --Crafty.DB(name)
    --Crafty.DB(stockamount)
    watchlist[i].amount = stockamount
    -- this amount can be 0 and will be set to 0
    -- at this point future actions can react to 0 amounts in watchlist
  end
end

----------------------------------------------------------------------------------------
-- Functions to call from events, xml (buttons) or settings
----------------------------------------------------------------------------------------

-- close or hide the interface (from settings) this is not a toggle!
function Crafty.Check()
  Crafty.DB("Crafty: Check")
  if Crafty.showWL then
      Crafty.OpenWL()
  else 
      Crafty.CloseWL()
  end
end

-- open interface on vendor if set (called from eventmanager)
function Crafty.EventCheckVendorOpen()
  Crafty.DB("Crafty: EventCheckVendorOpen")
  Crafty.DB(Crafty.vendorwatchListID)
  if Crafty.vendorOpen then -- open vendorwatchlist if setting is on / else do nothing
    Crafty.oldactivewatchListID = Crafty.activewatchListID
    Crafty.oldshowWL = Crafty.showWL
    Crafty.OpenWL(Crafty.vendorwatchListID)
  end
end

-- close interface on vendor if set (called from eventmanager)
function Crafty.EventCheckVendorClose()
  Crafty.DB("Crafty: EventCheckVendorClose")
  --d(Crafty.oldshowWL)
  if Crafty.vendorOpen then -- only do something if vendorOpen setting is on
    if Crafty.vendorClose then -- close watchlist is on
      Crafty.CloseWL() -- close watchlist
      Crafty.SetActiveWatchList(Crafty.oldactivewatchListID) -- set active watchlist to previous in case user opens watchlist later
    else -- close watchlist is off -> switch to previous watchlist but only if the previous was shown
      if Crafty.oldshowWL then
        Crafty.CloseSL()
        Crafty.OpenWL(Crafty.oldactivewatchListID)
      else -- close the watchlist cause the switch was not performed
        Crafty.CloseWL()
        Crafty.SetActiveWatchList(Crafty.oldactivewatchListID)
      end
    end
  end 
end

-- Disable Setting "Close after guildvendor" if vendorOpen == false
function Crafty.CheckVendorClose()
  Crafty.DB("Crafty: CheckVendorClose")
  --Crafty.DB(Crafty.vendorClose)
  if not Crafty.vendorOpen then
    Crafty.vendorClose = false
    Crafty.SavevendorClose()
    return false
  end
  return Crafty.vendorClose
end

-- Save setting "Open on guildvendor"
function Crafty.SavevendorOpen()
  Crafty.DB("Crafty: SavevendorOpen")
  --Crafty.DB(Crafty.vendorOpen)
  Crafty.savedVariables.VendorOpen = Crafty.vendorOpen
end

-- Save setting "Close after guildvendor"
function Crafty.SavevendorClose()
  Crafty.DB("Crafty: SavevendorClose")
  Crafty.savedVariables.VendorClose = Crafty.vendorClose
end

-- Save setting "Guildvendor watchlist"
function Crafty.SavevendorwatchListID()
  Crafty.DB("Crafty: SavevendorwatchListID")
  Crafty.savedVariables.VendorwatchListID = Crafty.vendorwatchListID
end

-- Save setting "Different watchlist positions"
function Crafty.SavedifferentWLPositions()
  Crafty.DB("Crafty: savedifferentWLPositions")
  Crafty.savedVariables.DifferentWLPositions = Crafty.differentWLPositions
end

-- Save setting "Accountwide settings"
function Crafty.SaveaccountWide()
  Crafty.DB("Crafty: SaveaccountWide")
  Crafty.savedVariablesACC.AccountWide = Crafty.accountWide
  --ReloadUI("ingame")
end

-- Sort WL Initial (set texture)
function Crafty.SortWLTexture()
  Crafty.DB("Crafty: SortWLTexture")
  if Crafty.sortWL == "Name" then
    if Crafty.sortWLName == "up" then
      CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  else
    if Crafty.sortWLAmount == "up" then
      CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  end
end

-- Sort WL Name
function Crafty.SortWLName()
  Crafty.DB("Crafty: SortWLName")
  Crafty.sortWL = "Name"
  Crafty.sortWLAmount = "down"
  CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortWLName == "up" then
    Crafty.sortWLName = "down"
    CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortWLName = "up"
    CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortWL = Crafty.sortWL
  Crafty.savedVariables.SortWLName = Crafty.sortWLName
  Crafty.savedVariables.SortWLAmount = Crafty.sortWLAmount
  Crafty.Refresh()
end

-- Sort WL Amount
function Crafty.SortWLAmount()
  Crafty.DB("Crafty: SortWLAmount")
  Crafty.sortWL = "Amount"
  Crafty.sortWLName = "down"
  CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortWLAmount == "up" then
    Crafty.sortWLAmount = "down"
    CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortWLAmount = "up"
    CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortWL = Crafty.sortWL
  Crafty.savedVariables.SortWLAmount = Crafty.sortWLAmount
  Crafty.savedVariables.SortWLName = Crafty.sortWLName
  Crafty.Refresh()
end

-- Sort SL Initial (set texture)
function Crafty.SortSLTexture()
  Crafty.DB("Crafty: SortSLTexture")
  if Crafty.sortSL == "Name" then
    if Crafty.sortSLName == "up" then
      CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  else
    if Crafty.sortSLAmount == "up" then
      CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  end
end

-- Sort SL Name
function Crafty.SortSLName()
  Crafty.DB("Crafty: SortSLName")
  Crafty.sortSL = "Name"
  Crafty.sortSLAmount = "down"
  CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortSLName == "up" then
    Crafty.sortSLName = "down"
    CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortSLName = "up"
    CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortSL = Crafty.sortSL
  Crafty.savedVariables.SortSLName = Crafty.sortSLName
  Crafty.savedVariables.SortSLAmount = Crafty.sortSLAmount
  Crafty.Refresh()
end

-- Sort SL Amount
function Crafty.SortSLAmount()
  Crafty.DB("Crafty: SortSLAmount")
  Crafty.sortSL = "Amount"
  Crafty.sortSLName = "down"
  CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortSLAmount == "up" then
    Crafty.sortSLAmount = "down"
    CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortSLAmount = "up"
    CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortSL = Crafty.sortSL
  Crafty.savedVariables.SortSLAmount = Crafty.sortSLAmount
  Crafty.savedVariables.SortSLName = Crafty.sortSLName
  Crafty.Refresh()
end

-- show or hide stocklist (from xml)
function Crafty.ToggleSL()
  Crafty.DB("Crafty: ToggleSL")
  if Crafty.showSL then
    Crafty.CloseSL()
  else
    Crafty.OpenSL()
  end
end

-- show or hide watchlist (from keybinding)
function Crafty.ToggleWL()
  Crafty.DB("Crafty: ToggleWL")
  if Crafty.showWL then
    Crafty.CloseWL()
  else
    Crafty.OpenWL()
  end
end

-- anker the stocklist to watchlist
function Crafty.AnkerSL()
  Crafty.DB("Crafty: AnkerSL")
  CraftyStockList:ClearAnchors()
  CraftyStockList:SetAnchor(TOPRIGHT, CraftyWatchList, TOPLEFT, -15 ,0)
end

-- set anker on or off, also sets the texture
function Crafty.ToggleAnkerSL()
  Crafty.DB("Crafty: ToggleAnkerSL")
  if Crafty.ankerSL then
    Crafty.ankerSL = false
    Crafty.savedVariables.AnkerSL = false
    
    CraftyStockListButtonToggleAnkerSL:SetNormalTexture("esoui/art/miscellaneous/unlocked_up.dds")
    CraftyStockListButtonToggleAnkerSL:SetMouseOverTexture("esoui/art/miscellaneous/unlocked_over.dds")
    CraftyStockListButtonToggleAnkerSL:SetPressedTexture("esoui/art/miscellaneous/unlocked_down.dds")

  else
    Crafty.ankerSL = true
    Crafty.savedVariables.AnkerSL = true
    
    CraftyStockListButtonToggleAnkerSL:SetNormalTexture("esoui/art/miscellaneous/locked_up.dds")
    CraftyStockListButtonToggleAnkerSL:SetMouseOverTexture("esoui/art/miscellaneous/locked_over.dds")
    CraftyStockListButtonToggleAnkerSL:SetPressedTexture("esoui/art/miscellaneous/locked_down.dds")
    
    Crafty.AnkerSL()
  end
end

---- show or hide the typewindow (depricated)
--function Crafty.ToggleTS()
--  Crafty.DB("Crafty: ToggleTS")
--  if Crafty.showTS then
--    Crafty.CloseTS()
--  else
--    Crafty.OpenTS()
--  end
--end

-- hide the typewindow
function Crafty.CloseTS()
  Crafty.DB("Crafty: CloseTS")
  CraftyStockListType:SetHidden(true)
  Crafty.showTS = false
end

-- show the typewindow
function Crafty.OpenTS()
  Crafty.DB("Crafty: OpenTS")
  CraftyStockListType:SetHidden(false)
  Crafty.showTS = true
end

-- close the stocklist and typewindow
function Crafty.CloseSL()
  Crafty.DB("Crafty: CloseSL")
  CraftyStockList:SetHidden(true)
  Crafty.showSL = false
  Crafty.savedVariables.ShowSL = false
  Crafty.CloseTS()
end

-- show the stocklist and typewindow
function Crafty.OpenSL()
  Crafty.DB("Crafty: OpenSL")
  CraftyStockList:SetHidden(false)
  Crafty.showSL = true
  Crafty.savedVariables.ShowSL = true
  Crafty.OpenTS()
end

-- close the watchlist, stocklist and typewindow
function Crafty.CloseWL()
  Crafty.DB("Crafty: CloseWL")
  CraftyWatchList:SetHidden(true)
  Crafty.showWL = false
  Crafty.savedVariables.ShowWL = false
  CraftyStockList:SetHidden(true)
  Crafty.showSL = false
  Crafty.savedVariables.ShowSL = false
  Crafty.CloseSL()
  Crafty.CloseTS()
  Crafty.undoRemove = nil
  Crafty.CheckUndo()
end

-- open the watchlist
function Crafty.OpenWL(arg)
  Crafty.DB("Crafty: OpenWL")
  if arg ~= nil then
    Crafty.SetActiveWatchList(arg)
    -- in case that the stocklist is open and the ui reloaded. after reload this opens the
    -- watchlist and the stocklist is still true but not visible.
    -- stocklist button does not open the list in this case.
    Crafty.showSL = false
    Crafty.savedVariables.ShowSL = false 
  end
    CraftyWatchList:SetHidden(false)
    Crafty.showWL = true
    Crafty.savedVariables.ShowWL = true
    Crafty.showSL = false
    Crafty.savedVariables.ShowSL = false 
end

-- OnMouseEnter watchlist row
function Crafty.OnMouseEnterWL(control)
  --Crafty.DB("Crafty: OnMouseEnterWL")
  CraftyStockListTooltip:SetHidden(false)
  CraftyStockListTooltip:SetHeight(500)
  if not Crafty.showSL or not Crafty.ankerSL then
    CraftyStockListTooltip:ClearAnchors()
    CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -25, 0)
  else
    CraftyStockListTooltip:ClearAnchors()
    CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, 35, 0)
  end
  
  local itemIcon = GetItemLinkIcon(control.data.link)
  CraftyStockListTooltipItemIcon:SetTexture(itemIcon)
  
  local itemLink = control.data.link
  CraftyStockListTooltipItemLink:SetText(itemLink)
 
  local traitText = ""
  if GetItemLinkTraitType(control.data.link) ~= 0 then
    local traitType = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitType(control.data.link))
    traitText =" ("..traitType..")"
  end
  local itemType = GetString("SI_ITEMTYPE", GetItemLinkItemType(control.data.link))
  CraftyStockListTooltipItemType:SetText(itemType..traitText)
  
  local itemFlavor = GetItemLinkFlavorText(control.data.link)
  CraftyStockListTooltipItemFlavor:SetText(itemFlavor)
  
  local itemFlavorTextHeight = CraftyStockListTooltipItemFlavor:GetTextHeight()
  
  CraftyStockListTooltip:SetHeight(110+itemFlavorTextHeight)
  
end

-- OnMouseExit watchlist row
function Crafty.OnMouseExitWL(control)
  --Crafty.DB("Crafty: OnMouseExitWL")
  CraftyStockListTooltip:SetHidden(true)
end

-- OnMouseEnter stocklist row (in case that this can be different from watchlist)
function Crafty.OnMouseEnterSL(control)
  --Crafty.DB("Crafty: OnMouseEnterSL")
  CraftyStockListTooltip:SetHidden(false)
  CraftyStockListTooltip:SetHeight(500)
  CraftyStockListTooltip:ClearAnchors()
  CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -25, 0)
  
  local itemIcon = GetItemLinkIcon(control.data.link)
  CraftyStockListTooltipItemIcon:SetTexture(itemIcon)
  
  local itemLink = control.data.link
  CraftyStockListTooltipItemLink:SetText(itemLink)
  
  local traitText = ""
  if GetItemLinkTraitType(control.data.link) ~= 0 then
    local traitType = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitType(control.data.link))
    traitText =" ("..traitType..")"
  end
  local itemType = GetString("SI_ITEMTYPE", GetItemLinkItemType(control.data.link))
  CraftyStockListTooltipItemType:SetText(itemType..traitText)
  
  local itemFlavor = GetItemLinkFlavorText(control.data.link)
  CraftyStockListTooltipItemFlavor:SetText(itemFlavor)
  
  local itemFlavorTextHeight = CraftyStockListTooltipItemFlavor:GetTextHeight()
  
  CraftyStockListTooltip:SetHeight(110+itemFlavorTextHeight)
  
end

-- OnMouseExit stocklist row (in case that this can be different from watchlist)
function Crafty.OnMouseExitSL(control)
  --Crafty.DB("Crafty: OnMouseExitSL")
  CraftyStockListTooltip:SetHidden(true)
end

----------------------------------------------------------------------------------------
-- Functions for modifying the listdata (add items, remove, undo)
----------------------------------------------------------------------------------------

-- adds an item to the watchlist, function for calling from xml (stocklist)
function Crafty.OnMouseUpSL(control, button, upInside)
  Crafty.AddItemToWatchList(control)
end

-- removes an item from the watchlist, function for calling from xml (watchlist)
function Crafty.OnMouseUpWL(control, button, upInside)
  Crafty.RemoveItemFromWatchList(control)
end

-- adds an item to the watchlist, only if its not there, undoitem removed, updated icons on interface
function Crafty.AddItemToWatchList(control)
  Crafty.DB("Crafty: AddItemToWatchList")
  local name = control.data.name
  local watchList = Crafty.activewatchList
  local size = table.getn(watchList)

  local found = Crafty.CheckItemInWatchList(control.data.name)
  
  if not found then
    watchList[size+1] = {
        link = control.data.link,
        name = control.data.name,
        amount = control.data.amount,
        cinfo = control.data.cinfo
      }
      Crafty.undoRemove = nil
      Crafty.CheckUndo()
  end
  
  Crafty.DB("Crafty: Added "..name.." at #"..table.getn(watchList))
  --Crafty.DBPrintWatchList()
  Crafty.Refresh()  
end

-- removes an item from the watchlist
function Crafty.RemoveItemFromWatchList(control)
  Crafty.DB("Crafty: RemoveItemFromWatchList")
  local name=control.data.name
  local watchList = Crafty.activewatchList
  for i=1,table.getn(watchList) do
    if watchList[i].name == name then
      Crafty.DB("Crafty: Removed "..name.." at #"..i)
      Crafty.undoRemove = (watchList[i])
      Crafty.CheckUndo()
      table.remove(watchList, i)
      break
    end
  end
  --Crafty.DBPrintWatchList()
  Crafty.Refresh()
end

-- checks if there is an undoitem and sets the button in xml
function Crafty.CheckUndo()
  Crafty.DB("Crafty: CheckUndo")
  if Crafty.undoRemove ~= nil then
    CraftyWatchListButtonUndo:SetHidden(false)
  else
    CraftyWatchListButtonUndo:SetHidden(true)
  end
end

-- adds the item from the undovar, if its not allready there
function Crafty.UndoRemove()
  Crafty.DB("Crafty: UndoRemove")
  local found = Crafty.CheckItemInWatchList(Crafty.undoRemove.name)
  if Crafty.undoRemove ~= nil then
    if not found then
      table.insert(Crafty.activewatchList, Crafty.undoRemove)
    else
      return
    end
  end
  Crafty.undoRemove = nil
  Crafty.CheckUndo()
  Crafty.Refresh()
end

-- helper function to check if an item is in the watchlist (the name!)
function Crafty.CheckItemInWatchList(control)
  Crafty.DB("Crafty: CheckItemInWatchList")
  local found = false
  local watchList = Crafty.activewatchList
  for i=1,table.getn(watchList) do
    if watchList[i].name == control then
      local found = true
      return found
    end
  end
  return found
end

-- helper function to return stocklist item amount
function Crafty.ReturnStockListItemAmount(itemname,stocklist)
  Crafty.DB("Crafty: ReturnStockListItemAmount")
  local amount = 0
  for i=1,table.getn(stocklist) do
    --Crafty.DB(stocklist[i].name)
    if stocklist[i].name == itemname then
      local amount = stocklist[i].amount
      --Crafty.DB(amount)
      return amount
    end
  end
  --Crafty.DB(amount)
  return amount
end

-- helper function to create a complete stocklist table
function Crafty.PopulateCompleteStock()
  Crafty.DB("Crafty: PopulateCompleteStock")
  local cstock = {}
  local stockcounter = 0

  for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
    if data ~= nil then
      stockcounter = stockcounter + 1
      cstock[stockcounter] = {
        link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
        name = GetItemName(BAG_VIRTUAL,data.slotIndex),
        amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
        cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
      }
      --Crafty.DB(cstock[stockcounter].icon) --working
    end
  end
  return cstock
end

----------------------------------------------------------------------------------------
-- Debugfunctions
----------------------------------------------------------------------------------------

-- show debug message
function Crafty.DB(message)
  if Crafty.db then
    d(message)
  end
end

-- for slashcommand
function Crafty.ToggleDB()
  if Crafty.db then
    d("Crafty: Debugmode off")
    Crafty.db = false
  else
    d("Crafty: Debugmode on")
    Crafty.db = true
  end
end

-- output complete watchlist1
function Crafty.DBPrintWatchList()
  local watchList = Crafty.watchList1
  if Crafty.db then
    Crafty.DB("Debug WatchList -------------------------")
    for i=1,table.getn(watchList) do
      Crafty.DB(watchList[i].link)
    end
  end
end

----------------------------------------------------------------------------------------
-- Events
----------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_ADD_ON_LOADED, Crafty.OnAddOnLoaded)

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Crafty.InvChange)
EVENT_MANAGER:AddFilterForEvent(Crafty.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_VIRTUAL)

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_OPEN_TRADING_HOUSE, Crafty.EventCheckVendorOpen)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_CLOSE_TRADING_HOUSE, Crafty.EventCheckVendorClose)

--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_BUY_RECEIPT, Crafty.InvChange)
--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_LOOT_RECEIVED, Crafty.InvChange)
--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS , Crafty.InvChange)
--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_CRAFT_COMPLETED, Crafty.InvChange)


----------------------------------------------------------------------------------------
-- Slash Commands
----------------------------------------------------------------------------------------

SLASH_COMMANDS["/crafty"] = function()  Crafty.ToggleWL() end
SLASH_COMMANDS["/craftydb"] = function()  Crafty.ToggleDB() end
--SLASH_COMMANDS["/craftytest"] = function()  Crafty.ReturnStockListItemAmount("silver dust") end
