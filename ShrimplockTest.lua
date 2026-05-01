--[[
    BRM5 WARZONE v2.2.2 - Advanced DX9WARE Combat Script
    Made by Lorthanyx - Zero external dependencies

    Features:
      - Player & NPC ESP + Aimbot (erweitert, 10 Aim Parts)
      - Vehicle ESP (FMTV, M998, BTR70, T72A, BMP2, TigrSpn, ...)
      - Ammo/Loot ESP (Ammo762, Ammo50, AmmoCrate, AmmoLong, ...)
      - Spawner ESP (Spawn-Posts, Vendor, Company, FOB)
      - Erweiterte Visuals & Crosshair
      - Professionelle Startup-Animation
      - Vollstaendiges UI mit 5 Tabs

    DX9WARE Lua 5.1.4 | dx9 library
--]]

-- ============================================================
-- KONFIGURATION
-- ============================================================
local CFG = {
    VERSION         = "0.0.1",
    SCRIPT_NAME     = "Shrimplock Universal",
    TOGGLE_KEY      = "[F6]",
    NO_HOTKEY       = "[NONE]",
    CANCEL_KEY      = "[ESC]",
    LOCAL_PLAYER_HINT = nil,

    -- GUI Layout
    GUI_X           = 200,
    GUI_Y           = 100,
    GUI_W           = 520,
    GUI_H           = 440,
    ROW_H           = 18,
    PAD             = 8,
    HEADER_H        = 28,
    TAB_H           = 22,

    -- Colors
    C_BG            = {12, 12, 16},
    C_PANEL         = {22, 22, 28},
    C_SURF          = {32, 32, 40},
    C_BRD           = {48, 48, 58},
    C_TXT           = {220, 220, 230},
    C_DIM           = {120, 120, 140},
    C_ACC           = {255, 60, 60},
    C_ACC_D         = {180, 40, 40},
    C_SUCCESS       = {0, 200, 100},
    C_WARN          = {255, 180, 0},
    C_DANGER        = {255, 50, 50},
    C_VEHICLE       = {0, 180, 255},
    C_AMMO          = {255, 200, 0},
    C_SPAWNER       = {180, 0, 255},

    -- Performance
    LOC_CACHE_SEC       = 15.0,
    ENTITY_CACHE_SEC    = 4.0,
    LOCAL_CACHE_SEC     = 1.0,
    VEHICLE_CACHE_SEC   = 5.0,
    ITEM_CACHE_SEC      = 8.0,
    SPAWNER_CACHE_SEC   = 10.0,
    SELF_EXCLUDE_DIST   = 4.0,
    PERF_LOG_MS         = 5.0,
    PERF_LOG_SEC        = 0.75,
    SLOW_FRAME_MS       = 16.0,

    -- Skeleton (R15)
    SKELETON = {
        {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
        {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"},
        {"RightLowerArm","RightHand"}, {"UpperTorso","LeftUpperArm"},
        {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
        {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"},
        {"RightLowerLeg","RightFoot"}, {"LowerTorso","LeftUpperLeg"},
        {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    },

    PALETTE = {
        {255,50,50}, {255,100,50}, {255,160,0}, {255,220,0},
        {180,255,0}, {0,220,100}, {0,255,200}, {0,200,255},
        {0,130,255}, {80,80,255}, {160,50,255}, {255,50,200},
        {255,255,255}, {200,200,210}, {130,130,145}, {60,60,70},
    },

    TABS = {"Players"},

    AIM_PARTS   = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "RightUpperArm",
        "LeftHand", "RightHand",
        "LeftUpperLeg", "RightUpperLeg",
        "LeftFoot", "RightFoot",
    },
    AIM_MODES   = {"First Person", "Third Person"},
    CROSS_STYLES = {"Cross", "Dot", "Circle", "Cross+Circle"},

    ACCENTS = {
        {255,60,60}, {0,150,255}, {0,200,120}, {255,160,0},
        {180,50,255}, {255,50,200}, {0,220,220}, {255,220,0},
    },

    -- Known vehicles from ExplorerData
    VEHICLE_NAMES = {
        "FMTV", "M998", "BTR70_1", "T72A_Full2", "BMP2_Body1",
        "BMP2_Turret1", "TigrSpn",
        "Cart_Mechanic_1_2", "Cart_Mechanic_2_Simple", "Cart_Mechanic_3",
    },

    VEHICLE_DISPLAY = {
        FMTV = "FMTV Truck",
        M998 = "M998 Humvee",
        BTR70_1 = "BTR-70 APC",
        T72A_Full2 = "T-72A Tank",
        BMP2_Body1 = "BMP-2 IFV",
        BMP2_Turret1 = "BMP-2 Turret",
        TigrSpn = "Tigr SPM",
        Cart_Mechanic_1_2 = "Mech Cart 1",
        Cart_Mechanic_2_Simple = "Mech Cart 2",
        Cart_Mechanic_3 = "Mech Cart 3",
    },

    -- Known ammo/loot item names from ExplorerData
    ITEM_NAMES = {
        "Ammo762", "Ammo50", "AmmoCrate", "AmmoCrates", "AmmoLong",
        "Ammo", "wep_cabinet_1", "wep_cabinet_2", "wep_cabinet_3", "wep_cabinet_4",
    },

    ITEM_DISPLAY = {
        Ammo762 = "7.62mm Ammo",
        Ammo50 = ".50 Cal Ammo",
        AmmoCrate = "Ammo Crate",
        AmmoCrates = "Ammo Crates",
        AmmoLong = "Long Ammo Box",
        Ammo = "Ammo Box",
        wep_cabinet_1 = "Weapon Cab 1",
        wep_cabinet_2 = "Weapon Cab 2",
        wep_cabinet_3 = "Weapon Cab 3",
        wep_cabinet_4 = "Weapon Cab 4",
    },
}

-- ============================================================
-- PERSISTENTER STATE in _G
-- ============================================================
if not _G.WARZONE then
    _G.WARZONE = {
        -- GUI
        guiOn       = true,
        guiX        = CFG.GUI_X,
        guiY        = CFG.GUI_Y,
        tab         = 1,
        drag        = false,
        dragOX      = 0,
        dragOY      = 0,
        slider      = nil,
        ddOpen      = nil,
        bindTarget  = false,
        bindArmed   = false,
        bindSeedKey = "",
        keyHeld     = false,
        scrollY     = {},

        -- Theme
        dark        = true,
        accC        = {255, 60, 60},
        accD        = {180, 40, 40},

        -- Player ESP
        pEsp = false, pBox = false, pBoxC = {0,180,255},
        pName = false, pNameC = {220,220,230},
        pDot = false, pDotC = {255,50,80}, pDotR = 3,
        pDist = false, pDistC = {180,180,190},
        pTrace = false, pTraceC = {0,180,255},
        pSkel = false, pSkelC = {200,200,220},
        pHealth = false, pHealthC = {0,255,100},
        pSnapLine = false, pSnapC = {255,255,0},

        -- NPC ESP
        nEsp = false, nBox = false, nBoxC = {255,160,0},
        nName = false, nNameC = {220,220,230},
        nDot = false, nDotC = {255,200,0}, nDotR = 3,
        nDist = false, nDistC = {180,180,190},
        nTrace = false, nTraceC = {255,160,0},
        nSkel = false, nSkelC = {255,200,150},
        nHealth = false, nHealthC = {0,255,100},

        -- Player Aimbot
        pAim = false, pAimPart = 1, pSmooth = 1.5, pSens = 2.0,
        pFov = 350, pShowFov = false, pFovC = {255,255,255}, pAimMode = 1,
        pRecoil = false, pRecoilPower = 4.0, pRecoilKey = CFG.NO_HOTKEY,
        pRecoilHotkeyOn = false, pRecoilHotkeyHeld = false, pRecoilHotkeySeen = 0,

        -- NPC Aimbot
        nAim = false, nAimPart = 1, nSmooth = 1.5, nSens = 2.0,
        nFov = 400, nShowFov = false, nFovC = {255,200,0}, nAimMode = 1,

        -- Vehicle ESP
        vEsp = false, vBox = false, vBoxC = {0,180,255},
        vName = false, vNameC = {0,200,255},
        vDist = false, vDistC = {0,160,220},
        vTrace = false, vTraceC = {0,140,200},

        -- Ammo/Item ESP
        iEsp = false, iBox = false, iBoxC = {255,200,0},
        iName = false, iNameC = {255,220,100},
        iDist = false, iDistC = {200,180,100},
        iTrace = false, iTraceC = {255,200,0},
        iMaxDist = 500,

        -- Spawner ESP
        sEsp = false, sBox = false, sBoxC = {180,0,255},
        sName = false, sNameC = {200,150,255},
        sDist = false, sDistC = {160,130,200},
        sTrace = false, sTraceC = {180,0,255},

        -- Crosshair
        cross = false, crossStyle = 1, crossC = {0,255,100},
        crossSz = 8, crossGap = 3, crossDot = true,

        -- Overlays
        wmark = true, fpsCtr = false, snap = false, snapC = {255,255,0},
        showConsole = false,
        debug = false,
        statTracker = false,

        -- Cache
        loc         = "comp",
        locTime     = 0,
        entities    = {},
        entityByModel = {},
        entityCacheTime = 0,
        entityCacheWs = 0,
        entityCacheMode = "",
        localName    = nil,
        localPos     = nil,
        localInfoTime = 0,
        camPos      = nil,
        fps         = 0,
        fpsFrames   = 0,
        fpsTime     = 0,
        lastShowConsole = nil,

        -- Vehicle cache
        vehicles        = {},
        vehicleCacheTime = 0,

        -- Item cache
        items           = {},
        itemCacheTime   = 0,

        -- Spawner cache
        spawners        = {},
        spawnerCacheTime = 0,

        -- Aim runtime
        aimX        = nil,
        aimY        = nil,
        aimCallX    = nil,
        aimCallY    = nil,
        aimDist     = 1e9,
        aimType     = nil,
        recoilNext  = 0,

        -- Notifications
        notifs      = {},

        -- Session
        sessionStart = 0,

        -- Debug
        debugTimes  = {},
        perfLast    = {},
        lastSlowLog = 0,
        frameCount  = 0,
        foundBillboard = false,

        -- Startup Animation
        introStart  = 0,
        introPhase  = 0,
        introDone   = false,
        introParticles = nil,

        -- Init
        initialized = false,
        version     = CFG.VERSION,
    }
    dx9.ShowConsole(false)
    print("[WARZONE] v" .. CFG.VERSION .. " wird geladen...")
end

local S = _G.WARZONE
local prevVersion = S.version

-- Ensure new state keys exist for upgrades
local function ensureState(key, value)
    if S[key] == nil then
        S[key] = value
    end
end

ensureState("entities", {})
ensureState("entityByModel", {})
ensureState("entityCacheTime", 0)
ensureState("entityCacheWs", 0)
ensureState("entityCacheMode", "")
ensureState("localName", nil)
ensureState("localPos", nil)
ensureState("localInfoTime", 0)
ensureState("aimCallX", nil)
ensureState("aimCallY", nil)
ensureState("bindTarget", false)
ensureState("bindArmed", false)
ensureState("bindSeedKey", "")
ensureState("pRecoil", false)
ensureState("pRecoilPower", 4.0)
ensureState("pRecoilKey", CFG.NO_HOTKEY)
ensureState("pRecoilHotkeyOn", false)
ensureState("pRecoilHotkeyHeld", false)
ensureState("pRecoilHotkeySeen", 0)
ensureState("recoilNext", 0)
ensureState("debugTimes", {})
ensureState("perfLast", {})
ensureState("lastSlowLog", 0)
ensureState("lastShowConsole", nil)
ensureState("vehicles", {})
ensureState("vehicleCacheTime", 0)
ensureState("items", {})
ensureState("itemCacheTime", 0)
ensureState("spawners", {})
ensureState("spawnerCacheTime", 0)
ensureState("scrollY", {})
ensureState("pHealth", false)
ensureState("pHealthC", {0,255,100})
ensureState("nHealth", false)
ensureState("nHealthC", {0,255,100})
ensureState("pSnapLine", false)
ensureState("pSnapC", {255,255,0})
ensureState("vEsp", false)
ensureState("vBox", false)
ensureState("vBoxC", {0,180,255})
ensureState("vName", false)
ensureState("vNameC", {0,200,255})
ensureState("vDist", false)
ensureState("vDistC", {0,160,220})
ensureState("vTrace", false)
ensureState("vTraceC", {0,140,200})
ensureState("iEsp", false)
ensureState("iBox", false)
ensureState("iBoxC", {255,200,0})
ensureState("iName", false)
ensureState("iNameC", {255,220,100})
ensureState("iDist", false)
ensureState("iDistC", {200,180,100})
ensureState("iTrace", false)
ensureState("iTraceC", {255,200,0})
ensureState("iMaxDist", 500)
ensureState("sEsp", false)
ensureState("sBox", false)
ensureState("sBoxC", {180,0,255})
ensureState("sName", false)
ensureState("sNameC", {200,150,255})
ensureState("sDist", false)
ensureState("sDistC", {160,130,200})
ensureState("sTrace", false)
ensureState("sTraceC", {180,0,255})
ensureState("statTracker", false)
ensureState("introStart", 0)
ensureState("introPhase", 0)
ensureState("introDone", false)
ensureState("introParticles", nil)
ensureState("sessionStart", 0)

if prevVersion ~= CFG.VERSION then
    S.version = CFG.VERSION
    S.debug = false
    S.showConsole = false
    S.debugTimes = {}
    S.perfLast = {}
    S.entities = {}
    S.entityByModel = {}
    S.entityCacheTime = 0
    S.entityCacheWs = 0
    S.entityCacheMode = ""
    S.localName = nil
    S.localPos = nil
    S.localInfoTime = 0
    S.lastShowConsole = nil
    S.bindTarget = false
    S.bindArmed = false
    S.bindSeedKey = ""
    S.pRecoilHotkeyOn = false
    S.pRecoilHotkeyHeld = false
    S.pRecoilHotkeySeen = 0
    S.vehicles = {}
    S.vehicleCacheTime = 0
    S.items = {}
    S.itemCacheTime = 0
    S.spawners = {}
    S.spawnerCacheTime = 0
    S.initialized = false
    S.introDone = false
    S.introStart = 0
    S.introParticles = nil
end

if S.sessionStart == 0 then
    S.sessionStart = os.clock()
end

-- ============================================================
-- HILFSFUNKTIONEN
-- ============================================================
local floor = math.floor
local sqrt  = math.sqrt
local abs   = math.abs
local huge  = math.huge
local sin   = math.sin
local cos   = math.cos
local pi    = math.pi
local min   = math.min
local max   = math.max

local function getTime()
    return os.clock() * 1000
end

local function clamp(val, lo, hi)
    if val < lo then return lo end
    if val > hi then return hi end
    return val
end

local function round(v, d)
    local m = 10 ^ (d or 0)
    return floor(v * m + 0.5) / m
end

local function inRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

local function dist3d(a, b)
    if not a or not b then return huge end
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return sqrt(dx * dx + dy * dy + dz * dz)
end

local function lerpColor(c1, c2, t)
    t = clamp(t, 0, 1)
    return {
        floor(c1[1] + (c2[1] - c1[1]) * t),
        floor(c1[2] + (c2[2] - c1[2]) * t),
        floor(c1[3] + (c2[3] - c1[3]) * t),
    }
end

local function scaleColor(col, scale)
    scale = clamp(scale, 0, 1)
    return {
        floor(col[1] * scale),
        floor(col[2] * scale),
        floor(col[3] * scale),
    }
end

local function withAlpha(col, alpha)
    return {
        col[1],
        col[2],
        col[3],
        floor(clamp(alpha, 0, 255)),
    }
end

local function easeInOut01(t)
    t = clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

local function normalizeKeyName(key)
    if key == nil or key == false or key == 0 then
        return ""
    end
    if type(key) ~= "string" then
        return tostring(key)
    end
    return key
end

local function formatTime(seconds)
    local m = floor(seconds / 60)
    local s = floor(seconds % 60)
    if m > 0 then return m .. "m " .. s .. "s" end
    return s .. "s"
end

local function drawShadowedString(pos, col, text, shadowCol)
    local sc = shadowCol or {0, 0, 0}
    dx9.DrawString({pos[1] + 1, pos[2] + 1}, sc, text)
    dx9.DrawString(pos, col, text)
end

local function timerStart(name)
    if S.debug then S.debugTimes[name] = getTime() end
end

local function timerEnd(name)
    if S.debug and S.debugTimes[name] then
        local elapsed = getTime() - S.debugTimes[name]
        if elapsed > CFG.PERF_LOG_MS then
            local now = os.clock()
            local last = S.perfLast[name] or 0
            if now - last >= CFG.PERF_LOG_SEC then
                S.perfLast[name] = now
                print("[PERF] " .. name .. ": " .. string.format("%.2f", elapsed) .. "ms")
            end
        end
        S.debugTimes[name] = nil
        return elapsed
    end
    return 0
end

-- ============================================================
-- SAFE HELPERS
-- ============================================================
local function getChildrenSafe(obj)
    if not obj or obj == 0 then return {} end
    local ok, children = pcall(dx9.GetChildren, obj)
    if ok and children then return children end
    return {}
end

local function findChild(parent, name)
    if not parent or parent == 0 then return nil end
    local result = dx9.FindFirstChild(parent, name)
    if result and result ~= 0 then return result end
    return nil
end

local function getPos(obj)
    if not obj or obj == 0 then return nil end
    local ok, pos = pcall(dx9.GetPosition, obj)
    if ok and pos and pos.x then return pos end
    return nil
end

local function getStringProperty(obj, prop)
    if not obj or obj == 0 then return nil end
    local ok, value = pcall(function()
        return dx9.GetProperty(obj, prop)
    end)
    if ok and type(value) == "string" then
        return value
    end
    return nil
end

local function getLocalPlayerApiInfo()
    if not dx9.get_localplayer then return nil end
    local ok, info = pcall(dx9.get_localplayer)
    if ok and type(info) == "table" then
        return info
    end
    return nil
end

-- ============================================================
-- GUI STATE
-- ============================================================
local consumed = false
local lyX, lyY, lyW = 0, 0, 0

local function consume()
    consumed = true
end

-- ============================================================
-- THEME
-- ============================================================
local function getTheme()
    if S.dark then
        return {
            bg = CFG.C_BG, panel = CFG.C_PANEL, surf = CFG.C_SURF,
            brd = CFG.C_BRD, txt = CFG.C_TXT, dim = CFG.C_DIM,
            acc = S.accC, accD = S.accD,
            success = CFG.C_SUCCESS, warn = CFG.C_WARN, danger = CFG.C_DANGER,
        }
    else
        return {
            bg = {210,210,220}, panel = {190,190,200}, surf = {175,175,185},
            brd = {140,140,155}, txt = {30,30,40}, dim = {80,80,95},
            acc = S.accC, accD = S.accD,
            success = CFG.C_SUCCESS, warn = CFG.C_WARN, danger = CFG.C_DANGER,
        }
    end
end

-- ============================================================
-- LOCAL PLAYER INFO
-- ============================================================
local function isLocalPlayerNode(player)
    if not player or player == 0 then return false end
    return findChild(player, "PlayerGui") ~= nil or findChild(player, "PlayerScripts") ~= nil
end

local function captureLocalPlayerFromPlayer(player)
    if not player or player == 0 then return false end

    local wm = findChild(player, "WorldModel")
    if not wm then return false end

    local male = findChild(wm, "Male")
    if not male then return false end

    local root = findChild(male, "Root")
    local lowerTorso = findChild(male, "LowerTorso")
    local torso = findChild(male, "UpperTorso")
    local head = findChild(male, "Head")
    local pos = getPos(root) or getPos(lowerTorso) or getPos(torso) or getPos(head)

    S.localName = dx9.GetName(player)
    if pos then
        S.localPos = pos
    end
    return true
end

local function captureLocalPlayerInfo(pls)
    if not pls then return false end

    if S.localName then
        local player = findChild(pls, S.localName)
        if player and captureLocalPlayerFromPlayer(player) then
            return true
        end
    end

    for _, player in ipairs(getChildrenSafe(pls)) do
        if isLocalPlayerNode(player) and captureLocalPlayerFromPlayer(player) then
            return true
        end
    end

    if S.localName then
        for _, player in ipairs(getChildrenSafe(pls)) do
            if dx9.GetName(player) == S.localName and captureLocalPlayerFromPlayer(player) then
                return true
            end
        end
    end

    return false
end

local function refreshLocalPlayerInfo(now, pls)
    if pls and S.localName then
        local knownPlayer = findChild(pls, S.localName)
        if knownPlayer and isLocalPlayerNode(knownPlayer) and captureLocalPlayerFromPlayer(knownPlayer) then
            S.localInfoTime = now
            return
        end
    end

    local preferredName = CFG.LOCAL_PLAYER_HINT
    if preferredName and pls then
        local preferredPlayer = findChild(pls, preferredName)
        if preferredPlayer and isLocalPlayerNode(preferredPlayer) and captureLocalPlayerFromPlayer(preferredPlayer) then
            S.localName = preferredName
            S.localInfoTime = now
            return
        end
    end

    if pls then
        for _, player in ipairs(getChildrenSafe(pls)) do
            if isLocalPlayerNode(player) and captureLocalPlayerFromPlayer(player) then
                S.localInfoTime = now
                return
            end
        end
    end

    local lpInfo = getLocalPlayerApiInfo()
    if lpInfo then
        if lpInfo.Info and lpInfo.Info.name then
            S.localName = lpInfo.Info.name
        end
        if lpInfo.Position and lpInfo.Position.x and lpInfo.Position.y and lpInfo.Position.z then
            S.localPos = lpInfo.Position
            S.localInfoTime = now
            return
        end
    end

    if now - (S.localInfoTime or 0) < CFG.LOCAL_CACHE_SEC then return end

    if pls and captureLocalPlayerInfo(pls) then
        S.localInfoTime = now
        return
    end

    local ok, game = pcall(dx9.GetDatamodel)
    if ok and game then
        local players = findChild(game, "Players")
        if captureLocalPlayerInfo(players) then
            S.localInfoTime = now
            return
        end
    end

    S.localInfoTime = now
end

local function isSelfPosition(pos)
    local lp = S.localPos
    if not lp or not pos then return false end
    local dx = lp.x - pos.x
    local dy = lp.y - pos.y
    local dz = lp.z - pos.z
    return (dx * dx + dy * dy + dz * dz) <= (CFG.SELF_EXCLUDE_DIST * CFG.SELF_EXCLUDE_DIST)
end

local function getDistanceOrigin()
    return S.localPos
end

-- ============================================================
-- LOCATION DETECTION
-- ============================================================
local function detectLocation()
    local now = os.clock()
    if now - S.locTime < CFG.LOC_CACHE_SEC then return S.loc end
    S.locTime = now

    if S.foundBillboard then
        S.loc = "ronograd"
        return S.loc
    end

    local ok, game = pcall(dx9.GetDatamodel)
    if ok and game then
        local ws = findChild(game, "Workspace")
        local pls = findChild(game, "Players")

        if ws then
            for _, c in ipairs(getChildrenSafe(ws)) do
                local name = dx9.GetName(c)
                if name == "Male" and findChild(c, "BillboardGui") then
                    S.loc = "ronograd"
                    return S.loc
                elseif name == "Model" then
                    for _, m in ipairs(getChildrenSafe(c)) do
                        if dx9.GetName(m) == "Male" and findChild(m, "BillboardGui") then
                            S.loc = "ronograd"
                            return S.loc
                        end
                    end
                end
            end
        end

        if pls then
            for _, player in ipairs(getChildrenSafe(pls)) do
                local wm = findChild(player, "WorldModel")
                if wm then
                    for _, m in ipairs(getChildrenSafe(wm)) do
                        if dx9.GetName(m) == "Male" and findChild(m, "BillboardGui") then
                            S.loc = "ronograd"
                            return S.loc
                        end
                    end
                end
            end
        end

        if ws and findChild(ws, "Body") then
            S.loc = "lobby"
        else
            S.loc = "comp"
        end
    end

    return S.loc
end

-- ============================================================
-- ENTITY CACHE (Players & NPCs)
-- ============================================================
local function playerEspActive()
    return S.pEsp and (S.pBox or S.pName or S.pDot or S.pDist or S.pTrace or S.pSkel or S.pHealth or S.pSnapLine)
end

local function npcEspActive()
    return S.nEsp and (S.nBox or S.nName or S.nDot or S.nDist or S.nTrace or S.nSkel or S.nHealth)
end

local function cachePart(parts, model, name)
    local part = parts[name]
    if part == nil then
        part = dx9.FindFirstChild(model, name)
        parts[name] = part
    end
    return part
end

local function resolveEntityCorePart(parts, model)
    local root = cachePart(parts, model, "Root")
    if root and root ~= 0 then return root end

    local lowerTorso = cachePart(parts, model, "LowerTorso")
    if lowerTorso and lowerTorso ~= 0 then return lowerTorso end

    local upperTorso = cachePart(parts, model, "UpperTorso")
    if upperTorso and upperTorso ~= 0 then return upperTorso end

    local head = cachePart(parts, model, "Head")
    if head and head ~= 0 then return head end

    return nil
end

local function cleanPlayerLabel(text)
    if type(text) ~= "string" then return nil end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" or text == "NPC" or text == "Player" then return nil end
    if #text > 32 then return nil end
    if text:match("^%d+$") or text:match("^%d+[mM]$") then return nil end
    if not text:match("[%a_]") then return nil end
    return text
end

local function extractBillboardName(node, depth)
    if not node or node == 0 or depth > 6 then return nil end

    local text = cleanPlayerLabel(getStringProperty(node, "Text"))
    if text then
        return text
    end

    for _, child in ipairs(getChildrenSafe(node)) do
        local found = extractBillboardName(child, depth + 1)
        if found then
            return found
        end
    end

    return nil
end

local function resolvePlayerName(model, ownerName)
    if ownerName and ownerName ~= "" then
        return ownerName
    end

    local humanoid = findChild(model, "Humanoid")
    local displayName = cleanPlayerLabel(getStringProperty(humanoid, "DisplayName"))
    if displayName then
        return displayName
    end

    local billboard = findChild(model, "BillboardGui")
    if billboard then
        return extractBillboardName(billboard, 0)
    end

    return nil
end

local function addEntity(cache, seen, model, forcePlayer, ownerName)
    if not model or model == 0 or seen[model] or dx9.GetName(model) ~= "Male" then
        return false
    end
    seen[model] = true

    if ownerName and S.localName and ownerName == S.localName then
        return false
    end

    local old = S.entityByModel and S.entityByModel[model]
    if old then
        if old.isSelf then return false end
        local parts = old.parts or {}
        old.core = resolveEntityCorePart(parts, model)
        if old.core and old.core ~= 0 and isSelfPosition(dx9.GetPosition(old.core)) then
            old.isSelf = true
            return false
        end
        old.isP = forcePlayer or old.hasBillboard
        old.ownerName = resolvePlayerName(model, ownerName) or old.ownerName
        if (S.pEsp and S.pSkel) or (S.nEsp and S.nSkel) then
            for _, conn in ipairs(CFG.SKELETON) do
                cachePart(parts, model, conn[1])
                cachePart(parts, model, conn[2])
            end
        end
        old.parts = parts
        cache[#cache + 1] = old
        return old.hasBillboard
    end

    local parts = {}
    local head = cachePart(parts, model, "Head")
    local foot = cachePart(parts, model, "LeftFoot")
    local core = resolveEntityCorePart(parts, model)

    if not head or head == 0 or not foot or foot == 0 then
        return false
    end

    local corePos = dx9.GetPosition(core or head)
    if isSelfPosition(corePos) then return false end

    if (S.pEsp and S.pSkel) or (S.nEsp and S.nSkel) then
        for _, conn in ipairs(CFG.SKELETON) do
            cachePart(parts, model, conn[1])
            cachePart(parts, model, conn[2])
        end
    end

    local billboard = dx9.FindFirstChild(model, "BillboardGui")
    local hasBillboard = billboard ~= 0
    local isP = forcePlayer or hasBillboard
    local resolvedOwnerName = resolvePlayerName(model, ownerName)

    local humanoid = findChild(model, "Humanoid")
    local hp, maxHp = 100, 100
    if humanoid then
        local okH, hVal = pcall(function() return dx9.GetProperty(humanoid, "Health") end)
        local okM, mVal = pcall(function() return dx9.GetProperty(humanoid, "MaxHealth") end)
        if okH and hVal then hp = hVal end
        if okM and mVal then maxHp = mVal end
    end

    cache[#cache + 1] = {
        model = model,
        head = head,
        foot = foot,
        core = core,
        parts = parts,
        isP = isP,
        hasBillboard = hasBillboard,
        ownerName = resolvedOwnerName,
        isSelf = false,
        hp = hp,
        maxHp = maxHp,
    }

    return hasBillboard
end

local function scanMaleContainer(cache, seen, container, forcePlayer, scanModelChildren, ownerName)
    local foundBillboard = false
    for _, child in ipairs(getChildrenSafe(container)) do
        local name = dx9.GetName(child)
        if name == "Male" then
            if addEntity(cache, seen, child, forcePlayer, ownerName) then
                foundBillboard = true
            end
        elseif scanModelChildren and name == "Model" then
            if scanMaleContainer(cache, seen, child, forcePlayer, false, ownerName) then
                foundBillboard = true
            end
        end
    end
    return foundBillboard
end

local function refreshEntityCache(ws, pls, now, needP, needN, cacheMode)
    refreshLocalPlayerInfo(now, pls)

    local cache = {}
    local seen = {}
    local foundBillboard = false

    if needP and pls then
        for _, player in ipairs(getChildrenSafe(pls)) do
            if not isLocalPlayerNode(player) then
                local playerName = dx9.GetName(player)
                local wm = findChild(player, "WorldModel")
                if wm then
                    foundBillboard = scanMaleContainer(cache, seen, wm, true, false, playerName) or foundBillboard
                end
            end
        end
    end

    if needN or (needP and #cache == 0) then
        foundBillboard = scanMaleContainer(cache, seen, ws, false, true, nil) or foundBillboard
    end

    S.entities = cache
    local byModel = {}
    for _, entity in ipairs(cache) do
        byModel[entity.model] = entity
    end
    S.entityByModel = byModel
    S.entityCacheTime = now
    S.entityCacheWs = ws
    S.entityCacheMode = cacheMode
    S.foundBillboard = foundBillboard

    if foundBillboard then
        S.loc = "ronograd"
        S.locTime = now
    elseif S.loc == "ronograd" then
        S.locTime = 0
    end

    return cache
end

-- ============================================================
-- VEHICLE CACHE
-- ============================================================
local function refreshVehicleCache(ws, now)
    if now - (S.vehicleCacheTime or 0) < CFG.VEHICLE_CACHE_SEC then
        return S.vehicles
    end
    S.vehicleCacheTime = now

    local cache = {}
    local live = findChild(ws, "Live")
    if not live then
        S.vehicles = cache
        return cache
    end

    local unsorted = findChild(live, "Unsorted")
    if unsorted then
        local nameSet = {}
        for _, vn in ipairs(CFG.VEHICLE_NAMES) do nameSet[vn] = true end
        for _, child in ipairs(getChildrenSafe(unsorted)) do
            local cname = dx9.GetName(child)
            if nameSet[cname] then
                local main = findChild(child, "Main")
                local pos = main and getPos(main) or getPos(child)
                if pos then
                    cache[#cache + 1] = {
                        obj = child,
                        name = cname,
                        display = CFG.VEHICLE_DISPLAY[cname] or cname,
                        pos = pos,
                    }
                end
            end
        end
    end

    S.vehicles = cache
    return cache
end

-- ============================================================
-- ITEM/AMMO CACHE (FIXED: recursive + dx9.GetName)
-- ============================================================
local function scanItemsRecursive(container, nameSet, cache, depth)
    if depth > 3 then return end
    for _, child in ipairs(getChildrenSafe(container)) do
        local cname = dx9.GetName(child)
        if nameSet[cname] then
            local main = findChild(child, "Main")
            local pos = main and getPos(main) or getPos(child)
            if pos then
                cache[#cache + 1] = {
                    obj = child,
                    name = cname,
                    display = CFG.ITEM_DISPLAY[cname] or cname,
                    pos = pos,
                }
            end
        else
            -- Recurse into folders/groups
            scanItemsRecursive(child, nameSet, cache, depth + 1)
        end
    end
end

local function refreshItemCache(ws, now)
    if now - (S.itemCacheTime or 0) < CFG.ITEM_CACHE_SEC then
        return S.items
    end
    S.itemCacheTime = now

    local cache = {}
    local live = findChild(ws, "Live")
    if not live then
        S.items = cache
        return cache
    end

    local nameSet = {}
    for _, iname in ipairs(CFG.ITEM_NAMES) do nameSet[iname] = true end

    -- Scan Tech > SpawnersMisc for Ammo items
    local tech = findChild(live, "Tech")
    if tech then
        local spawnersMisc = findChild(tech, "SpawnersMisc")
        if spawnersMisc then
            scanItemsRecursive(spawnersMisc, nameSet, cache, 0)
        end
    end

    -- Scan Map > PropsNew for ammo models
    local mapFolder = findChild(live, "Map")
    if mapFolder then
        local propsNew = findChild(mapFolder, "PropsNew")
        if propsNew then
            for _, child in ipairs(getChildrenSafe(propsNew)) do
                local cname = dx9.GetName(child)
                if nameSet[cname] then
                    local main = findChild(child, "Main")
                    local pos = main and getPos(main) or getPos(child)
                    if pos then
                        cache[#cache + 1] = {
                            obj = child,
                            name = cname,
                            display = CFG.ITEM_DISPLAY[cname] or cname,
                            pos = pos,
                        }
                    end
                end
            end
        end
    end

    -- Scan Unsorted for weapon cabinets
    local unsorted = findChild(live, "Unsorted")
    if unsorted then
        for _, child in ipairs(getChildrenSafe(unsorted)) do
            local cname = dx9.GetName(child)
            if nameSet[cname] then
                local pos = getPos(child)
                if not pos then
                    local main = findChild(child, "Main")
                    if main then pos = getPos(main) end
                end
                if pos then
                    cache[#cache + 1] = {
                        obj = child,
                        name = cname,
                        display = CFG.ITEM_DISPLAY[cname] or cname,
                        pos = pos,
                    }
                end
            end
        end
    end

    S.items = cache
    return cache
end

-- ============================================================
-- SPAWNER CACHE
-- ============================================================
local function refreshSpawnerCache(ws, now)
    if now - (S.spawnerCacheTime or 0) < CFG.SPAWNER_CACHE_SEC then
        return S.spawners
    end
    S.spawnerCacheTime = now

    local cache = {}
    local live = findChild(ws, "Live")
    if not live then
        S.spawners = cache
        return cache
    end

    local tech = findChild(live, "Tech")
    if tech then
        local spawnersMisc = findChild(tech, "SpawnersMisc")
        if spawnersMisc then
            for _, child in ipairs(getChildrenSafe(spawnersMisc)) do
                local cname = dx9.GetName(child)
                if cname == "Spawner" then
                    local post = findChild(child, "Post")
                    local pos = post and getPos(post) or getPos(child)
                    if pos then
                        cache[#cache + 1] = { obj = child, name = "Spawner", display = "Vehicle Spawner", pos = pos }
                    end
                elseif cname == "Vendor" then
                    local pos = getPos(child)
                    if pos then
                        cache[#cache + 1] = { obj = child, name = "Vendor", display = "Vendor", pos = pos }
                    end
                elseif cname == "Company" then
                    local pos = getPos(child)
                    if pos then
                        cache[#cache + 1] = { obj = child, name = "Company", display = "Company HQ", pos = pos }
                    end
                end
            end

            local fobF = findChild(spawnersMisc, "fob friendlies")
            if fobF then
                for _, child in ipairs(getChildrenSafe(fobF)) do
                    local cname = dx9.GetName(child)
                    local pos = getPos(child)
                    if pos then
                        local display = cname
                        if cname == "FAI_Rifleman" then display = "FOB Rifleman"
                        elseif cname == "FAI_HQ" then display = "FOB HQ"
                        elseif cname == "HQ_Staff" then display = "HQ Staff"
                        end
                        cache[#cache + 1] = { obj = child, name = cname, display = display, pos = pos }
                    end
                end
            end
        end
    end

    S.spawners = cache
    return cache
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local function addNotif(msg, dur, col)
    S.notifs[#S.notifs + 1] = {text = msg, start = os.clock(), dur = dur or 4, col = col}
end

local function drawNotifs(T)
    local now = os.clock()
    local ny = S.wmark and 58 or 10
    local boxW = 430
    local boxH = 28
    local i = 1
    while i <= #S.notifs do
        local n = S.notifs[i]
        if now - n.start > n.dur then
            table.remove(S.notifs, i)
        else
            local accent = n.col or T.acc
            dx9.DrawFilledBox({8, ny}, {8 + boxW, ny + boxH}, T.panel)
            dx9.DrawBox({8, ny}, {8 + boxW, ny + boxH}, T.brd)
            dx9.DrawFilledBox({8, ny}, {14, ny + boxH}, accent)
            drawShadowedString({20, ny + 7}, T.txt, n.text, {4, 4, 6})
            ny = ny + boxH + 6
            i = i + 1
        end
    end
end

local function formatHotkey(bindKey)
    if not bindKey or bindKey == CFG.NO_HOTKEY then
        return "Always On"
    end
    return bindKey
end

local function handlePendingKeybind(currentKey)
    local bindTarget = S.bindTarget
    if not bindTarget then return false end

    currentKey = normalizeKeyName(currentKey)
    local seedKey = normalizeKeyName(S.bindSeedKey)

    if currentKey == "" or currentKey == seedKey then
        return true
    end

    if currentKey == CFG.CANCEL_KEY then
        S.bindTarget = false
        S.bindArmed = false
        S.bindSeedKey = ""
        addNotif("Hotkey-Bind abgebrochen", 2, CFG.C_WARN)
        return true
    end

    if currentKey == CFG.TOGGLE_KEY then
        S.bindSeedKey = currentKey
        addNotif("F6 ist fuer GUI Toggle reserviert", 2, CFG.C_WARN)
        return true
    end

    S[bindTarget] = currentKey
    S.bindTarget = false
    S.bindArmed = false
    S.bindSeedKey = ""
    S.pRecoilHotkeyOn = false
    S.pRecoilHotkeyHeld = false
    S.pRecoilHotkeySeen = 0
    addNotif("Recoil Hotkey: " .. currentKey .. " (Toggle)", 2, CFG.C_SUCCESS)
    return true
end

-- ============================================================
-- GUI CONTROLS
-- ============================================================
local function guiHeader(title, T)
    dx9.DrawFilledBox({lyX, lyY}, {lyX + lyW, lyY + 20}, T.surf)
    dx9.DrawFilledBox({lyX, lyY + 19}, {lyX + lyW, lyY + 20}, T.acc)
    dx9.DrawString({lyX + 6, lyY + 3}, T.acc, title)
    lyY = lyY + 24
end

local function guiToggle(label, key, T, mx, my, click)
    local x, y, w = lyX + 6, lyY, lyW - 12
    local val = S[key]
    dx9.DrawFilledBox({x, y + 2}, {x + 12, y + 14}, val and T.acc or T.surf)
    dx9.DrawBox({x, y + 2}, {x + 12, y + 14}, val and T.accD or T.brd)
    dx9.DrawString({x + 16, y + 2}, T.txt, label)
    if click and not consumed and inRect(mx, my, x, y, w, 18) then
        local newVal = not S[key]
        S[key] = newVal
        if newVal and key == "pEsp" and not (S.pBox or S.pName or S.pDot or S.pDist or S.pTrace or S.pSkel) then
            S.pBox = true
            S.pName = true
        elseif newVal and key == "nEsp" and not (S.nBox or S.nName or S.nDot or S.nDist or S.nTrace or S.nSkel) then
            S.nBox = true
            S.nName = true
        elseif newVal and key == "vEsp" and not (S.vBox or S.vName or S.vDist or S.vTrace) then
            S.vBox = true
            S.vName = true
        elseif newVal and key == "iEsp" and not (S.iBox or S.iName or S.iDist or S.iTrace) then
            S.iName = true
            S.iDist = true
        elseif newVal and key == "sEsp" and not (S.sBox or S.sName or S.sDist or S.sTrace) then
            S.sName = true
            S.sDist = true
        end
        consume()
    end
    lyY = lyY + 18
end

local function guiToggleColor(label, key, ckey, T, mx, my, click)
    local x, y, w = lyX + 6, lyY, lyW - 12
    local val = S[key]
    local col = S[ckey]
    dx9.DrawFilledBox({x, y + 2}, {x + 12, y + 14}, val and T.acc or T.surf)
    dx9.DrawBox({x, y + 2}, {x + 12, y + 14}, val and T.accD or T.brd)
    dx9.DrawString({x + 16, y + 2}, T.txt, label)
    local sx = x + w - 14
    dx9.DrawFilledBox({sx, y + 2}, {sx + 12, y + 14}, col)
    dx9.DrawBox({sx, y + 2}, {sx + 12, y + 14}, T.brd)
    if click and not consumed and inRect(mx, my, x, y, w - 18, 18) then
        local newVal = not S[key]
        S[key] = newVal
        if newVal then
            if key == "pBox" or key == "pName" or key == "pDot" or key == "pDist" or key == "pTrace" or key == "pSkel" or key == "pHealth" or key == "pSnapLine" then
                S.pEsp = true
            elseif key == "nBox" or key == "nName" or key == "nDot" or key == "nDist" or key == "nTrace" or key == "nSkel" or key == "nHealth" then
                S.nEsp = true
            elseif key == "vBox" or key == "vName" or key == "vDist" or key == "vTrace" then
                S.vEsp = true
            elseif key == "iBox" or key == "iName" or key == "iDist" or key == "iTrace" then
                S.iEsp = true
            elseif key == "sBox" or key == "sName" or key == "sDist" or key == "sTrace" then
                S.sEsp = true
            end
        end
        consume()
    end
    if click and not consumed and inRect(mx, my, sx - 2, y, 16, 18) then
        local P = CFG.PALETTE
        for i, p in ipairs(P) do
            if p[1] == col[1] and p[2] == col[2] and p[3] == col[3] then
                local nx = P[(i % #P) + 1]
                S[ckey] = {nx[1], nx[2], nx[3]}
                consume()
                lyY = lyY + 18
                return
            end
        end
        S[ckey] = {P[1][1], P[1][2], P[1][3]}
        consume()
    end
    lyY = lyY + 18
end

local function guiSlider(label, key, lo, hi, T, mx, my, click, held)
    local x, y, w = lyX + 6, lyY, lyW - 12
    local val = S[key]
    dx9.DrawString({x, y}, T.txt, label)
    dx9.DrawString({x + w - 30, y}, T.acc, tostring(round(val, 1)))
    local by = y + 14
    dx9.DrawFilledBox({x, by}, {x + w, by + 5}, T.surf)
    local pct = clamp((val - lo) / (hi - lo), 0, 1)
    local fw = floor(pct * w)
    if fw > 0 then dx9.DrawFilledBox({x, by}, {x + fw, by + 5}, T.acc) end
    if click and not consumed and inRect(mx, my, x - 2, by - 3, w + 4, 11) then
        S.slider = key
        consume()
    end
    if S.slider == key then
        if held then
            local np = clamp((mx - x) / w, 0, 1)
            S[key] = round(lo + np * (hi - lo), 1)
        else
            S.slider = nil
        end
    end
    lyY = lyY + 24
end

local function guiDrop(label, key, opts, T, mx, my, click)
    local x, y, w = lyX + 6, lyY, lyW - 12
    local idx = S[key]
    local val = opts[idx] or opts[1]
    dx9.DrawString({x, y}, T.txt, label)
    local dy = y + 14
    if S.ddOpen == key then
        for i, opt in ipairs(opts) do
            local oy = dy + (i - 1) * 18
            local hov = inRect(mx, my, x, oy, w, 18)
            dx9.DrawFilledBox({x, oy}, {x + w, oy + 18}, hov and T.acc or T.panel)
            dx9.DrawBox({x, oy}, {x + w, oy + 18}, T.brd)
            dx9.DrawString({x + 6, oy + 3}, hov and {255,255,255} or T.txt, opt)
            if click and not consumed and hov then
                S[key] = i
                S.ddOpen = nil
                consume()
            end
        end
        lyY = lyY + 16 + #opts * 18
    else
        dx9.DrawFilledBox({x, dy}, {x + w, dy + 18}, T.surf)
        dx9.DrawBox({x, dy}, {x + w, dy + 18}, T.brd)
        dx9.DrawString({x + 6, dy + 3}, T.txt, val)
        dx9.DrawString({x + w - 12, dy + 3}, T.dim, "v")
        if click and not consumed and inRect(mx, my, x, dy, w, 18) then
            S.ddOpen = key
            consume()
        end
        lyY = lyY + 36
    end
end

local function guiKeybind(label, key, T, mx, my, click)
    local x, y, w = lyX + 6, lyY, lyW - 12
    local by = y + 14
    local clearW = 56
    local bindW = w - clearW - 6
    local waiting = (S.bindTarget == key)
    local bindText = waiting and "Press key..." or formatHotkey(S[key])

    dx9.DrawString({x, y}, T.txt, label)

    dx9.DrawFilledBox({x, by}, {x + bindW, by + 18}, waiting and T.acc or T.surf)
    dx9.DrawBox({x, by}, {x + bindW, by + 18}, T.brd)
    dx9.DrawString({x + 6, by + 3}, waiting and {255,255,255} or T.txt, bindText)

    local clearX = x + bindW + 6
    dx9.DrawFilledBox({clearX, by}, {clearX + clearW, by + 18}, T.panel)
    dx9.DrawBox({clearX, by}, {clearX + clearW, by + 18}, T.brd)
    dx9.DrawString({clearX + 10, by + 3}, T.dim, "Clear")

    if click and not consumed and inRect(mx, my, x, by, bindW, 18) then
        if waiting then
            S.bindTarget = false
            S.bindArmed = false
            S.bindSeedKey = ""
        else
            S.bindTarget = key
            S.bindArmed = false
            S.bindSeedKey = normalizeKeyName(dx9.GetKey())
            S.ddOpen = nil
        end
        consume()
    end

    if click and not consumed and inRect(mx, my, clearX, by, clearW, 18) then
        S[key] = CFG.NO_HOTKEY
        S.bindTarget = false
        S.bindArmed = false
        S.bindSeedKey = ""
        S.pRecoilHotkeyOn = false
        S.pRecoilHotkeyHeld = false
        S.pRecoilHotkeySeen = 0
        addNotif("Recoil Hotkey: Always On", 2, CFG.C_SUCCESS)
        consume()
    end

    if waiting then
        dx9.DrawString({x, by + 22}, T.dim, "Press any key | ESC cancel")
        lyY = lyY + 50
    else
        lyY = lyY + 38
    end
end

local function guiLabel(text, col)
    dx9.DrawString({lyX + 6, lyY}, col, text)
    lyY = lyY + 14
end

local function guiSep(T)
    dx9.DrawLine({lyX + 6, lyY}, {lyX + lyW - 6, lyY}, T.brd)
    lyY = lyY + 4
end

-- ============================================================
-- TAB: PLAYERS
-- ============================================================
local function tabPlayers(T, mx, my, click, held)
    local gx, gw = S.guiX, CFG.GUI_W

    lyX = gx + 10
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8
    lyW = (gw - 30) / 2

    guiHeader("Player ESP", T)
    guiToggle("Enable ESP", "pEsp", T, mx, my, click)
    guiToggleColor("Box ESP", "pBox", "pBoxC", T, mx, my, click)
    guiToggleColor("Name ESP", "pName", "pNameC", T, mx, my, click)
    guiToggleColor("Head Dot", "pDot", "pDotC", T, mx, my, click)
    guiSlider("Dot Radius", "pDotR", 1, 8, T, mx, my, click, held)
    guiToggleColor("Distance", "pDist", "pDistC", T, mx, my, click)
    guiToggleColor("Tracers", "pTrace", "pTraceC", T, mx, my, click)
    guiToggleColor("Skeleton", "pSkel", "pSkelC", T, mx, my, click)
    guiToggleColor("Health Bar", "pHealth", "pHealthC", T, mx, my, click)
    guiToggleColor("Snap Line", "pSnapLine", "pSnapC", T, mx, my, click)

    lyX = gx + gw / 2 + 5
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8

    guiHeader("Player Aimbot", T)
    guiToggle("Enable Aimbot", "pAim", T, mx, my, click)
    guiDrop("Aim Part", "pAimPart", CFG.AIM_PARTS, T, mx, my, click)
    guiDrop("Mode", "pAimMode", CFG.AIM_MODES, T, mx, my, click)
    guiSlider("Sensitivity", "pSens", 1, 10, T, mx, my, click, held)
    guiSlider("Smoothness", "pSmooth", 1, 10, T, mx, my, click, held)
    guiSlider("FOV Size", "pFov", 50, 500, T, mx, my, click, held)
    guiToggleColor("Show FOV", "pShowFov", "pFovC", T, mx, my, click)
    guiSep(T)
    guiHeader("Weapon Assist", T)
    guiToggle("Counter Recoil", "pRecoil", T, mx, my, click)
    guiKeybind("Activation Hotkey", "pRecoilKey", T, mx, my, click)
    if S.pRecoilKey == CFG.NO_HOTKEY then
        guiLabel("Status: Immer aktiv", T.dim)
    elseif S.pRecoilHotkeyOn then
        guiLabel("Status: Aktiv", T.success)
    else
        guiLabel("Status: Standby", T.warn)
    end
    guiSlider("Recoil Power", "pRecoilPower", 1, 20, T, mx, my, click, held)
end

-- ============================================================
-- TAB: NPCs
-- ============================================================
local function tabNPCs(T, mx, my, click, held)
    local gx, gw = S.guiX, CFG.GUI_W

    lyX = gx + 10
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8
    lyW = (gw - 30) / 2

    guiHeader("NPC ESP", T)
    guiToggle("Enable ESP", "nEsp", T, mx, my, click)
    guiToggleColor("Box ESP", "nBox", "nBoxC", T, mx, my, click)
    guiToggleColor("Name ESP", "nName", "nNameC", T, mx, my, click)
    guiToggleColor("Head Dot", "nDot", "nDotC", T, mx, my, click)
    guiSlider("Dot Radius", "nDotR", 1, 8, T, mx, my, click, held)
    guiToggleColor("Distance", "nDist", "nDistC", T, mx, my, click)
    guiToggleColor("Tracers", "nTrace", "nTraceC", T, mx, my, click)
    guiToggleColor("Skeleton", "nSkel", "nSkelC", T, mx, my, click)
    guiToggleColor("Health Bar", "nHealth", "nHealthC", T, mx, my, click)

    lyX = gx + gw / 2 + 5
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8

    guiHeader("NPC Aimbot", T)
    guiToggle("Enable Aimbot", "nAim", T, mx, my, click)
    guiDrop("Aim Part", "nAimPart", CFG.AIM_PARTS, T, mx, my, click)
    guiDrop("Mode", "nAimMode", CFG.AIM_MODES, T, mx, my, click)
    guiSlider("Sensitivity", "nSens", 1, 10, T, mx, my, click, held)
    guiSlider("Smoothness", "nSmooth", 1, 10, T, mx, my, click, held)
    guiSlider("FOV Size", "nFov", 50, 500, T, mx, my, click, held)
    guiToggleColor("Show FOV", "nShowFov", "nFovC", T, mx, my, click)
end

-- ============================================================
-- TAB: WORLD (Vehicles, Ammo, Spawners)
-- ============================================================
local function tabWorld(T, mx, my, click, held)
    local gx, gw = S.guiX, CFG.GUI_W

    lyX = gx + 10
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8
    lyW = (gw - 30) / 2

    guiHeader("Vehicle ESP", T)
    guiToggle("Enable Vehicle ESP", "vEsp", T, mx, my, click)
    guiToggleColor("Box ESP", "vBox", "vBoxC", T, mx, my, click)
    guiToggleColor("Name ESP", "vName", "vNameC", T, mx, my, click)
    guiToggleColor("Distance", "vDist", "vDistC", T, mx, my, click)
    guiToggleColor("Tracers", "vTrace", "vTraceC", T, mx, my, click)
    guiSep(T)
    guiLabel("Vehicles: " .. #S.vehicles, T.dim)

    guiHeader("Ammo/Item ESP", T)
    guiToggle("Enable Item ESP", "iEsp", T, mx, my, click)
    guiToggleColor("Box ESP", "iBox", "iBoxC", T, mx, my, click)
    guiToggleColor("Name ESP", "iName", "iNameC", T, mx, my, click)
    guiToggleColor("Distance", "iDist", "iDistC", T, mx, my, click)
    guiToggleColor("Tracers", "iTrace", "iTraceC", T, mx, my, click)
    guiSlider("Max Distance", "iMaxDist", 50, 1000, T, mx, my, click, held)
    guiSep(T)
    guiLabel("Items: " .. #S.items, T.dim)

    lyX = gx + gw / 2 + 5
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8

    guiHeader("Spawner ESP", T)
    guiToggle("Enable Spawner ESP", "sEsp", T, mx, my, click)
    guiToggleColor("Box ESP", "sBox", "sBoxC", T, mx, my, click)
    guiToggleColor("Name ESP", "sName", "sNameC", T, mx, my, click)
    guiToggleColor("Distance", "sDist", "sDistC", T, mx, my, click)
    guiToggleColor("Tracers", "sTrace", "sTraceC", T, mx, my, click)
    guiSep(T)
    guiLabel("Spawners: " .. #S.spawners, T.dim)

    guiHeader("Stats", T)
    guiLabel("Location: " .. S.loc, T.txt)
    guiLabel("Entities: " .. #S.entities, T.txt)
    guiLabel("Session: " .. formatTime(os.clock() - S.sessionStart), T.dim)
end

-- ============================================================
-- TAB: VISUALS
-- ============================================================
local function tabVisuals(T, mx, my, click, held)
    local gx, gw = S.guiX, CFG.GUI_W

    lyX = gx + 10
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8
    lyW = (gw - 30) / 2

    guiHeader("Crosshair", T)
    guiToggle("Enable", "cross", T, mx, my, click)
    guiDrop("Style", "crossStyle", CFG.CROSS_STYLES, T, mx, my, click)
    guiToggleColor("Color / Dot", "crossDot", "crossC", T, mx, my, click)
    guiSlider("Size", "crossSz", 2, 20, T, mx, my, click, held)
    guiSlider("Gap", "crossGap", 0, 10, T, mx, my, click, held)

    guiSep(T)
    guiHeader("Overlays", T)
    guiToggle("Watermark", "wmark", T, mx, my, click)
    guiToggle("FPS Counter", "fpsCtr", T, mx, my, click)
    guiToggle("Stat Tracker", "statTracker", T, mx, my, click)

    lyX = gx + gw / 2 + 5
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8

    guiHeader("Crosshair Info", T)
    guiLabel("  Cross = Fadenkreuz", T.dim)
    guiLabel("  Dot = Punkt", T.dim)
    guiLabel("  Circle = Kreis", T.dim)
    guiLabel("  Cross+Circle = Beides", T.dim)
    guiSep(T)
    guiLabel("Stat Tracker zeigt Session-Daten", T.dim)
end

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local function tabSettings(T, mx, my, click, held)
    local gx, gw = S.guiX, CFG.GUI_W

    lyX = gx + 10
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8
    lyW = (gw - 30) / 2

    guiHeader("Appearance", T)
    local function toggleTheme()
        S.dark = not S.dark
    end
    local themeLabel = S.dark and "Light Theme" or "Dark Theme"
    local x, y, w = lyX + 6, lyY, lyW - 12
    local hov = inRect(mx, my, x, y, w, 22)
    dx9.DrawFilledBox({x, y}, {x + w, y + 22}, hov and T.acc or T.surf)
    dx9.DrawBox({x, y}, {x + w, y + 22}, T.brd)
    dx9.DrawString({x + 6, y + 5}, hov and {255,255,255} or T.txt, themeLabel)
    if click and not consumed and hov then
        toggleTheme()
        consume()
    end
    lyY = lyY + 26

    guiSep(T)
    guiLabel("Accent Color:", T.txt)
    local ax = lyX + 6
    local ay = lyY
    for i, c in ipairs(CFG.ACCENTS) do
        local cx = ax + (i - 1) * 22
        dx9.DrawFilledBox({cx, ay}, {cx + 18, ay + 18}, c)
        dx9.DrawBox({cx, ay}, {cx + 18, ay + 18}, T.brd)
        if click and not consumed and inRect(mx, my, cx, ay, 18, 18) then
            S.accC = {c[1], c[2], c[3]}
            S.accD = {floor(c[1] * 0.65), floor(c[2] * 0.65), floor(c[3] * 0.65)}
            consume()
        end
    end
    lyY = lyY + 24

    guiSep(T)
    guiHeader("System", T)
    guiToggle("Show Console", "showConsole", T, mx, my, click)
    guiToggle("Debug Mode", "debug", T, mx, my, click)

    -- Clear Console button
    x, y, w = lyX + 6, lyY, lyW - 12
    hov = inRect(mx, my, x, y, w, 22)
    dx9.DrawFilledBox({x, y}, {x + w, y + 22}, hov and T.acc or T.surf)
    dx9.DrawBox({x, y}, {x + w, y + 22}, T.brd)
    dx9.DrawString({x + 6, y + 5}, hov and {255,255,255} or T.txt, "Clear Console")
    if click and not consumed and hov then
        dx9.ClearConsole()
        addNotif("Console cleared", 2)
        consume()
    end
    lyY = lyY + 26

    -- Reset Caches button
    x, y, w = lyX + 6, lyY, lyW - 12
    hov = inRect(mx, my, x, y, w, 22)
    dx9.DrawFilledBox({x, y}, {x + w, y + 22}, hov and CFG.C_WARN or T.surf)
    dx9.DrawBox({x, y}, {x + w, y + 22}, T.brd)
    dx9.DrawString({x + 6, y + 5}, hov and {255,255,255} or T.txt, "Reset All Caches")
    if click and not consumed and hov then
        S.entities = {}
        S.entityByModel = {}
        S.entityCacheTime = 0
        S.vehicles = {}
        S.vehicleCacheTime = 0
        S.items = {}
        S.itemCacheTime = 0
        S.spawners = {}
        S.spawnerCacheTime = 0
        addNotif("Caches zurueckgesetzt", 2)
        consume()
    end
    lyY = lyY + 26

    -- Right column
    lyX = gx + gw / 2 + 5
    lyY = S.guiY + CFG.HEADER_H + CFG.TAB_H + 8

    guiHeader("Info", T)
    guiSep(T)
    guiLabel("Toggle GUI:  [F6]", T.dim)
    guiLabel("Aimbot:  Auto (wenn aktiv)", T.dim)
    guiLabel("Aim Parts: 11 (Head..Foot)", T.dim)
    guiSep(T)
    guiLabel(CFG.SCRIPT_NAME .. " v" .. CFG.VERSION, T.acc)
    guiLabel("DX9WARE Lua 5.1.4", T.dim)

    guiSep(T)
    guiHeader("Features", T)
    guiLabel("+ Player/NPC ESP & Aimbot", T.txt)
    guiLabel("+ 11 Aim Parts (Head bis Foot)", T.txt)
    guiLabel("+ Vehicle ESP (FMTV, T72, BTR..)", T.txt)
    guiLabel("+ Ammo/Item ESP", T.txt)
    guiLabel("+ Spawner ESP", T.txt)
    guiLabel("+ Health Bars", T.txt)
    guiLabel("+ Snap Lines", T.txt)
    guiLabel("+ Crosshair-Styles", T.txt)
    guiLabel("+ Startup Animation", T.txt)
end

-- ============================================================
-- WINDOW RENDERING
-- ============================================================
local function drawWindow(T, mx, my, click, held)
    local x, y = S.guiX, S.guiY
    local w, h = CFG.GUI_W, CFG.GUI_H

    if click and not consumed and inRect(mx, my, x, y, w, CFG.HEADER_H) then
        S.drag = true
        S.dragOX = mx - x
        S.dragOY = my - y
        consume()
    end
    if S.drag then
        if held then
            S.guiX = mx - S.dragOX
            S.guiY = my - S.dragOY
            x, y = S.guiX, S.guiY
        else
            S.drag = false
        end
    end

    if click and not inRect(mx, my, x, y, w, h) then S.ddOpen = nil end

    -- Background
    dx9.DrawFilledBox({x, y}, {x + w, y + h}, T.bg)
    dx9.DrawBox({x, y}, {x + w, y + h}, T.brd)

    -- Title bar
    dx9.DrawFilledBox({x + 1, y + 1}, {x + w - 1, y + CFG.HEADER_H}, T.panel)
    dx9.DrawFilledBox({x + 1, y + CFG.HEADER_H}, {x + w - 1, y + CFG.HEADER_H + 2}, T.acc)
    drawShadowedString({x + 10, y + 7}, T.acc, CFG.SCRIPT_NAME .. "  v" .. CFG.VERSION, {4, 4, 6})
    dx9.DrawString({x + 180, y + 7}, T.dim, "by Lorthanyx")
    dx9.DrawString({x + w - 84, y + 7}, T.dim, "[F6] Toggle")

    -- Tab bar
    local ty = y + CFG.HEADER_H + 2
    local tw = floor(w / #CFG.TABS)
    dx9.DrawFilledBox({x + 1, ty}, {x + w - 1, ty + CFG.TAB_H}, T.panel)

    for i, name in ipairs(CFG.TABS) do
        local tx = x + (i - 1) * tw
        if S.tab == i then
            dx9.DrawFilledBox({tx + 1, ty}, {tx + tw - 1, ty + CFG.TAB_H}, T.surf)
            dx9.DrawFilledBox({tx + 1, ty + CFG.TAB_H - 2}, {tx + tw - 1, ty + CFG.TAB_H}, T.acc)
            dx9.DrawString({tx + 6, ty + 5}, T.acc, name)
        else
            dx9.DrawString({tx + 6, ty + 5}, T.dim, name)
        end
        if click and not consumed and inRect(mx, my, tx, ty, tw, CFG.TAB_H) then
            S.tab = i
            S.ddOpen = nil
            consume()
        end
    end

    dx9.DrawLine({x, ty + CFG.TAB_H}, {x + w, ty + CFG.TAB_H}, T.brd)

    local tabFns = {tabPlayers, tabNPCs, tabWorld, tabVisuals, tabSettings}
    if tabFns[S.tab] then
        tabFns[S.tab](T, mx, my, click, held)
    end
end

-- ============================================================
-- ESP DRAWING
-- ============================================================
local function drawHealthBar(x, y, w, hp, maxHp, col)
    local pct = clamp(hp / max(maxHp, 1), 0, 1)
    local barH = 3
    dx9.DrawFilledBox({x, y}, {x + w, y + barH}, {40, 40, 50})
    local hpColor = lerpColor({255,50,50}, col, pct)
    local fw = floor(pct * w)
    if fw > 0 then dx9.DrawFilledBox({x, y}, {x + fw, y + barH}, hpColor) end
end

local function drawEntityESP(entity, isP, headWTS, footWTS, headPos, footPos, sw, sh, T)
    if not headWTS.x or headWTS.x < 0 or headWTS.x > sw or headWTS.y < 0 or headWTS.y > sh then
        return
    end

    local masterOn = isP and S.pEsp or S.nEsp
    if not masterOn then return end

    local ch = abs(headWTS.y - footWTS.y)
    if ch < 5 then return end
    local cw = ch * 0.65

    -- Box
    if (isP and S.pBox) or (not isP and S.nBox) then
        local c = isP and S.pBoxC or S.nBoxC
        dx9.DrawBox({headWTS.x - cw / 2, headWTS.y}, {headWTS.x + cw / 2, footWTS.y}, c)
    end

    -- Name
    if (isP and S.pName) or (not isP and S.nName) then
        local c = isP and S.pNameC or S.nNameC
        local label = isP and (entity.ownerName or "Player") or "NPC"
        dx9.DrawString({headWTS.x + cw / 2 + 4, headWTS.y}, c, label)
    end

    -- Head Dot
    if (isP and S.pDot) or (not isP and S.nDot) then
        local c = isP and S.pDotC or S.nDotC
        local r = isP and S.pDotR or S.nDotR
        dx9.DrawCircle({headWTS.x, headWTS.y}, c, r)
    end

    -- Distance (from player character position)
    local refPos = getDistanceOrigin()
    if ((isP and S.pDist) or (not isP and S.nDist)) and refPos then
        local distPos = headPos
        if entity.core and entity.core ~= 0 then
            local corePos = dx9.GetPosition(entity.core)
            if corePos then
                distPos = corePos
            end
        end
        local lp = refPos
        local ddx = lp.x - distPos.x
        local ddy = lp.y - distPos.y
        local ddz = lp.z - distPos.z
        local d = floor(sqrt(ddx * ddx + ddy * ddy + ddz * ddz))
        local c = isP and S.pDistC or S.nDistC
        dx9.DrawString({headWTS.x - 10, footWTS.y + 4}, c, d .. "m")
    end

    -- Tracers
    if (isP and S.pTrace) or (not isP and S.nTrace) then
        local c = isP and S.pTraceC or S.nTraceC
        dx9.DrawLine({sw / 2, sh}, {footWTS.x, footWTS.y}, c)
    end

    -- Health Bar
    if (isP and S.pHealth) or (not isP and S.nHealth) then
        local c = isP and S.pHealthC or S.nHealthC
        drawHealthBar(headWTS.x - cw / 2, headWTS.y - 6, cw, entity.hp or 100, entity.maxHp or 100, c)
    end

    -- Snap Line (player only)
    if isP and S.pSnapLine then
        dx9.DrawLine({sw / 2, sh / 2}, {headWTS.x, headWTS.y}, S.pSnapC)
    end

    -- Skeleton
    if (isP and S.pSkel) or (not isP and S.nSkel) then
        local c = isP and S.pSkelC or S.nSkelC
        local parts = entity.parts or {}
        for _, conn in ipairs(CFG.SKELETON) do
            local p1 = parts[conn[1]]
            local p2 = parts[conn[2]]
            if p1 and p1 ~= 0 and p2 and p2 ~= 0 then
                local pos1 = dx9.GetPosition(p1)
                local pos2 = dx9.GetPosition(p2)
                if pos1 and pos2 then
                    local w1 = dx9.WorldToScreen({pos1.x, pos1.y, pos1.z})
                    local w2 = dx9.WorldToScreen({pos2.x, pos2.y, pos2.z})
                    if w1 and w2 and w1.x and w2.x then
                        dx9.DrawLine({w1.x, w1.y}, {w2.x, w2.y}, c)
                    end
                end
            end
        end
    end
end

-- ============================================================
-- WORLD ESP (Vehicles, Items, Spawners)
-- ============================================================
local function drawWorldESP(sw, sh, T)
    local cp = getDistanceOrigin()

    -- Vehicle ESP
    if S.vEsp then
        for _, v in ipairs(S.vehicles) do
            if v.pos then
                local wts = dx9.WorldToScreen({v.pos.x, v.pos.y, v.pos.z})
                if wts and wts.x and wts.x > 0 and wts.x < sw and wts.y > 0 and wts.y < sh then
                    if S.vBox then
                        dx9.DrawBox({wts.x - 20, wts.y - 10}, {wts.x + 20, wts.y + 10}, S.vBoxC)
                    end
                    if S.vName then
                        dx9.DrawString({wts.x + 22, wts.y - 6}, S.vNameC, v.display)
                    end
                    if S.vDist and cp then
                        local d = floor(dist3d(cp, v.pos))
                        dx9.DrawString({wts.x - 10, wts.y + 12}, S.vDistC, d .. "m")
                    end
                    if S.vTrace then
                        dx9.DrawLine({sw / 2, sh}, {wts.x, wts.y}, S.vTraceC)
                    end
                    -- Vehicle diamond icon
                    dx9.DrawLine({wts.x, wts.y - 5}, {wts.x + 5, wts.y}, S.vBoxC)
                    dx9.DrawLine({wts.x + 5, wts.y}, {wts.x, wts.y + 5}, S.vBoxC)
                    dx9.DrawLine({wts.x, wts.y + 5}, {wts.x - 5, wts.y}, S.vBoxC)
                    dx9.DrawLine({wts.x - 5, wts.y}, {wts.x, wts.y - 5}, S.vBoxC)
                end
            end
        end
    end

    -- Item ESP
    if S.iEsp then
        for _, item in ipairs(S.items) do
            if item.pos then
                local d = cp and dist3d(cp, item.pos) or 0
                if d <= S.iMaxDist then
                    local wts = dx9.WorldToScreen({item.pos.x, item.pos.y, item.pos.z})
                    if wts and wts.x and wts.x > 0 and wts.x < sw and wts.y > 0 and wts.y < sh then
                        if S.iBox then
                            dx9.DrawBox({wts.x - 8, wts.y - 8}, {wts.x + 8, wts.y + 8}, S.iBoxC)
                        end
                        if S.iName then
                            dx9.DrawString({wts.x + 10, wts.y - 4}, S.iNameC, item.display)
                        end
                        if S.iDist then
                            dx9.DrawString({wts.x - 8, wts.y + 10}, S.iDistC, floor(d) .. "m")
                        end
                        if S.iTrace then
                            dx9.DrawLine({sw / 2, sh}, {wts.x, wts.y}, S.iTraceC)
                        end
                        dx9.DrawFilledBox({wts.x - 3, wts.y - 3}, {wts.x + 3, wts.y + 3}, S.iBoxC)
                    end
                end
            end
        end
    end

    -- Spawner ESP
    if S.sEsp then
        for _, sp in ipairs(S.spawners) do
            if sp.pos then
                local wts = dx9.WorldToScreen({sp.pos.x, sp.pos.y, sp.pos.z})
                if wts and wts.x and wts.x > 0 and wts.x < sw and wts.y > 0 and wts.y < sh then
                    if S.sBox then
                        dx9.DrawBox({wts.x - 12, wts.y - 12}, {wts.x + 12, wts.y + 12}, S.sBoxC)
                    end
                    if S.sName then
                        dx9.DrawString({wts.x + 14, wts.y - 4}, S.sNameC, sp.display)
                    end
                    if S.sDist and cp then
                        local d = floor(dist3d(cp, sp.pos))
                        dx9.DrawString({wts.x - 8, wts.y + 14}, S.sDistC, d .. "m")
                    end
                    if S.sTrace then
                        dx9.DrawLine({sw / 2, sh}, {wts.x, wts.y}, S.sTraceC)
                    end
                    -- Spawner triangle icon
                    dx9.DrawLine({wts.x, wts.y - 6}, {wts.x + 6, wts.y + 4}, S.sBoxC)
                    dx9.DrawLine({wts.x + 6, wts.y + 4}, {wts.x - 6, wts.y + 4}, S.sBoxC)
                    dx9.DrawLine({wts.x - 6, wts.y + 4}, {wts.x, wts.y - 6}, S.sBoxC)
                end
            end
        end
    end
end

-- ============================================================
-- AIMBOT PROCESSING
-- ============================================================
local function processAimbot(entity, isP, sw, sh)
    local enabled = isP and S.pAim or S.nAim
    if not enabled then return end

    local partIdx = isP and S.pAimPart or S.nAimPart
    local partName = CFG.AIM_PARTS[partIdx] or "Head"

    local parts = entity.parts or {}
    local part = parts[partName]
    if part == nil then
        part = dx9.FindFirstChild(entity.model, partName)
        parts[partName] = part
        entity.parts = parts
    end
    if not part or part == 0 then return end

    local pos = dx9.GetPosition(part)
    if not pos then return end

    local wts = dx9.WorldToScreen({pos.x, pos.y, pos.z})
    if not wts or not wts.x then return end

    local cx, cy = sw / 2, sh / 2
    local ddx = wts.x - cx
    local ddy = wts.y - cy
    local d = sqrt(ddx * ddx + ddy * ddy)

    local fov = isP and S.pFov or S.nFov
    if d > fov then return end

    if d < S.aimDist then
        S.aimDist = d
        S.aimX = wts.x
        S.aimY = wts.y
        S.aimCallX = wts.x + cx
        S.aimCallY = wts.y + cy
        S.aimType = isP and "p" or "n"
    end
end

local function updateRecoilHotkeyState(currentKey, now)
    local bindKey = normalizeKeyName(S.pRecoilKey)
    local keyName = normalizeKeyName(currentKey)

    if bindKey == "" or bindKey == CFG.NO_HOTKEY then
        S.pRecoilHotkeyOn = false
        S.pRecoilHotkeyHeld = false
        S.pRecoilHotkeySeen = 0
        return
    end

    if keyName == bindKey then
        S.pRecoilHotkeySeen = now
        if not S.pRecoilHotkeyHeld then
            S.pRecoilHotkeyHeld = true
            S.pRecoilHotkeyOn = not S.pRecoilHotkeyOn
            addNotif(
                S.pRecoilHotkeyOn and "Counter Recoil aktiviert" or "Counter Recoil pausiert",
                2,
                S.pRecoilHotkeyOn and CFG.C_SUCCESS or CFG.C_WARN
            )
        end
        return
    end

    if S.pRecoilHotkeyHeld and now - (S.pRecoilHotkeySeen or 0) > 0.18 then
        S.pRecoilHotkeyHeld = false
    end
end

local function recoilHotkeyActive()
    local bindKey = normalizeKeyName(S.pRecoilKey)
    if bindKey == "" or bindKey == CFG.NO_HOTKEY then
        return true
    end
    return S.pRecoilHotkeyOn == true
end

local function getRecoilOffset(held)
    if not held or not S.pRecoil or not recoilHotkeyActive() then
        S.recoilNext = 0
        return 0
    end

    -- A continuous pull works more reliably with the dx9 aim helpers
    -- than tiny timed pulses, which often end up too weak to notice.
    return (S.pRecoilPower or 0) * 4
end

local function executeAimbot(sw, sh, recoilOffset)
    if not S.aimX then return false end

    local smooth, sens, mode
    if S.aimType == "p" then
        smooth = S.pSmooth
        sens = S.pSens
        mode = S.pAimMode
    else
        smooth = S.nSmooth
        sens = S.nSens
        mode = S.nAimMode
    end

    local tx = S.aimCallX or (S.aimX + sw / 2)
    local ty = S.aimCallY or (S.aimY + sh / 2)
    ty = ty + (recoilOffset or 0)

    if mode == 2 then
        dx9.ThirdPersonAim({tx, ty}, smooth, smooth)
    else
        dx9.FirstPersonAim({tx, ty}, smooth, sens)
    end

    return true
end

local function executeCounterRecoil(sw, sh, recoilOffset)
    if recoilOffset <= 0 then return end

    local cx, cy = sw / 2, sh / 2
    local tx = cx
    local ty = cy + recoilOffset
    local mode = S.pAimMode or 1

    if mode == 2 then
        dx9.ThirdPersonAim({tx, ty}, 1, 1)
    else
        local fpSens = max(2, recoilOffset * 0.5)
        dx9.FirstPersonAim({tx, ty}, 1, fpSens)
    end
end

-- ============================================================
-- VISUAL OVERLAYS
-- ============================================================
local function drawCrosshair(sw, sh)
    if not S.cross then return end
    local cx, cy = sw / 2, sh / 2
    local col = S.crossC
    local sz = S.crossSz
    local gap = S.crossGap
    local style = S.crossStyle

    if style == 1 or style == 4 then
        dx9.DrawLine({cx - sz - gap, cy}, {cx - gap, cy}, col)
        dx9.DrawLine({cx + gap, cy}, {cx + sz + gap, cy}, col)
        dx9.DrawLine({cx, cy - sz - gap}, {cx, cy - gap}, col)
        dx9.DrawLine({cx, cy + gap}, {cx, cy + sz + gap}, col)
        if S.crossDot then dx9.DrawCircle({cx, cy}, col, 1) end
    end
    if style == 2 then
        dx9.DrawCircle({cx, cy}, col, 2)
    end
    if style == 3 or style == 4 then
        dx9.DrawCircle({cx, cy}, col, sz)
        if S.crossDot and style == 3 then dx9.DrawCircle({cx, cy}, col, 1) end
    end
end

local function drawFovCircles(sw, sh)
    local cx, cy = sw / 2, sh / 2
    if S.pShowFov and S.pAim then dx9.DrawCircle({cx, cy}, S.pFovC, S.pFov) end
    if S.nShowFov and S.nAim then dx9.DrawCircle({cx, cy}, S.nFovC, S.nFov) end
end

local function drawWatermark(T)
    if not S.wmark then return end
    dx9.DrawFilledBox({8, 8}, {252, 46}, T.panel)
    dx9.DrawBox({8, 8}, {252, 46}, T.brd)
    dx9.DrawFilledBox({8, 8}, {14, 46}, T.acc)
    drawShadowedString({20, 14}, T.acc, CFG.SCRIPT_NAME .. " v" .. CFG.VERSION, {4, 4, 6})
    dx9.DrawString({20, 29}, T.dim, "by Lorthanyx")
end

local function drawFPS(T)
    if not S.fpsCtr then return end
    S.fpsFrames = S.fpsFrames + 1
    local now = os.clock()
    if now - S.fpsTime >= 1 then
        S.fps = floor(S.fpsFrames / (now - S.fpsTime))
        S.fpsFrames = 0
        S.fpsTime = now
    end
    local wy = S.wmark and 54 or 8
    dx9.DrawFilledBox({8, wy}, {100, wy + 20}, T.panel)
    dx9.DrawBox({8, wy}, {100, wy + 20}, T.brd)
    dx9.DrawString({14, wy + 4}, T.txt, "FPS: " .. S.fps)
end

local function drawStatTracker(sw, sh, T)
    if not S.statTracker then return end
    local bx = sw - 180
    local by = 8
    dx9.DrawFilledBox({bx, by}, {bx + 170, by + 60}, T.panel)
    dx9.DrawBox({bx, by}, {bx + 170, by + 60}, T.brd)
    dx9.DrawFilledBox({bx, by}, {bx + 3, by + 60}, T.acc)
    dx9.DrawString({bx + 8, by + 4}, T.acc, "Session Stats")
    dx9.DrawString({bx + 8, by + 18}, T.txt, "Zeit: " .. formatTime(os.clock() - S.sessionStart))
    dx9.DrawString({bx + 8, by + 32}, T.txt, "Entities: " .. #S.entities .. " | Veh: " .. #S.vehicles)
    dx9.DrawString({bx + 8, by + 46}, T.txt, "Items: " .. #S.items .. " | Spawner: " .. #S.spawners)
end

local function drawDebugOverlay(sw, sh, T, frameTime)
    if not S.debug then return end
    local dy = sh - 80
    dx9.DrawString({10, dy}, {255,180,0}, "DEBUG")
    dx9.DrawString({10, dy + 14}, T.txt, "Loc: " .. S.loc .. " | Frame: " .. S.frameCount)
    dx9.DrawString({10, dy + 28}, T.txt, "Ent: " .. #S.entities .. " Veh: " .. #S.vehicles .. " Items: " .. #S.items .. " Sp: " .. #S.spawners)
    if frameTime then
        dx9.DrawString({10, dy + 42}, T.txt, "Time: " .. string.format("%.1f", frameTime) .. "ms")
    end
    if S.localPos then
        dx9.DrawString({10, dy + 56}, T.txt, string.format("Pos: %.0f, %.0f, %.0f", S.localPos.x, S.localPos.y, S.localPos.z))
    end
end

-- ============================================================
-- STARTUP ANIMATION (Professional)
-- ============================================================
local function initParticles(sw, sh)
    local p = {}
    for i = 1, 40 do
        p[i] = {
            x = math.random(0, sw),
            y = math.random(0, sh),
            vx = (math.random() - 0.5) * 60,
            vy = (math.random() - 0.5) * 60,
            sz = math.random(1, 3),
            life = math.random() * 0.6 + 0.4,
        }
    end
    return p
end

local function drawStartupAnimation(sw, sh, T)
    if S.introDone then return false end

    local now = os.clock()

    if S.introStart == 0 then
        S.introStart = now
        S.introPhase = 1
        S.introParticles = initParticles(sw, sh)
    end

    local elapsed = now - S.introStart
    local totalDuration = 7.4

    if elapsed > totalDuration then
        S.introDone = true
        S.introParticles = nil
        return false
    end

    local cx = sw / 2
    local cy = sh / 2
    local introFade = easeInOut01(elapsed / 0.55)
    local outroFade = easeInOut01((totalDuration - elapsed) / 0.9)
    local sceneFade = min(introFade, outroFade)
    local bgOutroFade = easeInOut01((totalDuration - elapsed) / 0.9)
    local bgFade = min(introFade, bgOutroFade)
    local bgAlpha = 255 * bgFade
    local bgCol = lerpColor({0, 0, 0}, {4, 4, 8}, bgFade)
    local ac = lerpColor({0, 0, 0}, S.accC, sceneFade)

    -- === FULL SCREEN BACKGROUND ===
    dx9.DrawFilledBox({0, 0}, {sw, sh}, withAlpha(bgCol, bgAlpha))

    -- === PARTICLE FIELD (floating dots/lines) ===
    local particles = S.introParticles or {}
    local dt = 0.016
    for i, p in ipairs(particles) do
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        if p.x < 0 then p.x = sw end
        if p.x > sw then p.x = 0 end
        if p.y < 0 then p.y = sh end
        if p.y > sh then p.y = 0 end

        local fadeIn = clamp(elapsed / 1.0, 0, 1)
        local fadeOut = clamp((totalDuration - elapsed) / 1.0, 0, 1)
        local alpha = fadeIn * fadeOut * p.life

        if alpha > 0.1 then
            local brightness = floor(alpha * 60 * sceneFade)
            local pc = {brightness, brightness, floor(brightness * 1.2)}
            dx9.DrawFilledBox({floor(p.x), floor(p.y)}, {floor(p.x) + p.sz, floor(p.y) + p.sz}, pc)

            -- Connect nearby particles with lines
            for j = i + 1, min(i + 5, #particles) do
                local p2 = particles[j]
                local pdx = p.x - p2.x
                local pdy = p.y - p2.y
                if pdx * pdx + pdy * pdy < 15000 then
                    dx9.DrawLine({floor(p.x), floor(p.y)}, {floor(p2.x), floor(p2.y)}, scaleColor({20, 20, 30}, sceneFade))
                end
            end
        end
    end

    -- === HEXAGONAL GRID BACKGROUND (subtle) ===
    if elapsed > 0.3 and elapsed < totalDuration - 0.5 then
        local gridAlpha = clamp((elapsed - 0.3) / 0.5, 0, 1) * clamp((totalDuration - 0.5 - elapsed) / 0.5, 0, 1)
        if gridAlpha > 0.05 then
            local gc = scaleColor({floor(15 * gridAlpha), floor(15 * gridAlpha), floor(20 * gridAlpha)}, sceneFade)
            local spacing = 40
            for gx = floor(cx - 220), floor(cx + 220), spacing do
                dx9.DrawLine({gx, floor(cy - 120)}, {gx, floor(cy + 120)}, gc)
            end
            for gy = floor(cy - 120), floor(cy + 120), spacing do
                dx9.DrawLine({floor(cx - 220), gy}, {floor(cx + 220), gy}, gc)
            end
        end
    end

    -- === PHASE 1 (0-1.5s): Cinematic bars + center line ===
    local barMaxH = 50
    if elapsed < 1.5 then
        local t = clamp(elapsed / 1.2, 0, 1)
        local easeT = t * t * (3 - 2 * t)
        local barH = floor(easeT * barMaxH)
        dx9.DrawFilledBox({0, 0}, {sw, barH}, ac)
        dx9.DrawFilledBox({0, sh - barH}, {sw, sh}, ac)

        -- Center line grows
        local lineW = floor(easeT * 250)
        if lineW > 0 then
            dx9.DrawFilledBox({cx - lineW, cy - 1}, {cx + lineW, cy + 1}, ac)
            -- Glow effect: slightly wider dimmer lines
            local glow = scaleColor(ac, 0.3)
            dx9.DrawFilledBox({cx - lineW - 20, cy - 2}, {cx + lineW + 20, cy + 2}, glow)
        end
    else
        -- Bars stay
        local fadeBarT = 1
        if elapsed > totalDuration - 1.5 then
            fadeBarT = clamp((totalDuration - elapsed) / 1.5, 0, 1)
        end
        local barH = floor(fadeBarT * barMaxH)
        if barH > 0 then
            dx9.DrawFilledBox({0, 0}, {sw, barH}, ac)
            dx9.DrawFilledBox({0, sh - barH}, {sw, sh}, ac)
        end

        -- Center line
        local lineAlpha = fadeBarT
        if lineAlpha > 0.05 then
            dx9.DrawFilledBox({cx - 250, cy - 1}, {cx + 250, cy + 1}, ac)
        end
    end

    -- === CORNER BRACKETS (decorative frame) ===
    if elapsed > 0.8 and elapsed < totalDuration - 0.8 then
        local bt = clamp((elapsed - 0.8) / 0.6, 0, 1)
        local bFade = clamp((totalDuration - 0.8 - elapsed) / 0.6, 0, 1)
        local bLen = floor(bt * bFade * 30)
        if bLen > 2 then
            local bx1, by1 = cx - 220, cy - 80
            local bx2, by2 = cx + 220, cy + 90
            dx9.DrawLine({bx1, by1}, {bx1 + bLen, by1}, ac)
            dx9.DrawLine({bx1, by1}, {bx1, by1 + bLen}, ac)
            dx9.DrawLine({bx2, by1}, {bx2 - bLen, by1}, ac)
            dx9.DrawLine({bx2, by1}, {bx2, by1 + bLen}, ac)
            dx9.DrawLine({bx1, by2}, {bx1 + bLen, by2}, ac)
            dx9.DrawLine({bx1, by2}, {bx1, by2 - bLen}, ac)
            dx9.DrawLine({bx2, by2}, {bx2 - bLen, by2}, ac)
            dx9.DrawLine({bx2, by2}, {bx2, by2 - bLen}, ac)
        end
    end

    -- === PHASE 2 (1.2-3.0s): Title typewriter ===
    if elapsed > 1.2 then
        local title = "Shrimplock Universal"
        local titleT = clamp((elapsed - 1.2) / 1.0, 0, 1)
        local visibleChars = floor(titleT * #title)
        local visibleTitle = string.sub(title, 1, visibleChars)

        -- Glitch char at cursor
        if visibleChars < #title and visibleChars > 0 then
            local glitchSet = "!@#$%&*<>=/|~"
            local gi = floor(now * 20) % #glitchSet + 1
            visibleTitle = visibleTitle .. string.sub(glitchSet, gi, gi)
        end

        -- Pulsing glow on title
        local pulse = 0.85 + sin(now * 4) * 0.15
        local titleCol = {
            floor(min(ac[1] * pulse, 255)),
            floor(min(ac[2] * pulse, 255)),
            floor(min(ac[3] * pulse, 255)),
        }

        local titleX = cx - (#title * 5)
        local fadeOut = clamp((totalDuration - elapsed) / 1.2, 0, 1)
        if fadeOut > 0.05 then
            local titleShadow = scaleColor(ac, 0.2)
            drawShadowedString(
                {titleX, cy - 35},
                titleCol,
                visibleTitle,
                titleShadow
            )
        end
    end

    -- === PHASE 3 (2.5-end): "Made by Lorthanyx" ===
    if elapsed > 2.5 then
        local subT = clamp((elapsed - 2.5) / 0.8, 0, 1)
        local subFade = clamp((totalDuration - elapsed) / 1.0, 0, 1)
        local alpha = subT * subFade
        if alpha > 0.05 then
            local subtitle = "Made by Lorthanyx"
            local subX = cx - (#subtitle * 3.5)
            local subCol = scaleColor(lerpColor({28, 28, 36}, {240, 240, 245}, alpha), sceneFade)
            drawShadowedString({subX, cy + 8}, subCol, subtitle, {4, 4, 6})
        end
    end

    -- === PHASE 4 (3.2s): Version line ===
    if elapsed > 3.2 then
        local verT = clamp((elapsed - 3.2) / 0.6, 0, 1)
        local verFade = clamp((totalDuration - elapsed) / 1.0, 0, 1)
        local alpha = verT * verFade
        if alpha > 0.05 then
            local verText = "v" .. CFG.VERSION .. "  |  DX9WARE  |  Lua 5.1"
            local verX = cx - (#verText * 3)
            local verCol = scaleColor(lerpColor({4, 4, 8}, ac, alpha), sceneFade)
            drawShadowedString({verX, cy + 26}, verCol, verText, {4, 4, 6})
        end
    end

    -- === PHASE 5 (3.8s): Feature tags ===
    if elapsed > 3.8 then
        local featT = clamp((elapsed - 3.8) / 0.6, 0, 1)
        local featFade = clamp((totalDuration - elapsed) / 1.0, 0, 1)
        local alpha = featT * featFade
        if alpha > 0.05 then
            local featCol = scaleColor(lerpColor({24, 24, 30}, {140, 140, 160}, alpha), sceneFade)
            local line1 = "ESP  +  Aimbot  +  Vehicles  +  Ammo  +  Spawner"
            local fX1 = cx - (#line1 * 2.8)
            drawShadowedString({fX1, cy + 44}, featCol, line1, {4, 4, 6})
        end
    end

    -- === PHASE 6 (4.5s): Loading bar ===
    if elapsed > 4.5 then
        local loadT = clamp((elapsed - 4.5) / 1.2, 0, 1)
        local loadFade = clamp((totalDuration - elapsed) / 0.8, 0, 1)
        if loadFade > 0.05 then
            local barW = 240
            local barX = cx - barW / 2
            local barY = cy + 65

            -- Bar background
            dx9.DrawFilledBox({barX, barY}, {barX + barW, barY + 3}, scaleColor({20, 20, 28}, sceneFade))
            dx9.DrawBox({barX - 1, barY - 1}, {barX + barW + 1, barY + 4}, scaleColor({30, 30, 40}, sceneFade))

            -- Fill with gradient feel
            local fillW = floor(loadT * barW)
            if fillW > 0 then
                dx9.DrawFilledBox({barX, barY}, {barX + fillW, barY + 3}, ac)
                -- Bright tip
                if fillW > 3 then
                    dx9.DrawFilledBox({barX + fillW - 3, barY}, {barX + fillW, barY + 3}, scaleColor({255, 255, 255}, sceneFade))
                end
            end

            -- Status text
            local pct = floor(loadT * 100)
            local dots = string.rep(".", floor(now * 3) % 4)
            local statusText = "INITIALIZING" .. dots .. "  " .. pct .. "%"
            local stX = cx - (#statusText * 3)
            drawShadowedString({stX, barY + 8}, scaleColor({185, 185, 200}, sceneFade), statusText, {4, 4, 6})
        end
    end

    -- === SCANNING LINE (horizontal sweep) ===
    if elapsed > 1.0 and elapsed < totalDuration - 1.0 then
        local scanSpeed = 1.8
        local scanPos = ((elapsed * scanSpeed) % 1.0)
        local scanY = floor(cy - 70 + scanPos * 160)
        local scanAlpha = clamp((totalDuration - 1.0 - elapsed) / 1.0, 0, 1)
        if scanAlpha > 0.1 then
            local scanCol = {floor(ac[1] * 0.25 * scanAlpha), floor(ac[2] * 0.25 * scanAlpha), floor(ac[3] * 0.25 * scanAlpha)}
            dx9.DrawLine({cx - 230, scanY}, {cx + 230, scanY}, scanCol)
        end
    end

    -- === DIGITAL RAIN COLUMNS (subtle, sides) ===
    if elapsed > 0.5 and elapsed < totalDuration - 0.5 then
        local rainAlpha = clamp((elapsed - 0.5) / 0.5, 0, 1) * clamp((totalDuration - 0.5 - elapsed) / 0.5, 0, 1) * 0.4
        if rainAlpha > 0.02 then
            local chars = "01"
            local colCount = 6
            for ci = 1, colCount do
                local rx = (ci <= 3) and (cx - 260 + (ci - 1) * 20) or (cx + 200 + (ci - 4) * 20)
                local speed = 40 + ci * 15
                local offset = (elapsed * speed) % 200
                for ri = 0, 5 do
                    local ry = floor(cy - 80 + offset + ri * 25) % floor(sh)
                    if ry > cy - 80 and ry < cy + 100 then
                        local charIdx = floor(now * 10 + ci + ri) % #chars + 1
                        local ch = string.sub(chars, charIdx, charIdx)
                        local rc = {floor(ac[1] * rainAlpha * (1 - ri * 0.15)), floor(ac[2] * rainAlpha * (1 - ri * 0.15)), floor(ac[3] * rainAlpha * (1 - ri * 0.15))}
                        dx9.DrawString({rx, ry}, rc, ch)
                    end
                end
            end
        end
    end

    return true
end

-- ============================================================
-- MAIN (laeuft jeden Frame)
-- ============================================================

timerStart("FRAME_TOTAL")
S.frameCount = S.frameCount + 1

-- 1. Input
local mouse = dx9.GetMouse()
local mx = mouse.x or 0
local my = mouse.y or 0
local click = dx9.isLeftClick()
local held = dx9.isLeftClickHeld()

local key = dx9.GetKey()
local sz = dx9.size()
local sw = sz.width
local sh = sz.height
consumed = false

-- 2. Reset aim
S.aimX = nil
S.aimY = nil
S.aimCallX = nil
S.aimCallY = nil
S.aimDist = huge
S.aimType = nil

-- 3. Hotkey capture + toggle key
local bindBusy = handlePendingKeybind(key)
local kd = (not bindBusy) and (key == CFG.TOGGLE_KEY)
if kd and not S.keyHeld then
    S.guiOn = not S.guiOn
    S.ddOpen = nil
end
S.keyHeld = kd

-- 4. Console sync
if S.lastShowConsole ~= S.showConsole then
    dx9.ShowConsole(S.showConsole)
    S.lastShowConsole = S.showConsole
end

-- 5. Theme
local T = getTheme()

-- 6. Feature gating
local pEspOn = playerEspActive()
local nEspOn = npcEspActive()
local needP = pEspOn or S.pAim
local needN = nEspOn or S.nAim
local needEntities = needP or needN
local cacheMode = (needP and "p" or "") .. (needN and "n" or "")
local loc = S.loc

local needWorld = S.vEsp or S.iEsp or S.sEsp

if needEntities or needWorld or S.debug then
    loc = detectLocation()
end

-- 7. Always refresh local player info for distance
local now = os.clock()
if not bindBusy then
    updateRecoilHotkeyState(key, now)
end

-- 8. Entity scan
timerStart("entityScan")
local entityCount = 0
local espCount = 0

local ok_dm, game = pcall(dx9.GetDatamodel)
local ws = nil
local pls = nil

if ok_dm and game then
    ws = findChild(game, "Workspace")
    pls = findChild(game, "Players")
end

if ws then
    local cam = findChild(ws, "Camera")
    if cam then
        S.camPos = getPos(cam)
    end
end

refreshLocalPlayerInfo(now, pls)

if needEntities and ws then
    if S.entityCacheWs ~= ws or S.entityCacheMode ~= cacheMode or now - (S.entityCacheTime or 0) >= CFG.ENTITY_CACHE_SEC then
        refreshEntityCache(ws, pls, now, needP, needN, cacheMode)
        loc = S.loc
    end

    local entities = S.entities or {}
    for _, entity in ipairs(entities) do
        entityCount = entityCount + 1
        local isP = entity.isP
        local showP = isP and needP and (loc == "comp" or loc == "ronograd")
        local showN = (not isP) and needN and loc == "ronograd"

        if showP or showN then
            local espOn = (isP and pEspOn) or ((not isP) and nEspOn)
            if espOn then
                local hp = dx9.GetPosition(entity.head)
                local fp = dx9.GetPosition(entity.foot)

                if hp and fp then
                    local hw = dx9.WorldToScreen({hp.x, hp.y, hp.z})
                    local fw = dx9.WorldToScreen({fp.x, fp.y, fp.z})

                    if hw and fw and hw.x and fw.x then
                        espCount = espCount + 1
                        drawEntityESP(entity, isP, hw, fw, hp, fp, sw, sh, T)
                    end
                end
            end

            if isP and S.pAim then
                processAimbot(entity, true, sw, sh)
            elseif (not isP) and S.nAim then
                processAimbot(entity, false, sw, sh)
            end
        end
    end
end
timerEnd("entityScan")

-- 9. World scans (vehicles, items, spawners)
timerStart("worldScan")
if ws and needWorld then
    refreshVehicleCache(ws, now)
    refreshItemCache(ws, now)
    refreshSpawnerCache(ws, now)
end
timerEnd("worldScan")

-- 10. Aimbot
local recoilOffset = getRecoilOffset(held)
local aimed = executeAimbot(sw, sh, recoilOffset)
if not aimed then
    executeCounterRecoil(sw, sh, recoilOffset)
end

-- 11. World ESP
drawWorldESP(sw, sh, T)

-- 12. Overlays
drawFovCircles(sw, sh)
drawCrosshair(sw, sh)
drawWatermark(T)
drawFPS(T)
drawStatTracker(sw, sh, T)

-- 13. GUI
if S.guiOn then
    drawWindow(T, mx, my, click, held)
end

-- 14. Startup Animation (on top)
drawStartupAnimation(sw, sh, T)

-- 15. Notifications
drawNotifs(T)

-- 16. Debug
local totalTime = timerEnd("FRAME_TOTAL")
drawDebugOverlay(sw, sh, T, totalTime)

if S.debug and totalTime and totalTime > CFG.SLOW_FRAME_MS then
    if now - (S.lastSlowLog or 0) >= CFG.PERF_LOG_SEC then
        S.lastSlowLog = now
        print("[SLOW FRAME] " .. string.format("%.1f", totalTime) .. "ms (frame #" .. S.frameCount .. ")")
    end
end

-- 17. Debug periodic log
if S.debug and S.frameCount % 120 == 0 then
    print("[SCAN] loc=" .. loc .. " entities=" .. entityCount .. " esp=" .. espCount .. " veh=" .. #S.vehicles .. " items=" .. #S.items .. " spawners=" .. #S.spawners)
end

-- 18. First run
if not S.initialized then
    S.initialized = true
    addNotif(CFG.SCRIPT_NAME .. " v" .. CFG.VERSION .. " geladen!", 5, CFG.C_SUCCESS)
    addNotif("Toggle: [F6]  |  5 Tabs  |  11 Aim Parts", 5)
    addNotif("Vehicle + Ammo + Spawner ESP im World-Tab", 5)
    print("[WARZONE] v" .. CFG.VERSION .. " erfolgreich geladen!")
    print("[WARZONE] Made by Lorthanyx")
    print("[WARZONE] Toggle: F6 | 5 Tabs | 11 Aim Parts")
    print("[WARZONE] ESP: Players, NPCs, Vehicles, Ammo, Spawner")
    print("")
end

