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
	    print(string.format("%s v1.0.0 is loaded susscessfully\nThank you for using my addon", arg1));
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
		  showSortByBuyoutCheckbox=true
	  }
end

function initSettings()
	local optionsFrame = CreateFrame( "Frame", "optionsFrame", UIParent )
	optionsFrame.name = "All in one minimalistic"
	InterfaceOptions_AddCategory(optionsFrame)
	
	if AllinoneMinimalisticSettings == nil then
		loadDefaultSettings()
		print("unable to load AllinoneMinimalistic saved data, backing up to defaults");
	else
		print("AllinoneMinimalistic saved data loaded");
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