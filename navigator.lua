-- =========================================================================
-- NAVIGATOR: Command-Driven Pan & Zoom Map Display for Sailing/Wilderness
-- =========================================================================
Navigator = Navigator or {}

-- CONFIGURATION
Navigator.imagePath = getMudletHomeDir() .. "/Sea_Wilderness_Map_2020.png" -- Change to your map!
Navigator.currentZoom = 100 -- Percentage
Navigator.currentX = 50     -- Percentage (50 is center)
Navigator.currentY = 50     -- Percentage (50 is center)

-- 1. Initialize the UI
function Navigator:init()
    -- Create a container to hold the map (Bottom Right corner example)
    self.container = Geyser.Container:new({
        name = "NavigatorContainer",
        x = "-400px", y = "-400px", -- Anchored 400px from right and bottom
        width = "400px", height = "400px",
    })

    -- Create the label inside the container
    self.label = Geyser.Label:new({
        name = "NavigatorLabel",
        x = 0, y = 0,
        width = "100%", height = "100%",
    }, self.container)

    -- Render the initial view
    self:updateView()
    cecho("\n<blue>[Navigator]:<reset> Nautical map UI Initialized.\n")
end

-- 2. Update the CSS to render the new Zoom/Pan coordinates
function Navigator:updateView()
    -- Qt CSS requires forward slashes for file paths
    local safePath = self.imagePath:gsub("\\", "/")
    
    -- Ensure the path starts with a slash for the file:/// URI scheme
    if not safePath:starts("/") then
        safePath = "/" .. safePath
    end
    
    local css = string.format([[
        background-image: url("file://%s");
        background-color: #000000;
        background-repeat: no-repeat;
        background-position: %d%% %d%%;
        background-size: %d%%;
    ]], safePath, self.currentX, self.currentY, self.currentZoom)

    self.label:setStyleSheet(css)
    
    -- Debug line to show you exactly where it is looking:
    cecho(string.format("\n<blue>[Navigator]:<reset> Attempting to load map from: <yellow>%s<reset>\n", safePath))
end

-- 3. Helper function to jump to specific named locations
function Navigator:lookAt(location)
    location = location:lower()

    if location == "world" or location == "reset" then
        self.currentZoom = 100
        self.currentX = 50
        self.currentY = 50
        
    elseif location == "northern_sea" then
        self.currentZoom = 250 -- Zoom in 2.5x
        self.currentX = 50     -- Middle horizontally
        self.currentY = 10     -- Pan to the top
        
    elseif location == "southern_archipelago" then
        self.currentZoom = 300 -- Zoom in 3x
        self.currentX = 80     -- Pan right
        self.currentY = 90     -- Pan down
        
    elseif location == "western_shallows" then
        self.currentZoom = 200
        self.currentX = 10     -- Pan left
        self.currentY = 50     -- Middle vertically
        
    else
        cecho("\n<red>[Navigator]:<reset> Unknown coordinate or region: " .. location .. "\n")
        return
    end

    self:updateView()
    cecho(string.format("\n<blue>[Navigator]:<reset> Charting view to '<white>%s<reset>'.\n", location))
end

-- =========================================================================
-- ALIAS CREATION
-- =========================================================================

-- Kill the old alias if we are reloading/saving the script so they don't duplicate
if Navigator.aliasID then
    killAlias(Navigator.aliasID)
end

-- Create the new alias and store its ID
Navigator.aliasID = tempAlias("^navmap (.*)$", [[
    Navigator:lookAt(matches[2])
]])

-- Initialize the UI when the script compiles
Navigator:init()
