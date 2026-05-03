-- =========================================================================
-- SHIP'S OFFICER: A Comprehensive Nautical Package for Achaea
-- =========================================================================

-- Master Namespace Initialization
ShipsOfficer = ShipsOfficer or {}
ShipsOfficer.Navigator = ShipsOfficer.Navigator or {}
ShipsOfficer.Aide = ShipsOfficer.Aide or {}
ShipsOfficer.Aide.rawList = ShipsOfficer.Aide.rawList or {}
ShipsOfficer.Aide.equipList = ShipsOfficer.Aide.equipList or {}

-- =========================================================================
-- MODULE 1: NAVIGATOR (Map UI)
-- =========================================================================

-- Navigator Configuration
ShipsOfficer.Navigator.imagePath = getMudletHomeDir() .. "/Sea_Wilderness_Map_2020.png"
ShipsOfficer.Navigator.currentZoom = 100 
ShipsOfficer.Navigator.currentX = 50     
ShipsOfficer.Navigator.currentY = 50     

function ShipsOfficer.Navigator:init()
    if not self.container then
        self.container = Geyser.Container:new({
            name = "NavigatorContainer",
            x = "-400px", y = "-400px", 
            width = "400px", height = "400px",
        })

        self.label = Geyser.Label:new({
            name = "NavigatorLabel",
            x = 0, y = 0,
            width = "100%", height = "100%",
        }, self.container)
    end

    self:updateView()
    cecho("\n<blue>[Ship's Officer]:<reset> Nautical map UI Initialized.\n")
end

function ShipsOfficer.Navigator:updateView()
    local safePath = self.imagePath:gsub("\\", "/")
    if not safePath:starts("/") then safePath = "/" .. safePath end
    
    local css = string.format([[
        background-image: url("file://%s");
        background-color: #000000;
        background-repeat: no-repeat;
        background-position: %d%% %d%%;
        background-size: %d%%;
    ]], safePath, self.currentX, self.currentY, self.currentZoom)

    self.label:setStyleSheet(css)
end

function ShipsOfficer.Navigator:lookAt(location)
    location = location:lower():gsub(" ", "_")

    if location == "world" or location == "reset" then
        self.currentZoom = 100; self.currentX = 50; self.currentY = 50
    elseif location == "northern_sea" then
        self.currentZoom = 250; self.currentX = 50; self.currentY = 10
    elseif location == "southern_archipelago" then
        self.currentZoom = 300; self.currentX = 80; self.currentY = 90
    elseif location == "western_shallows" then
        self.currentZoom = 200; self.currentX = 10; self.currentY = 50
    else
        cecho("\n<firebrick>[Ship's Officer]:<reset> Unknown coordinate or region: " .. location .. "\n")
        return
    end

    self:updateView()
    cecho(string.format("\n<blue>[Ship's Officer]:<reset> Charting view to '<white>%s<reset>'.\n", location:gsub("_", " "):title()))
end

-- =========================================================================
-- MODULE 2: AIDE (Shipfitter's Calculator)
-- =========================================================================

-- Aide Databases
ShipsOfficer.Aide.recipes = {
    shipcloth = { cloth = 50 },
    shipiron  = { iron = 50, steel = 10 },
    shipwood  = { wood = 50, iron = 10 },
    shiplines = { rope = 50, iron = 10 },
    pitch     = { wood = 50, fat = 10 }
}

ShipsOfficer.Aide.equipment = {
    baittank     = { name = "Bait Tank", materials = { shipiron = 40, pitch = 5 } },
    beacon       = { name = "Beacon", materials = { shipiron = 20, goldbar = 50, stone = 50 } },
    trunk        = { name = "Trunk", materials = { shipwood = 5, shipiron = 5 } },
    standarddesk = { name = "Standard Desk", materials = { shipiron = 5, shipwood = 5 } },
    largedesk    = { name = "Large Desk", materials = { shipiron = 15, shipwood = 15 } },
    bell         = { name = "Bell", materials = { shipwood = 20, shiplines = 10, pitch = 10 } },
    leadline     = { name = "Leadline", materials = { leather = 10, rope = 40 } },
    sextant      = { name = "Sextant", materials = { shipiron = 15 } },
    salvagecrane = { name = "Salvage Crane", materials = { leather = 10, rope = 40 } },
    dredgecrane  = { name = "Dredge Crane", materials = { shipwood = 20, shipiron = 25, shiplines = 15 } },
    shipaxe      = { name = "Ship Axe", materials = { wood = 15, iron = 15 } },
    buoy         = { name = "Buoy", materials = { shipcloth = 3, shiplines = 3 } },
    float        = { name = "Float", materials = { shipwood = 3, shiplines = 3 } },
    loudhailer   = { name = "Loudhailer", materials = { wood = 10, cloth = 5 } },
    onager       = { name = "Onager", materials = { shipwood = 70, shipiron = 80, shiplines = 35 } },
    ballista     = { name = "Ballista", materials = { shipiron = 40, shipwood = 50, shiplines = 25 } },
    thrower      = { name = "Thrower", materials = { shipiron = 30, shipwood = 25, shiplines = 20 } }
}

ShipsOfficer.Aide.nominalPrices = {
    iron = 23, steel = 1050, wood = 105, rope = 23, cloth = 10, fat = 1, goldbar = 1000, stone = 40, leather = 40
}

-- Aide File I/O
function ShipsOfficer.Aide.getSavePath()
    return getMudletHomeDir() .. "/ShipsOfficer-Aide-Prices.lua"
end

function ShipsOfficer.Aide.savePrices()
    table.save(ShipsOfficer.Aide.getSavePath(), ShipsOfficer.Aide.nominalPrices)
end

function ShipsOfficer.Aide.loadPrices()
    local save_path = ShipsOfficer.Aide.getSavePath()
    if io.exists(save_path) then
        local saved_prices = {}
        table.load(save_path, saved_prices)
        for k, v in pairs(saved_prices) do ShipsOfficer.Aide.nominalPrices[k] = v end
    end
end

-- Formatting Helper
function ShipsOfficer.formatNumber(amount)
    local formatted = tostring(amount)
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

-- Aide List Management
function ShipsOfficer.Aide.listEquipment()
    cecho("\n<SeaGreen>=================================================================<reset>\n")
    cecho("<SeaGreen>                  Available Ship Equipment                       <reset>\n")
    cecho("<SeaGreen>=================================================================<reset>\n\n")

    local sortedKeys = {}
    for k, _ in pairs(ShipsOfficer.Aide.equipment) do table.insert(sortedKeys, k) end
    table.sort(sortedKeys)

    for _, key in ipairs(sortedKeys) do
        local item = ShipsOfficer.Aide.equipment[key]
        cecho(string.format("  * <cyan>%-15s<reset> : <white>%s<reset>\n", key, item.name))
    end
    
    cecho("\n<SeaGreen>=================================================================<reset>\n")
    cecho("  Use <cyan>so aide equip <amount> <keyword><reset> to add to your list.\n\n")
end

function ShipsOfficer.Aide.calculateSingle(amount, comm)
    amount = tonumber(amount) or 1
    comm = comm:lower()
    local recipe = ShipsOfficer.Aide.recipes[comm]

    if not recipe then
        cecho(string.format("\n<firebrick>[Ship's Officer]:<reset> Unknown ship commodity '%s'. Valid: shipcloth, shipiron, shipwood, shiplines, pitch.\n", comm))
        return
    end

    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> To craft <white>%s %s<reset>, you will need:\n", ShipsOfficer.formatNumber(amount), comm))
    for baseComm, baseAmount in pairs(recipe) do
        local totalNeeded = baseAmount * amount
        local displayComm = baseComm == "fat" and "animal fat" or baseComm
        cecho(string.format("  * <gold>%s<reset> %s\n", ShipsOfficer.formatNumber(totalNeeded), displayComm:title()))
    end
    echo("\n")
end

function ShipsOfficer.Aide.addToList(amount, comm)
    amount = tonumber(amount) or 1
    comm = comm:lower()
    ShipsOfficer.Aide.rawList[comm] = (ShipsOfficer.Aide.rawList[comm] or 0) + amount
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Added <white>%s %s<reset> to your list. (Total: %s)\n", ShipsOfficer.formatNumber(amount), comm, ShipsOfficer.formatNumber(ShipsOfficer.Aide.rawList[comm])))
end

function ShipsOfficer.Aide.addEquipToList(amount, equip)
    amount = tonumber(amount) or 1
    equip = equip:lower():gsub(" ", "") 
    local item = ShipsOfficer.Aide.equipment[equip]

    if not item then
        cecho(string.format("\n<firebrick>[Ship's Officer]:<reset> Unknown ship equipment '%s'.\n", equip))
        return
    end

    ShipsOfficer.Aide.equipList[equip] = (ShipsOfficer.Aide.equipList[equip] or 0) + amount
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Queued <white>%s %s<reset>.\n", ShipsOfficer.formatNumber(amount), item.name))
end

function ShipsOfficer.Aide.clearList()
    ShipsOfficer.Aide.rawList = {}
    ShipsOfficer.Aide.equipList = {}
    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Shopping list cleared.\n")
end

function ShipsOfficer.Aide.calculateList()
    if next(ShipsOfficer.Aide.rawList) == nil and next(ShipsOfficer.Aide.equipList) == nil then
        cecho("\n<firebrick>[Ship's Officer]:<reset> Your shopping list is empty. Use 'so aide add' or 'so aide equip' first.\n")
        return
    end

    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Current Shopping List:\n")

    if next(ShipsOfficer.Aide.equipList) ~= nil then
        cecho("\n  <cyan>Equipment Queued:<reset>\n")
        for equip, amt in pairs(ShipsOfficer.Aide.equipList) do
            local item = ShipsOfficer.Aide.equipment[equip]
            cecho(string.format("    * <white>%s<reset> %s\n", ShipsOfficer.formatNumber(amt), item.name))
        end
    end

    if next(ShipsOfficer.Aide.rawList) ~= nil then
        cecho("\n  <cyan>Additional Materials Queued:<reset>\n")
        for comm, amt in pairs(ShipsOfficer.Aide.rawList) do
            cecho(string.format("    * <white>%s<reset> %s\n", ShipsOfficer.formatNumber(amt), comm))
        end
    end

    local combinedRaw = {}
    local baseTotals = {}

    for comm, amt in pairs(ShipsOfficer.Aide.rawList) do combinedRaw[comm] = (combinedRaw[comm] or 0) + amt end
    for equip, amt in pairs(ShipsOfficer.Aide.equipList) do
        local item = ShipsOfficer.Aide.equipment[equip]
        for comm, commAmt in pairs(item.materials) do combinedRaw[comm] = (combinedRaw[comm] or 0) + (commAmt * amt) end
    end

    for comm, amt in pairs(combinedRaw) do
        if ShipsOfficer.Aide.recipes[comm] then
            for bComm, bAmount in pairs(ShipsOfficer.Aide.recipes[comm]) do
                baseTotals[bComm] = (baseTotals[bComm] or 0) + (bAmount * amt)
            end
        else
            baseTotals[comm] = (baseTotals[comm] or 0) + amt
        end
    end

    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Total Base Commodities Required:\n")
    for bComm, totalNeeded in pairs(baseTotals) do
        local displayComm = bComm == "fat" and "animal fat" or bComm
        cecho(string.format("  * <gold>%s<reset> %s\n", ShipsOfficer.formatNumber(totalNeeded), displayComm:title()))
    end
    echo("\n")
end

function ShipsOfficer.Aide.calculateCost(mode)
    mode = mode or "avg"

    if next(ShipsOfficer.Aide.rawList) == nil and next(ShipsOfficer.Aide.equipList) == nil then
        cecho("\n<firebrick>[Ship's Officer]:<reset> Your shopping list is empty. Add items first.\n")
        return
    end

    local combinedRaw = {}
    ShipsOfficer.Aide.baseTotals = {} 

    for comm, amt in pairs(ShipsOfficer.Aide.rawList) do combinedRaw[comm] = (combinedRaw[comm] or 0) + amt end
    for equip, amt in pairs(ShipsOfficer.Aide.equipList) do
        local item = ShipsOfficer.Aide.equipment[equip]
        for comm, commAmt in pairs(item.materials) do combinedRaw[comm] = (combinedRaw[comm] or 0) + (commAmt * amt) end
    end

    for comm, amt in pairs(combinedRaw) do
        if ShipsOfficer.Aide.recipes[comm] then
            for bComm, bAmount in pairs(ShipsOfficer.Aide.recipes[comm]) do
                ShipsOfficer.Aide.baseTotals[bComm] = (ShipsOfficer.Aide.baseTotals[bComm] or 0) + (bAmount * amt)
            end
        else
            ShipsOfficer.Aide.baseTotals[comm] = (ShipsOfficer.Aide.baseTotals[comm] or 0) + amt
        end
    end

    if mode == "avg" then
        local grandTotal = 0
        cecho("\n<SeaGreen>[Ship's Officer]:<reset> Average Cost Estimation (Instant):\n")
        
        for bComm, totalNeeded in pairs(ShipsOfficer.Aide.baseTotals) do
            local displayComm = bComm == "fat" and "animal fat" or bComm
            local avgPrice = ShipsOfficer.Aide.nominalPrices[bComm] or 50 
            local cost = totalNeeded * avgPrice
            grandTotal = grandTotal + cost

            cecho(string.format("  * <cyan>%s<reset>: Needed <white>%s<reset> @ ~<yellow>%sgp<reset> ea. Cost: <gold>%sgp<reset>\n", 
                displayComm:title(), ShipsOfficer.formatNumber(totalNeeded), ShipsOfficer.formatNumber(avgPrice), ShipsOfficer.formatNumber(cost)))
        end
        cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Grand Total Average Cost: <gold>%s gp<reset>\n\n", ShipsOfficer.formatNumber(grandTotal)))
        return
    end

    -- Market Scraper Mode
    ShipsOfficer.Aide.marketNeeded = {}
    local commCount = 0
    for k, v in pairs(ShipsOfficer.Aide.baseTotals) do 
        ShipsOfficer.Aide.marketNeeded[k] = v 
        commCount = commCount + 1
    end
    
    ShipsOfficer.Aide.marketBought = {}
    ShipsOfficer.Aide.marketCost = {}

    local estimatedTime = (commCount * 1.6) + 1.0
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Fetching live market prices. Please <yellow>stand still for %.1f seconds<reset>...\n", estimatedTime))

    if ShipsOfficer.Aide.gagTrigger1 then killTrigger(ShipsOfficer.Aide.gagTrigger1) end
    ShipsOfficer.Aide.gagTrigger1 = tempRegexTrigger("^Listing all .+ commodities:$", [[deleteLine()]])

    if ShipsOfficer.Aide.gagTrigger2 then killTrigger(ShipsOfficer.Aide.gagTrigger2) end
    ShipsOfficer.Aide.gagTrigger2 = tempRegexTrigger("^Commodity\\s+Price\\s+Quantity Available$", [[deleteLine()]])

    if ShipsOfficer.Aide.gagTrigger3 then killTrigger(ShipsOfficer.Aide.gagTrigger3) end
    ShipsOfficer.Aide.gagTrigger3 = tempRegexTrigger("^\\-{40,}$", [[deleteLine()]]) 

    if ShipsOfficer.Aide.gagTrigger4 then killTrigger(ShipsOfficer.Aide.gagTrigger4) end
    ShipsOfficer.Aide.gagTrigger4 = tempRegexTrigger("^There are no .+ commodities for sale\\.$", [[deleteLine()]])

    if ShipsOfficer.Aide.scraperTrigger then killTrigger(ShipsOfficer.Aide.scraperTrigger) end
    ShipsOfficer.Aide.scraperTrigger = tempRegexTrigger("^([A-Za-z ]+?)\\s+(\\d+)gp\\s+(\\d+)$", [[
        deleteLine()
        local comm = matches[2]:lower():match("^%s*(.-)%s*$") 
        if comm == "animal fat" then comm = "fat" end
        local price = tonumber(matches[3])
        local avail = tonumber(matches[4])

        if ShipsOfficer.Aide.marketNeeded[comm] and ShipsOfficer.Aide.marketNeeded[comm] > 0 then
            local taking = math.min(avail, ShipsOfficer.Aide.marketNeeded[comm])
            ShipsOfficer.Aide.marketNeeded[comm] = ShipsOfficer.Aide.marketNeeded[comm] - taking
            ShipsOfficer.Aide.marketBought[comm] = (ShipsOfficer.Aide.marketBought[comm] or 0) + taking
            ShipsOfficer.Aide.marketCost[comm] = (ShipsOfficer.Aide.marketCost[comm] or 0) + (taking * price)
        end
    ]])

    local delay = 0
    for bComm, _ in pairs(ShipsOfficer.Aide.baseTotals) do
        local queryComm = bComm == "fat" and "animal fat" or bComm
        tempTimer(delay, string.format([[send("cm list %s", false)]], queryComm))
        delay = delay + 1.6
    end

    if ShipsOfficer.Aide.summaryTimer then killTimer(ShipsOfficer.Aide.summaryTimer) end
    ShipsOfficer.Aide.summaryTimer = tempTimer(delay + 1.5, [[ShipsOfficer.Aide.printCostSummary()]])
end

function ShipsOfficer.Aide.printCostSummary()
    if ShipsOfficer.Aide.scraperTrigger then killTrigger(ShipsOfficer.Aide.scraperTrigger); ShipsOfficer.Aide.scraperTrigger = nil end
    if ShipsOfficer.Aide.gagTrigger1 then killTrigger(ShipsOfficer.Aide.gagTrigger1); ShipsOfficer.Aide.gagTrigger1 = nil end
    if ShipsOfficer.Aide.gagTrigger2 then killTrigger(ShipsOfficer.Aide.gagTrigger2); ShipsOfficer.Aide.gagTrigger2 = nil end
    if ShipsOfficer.Aide.gagTrigger3 then killTrigger(ShipsOfficer.Aide.gagTrigger3); ShipsOfficer.Aide.gagTrigger3 = nil end
    if ShipsOfficer.Aide.gagTrigger4 then killTrigger(ShipsOfficer.Aide.gagTrigger4); ShipsOfficer.Aide.gagTrigger4 = nil end

    local grandTotal = 0
    local pricesUpdated = false
    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Live Market Cost Estimation:\n")

    for bComm, totalNeeded in pairs(ShipsOfficer.Aide.baseTotals) do
        local displayComm = bComm == "fat" and "animal fat" or bComm
        local bought = ShipsOfficer.Aide.marketBought[bComm] or 0
        local cost = ShipsOfficer.Aide.marketCost[bComm] or 0
        local missing = totalNeeded - bought

        grandTotal = grandTotal + cost

        if bought > 0 then
            ShipsOfficer.Aide.nominalPrices[bComm] = math.floor(cost / bought)
            pricesUpdated = true
        end

        local statusStr = ""
        if missing > 0 then
            statusStr = string.format("<firebrick>(WARNING: Market is short %s units!)<reset>", ShipsOfficer.formatNumber(missing))
        else
            statusStr = "<green>(Fully available)<reset>"
        end

        cecho(string.format("  * <cyan>%s<reset>: Needed <white>%s<reset>, Found <white>%s<reset>. Cost: <gold>%sgp<reset> %s\n", 
            displayComm:title(), ShipsOfficer.formatNumber(totalNeeded), ShipsOfficer.formatNumber(bought), ShipsOfficer.formatNumber(cost), statusStr))
    end

    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Grand Total Estimated Cost: <gold>%s gp<reset>\n\n", ShipsOfficer.formatNumber(grandTotal)))

    if pricesUpdated then
        ShipsOfficer.Aide.savePrices()
        cecho("<SeaGreen>[Ship's Officer]:<reset> Nominal market prices successfully updated and saved.\n")
    end
end

-- =========================================================================
-- UNIFIED HELP & ROUTING (The Master Alias)
-- =========================================================================

function ShipsOfficer.showHelp()
    cecho("\n<SeaGreen>=================================================================<reset>\n")
    cecho("<SeaGreen>                     Ship's Officer - Help Manual                <reset>\n")
    cecho("<SeaGreen>=================================================================<reset>\n\n")
    
    cecho("<yellow>--- MODULE: Navigator (Map) ---\n<reset>")
    cecho("  <cyan>so map <location><reset>\n")
    cecho("    * Pans and zooms the map GUI to the specified location.\n")
    cecho("    * <gold>Example:<reset> so map northern sea\n\n")

    cecho("<yellow>--- MODULE: Aide (Crafting & Cost Estimation) ---\n<reset>")
    cecho("  <cyan>so aide calc <amount> <commodity><reset>\n")
    cecho("    * Instantly calculates base materials for a single ship commodity.\n")
    cecho("  <cyan>so aide equip<reset>\n")
    cecho("    * Lists all available ship equipment you can add to your list.\n")
    cecho("  <cyan>so aide equip <amount> <equipment><reset>\n")
    cecho("    * Adds the required materials for ship equipment to your list.\n")
    cecho("  <cyan>so aide add <amount> <commodity><reset>\n")
    cecho("    * Adds raw materials or ship commodities directly to your list.\n")
    cecho("  <cyan>so aide list<reset>\n")
    cecho("    * Displays your current queued list and the base commodities needed.\n")
    cecho("  <cyan>so aide cost [avg | now]<reset>\n")
    cecho("    * Estimates the gold cost of your list based on historical averages (avg) or live market scraping (now).\n")
    cecho("  <cyan>so aide clear<reset>\n")
    cecho("    * Empties your current shopping list.\n\n")

    cecho("<yellow>--- UPCOMING MODULES ---\n<reset>")
    cecho("  <geSilver>* Crew Wages, Morale & Provisions\n")
    cecho("  * Ammunition Tracking\n")
    cecho("  * Trade Deal Monitoring\n<reset>")
    
    cecho("\n<SeaGreen>=================================================================<reset>\n")
end

-- Kill old master alias if it exists
if ShipsOfficer.masterAlias then killAlias(ShipsOfficer.masterAlias) end

-- Create the Unified Master Alias
ShipsOfficer.masterAlias = tempAlias("^so(?:\\s+(.*))?$", string.format([[
    local input = matches[2] or ""

    if input == "" or input:lower() == "help" then
        ShipsOfficer.showHelp()
        return
    end

    -- Helper to catch bad syntax
    local function syntaxError()
        cecho(string.format("\n<firebrick>[Ship's Officer]:<reset> Invalid command or syntax: 'so %%s'\n", input))
        cecho("<SeaGreen>[Ship's Officer]:<reset> Showing help menu...\n")
        ShipsOfficer.showHelp()
    end

    -- Split input into module and remainder
    local module, rest = input:match("^(%%a+)%%s*(.*)$")
    module = module and module:lower() or ""

    -- Route to Navigator Map
    if module == "map" then
        if rest ~= "" then
            ShipsOfficer.Navigator:lookAt(rest)
        else
            syntaxError()
        end

    -- Route to Aide
    elseif module == "aide" then
        local cmd, args = rest:match("^(%%a+)%%s*(.*)$")
        cmd = cmd and cmd:lower() or ""

        if cmd == "calc" then
            local amt, comm = args:match("^(%%d+)%%s+(%%a+)$")
            if amt and comm then ShipsOfficer.Aide.calculateSingle(amt, comm) else syntaxError() end

        elseif cmd == "add" then
            local amt, comm = args:match("^(%%d+)%%s+(%%a+)$")
            if amt and comm then ShipsOfficer.Aide.addToList(amt, comm) else syntaxError() end

        elseif cmd == "equip" then
            if args == "" then
                ShipsOfficer.Aide.listEquipment()
            else
                local amt, equip = args:match("^(%%d+)%%s+(.+)$")
                if amt and equip then ShipsOfficer.Aide.addEquipToList(amt, equip) else syntaxError() end
            end

        elseif cmd == "list" and args == "" then
            ShipsOfficer.Aide.calculateList()

        elseif cmd == "cost" then
            if args == "" or args:lower() == "avg" then
                ShipsOfficer.Aide.calculateCost("avg")
            elseif args:lower() == "now" then
                ShipsOfficer.Aide.calculateCost("now")
            else
                syntaxError()
            end

        elseif cmd == "clear" and args == "" then
            ShipsOfficer.Aide.clearList()
        else
            syntaxError()
        end

    else
        syntaxError()
    end
]]))

-- =========================================================================
-- INITIALIZATION CALLS
-- =========================================================================

ShipsOfficer.Aide.loadPrices()
ShipsOfficer.Navigator:init()