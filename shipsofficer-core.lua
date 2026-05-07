-- =========================================================================
-- SHIP'S OFFICER: A Comprehensive Nautical Package for Achaea
-- =========================================================================

-- Master Namespace Initialization
ShipsOfficer = ShipsOfficer or {}
ShipsOfficer.Navigator = ShipsOfficer.Navigator or {}
ShipsOfficer.shipfit = ShipsOfficer.shipfit or {}
ShipsOfficer.shipfit.rawList = ShipsOfficer.shipfit.rawList or {}
ShipsOfficer.shipfit.equipList = ShipsOfficer.shipfit.equipList or {}
ShipsOfficer.Purser = ShipsOfficer.Purser or {}
ShipsOfficer.Purser.currentDeal = ShipsOfficer.Purser.currentDeal or nil

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

-- =========================================================================
-- MODULE 1: NAVIGATOR (Map UI)
-- =========================================================================

ShipsOfficer.Navigator.imagePath = getMudletHomeDir() .. "/Sea_Wilderness_Map_2020.png"
ShipsOfficer.Navigator.currentZoom = 100 
ShipsOfficer.Navigator.currentX = 50     
ShipsOfficer.Navigator.currentY = 50     

function ShipsOfficer.Navigator:init()
    if not self.container then
        self.container = Geyser.Container:new({
            name = "NavigatorContainer", x = "-400px", y = "-400px", width = "400px", height = "400px",
        })
        self.label = Geyser.Label:new({
            name = "NavigatorLabel", x = 0, y = 0, width = "100%", height = "100%",
        }, self.container)
    end
    self:updateView()
end

function ShipsOfficer.Navigator:updateView()
    local safePath = self.imagePath:gsub("\\", "/")
    if not safePath:starts("/") then safePath = "/" .. safePath end
    local css = string.format([[
        background-image: url("file://%s"); background-color: #000000; background-repeat: no-repeat;
        background-position: %d%% %d%%; background-size: %d%%;
    ]], safePath, self.currentX, self.currentY, self.currentZoom)
    self.label:setStyleSheet(css)
end

function ShipsOfficer.Navigator:lookAt(location)
    location = location:lower():gsub(" ", "_")
    if location == "world" or location == "reset" then self.currentZoom = 100; self.currentX = 50; self.currentY = 50
    elseif location == "northern_sea" then self.currentZoom = 250; self.currentX = 50; self.currentY = 10
    elseif location == "southern_archipelago" then self.currentZoom = 300; self.currentX = 80; self.currentY = 90
    elseif location == "western_shallows" then self.currentZoom = 200; self.currentX = 10; self.currentY = 50
    else cecho("\n<firebrick>[Ship's Officer]:<reset> Unknown coordinate or region: " .. location .. "\n"); return end
    self:updateView()
    cecho(string.format("\n<blue>[Ship's Officer]:<reset> Charting view to '<white>%s<reset>'.\n", location:gsub("_", " "):title()))
end

-- =========================================================================
-- MODULE 2: SHIPFITTER (Crafting Calculator)
-- =========================================================================

ShipsOfficer.shipfit.recipes = {
    shipcloth = { cloth = 50 }, shipiron  = { iron = 50, steel = 10 }, shipwood  = { wood = 50, iron = 10 },
    shiplines = { rope = 50, iron = 10 }, pitch = { wood = 50, fat = 10 }
}

ShipsOfficer.shipfit.equipment = {
    baittank = { name = "Bait Tank", materials = { shipiron = 40, pitch = 5 } },
    beacon = { name = "Beacon", materials = { shipiron = 20, goldbar = 50, stone = 50 } },
    trunk = { name = "Trunk", materials = { shipwood = 5, shipiron = 5 } },
    standarddesk = { name = "Standard Desk", materials = { shipiron = 5, shipwood = 5 } },
    largedesk = { name = "Large Desk", materials = { shipiron = 15, shipwood = 15 } },
    bell = { name = "Bell", materials = { shipwood = 20, shiplines = 10, pitch = 10 } },
    leadline = { name = "Leadline", materials = { leather = 10, rope = 40 } },
    sextant = { name = "Sextant", materials = { shipiron = 15 } },
    salvagecrane = { name = "Salvage Crane", materials = { leather = 10, rope = 40 } },
    dredgecrane = { name = "Dredge Crane", materials = { shipwood = 20, shipiron = 25, shiplines = 15 } },
    shipaxe = { name = "Ship Axe", materials = { wood = 15, iron = 15 } },
    buoy = { name = "Buoy", materials = { shipcloth = 3, shiplines = 3 } },
    float = { name = "Float", materials = { shipwood = 3, shiplines = 3 } },
    loudhailer = { name = "Loudhailer", materials = { wood = 10, cloth = 5 } },
    onager = { name = "Onager", materials = { shipwood = 70, shipiron = 80, shiplines = 35 } },
    ballista = { name = "Ballista", materials = { shipiron = 40, shipwood = 50, shiplines = 25 } },
    thrower = { name = "Thrower", materials = { shipiron = 30, shipwood = 25, shiplines = 20 } }
}

ShipsOfficer.shipfit.nominalPrices = { iron = 23, steel = 1050, wood = 105, rope = 23, cloth = 10, fat = 1, goldbar = 1000, stone = 40, leather = 40 }

function ShipsOfficer.shipfit.getSavePath() return getMudletHomeDir() .. "/ShipsOfficer-shipfit-Prices.lua" end
function ShipsOfficer.shipfit.savePrices() table.save(ShipsOfficer.shipfit.getSavePath(), ShipsOfficer.shipfit.nominalPrices) end
function ShipsOfficer.shipfit.loadPrices()
    if io.exists(ShipsOfficer.shipfit.getSavePath()) then
        local p = {}; table.load(ShipsOfficer.shipfit.getSavePath(), p); for k, v in pairs(p) do ShipsOfficer.shipfit.nominalPrices[k] = v end
    end
end

function ShipsOfficer.shipfit.listEquipment()
    cecho("\n<SeaGreen>=================================================================<reset>\n<SeaGreen>                  Available Ship Equipment                       <reset>\n<SeaGreen>=================================================================<reset>\n\n")
    local sorted = {}; for k, _ in pairs(ShipsOfficer.shipfit.equipment) do table.insert(sorted, k) end; table.sort(sorted)
    for _, key in ipairs(sorted) do cecho(string.format("  * <cyan>%-15s<reset> : <white>%s<reset>\n", key, ShipsOfficer.shipfit.equipment[key].name)) end
    cecho("\n<SeaGreen>=================================================================<reset>\n  Use <cyan>so shipfit equip <amount> <keyword><reset> to add to your list.\n\n")
end

function ShipsOfficer.shipfit.calculateSingle(amount, comm)
    amount = tonumber(amount) or 1; comm = comm:lower()
    local recipe = ShipsOfficer.shipfit.recipes[comm]
    if not recipe then cecho(string.format("\n<firebrick>[Ship's Officer]:<reset> Unknown ship commodity '%s'. Valid: shipcloth, shipiron, shipwood, shiplines, pitch.\n", comm)); return end
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> To craft <white>%s %s<reset>, you will need:\n", ShipsOfficer.formatNumber(amount), comm))
    for bc, ba in pairs(recipe) do cecho(string.format("  * <gold>%s<reset> %s\n", ShipsOfficer.formatNumber(ba * amount), (bc == "fat" and "animal fat" or bc):title())) end
    echo("\n")
end

function ShipsOfficer.shipfit.addToList(amount, comm)
    amount = tonumber(amount) or 1; comm = comm:lower()
    ShipsOfficer.shipfit.rawList[comm] = (ShipsOfficer.shipfit.rawList[comm] or 0) + amount
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Added <white>%s %s<reset> to your list. (Total: %s)\n", ShipsOfficer.formatNumber(amount), comm, ShipsOfficer.formatNumber(ShipsOfficer.shipfit.rawList[comm])))
end

function ShipsOfficer.shipfit.addEquipToList(amount, equip)
    amount = tonumber(amount) or 1; equip = equip:lower():gsub(" ", "") 
    if not ShipsOfficer.shipfit.equipment[equip] then cecho(string.format("\n<firebrick>[Ship's Officer]:<reset> Unknown equipment '%s'.\n", equip)); return end
    ShipsOfficer.shipfit.equipList[equip] = (ShipsOfficer.shipfit.equipList[equip] or 0) + amount
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Queued <white>%s %s<reset>.\n", ShipsOfficer.formatNumber(amount), ShipsOfficer.shipfit.equipment[equip].name))
end

function ShipsOfficer.shipfit.clearList()
    ShipsOfficer.shipfit.rawList = {}; ShipsOfficer.shipfit.equipList = {}; cecho("\n<SeaGreen>[Ship's Officer]:<reset> Shopping list cleared.\n")
end

function ShipsOfficer.shipfit.calculateList()
    if next(ShipsOfficer.shipfit.rawList) == nil and next(ShipsOfficer.shipfit.equipList) == nil then cecho("\n<firebrick>[Ship's Officer]:<reset> Your shopping list is empty.\n"); return end
    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Current Shopping List:\n")
    if next(ShipsOfficer.shipfit.equipList) ~= nil then
        cecho("\n  <cyan>Equipment Queued:<reset>\n"); for eq, amt in pairs(ShipsOfficer.shipfit.equipList) do cecho(string.format("    * <white>%s<reset> %s\n", ShipsOfficer.formatNumber(amt), ShipsOfficer.shipfit.equipment[eq].name)) end
    end
    if next(ShipsOfficer.shipfit.rawList) ~= nil then
        cecho("\n  <cyan>Additional Materials Queued:<reset>\n"); for cm, amt in pairs(ShipsOfficer.shipfit.rawList) do cecho(string.format("    * <white>%s<reset> %s\n", ShipsOfficer.formatNumber(amt), cm)) end
    end

    local cRaw, bTot = {}, {}
    for cm, amt in pairs(ShipsOfficer.shipfit.rawList) do cRaw[cm] = (cRaw[cm] or 0) + amt end
    for eq, amt in pairs(ShipsOfficer.shipfit.equipList) do for cm, cAmt in pairs(ShipsOfficer.shipfit.equipment[eq].materials) do cRaw[cm] = (cRaw[cm] or 0) + (cAmt * amt) end end
    for cm, amt in pairs(cRaw) do
        if ShipsOfficer.shipfit.recipes[cm] then for bC, bA in pairs(ShipsOfficer.shipfit.recipes[cm]) do bTot[bC] = (bTot[bC] or 0) + (bA * amt) end else bTot[cm] = (bTot[cm] or 0) + amt end
    end

    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Total Base Commodities Required:\n")
    for bC, tN in pairs(bTot) do cecho(string.format("  * <gold>%s<reset> %s\n", ShipsOfficer.formatNumber(tN), (bC == "fat" and "animal fat" or bC):title())) end
    echo("\n")
end

function ShipsOfficer.shipfit.calculateCost(mode)
    mode = mode or "avg"

    if next(ShipsOfficer.shipfit.rawList) == nil and next(ShipsOfficer.shipfit.equipList) == nil then
        cecho("\n<firebrick>[Ship's Officer]:<reset> Your shopping list is empty. Add items first.\n")
        return
    end

    local combinedRaw = {}
    ShipsOfficer.shipfit.baseTotals = {} 

    for comm, amt in pairs(ShipsOfficer.shipfit.rawList) do combinedRaw[comm] = (combinedRaw[comm] or 0) + amt end
    for equip, amt in pairs(ShipsOfficer.shipfit.equipList) do
        local item = ShipsOfficer.shipfit.equipment[equip]
        for comm, commAmt in pairs(item.materials) do combinedRaw[comm] = (combinedRaw[comm] or 0) + (commAmt * amt) end
    end

    for comm, amt in pairs(combinedRaw) do
        if ShipsOfficer.shipfit.recipes[comm] then
            for bComm, bAmount in pairs(ShipsOfficer.shipfit.recipes[comm]) do
                ShipsOfficer.shipfit.baseTotals[bComm] = (ShipsOfficer.shipfit.baseTotals[bComm] or 0) + (bAmount * amt)
            end
        else
            ShipsOfficer.shipfit.baseTotals[comm] = (ShipsOfficer.shipfit.baseTotals[comm] or 0) + amt
        end
    end

    if mode == "avg" then
        local grandTotal = 0
        cecho("\n<SeaGreen>[Ship's Officer]:<reset> Average Cost Estimation (Instant):\n")
        
        for bComm, totalNeeded in pairs(ShipsOfficer.shipfit.baseTotals) do
            local displayComm = bComm == "fat" and "animal fat" or bComm
            local avgPrice = ShipsOfficer.shipfit.nominalPrices[bComm] or 50 
            local cost = totalNeeded * avgPrice
            grandTotal = grandTotal + cost

            cecho(string.format("  * <cyan>%s<reset>: Needed <white>%s<reset> @ ~<yellow>%sgp<reset> ea. Cost: <gold>%sgp<reset>\n", 
                displayComm:title(), ShipsOfficer.formatNumber(totalNeeded), ShipsOfficer.formatNumber(avgPrice), ShipsOfficer.formatNumber(cost)))
        end
        cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Grand Total Average Cost: <gold>%s gp<reset>\n\n", ShipsOfficer.formatNumber(grandTotal)))
        return
    end

    -- Market Scraper Mode
    ShipsOfficer.shipfit.marketNeeded = {}
    local commCount = 0
    for k, v in pairs(ShipsOfficer.shipfit.baseTotals) do 
        ShipsOfficer.shipfit.marketNeeded[k] = v 
        commCount = commCount + 1
    end
    
    ShipsOfficer.shipfit.marketBought = {}
    ShipsOfficer.shipfit.marketCost = {}

    local estimatedTime = (commCount * 1.6) + 1.0
    cecho(string.format("\n<SeaGreen>[Ship's Officer]:<reset> Fetching live market prices. Please <yellow>stand still for %.1f seconds<reset>...\n", estimatedTime))

    if ShipsOfficer.shipfit.gagTrigger1 then killTrigger(ShipsOfficer.shipfit.gagTrigger1) end
    ShipsOfficer.shipfit.gagTrigger1 = tempRegexTrigger("^Listing all .+ commodities:$", [[deleteLine()]])

    if ShipsOfficer.shipfit.gagTrigger2 then killTrigger(ShipsOfficer.shipfit.gagTrigger2) end
    ShipsOfficer.shipfit.gagTrigger2 = tempRegexTrigger("^Commodity\\s+Price\\s+Quantity Available$", [[deleteLine()]])

    if ShipsOfficer.shipfit.gagTrigger3 then killTrigger(ShipsOfficer.shipfit.gagTrigger3) end
    ShipsOfficer.shipfit.gagTrigger3 = tempRegexTrigger("^\\-{40,}$", [[deleteLine()]]) 

    if ShipsOfficer.shipfit.gagTrigger4 then killTrigger(ShipsOfficer.shipfit.gagTrigger4) end
    ShipsOfficer.shipfit.gagTrigger4 = tempRegexTrigger("^There are no .+ commodities for sale\\.$", [[deleteLine()]])

    if ShipsOfficer.shipfit.scraperTrigger then killTrigger(ShipsOfficer.shipfit.scraperTrigger) end
    ShipsOfficer.shipfit.scraperTrigger = tempRegexTrigger("^([A-Za-z ]+?)\\s+(\\d+)gp\\s+(\\d+)$", [[
        deleteLine()
        local comm = matches[2]:lower():match("^%s*(.-)%s*$") 
        if comm == "animal fat" then comm = "fat" end
        local price = tonumber(matches[3])
        local avail = tonumber(matches[4])

        if ShipsOfficer.shipfit.marketNeeded[comm] and ShipsOfficer.shipfit.marketNeeded[comm] > 0 then
            local taking = math.min(avail, ShipsOfficer.shipfit.marketNeeded[comm])
            ShipsOfficer.shipfit.marketNeeded[comm] = ShipsOfficer.shipfit.marketNeeded[comm] - taking
            ShipsOfficer.shipfit.marketBought[comm] = (ShipsOfficer.shipfit.marketBought[comm] or 0) + taking
            ShipsOfficer.shipfit.marketCost[comm] = (ShipsOfficer.shipfit.marketCost[comm] or 0) + (taking * price)
        end
    ]])

    local delay = 0
    for bComm, _ in pairs(ShipsOfficer.shipfit.baseTotals) do
        local queryComm = bComm == "fat" and "animal fat" or bComm
        tempTimer(delay, string.format([[send("cm list %s", false)]], queryComm))
        delay = delay + 1.6
    end

    if ShipsOfficer.shipfit.summaryTimer then killTimer(ShipsOfficer.shipfit.summaryTimer) end
    ShipsOfficer.shipfit.summaryTimer = tempTimer(delay + 1.5, [[ShipsOfficer.shipfit.printCostSummary()]])
end

function ShipsOfficer.shipfit.printCostSummary()
    if ShipsOfficer.shipfit.scraperTrigger then killTrigger(ShipsOfficer.shipfit.scraperTrigger); ShipsOfficer.shipfit.scraperTrigger = nil end
    if ShipsOfficer.shipfit.gagTrigger1 then killTrigger(ShipsOfficer.shipfit.gagTrigger1); ShipsOfficer.shipfit.gagTrigger1 = nil end
    if ShipsOfficer.shipfit.gagTrigger2 then killTrigger(ShipsOfficer.shipfit.gagTrigger2); ShipsOfficer.shipfit.gagTrigger2 = nil end
    if ShipsOfficer.shipfit.gagTrigger3 then killTrigger(ShipsOfficer.shipfit.gagTrigger3); ShipsOfficer.shipfit.gagTrigger3 = nil end
    if ShipsOfficer.shipfit.gagTrigger4 then killTrigger(ShipsOfficer.shipfit.gagTrigger4); ShipsOfficer.shipfit.gagTrigger4 = nil end

    local grandTotal = 0
    local pricesUpdated = false
    cecho("\n<SeaGreen>[Ship's Officer]:<reset> Live Market Cost Estimation:\n")

    for bComm, totalNeeded in pairs(ShipsOfficer.shipfit.baseTotals) do
        local displayComm = bComm == "fat" and "animal fat" or bComm
        local bought = ShipsOfficer.shipfit.marketBought[bComm] or 0
        local cost = ShipsOfficer.shipfit.marketCost[bComm] or 0
        local missing = totalNeeded - bought

        grandTotal = grandTotal + cost

        if bought > 0 then
            ShipsOfficer.shipfit.nominalPrices[bComm] = math.floor(cost / bought)
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
        ShipsOfficer.shipfit.savePrices()
        cecho("<SeaGreen>[Ship's Officer]:<reset> Nominal market prices successfully updated and saved.\n")
    end
end

-- =========================================================================
-- MODULE 3: THE PURSER (Trade Deals & Routing)
-- =========================================================================

ShipsOfficer.Purser.fees = {
    ["Colchis"] = 0, ["Karbaz"] = 200, ["Minos"] = 0, ["Mysia"] = 1000, ["Orilla"] = 0, 
    ["Shala-Khulia"] = 500, ["Shastaan"] = 1000, ["Suliel"] = 500, ["Tasur'ke"] = 2000, 
    ["Thraasi"] = 2000, ["Umbrin"] = 0, ["Zanzibaar"] = 2000, ["Zaphar"] = 100
}

ShipsOfficer.Purser.bases = {
    ["cotton"] = "Shastaan", ["sandstone"] = "Shastaan", ["wool"] = "Tasur'ke",
    ["ore"] = "Thraasi", ["grain"] = "Thraasi", ["salt"] = "Zaphar"
}

ShipsOfficer.Purser.trades = {
    {port="Colchis", in_qty=3, in_item="marble", out_qty=2, out_item="silk"},
    {port="Colchis", in_qty=3, in_item="incense", out_qty=2, out_item="perfume"},
    {port="Colchis", in_qty=2, in_item="incense", out_qty=3, out_item="glass"},
    {port="Karbaz", in_qty=3, in_item="honey", out_qty=2, out_item="ceramics"},
    {port="Karbaz", in_qty=3, in_item="hemp", out_qty=2, out_item="ceramics"},
    {port="Karbaz", in_qty=3, in_item="hemp", out_qty=2, out_item="marble"},
    {port="Karbaz", in_qty=3, in_item="granite", out_qty=2, out_item="marble"},
    {port="Minos", in_qty=4, in_item="salt", out_qty=3, out_item="honey"},
    {port="Minos", in_qty=3, in_item="marble", out_qty=2, out_item="wine"},
    {port="Minos", in_qty=3, in_item="tea", out_qty=2, out_item="wine"},
    {port="Mysia", in_qty=3, in_item="porcelain", out_qty=2, out_item="tabac"},
    {port="Mysia", in_qty=3, in_item="silk", out_qty=2, out_item="tabac"},
    {port="Mysia", in_qty=2, in_item="porcelain", out_qty=3, out_item="ceramics"},
    {port="Mysia", in_qty=2, in_item="silk", out_qty=3, out_item="ceramics"},
    {port="Orilla", in_qty=4, in_item="cotton", out_qty=3, out_item="terracotta"},
    {port="Shala-Khulia", in_qty=3, in_item="glass", out_qty=2, out_item="incense"},
    {port="Shastaan", in_qty=4, in_item="furs", out_qty=3, out_item="hemp"},
    {port="Shastaan", in_qty=2, in_item="perfume", out_qty=1, out_item="gems"},
    {port="Shastaan", in_qty=2, in_item="perfume", out_qty=3, out_item="wine"},
    {port="Suliel", in_qty=1, in_item="wool", out_qty=1, out_item="furs"},
    {port="Suliel", in_qty=3, in_item="kahwe", out_qty=2, out_item="incense"},
    {port="Tasur'ke", in_qty=4, in_item="sandstone", out_qty=3, out_item="granite"},
    {port="Tasur'ke", in_qty=3, in_item="sugar", out_qty=2, out_item="kahwe"},
    {port="Thraasi", in_qty=3, in_item="fruits", out_qty=2, out_item="glass"},
    {port="Thraasi", in_qty=1, in_item="spices", out_qty=2, out_item="armaments"},
    {port="Umbrin", in_qty=3, in_item="ceramics", out_qty=2, out_item="porcelain"},
    {port="Umbrin", in_qty=3, in_item="wine", out_qty=2, out_item="armaments"},
    {port="Umbrin", in_qty=2, in_item="wine", out_qty=3, out_item="kahwe"},
    {port="Zanzibaar", in_qty=4, in_item="ore", out_qty=3, out_item="fruits"},
    {port="Zanzibaar", in_qty=3, in_item="terracotta", out_qty=2, out_item="tea"},
    {port="Zanzibaar", in_qty=2, in_item="armaments", out_qty=1, out_item="spices"},
    {port="Zanzibaar", in_qty=1, in_item="gems", out_qty=2, out_item="perfume"},
    {port="Zanzibaar", in_qty=2, in_item="armaments", out_qty=3, out_item="incense"},
    {port="Zaphar", in_qty=4, in_item="grain", out_qty=3, out_item="sugar"}
}

-- Triggers to auto-capture Trade Deals
function ShipsOfficer.Purser:initTriggers()
    if self.dockTrigger then killTrigger(self.dockTrigger) end
    self.dockTrigger = tempRegexTrigger("^The ship completes docking at the harbour, and the crew lowers the anchor\\.$", [[
        send("harbour info")
    ]])

    if self.dealTrigger then killTrigger(self.dealTrigger) end
    self.dealTrigger = tempRegexTrigger("^\\s*Deliver (\\d+) ([a-zA-Z]+) to (.+?) Harbour in return for (.+?)\\. \\((.+?)\\)$", [[
        local rewardStr = matches[5]
        local rewardGold = tonumber(rewardStr:match("^(%d+) gold")) or 0

        ShipsOfficer.Purser.currentDeal = {
            qty = tonumber(matches[2]),
            item = matches[3]:lower(),
            destination = matches[4],
            rewardStr = rewardStr,
            rewardGold = rewardGold
        }
        cecho("\n<blue>[Ship's Officer]:<reset> <SeaGreen>Trade Deal recorded!<reset> Use '<cyan>so purser deal<reset>' to evaluate routes.\n")
    ]])
end

-- Recursive Pathfinder to map out required trades
function ShipsOfficer.Purser.findRoutes(item, qty, visited)
    visited = visited or {}
    local routes = {}

    -- Base Case: Is it a purchasable commodity?
    if ShipsOfficer.Purser.bases[item] then
        local port = ShipsOfficer.Purser.bases[item]
        table.insert(routes, {
            cost = qty * 1000,
            steps = { {action="Buy", qty=qty, item=item, port=port, fee=ShipsOfficer.Purser.fees[port]} }
        })
    end

    -- Recursive Case: Search the trade networks
    for _, trade in ipairs(ShipsOfficer.Purser.trades) do
        if trade.out_item == item and not visited[trade.in_item] then
            local multiplier = math.ceil(qty / trade.out_qty)
            local req_in_qty = multiplier * trade.in_qty
            local actual_yield = multiplier * trade.out_qty

            local new_visited = {}
            for k,v in pairs(visited) do new_visited[k] = v end
            new_visited[trade.in_item] = true

            local sub_routes = ShipsOfficer.Purser.findRoutes(trade.in_item, req_in_qty, new_visited)

            for _, sub in ipairs(sub_routes) do
                local new_steps = {}
                for _, step in ipairs(sub.steps) do table.insert(new_steps, step) end
                
                table.insert(new_steps, {
                    action="Trade", in_qty=req_in_qty, in_item=trade.in_item, 
                    out_qty=actual_yield, out_item=trade.out_item, 
                    port=trade.port, fee=ShipsOfficer.Purser.fees[trade.port]
                })
                table.insert(routes, { cost = sub.cost, steps = new_steps })
            end
        end
    end
    return routes
end

-- Evaluate generic cargo route without an active deal
function ShipsOfficer.Purser.evaluateRoute(qty, item, show_all, sort_by)
    cecho(string.format("\n<blue>[Ship's Officer]:<reset> Evaluating routes for <white>%d %s<reset>\n\n", qty, item:title()))

    local routes = ShipsOfficer.Purser.findRoutes(item, qty)

    if #routes == 0 then
        cecho("<firebrick>  Unable to find a valid trading route for this cargo.<reset>\n")
        return
    end

    -- Pre-calculate totals for sorting
    for _, route in ipairs(routes) do
        local total_fees = 0
        local last_port = ""
        for _, step in ipairs(route.steps) do
            if step.port ~= last_port then
                total_fees = total_fees + step.fee
                last_port = step.port
            end
        end
        route.total_cost = route.cost + total_fees
        route.step_count = #route.steps
    end

    -- Apply sorting
    table.sort(routes, function(a, b)
        if sort_by == "cost" then
            if a.total_cost == b.total_cost then return a.step_count < b.step_count end
            return a.total_cost < b.total_cost
        else
            if a.step_count == b.step_count then return a.total_cost < b.total_cost end
            return a.step_count < b.step_count
        end
    end)

    -- Display truncated or full list
    local max_routes = show_all and #routes or math.min(#routes, 2)

    for i = 1, max_routes do
        local route = routes[i]
        local last_port = ""
        
        cecho(string.format("<SeaGreen>Route %d:<reset>\n", i))
        for _, step in ipairs(route.steps) do
            local fee_str = ""
            if step.port ~= last_port then
                fee_str = string.format("Fee: %sgp", ShipsOfficer.formatNumber(step.fee))
                last_port = step.port
            else
                fee_str = "Fee: Paid"
            end

            if step.action == "Buy" then
                cecho(string.format("  * Buy <white>%d %s<reset> @ <cyan>%s<reset> (Cost: <gold>%sgp<reset>, %s)\n", 
                    step.qty, step.item:title(), step.port, ShipsOfficer.formatNumber(step.qty * 1000), fee_str))
            else
                cecho(string.format("  * Trade <white>%d %s<reset> -> <white>%d %s<reset> @ <cyan>%s<reset> (%s)\n", 
                    step.in_qty, step.in_item:title(), step.out_qty, step.out_item:title(), step.port, fee_str))
            end
        end

        cecho(string.format("  <light_grey>Total Route Cost: <gold>%sgp<reset>\n\n", ShipsOfficer.formatNumber(route.total_cost)))
    end

    if #routes > max_routes then
        cecho(string.format("<light_grey>  ... and %d other routes. Use 'so purser route %d %s all' to view them.<reset>\n\n", #routes - max_routes, qty, item))
    end
end

-- Evaluate and display the currently stored deal
function ShipsOfficer.Purser.evaluateDeal(show_all, sort_by)
    local deal = ShipsOfficer.Purser.currentDeal
    if not deal then
        cecho("\n<firebrick>[Ship's Officer]:<reset> No active trade deal logged. Dock at a harbour and look at HARBOUR INFO first.\n")
        return
    end

    cecho(string.format("\n<blue>[Ship's Officer]:<reset> Evaluating routes for <white>%d %s<reset>\n", deal.qty, deal.item:title()))
    cecho(string.format("  Destination: <cyan>%s<reset> (Reward: <gold>%s<reset>)\n\n", deal.destination, deal.rewardStr))

    local routes = ShipsOfficer.Purser.findRoutes(deal.item, deal.qty)

    if #routes == 0 then
        cecho("<firebrick>  Unable to find a valid trading route for this cargo.<reset>\n")
        return
    end

    -- Pre-calculate totals for sorting
    for _, route in ipairs(routes) do
        local total_fees = 0
        local last_port = ""
        for _, step in ipairs(route.steps) do
            if step.port ~= last_port then
                total_fees = total_fees + step.fee
                last_port = step.port
            end
        end
        local turn_in_fee = ShipsOfficer.Purser.fees[deal.destination] or 0
        if deal.destination ~= last_port then
            total_fees = total_fees + turn_in_fee
        end

        route.total_cost = route.cost + total_fees
        route.step_count = #route.steps
    end

    -- Apply sorting
    table.sort(routes, function(a, b)
        if sort_by == "cost" then
            if a.total_cost == b.total_cost then return a.step_count < b.step_count end
            return a.total_cost < b.total_cost
        else
            if a.step_count == b.step_count then return a.total_cost < b.total_cost end
            return a.step_count < b.step_count
        end
    end)

    -- Display truncated or full list
    local max_routes = show_all and #routes or math.min(#routes, 2)

    for i = 1, max_routes do
        local route = routes[i]
        local last_port = ""
        
        cecho(string.format("<SeaGreen>Route %d:<reset>\n", i))
        for _, step in ipairs(route.steps) do
            local fee_str = ""
            if step.port ~= last_port then
                fee_str = string.format("Fee: %sgp", ShipsOfficer.formatNumber(step.fee))
                last_port = step.port
            else
                fee_str = "Fee: Paid"
            end

            if step.action == "Buy" then
                cecho(string.format("  * Buy <white>%d %s<reset> @ <cyan>%s<reset> (Cost: <gold>%sgp<reset>, %s)\n", 
                    step.qty, step.item:title(), step.port, ShipsOfficer.formatNumber(step.qty * 1000), fee_str))
            else
                cecho(string.format("  * Trade <white>%d %s<reset> -> <white>%d %s<reset> @ <cyan>%s<reset> (%s)\n", 
                    step.in_qty, step.in_item:title(), step.out_qty, step.out_item:title(), step.port, fee_str))
            end
        end

        -- Add Turn-in Fee
        local turn_in_fee = ShipsOfficer.Purser.fees[deal.destination] or 0
        cecho(string.format("  * Deliver @ <cyan>%s<reset> (Fee: %sgp)\n", deal.destination, ShipsOfficer.formatNumber(turn_in_fee)))
        
        local profitStr = ""
        if deal.rewardGold > 0 then
            local profit = deal.rewardGold - route.total_cost
            profitStr = string.format(" | <light_grey>Estimated Profit: <green>%sgp<reset>", ShipsOfficer.formatNumber(profit))
        else
            profitStr = string.format(" | <light_grey>Reward: <green>%s<reset>", deal.rewardStr)
        end

        cecho(string.format("  <light_grey>Total Costs: <gold>%sgp<reset>%s\n\n", ShipsOfficer.formatNumber(route.total_cost), profitStr))
    end

    if #routes > max_routes then
        cecho(string.format("<light_grey>  ... and %d other routes. Use 'so purser deal all' to view them.<reset>\n\n", #routes - max_routes))
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
    cecho("  <cyan>so map <location><reset> - Pans the map GUI to the specified location.\n")
    cecho("  <cyan>so map [show|hide]<reset> - Toggles the visibility of the map.\n\n")

    cecho("<yellow>--- MODULE: Purser (Trade Deals) ---\n<reset>")
    cecho("  <cyan>so purser deal [all] [cost]<reset> - Evaluates trading routes for active deal. Defaults to showing top 2 shortest routes.\n")
    cecho("  <cyan>so purser route <amount> <commodity> [all] [cost]<reset> - Evaluates trading routes for specific cargo.\n\n")

    cecho("<yellow>--- MODULE: Shipfitter (Crafting & Cost Estimation) ---\n<reset>")
    cecho("  <cyan>so shipfit calc <amount> <commodity><reset> - Instantly calculates base materials for a single ship commodity.\n")
    cecho("  <cyan>so shipfit equip<reset> - Lists all available ship equipment you can add to your list.\n")
    cecho("  <cyan>so shipfit equip <amount> <equipment><reset> - Adds the required materials for ship equipment to your list.\n")
    cecho("  <cyan>so shipfit add <amount> <commodity><reset> - Adds raw materials or ship commodities directly to your list.\n")
    cecho("  <cyan>so shipfit list<reset> - Displays your current queued list and the base commodities needed.\n")
    cecho("  <cyan>so shipfit cost [avg | now]<reset> - Estimates gold cost based on historical averages (avg) or live market scraping (now).\n")
    cecho("  <cyan>so shipfit clear<reset> - Empties your current shopping list.\n\n")
    
    cecho("\n<SeaGreen>=================================================================<reset>\n")
end

-- Kill old master alias if it exists
if ShipsOfficer.masterAlias then killAlias(ShipsOfficer.masterAlias) end

-- Create the Unified Master Alias
ShipsOfficer.masterAlias = tempAlias("^so(?:\\s+(.*))?$", [[
    local input = matches[2] or ""
    if input == "" or input:lower() == "help" then ShipsOfficer.showHelp(); return end

    local function syntaxError()
        cecho(string.format("\n<firebrick>[Ship's Officer]:<reset> Invalid command or syntax: 'so %s'\n", input))
        cecho("<SeaGreen>[Ship's Officer]:<reset> Showing help menu...\n"); ShipsOfficer.showHelp()
    end

    local module, rest = input:match("^(%a+)%s*(.*)$")
    module = module and module:lower() or ""

    if module == "map" then
        if rest == "hide" then ShipsOfficer.Navigator.container:hide(); cecho("\n<blue>[Ship's Officer]:<reset> Map interface hidden.\n")
        elseif rest == "show" then ShipsOfficer.Navigator.container:show(); cecho("\n<blue>[Ship's Officer]:<reset> Map interface shown.\n")
        elseif rest ~= "" then ShipsOfficer.Navigator:lookAt(rest)
        else syntaxError() end

    elseif module == "purser" then
        local cmd, args = rest:match("^(%a+)%s*(.*)$")
        cmd = cmd and cmd:lower() or ""

        if cmd == "deal" then 
            local show_all = args:lower():find("all") ~= nil
            local sort_by = args:lower():find("cost") and "cost" or "steps"
            ShipsOfficer.Purser.evaluateDeal(show_all, sort_by) 
        elseif cmd == "route" then
            local amt, comm = args:match("^(%d+)%s+(%a+)")
            if amt and comm then 
                local show_all = args:lower():find("all") ~= nil
                local sort_by = args:lower():find("cost") and "cost" or "steps"
                ShipsOfficer.Purser.evaluateRoute(tonumber(amt), comm:lower(), show_all, sort_by) 
            else syntaxError() end
        else 
            syntaxError() 
        end

    elseif module == "shipfit" then
        local cmd, args = rest:match("^(%a+)%s*(.*)$")
        cmd = cmd and cmd:lower() or ""

        if cmd == "calc" then
            local amt, comm = args:match("^(%d+)%s+(%a+)$")
            if amt and comm then ShipsOfficer.shipfit.calculateSingle(amt, comm) else syntaxError() end
        elseif cmd == "add" then
            local amt, comm = args:match("^(%d+)%s+(%a+)$")
            if amt and comm then ShipsOfficer.shipfit.addToList(amt, comm) else syntaxError() end
        elseif cmd == "equip" then
            if args == "" then ShipsOfficer.shipfit.listEquipment()
            else
                local amt, equip = args:match("^(%d+)%s+(.+)$")
                if amt and equip then ShipsOfficer.shipfit.addEquipToList(amt, equip) else syntaxError() end
            end
        elseif cmd == "list" and args == "" then ShipsOfficer.shipfit.calculateList()
        elseif cmd == "cost" then
            if args == "" or args:lower() == "avg" then ShipsOfficer.shipfit.calculateCost("avg")
            elseif args:lower() == "now" then ShipsOfficer.shipfit.calculateCost("now")
            else syntaxError() end
        elseif cmd == "clear" and args == "" then ShipsOfficer.shipfit.clearList()
        else syntaxError() end

    else syntaxError() end
]])

-- =========================================================================
-- INITIALIZATION CALLS
-- =========================================================================

ShipsOfficer.shipfit.loadPrices()
ShipsOfficer.Navigator:init()
ShipsOfficer.Purser:initTriggers()