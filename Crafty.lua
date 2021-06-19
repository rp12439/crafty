----------------------------------------------------------------------------------------
-- Global vars and constants
----------------------------------------------------------------------------------------

Crafty = {}
Crafty.name = "Crafty"
Crafty.version = "V1.3b"
Crafty.showSL = true
Crafty.showWL = true
Crafty.ankerSL = true
Crafty.vendorOpen = false
Crafty.vendorOpen = false
Crafty.showTS = false
Crafty.undoRemove = nil
Crafty.differentWLPositions = true
Crafty.db = false7
Crafty.filterTypeSL = 4
Crafty.watchList1 = {}
Crafty.watchList2 = {}
Crafty.watchList3 = {}
Crafty.activewatchList = Crafty.watchList1
Crafty.activewatchListID = 1
Crafty.vendorwatchListID = 1
Crafty.oldactivewatchListID = 1
Crafty.masterHeight = 600
Crafty.masterWidth = 300
Crafty.autoHeightWL = 600
Crafty.autoHeightWLOpt = true
Crafty.masterAlpha = 0

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
  
  self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("CraftySavedVariables", 1, nil, {})
  
  if Crafty.savedVariables.AnkerSL ~= nil then
    Crafty.ankerSL = Crafty.savedVariables.AnkerSL
  end
  if Crafty.savedVariables.ShowSL ~= nil then
    Crafty.showSL = Crafty.savedVariables.ShowSL
  end
  if Crafty.savedVariables.ShowWL ~= nil then
    Crafty.showWL = Crafty.savedVariables.ShowWL
  end
  if Crafty.savedVariables.WatchList1 ~= nil then
    Crafty.watchList1 = Crafty.savedVariables.WatchList1
  end
  if Crafty.savedVariables.WatchList2 ~= nil then
    Crafty.watchList2 = Crafty.savedVariables.WatchList2
  end
  if Crafty.savedVariables.WatchList3 ~= nil then
    Crafty.watchList3 = Crafty.savedVariables.WatchList3
  end
  if Crafty.savedVariables.ActivewatchList ~= nil then
    Crafty.activewatchList = Crafty.savedVariables.ActivewatchList
  end
  if Crafty.savedVariables.ActivewatchListID ~= nil then
    Crafty.activewatchListID = Crafty.savedVariables.ActivewatchListID
  end
  if Crafty.savedVariables.DifferentWLPositions ~= nil then
    Crafty.differentWLPositions = Crafty.savedVariables.DifferentWLPositions
  end
  if Crafty.savedVariables.VendorOpen ~= nil then
    Crafty.vendorOpen = Crafty.savedVariables.VendorOpen
  end
  if Crafty.savedVariables.VendorOpen ~= nil then
    Crafty.vendorClose = Crafty.savedVariables.VendorClose
  end
  if Crafty.savedVariables.VendorwatchListID ~= nil then
    Crafty.vendorwatchListID = Crafty.savedVariables.VendorwatchListID
  end
  if Crafty.savedVariables.MasterAlpha ~= nil then
    Crafty.masterAlpha = Crafty.savedVariables.MasterAlpha
  end
  if Crafty.savedVariables.MasterHeight ~= nil then
    Crafty.masterHeight = Crafty.savedVariables.MasterHeight
  end
  if Crafty.savedVariables.AutoHeightWLOpt ~= nil then
    Crafty.autoHeightWLOpt = Crafty.savedVariables.AutoHeightWLOpt
  end
   
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
  Crafty.SetTS(4)
  Crafty.SetActiveWatchList(Crafty.activewatchListID)
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
  CraftyStockListType:SetWidth(width-100)
  CraftyStockListType:SetHeight(height)
  
  Crafty.savedVariables.MasterHeight = height
  Crafty.Refresh()
end

-- set overall backgroundalpha (from settings)
function Crafty.SetMasterAlpha()
  Crafty.DB("Crafty: SetMasterAlpha")
  
  CraftyWatchListBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListTypeBG:SetAlpha(Crafty.masterAlpha)
  
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
  
  Crafty.RestoreWLPosition(Crafty.activewatchListID)
  
  if not Crafty.ankerSL then
    local leftSL = Crafty.savedVariables.leftSL
    local topSL = Crafty.savedVariables.topSL
    CraftyStockList:ClearAnchors()
    CraftyStockList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftSL, topSL)
  else
    Crafty.AnkerSL()
  end
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
    local leftWL = Crafty.savedVariables.leftWL
    local topWL = Crafty.savedVariables.topWL
    CraftyWatchList:ClearAnchors()
    CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
  end
end

-- calculate the autoheight for the watchlist, sets the global var
function Crafty.CalculateHeightWL()
  Crafty.DB("Crafty: CalculateHeightWL")
  
  local watchList = Crafty.activewatchList
  local watchlistItems = table.getn(watchList)
  
  Crafty.autoHeightWL = 65+watchlistItems*25
end

-- sets the autoheight value to the xml element watchlist
function Crafty.SetHeightWL()
  if Crafty.autoHeightWLOpt then
    Crafty.DB("Crafty: SetHeightWL")
    Crafty.CalculateHeightWL()
    local width = Crafty.masterWidth
    local height = Crafty.autoHeightWL
    
    CraftyWatchList:SetWidth(width)
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
  local height = 25
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
  local height = 25
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
  Crafty.DB("Crafty: SetActiveWatchList "..arg)
  local mydefcolor = ZO_ColorDef:New("CFDCBD")
  
  CraftyWatchListWatchList1:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList2:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList3:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList1:SetFont("ZoFontWinH4")
  CraftyWatchListWatchList2:SetFont("ZoFontWinH4")
  CraftyWatchListWatchList3:SetFont("ZoFontWinH4")
  
  if arg == 1 then
    CraftyWatchListWatchList1:SetColor(1,1,1)
    CraftyWatchListWatchList1:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList1
  end
  if arg == 2 then
    CraftyWatchListWatchList2:SetColor(1,1,1)
    CraftyWatchListWatchList2:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList2
  end
  if arg == 3 then
    CraftyWatchListWatchList3:SetColor(1,1,1)
    CraftyWatchListWatchList3:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList3
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
  
  local mydefcolor = ZO_ColorDef:New("CFDCBD")

  CraftyStockListTypeMatsLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeBlacksmithingLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeClothierLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeEnchantingLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeAlchemyLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeProvisioningLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeWoodworkingLabel:SetColor(mydefcolor:UnpackRGBA())
  CraftyStockListTypeJewelryLabel:SetColor(mydefcolor:UnpackRGBA())
  
  if         arg == 0 then CraftyStockListTypeMatsLabel:SetColor(1,1,1,1)
      elseif arg == 1 then CraftyStockListTypeBlacksmithingLabel:SetColor(1,1,1,1)
      elseif arg == 2 then CraftyStockListTypeClothierLabel:SetColor(1,1,1,1)
      elseif arg == 3 then CraftyStockListTypeEnchantingLabel:SetColor(1,1,1,1)
      elseif arg == 4 then CraftyStockListTypeAlchemyLabel:SetColor(1,1,1,1)
      elseif arg == 5 then CraftyStockListTypeProvisioningLabel:SetColor(1,1,1,1)
      elseif arg == 6 then CraftyStockListTypeWoodworkingLabel:SetColor(1,1,1,1)
      elseif arg == 7 then CraftyStockListTypeJewelryLabel:SetColor(1,1,1,1)
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
  Crafty.DB("Crafty: PopulateWL "..table.getn(watchList))
  Crafty.RefreshWLAmounts()
  local stock = {}
  --Crafty.DBPrintWatchList()
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
  
  table.sort(dataList, function(a,b) return a.data.name < b.data.name end)
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
   
  table.sort(dataListWL, function(a,b) return a.data.name < b.data.name end)
  ZO_ScrollList_Commit(control)
  
  --Crafty.DBPrintWatchList()
  
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
  --d("Crafty: LayoutRow")

  rowControl.data = data
  rowControl.name = GetControl(rowControl, "Name")
  rowControl.amount = GetControl(rowControl, "Amount")
  
  rowControl.name:SetText(data.link)
  rowControl.amount:SetText(data.amount)  
end

----------------------------------------------------------------------------------------
-- Listdatahandling dataupdates
----------------------------------------------------------------------------------------

-- eventmanager target for several inventory change events
function Crafty.InvChange()
  Crafty.DB("Crafty: InvChange")
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
  if table.getn(Crafty.activewatchList) ~= 0 then
    for i=1,table.getn(Crafty.activewatchList) do
      local name = Crafty.activewatchList[i].name
      for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
        if data ~= nil then
          if GetItemName(BAG_VIRTUAL,data.slotIndex) == name then
            Crafty.activewatchList[i].amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex)
          end
        end
      end
    end
  end
end

----------------------------------------------------------------------------------------
-- Functions to call from events, xml (buttons) or settings
----------------------------------------------------------------------------------------

-- close or hide the interface (from settings) this is not a toggle!
function Crafty.Check()
  Crafty.DB("Crafty: Check")
  if Crafty.showWL == true then
      Crafty.OpenWL()
  else 
      Crafty.CloseWL()
  end
end

-- open interface on vendor if set (called from eventmanager)
function Crafty.CheckVendorOpen()
  Crafty.DB("Crafty: CheckVendorOpen")
  Crafty.DB(Crafty.vendorwatchListID)
  if Crafty.vendorOpen then
    Crafty.oldactivewatchListID = Crafty.activewatchListID
    Crafty.OpenWL(Crafty.vendorwatchListID)
  end
end

-- close interface on vendor if set (called from eventmanager)
function Crafty.CheckVendorClose()
  Crafty.DB("Crafty: CheckVendorClose")
  if Crafty.vendorClose then
    Crafty.CloseWL()
    Crafty.SetActiveWatchList(Crafty.oldactivewatchListID)
  else
    Crafty.OpenWL(Crafty.oldactivewatchListID)
  end
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
  CraftyStockList:SetAnchor(TOPRIGHT, CraftyWatchList, TOPLEFT, -4 ,0)
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
end

-- open the watchlist
function Crafty.OpenWL(arg)
  Crafty.DB("Crafty: OpenWL")
  if arg ~= nil then
    Crafty.SetActiveWatchList(arg)
  end
  CraftyWatchList:SetHidden(false)
  Crafty.showWL = true
  Crafty.savedVariables.ShowWL = true
end

---- not used yet
--function Crafty.OnMouseEnterSL(control)
--
--
--end
--
---- not used yet
--function Crafty.OnMouseExitSL(control)
--
--
--end

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

-- helper function to check if an item is in the list
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

-- output complete watchlist
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

--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Crafty.InvChange)

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_OPEN_TRADING_HOUSE, Crafty.CheckVendorOpen)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_CLOSE_TRADING_HOUSE, Crafty.CheckVendorClose)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_BUY_RECEIPT, Crafty.InvChange)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_LOOT_RECEIVED, Crafty.InvChange)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS , Crafty.InvChange)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_CRAFT_COMPLETED, Crafty.InvChange)


----------------------------------------------------------------------------------------
-- Slash Commands
----------------------------------------------------------------------------------------

SLASH_COMMANDS["/crafty"] = function()  Crafty.ToggleWL() end
SLASH_COMMANDS["/craftydb"] = function()  Crafty.ToggleDB() end
