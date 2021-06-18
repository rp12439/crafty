Crafty = {}
Crafty.name = "Crafty"

function Crafty.OnAddOnLoaded(event, addonName)
  if addonName == Crafty.name then
    d("Crafty: OnAddOnLoaded")
    Crafty:Initialize()
  end
end
 
function Crafty:Initialize()
  d("Crafty: Initialize")
  
  self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("CraftySavedVariables", 1, nil, {})
  self:RestorePosition()
  
  Crafty.CreateScrollListDataType()
  local stock = Crafty.Populate()
  local typeId = 1
  Crafty.UpdateScrollList(CraftyListList, stock, typeId)
end

function Crafty.OnIndicatorMoveStop()
  Crafty.savedVariables.left = CraftyList:GetLeft()
  Crafty.savedVariables.top = CraftyList:GetTop()
end

function Crafty:RestorePosition()
  d("Crafty: RestorePosition")
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  CraftyList:ClearAnchors()
  CraftyList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Crafty.CreateScrollListDataType()
  d("Crafty: CreateScrollListDataType")
  local control = CraftyListList
  local typeId = 1
  local templateName = "StockRow"
  local height = 25
  local setupFunction = Crafty.LayoutRow
  local hideCallback = nil
  local dataTypeSelectSound = nil
  local resetControlCallback = nil
  local selectTemplate = "ZO_ThinListHighlight"
  local selectCallback = Crafty.OnRowSelect
  
  ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
end

function Crafty.Populate()
  d("Crafty: Populate")
  local stock = {}
  local stockcounter = 0

  for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
    if data ~= nil then
      if GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex) == 2 then
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

function Crafty.UpdateScrollList(control, data, rowType)
  d("Crafty: UpdateScrollList")
  
  local dataCopy = ZO_DeepTableCopy(data)
  local dataList = ZO_ScrollList_GetDataList(control)
  
  ZO_ScrollList_Clear(control)
  
  for key, value in ipairs(dataCopy) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataList, entry)
  end
  
  table.sort(dataList, function(a,b) return a.data.name < b.data.name end)
   
  ZO_ScrollList_Commit(control)
end

function Crafty.LayoutRow(rowControl, data, scrollList)
  rowControl.data = data
  rowControl.name = GetControl(rowControl, "Name")
  rowControl.amount = GetControl(rowControl, "Amount")
  
  rowControl.name:SetText(data.link)
  rowControl.amount:SetText(data.amount)
end

function Crafty.Refresh()
  local stock = Crafty.Populate()
  local typeId = 1
  Crafty.UpdateScrollList(CraftyListList, stock, typeId)
end

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_ADD_ON_LOADED, Crafty.OnAddOnLoaded)