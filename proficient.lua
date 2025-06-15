local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "LibPubSub-1.0")

local _G = _G
local DEFAULT_SEARCH_TEXT = "|cFF999999Search..."
local SKILL_TYPE_SORT_ORDER = {
    difficult = 1,
    optimal = 2,
    medium = 3,
    easy = 4,
    trivial = 5,
}

function addon:OnInitialize()
    self.frame = CreateFrame("Frame")

    self.frames = {
        trade = {
            title = nil,
            searchBox = nil,
            clearButton = nil,
            hasMatsCheckbox = nil,
        },
        craft = {
            title = nil,
            searchBox = nil,
            clearButton = nil,
            hasMatsCheckbox = nil,
        },
    };

    -- initialize on the first run
    if not ProficientStorage then
        ProficientUtils:ChatMessage("|cFFFFFF00[Proficient] ".."|cFFFFFF00Initializing...")
        ProficientStorage = {}
    end

    self:SetProficientStorageDefaults()
end

function addon:SetProficientStorageDefaults()
    ProficientUtils:SetDefault(ProficientStorage, "showChatMessages", true)
    ProficientUtils:SetDefault(ProficientStorage, "frames", {})
end

function addon:OnEnable()
    self:RegisterEvent("TRADE_SKILL_SHOW", "OnTradeSkillShow")
    self:RegisterEvent("TRADE_SKILL_CLOSE", "OnTradeSkillClose")
    self:RegisterEvent("CRAFT_SHOW", "OnCraftShow")
    self:RegisterEvent("CRAFT_CLOSE", "OnCraftClose")

    self.frame:SetScript("OnUpdate", function(_, elapsed)
        addon:OnUpdate()
    end)
    addon:Subscribe("MOUSE_CLICK", self, "OnClick")
end

function addon:OnDisable()
    self.frame:SetScript("OnUpdate", nil)
    addon:Unsubscribe("MOUSE_CLICK", self, "OnClick")
    self:UnregisterAllEvents()
end

function addon:OnUpdate()
    for frameMode, frameInfo in pairs(self.frames) do
        if frameInfo.searchBox and frameInfo.updateRequired then
            frameInfo.updateRequired = false
            frameInfo.origUpdate()
            self:Search(frameMode)
        end
    end
end

function addon:OnCraftShow()
    addon:ShowFrame("craft")
end

function addon:OnTradeSkillShow()
    addon:ShowFrame("trade")
end

function addon:ShowFrame(mode)
    if mode == "craft" then
        CraftCollapseAllButton:Hide()
        CraftHighlightFrame:Hide()

        if not self.frames["craft"]["origUpdate"] then
            self.frames["craft"]["origUpdate"] = CraftFrame_Update
            CraftFrame_Update = function()
                addon.frames["craft"]["updateRequired"] = true
            end
        end
    elseif mode == "trade" then
        TradeSkillCollapseAllButton:Hide()
        TradeSkillHighlightFrame:Hide()
        TradeSkillSubClassDropdown:Hide()
        TradeSkillInvSlotDropdown:Hide()

        if not self.frames["trade"]["origUpdate"] then
            self.frames["trade"]["origUpdate"] = TradeSkillFrame_Update
            TradeSkillFrame_Update = function()
                addon.frames["trade"]["updateRequired"] = true
            end
        end
    end

    -- if frame title has changed, recreate UI elements
    local frameTitle = _G[mode == "craft" and "CraftFrameTitleText" or "TradeSkillFrameTitleText"]:GetText()
    if self.frames[mode].title ~= frameTitle then
        self.frames[mode].title = frameTitle
        if self.frames[mode].searchBox then
            self.frames[mode].searchBox:Hide()
            self.frames[mode].hasMatsCheckbox:Hide()
            self.frames[mode].clearButton:Hide()
            self.frames[mode].sortDropdown:Hide()
            self.frames[mode].searchBox = nil
            self.frames[mode].clearButton = nil
            self.frames[mode].sortDropdown = nil
            self.frames[mode].hasMatsCheckbox = nil
        end
    end

    local psFrameName = mode.."-"..self.frames[mode].title
    if not ProficientStorage.frames[psFrameName] then
        ProficientStorage.frames[psFrameName] = {
            sortDropdownValue = "alphabetical",
            hasMatsChecked = false,
            favorites = {},
        }
    end

    if not self.frames[mode].searchBox then
        self.frames[mode].searchBox = CreateFrame("EditBox", nil, mode == "craft" and CraftFrame or TradeSkillFrame, "InputBoxTemplate")
        local searchBox = self.frames[mode].searchBox

        searchBox:SetSize(115, 18)
        searchBox:SetPoint("TOPRIGHT", -45, -70)
        searchBox:SetAutoFocus(false)

        searchBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)

        searchBox:SetScript("OnTextChanged", function(self)
            addon:Search(mode)
        end)

        searchBox:SetScript("OnEditFocusLost", function(self)
            if self:GetText() == "" then
                self:SetText(DEFAULT_SEARCH_TEXT)
            end
        end)

        searchBox:SetScript("OnEditFocusGained", function(self)
            if self:GetText() == DEFAULT_SEARCH_TEXT then
                self:SetText("")
            end
        end)

		self.frames[mode].clearButton = CreateFrame("Button", nil, searchBox)
		local clearButton = self.frames[mode].clearButton

        clearButton:SetPoint("RIGHT", -2, 0)
        clearButton:SetWidth(17)
        clearButton:SetHeight(17)
        do
            local tex = clearButton:CreateTexture(nil, "ARTWORK")
            tex:SetTexture[[Interface\AddOns\Proficient\ClearSearchIcon]]
            tex:SetPoint("TOPRIGHT", 0, 0)
            tex:SetWidth(17)
            tex:SetHeight(17)
            tex:SetAlpha(.5)
            clearButton.tex = tex
        end

		clearButton:SetScript("OnEnter", function(self)
			self.tex:SetAlpha(1)
		end)

		clearButton:SetScript("OnLeave", function(self)
			self.tex:SetAlpha(.5)
		end)

		clearButton:SetScript("OnMouseUp", function(self)
			self.tex:SetPoint("TOPLEFT", 0, 0)
		end)

		clearButton:SetScript("OnMouseDown", function(self)
			self.tex:SetPoint("TOPLEFT", 1, -1)
		end)

		clearButton:SetScript("OnClick", function()
			PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
			searchBox:SetText(DEFAULT_SEARCH_TEXT)
			searchBox:ClearFocus()
		end)

        self.frames[mode].hasMatsCheckbox = CreateFrame("CheckButton", nil, mode == "craft" and CraftFrame or TradeSkillFrame, "UICheckButtonTemplate")
        local hasMatsCheckbox = self.frames[mode].hasMatsCheckbox

        hasMatsCheckbox:SetPoint("TOPLEFT", 142, -64)
        hasMatsCheckbox.text:SetText("Mats")
        hasMatsCheckbox:SetChecked(ProficientStorage.frames[psFrameName].hasMatsChecked)

        hasMatsCheckbox:SetScript("OnClick", function(self)
            ProficientStorage.frames[psFrameName].hasMatsChecked = self:GetChecked()
            addon:Search(mode)
        end)

        hasMatsCheckbox:SetScript("OnShow", function(self)
            self:SetChecked(ProficientStorage.frames[psFrameName].hasMatsChecked)
        end)

		self.frames[mode].sortDropdown = CreateFrame("Frame", nil, mode == "craft" and CraftFrame or TradeSkillFrame, "UIDropDownMenuTemplate")
		local sortDropdown = self.frames[mode].sortDropdown

        sortDropdown:SetPoint("TOPLEFT", 5, -66)
        UIDropDownMenu_SetWidth(sortDropdown, 100)

        UIDropDownMenu_Initialize(sortDropdown, function()
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Alphabetical"
            info.value = "alphabetical"
            info.func = function()
                UIDropDownMenu_SetSelectedValue(sortDropdown, "alphabetical")
                ProficientStorage.frames[psFrameName].sortDropdownValue = "alphabetical"
                addon.frames["trade"]["resetSelection"] = true
                addon:Search(mode)
            end
            UIDropDownMenu_AddButton(info)

            local info = UIDropDownMenu_CreateInfo()
            info.text = "Level"
            info.value = "level"
            info.func = function()
                UIDropDownMenu_SetSelectedValue(sortDropdown, "level")
                ProficientStorage.frames[psFrameName].sortDropdownValue = "level"
                addon.frames["trade"]["resetSelection"] = true
                addon:Search(mode)
            end
            UIDropDownMenu_AddButton(info)
        end)
    end

    self.frames[mode].searchBox:SetText(DEFAULT_SEARCH_TEXT)
    UIDropDownMenu_SetSelectedValue(self.frames[mode].sortDropdown, ProficientStorage.frames[psFrameName].sortDropdownValue)

    self.frames[mode].searchBox:Show()
    self.frames[mode].sortDropdown:Show()
    self.frames[mode].hasMatsCheckbox:Show()

    addon.frames["trade"].resetSelection = true
end

function addon:OnTradeSkillClose()
    self.frames["trade"].searchBox:Hide()
end

function addon:OnCraftClose()
    self.frames["craft"].searchBox:Hide()
end

function addon:SelectionInList(mode, skillOffset, foundSkills)
	for i = skillOffset + 1, skillOffset + (mode == "craft" and CRAFTS_DISPLAYED or TRADE_SKILLS_DISPLAYED) do
		if foundSkills[i] and foundSkills[i].index == (mode == "craft" and GetCraftSelectionIndex() or GetTradeSkillSelectionIndex()) then
			return true
		end
	end
	return false
end

function addon:Search(mode)
    term = self.frames[mode].searchBox:GetText():lower()

    if term == "" or term == DEFAULT_SEARCH_TEXT:lower() then
        term = nil
        self.frames[mode].clearButton:Hide()
    else
        self.frames[mode].clearButton:Show()
    end

    local psFrameName = mode.."-"..self.frames[mode].title

    -- create filtered list of skills
    local foundSkills = {}

    local numSkills = mode == "craft" and GetNumCrafts() or GetNumTradeSkills()
    for skillIndex = 1, numSkills do
        local skillName, skillType, numAvailable = nil, nil, nil
        if mode == "craft" then
            skillName, _, skillType, numAvailable = GetCraftInfo(skillIndex)
        elseif mode == "trade" then
            skillName, skillType, numAvailable = GetTradeSkillInfo(skillIndex)
        end
        if skillName and skillType ~= "header" then
            if not term or string.find(skillName:lower(), term) then
                if (
                    not ProficientStorage.frames[psFrameName].hasMatsChecked
                    or numAvailable > 0
                ) then
                    tinsert(foundSkills, {name = skillName, index = skillIndex, available = numAvailable, type = skillType})
                end
            end
        elseif skillType == "header" and not isExpanded then
            ExpandTradeSkillSubClass(skillIndex)
        end
    end

    -- sort the list and prioritize favorites
    table.sort(foundSkills, function(a, b)
        if ProficientStorage.frames[psFrameName].favorites[a.name] and not ProficientStorage.frames[psFrameName].favorites[b.name] then
            return true
        elseif not ProficientStorage.frames[psFrameName].favorites[a.name] and ProficientStorage.frames[psFrameName].favorites[b.name] then
            return false
        else
            if ProficientStorage.frames[psFrameName].sortDropdownValue == "alphabetical" then
                return a.name < b.name
            elseif ProficientStorage.frames[psFrameName].sortDropdownValue == "level" then
                if SKILL_TYPE_SORT_ORDER[a.type] == SKILL_TYPE_SORT_ORDER[b.type] then
                    return a.name < b.name
                else
                    return SKILL_TYPE_SORT_ORDER[a.type] < SKILL_TYPE_SORT_ORDER[b.type]
                end
            else
                print("|cFFFF0000[Proficient] ".."|cFFFF0000Invalid sortDropdownValue: "..ProficientStorage.frames[psFrameName].sortDropdownValue)
                # default to alphabetical sorting
                return a.name < b.name
            end
        end
    end)

    local skillFrame = mode == "craft" and CraftListScrollFrame or TradeSkillListScrollFrame

    if addon.frames[mode]["resetSelection"] then
        if mode == "craft" then
            FauxScrollFrame_SetOffset(skillFrame, 0)
            if foundSkills[1] then
                CraftFrame_SetSelection(foundSkills[1].index)
                addon.frames[mode].resetSelection = false
             end
        elseif mode == "trade" then
            FauxScrollFrame_SetOffset(skillFrame, 0)
            if foundSkills[1] then
                TradeSkillFrame_SetSelection(foundSkills[1].index)
                addon.frames[mode].resetSelection = false
            end
        end
    end

    FauxScrollFrame_Update(
        skillFrame,
        #foundSkills,
        mode == "craft" and CRAFTS_DISPLAYED or TRADE_SKILLS_DISPLAYED,
        mode == "craft" and CRAFT_SKILL_HEIGHT or TRADE_SKILL_HEIGHT
    )

    local skillOffset = FauxScrollFrame_GetOffset(skillFrame)

    local highlightFrame = mode == "craft" and CraftHighlightFrame or TradeSkillHighlightFrame
    highlightFrame:Hide()

    local scrollFrame = mode == "craft" and CraftListScrollFrame or TradeSkillListScrollFrame

    for i = 1, mode == "craft" and CRAFTS_DISPLAYED or TRADE_SKILLS_DISPLAYED do
        local skillIndex = i + skillOffset
        local skillButton = _G[(mode == "craft" and "Craft" or "TradeSkillSkill")..i]

        if mode == "trade" then
            local skillButtonText = _G[(mode == "craft" and "Craft" or "TradeSkillSkill")..i.."Text"]
            skillButtonText:SetPoint("TOPLEFT", skillButton, "TOPLEFT", 3, 0)
        end

        if not foundSkills[skillIndex] then
            skillButton:Hide()
        else
            if scrollFrame:IsVisible() then
                skillButton:SetWidth(293)
            else
                skillButton:SetWidth(316)
            end

            local textColor = (mode == "craft" and CraftTypeColor[foundSkills[skillIndex].type] or TradeSkillTypeColor[foundSkills[skillIndex].type])
            if textColor then
                skillButton.text:SetTextColor(textColor.r, textColor.g, textColor.b)
            end

            skillButton:SetID(foundSkills[skillIndex].index)
            skillButton.skillName = foundSkills[skillIndex].name

            if foundSkills[skillIndex].available > 0 then
                skillButton:SetText(skillButton.skillName.." ("..foundSkills[skillIndex].available..")")
            else
                skillButton:SetText(skillButton.skillName)
            end

            skillButton:ClearNormalTexture()
            skillButton:GetNormalTexture():ClearAllPoints()
            skillButton:GetNormalTexture():SetPoint("TOPRIGHT", 0, 0)

            if ProficientStorage.frames[psFrameName].favorites[skillButton.skillName] then
                skillButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
            end

            skillButton:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
                    addon.frames[mode].searchBox:ClearFocus()
                elseif button == "RightButton" then
                    if ProficientStorage.frames[psFrameName].favorites[self.skillName] then
                        ProficientStorage.frames[psFrameName].favorites[self.skillName] = nil
                    else
                        ProficientStorage.frames[psFrameName].favorites[self.skillName] = true
                    end
                    addon:Search(mode)
                end
            end)

            skillButton:Show()

            if skillButton.skillName then
                local skillButtonHighlight = _G[(mode == "craft" and "Craft" or "TradeSkillSkill")..i.."Highlight"]
                skillButtonHighlight:SetTexture("")

                if (mode == "craft" and GetCraftSelectionIndex() or GetTradeSkillSelectionIndex()) == foundSkills[skillIndex].index then
                    if mode == "trade" and TradeSkillFrame then
                        TradeSkillFrame.numAvailable = foundSkills[skillIndex].available
                    end
                    highlightFrame:SetPoint("TOPLEFT", skillButton, "TOPLEFT", 0, 0)
                    highlightFrame:Show()
                    skillButton:LockHighlight()
                else
                    if not self:SelectionInList(mode, skillOffset, foundSkills) then
                        highlightFrame:Hide()
                    end
                    skillButton:UnlockHighlight()
                end
           end
        end
    end
end
