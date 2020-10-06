local version = "1.0.4"

local frame = CreateFrame("Frame")
frame:SetFrameStrata("LOW")

local NORMAL_BAG = 0	-- Non-profession bag type ID
local freeBagSlots = -1

local bagLabel = MainMenuBarBackpackButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
bagLabel:SetFont("Fonts\\ARIALN.TTF", 14, "THINOUTLINE")
bagLabel:SetPoint("TOP",_G["MainMenuBarBackpackButton"],"CENTER",0,0)
bagLabel:SetTextColor(1, 1, 1)

local targetHelathFrameText = TargetFrameTextureFrame:CreateFontString(nil,"OVERLAY","TextStatusBarText")
targetHelathFrameText:SetFont("Fonts\\ARIALN.TTF", 13, "THINOUTLINE")
targetHelathFrameText:SetPoint("CENTER",_G["TargetFrameHealthBar"],"CENTER",0,0)
targetHelathFrameText:SetTextColor(1, 1, 1)

local targetPowerFrameText = TargetFrameTextureFrame:CreateFontString(nil,"OVERLAY","TextStatusBarText")
targetPowerFrameText:SetFont("Fonts\\ARIALN.TTF", 13, "THINOUTLINE")
targetPowerFrameText:SetPoint("CENTER",_G["TargetFrameManaBar"],"CENTER",0,0)
targetPowerFrameText:SetTextColor(1, 1, 1)

function enhanceItemTooltip(tooltip, useQuantity)
	if AllinoneMinimalisticSettings.showEnhancedItemTooltipCheckbox then
		local name, link = tooltip:GetItem()
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
		itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(link)
		
		--|TInterface\\Icons\\INV_Misc_Coin_01:16|t
		if itemTexture ~= nil then
			tooltip:AppendText("  |T"..itemTexture..":16|t")
		end
		
		quantity = 1
		
		if useQuantity and GetMouseFocus() ~= nil and GetMouseFocus().Count ~= nil and GetMouseFocus().Count:GetText() ~= nil then
			quantity = tonumber(GetMouseFocus().Count:GetText())
		end
		
		tooltip:AddLine("Additional info:")
		tooltip:AddLine(string.format("iLvl: %d", itemLevel), 1, 1, 1)
		if itemStackCount ~= nil and itemStackCount > 1 then
			tooltip:AddLine(string.format("|cFFf1f1f1Stack size: %s", itemStackCount))
		end
		--cc801a
		if quantity ~= nil and itemSellPrice ~= nil then
		 tooltip:AddLine(GetCoinTextureString(itemSellPrice*quantity), 1, 1, 1)
		end
		if quantity ~= nil and quantity > 1 then
			tooltip:AddDoubleLine("|cFFcc801aSell one: ", GetCoinTextureString(itemSellPrice), 0.3, 0.5, 0.4, 1, 1, 1)
		end
		if itemStackCount ~= nil and itemStackCount > 1 then
			tooltip:AddDoubleLine(string.format("|cFFcc801aSell stack (|cFFaf5529%s|cFFcc801a): ", itemStackCount), GetCoinTextureString(itemSellPrice*itemStackCount), 0.3, 0.5, 0.4, 1, 1, 1)
		end
		if itemType ~= nil and itemSubType ~= nil then
			if itemType ~= itemSubType then
				tooltip:AddLine(string.format("|cFF9966ccItem type: %s - %s", itemType, itemSubType), 0.3, 0.5, 0.4)
			else
				tooltip:AddLine(string.format("|cFF9966ccItem type: %s", itemType), 0.3, 0.5, 0.4)
			end	
		end
	end
end

GameTooltip:SetScript("OnTooltipSetItem", function(self)
	enhanceItemTooltip(GameTooltip, true)
end)

ItemRefTooltip:SetScript("OnTooltipSetItem", function(self)
	enhanceItemTooltip(ItemRefTooltip, false)
end)

local auctionSortButton = CreateFrame("Button","auctionSortButton",_G["AuctionFrame"],"UIPanelButtonTemplate") --frameType, frameName, frameParent, frameTemplate    
auctionSortButton:SetSize(150,20)
auctionSortButton:SetFrameStrata("HIGH")
--auctionSortButton:SetPoint("CENTER",0,320)
--auctionSortButton:SetPoint("CENTER",40,300)
--auctionSortButton:SetPoint("RIGHT",_G["AuctionFrame"],"TOPRIGHT",-24,0)
--auctionSortButton:SetPoint("TOP",_G["AuctionFrame"],"TOP",0,0)
-- auctionSortButton.text = _G[name.."Text"]
-- auctionSortButton.text:SetText("Hello World")
auctionSortButton:SetText("sort by buyout")
auctionSortButton:SetScript("OnClick", function(self, arg1)
    SortAuctionItems("list", "buyout")
end)
--auctionSortButton:Hide()
--auctionSortButton:Click("foo bar") -- will print "foo bar" in the chat frame.
--auctionSortButton:Click("blah blah") -- will print "blah blah" in the chat frame.

function countTotalFreeBagSlots()
	local totalFreeSlots = 0
	for i=0, NUM_BAG_SLOTS do
		local freeCount, bagType = GetContainerNumFreeSlots(i)
		if bagType == NORMAL_BAG then
			totalFreeSlots = totalFreeSlots + freeCount
		end
	end
	
	return totalFreeSlots
end

function updateBagCountLabel()
	if not AllinoneMinimalisticSettings.showFreeBagSpaceCheckbox then
		bagLabel:Hide()
		return
	else
		bagLabel:Show()
		bagLabel:SetFormattedText("(%d)", freeBagSlots)
	end
end

function updateTargetFrameLabels()
	if not AllinoneMinimalisticSettings.showMobHealthAndPowerCheckbox then
		targetHelathFrameText:Hide()
		targetPowerFrameText:Hide()
		return
	else
		targetHelathFrameText:Show()
		targetPowerFrameText:Show()
		
		if not UnitExists("target") then
			targetHelathFrameText:SetText("n/e")
		elseif UnitIsDead("target") then
			targetHelathFrameText:SetText("")
		else
			if UnitHealthMax("target") == 100 then
				targetHelathFrameText:SetFormattedText("%d/%d (%%)", UnitHealth("target"), UnitHealthMax("target"))
			else 
				targetHelathFrameText:SetFormattedText("%d/%d", UnitHealth("target"), UnitHealthMax("target"))
			end
			targetPowerFrameText:SetFormattedText("%d/%d", UnitPower("target"), UnitPowerMax("target"))
		end	
	end
		
	
end

function updateSortByBuyoutButton() 
	if (auctionHouseVisible == true) and (AllinoneMinimalisticSettings.showSortByBuyoutCheckbox) then
		auctionSortButton:Show()
	else
		auctionSortButton:Hide()
	end
end


function updateAll()
	updateBagCountLabel()
	updateTargetFrameLabels()
	updateSortByBuyoutButton() 
end

auctionHouseVisible = false
addonIsLoaded = false

function handleEvent(self, event, arg1, ...) 
	if (event == "BAG_UPDATE") then
		-- Fired when a bags inventory changes. 
		-- Bag zero, the sixteen slot default backpack, may not fire on login. 
		-- Upon login (or reloading the console) this event fires even for bank bags. 
		-- When moving an item in your inventory, this fires multiple times: 
		-- once each for the source and destination bag. 
		-- If the bag involved is the default backpack, 
		-- this event will also fire with a container ID of "-2" 
		-- (twice if you are moving the item inside the same bag).
		-- arg1 
		-- container ID	
		-- arg1 >= NUM_BAG_SLOTS should be bank containers
		-- arg1 -2 could be a ring bag
		if arg1 >= 0 or arg1 < NUM_BAG_SLOTS then
			freeBagSlots = countTotalFreeBagSlots()
			updateBagCountLabel()
		end
	elseif event == "UNIT_HEALTH" then
		--do nothing
	elseif event == "AUCTION_HOUSE_SHOW" then
		auctionHouseVisible = true
		auctionSortButton:SetPoint("TOPRIGHT",_G["AuctionFrame"],"TOPRIGHT",-22,-12)
		updateSortByBuyoutButton()
		--auctionSortButton:Show()
	elseif event == "AUCTION_HOUSE_CLOSED" then
		auctionHouseVisible = false
		--auctionSortButton:Hide()
		updateSortByBuyoutButton()
	end
end

--/run print((select(4, GetBuildInfo())));
--/run print(GetBuildInfo());

function dispatchEvents(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "AllinoneMinimalistic" then
	    print(string.format("%s v%s is loaded susscessfully\nThank you for using my addon", arg1, version));
		initSettings()
		addonIsLoaded = true
		handleEvent(nil, "BAG_UPDATE", 0)
	end
	if addonIsLoaded then
		handleEvent(self, event, arg1, ...)
	end
	updateTargetFrameLabels()	
end

function loadDefaultSettings() 
	AllinoneMinimalisticSettings = {
		  showMobHealthAndPowerCheckbox=true, 
		  showFreeBagSpaceCheckbox=true, 
		  showSortByBuyoutCheckbox=true,
		  showEnhancedItemTooltipCheckbox=true
	  }
end

function initSettings()
	local optionsFrame = CreateFrame( "Frame", "optionsFrame", UIParent )
	optionsFrame.name = "All in one minimalistic"
	InterfaceOptions_AddCategory(optionsFrame)
	
	if AllinoneMinimalisticSettings == nil then
		loadDefaultSettings()
		print("unable to load AllinoneMinimalistic saved data, backing up to defaults")
	else	
		if AllinoneMinimalisticSettings.showEnhancedItemTooltipCheckbox == nil then
			AllinoneMinimalisticSettings.showEnhancedItemTooltipCheckbox=true
			print("AllinoneMinimalistic.showEnhancedItemTooltipCheckbox is a new feature, enabling by default")
		end
		print("AllinoneMinimalistic saved data loaded")
	end	
	
	local showMobHealthAndPowerCheckbox = CreateFrame("CheckButton", "showMobHealthAndPowerCheckbox", optionsFrame, "UICheckButtonTemplate")
	showMobHealthAndPowerCheckbox:SetPoint("TOPLEFT",0,0)
	showMobHealthAndPowerCheckbox.text:SetText("Show mob health/power")
	showMobHealthAndPowerCheckbox:SetChecked(AllinoneMinimalisticSettings.showMobHealthAndPowerCheckbox)
	showMobHealthAndPowerCheckbox:SetScript("OnClick",
		function() 
			AllinoneMinimalisticSettings.showMobHealthAndPowerCheckbox=not AllinoneMinimalisticSettings.showMobHealthAndPowerCheckbox
			updateAll() 
		end)
	
	local showFreeBagSpaceCheckbox = CreateFrame("CheckButton", "showFreeBagSpaceCheckbox", optionsFrame, "UICheckButtonTemplate")
	showFreeBagSpaceCheckbox:SetPoint("TOPLEFT",0,-30)
	showFreeBagSpaceCheckbox.text:SetText("Show free bag space")
	showFreeBagSpaceCheckbox:SetChecked(AllinoneMinimalisticSettings.showFreeBagSpaceCheckbox)
	showFreeBagSpaceCheckbox:SetScript("OnClick",
		function()
			AllinoneMinimalisticSettings.showFreeBagSpaceCheckbox=not AllinoneMinimalisticSettings.showFreeBagSpaceCheckbox
			updateAll() 
		end)
	  
	local showSortByBuyoutCheckbox = CreateFrame("CheckButton", "showSortByBuyoutCheckbox", optionsFrame, "UICheckButtonTemplate")
	showSortByBuyoutCheckbox:SetPoint("TOPLEFT",0,-60)
	showSortByBuyoutCheckbox.text:SetText("Show \"sort by buyout\" button")
	showSortByBuyoutCheckbox:SetChecked(AllinoneMinimalisticSettings.showSortByBuyoutCheckbox)
	showSortByBuyoutCheckbox:SetScript("OnClick",
		function()
			AllinoneMinimalisticSettings.showSortByBuyoutCheckbox=not AllinoneMinimalisticSettings.showSortByBuyoutCheckbox 
			updateAll() 
		end)	  
		
	local showEnhancedItemTooltipCheckbox = CreateFrame("CheckButton", "showEnhancedItemTooltipCheckbox", optionsFrame, "UICheckButtonTemplate")
	showEnhancedItemTooltipCheckbox:SetPoint("TOPLEFT",0,-90)
	showEnhancedItemTooltipCheckbox.text:SetText("Show enhanced item tooltip")
	showEnhancedItemTooltipCheckbox:SetChecked(AllinoneMinimalisticSettings.showEnhancedItemTooltipCheckbox)
	showEnhancedItemTooltipCheckbox:SetScript("OnClick",
		function()
			AllinoneMinimalisticSettings.showEnhancedItemTooltipCheckbox=not AllinoneMinimalisticSettings.showEnhancedItemTooltipCheckbox 
			updateAll() 
		end)	
end

function init()
	frame:SetScript("OnEvent", dispatchEvents)
	frame:RegisterEvent("ADDON_LOADED")
	
	frame:RegisterEvent("BAG_UPDATE")
	
	frame:RegisterEvent("UNIT_HEALTH")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UNIT_POWER_FREQUENT")
	
	frame:RegisterEvent("AUCTION_HOUSE_SHOW")
	frame:RegisterEvent("AUCTION_HOUSE_CLOSED")	
end

--Init
init()
