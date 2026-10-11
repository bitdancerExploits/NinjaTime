-- NINJA TIME v8.1 — dma.wtf
-- Native raid punches/moves, telegraph avoidance, and cached Kurama resolver.
-- Dynamic Zone Scanner (Training Dummies, NPC Spawns, Boss Arenas)
-- Master ScriptRunning Killswitch (Instantly breaks all threads & loops)
-- Keybind Killswitch: Press [END] or [DELETE] to instantly terminate & restore physics
-- Melee Reach (Behind-Target Lock) | God Mode | Virtual Input
-- ============================================

-----------------------------------------------
-- MASTER LIFECYCLE & STATE FLAGS
-----------------------------------------------
local ScriptRunning = true
local NinjaRuntime = {GameId = 3110388936, Executor = "Unknown", StateFile = "dma_wtf/NinjaTime/autoexecute.json"}
if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= NinjaRuntime.GameId then
    warn("[dma.wtf] Not Ninja Time; script was not started.")
    return
end
NinjaRuntime.Env = _G
if type(getgenv) == "function" then
    local ok, env = pcall(getgenv)
    if ok and type(env) == "table" then NinjaRuntime.Env = env end
end
do
    local identify = type(identifyexecutor) == "function" and identifyexecutor or getexecutorname
    if type(identify) == "function" then
        local ok, name, version = pcall(identify)
        if ok and type(name) == "string" then
            NinjaRuntime.Executor = name .. (type(version) == "string" and (" " .. version) or "")
        end
    end
    -- Feature detection takes precedence over an executor brand name.
    NinjaRuntime.QueueFunction = type(queue_on_teleport) == "function" and queue_on_teleport
        or type(queueonteleport) == "function" and queueonteleport
        or type(syn) == "table" and type(syn.queue_on_teleport) == "function" and syn.queue_on_teleport
        or type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" and fluxus.queue_on_teleport
        or nil
end

-----------------------------------------------
-- CREEP.CC UI — native controls, stable IDs, and synchronized engine settings
-----------------------------------------------
local function createNinjaTimeUI(Library)
    local ui = {Library = Library, Controls = {}, BoundControls = {}, ConfigSchema = {}, Destroyed = false, Syncing = false, Notifications = true}
    local bindings = {
        ["God Mode (Never Die / Full Immunity)"] = "GodMode",
        ["Touch Damage Nullifier (Blocks Hitboxes/AOE)"] = "TouchDamageNullifier",
        ["Death State & Ragdoll Bypass"] = "DeathStateBypass",
        ["Emergency Escape & Auto-Meditation"] = "EmergencyEscape",
        ["Emergency Escape HP Threshold (%)"] = "EscapeThreshold",
        ["Auto Farm Target"] = "AutoFarm",
        ["Only Target Currently ALIVE Mobs"] = "OnlyAliveMobs",
        ["LIVE MOBS (Currently Spawned)"] = "LiveTargetSelect",
        ["ALL MOBS DATABASE (Master List)"] = "TargetType",
        ["Custom Search Input"] = "CustomTargetInput",
        ["Attack Speed (Delay)"] = "AttackSpeed",
        ["Hover Distance / Height (Studs)"] = "FarmHeight",
        ["Auto Equip Weapon / Sword"] = "AutoEquipWeapon",
        ["Auto Cast Jutsu Skills & Moves"] = "AutoJutsu",
        ["Instant Kunai Spam"] = "KunaiSpam",
        ["Extend Enemy Hitbox Reach"] = "HitboxExtender",
        ["Hitbox Target Part"] = "HitboxTargetPart",
        ["Enemy Hitbox Size (Studs)"] = "HitboxSize",
        ["Hitbox Visual Style"] = "HitboxVisualMode",
        ["Fast Auto Puncher (M1 Click Spam)"] = "AutoPuncher",
        ["Punch Speed (Delay between M1s)"] = "PunchSpeed",
        ["Auto-Dodge Boss Jutsu / Attacks"] = "AutoDodge",
        ["Dodge Technique / Style"] = "DodgeMode",
        ["Dodge Evasion Distance"] = "DodgeDistance",
        ["Auto-Block Guard (Hold F while targeted)"] = "AutoBlock",
        ["Enable Auto Rebirth Loop"] = "AutoRebirthLoop",
        ["Raid Difficulty"] = "RebirthDifficulty",
        ["Stat Priority (points go here)"] = "RebirthStatPriority",
        ["Auto-Play Kurama Fight (dodge / heal / awaken)"] = "AutoPlayKuramaFight",
        ["Self-Heal Below HP (%)"] = "KuramaHealThreshold",
        ["Awaken Mode at Stacks"] = "KuramaModeStacks",
        ["Auto-Level 1 to Max Between Rebirths"] = "AutoLevelTo200",
        ["Persist Settings (resume after rejoin/hop)"] = "PersistSettings",
        ["Smart Auto Quest & DNA Boss Scanner"] = "AutoSmartQuestTracker",
        ["Auto Complete Dual Eyes Quests"] = "AutoDualEyesQuest",
        ["Auto Farm Dual Eyes (Sharingan/Rinnegan/Crimson)"] = "AutoDualEyesFarm",
        ["Select Target Spin Slot"] = "SelectedSlot",
        ["Target Clan / Sharingan / Family"] = "TargetClanRarity",
        ["Auto Spin Clan (Auto-Stops On Hit)"] = "AutoSpinClan",
        ["Target Element"] = "TargetElementRarity",
        ["Auto Spin Element (Auto-Stops On Hit)"] = "AutoSpinElement",
        ["Auto Spin Eye Abilities"] = "AutoSpinEye",
        ["Select Shukaku Variant"] = "QuizVariant",
        ["Auto-Answer Shukaku Quiz"] = "AutoShukakuQuiz",
        ["Infinite Chakra"] = "InfiniteChakra",
        ["Infinite Stamina"] = "InfiniteStamina",
        ["Auto Rinnegan Mode"] = "AutoRinnegan",
        ["Auto Tailed Beast (KCM / Shukaku)"] = "AutoTailedBeast",
        ["Auto Susanoo / Crimson Skeleton"] = "AutoSusanoo",
        ["Auto Evolve Sharingan (Tomoe)"] = "AutoTomoeEvolve",
        ["Infinite Mount Dash & Flight"] = "InfiniteMountDash",
        ["Bone Boss Spawn Detector"] = "BoneBossTracker",
        ["Auto Teleport When Bone Spawns"] = "AutoTeleportBone",
        ["Auto Raid Kurama"] = "AutoKuramaRaid",
        ["Raid Punches (M1)"] = "KuramaPunches",
        ["Raid Moves (Z / X / C / V)"] = "KuramaMoves",
        ["Avoid Kurama Attack Wind-ups"] = "KuramaAvoidAttacks",
        ["Kurama Melee Distance"] = "KuramaMeleeDistance",
        ["Kurama Retreat Distance"] = "KuramaDodgeRadius",
        ["Red Circle Safety Buffer"] = "KuramaCircleBuffer",
        ["Red Circle Recovery Delay"] = "KuramaCircleRecovery",
        ["Auto-Execute After Teleport (Ninja Time Only)"] = "AutoExecute",
        ["Auto-Execute Script File or HTTPS URL"] = "AutoExecuteSource",
        ["Kurama Hover Height"] = "KuramaHeight",
        ["Auto Collect Raid Chests & Loot"] = "AutoCollectRaidLoot",
        ["Auto Enter Raid Gate / Portal"] = "AutoEnterRaidGate",
        ["Auto Win Raven Raid"] = "AutoRavenRaid",
        ["Auto Pass Written & Chunin Exams"] = "AutoExams",
        ["Auto-Win Balancing Minigame"] = "AutoBalancing",
        ["Auto-Win Chakra Charge Minigame"] = "AutoChakraMinigame",
        ["Auto Unlock Skill Tree"] = "AutoSkillTree",
        ["Auto Rank Up Ninja Rank"] = "AutoRankUp",
        ["Auto Meditate"] = "AutoMeditate",
        ["Auto Train Mastery"] = "AutoMastery",
        ["Select Landmark / Zone"] = "SelectedTeleport",
        ["Select NPC"] = "SelectedNPCTp",
        ["Auto Level Quest Engine (Level-Based NPC + Farm Sync)"] = "AutoLevelQuest",
        ["Auto Accept & Complete Quests"] = "AutoQuests",
        ["Auto Claim Daily Rewards"] = "AutoClaimDailies",
        ["Auto Allocate Stats"] = "AutoAllocateStats",
        ["Noclip"] = "Noclip",
        ["Speed Boost"] = "SpeedBoost",
        ["WalkSpeed"] = "SpeedValue",
        ["Jump Boost"] = "JumpBoost",
        ["JumpPower"] = "JumpValue",
        ["Mob & Boss ESP"] = "MobESP",
        ["NPC ESP"] = "NPCESP",
        ["Anti-AFK (Random inputs every 4 min)"] = "AntiAFK",
        ["Smart Mob Relocator (TP to spawn if no mobs 10s)"] = "SmartRelocator",
        ["Auto Server Hop (no mobs for 30s)"] = "AutoServerHop",
        ["Auto Chest / Drop Collector"] = "AutoChestCollect",
        ["Auto Training Room (Attack Dummies — Mastery Grind)"] = "AutoTrainingRoom",
        ["Stat Priority"] = "StatPriority",
        ["Boss Spawn Notifier (Notify when boss appears)"] = "BossNotifier",
        ["Auto-TP to Boss on Spawn"] = "AutoTPOnBossSpawn",
        ["Active Features / Keybinds List HUD"] = "ShowActiveFeaturesHUD",
        ["Farm Stats HUD (Level / Target / Kills / K/min)"] = "ShowFarmHUD",
        ["Quest Progress HUD (Active quest + kill count)"] = "ShowQuestHUD",
    }
    local shortNames = {
        ["Kurama Hover Height"] = "Retreat height (not melee height)",
        ["God Mode (Never Die / Full Immunity)"] = "Client survivability",
        ["Touch Damage Nullifier (Blocks Hitboxes/AOE)"] = "Disable character touch",
        ["Emergency Escape & Auto-Meditation"] = "Emergency escape / charge",
        ["Emergency Escape HP Threshold (%)"] = "Escape below HP (%)",
        ["Only Target Currently ALIVE Mobs"] = "Alive targets only",
        ["LIVE MOBS (Currently Spawned)"] = "Live target",
        ["ALL MOBS DATABASE (Master List)"] = "Target database",
        ["Hover Distance / Height (Studs)"] = "Farm hover height",
        ["Auto-Play Kurama Fight (dodge / heal / awaken)"] = "Kurama fight AI",
        ["Auto-Level 1 to Max Between Rebirths"] = "Auto-level between rebirths",
        ["Persist Settings (resume after rejoin/hop)"] = "Auto-save active config",
        ["Auto Farm Dual Eyes (Sharingan/Rinnegan/Crimson)"] = "Farm eye progression",
        ["Auto Level Quest Engine (Level-Based NPC + Farm Sync)"] = "Level quest automation",
        ["Auto Training Room (Attack Dummies — Mastery Grind)"] = "Training room / mastery",
        ["Smart Mob Relocator (TP to spawn if no mobs 10s)"] = "Relocate when targets vanish",
        ["Auto-Block Guard (Hold F while targeted)"] = "Auto-block",
        ["Boss Spawn Notifier (Notify when boss appears)"] = "Boss spawn notifications",
        ["Farm Stats HUD (Level / Target / Kills / K/min)"] = "Farm statistics HUD",
        ["Quest Progress HUD (Active quest + kill count)"] = "Quest progress HUD",
    }
    local headerTitles = {
        ["Auto Farm Target Engine"] = "Targeting & Survival",
        ["Abilities & Combat Engine"] = "Weapons & Abilities",
        ["Jutsu Defense & Auto-Dodge"] = "Defense & Dodge",
        ["Kurama Lair EXP Cycle (Auto Rebirth)"] = "Rebirth Cycle",
        ["Auto-Fight AI & Auto-Level"] = "Fight AI & Levelling",
        ["Dual Eyes & Tenseigan Awakening Engine"] = "Eye Progression",
        ["Main Menu Slot Auto Spinner"] = "Slots & Spin Tracking",
        ["Nine-Tails (Kurama) Raid Automation"] = "Kurama Raid",
        ["Ninja Exams & Minigames"] = "Exams & Minigames",
        ["Smart Zone & Arena Teleports"] = "Zones & Arenas",
        ["NPC & Mentor Teleports"] = "NPCs & Mentors",
        ["Movement Hacks"] = "Movement",
        ["Auto-Execute On Join (Ninja Time)"] = "Auto-Execute",
    }
    function ui:SetAccent(name)
        local colors = {
            Ocean = Color3.fromRGB(91, 164, 255), Violet = Color3.fromRGB(174, 132, 255),
            Ember = Color3.fromRGB(255, 151, 87), Mint = Color3.fromRGB(93, 219, 167),
        }
        self.Accent = colors[name] and name or "Ocean"
        Library.AccentColor = colors[self.Accent]
        Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
        Library:UpdateColorsUsingRegistry()
    end
    Library.MainColor = Color3.fromRGB(22, 25, 33)
    Library.BackgroundColor = Color3.fromRGB(15, 18, 25)
    Library.OutlineColor = Color3.fromRGB(43, 49, 64)
    Library.FontColor = Color3.fromRGB(232, 238, 248)
    Library.NotifyOnError = true
    Library.ToggleKeybind = "RightControl"
    ui:SetAccent("Ocean")
    ui.NativeWindow = Library:CreateWindow({
        Title = "dma.wtf  /  NINJA TIME  /  v8.1",
        Size = UDim2.fromOffset(760, 640), Center = true, AutoShow = false,
        TabPadding = 6, MenuFadeTime = 0.15, UseBlur = false, UseDarken = false,
    })
    Library.ScreenGui.Name = "NinjaTime_dmaUI"
    Library.ScreenGui.ResetOnSpawn = false
    Library.KeybindFrame.Visible = false
    Library:SetWatermarkVisibility(false)

    function ui:Notify(info)
        if self.Destroyed or not self.Notifications then return end
        local text = type(info) == "table" and ((info.Title or "Ninja Time") .. ": " .. (info.Description or "")) or tostring(info)
        Library:Notify(text:gsub("\n", " "), type(info) == "table" and (info.Lifetime or 5) or 5)
    end
    function ui:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        Library.Toggled = false
        Library:Unload()
    end
    function ui:Callback(callback)
        return function(...)
            if self.Destroyed or self.Syncing or not ScriptRunning or not callback then return end
            local ok, err = pcall(callback, ...)
            if not ok then
                self.LastError = tostring(err)
                warn("[Ninja Time UI] " .. self.LastError)
                self:Notify({Title = "Control error", Description = self.LastError, Lifetime = 6})
            end
        end
    end
    local function configValue(key, value)
        if key == "SelectedSlot" and value ~= nil then return "Slot " .. tostring(value) end
        return value
    end
    function ui:SyncConfig()
        if not self.Config or self.Destroyed then return end
        self.Syncing = true
        for key, control in pairs(self.BoundControls) do
            local value = configValue(key, self.Config[key])
            if value ~= nil and control.Value ~= value then
                -- A streamed target need not have existed when the dropdown was constructed.
                if control.Type == "Dropdown" and (key == "TargetType" or key == "LiveTargetSelect")
                    and not table.find(control.Values, value) then
                    local values = table.clone(control.Values)
                    table.insert(values, value)
                    control:SetValues(values)
                end
                local ok, err = pcall(control.SetValue, control, value)
                if not ok then warn("[Ninja Time UI] Sync " .. key .. ": " .. tostring(err)) end
            end
        end
        self.Syncing = false
    end
    function ui:Section(tab, side, id)
        local section = {Tab = tab, Side = side, Id = id, GroupCount = 0}
        local function group()
            if not section.Group then section:Header({Name = id}) end
            return section.Group
        end
        local function text(info) return shortNames[info.Name] or info.Name end
        local function default(info)
            local key = bindings[info.Name]
            if key and ui.Config and ui.Config[key] ~= nil then return configValue(key, ui.Config[key]) end
            return info.Default
        end
        local function register(info, control)
            local key = bindings[info.Name]
            local idx = "NT_" .. (key or (id .. "_" .. info.Name:gsub("[^%w]", "_")))
            assert(not ui.Controls[idx], "Duplicate control ID: " .. idx)
            ui.Controls[idx] = control
            if key then ui.BoundControls[key] = control; ui.ConfigSchema[key] = info end
            return control
        end
        local function idx(info) return "NT_" .. (bindings[info.Name] or (id .. "_" .. info.Name:gsub("[^%w]", "_"))) end
        function section:Header(info)
            local title = info.Title or headerTitles[info.Name] or info.Name
            self.Group = side == "Left" and tab:AddLeftGroupbox(title) or tab:AddRightGroupbox(title)
            self.GroupCount += 1
            -- Keep the Kurama controls above the longer rebirth setup, without reordering engine code.
            local priorities = {RaidsLeft = 0, RebirthLeft = 10, RebirthRight = 0, RaidsRight = 10}
            if self.Group.Container then
                self.Group.Container.Parent.Parent.LayoutOrder = (priorities[id] or 0) + self.GroupCount
            end
            return self.Group
        end
        function section:Divider() group():AddBlank(6) end
        function section:Label(info) return group():AddLabel(info.Text or info.Name, info.Wrap ~= false) end
        function section:Button(info)
            return group():AddButton({Text = text(info), Tooltip = info.Tooltip or info.Name, Func = ui:Callback(info.Callback)})
        end
        function section:Toggle(info)
            return register(info, group():AddToggle(idx(info), {
                Text = text(info), Default = default(info), Tooltip = info.Tooltip or info.Name,
                Callback = ui:Callback(info.Callback),
            }))
        end
        function section:Slider(info)
            return register(info, group():AddSlider(idx(info), {
                Text = text(info), Default = default(info), Min = info.Minimum, Max = info.Maximum,
                Rounding = info.Precision or 0, Tooltip = info.Tooltip or info.Name,
                Callback = ui:Callback(info.Callback),
            }))
        end
        function section:Dropdown(info)
            local value = default(info)
            if not table.find(info.Options, value) then value = info.Default or info.Options[1] end
            return register(info, group():AddDropdown(idx(info), {
                Text = text(info), Values = info.Options, Default = value, Multi = info.Multi or false,
                AllowNull = false, Tooltip = info.Tooltip or info.Name,
                Callback = ui:Callback(function(v) if v ~= nil and info.Callback then info.Callback(v) end end),
            }))
        end
        function section:Input(info)
            return register(info, group():AddInput(idx(info), {
                Text = text(info), Default = default(info) or "", Placeholder = info.Placeholder,
                Finished = false, MaxLength = 160, Callback = ui:Callback(info.Callback),
            }))
        end
        return section
    end
    return ui
end

local Window
do
    -- Pin the reviewed API instead of silently following upstream breaking changes.
    local url = "https://raw.githubusercontent.com/visnoukkk/Creep.cc/c750ab041bf05ac04139cdc43869fa97f53a2bd3/Source.lua"
    local ok, library = pcall(function()
        local loader, err = loadstring(game:HttpGet(url))
        assert(loader, "dma.wtf UI compile error: " .. tostring(err))
        return loader()
    end)
    assert(ok and type(library) == "table", "Unable to load dma.wtf UI: " .. tostring(library))
    Window = createNinjaTimeUI(library)
end

-----------------------------------------------
-- SERVICES & LOCAL PLAYER
-----------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local WS = game:GetService("Workspace")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local Connections = {}
local startTick = tick()

-- Forward declarations (assigned later; UI callbacks capture these locals)
local isModelAlive, findKurama, startAutoKuramaRaid, getPlayerLevel
local KuramaCombat = {}
-- m1Tick must be declared here: the Kurama engine (defined earlier than the farm
-- engine) references it, and a later 'local' would leave it as a nil global there.
local m1Tick = 0
local killCount, sessionStart, farmLastTarget = 0, tick(), nil
local notifiedBosses = {}
local lastModePress = 0
local lastAutoQuestAccept = 0
local lastEyeQuestAccept = 0

-----------------------------------------------
-- LOCATE REMOTES FROM DATA DUMP
-----------------------------------------------
-- FIX: old resolver ran FindFirstChild once before RS replicated -> every remote was nil.
-- Now waits for replication (up to 20s) before resolving.
local function resolveBridges()
    local modules = RS:FindFirstChild("Modules")
    if not modules then return nil end
    local services = modules:FindFirstChild("Services")
    if not services then return nil end
    local rnet = services:FindFirstChild("RNet")
    if not rnet then return nil end
    return rnet:FindFirstChild("Bridges")
end
local Bridges = resolveBridges()
do
    local t0 = os.clock()
    while not Bridges and os.clock() - t0 < 20 do
        task.wait(0.25)
        Bridges = resolveBridges()
    end
end

local Remotes = {}
local function findRemote(name)
    local found
    local attempts = Bridges and 5 or 1
    for _ = 1, attempts do
        if Bridges then
            found = Bridges:FindFirstChild(name)
            if not found then
                -- Fuzzy match: ignore _Event/_Function suffix differences
                local want = name:lower():gsub("_event$", ""):gsub("_function$", "")
                for _, child in ipairs(Bridges:GetChildren()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        local cn = child.Name:lower()
                        local base = cn:gsub("_event$", ""):gsub("_function$", "")
                        if cn == name:lower() or base == want then
                            found = child
                            break
                        end
                    end
                end
            end
        end
        if not found then
            found = RS:FindFirstChild(name, true)
            if found and not (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then found = nil end
        end
        if found then break end
        task.wait(0.2)
    end
    return found
end

-- Core Combat & Abilities — VERIFIED bridge names from decompiled game source
Remotes.CombatEvent = findRemote("CombatEvent_Event")
Remotes.WeaponEvent = findRemote("WeaponEvent_Event")
Remotes.AbilityEvent = findRemote("AbilityEvent_Event")
Remotes.AbilityFunction = findRemote("AbilityFunction_Function") or findRemote("AbilityFunction_Event")
Remotes.KunaiHit = findRemote("KunaiHit_Event")
Remotes.TomoeEvent = findRemote("TomoeEvent_Event")

-- Dialogue, quests, shops (verified)
Remotes.DialogueEvent = findRemote("DialogueEvent_Event")
Remotes.QuestEvent = findRemote("QuestEvent_Event")
Remotes.ShopService = findRemote("ShopServiceRemote_Event") or findRemote("ShopServiceRemote_Function")
Remotes.CraftingService = findRemote("CraftingServiceRemote_Event") or findRemote("CraftingServiceRemote_Function")
Remotes.BagSwitch = findRemote("BagSwitch_Function") or findRemote("BagSwitch_Event")

-- Meditation, training & stats (verified)
Remotes.MeditationEvent = findRemote("MeditationEvent_Event")
Remotes.TrainingEvent = findRemote("TrainingEvent_Event")
Remotes.AttributesRemote = findRemote("AttributesRemote_Function") or findRemote("AttributesRemote_Event")
Remotes.SkillTree = findRemote("SkillTreeRemote_Function") or findRemote("SkillTreeRemote_Event")
Remotes.NinjaRank = findRemote("NinjaRankServiceRemote_Event") or findRemote("NinjaRankServiceRemote_Function")

-- Codes & rewards (verified)
Remotes.CodeRemote = findRemote("CodeRemote_Function") or findRemote("CodeRemote_Event")
Remotes.DailyQuestsRemote = findRemote("DailyQuestsRemote_Event")
Remotes.DailyFunction = findRemote("DailyFunction_Function") or findRemote("DailyFunction_Event")
Remotes.CollectFunction = findRemote("CollectFunction_Event")
Remotes.ChakraMinigame = findRemote("ChakraMinigame_Event") or findRemote("ChakraMinigame_Function")
Remotes.BalancingMinigame = findRemote("BalancingMinigame_Event")
Remotes.ExamSend = findRemote("ExamSend_Event")

-- Raids, prestige & mounts (verified)
-- NOTE: the game's Extra.Remotes wrapper names its instances "RemoteEvent_<Name>"/"RemoteFunction_<Name>"
Remotes.RaidState = findRemote("RemoteEvent_RaidState") or findRemote("RaidState_Event")
Remotes.RaidKurama = findRemote("RemoteEvent_RaidKurama") or findRemote("RaidKurama_Event")
Remotes.RaidStartVote = findRemote("RemoteEvent_RaidStartVote") or findRemote("RaidStartVote_Event")
Remotes.RaidRetryVote = findRemote("RemoteEvent_RaidRetryVote") or findRemote("RaidRetryVote_Event")
Remotes.PrestigeConfirm = findRemote("PrestigeConfirmRemote_Event")
Remotes.AwakeningSkipSelect = findRemote("RemoteEvent_AwakeningSkipSelect")
Remotes.ToadMountDash = findRemote("ToadMountDashRemote_Event")
Remotes.ToadMountJump = findRemote("ToadMountJumpRemote_Event")
Remotes.GameplayEvent = findRemote("GameplayEvent_Event")

-- NOTE: "ClanSpin"/"ElementSpin"/"EyeSpin" remotes do NOT exist in this game.
-- Spins are tokens (ClanSpins/ElementSpins/FamilySpins) consumed through the Bag gacha UI.
Remotes.ClanSpin, Remotes.ElementSpin, Remotes.EyeSpin = nil, nil, nil
-- NOTE: stamina is a client-side NumberTime value; there is no IncrementStamina remote.
Remotes.IncrementStamina = nil

-- Shared game modules (the game itself exposes these to the client — safe to require)
local Shared = {}
do
    pcall(function()
        Shared.ReplicatedData = require(RS:WaitForChild("Core", 20):WaitForChild("ReplicatedData", 20))
    end)
    pcall(function()
        Shared.Prestige = require(RS:WaitForChild("Modules", 15).Definitions:WaitForChild("Prestige", 15))
    end)
    pcall(function()
        Shared.RaidLobby = require(RS:WaitForChild("Modules", 15).Services:WaitForChild("RaidLobby", 15))
    end)
    pcall(function()
        Shared.RaidConfigs = require(RS:WaitForChild("Modules", 15).Data.Raids:WaitForChild("RaidConfigurations", 15))
    end)
    pcall(function()
        Shared.Settings = require(RS:WaitForChild("Modules", 15).Definitions:WaitForChild("Settings", 15))
    end)
    pcall(function()
        Shared.AbilityConfig = require(RS:WaitForChild("Modules", 15).Definitions:WaitForChild("AbilityConfig", 15))
    end)
end

-- Forward declarations for the rebirth engine (UI callbacks below capture these)
local getRebirthBlockers, isRebirthEligible, confirmPrestige, requestKuramaLobby, runRebirthLoop

task.spawn(function()
    task.wait(3)
    if not ScriptRunning then return end
    local okList, missList = {}, {}
    for key, remote in pairs(Remotes) do
        if remote then table.insert(okList, key) else table.insert(missList, key) end
    end
    table.sort(okList)
    table.sort(missList)
    print(("[dma.wtf / Ninja Time v8.1] Remotes OK (%d): %s | Missing (%d): %s"):format(
        #okList, table.concat(okList, ", "), #missList, table.concat(missList, ", ")))
    if #missList > 0 then
        Window:Notify({ Title = "Remote Resolver", Description = #okList .. " remotes loaded, " .. #missList .. " missing: " .. table.concat(missList, ", "), Lifetime = 8 })
    end
    local sharedOk = {}
    for k, v in pairs(Shared) do
        if v then table.insert(sharedOk, k) end
    end
    table.sort(sharedOk)
    print("[dma.wtf / Ninja Time v8.1] Shared modules loaded: " .. table.concat(sharedOk, ", "))
end)

-----------------------------------------------
-- MASTER MOBS DATABASE
-----------------------------------------------
local MasterMobsList = {
    "All Mobs",
    "Dual Eyes (Sharingan/Rinnegan/Crimson)",
    "Monster of Sand (Yin/Yang Farm)",
    "Bosses Only",
    "Bone (Global Boss)",
    "Shukaku", "Kurama (Raid Boss)", "Koroma", "Immortal", "One-Tailed Hero", "Chief Toad",
    "Azure Blade Ninja", "Wind Blade Ninja", "Four Symbol's Leader", "Gold Dust Ninja",
    "Wind Fan Expert", "Young Puppeteer", "Sand Ninja", "Desert's Scorch",
    "Ankokuji Traitor", "Log", "Attack Dummy", "Black Flames", "Bone", "Bug",
    "Chunin Ninja of Earth", "Chunin Ninja of Fire", "Chunin Ninja of Lightning", "Chunin Ninja of Water", "Chunin Ninja of Wind",
    "Copycat", "Curse Mark Black Flames", "Damage TestDummy", "Demon Brother Left", "Demon Brother Right",
    "Elite Jonin", "Fast Hands", "Flower Member", "Fly-trap", "Gamer Prodigy",
    "Hammerhand", "Harukimao", "Healer Member", "Hidden Gas Demon", "High Muty",
    "Icy", "InfDungeon", "Ivy", "Jinchiruki of Shukaku", "Jonin Ninja of Earth", "Jonin Ninja of Fire",
    "Jonin Ninja of Lightning", "Jonin Ninja of Water", "Jonin Ninja of Wind", "Kojaku", "KoromaOld",
    "Leaf Renegate", "Medium Ninja of Earth", "Meteor", "Mugetsu", "Ninja Guard", "Ninja",
    "PlayerClone", "Prodigy", "Rakura", "Raven", "RavenSpirit", "Red Eyes Friend", "Red Eyes Member", "Renegate Ninja",
    "Sand Beast", "Scarecrow", "Scarecrow Heart Four", "Scarecrow Heart One", "Scarecrow Heart Three", "Scarecrow Heart Two",
    "Shadow Anbu", "Shadow Member", "Silver Storm", "Skill Dummy", "Snake", "Sora", "Sound Brother", "Sound Brother 2", "Sound Brother 3",
    "Special Sound Ninja of Earth", "Special Sound Ninja of Fire", "Special Sound Ninja of Lightning", "Special Sound Ninja of Water", "Special Sound Ninja of Wind",
    "Stone Leo", "Stone Leo [Chunin]", "Test Dummy", "Test Dummy 2", "Test Dummy 3", "Thousand Hands",
    "Traitor", "VanishClone", "Weak Ninja Sound", "Weak Ninja of Earth", "Weak Ninja of Fire", "Weak Ninja of Lightning",
    "Weak Ninja of Water", "Weak Ninja of Wind", "White Clone", "White Eyed Sinner", "White Eyes Adept", "White Eyes",
    "Yellow Thunder", "Yuhi", "Crimson Puppet Master", "Reihaku", "Shinjuroku", "Ten Hikari", "Yugatsura"
}

-----------------------------------------------
-- CONFIG STATE
-----------------------------------------------
local Config = {
    -- Combat & Defense
    GodMode = true,
    TouchDamageNullifier = true,
    DeathStateBypass = true,
    EmergencyEscape = true,
    EscapeThreshold = 35,
    AutoFarm = false,
    AttackSpeed = 0.15,
    FarmHeight = 3,
    TargetType = "All Mobs",
    LiveTargetSelect = "All Live Mobs",
    CustomTargetInput = "",
    OnlyAliveMobs = true,
    AutoJutsu = true,
    KunaiSpam = true,
    AutoEquipWeapon = true,
    HitboxExtender = true,
    HitboxTargetPart = "Head", -- "Head", "HumanoidRootPart", "All Limbs"
    HitboxSize = 20,
    HitboxVisualMode = "Normal (Invisible Box)", -- "Normal (Invisible Box)", "Visible Ghost (0.8)", "Solid"
    HitboxTransparency = 1,
    AutoPuncher = true,
    PunchSpeed = 0.08,
    
    -- Auto-Dodge & Sharingan / Kawarimi Defense
    AutoDodge = true,
    DodgeMode = "Sharingan / Orbit Glide", -- "Sharingan / Orbit Glide", "Kawarimi Teleport", "Block / Guard", "Sky Float"
    DodgeDistance = 15,
    AutoBlock = true,
    
    -- Dual Eyes & Quests
    AutoDualEyesQuest = false,
    AutoSmartQuestTracker = false,
    AutoDualEyesFarm = false,

    -- Auto Spinner & Slot Selection
    AutoSpinClan = false,
    AutoSpinElement = false,
    AutoSpinEye = false,
    SelectedSlot = 1,
    TargetClanRarity = "Uchiha",
    TargetElementRarity = "Wood",

    -- Chakra & Special
    InfiniteChakra = false,
    InfiniteStamina = false,
    AutoTomoeEvolve = false,
    AutoRinnegan = false,
    AutoTailedBeast = false,
    AutoSusanoo = false,
    InfiniteMountDash = false,
    
    -- Shukaku Stage 2 & Sand
    AutoShukakuQuiz = false,
    QuizVariant = "Variant 1 (Offensive)",
    AutoBuySoulcast = false,
    
    -- Global Boss
    BoneBossTracker = true,
    AutoTeleportBone = false,
    
    -- Raids & Minigames
    AutoKuramaRaid = false,
    KuramaPunches = true,
    KuramaMoves = true,
    KuramaAvoidAttacks = true,
    KuramaMeleeDistance = 4,
    KuramaHeight = 18,
    AutoCollectRaidLoot = true,
    AutoEnterRaidGate = true,
    AutoRavenRaid = false,
    AutoExams = false,
    AutoBalancing = false,
    AutoChakraMinigame = false,
    
    -- Training & Skill Tree
    AutoMeditate = false,
    AutoMastery = false,
    AutoRankUp = false,
    AutoSkillTree = false,
    
    -- Quests & Stats
    AutoQuests = false,
    AutoLevelQuest = false,
    AutoClaimDailies = false,
    AutoAllocateStats = false,

    -- Auto Rebirth Loop (Kurama Lair EXP cycle)
    AutoRebirthLoop = false,
    RebirthDifficulty = "Normal",
    RebirthStatPriority = "Chackra",
    
    -- Movement & Visuals
    Noclip = false,
    SpeedBoost = false,
    SpeedValue = 32,
    JumpBoost = false,
    JumpValue = 100,
    MobESP = false,
    NPCESP = false,
    
    SelectedTeleport = "Training Ground (Attack Dummies)",
    SelectedNPCTp = "Isago",

    -- Anti-AFK
    AntiAFK = false,

    -- Boss Spawn Notifier
    BossNotifier = true,
    AutoTPOnBossSpawn = false,

    -- Smart Mob Relocator
    SmartRelocator = false,
    NoMobTimeout = 10, -- seconds before relocating

    -- Server Hop
    AutoServerHop = false,
    ServerHopNoMobTime = 30, -- seconds with no mobs before hop

    -- HUDs
    ShowFarmHUD = false,
    ShowQuestHUD = false,
    ShowActiveFeaturesHUD = true,

    -- Auto Chest / Drop Collector
    AutoChestCollect = false,

    -- Auto Training Room (attack dummies for mastery)
    AutoTrainingRoom = false,

    -- Smart Stat Priority
    StatPriority = "Ninjutsu",

    -- Auto-Play Kurama Fight AI (dodge patterns / self-heal / mode awakening)
    AutoPlayKuramaFight = false,
    KuramaHealThreshold = 40,   -- use a heal ability/tool below this HP %
    KuramaModeStacks = 5,       -- activate awakening when stacks reach this
    KuramaDodgeRadius = 160,    -- also clears the corners of the dumped 200x200 AoE box
    KuramaCircleBuffer = 24,   -- extra horizontal clearance beyond the marker/blast radius
    KuramaCircleRecovery = 2.5, -- keep removed circle locations unsafe through their impact
    KuramaOrbitSpeed = 2.5,     -- strafe speed (studs per tick) around Kurama

    -- Auto-Level (1 -> max) between rebirths
    AutoLevelTo200 = false,

    -- Settings persistence (writefile/readfile)
    PersistSettings = true,
    AutoExecute = false,
    AutoExecuteSource = "NinjaTime.lua",
}
Window.Config = Config

-----------------------------------------------
-- SETTINGS PERSISTENCE (writefile / readfile)
-- Full named feature/UI profiles; the older rebirth-only file is import-only.
-----------------------------------------------
local PERSIST_FILE = "NinjaTime_RebirthSettings.json"
local PersistKeys = {
    "AutoRebirthLoop", "RebirthDifficulty", "RebirthStatPriority",
    "AutoPlayKuramaFight", "KuramaHealThreshold", "KuramaModeStacks",
    "KuramaDodgeRadius", "KuramaOrbitSpeed",
    "KuramaPunches", "KuramaMoves", "KuramaAvoidAttacks", "KuramaMeleeDistance",
    "KuramaCircleBuffer", "KuramaCircleRecovery",
    "AutoLevelTo200", "AutoFarm", "PersistSettings",
}

-- Named, versioned profiles: only known primitive Config keys are accepted.
local ConfigStore = {Folder = "dma_wtf/NinjaTime/Configs", Selected = "Default", Defaults = table.clone(Config)}
function ConfigStore.Available()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end
function ConfigStore.Name(name)
    return type(name) == "string" and #name > 0 and #name <= 48 and name:match("^[%w_%-]+$") and name or nil
end
function ConfigStore.EnsureFolders()
    assert(ConfigStore.Available(), "Executor file access is unavailable")
    assert(type(makefolder) == "function" and type(isfolder) == "function", "Executor folder APIs are unavailable")
    for _, folder in ipairs({"dma_wtf", "dma_wtf/NinjaTime", ConfigStore.Folder}) do
        if not isfolder(folder) then makefolder(folder) end
    end
end
function ConfigStore.Read(file)
    assert(type(readfile) == "function" and type(isfile) == "function" and isfile(file), "File not found: " .. file)
    local decoded = game:GetService("HttpService"):JSONDecode(readfile(file))
    assert(type(decoded) == "table", "Invalid config document")
    return decoded
end
function ConfigStore.Validate(values)
    assert(type(values) == "table", "Invalid config values")
    local out = table.clone(ConfigStore.Defaults)
    for key, default in pairs(ConfigStore.Defaults) do
        local value = values[key]
        if value ~= nil then
            assert(type(value) == type(default), "Invalid type for " .. key)
            if type(value) == "number" then
                assert(value == value and math.abs(value) < 1e9, "Invalid number for " .. key)
                local schema = Window.ConfigSchema[key]
                if schema and schema.Minimum then value = math.clamp(value, schema.Minimum, schema.Maximum) end
                if key == "SelectedSlot" then
                    assert(value % 1 == 0 and value >= 1 and value <= 10, "Invalid slot")
                    if schema and schema.Options then assert(table.find(schema.Options, "Slot " .. value), "Invalid slot") end
                end
            elseif type(value) == "string" then
                assert(#value <= 2048, "Config string too long: " .. key)
                local schema = Window.ConfigSchema[key]
                if schema and schema.Options and key ~= "TargetType" and key ~= "LiveTargetSelect" then
                    assert(table.find(schema.Options, value), "Invalid option for " .. key)
                end
            end
            out[key] = value
        end
    end
    out.KuramaDodgeRadius = math.clamp(out.KuramaDodgeRadius, 150, 240)
    out.KuramaCircleBuffer = math.clamp(out.KuramaCircleBuffer, 12, 80)
    out.KuramaCircleRecovery = math.clamp(out.KuramaCircleRecovery, 1, 8)
    if NinjaRuntime.Source then NinjaRuntime.Source(out.AutoExecuteSource) end
    return out
end
function ConfigStore.Interface()
    return {Accent = Window.Accent or "Ocean", Notifications = Window.Notifications,
        Blur = Window.Library.UseBlur == true, Watermark = Window.ShowWatermark == true,
        MenuKey = Window.MenuKey and Window.MenuKey.Value or "RightControl"}
end
function ConfigStore.ApplyInterface(info)
    if type(info) ~= "table" then return end
    Window.Syncing = true
    if table.find({"Ocean", "Violet", "Ember", "Mint"}, info.Accent) then
        Window:SetAccent(info.Accent)
        if Window.InterfaceControls then Window.InterfaceControls.Accent:SetValue(info.Accent) end
    end
    if type(info.Notifications) == "boolean" then
        Window.Notifications = info.Notifications
        if Window.InterfaceControls then Window.InterfaceControls.Notifications:SetValue(info.Notifications) end
    end
    if type(info.Blur) == "boolean" then
        Window.Library.UseBlur = info.Blur
        Window.Library:UpdateBlur()
        if Window.InterfaceControls then Window.InterfaceControls.Blur:SetValue(info.Blur) end
    end
    if type(info.Watermark) == "boolean" then
        Window.ShowWatermark = info.Watermark
        if info.Watermark then Window.Library:SetWatermark("dma.wtf | Ninja Time | v8.1")
        else Window.Library:SetWatermarkVisibility(false) end
        if Window.InterfaceControls then Window.InterfaceControls.Watermark:SetValue(info.Watermark) end
    end
    if type(info.MenuKey) == "string" and info.MenuKey ~= "Unknown" and Window.MenuKey then
        local ok, key = pcall(function() return Enum.KeyCode[info.MenuKey] end)
        if ok and key then Window.MenuKey:SetValue({info.MenuKey, "Toggle"}) end
    end
    Window.Syncing = false
end
function ConfigStore.Apply(values, interface)
    local validated = ConfigStore.Validate(values) -- validate before changing any live state
    for key, value in pairs(validated) do Config[key] = value end
    Window:SyncConfig()
    ConfigStore.ApplyInterface(interface)
    if KuramaCombat.Stop and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) then KuramaCombat.Stop(true) end
    if hum and hum.Parent then
        hum.WalkSpeed = Config.SpeedBoost and Config.SpeedValue or 16
        hum.JumpPower = Config.JumpBoost and Config.JumpValue or 50
    end
    if NinjaRuntime.UpdateState then NinjaRuntime.UpdateState() end
end
function ConfigStore.Save(name)
    local ok, err = pcall(function()
        assert(ConfigStore.Name(name), "Use 1–48 letters, numbers, underscores or hyphens")
        ConfigStore.EnsureFolders()
        local http = game:GetService("HttpService")
        writefile(ConfigStore.Folder .. "/" .. name .. ".json", http:JSONEncode({Version = 1, GameId = NinjaRuntime.GameId,
            Config = ConfigStore.Validate(Config), Interface = ConfigStore.Interface()}))
        writefile("dma_wtf/NinjaTime/selected.json", http:JSONEncode({Profile = name}))
        ConfigStore.Selected = name
        ConfigStore.SuspendAutosave = false
    end)
    if not ok then Window.LastError = tostring(err) end
    return ok, err
end
function ConfigStore.Load(name)
    local ok, err = pcall(function()
        assert(ConfigStore.Name(name), "Invalid profile name")
        local document = ConfigStore.Read(ConfigStore.Folder .. "/" .. name .. ".json")
        assert(document.Version == 1 and document.GameId == NinjaRuntime.GameId, "Wrong game or unsupported config version")
        ConfigStore.Apply(document.Config, document.Interface)
        ConfigStore.Selected = name
        ConfigStore.SuspendAutosave = false
        if ConfigStore.Available() then
            ConfigStore.EnsureFolders()
            writefile("dma_wtf/NinjaTime/selected.json", game:GetService("HttpService"):JSONEncode({Profile = name}))
        end
    end)
    if not ok then Window.LastError = tostring(err); Window.Syncing = false end
    return ok, err
end
function ConfigStore.List()
    local names, seen = {"Default"}, {Default = true}
    if type(listfiles) == "function" then
        pcall(function()
            for _, file in ipairs(listfiles(ConfigStore.Folder)) do
                local name = file:gsub("\\", "/"):match("([^/]+)%.json$")
                if ConfigStore.Name(name) and not seen[name] then seen[name] = true; table.insert(names, name) end
            end
        end)
    end
    if not seen[ConfigStore.Selected] then table.insert(names, ConfigStore.Selected) end
    table.sort(names)
    return names
end
function ConfigStore.Delete(name)
    local ok, err = pcall(function()
        assert(ConfigStore.Name(name), "Invalid profile name")
        assert(type(delfile) == "function", "Executor cannot delete files")
        local file = ConfigStore.Folder .. "/" .. name .. ".json"
        assert(isfile(file), "Profile not found")
        delfile(file)
        if ConfigStore.Selected == name then
            ConfigStore.Selected = "Default"
            ConfigStore.SuspendAutosave = true -- do not recreate a deleted active profile on the next autosave
            if isfile("dma_wtf/NinjaTime/selected.json") then delfile("dma_wtf/NinjaTime/selected.json") end
        end
    end)
    return ok, err
end
local function canPersist() return ConfigStore.Available() end
local function saveSettings()
    if Config.PersistSettings and not ConfigStore.SuspendAutosave and canPersist() then return ConfigStore.Save(ConfigStore.Selected) end
    return false, "Automatic saving disabled or file APIs unavailable"
end
local function loadSettings()
    if not canPersist() then return false end
    local ok, selection = pcall(ConfigStore.Read, "dma_wtf/NinjaTime/selected.json")
    if ok and ConfigStore.Name(selection.Profile) then ConfigStore.Selected = selection.Profile end
    if isfile(ConfigStore.Folder .. "/" .. ConfigStore.Selected .. ".json") then return ConfigStore.Load(ConfigStore.Selected) end
    -- Import the old rebirth-only file without deleting or overwriting it.
    local legacyOk, legacy = pcall(ConfigStore.Read, PERSIST_FILE)
    if not legacyOk then return false end
    local values = {}
    for _, key in ipairs(PersistKeys) do values[key] = legacy[key] end
    local applied, err = pcall(ConfigStore.Apply, values)
    if not applied then Window.LastError = tostring(err) end
    return applied
end

function NinjaRuntime.Source(source)
    assert(type(source) == "string" and #source > 0 and #source <= 2048, "Set a script file or HTTPS URL first")
    if source:match("^https://[^%s]+$") then return "url", source end
    assert(not source:find("..", 1, true) and not source:find(":", 1, true) and not source:match("^[/\\]"), "Use a workspace-relative .lua file")
    assert(source:match("^[%w_/%-%. ]+%.lua$"), "Source must be a .lua file or HTTPS URL")
    return "file", source
end
function NinjaRuntime.Loader()
    local _, source = NinjaRuntime.Source(Config.AutoExecuteSource)
    return string.format([=[-- dma.wtf / Ninja Time auto-execute: universe-gated, opt-in, no duplicate hub.
if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= %d then return end
local env = type(getgenv) == "function" and getgenv() or _G
if env.DMA_NINJA_ACTIVE or env.DMA_NINJA_LOADING then return end
local ok, state = pcall(function()
    if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(%q) then return nil end
    return game:GetService("HttpService"):JSONDecode(readfile(%q))
end)
if not ok or type(state) ~= "table" or state.Enabled ~= true then return end
env.DMA_NINJA_LOADING = true
local ran, err = pcall(function()
    local source = state.Source or %q
    assert(type(source) == "string" and #source > 0 and #source <= 2048, "Invalid auto-execute source")
    local code
    if source:match("^https://[^%%s]+$") then code = game:HttpGet(source)
    else
        assert(not source:find("..", 1, true) and not source:find(":", 1, true) and not source:match("^[/\\]"), "Invalid script path")
        assert(source:match("^[%%w_/%%-%%. ]+%%.lua$"), "Invalid script path")
        assert(type(readfile) == "function" and isfile(source), "Copy the updated script into the executor workspace: " .. source)
        code = readfile(source)
    end
    local chunk, compileError = loadstring(code)
    assert(chunk, compileError)
    chunk()
end)
env.DMA_NINJA_LOADING = nil
if not ran then warn("[dma.wtf Auto-Execute] " .. tostring(err)) end
]=], NinjaRuntime.GameId, NinjaRuntime.StateFile, NinjaRuntime.StateFile, source)
end
function NinjaRuntime.UpdateState(disable)
    local ok, err = pcall(function()
        ConfigStore.EnsureFolders()
        if not disable and Config.AutoExecute then NinjaRuntime.Source(Config.AutoExecuteSource) end
        writefile(NinjaRuntime.StateFile, game:GetService("HttpService"):JSONEncode({Enabled = not disable and Config.AutoExecute == true,
            Source = Config.AutoExecuteSource}))
    end)
    return ok, err
end
function NinjaRuntime.Queue()
    if NinjaRuntime.Queued or not ScriptRunning or not Config.AutoExecute then return false, "Disabled or already queued" end
    if type(NinjaRuntime.QueueFunction) ~= "function" then return false, "Executor has no teleport queue API" end
    local ok, err = pcall(function()
        local kind, source = NinjaRuntime.Source(Config.AutoExecuteSource)
        if kind == "file" then assert(type(isfile) == "function" and isfile(source), "Copy NinjaTime.lua into the executor workspace first") end
        local written, reason = NinjaRuntime.UpdateState()
        assert(written, reason)
        NinjaRuntime.QueueFunction(NinjaRuntime.Loader())
        NinjaRuntime.Queued = true
    end)
    return ok, err
end

-- Character respawn handler: refresh refs (speeds re-apply)
local characterConn = plr.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
    task.wait(0.5)
    if ScriptRunning and Config.SpeedBoost then hum.WalkSpeed = Config.SpeedValue end
    if ScriptRunning and Config.JumpBoost then hum.JumpPower = Config.JumpValue end
end)
table.insert(Connections, characterConn)

-- Landmark & Zone Teleport Definitions (Extracted Directly From Game Modules)
local TeleportNames = {
    "Spawn Location",
    "Training Ground (Attack Dummies)",
    "Red Eyes Hideout (Red Eyes Leader)",
    "Red Eyes Stone (Uchiha)",
    "Red Eyes Ninja",
    "Danzu (Leaf Leader)",
    "Ankokuji Leader (Forest of Death)",
    "Forest of Death (Ankokuji Traitors)",
    "BlackSmith (Weapon Crafting)",
    "Ishikage (Stone Leader)",
    "One-Tailed Hero (Shukaku)",
    "Curse Mark Black Flames",
    "Mugetsu (Tenseigan Awakening Boss)",
    "Bone Boss Arena",
    "Yellow Thunder (Global Boss - 150k HP)",
    "Meteor (Global Boss - 250k HP)",
    "Thousand Hands",
    "Silver Storm",
    "Hidden Gas Demon",
    "Immortal",
    "Scarecrow",
    "Snake Boss",
    "Aruka (Starter Quests)",
    "Stone Leo",
    "High Muty",
    "Chiraku",
    "Power",
    "Raven",
    "Tazune",
    "Farm Rob",
    "Soul",
    "Yuhi",
    "Ibiqui (Chunin Exam Room)",
    "Written Test Paper",
    "Enter Classroom",
    "Leave Classroom",
    "Mansion Entrance",
    "Mansion Exit",
    "Rift Walker"
}

local FallbackTeleports = {
    ["Spawn Location"] = Vector3.new(1081.9, 9.0, -1303.8),
    ["Training Ground (Attack Dummies)"] = Vector3.new(1105.2, 10.5, -1261.8),
    ["Red Eyes Hideout (Red Eyes Leader)"] = Vector3.new(-1767.7, 72.0, 2499.3),
    ["Red Eyes Stone (Uchiha)"] = Vector3.new(-1737.1, 18.0, 2526.4),
    ["Red Eyes Ninja"] = Vector3.new(-1663.0, 12.0, 1357.6),
    ["Danzu (Leaf Leader)"] = Vector3.new(2266.9, 410.0, -506.6),
    ["Ankokuji Leader (Forest of Death)"] = Vector3.new(-5449.7, -134.0, -2031.8),
    ["Forest of Death (Ankokuji Traitors)"] = Vector3.new(-1498.0, 12.0, -2480.0),
    ["BlackSmith (Weapon Crafting)"] = Vector3.new(699.1, 47.0, -658.2),
    ["Ishikage (Stone Leader)"] = Vector3.new(1358.2, 134.0, -120.6),
    ["One-Tailed Hero (Shukaku)"] = Vector3.new(5346.1, 221.0, -236.3),
    ["Curse Mark Black Flames"] = Vector3.new(5304.4, 221.0, -1118.6),
    ["Mugetsu (Tenseigan Awakening Boss)"] = Vector3.new(1134.0, 180.0, -3640.7),
    ["Bone Boss Arena"] = Vector3.new(2387.3, 15.0, 4257.3),
    ["Yellow Thunder (Global Boss - 150k HP)"] = Vector3.new(-5204.0, 14.0, 3007.8),
    ["Meteor (Global Boss - 250k HP)"] = Vector3.new(6702.7, 912.0, -655.9),
    ["Thousand Hands"] = Vector3.new(6702.6, 910.0, -448.4),
    ["Silver Storm"] = Vector3.new(7151.2, 910.0, -560.1),
    ["Hidden Gas Demon"] = Vector3.new(-7229.3, 14.0, 5876.4),
    ["Immortal"] = Vector3.new(1096.5, 12.0, 2493.9),
    ["Scarecrow"] = Vector3.new(557.9, 15.0, 4084.5),
    ["Snake Boss"] = Vector3.new(8552.3, 871.0, -3838.6),
    ["Aruka (Starter Quests)"] = Vector3.new(1134.7, 12.0, -1204.9),
    ["Stone Leo"] = Vector3.new(994.7, 12.0, -1292.3),
    ["High Muty"] = Vector3.new(1023.0, 10.0, -1206.6),
    ["Chiraku"] = Vector3.new(221.7, 47.0, -158.6),
    ["Power"] = Vector3.new(180.7, 10.0, -692.5),
    ["Raven"] = Vector3.new(11.0, 43.0, -2925.8),
    ["Tazune"] = Vector3.new(-5626.2, 13.0, 5244.4),
    ["Farm Rob"] = Vector3.new(-1989.2, 12.0, 1737.2),
    ["Soul"] = Vector3.new(470.6, 47.0, 1303.4),
    ["Yuhi"] = Vector3.new(852.1, 54.0, 1246.2),
    ["Ibiqui (Chunin Exam Room)"] = Vector3.new(3874.8, -230.0, -7901.6),
    ["Written Test Paper"] = Vector3.new(3872.8, -230.0, -7904.9),
    ["Enter Classroom"] = Vector3.new(1221.7, 13.0, -1293.5),
    ["Leave Classroom"] = Vector3.new(3839.8, -229.0, -7909.0),
    ["Mansion Entrance"] = Vector3.new(1505.8, 53.0, -783.5),
    ["Mansion Exit"] = Vector3.new(1489.5, -106.0, -788.5),
    ["Rift Walker"] = Vector3.new(-2470.8, 61.0, 2681.8),
    ["Isago (Scroll Merchant)"] = Vector3.new(1370.0, 9.5, -1580.0),
    ["Monster of Sand"] = Vector3.new(5350.0, 215.0, -600.0)
}

local NPCFallbacks = {
    ["Red Eyes Leader"] = Vector3.new(-1767.7, 72.0, 2499.3),
    ["Danzu"] = Vector3.new(2266.9, 410.0, -506.6),
    ["Aruka"] = Vector3.new(1134.7, 12.0, -1204.9),
    ["Stone Leo"] = Vector3.new(994.7, 12.0, -1292.3),
    ["High Muty"] = Vector3.new(1023.0, 10.0, -1206.6),
    ["BlackSmith"] = Vector3.new(699.1, 47.0, -658.2),
    ["Chiraku"] = Vector3.new(221.7, 47.0, -158.6),
    ["Power"] = Vector3.new(180.7, 10.0, -692.5),
    ["Ishikage"] = Vector3.new(1358.2, 134.0, -120.6),
    ["Raven"] = Vector3.new(11.0, 43.0, -2925.8),
    ["Ibiqui"] = Vector3.new(3874.8, -230.0, -7901.6),
    ["Tazune"] = Vector3.new(-5626.2, 13.0, 5244.4),
    ["Farm Rob"] = Vector3.new(-1989.2, 12.0, 1737.2),
    ["Soul"] = Vector3.new(470.6, 47.0, 1303.4),
    ["Yuhi"] = Vector3.new(852.1, 54.0, 1246.2),
    ["Kaba"] = Vector3.new(1101.3, 10.0, -1549.8),
    ["Mei Kagaku"] = Vector3.new(6360.9, 232.0, 213.9),
    ["Shugetsu"] = Vector3.new(-3716.0, 11.0, 4966.6),
    ["Ekisu"] = Vector3.new(-4709.3, 11.0, 1601.7),
    ["Toketsu"] = Vector3.new(-681.9, 12.0, 4350.8),
    ["Nora"] = Vector3.new(7886.3, 870.0, -3455.2),
    ["Yamako"] = Vector3.new(4244.1, 873.0, -2449.7),
    ["Izuko"] = Vector3.new(278.3, 141.0, -2711.3),
    ["Nero"] = Vector3.new(883.8, 159.0, -3868.7),
    ["Euphor"] = Vector3.new(6395.1, 232.0, 194.2),
    ["Isago"] = Vector3.new(1370.0, 9.5, -1580.0)
}

local NPCNames = {
    "Red Eyes Leader", "Danzu", "Aruka", "Stone Leo", "High Muty", "BlackSmith", 
    "Chiraku", "Power", "Ishikage", "Raven", "Ibiqui", "Tazune", "Farm Rob", 
    "Soul", "Yuhi", "Kaba", "Mei Kagaku", "Shugetsu", "Ekisu", "Toketsu", 
    "Nora", "Yamako", "Izuko", "Nero", "Euphor", "Isago"
}

local NinjaCodes = {
    "STFIX", "MOREMOBILESFIX", "DATARECONCILE", "ILOVEMOBILES", "MOBILEMOUNTS",
    "MORENPCFIXES", "BYTE1K", "BYTE2K", "10M", "8M", "9M", "MAYBEPERFORMANCE",
    "12MVISITS", "SORRYFORTERRAIN", "NINJATIME", "RELEASE", "50KLIKES", "100KLIKES",
    "SHINOBI", "CHAKRA", "UPDATE", "FREEEXP", "BOOST", "WELCOME"
}

-----------------------------------------------
-- BODYVELOCITY / BODYGYRO PHYSICAL ANCHOR ENGINE
-----------------------------------------------
local bodyVelocity, bodyGyro

local function ensureAnchor()
    if not ScriptRunning or not hrp then return end
    
    if not bodyVelocity or bodyVelocity.Parent ~= hrp then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = hrp
    end
    
    if not bodyGyro or bodyGyro.Parent ~= hrp then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.P = 30000
        bodyGyro.Parent = hrp
    end
end

local function removeAnchor()
    if bodyVelocity then 
        pcall(function() bodyVelocity:Destroy() end)
        bodyVelocity = nil 
    end
    if bodyGyro then 
        pcall(function() bodyGyro:Destroy() end)
        bodyGyro = nil 
    end
    -- Restore normal player physics & collision
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    if hum then
        hum.PlatformStand = false
    end
end

-----------------------------------------------
-- SAFE RELIABLE TELEPORT ENGINE
-----------------------------------------------
local function performSafeTeleport(destPos, name)
    pcall(function()
        char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            char = plr.CharacterAdded:Wait()
        end
        hrp = char:WaitForChild("HumanoidRootPart")
        hum = char:FindFirstChildOfClass("Humanoid")

        pcall(removeAnchor)

        if hrp then
            hrp.Anchored = false
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end

        local destCF = CFrame.new(destPos + Vector3.new(0, 4, 0))
        char:PivotTo(destCF)
        hrp.CFrame = destCF
        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end

        Window:Notify({ Title = "Teleported", Description = "Teleported to " .. tostring(name) .. "!", Lifetime = 4 })
    end)
end

-----------------------------------------------
-- OFFICIAL FAST TRAVEL & WAYPOINT ENGINE
-----------------------------------------------
local function smartTeleportToZone(zoneName)
    local targetPos = nil

    local fastTravelAliases = {
        ["Training Ground (Attack Dummies)"] = {"training", "dummy", "practice"},
        ["Forest of Death (Ankokuji Traitors)"] = {"forest", "death", "traitor", "ankokuji"},
        ["Sand Village / Hospital (Isago)"] = {"sand", "hospital", "isago", "desert"},
        ["Red Eyes Hideout (Dual Eyes)"] = {"red eyes", "hideout", "uchiha", "dual eyes"},
        ["Leaf Village / Town Hall (Mentors)"] = {"leaf", "town", "mentor", "danzu", "spawn"},
        ["Elder Room (Granny Jiyo)"] = {"elder", "jiyo", "granny", "council"},
        ["Arid Leader Estate"] = {"arid", "leader", "symbol", "estate"},
        ["Mugetsu (Reincarnation Eye Boss)"] = {"mugetsu", "reincarnation", "tenseigan"},
        ["Monster of Sand Area"] = {"monster", "sand monster", "yin yang"},
        ["Bone Boss Arena"] = {"bone", "boss", "global"}
    }

    local aliases = fastTravelAliases[zoneName] or {zoneName:lower()}

    -- 1. Try to invoke Official Fast Travel Remotes if available
    pcall(function()
        if Remotes.FastTravel then
            if Remotes.FastTravel:IsA("RemoteEvent") then
                Remotes.FastTravel:FireServer(zoneName)
            else
                Remotes.FastTravel:InvokeServer(zoneName)
            end
        end
        if Remotes.DialogueEvent then
            Remotes.DialogueEvent:FireServer("FastTravel", zoneName)
            Remotes.DialogueEvent:FireServer("Travel", zoneName)
        end
    end)

    -- 2. Search for physical Fast Travel Waypoints, Carriages, Teleport Pads, and Signs in Workspace
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj ~= char and not obj:IsDescendantOf(char) then
            local objName = tostring(obj.Name):lower()
            local isTravelPoint = objName:find("travel") or objName:find("waypoint") or objName:find("carriage") or objName:find("teleport") or objName:find("cart") or objName:find("wagon") or obj:IsA("SpawnLocation") or obj:FindFirstChild("TouchTransmitter") or obj:FindFirstChild("ProximityPrompt")

            if isTravelPoint then
                for _, alias in ipairs(aliases) do
                    if objName:find(alias) or (obj.Parent and tostring(obj.Parent.Name):lower():find(alias)) then
                        local part = (obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") and obj.PrimaryPart)
                            or (obj:IsA("BasePart") and obj)
                            or obj:FindFirstChild("HumanoidRootPart")
                            or obj:FindFirstChildOfClass("BasePart")
                        if part then
                            targetPos = part.Position + Vector3.new(0, 4, 0)
                            break
                        end
                    end
                end
            end
            if targetPos then break end
        end
    end

    -- 3. Fallback to active Named Mob / NPC if Fast Travel Point wasn't found
    if not targetPos then
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char and not obj:IsDescendantOf(char) then
                local objName = tostring(obj.Name):lower()
                local eRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if eRoot then
                    for _, alias in ipairs(aliases) do
                        if objName:find(alias) then
                            targetPos = eRoot.Position + Vector3.new(0, 4, 4)
                            break
                        end
                    end
                end
                if targetPos then break end
            end
        end
    end

    -- 4. Fallback to calibrated coordinates
    if not targetPos and FallbackTeleports[zoneName] then
        targetPos = FallbackTeleports[zoneName]
    end

    if targetPos then
        performSafeTeleport(targetPos, zoneName)
    else
        Window:Notify({ Title = "Fast Travel", Description = "Could not find fast travel point for " .. zoneName .. ".", Lifetime = 4 })
    end
end

local function smartTeleportToNPC(npcName)
    local targetPos = nil
    local targetLower = npcName:lower()

    -- Rank matches: exact name > name prefix > substring; prefer real NPC rigs (Humanoid) over props
    local exactPos, prefixPos, partialPos
    local function consider(obj)
        local part = (obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") and obj.PrimaryPart)
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChild("Head")
            or obj:FindFirstChildOfClass("BasePart")
        if not part then return end
        local pos = part.Position + Vector3.new(0, 3, -4)
        local n = tostring(obj.Name):lower()
        if n == targetLower then
            exactPos = exactPos or pos
        elseif n:sub(1, #targetLower) == targetLower then
            prefixPos = prefixPos or pos
        elseif n:find(targetLower, 1, true) then
            partialPos = partialPos or pos
        end
    end

    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char and not obj:IsDescendantOf(char)
            and (obj:FindFirstChildOfClass("Humanoid") or obj.PrimaryPart) then
            consider(obj)
        end
        if exactPos then break end
    end

    targetPos = exactPos or prefixPos or partialPos

    if not targetPos and NPCFallbacks[npcName] then
        targetPos = NPCFallbacks[npcName]
    end

    if targetPos then
        performSafeTeleport(targetPos, npcName)
    else
        Window:Notify({ Title = "NPC Not Found", Description = "Could not find " .. npcName .. " in workspace.", Lifetime = 4 })
    end
end

-----------------------------------------------
-- ESP Visuals & Cleanup
-----------------------------------------------
local espCache = {}
local function clearESP()
    for _, entry in pairs(espCache) do
        pcall(function() if entry.Highlight then entry.Highlight:Destroy() end end)
        pcall(function() if entry.Billboard then entry.Billboard:Destroy() end end)
    end
    espCache = {}
end

-----------------------------------------------
-- MASTER CLEAN UNLOAD & TERMINATE FUNCTION
-----------------------------------------------
local function unloadScript()
    if not ScriptRunning then return end
    ScriptRunning = false
    if NinjaRuntime.Env.DMA_NINJA_ACTIVE == unloadScript then NinjaRuntime.Env.DMA_NINJA_ACTIVE = nil end
    NinjaRuntime.UpdateState(true)
    if KuramaCombat.Stop then pcall(KuramaCombat.Stop, true) end

    -- 1. Force disable all auto farm & looping flags
    Config.AutoFarm = false
    Config.AutoKuramaRaid = false
    Config.AutoPlayKuramaFight = false
    Config.AutoRebirthLoop = false
    Config.AutoDualEyesQuest = false
    Config.AutoSmartQuestTracker = false
    Config.AutoDualEyesFarm = false
    Config.AutoSpinClan = false
    Config.AutoSpinElement = false
    Config.AutoSpinEye = false
    Config.GodMode = false
    Config.Noclip = false
    Config.MobESP = false
    Config.NPCESP = false
    Config.SpeedBoost = false
    Config.JumpBoost = false

    -- 2. Clear ESP highlights & bill boards
    clearESP()

    -- 3. Disconnect all background listeners
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}

    -- 4. Destroy physics anchors and restore character gravity
    pcall(removeAnchor)

    -- 5. Restore default walkspeed / jumppower
    if hum and hum.Parent then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    -- 6. Destroy UI Window
    pcall(function() Window:Destroy() end)
    pcall(function()
        local gui = plr:FindFirstChild("PlayerGui")
        if gui then
            for _, name in ipairs({"NTFeaturesHUD", "NTFarmHUD", "NTQuestHUD"}) do
                local hud = gui:FindFirstChild(name)
                if hud then hud:Destroy() end
            end
        end
    end)

    print("[dma.wtf / Ninja Time v8.1] ALL LOOPS KILLED & SCRIPT CLEANLY UNLOADED!")
end
Window.Library:OnUnload(unloadScript)
if type(NinjaRuntime.Env.DMA_NINJA_ACTIVE) == "function" then pcall(NinjaRuntime.Env.DMA_NINJA_ACTIVE) end
NinjaRuntime.Env.DMA_NINJA_ACTIVE = unloadScript
table.insert(Connections, plr.OnTeleport:Connect(function(state)
    if not ScriptRunning then return end
    if state == Enum.TeleportState.Failed then NinjaRuntime.Queued = false; return end
    if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
        saveSettings()
        if Config.AutoExecute and not NinjaRuntime.Queued then
            local ok, err = NinjaRuntime.Queue()
            if not ok then Window.LastError = "Auto-execute: " .. tostring(err) end
        end
    end
end))

-----------------------------------------------
-- EMERGENCY HARDWARE KILLSWITCH KEYBIND (PRESS [END] OR [DELETE])
-----------------------------------------------
local killswitchConn = UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.End or input.KeyCode == Enum.KeyCode.Delete then
        unloadScript()
    end
end)
table.insert(Connections, killswitchConn)

-- FIX: Anti-AFK was a toggle-only stub; now wired to the Idled event
local antiAfkConn = plr.Idled:Connect(function()
    if ScriptRunning and Config.AntiAFK then
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)
table.insert(Connections, antiAfkConn)

-----------------------------------------------
-- LIVE MOBS SCANNER & DYNAMIC UPDATER
-----------------------------------------------
local LiveMobsList = {"All Live Mobs"}
local lastLiveScan = -math.huge

local function scanLiveMobs(force)
    if not ScriptRunning then return {"All Live Mobs"} end
    if not force and tick() - lastLiveScan < 5 then return LiveMobsList end
    lastLiveScan = tick()
    local liveSet = {}
    local newList = {"All Live Mobs"}

    local function checkContainer(container)
        if not container then return end
        for _, child in ipairs(container:GetDescendants()) do
            if child:IsA("Model") and child ~= char and not Players:GetPlayerFromCharacter(child) then
                local eHum = child:FindFirstChildOfClass("Humanoid")
                local eHRP = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head") or child:FindFirstChildOfClass("BasePart")
                if eHum and eHRP and eHum.Health > 0 and eHum.MaxHealth > 1 then
                    if not liveSet[child.Name] then
                        liveSet[child.Name] = true
                        table.insert(newList, child.Name)
                    end
                end
            end
        end
    end

    -- One snapshot includes the optional containers; do not scan them again separately.
    checkContainer(WS)

    LiveMobsList = newList
    return LiveMobsList
end

scanLiveMobs()

-----------------------------------------------
-- CREEP.CC WORKSPACE — fewer pages, feature-sized groupboxes, and a live dashboard
-----------------------------------------------
local tabs = {
    Home = Window.NativeWindow:AddTab("Home"),
    Raids = Window.NativeWindow:AddTab("Raids"),
    Combat = Window.NativeWindow:AddTab("Combat"),
    Progression = Window.NativeWindow:AddTab("Progress"),
    World = Window.NativeWindow:AddTab("World"),
    Player = Window.NativeWindow:AddTab("Player"),
    Teleports = Window.NativeWindow:AddTab("Travel"),
    Settings = Window.NativeWindow:AddTab("Settings"),
}

local sections = {
    CombatLeft = Window:Section(tabs.Combat, "Left", "CombatLeft"),
    CombatRight = Window:Section(tabs.Combat, "Right", "CombatRight"),
    RebirthLeft = Window:Section(tabs.Raids, "Left", "RebirthLeft"),
    RebirthRight = Window:Section(tabs.Raids, "Right", "RebirthRight"),
    DualLeft = Window:Section(tabs.Progression, "Left", "DualLeft"),
    DualRight = Window:Section(tabs.Progression, "Right", "DualRight"),
    SandLeft = Window:Section(tabs.World, "Left", "SandLeft"),
    SandRight = Window:Section(tabs.World, "Right", "SandRight"),
    ChakraLeft = Window:Section(tabs.Player, "Left", "ChakraLeft"),
    ChakraRight = Window:Section(tabs.Player, "Right", "ChakraRight"),
    BossesLeft = Window:Section(tabs.World, "Left", "BossesLeft"),
    RaidsLeft = Window:Section(tabs.Raids, "Left", "RaidsLeft"),
    RaidsRight = Window:Section(tabs.Raids, "Right", "RaidsRight"),
    TrainingLeft = Window:Section(tabs.Progression, "Left", "TrainingLeft"),
    TrainingRight = Window:Section(tabs.Progression, "Right", "TrainingRight"),
    TeleportsLeft = Window:Section(tabs.Teleports, "Left", "TeleportsLeft"),
    TeleportsRight = Window:Section(tabs.Teleports, "Right", "TeleportsRight"),
    QuestsLeft = Window:Section(tabs.Progression, "Left", "QuestsLeft"),
    QuestsRight = Window:Section(tabs.Progression, "Right", "QuestsRight"),
    PlayerLeft = Window:Section(tabs.Player, "Left", "PlayerLeft"),
    PlayerRight = Window:Section(tabs.Player, "Right", "PlayerRight"),
    UtilLeft = Window:Section(tabs.Settings, "Left", "UtilLeft"),
    UtilRight = Window:Section(tabs.Settings, "Right", "UtilRight"),
}

do
    local status = tabs.Home:AddLeftGroupbox("Session Overview")
    status:AddLabel("Ninja Time / dma.wtf", true)
    Window.Dashboard = {
        Player = status:AddLabel("Player: " .. plr.DisplayName, true),
        Level = status:AddLabel("Level: waiting for player data", true),
        Boss = status:AddLabel("Kurama: not scanned", true),
        Mode = status:AddLabel("Mode: idle", true),
        Rebirth = status:AddLabel("Rebirth: IDLE", true),
        Remotes = status:AddLabel("Remotes: resolving", true),
        Error = status:AddLabel("Last error: none", true),
    }
    local actions = tabs.Home:AddRightGroupbox("Quick Navigation")
    actions:AddButton("Check Kurama", Window:Callback(function()
        local boss = findKurama()
        Window:Notify({Title = "Kurama", Description = boss and (boss.Name .. " detected") or "No live Kurama rig is currently streamed in."})
    end))
    actions:AddButton("Kurama & Rebirth", Window:Callback(function() tabs.Raids:ShowTab() end))
    actions:AddButton("Combat Setup", Window:Callback(function() tabs.Combat:ShowTab() end))
    actions:AddButton("Travel & NPCs", Window:Callback(function() tabs.Teleports:ShowTab() end))
    actions:AddButton("Interface Settings", Window:Callback(function() tabs.Settings:ShowTab() end))
    local help = tabs.Home:AddRightGroupbox("Controls & Safety")
    Window.ControlsHelp = help:AddLabel("RightControl: show / hide menu\nEND or DELETE: stop and unload\nClosing the menu does not stop active features.", true)
    help:AddButton({Text = "Stop & Unload Hub", DoubleClick = true, Func = unloadScript})

    local menu = tabs.Settings:AddRightGroupbox("Interface")
    Window.InterfaceControls = {}
    Window.MenuKey = menu:AddLabel("Menu key"):AddKeyPicker("NT_MenuKey", {Default = "RightControl", NoUI = true, Text = "Menu key"})
    Window.Library.ToggleKeybind = Window.MenuKey
    Window.InterfaceControls.Accent = menu:AddDropdown("NT_Accent", {Text = "Accent", Values = {"Ocean", "Violet", "Ember", "Mint"}, Default = "Ocean",
        Callback = Window:Callback(function(value) Window:SetAccent(value) end)})
    Window.InterfaceControls.Notifications = menu:AddToggle("NT_Notifications", {Text = "Notifications", Default = true,
        Callback = Window:Callback(function(value) Window.Notifications = value end)})
    Window.InterfaceControls.Blur = menu:AddToggle("NT_MenuBlur", {Text = "Menu blur", Default = false,
        Callback = Window:Callback(function(value) Window.Library.UseBlur = value; Window.Library:UpdateBlur() end)})
    Window.InterfaceControls.Watermark = menu:AddToggle("NT_Watermark", {Text = "Watermark", Default = false,
        Callback = Window:Callback(function(value)
            Window.ShowWatermark = value
            if value then Window.Library:SetWatermark("dma.wtf | Ninja Time | v8.1")
            else Window.Library:SetWatermarkVisibility(false) end
        end)})
    menu:AddButton({Text = "Unload Hub", DoubleClick = true, Func = unloadScript})
end
tabs.Home:ShowTab()

do
    local profiles = tabs.Settings:AddLeftGroupbox("Configs")
    local name = "Default"
    local input
    local selected = profiles:AddDropdown("NT_Profile", {Text = "Saved profile", Values = ConfigStore.List(), Default = "Default",
        Callback = Window:Callback(function(value)
            name = value
            if input then Window.Syncing = true; input:SetValue(value); Window.Syncing = false end
        end)})
    input = profiles:AddInput("NT_ProfileName", {Text = "Save / load name", Default = "Default", Finished = true,
        Callback = Window:Callback(function(value) name = value end)})
    Window.ProfileStatus = profiles:AddLabel("Active profile: Default", true)
    profiles:AddLabel("Profiles include feature settings and interface preferences. Enabled automation resumes when loaded.", true)
    profiles:AddLabel("Names: 1–48 letters, numbers, underscores or hyphens.", true)
    local function refresh()
        selected:SetValues(ConfigStore.List())
        Window.Syncing = true
        selected:SetValue(ConfigStore.Selected)
        input:SetValue(ConfigStore.Selected)
        Window.Syncing = false
        name = ConfigStore.Selected
        Window.ProfileStatus:SetText("Active profile: " .. ConfigStore.Selected .. (ConfigStore.SuspendAutosave and " (unsaved; auto-save paused)" or ""))
    end
    Window.RefreshProfiles = refresh
    local function report(action, ok, err)
        Window:Notify({Title = "Configs", Description = ok and (action .. ": " .. ConfigStore.Selected) or tostring(err)})
        if ok then refresh() end
    end
    profiles:AddButton("Save Config", Window:Callback(function() report("Saved", ConfigStore.Save(name)) end))
    profiles:AddButton("Load Config", Window:Callback(function() report("Loaded", ConfigStore.Load(name)) end))
    profiles:AddButton("Refresh Profiles", Window:Callback(refresh))
    profiles:AddButton({Text = "Delete Config", DoubleClick = true, Func = Window:Callback(function() report("Deleted", ConfigStore.Delete(name)) end)})
    profiles:AddButton({Text = "Reset to Defaults", DoubleClick = true, Func = Window:Callback(function()
        ConfigStore.Apply(ConfigStore.Defaults, {Accent = "Ocean", Notifications = true, Blur = false, Watermark = false, MenuKey = "RightControl"})
        Window:Notify({Title = "Configs", Description = "Defaults restored; save to keep them. Stored profiles were not deleted."})
    end)})
    profiles:AddLabel("Files: " .. ConfigStore.Folder .. "\nLast selected profile restores on startup. Existing rebirth settings are imported if no profile exists.", true)
end

-----------------------------------------------
-- AUTO REBIRTH LOOP ENGINE (VERIFIED PROTOCOL)
-- Cycle: Kurama Lair raid (solo, any difficulty) -> EXP -> max level ->
-- apply attributes -> confirm rebirth (prestige) -> repeat.
-- Uses the game's own shared modules: RaidLobby (ByteNet packets built for us),
-- Prestige (eligibility check), ReplicatedData (live PlayerData).
-----------------------------------------------
local RebirthState = {
    phase = "IDLE",       -- IDLE | CREATING_LOBBY | STARTING_RAID | IN_RAID | ALLOCATING | PRESTIGE_READY | WAITING
    note = "",
    lastPhaseChange = tick(),
    lastLobbyAttempt = 0,
    lastPrestigeAttempt = 0,
    raidLooted = false,
    cycleCount = 0,
}

local function rebirthSetPhase(phase, note)
    if RebirthState.phase ~= phase or note ~= RebirthState.note then
        RebirthState.phase = phase
        RebirthState.note = note or ""
        RebirthState.lastPhaseChange = tick()
        print(("[Rebirth Loop] %s %s"):format(phase, note or ""))
    end
end

-- Reads live PlayerData through the game's own replication module
local function getPlayerData()
    if Shared.ReplicatedData and Shared.ReplicatedData.GetData then
        local ok, data = pcall(function() return Shared.ReplicatedData:GetData("PlayerData", true) end)
        if ok and type(data) == "table" then return data end
    end
    return nil
end

local function getMaxLevel()
    if Shared.Settings and Shared.Settings.MaxLevel then return Shared.Settings.MaxLevel end
    return 200 -- verified from game source (Settings.MaxLevel)
end

-- Prestige requirements (verified from Prestige module):
-- level 200, 3 maxed attributes, Anbu/Ankokuji rank, story quest "Duty Calls" complete
getRebirthBlockers = function(data)
    local blockers = {}
    data = data or getPlayerData() or {}
    local maxLevel = getMaxLevel()

    if (tonumber(data.Level) or 1) < maxLevel then
        table.insert(blockers, "reach level " .. maxLevel)
    end

    if Shared.Prestige and Shared.Prestige.GetBlocker then
        local ok, blocker = pcall(function() return Shared.Prestige:GetBlocker(data) end)
        if ok and type(blocker) == "string" then
            table.insert(blockers, blocker)
        end
    end

    return blockers
end

isRebirthEligible = function()
    local data = getPlayerData()
    if not data then return false end
    if Shared.Prestige and Shared.Prestige.IsEligible then
        local ok, eligible = pcall(function() return Shared.Prestige:IsEligible(data) end)
        if ok then return eligible end
    end
    return #getRebirthBlockers(data) == 0
end

-- Direct prestige confirmation (the server pushes the modal; this accepts it)
confirmPrestige = function()
    if Remotes.PrestigeConfirm then
        Remotes.PrestigeConfirm:FireServer()
        return true
    end
    return false
end

-- Apply one attribute point (verified payload: AttributesRemote:InvokeServer{Job="IncreaseLevel", ID})
local function allocateOnePoint(statID)
    if not Remotes.AttributesRemote then return false end
    local ok, result = pcall(function()
        if Remotes.AttributesRemote:IsA("RemoteFunction") then
            return Remotes.AttributesRemote:InvokeServer({ Job = "IncreaseLevel", ID = statID })
        end
        Remotes.AttributesRemote:FireServer({ Job = "IncreaseLevel", ID = statID })
        return true
    end)
    return ok and result ~= false
end

-- Solo Kurama lobby via the game's own shared RaidLobby module (verified payloads)
requestKuramaLobby = function()
    if not (Shared.RaidLobby and Shared.RaidLobby.RequestLobby) then return false end
    local ok = pcall(function()
        Shared.RaidLobby:RequestLobby({
            difficulty = Config.RebirthDifficulty, -- "Easy" | "Normal" | "Hard"
            minLevel = 1,
            maxPlayers = 1,
            privacy = "Private",
            raidId = "Kurama",                     -- verified RaidId (DisplayName: "Koroma Lair")
        })
    end)
    return ok
end

local function startRaidLobby()
    if not (Shared.RaidLobby and Shared.RaidLobby.RequestStart) then return false end
    return pcall(function() Shared.RaidLobby:RequestStart() end)
end

local function amIInLobby()
    if not (Shared.RaidLobby and Shared.RaidLobby.GetPlayerLobby) then return false end
    local ok, lobby = pcall(function() return Shared.RaidLobby:GetPlayerLobby(plr) end)
    return ok and lobby ~= nil
end

-- Raid state tracking (verified: RaidState_Event fires (stateString, ...))
do
    local conn = Remotes.RaidState and Remotes.RaidState.OnClientEvent:Connect(function(state)
        if typeof(state) == "string" then
            RebirthState.lastRaidState = state
            if state == "Gameplay" then
                rebirthSetPhase("IN_RAID", "Kurama raid running")
            elseif state == "Ended" then
                RebirthState.raidLooted = true
            end
        end
    end)
    if conn then table.insert(Connections, conn) end
end

-- The main rebirth state machine (runs once per second from the mode engine)
runRebirthLoop = function()
    if not Config.AutoRebirthLoop then return end
    if not hrp or not hrp.Parent then return end

    local data = getPlayerData()
    local level = data and (tonumber(data.Level) or 1) or (tonumber(getPlayerLevel()) or 1)
    local maxLevel = getMaxLevel()

    -- Safety: while raiding, keep AutoFarm targeting bosses/Kurama so EXP keeps flowing
    if RebirthState.phase == "IN_RAID" or RebirthState.lastRaidState == "Gameplay" then
        if not Config.AutoFarm then
            Config.AutoFarm = true
        end
        Config.TargetType = "Kurama (Raid Boss)"
        -- fall through; farming runs via the farm loop
    end

    if RebirthState.phase == "IDLE" or RebirthState.phase == "WAITING" then
        -- Priority 1: if already rebirth-eligible, confirm the prestige
        if isRebirthEligible() then
            rebirthSetPhase("PRESTIGE_READY", "All requirements met")
            return
        end
        -- Priority 2: raid for EXP (Kurama Lair = best EXP per your report)
        if not amIInLobby() then
            if (tick() - RebirthState.lastLobbyAttempt) > 8 then
                RebirthState.lastLobbyAttempt = tick()
                if requestKuramaLobby() then
                    rebirthSetPhase("CREATING_LOBBY", "Requested solo Kurama lobby (" .. Config.RebirthDifficulty .. ")")
                else
                    rebirthSetPhase("WAITING", "RaidLobby module unavailable")
                end
            end
        else
            rebirthSetPhase("STARTING_RAID", "Solo lobby ready")
        end

    elseif RebirthState.phase == "CREATING_LOBBY" then
        if amIInLobby() then
            rebirthSetPhase("STARTING_RAID", "Lobby created")
        elseif (tick() - RebirthState.lastPhaseChange) > 25 then
            rebirthSetPhase("IDLE", "Lobby request timed out, retrying")
        end

    elseif RebirthState.phase == "STARTING_RAID" then
        if (tick() - RebirthState.lastPhaseChange) > 1.5 then
            startRaidLobby()
            rebirthSetPhase("WAITING_START", "Waiting for raid to start")
        end

    elseif RebirthState.phase == "WAITING_START" then
        if RebirthState.lastRaidState == "Gameplay" then
            rebirthSetPhase("IN_RAID", "Fighting Kurama")
        elseif (tick() - RebirthState.lastPhaseChange) > 30 then
            rebirthSetPhase("IDLE", "Raid start timed out, retrying")
        end

    elseif RebirthState.phase == "IN_RAID" then
        -- AutoFarm handles combat. When raid ends, move to attribute allocation.
        if RebirthState.lastRaidState == "Ended" or RebirthState.lastRaidState == "Rewards" then
            rebirthSetPhase("ALLOCATING", "Raid complete — applying attributes")
            RebirthState.cycleCount = RebirthState.cycleCount + 1
        elseif RebirthState.lastRaidState ~= "Gameplay" and (tick() - RebirthState.lastPhaseChange) > 240 then
            rebirthSetPhase("IDLE", "Raid stalled — restarting cycle")
            RebirthState.lastRaidState = nil
        end

    elseif RebirthState.phase == "ALLOCATING" then
        -- Spend all free points into the priority stat (verified stat IDs: Chackra, Vitality, Taijutsu, Ninjutsu...)
        local attrs = data and data.Attributes
        local spent = false
        if type(attrs) == "table" then
            -- best-effort: hammer the IncreaseLevel job a few times; server rejects when broke
            for _ = 1, 6 do
                if not allocateOnePoint(Config.RebirthStatPriority) then break end
                spent = true
            end
        end
        rebirthSetPhase("PRESTIGE_CHECK", spent and "Points applied" or "Checked (no data or no points)")

    elseif RebirthState.phase == "PRESTIGE_CHECK" then
        if isRebirthEligible() then
            rebirthSetPhase("PRESTIGE_READY", "Eligible after raid")
        else
            rebirthSetPhase("IDLE", "Not eligible yet — queueing another raid")
        end

    elseif RebirthState.phase == "PRESTIGE_READY" then
        if (tick() - RebirthState.lastPrestigeAttempt) > 5 then
            RebirthState.lastPrestigeAttempt = tick()
            if confirmPrestige() then
                Window:Notify({ Title = "Rebirth", Description = "Prestige confirmed! Rebuilding character...", Lifetime = 5 })
                rebirthSetPhase("IDLE", "Prestige sent — restarting cycle")
            else
                rebirthSetPhase("WAITING", "PrestigeConfirm remote missing")
            end
        end
    end
end

-----------------------------------------------
-- 1. COMBAT TAB
-----------------------------------------------
sections.CombatLeft:Header({ Name = "Auto Farm Target Engine" })

sections.CombatLeft:Toggle({
    Name = "God Mode (Never Die / Full Immunity)",
    Default = true,
    Callback = function(v) Config.GodMode = v end
})

sections.CombatLeft:Toggle({
    Name = "Touch Damage Nullifier (Blocks Hitboxes/AOE)",
    Default = true,
    Callback = function(v) Config.TouchDamageNullifier = v end
})

sections.CombatLeft:Toggle({
    Name = "Death State & Ragdoll Bypass",
    Default = true,
    Callback = function(v) Config.DeathStateBypass = v end
})

sections.CombatLeft:Toggle({
    Name = "Emergency Escape & Auto-Meditation",
    Default = true,
    Callback = function(v) Config.EmergencyEscape = v end
})

sections.CombatLeft:Slider({
    Name = "Emergency Escape HP Threshold (%)",
    Default = 35,
    Minimum = 10,
    Maximum = 80,
    Precision = 0,
    Callback = function(v) Config.EscapeThreshold = v end
})

sections.CombatLeft:Toggle({
    Name = "Auto Farm Target",
    Default = false,
    Callback = function(v) 
        Config.AutoFarm = v
        if not v then
            removeAnchor()
        end
    end
})

sections.CombatLeft:Toggle({
    Name = "Only Target Currently ALIVE Mobs",
    Default = true,
    Callback = function(v) Config.OnlyAliveMobs = v end
})

local liveDropdown = sections.CombatLeft:Dropdown({
    Name = "LIVE MOBS (Currently Spawned)",
    Search = true,
    Multi = false,
    Required = false,
    Options = LiveMobsList,
    Default = "All Live Mobs",
    Callback = function(v) 
        Config.LiveTargetSelect = v 
        if v ~= "All Live Mobs" then
            Config.TargetType = v
        end
    end
})

sections.CombatLeft:Button({
    Name = "Refresh Live Mobs List",
    Callback = function()
        local updated = scanLiveMobs(true)
        liveDropdown:SetValues(updated)
        liveDropdown:SetValue(updated[1])
        Window:Notify({ Title = "Live Mobs Scanner", Description = "Found " .. tostring(#updated - 1) .. " active mob types in server!", Lifetime = 4 })
    end
})

sections.CombatLeft:Divider()

sections.CombatLeft:Dropdown({
    Name = "ALL MOBS DATABASE (Master List)",
    Search = true,
    Multi = false,
    Required = false,
    Options = MasterMobsList,
    Default = "All Mobs",
    Callback = function(v) Config.TargetType = v end
})

sections.CombatLeft:Input({
    Name = "Custom Search Input",
    Placeholder = "e.g. Monster of Sand",
    AcceptedCharacters = "All",
    Callback = function(v) Config.CustomTargetInput = v end
})

sections.CombatLeft:Slider({
    Name = "Attack Speed (Delay)",
    Default = 0.15,
    Minimum = 0.05,
    Maximum = 1.0,
    Precision = 2,
    Callback = function(v) Config.AttackSpeed = v end
})

sections.CombatLeft:Slider({
    Name = "Hover Distance / Height (Studs)",
    Default = 3,
    Minimum = 0,
    Maximum = 25,
    Precision = 0,
    Callback = function(v) Config.FarmHeight = v end
})

sections.CombatRight:Header({ Name = "Abilities & Combat Engine" })

sections.CombatRight:Toggle({
    Name = "Auto Equip Weapon / Sword",
    Default = true,
    Callback = function(v) Config.AutoEquipWeapon = v end
})

sections.CombatRight:Toggle({
    Name = "Auto Cast Jutsu Skills & Moves",
    Default = true,
    Callback = function(v) Config.AutoJutsu = v end
})

sections.CombatRight:Toggle({
    Name = "Instant Kunai Spam",
    Default = true,
    Callback = function(v) Config.KunaiSpam = v end
})

-- Hitbox engine (FIX: these were called but never defined -> script error every toggle)
local function getHitboxParts(model)
    local parts = {}
    if Config.HitboxTargetPart == "Head" then
        local h = model:FindFirstChild("Head")
        if h then table.insert(parts, h) end
    elseif Config.HitboxTargetPart == "HumanoidRootPart" then
        local r = model:FindFirstChild("HumanoidRootPart")
        if r then table.insert(parts, r) end
    else -- All Limbs
        for _, p in ipairs(model:GetChildren()) do
            if p:IsA("BasePart") and (p.Name:find("Arm") or p.Name:find("Leg") or p.Name:find("Torso")) then
                table.insert(parts, p)
            end
        end
    end
    return parts
end

local function expandMobHitboxes()
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local h = obj:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and h.MaxHealth > 1 then
                for _, p in ipairs(getHitboxParts(obj)) do
                    if not p:GetAttribute("NTOriginalSize") then
                        p:SetAttribute("NTOriginalSize", p.Size.X .. "," .. p.Size.Y .. "," .. p.Size.Z)
                    end
                    p.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    if Config.HitboxVisualMode == "Normal (Invisible Box)" then
                        p.Transparency = 1
                    elseif Config.HitboxVisualMode == "Visible Ghost (0.8)" then
                        p.Transparency = 0.8
                    else
                        p.Transparency = 0
                    end
                end
            end
        end
    end
end

local function restoreMobHitboxes()
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("NTOriginalSize") then
            local sx, sy, sz = tostring(obj:GetAttribute("NTOriginalSize")):match("([^,]+),([^,]+),([^,]+)")
            pcall(function()
                obj.Size = Vector3.new(tonumber(sx) or 1, tonumber(sy) or 1, tonumber(sz) or 1)
                obj:SetAttribute("NTOriginalSize", nil)
            end)
        end
    end
end

sections.CombatRight:Toggle({
    Name = "Extend Enemy Hitbox Reach",
    Default = true,
    Callback = function(v)
        Config.HitboxExtender = v
        if not v then
            pcall(restoreMobHitboxes)
        else
            pcall(expandMobHitboxes)
        end
    end
})

sections.CombatRight:Dropdown({
    Name = "Hitbox Target Part",
    Options = {
        "Head",
        "HumanoidRootPart",
        "All Limbs"
    },
    Default = "Head",
    Callback = function(v) Config.HitboxTargetPart = v end
})

sections.CombatRight:Slider({
    Name = "Enemy Hitbox Size (Studs)",
    Default = 20,
    Minimum = 5,
    Maximum = 50,
    Precision = 0,
    Callback = function(v) Config.HitboxSize = v end
})

sections.CombatRight:Dropdown({
    Name = "Hitbox Visual Style",
    Options = {
        "Normal (Invisible Box)",
        "Visible Ghost (0.8)",
        "Solid"
    },
    Default = "Normal (Invisible Box)",
    Callback = function(v) Config.HitboxVisualMode = v end
})

sections.CombatRight:Toggle({
    Name = "Fast Auto Puncher (M1 Click Spam)",
    Default = true,
    Callback = function(v) Config.AutoPuncher = v end
})

sections.CombatRight:Slider({
    Name = "Punch Speed (Delay between M1s)",
    Default = 0.08,
    Minimum = 0.04,
    Maximum = 0.5,
    Precision = 2,
    Callback = function(v) Config.PunchSpeed = v end
})

sections.CombatRight:Divider()
sections.CombatRight:Header({ Name = "Jutsu Defense & Auto-Dodge" })

sections.CombatRight:Toggle({
    Name = "Auto-Dodge Boss Jutsu / Attacks",
    Default = true,
    Callback = function(v) Config.AutoDodge = v end
})

sections.CombatRight:Dropdown({
    Name = "Dodge Technique / Style",
    Options = {
        "Sharingan / Orbit Glide",
        "Kawarimi (Behind Teleport)",
        "Sky Hover (Over Jutsu)",
        "Block / Guard (F Key)"
    },
    Default = "Sharingan / Orbit Glide",
    Callback = function(v) Config.DodgeMode = v end
})

sections.CombatRight:Slider({
    Name = "Dodge Evasion Distance",
    Default = 15,
    Minimum = 8,
    Maximum = 40,
    Precision = 0,
    Callback = function(v) Config.DodgeDistance = v end
})

sections.CombatRight:Toggle({
    Name = "Auto-Block Guard (Hold F while targeted)",
    Default = true,
    Callback = function(v) Config.AutoBlock = v end
})

sections.CombatRight:Divider()

sections.CombatRight:Button({
    Name = "STOP ALL & UNLOAD (PRESS END/DEL)",
    Callback = function()
        unloadScript()
    end
})

-----------------------------------------------
-- 1.5 AUTO REBIRTH TAB
-----------------------------------------------
sections.RebirthLeft:Header({ Name = "Kurama Lair EXP Cycle (Auto Rebirth)" })

sections.RebirthLeft:Toggle({
    Name = "Enable Auto Rebirth Loop",
    Default = false,
    Callback = function(v)
        Config.AutoRebirthLoop = v
        saveSettings()
        if v then
            RebirthState.lastRaidState = nil
            rebirthSetPhase("IDLE", "Loop enabled")
            Window:Notify({ Title = "Auto Rebirth", Description = "Kurama Lair EXP cycle active. It will raid, farm, allocate stats, and rebirth at max level.", Lifetime = 6 })
        else
            rebirthSetPhase("IDLE", "Loop disabled")
        end
    end
})

sections.RebirthLeft:Dropdown({
    Name = "Raid Difficulty",
    Options = { "Easy", "Normal", "Hard" },
    Default = "Normal",
    Callback = function(v) Config.RebirthDifficulty = v; saveSettings() end
})

sections.RebirthLeft:Dropdown({
    Name = "Stat Priority (points go here)",
    Search = true,
    Options = { "Chackra", "Vitality", "Taijutsu", "Ninjutsu", "Genjutsu", "Agility", "Weapons", "Evasive" },
    Default = "Chackra",
    Callback = function(v) Config.RebirthStatPriority = v; saveSettings() end
})

sections.RebirthLeft:Divider()
sections.RebirthLeft:Header({ Name = "Auto-Fight AI & Auto-Level" })

sections.RebirthLeft:Toggle({
    Name = "Auto-Play Kurama Fight (dodge / heal / awaken)",
    Default = false,
    Callback = function(v)
        Config.AutoPlayKuramaFight = v
        saveSettings()
        if v then
            Window:Notify({ Title = "Kurama AI", Description = "Native punches/moves, attack wind-up avoidance, healing and awakening enabled.", Lifetime = 6 })
        elseif not Config.AutoKuramaRaid and KuramaCombat.Stop then
            KuramaCombat.Stop(true)
        end
    end
})

sections.RebirthLeft:Slider({
    Name = "Self-Heal Below HP (%)",
    Default = 40,
    Minimum = 10,
    Maximum = 90,
    Precision = 0,
    Callback = function(v) Config.KuramaHealThreshold = v; saveSettings() end
})

sections.RebirthLeft:Slider({
    Name = "Awaken Mode at Stacks",
    Default = 5,
    Minimum = 1,
    Maximum = 20,
    Precision = 0,
    Callback = function(v) Config.KuramaModeStacks = v; saveSettings() end
})

sections.RebirthLeft:Toggle({
    Name = "Auto-Level 1 to Max Between Rebirths",
    Default = false,
    Callback = function(v)
        Config.AutoLevelTo200 = v
        if not v then Config.AutoLevelQuest = false end
        saveSettings()
    end
})

sections.RebirthLeft:Divider()

sections.RebirthLeft:Toggle({
    Name = "Persist Settings (resume after rejoin/hop)",
    Default = true,
    Callback = function(v) Config.PersistSettings = v; ConfigStore.Save(ConfigStore.Selected) end
})

sections.RebirthLeft:Button({
    Name = "Save Settings Now",
    Callback = function()
        local ok, err = ConfigStore.Save(ConfigStore.Selected)
        Window:Notify({ Title = "Settings", Description = ok and ("Saved profile: " .. ConfigStore.Selected) or tostring(err), Lifetime = 4 })
    end
})

sections.RebirthLeft:Button({
    Name = "Reload Saved Settings",
    Callback = function()
        if loadSettings() then
            Window:Notify({ Title = "Settings", Description = "Loaded: " .. Config.RebirthDifficulty .. " | " .. Config.RebirthStatPriority, Lifetime = 5 })
        else
            Window:Notify({ Title = "Settings", Description = "No saved settings found (or executor blocks file I/O).", Lifetime = 5 })
        end
    end
})

sections.RebirthLeft:Button({
    Name = "Force Rebirth Now (if eligible)",
    Callback = function()
        if isRebirthEligible() then
            if confirmPrestige() then
                Window:Notify({ Title = "Rebirth", Description = "Prestige confirm sent!", Lifetime = 4 })
            else
                Window:Notify({ Title = "Rebirth", Description = "PrestigeConfirm remote not found.", Lifetime = 4 })
            end
        else
            local blockers = getRebirthBlockers()
            Window:Notify({
                Title = "Not Eligible",
                Description = (#blockers > 0 and table.concat(blockers, ", ")) or "Unknown blocker",
                Lifetime = 7
            })
        end
    end
})

sections.RebirthRight:Header({ Name = "Live Rebirth Status" })

sections.RebirthRight:Button({
    Name = "Check Requirements / Blockers",
    Callback = function()
        local blockers = getRebirthBlockers()
        if #blockers == 0 then
            Window:Notify({ Title = "Rebirth", Description = "You are ELIGIBLE for rebirth right now!", Lifetime = 6 })
        else
            Window:Notify({
                Title = "Rebirth Requirements",
                Description = "Still need to: " .. table.concat(blockers, ", "),
                Lifetime = 8
            })
        end
    end
})

sections.RebirthRight:Button({
    Name = "Join Kurama Lair Now (solo lobby)",
    Callback = function()
        if requestKuramaLobby() then
            Window:Notify({ Title = "Kurama Lair", Description = "Solo lobby requested (" .. Config.RebirthDifficulty .. "). Open the raid GUI to start.", Lifetime = 5 })
        else
            Window:Notify({ Title = "Kurama Lair", Description = "RaidLobby module unavailable in this executor.", Lifetime = 5 })
        end
    end
})

local rebirthStatusLabel = sections.RebirthRight:Label({Text = "[IDLE] Waiting for automation", Wrap = true})

sections.RebirthRight:Button({
    Name = "Dump Rebirth State (console)",
    Callback = function()
        print(("[Rebirth Loop] phase=%s note=%s cycles=%d raidState=%s"):format(
            RebirthState.phase, RebirthState.note, RebirthState.cycleCount, tostring(RebirthState.lastRaidState)))
        local data = getPlayerData()
        if data then
            print(("[Rebirth Loop] Level=%s Prestige=%s Attributes=%s"):format(
                tostring(data.Level), tostring(data.Prestige), tostring(data.Attributes and "table" or "nil")))
        else
            print("[Rebirth Loop] PlayerData unavailable")
        end
    end
})

task.spawn(function()
    while ScriptRunning do
        task.wait(1)
        if Config.AutoRebirthLoop then
            pcall(runRebirthLoop)
            pcall(function()
                rebirthStatusLabel:SetText("[" .. RebirthState.phase .. "] " .. RebirthState.note)
            end)
        end
    end
end)

-----------------------------------------------
-- 2. DUAL EYES & AUTO SPINNER TAB (SLOT SUPPORT)
-----------------------------------------------
sections.DualLeft:Header({ Name = "Dual Eyes & Tenseigan Awakening Engine" })

sections.DualLeft:Toggle({
    Name = "Smart Auto Quest & DNA Boss Scanner",
    Default = false,
    Callback = function(v)
        Config.AutoSmartQuestTracker = v
        if v then
            Config.AutoFarm = true
            Window:Notify({ Title = "Smart Quest Scanner", Description = "Reading active quests & auto-targeting DNA Bosses!", Lifetime = 5 })
        else
            removeAnchor()
        end
    end
})

sections.DualLeft:Toggle({
    Name = "Auto Complete Dual Eyes Quests",
    Default = false,
    Callback = function(v)
        Config.AutoDualEyesQuest = v
        if v then
            Window:Notify({ Title = "Dual Eyes Quest Engine", Description = "Auto accepting, farming mobs, and submitting Dual Eyes Quests!", Lifetime = 5 })
        end
    end
})

sections.DualLeft:Toggle({
    Name = "Auto Farm Mugetsu (Tenseigan - 5x Eye Fragments)",
    Default = false,
    Callback = function(v)
        if v then
            Config.TargetType = "Mugetsu"
            Config.AutoFarm = true
            Window:Notify({ Title = "Tenseigan Farm", Description = "Targeting Mugetsu for 5x Reincarnation Eye Fragments!", Lifetime = 5 })
        else
            Config.AutoFarm = false
            removeAnchor()
        end
    end
})

sections.DualLeft:Button({
    Name = "Set Target: Mugetsu (Reincarnation Eye Boss)",
    Callback = function()
        Config.TargetType = "Mugetsu"
        Config.AutoFarm = true
        Window:Notify({ Title = "Tenseigan Target", Description = "Farming Mugetsu for Reincarnation Eye Fragments!", Lifetime = 4 })
    end
})

sections.DualLeft:Toggle({
    Name = "Auto Farm Dual Eyes (Sharingan/Rinnegan/Crimson)",
    Default = false,
    Callback = function(v)
        Config.AutoDualEyesFarm = v
        if v then
            Config.TargetType = "Dual Eyes (Sharingan/Rinnegan/Crimson)"
            Config.AutoFarm = true
            Window:Notify({ Title = "Dual Eyes Farm", Description = "Auto Farming Dual Eyes & Eye Boss Targets!", Lifetime = 4 })
        else
            Config.AutoFarm = false
            removeAnchor()
        end
    end
})

sections.DualLeft:Button({
    Name = "Teleport to Red Eyes Hideout (Dual Eyes NPC)",
    Callback = function()
        smartTeleportToZone("Red Eyes Hideout (Dual Eyes)")
    end
})

sections.DualRight:Header({ Name = "Main Menu Slot Auto Spinner" })

sections.DualRight:Dropdown({
    Name = "Select Target Spin Slot",
    Search = false,
    Options = {"Slot 1", "Slot 2", "Slot 3", "Slot 4"},
    Default = "Slot 1",
    Callback = function(v)
        local num = tonumber(v:match("%d+")) or 1
        Config.SelectedSlot = num
    end
})

sections.DualRight:Dropdown({
    Name = "Target Clan / Sharingan / Family",
    Search = true,
    Options = {
        "Uchiha", "Raven", "RavenSpirit", "Itachi", "Obito", "Madara", "Shisui", 
        "Rinnegan", "CrimsonEyes", "Red Eyes", "Kamui", "Amaterasu", "Kotoamatsukami",
        "Senju", "Uzumaki", "Namikaze", "Rikudou", "Bone", "Hyuga", "IronSand", 
        "Thousand Hands", "Kaguya", "Aburame", "Bug", "Haruno", "Lee", "Nara", "Sand", 
        "Anbu", "Akatsuki", "Sound", "Mythic", "Legendary", "Rare"
    },
    Default = "Uchiha",
    Callback = function(v) Config.TargetClanRarity = v end
})

local clanSpinToggle = sections.DualRight:Toggle({
    Name = "Auto Spin Clan (Auto-Stops On Hit)",
    Default = false,
    Callback = function(v) Config.AutoSpinClan = v end
})

sections.DualRight:Dropdown({
    Name = "Target Element",
    Search = true,
    Options = {
        "Wood", "Particle", "Black Lightning", "Blue Scorch", "FrostFire", "GoldDust", 
        "Crystal", "Explosion", "Boil", "Ice", "Powder Snow", "Scorch", "Sound", "Typhoon", 
        "Fire", "Water", "Earth", "Lightning", "Wind"
    },
    Default = "Wood",
    Callback = function(v) Config.TargetElementRarity = v end
})

local elementSpinToggle = sections.DualRight:Toggle({
    Name = "Auto Spin Element (Auto-Stops On Hit)",
    Default = false,
    Callback = function(v) Config.AutoSpinElement = v end
})

local eyeSpinToggle = sections.DualRight:Toggle({
    Name = "Auto Spin Eye Abilities",
    Default = false,
    Callback = function(v) Config.AutoSpinEye = v end
})

-----------------------------------------------
-- 3. SAND & SHUKAKU TAB
-----------------------------------------------
sections.SandLeft:Header({ Name = "Yin & Yang Fragment Farm" })

sections.SandLeft:Button({
    Name = "Set Target: Monster of Sand (Optimal Farm)",
    Callback = function()
        Config.TargetType = "Monster of Sand (Yin/Yang Farm)"
        Config.AutoFarm = true
        Window:Notify({ Title = "Sand Farm", Description = "Auto Farming Monster of Sand for Yin & Yang Fragments!", Lifetime = 4 })
    end
})

sections.SandLeft:Button({
    Name = "Teleport to Isago NPC (Scroll Merchant)",
    Callback = function()
        smartTeleportToNPC("Isago")
    end
})

sections.SandLeft:Button({
    Name = "Craft Scroll of Soulcast (Black Market)",
    Callback = function()
        -- VERIFIED: "Scroll of Soulcast" is a Black Market CRAFTING recipe
        -- (750x Chi Essence), not a shop item — payload is CraftingServiceRemote:
        -- FireServer("NormalCraft", { recipeName = "..." })
        if Remotes.CraftingService then
            pcall(function()
                Remotes.CraftingService:FireServer("NormalCraft", { recipeName = "Scroll of Soulcast" })
            end)
            Window:Notify({ Title = "Crafting", Description = "Craft request sent for Scroll of Soulcast (needs 750 Chi Essence).", Lifetime = 5 })
        else
            Window:Notify({ Title = "Crafting", Description = "CraftingService remote not found.", Lifetime = 4 })
        end
    end
})

sections.SandRight:Header({ Name = "Shukaku Stage 2 Quiz Auto-Solver" })

sections.SandRight:Dropdown({
    Name = "Select Shukaku Variant",
    Search = false,
    Options = {"Variant 1 (Offensive)", "Variant 2 (Defensive)"},
    Default = "Variant 1 (Offensive)",
    Callback = function(v) Config.QuizVariant = v end
})

sections.SandRight:Toggle({
    Name = "Auto-Answer Shukaku Quiz",
    Default = false,
    Callback = function(v) Config.AutoShukakuQuiz = v end
})

-----------------------------------------------
-- 4. CHAKRA & MODES TAB
-----------------------------------------------
sections.ChakraLeft:Header({ Name = "Infinite Reserves" })

sections.ChakraLeft:Toggle({
    Name = "Infinite Chakra",
    Default = false,
    Callback = function(v) Config.InfiniteChakra = v end
})

sections.ChakraLeft:Toggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(v) Config.InfiniteStamina = v end
})

sections.ChakraRight:Header({ Name = "Mode Auto-Activators" })

sections.ChakraRight:Toggle({
    Name = "Auto Rinnegan Mode",
    Default = false,
    Callback = function(v) Config.AutoRinnegan = v end
})

sections.ChakraRight:Toggle({
    Name = "Auto Tailed Beast (KCM / Shukaku)",
    Default = false,
    Callback = function(v) Config.AutoTailedBeast = v end
})

sections.ChakraRight:Toggle({
    Name = "Auto Susanoo / Crimson Skeleton",
    Default = false,
    Callback = function(v) Config.AutoSusanoo = v end
})

sections.ChakraRight:Toggle({
    Name = "Auto Evolve Sharingan (Tomoe)",
    Default = false,
    Callback = function(v) Config.AutoTomoeEvolve = v end
})

sections.ChakraRight:Toggle({
    Name = "Infinite Mount Dash & Flight",
    Default = false,
    Callback = function(v) Config.InfiniteMountDash = v end
})

-----------------------------------------------
-- 5. GLOBAL BOSSES TAB
-----------------------------------------------
sections.BossesLeft:Header({ Name = "Bone Boss (Global 3H Spawn)" })

sections.BossesLeft:Toggle({
    Name = "Bone Boss Spawn Detector",
    Default = true,
    Callback = function(v) Config.BoneBossTracker = v end
})

sections.BossesLeft:Toggle({
    Name = "Auto Teleport When Bone Spawns",
    Default = false,
    Callback = function(v) Config.AutoTeleportBone = v end
})

sections.BossesLeft:Button({
    Name = "Check Bone Boss Spawn Status",
    Callback = function()
        local found, hpLabel = nil, ""
        -- FIX: old check matched ANY instance containing "bone" (incl. character accessories).
        -- Only count rigs with a living Humanoid named like the boss.
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                local n = obj.Name:lower()
                if n:find("bone") and not n:find("boneplate") then
                    local h = obj:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 and h.MaxHealth > 1000 then
                        found = obj
                        hpLabel = string.format(" (HP: %d/%d)", math.floor(h.Health), math.floor(h.MaxHealth))
                        break
                    end
                end
            end
        end
        if found then
            Window:Notify({ Title = "Global Boss Alert", Description = "BONE BOSS IS ALIVE" .. hpLabel .. "!", Lifetime = 6 })
        else
            Window:Notify({ Title = "Global Boss Status", Description = "Bone Boss is not currently spawned.", Lifetime = 5 })
        end
    end
})

-----------------------------------------------
-- 6. RAIDS & MINIGAMES TAB
-----------------------------------------------
sections.RaidsLeft:Header({ Name = "Nine-Tails (Kurama) Raid Automation" })

sections.RaidsLeft:Toggle({
    Name = "Auto Raid Kurama",
    Default = false,
    Callback = function(v)
        Config.AutoKuramaRaid = v
        if v then
            startAutoKuramaRaid()
            Window:Notify({
                Title = "Kurama Raid",
                Description = "Raid enabled: native punches, equipped moves, and attack avoidance. Scanning for Kurama...",
                Lifetime = 3
            })
        elseif not Config.AutoPlayKuramaFight and KuramaCombat.Stop then
            KuramaCombat.Stop(true)
        end
    end
})

sections.RaidsLeft:Toggle({Name = "Raid Punches (M1)", Default = true,
    Callback = function(v) Config.KuramaPunches = v; if not v and KuramaCombat.Release then KuramaCombat.Release() end; saveSettings() end})
sections.RaidsLeft:Toggle({Name = "Raid Moves (Z / X / C / V)", Default = true,
    Callback = function(v) Config.KuramaMoves = v; if not v and KuramaCombat.Release then KuramaCombat.Release() end; saveSettings() end})
sections.RaidsLeft:Toggle({Name = "Avoid Kurama Attack Wind-ups", Default = true,
    Callback = function(v) Config.KuramaAvoidAttacks = v; saveSettings() end})
sections.RaidsLeft:Slider({Name = "Kurama Melee Distance", Default = 4, Minimum = 2, Maximum = 6, Precision = 1,
    Callback = function(v) Config.KuramaMeleeDistance = v; saveSettings() end})
sections.RaidsLeft:Slider({Name = "Kurama Retreat Distance", Default = 160, Minimum = 150, Maximum = 240, Precision = 0,
    Callback = function(v) Config.KuramaDodgeRadius = v; saveSettings() end})
sections.RaidsLeft:Slider({Name = "Red Circle Safety Buffer", Default = 24, Minimum = 12, Maximum = 80, Precision = 0,
    Callback = function(v) Config.KuramaCircleBuffer = v; saveSettings() end})
sections.RaidsLeft:Slider({Name = "Red Circle Recovery Delay", Default = 2.5, Minimum = 1, Maximum = 8, Precision = 1,
    Callback = function(v) Config.KuramaCircleRecovery = v; saveSettings() end})
Window.RaidStatus = sections.RaidsLeft:Label({Text = "Combat: idle", Wrap = true})
sections.RaidsLeft:Label({Text = "Red-circle priority: nested warnings, buffered escape spots, and post-impact hold. Attacks stay paused until the return spot is clear. Not invulnerability.", Wrap = true})

sections.RaidsLeft:Slider({
    Name = "Kurama Hover Height",
    Default = 18,
    Minimum = 8,
    Maximum = 40,
    Precision = 0,
    Callback = function(v) Config.KuramaHeight = v end
})

sections.RaidsLeft:Toggle({
    Name = "Auto Collect Raid Chests & Loot",
    Default = true,
    Callback = function(v) Config.AutoCollectRaidLoot = v end
})

sections.RaidsLeft:Toggle({
    Name = "Auto Enter Raid Gate / Portal",
    Default = true,
    Callback = function(v) Config.AutoEnterRaidGate = v end
})

sections.RaidsLeft:Button({
    Name = "Check Kurama Status",
    Callback = function()
        local k = findKurama()
        if k and isModelAlive(k.Model) then
            local dist = 0
            if hrp and k.Root then
                dist = math.floor((k.Root.Position - hrp.Position).Magnitude)
            end
            Window:Notify({
                Title = "Kurama Active!",
                Description = string.format("Kurama Found! HP: %d / %d (Dist: %d studs)", math.floor(k.Hum.Health), math.floor(k.Hum.MaxHealth), dist),
                Lifetime = 5
            })
        else
            Window:Notify({
                Title = "Kurama Status",
                Description = "Kurama is not active in this server. Waiting for raid or entrance portal.",
                Lifetime = 4
            })
        end
    end
})

sections.RaidsLeft:Button({
    Name = "Teleport Directly to Kurama",
    Callback = function()
        local k = findKurama()
        if k and k.Root and char and hrp then
            char:PivotTo(CFrame.new(k.Root.Position + Vector3.new(0, Config.KuramaHeight, 0), k.Root.Position))
            hrp.CFrame = CFrame.new(k.Root.Position + Vector3.new(0, Config.KuramaHeight, 0), k.Root.Position)
            Window:Notify({
                Title = "Teleported!",
                Description = "Teleported directly above Kurama.",
                Lifetime = 3
            })
        else
            Window:Notify({
                Title = "Kurama Not Found",
                Description = "Cannot teleport — Kurama is not currently spawned in this server.",
                Lifetime = 3
            })
        end
    end
})

sections.RaidsLeft:Divider()
sections.RaidsLeft:Header({ Name = "Other Raids" })

sections.RaidsLeft:Toggle({
    Name = "Auto Win Raven Raid",
    Default = false,
    Callback = function(v) Config.AutoRavenRaid = v end
})

sections.RaidsRight:Header({ Name = "Ninja Exams & Minigames" })

sections.RaidsRight:Toggle({
    Name = "Auto Pass Written & Chunin Exams",
    Default = false,
    Callback = function(v) Config.AutoExams = v end
})

sections.RaidsRight:Toggle({
    Name = "Auto-Win Balancing Minigame",
    Default = false,
    Callback = function(v) Config.AutoBalancing = v end
})

sections.RaidsRight:Toggle({
    Name = "Auto-Win Chakra Charge Minigame",
    Default = false,
    Callback = function(v) Config.AutoChakraMinigame = v end
})

-----------------------------------------------
-- 7. TRAINING & SKILLS TAB
-----------------------------------------------
sections.TrainingLeft:Header({ Name = "Skill Tree & Ninja Ranks" })

sections.TrainingLeft:Toggle({
    Name = "Auto Unlock Skill Tree",
    Default = false,
    Callback = function(v) Config.AutoSkillTree = v end
})

sections.TrainingLeft:Toggle({
    Name = "Auto Rank Up Ninja Rank",
    Default = false,
    Callback = function(v) Config.AutoRankUp = v end
})

sections.TrainingRight:Header({ Name = "Mastery & Meditation" })

sections.TrainingRight:Toggle({
    Name = "Auto Meditate",
    Default = false,
    Callback = function(v) Config.AutoMeditate = v end
})

sections.TrainingRight:Toggle({
    Name = "Auto Train Mastery",
    Default = false,
    Callback = function(v) Config.AutoMastery = v end
})

-----------------------------------------------
-- 8. TELEPORTS & NPCS TAB (SMART LANDMARKS ENGINE)
-----------------------------------------------
sections.TeleportsLeft:Header({ Name = "Smart Zone & Arena Teleports" })

sections.TeleportsLeft:Dropdown({
    Name = "Select Landmark / Zone",
    Search = true,
    Options = TeleportNames,
    Default = "Training Ground (Attack Dummies)",
    Callback = function(v) Config.SelectedTeleport = v end
})

sections.TeleportsLeft:Button({
    Name = "Teleport to Selected Zone",
    Callback = function()
        smartTeleportToZone(Config.SelectedTeleport)
    end
})

sections.TeleportsLeft:Button({
    Name = "SAVE CURRENT POS TO SELECTED ZONE",
    Callback = function()
        if hrp then
            local pos = hrp.Position
            FallbackTeleports[Config.SelectedTeleport] = pos
            Window:Notify({ Title = "Position Saved!", Description = "Saved your exact location to " .. Config.SelectedTeleport .. "!", Lifetime = 5 })
            print(string.format('["%s"] = Vector3.new(%.1f, %.1f, %.1f),', Config.SelectedTeleport, pos.X, pos.Y, pos.Z))
        end
    end
})

sections.TeleportsRight:Header({ Name = "NPC & Mentor Teleports" })

sections.TeleportsRight:Dropdown({
    Name = "Select NPC",
    Search = true,
    Options = NPCNames,
    Default = "Red Eyes Leader",
    Callback = function(v) Config.SelectedNPCTp = v end
})

sections.TeleportsRight:Button({
    Name = "Teleport to NPC",
    Callback = function()
        smartTeleportToNPC(Config.SelectedNPCTp)
    end
})

-----------------------------------------------
-- 9. QUESTS & CODES TAB
-----------------------------------------------
sections.QuestsLeft:Header({ Name = "Quests & Daily Rewards" })

sections.QuestsLeft:Toggle({
    Name = "Auto Level Quest Engine (Level-Based NPC + Farm Sync)",
    Default = false,
    Callback = function(v)
        Config.AutoLevelQuest = v
        if v then
            Window:Notify({
                Title = "Level Quest Engine",
                Description = "Active — reads your level every 6s, TPs to correct NPC, accepts quests & syncs farm target.",
                Lifetime = 5
            })
        end
    end
})

sections.QuestsLeft:Toggle({
    Name = "Auto Accept & Complete Quests",
    Default = false,
    Callback = function(v) Config.AutoQuests = v end
})

sections.QuestsLeft:Toggle({
    Name = "Auto Claim Daily Rewards",
    Default = false,
    Callback = function(v) Config.AutoClaimDailies = v end
})

sections.QuestsLeft:Button({
    Name = "Redeem ALL 24+ Promo Codes",
    Callback = function()
        if Remotes.CodeRemote then
            for _, code in ipairs(NinjaCodes) do
                pcall(function()
                    if Remotes.CodeRemote:IsA("RemoteEvent") then
                        Remotes.CodeRemote:FireServer(code)
                    else
                        Remotes.CodeRemote:InvokeServer(code)
                    end
                end)
                task.wait(0.15)
            end
            Window:Notify({ Title = "Promo Code Redeemer", Description = "Successfully attempted redemptions for all 24+ codes!", Lifetime = 4 })
        end
    end
})

sections.QuestsRight:Header({ Name = "Attribute Allocator" })

sections.QuestsRight:Toggle({
    Name = "Auto Allocate Stats",
    Default = false,
    Callback = function(v) Config.AutoAllocateStats = v end
})

-----------------------------------------------
-- 10. PLAYER & AUTOEXEC TAB
-----------------------------------------------
sections.PlayerLeft:Header({ Name = "Movement Hacks" })

sections.PlayerLeft:Toggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v) Config.Noclip = v end
})

sections.PlayerLeft:Toggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(v) Config.SpeedBoost = v end
})

sections.PlayerLeft:Slider({
    Name = "WalkSpeed",
    Default = 32,
    Minimum = 16,
    Maximum = 200,
    Precision = 0,
    Callback = function(v) Config.SpeedValue = v end
})

sections.PlayerLeft:Toggle({
    Name = "Jump Boost",
    Default = false,
    Callback = function(v) Config.JumpBoost = v end
})

sections.PlayerLeft:Slider({
    Name = "JumpPower",
    Default = 100,
    Minimum = 50,
    Maximum = 300,
    Precision = 0,
    Callback = function(v) Config.JumpValue = v end
})

sections.PlayerRight:Header({ Name = "Auto-Execute On Join (Ninja Time)" })

Window.ExecutorStatus = sections.PlayerRight:Label({Text = "Executor: " .. NinjaRuntime.Executor
    .. "\nTeleport queue: " .. (NinjaRuntime.QueueFunction and "available" or "unsupported")
    .. " | Config files: " .. (ConfigStore.Available() and "available" or "unsupported") .. "\nNinja Time GameId: " .. NinjaRuntime.GameId})
sections.PlayerRight:Toggle({Name = "Auto-Execute After Teleport (Ninja Time Only)", Default = false,
    Callback = function(value)
        Config.AutoExecute = value
        local ok, err = NinjaRuntime.UpdateState()
        saveSettings()
        Window:Notify({Title = "Auto-Execute", Description = not ok and tostring(err)
            or value and "Enabled for Ninja Time teleports. For fresh joins, export the loader and install it in your executor's real auto-execute folder."
            or "Disabled. Previously queued loaders will check the disabled flag."})
    end})
sections.PlayerRight:Input({Name = "Auto-Execute Script File or HTTPS URL", Default = "NinjaTime.lua",
    Placeholder = "NinjaTime.lua (executor workspace) or https://...",
    Callback = function(value)
        Config.AutoExecuteSource = value
        if Config.AutoExecute then NinjaRuntime.UpdateState() end
    end})
sections.PlayerRight:Label({Text = "Local file: copy this updated NinjaTime.lua into your executor workspace. URLs must point to YOUR updated script; no old third-party loader is used."})
sections.PlayerRight:Button({Name = "Check Auto-Execute / Queue Next Teleport", Callback = function()
    local ok, err = NinjaRuntime.Queue()
    Window:Notify({Title = "Auto-Execute", Description = ok and "Queued for the next teleport; only GameId 3110388936 will run." or tostring(err)})
end})
sections.PlayerRight:Button({Name = "Export Auto-Execute Loader", Callback = function()
    local ok, err = pcall(function()
        local kind, source = NinjaRuntime.Source(Config.AutoExecuteSource)
        if kind == "file" then assert(type(isfile) == "function" and isfile(source), "Copy the updated script into your executor workspace first") end
        local written, reason = NinjaRuntime.UpdateState()
        assert(written, reason)
        assert(type(writefile) == "function", "Executor cannot export files")
        writefile("NinjaTime_AutoExec.lua", NinjaRuntime.Loader())
    end)
    Window:Notify({Title = "Auto-Execute", Description = ok
        and "Exported NinjaTime_AutoExec.lua to the executor workspace. Move it into the executor's actual auto-execute folder and enable Auto-Execute here."
        or tostring(err), Lifetime = 8})
end})

sections.PlayerRight:Header({ Name = "ESP Visuals" })

sections.PlayerRight:Toggle({
    Name = "Mob & Boss ESP",
    Default = false,
    Callback = function(v) Config.MobESP = v end
})

sections.PlayerRight:Toggle({
    Name = "NPC ESP",
    Default = false,
    Callback = function(v) Config.NPCESP = v end
})

-----------------------------------------------
-- 11. UTILITIES & HUD TAB
-----------------------------------------------
sections.UtilLeft:Header({ Name = "Anti-AFK & Survivability" })

sections.UtilLeft:Toggle({
    Name = "Anti-AFK (Random inputs every 4 min)",
    Default = false,
    Callback = function(v) Config.AntiAFK = v end
})

sections.UtilLeft:Toggle({
    Name = "Smart Mob Relocator (TP to spawn if no mobs 10s)",
    Default = false,
    Callback = function(v) Config.SmartRelocator = v end
})

sections.UtilLeft:Toggle({
    Name = "Auto Server Hop (no mobs for 30s)",
    Default = false,
    Callback = function(v) Config.AutoServerHop = v end
})

sections.UtilLeft:Toggle({
    Name = "Auto Chest / Drop Collector",
    Default = false,
    Callback = function(v) Config.AutoChestCollect = v end
})

sections.UtilLeft:Toggle({
    Name = "Auto Training Room (Attack Dummies — Mastery Grind)",
    Default = false,
    Callback = function(v)
        Config.AutoTrainingRoom = v
        if v then
            Window:Notify({ Title = "Training Room", Description = "Farming Attack Dummies for Mastery XP!", Lifetime = 4 })
        end
    end
})

sections.UtilLeft:Divider()
sections.UtilLeft:Header({ Name = "Smart Stat Allocator" })

sections.UtilLeft:Dropdown({
    Name = "Stat Priority",
    Options = { "Ninjutsu", "Taijutsu", "Speed", "Defense", "Chakra", "Health" },
    Default = "Ninjutsu",
    Callback = function(v) Config.StatPriority = v end
})

sections.UtilLeft:Button({
    Name = "Allocate Stats Now (Priority)",
    Callback = function()
        if Remotes.AttributesRemote then
            -- VERIFIED payload: InvokeServer({ Job = "IncreaseLevel", ID = statID })
            local spent = 0
            for _ = 1, 50 do
                if not allocateOnePoint(Config.StatPriority) then break end
                spent += 1
            end
            Window:Notify({ Title = "Stat Allocator", Description = spent > 0 and ("Pushed " .. spent .. " points into " .. Config.StatPriority) or "No free points to spend (or rejected).", Lifetime = 4 })
        end
    end
})

sections.UtilRight:Header({ Name = "Boss Spawn Notifier" })

sections.UtilRight:Toggle({
    Name = "Boss Spawn Notifier (Notify when boss appears)",
    Default = true,
    Callback = function(v) Config.BossNotifier = v end
})

sections.UtilRight:Toggle({
    Name = "Auto-TP to Boss on Spawn",
    Default = false,
    Callback = function(v) Config.AutoTPOnBossSpawn = v end
})

sections.UtilRight:Divider()
sections.UtilRight:Toggle({
    Name = "Active Features / Keybinds List HUD",
    Default = true,
    Callback = function(v)
        Config.ShowActiveFeaturesHUD = v
        if not v then
            pcall(function()
                local existing = plr.PlayerGui:FindFirstChild("NTFeaturesHUD")
                if existing then existing:Destroy() end
            end)
        end
    end
})

sections.UtilRight:Toggle({
    Name = "Farm Stats HUD (Level / Target / Kills / K/min)",
    Default = false,
    Callback = function(v)
        Config.ShowFarmHUD = v
        if not v then
            pcall(function()
                local existing = plr.PlayerGui:FindFirstChild("NTFarmHUD")
                if existing then existing:Destroy() end
            end)
        end
    end
})

sections.UtilRight:Toggle({
    Name = "Quest Progress HUD (Active quest + kill count)",
    Default = false,
    Callback = function(v)
        Config.ShowQuestHUD = v
        if not v then
            pcall(function()
                local existing = plr.PlayerGui:FindFirstChild("NTQuestHUD")
                if existing then existing:Destroy() end
            end)
        end
    end
})

-----------------------------------------------
-- DYNAMIC QUEST & DNA SCANNER FUNCTION
-----------------------------------------------
local function scanActiveQuestObjective()
    if not ScriptRunning then return "" end
    local questText = ""
    pcall(function()
        local gui = plr:FindFirstChild("PlayerGui")
        if gui then
            for _, descendant in ipairs(gui:GetDescendants()) do
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    local text = descendant.Text:lower()
                    if text:find("dna") or text:find("boss") or text:find("mugetsu") or text:find("fragment") or text:find("red eye") or text:find("defeat") or text:find("collect") then
                        questText = questText .. " " .. text
                    end
                end
            end
        end
    end)
    return questText
end

-----------------------------------------------
-- MODEL & ROOT HELPERS
-----------------------------------------------
isModelAlive = function(model)
    if not model or not model.Parent then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    return h and (h.Health > 0)
end

local function getEntityRoot(model)
    if not model then return nil end
    local entityHumanoid = model:FindFirstChildOfClass("Humanoid")
    if entityHumanoid and entityHumanoid.RootPart then return entityHumanoid.RootPart end
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("RootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("LowerTorso")
        or model:FindFirstChild("Head")
        or model:FindFirstChildOfClass("BasePart")
end

local function getEntitySearchContainers()
    -- ipairs stops at the first nil: never put optional instances into an array literal.
    local containers = {}
    for _, name in ipairs({"Raids", "Bosses", "Dungeons", "Entities", "EntitiesReplication", "Mobs", "World"}) do
        local container = WS:FindFirstChild(name)
        if container then table.insert(containers, container) end
    end
    table.insert(containers, WS)
    return containers
end

-----------------------------------------------
-- PROXIMITY PROMPT ENGINE (RAID ENTRANCE & CHESTS)
-----------------------------------------------
local CachedPrompts = {}
local function safeFirePrompt(prompt)
    -- FIX: cached prompts can be destroyed between scans -> guard instead of erroring every loop
    if typeof(prompt) ~= "Instance" or not prompt.Parent or not prompt.Enabled then return end
    pcall(function()
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        elseif prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end
    end)
end

local function interactWithPrompts(keywords)
    for _, p in ipairs(CachedPrompts) do
        if p and p.Parent and p.Enabled then
            local act = (p.ActionText or ""):lower()
            local obj = (p.ObjectText or ""):lower()
            local combined = act .. " " .. obj
            for _, kw in ipairs(keywords) do
                if combined:find(kw) then
                    safeFirePrompt(p)
                    break
                end
            end
        end
    end
end

task.spawn(function()
    while ScriptRunning do
        pcall(function()
            local pr = {}
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    table.insert(pr, obj)
                end
            end
            CachedPrompts = pr
        end)
        task.wait(1.5)
    end
end)

-----------------------------------------------
-- NINE-TAILS (KURAMA) RAID RESOLVER & ENGINE
-----------------------------------------------
local kuramaCache = {target = nil, nextScan = 0}
local function isKuramaName(name)
    local lower = name:lower()
    for _, alias in ipairs({"kurama", "koroma", "kyuubi", "nine tails", "nine-tails", "ninetail"}) do
        if lower:find(alias, 1, true) then return true end
    end
    return false
end

findKurama = function()
    if not ScriptRunning then return nil end
    local cached = kuramaCache.target
    if cached and cached.Model:IsDescendantOf(WS) and isModelAlive(cached.Model)
        and not Players:GetPlayerFromCharacter(cached.Model) then
        local root = getEntityRoot(cached.Model)
        if root and root:IsA("BasePart") then
            cached.Root = root
            cached.Hum = cached.Model:FindFirstChildOfClass("Humanoid")
            return cached
        end
    end
    if cached then kuramaCache.nextScan = 0 end
    kuramaCache.target = nil
    if tick() < kuramaCache.nextScan then return nil end
    kuramaCache.nextScan = tick() + 1

    -- Walk folders/models, including nested raid rigs, without a full GetDescendants allocation.
    local visited = {}
    local function scan(container)
        if visited[container] then return nil end
        visited[container] = true
        for _, ent in ipairs(container:GetChildren()) do
            if ent ~= char and (ent:IsA("Folder") or ent:IsA("Model"))
                and not (ent:IsA("Model") and Players:GetPlayerFromCharacter(ent)) then
                local entHum = ent:IsA("Model") and ent:FindFirstChildOfClass("Humanoid") or nil
                if entHum and entHum.Health > 0 and isKuramaName(ent.Name) then
                    local entRoot = getEntityRoot(ent)
                    if entRoot and entRoot:IsA("BasePart") then
                        return {Model = ent, Root = entRoot, Hum = entHum, Name = ent.Name}
                    end
                end
                -- Living rigs are leaves; do not mistake their accessories for bosses.
                if not entHum then
                    local nested = scan(ent)
                    if nested then return nested end
                end
            end
        end
        return nil
    end
    for _, container in ipairs(getEntitySearchContainers()) do
        local target = scan(container)
        if target then
            kuramaCache.target = target
            return target
        end
    end
    return nil
end

local kuramaRaidRunning = false
local lastKuramaError = -math.huge
local function reportKuramaError(err)
    Window.LastError = tostring(err)
    if tick() - lastKuramaError >= 5 then
        lastKuramaError = tick()
        warn("[Kurama Raid] " .. tostring(err))
    end
end

-- Client combat contract from the supplied dump: InputHandler:FireAction("M1", bool)
-- and FireAction("AbilityKeybind", slot, pressed, alternate). Do not start a second
-- Equipment/AbilityManager, fabricate HitConnection reports, or spam every slot.
KuramaCombat.State = {untilTime = 0, nextMove = 0, nextSlot = 1, generation = 0, hazards = {}, ghosts = {}, seen = {}}
function KuramaCombat.Input()
    if KuramaCombat.Handler then return KuramaCombat.Handler end
    if tick() < (KuramaCombat.NextInputScan or 0) then return nil end
    KuramaCombat.NextInputScan = tick() + 3
    local starter = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    local core = starter and starter:FindFirstChild("Core")
    local misc = core and core:FindFirstChild("Misc")
    local module = misc and misc:FindFirstChild("InputHandler")
    if module then
        local ok, handler = pcall(require, module)
        if ok and type(handler) == "table" and type(handler.FireAction) == "function" then
            KuramaCombat.Handler = handler
        end
    end
    return KuramaCombat.Handler
end
function KuramaCombat.Punch(pressed)
    local state = KuramaCombat.State
    if state.punching == pressed then return end
    local generation, player = state.generation, char
    local handler = KuramaCombat.Input()
    if pressed and (not ScriptRunning or char ~= player or generation ~= state.generation
        or not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight)
        or (Config.KuramaAvoidAttacks and tick() < state.untilTime)) then return end
    if handler then
        handler:FireAction("M1", pressed)
    elseif VIM then
        -- Actual input fallback, never a forged damage packet.
        local camera = WS.CurrentCamera
        local size = camera and camera.ViewportSize or Vector2.new(800, 600)
        VIM:SendMouseButtonEvent(size.X / 2, size.Y / 2, 0, pressed, game, 0)
    else
        error("No native InputHandler or virtual input available for raid punches")
    end
    state.punching = pressed
end
function KuramaCombat.Release()
    local state = KuramaCombat.State
    state.generation += 1
    if state.punching then pcall(KuramaCombat.Punch, false) end
    if state.slot then
        local slot = state.slot
        state.slot = nil
        -- Release must not wait behind a yielding KeyPressed request, or frozen controls.
        if Remotes.AbilityEvent then pcall(function() Remotes.AbilityEvent:FireServer("KeyReleased", slot) end) end
    end
end
function KuramaCombat.Stop(reset)
    KuramaCombat.Release()
    local state = KuramaCombat.State
    if reset then
        if state.animationConn then state.animationConn:Disconnect(); state.animationConn = nil end
        if state.visualConn then state.visualConn:Disconnect(); state.visualConn = nil end
        if state.removalConn then state.removalConn:Disconnect(); state.removalConn = nil end
        state.boss, state.player, state.visuals, state.animator = nil, nil, nil, nil
        state.untilTime, state.retreat, state.hazards, state.seen = 0, nil, {}, {}
        state.ghosts, state.safePosition = {}, nil
    end
    Window.RaidAction = "Idle"
end
function KuramaCombat.Cast(slot)
    local state = KuramaCombat.State
    if state.busy or not ScriptRunning or not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) then return false end
    if Config.KuramaAvoidAttacks and tick() < state.untilTime then return false end
    KuramaCombat.Release()
    local generation, player = state.generation, char
    local token = {}
    state.busy, state.slot = token, slot
    state.releaseAt = tick() + 0.2
    task.spawn(function()
        local ok, err = pcall(function()
            if not ScriptRunning or state.generation ~= generation or char ~= player then return end
            local handler = KuramaCombat.Input()
            if not ScriptRunning or state.generation ~= generation or char ~= player then return end
            if handler then
                handler:FireAction("AbilityKeybind", slot, true, false)
            elseif Remotes.AbilityFunction then
                Remotes.AbilityFunction:InvokeServer("KeyPressed", slot, false)
            else
                error("No native ability input or AbilityFunction available for raid moves")
            end
        end)
        -- KeyPressed can yield; always pair it with KeyReleased, even after a dodge/unload.
        if Remotes.AbilityEvent then pcall(function() Remotes.AbilityEvent:FireServer("KeyReleased", slot) end) end
        if state.busy == token then
            state.busy = nil
            if state.slot == slot then state.slot = nil end
        end
        if not ok then reportKuramaError(err) end
    end)
    return true
end
function KuramaCombat.Warn(reason, duration)
    local state = KuramaCombat.State
    state.untilTime = math.max(state.untilTime, tick() + duration)
    state.reason = reason
    KuramaCombat.Release()
end
function KuramaCombat.Track(track, replay)
    local state = KuramaCombat.State
    if not Config.KuramaAvoidAttacks or (state.seen[track] and not replay) then return end
    state.seen[track] = true
    local animation = track.Animation
    local name = (animation and animation.Name or track.Name or ""):lower()
    local id = animation and animation.AnimationId
    if id and state.animationNames[id] then name = state.animationNames[id] end
    local attack = name:find("claw") or name:find("garrada") or name:find("slash") or name:find("stomp")
        or name:find("roar") or name:find("bijuu") or name:find("bomb") or name:find("attack")
        or name:find("punch") or name:find("m1") or name:find("combat")
    if attack then
        local linger = (name:find("bijuu") or name:find("bomb")) and 7 or name:find("stomp") and 4.5
            or name:find("roar") and 3.5 or 1.4
        local remaining = math.max(0, (track.Length or 0) - (track.TimePosition or 0)) / math.max(math.abs(track.Speed or 1), 0.1)
        KuramaCombat.Warn("Animation: " .. name, math.clamp(math.max(remaining + 0.6, linger), 1.4, 10))
    end
end
function KuramaCombat.Geometry(obj)
    if obj:IsA("BasePart") then return obj.Position, obj.Size end
    if obj:IsA("Model") then
        local ok, cf, size = pcall(obj.GetBoundingBox, obj)
        if ok and size.Magnitude > 0 then return cf.Position, size end
    end
    -- Named circle folders/models can have no PrimaryPart. Include their actual parts.
    if obj:IsA("Model") or obj:IsA("Folder") then
        local low, high
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") and part.Position and part.Size then
                local a, b = part.Position - part.Size * 0.5, part.Position + part.Size * 0.5
                low = low and Vector3.new(math.min(low.X, a.X), math.min(low.Y, a.Y), math.min(low.Z, a.Z)) or a
                high = high and Vector3.new(math.max(high.X, b.X), math.max(high.Y, b.Y), math.max(high.Z, b.Z)) or b
            end
        end
        if low then return (low + high) * 0.5, high - low end
    end
end
function KuramaCombat.Visual(obj)
    if not obj.Parent or (char and obj:IsDescendantOf(char)) then return false end
    local name = obj.Name:lower():gsub("[%s_%-]", "")
    local circle = name == "indicator" or name == "attackindicator" or name == "redcircle"
        or name == "dangerzone" or name == "warningcircle" or name == "circle"
    -- Also recognize unnamed flat red effect parts, not ordinary tail/body pieces.
    if not circle and obj:IsA("BasePart") and obj.Color and obj.Size then
        local color, size = obj.Color, obj.Size
        local flat = math.min(size.X, size.Y, size.Z) <= math.max(size.X, size.Y, size.Z) * 0.2
        local effects = obj.Parent == WS or (KuramaCombat.State.visuals and obj:IsDescendantOf(KuramaCombat.State.visuals))
        circle = effects and flat and color.R > 0.7 and color.R > color.G * 1.6 and color.R > color.B * 1.6
    end
    local blast = name == "move2ball" or name == "impact" or name == "fallimpact" or name == "explosion"
    local volume = name == "charge" or name == "projectile" or name == "roar"
    if circle or blast or volume then
        local state = KuramaCombat.State
        if not state.hazards[obj] then state.hazards[obj] = {circle = circle or blast, name = obj.Name} end
        return true
    end
    return false
end
function KuramaCombat.Forget(obj)
    local state = KuramaCombat.State
    local record = state.hazards[obj]
    if not record then return end
    state.hazards[obj] = nil
    if record.circle and record.position then
        table.insert(state.ghosts, {circle = true, name = record.name .. " impact", position = record.position,
            radius = record.radius, expires = tick() + (Config.KuramaCircleRecovery or 2.5)})
    end
end
function KuramaCombat.Areas()
    local state, areas = KuramaCombat.State, {}
    for obj, record in pairs(state.hazards) do
        if not obj.Parent or not obj:IsDescendantOf(WS) then
            KuramaCombat.Forget(obj)
        else
            local position, size = KuramaCombat.Geometry(obj)
            if position and size then
                -- Preserve the previous target if a pooled circle jumps to a new location.
                if record.circle and record.position and KuramaCombat.FlatDistance(record.position, position) > 8 then
                    table.insert(state.ghosts, {circle = true, name = record.name .. " impact", position = record.position,
                        radius = record.radius, expires = tick() + (Config.KuramaCircleRecovery or 2.5)})
                end
                record.position = position
                local visualRadius = math.max(size.X, size.Y, size.Z) * 0.5
                -- The decorative circle is not proof of the server's exact damage radius.
                local radius = record.circle and math.max(35, visualRadius) + (Config.KuramaCircleBuffer or 24) or visualRadius + 12
                record.radius = math.max(record.radius or 0, radius) -- fading/shrinking VFX must not prematurely shrink the blast zone
                table.insert(areas, record)
            end
        end
    end
    for i = #state.ghosts, 1, -1 do
        local record = state.ghosts[i]
        if tick() >= record.expires then table.remove(state.ghosts, i) else table.insert(areas, record) end
    end
    return areas
end
function KuramaCombat.Bind(boss)
    local state = KuramaCombat.State
    if state.boss ~= boss.Model or state.player ~= char then
        KuramaCombat.Stop(true)
        state.boss, state.player = boss.Model, char
        state.animationNames = {}
        local assets = RS:FindFirstChild("Assets")
        local animations = assets and assets:FindFirstChild("Animations")
        local mobs = animations and animations:FindFirstChild("Mobs")
        local folder = mobs and (mobs:FindFirstChild("Kurama") or mobs:FindFirstChild("Koroma"))
        if folder then
            for _, anim in ipairs(folder:GetDescendants()) do
                if anim:IsA("Animation") then
                    state.animationNames[anim.AnimationId] = (anim.Name .. " " .. anim.Parent.Name):lower()
                end
            end
        end
    end
    local animator = boss.Hum:FindFirstChildOfClass("Animator")
    if not animator then
        local controller = boss.Model:FindFirstChildOfClass("AnimationController")
        animator = controller and controller:FindFirstChildOfClass("Animator")
    end
    if animator ~= state.animator then
        if state.animationConn then state.animationConn:Disconnect() end
        state.animator = animator
        state.seen = setmetatable({}, {__mode = "k"})
        if animator then
            state.animationConn = animator.AnimationPlayed:Connect(function(track)
                if ScriptRunning then
                    local ok, err = pcall(KuramaCombat.Track, track, true)
                    if not ok then reportKuramaError(err) end
                end
            end)
        end
    end
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do KuramaCombat.Track(track, false) end
    end
    local world = WS:FindFirstChild("World")
    local visuals = world and world:FindFirstChild("Visuals")
    if not state.visualConn then
        -- DescendantAdded covers nested circles and other effect containers as well.
        -- React in the spawn event; do not wait for the next 50ms timer or a skill response.
        state.visualConn = WS.DescendantAdded:Connect(function(obj)
            if not ScriptRunning or not KuramaCombat.Visual(obj) or not Config.KuramaAvoidAttacks then return end
            if state.sensing or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then return end
            local activeBoss = kuramaCache.target
            if activeBoss and activeBoss.Model == state.boss then
                local ok, err = pcall(KuramaCombat.Evade, activeBoss)
                if not ok then KuramaCombat.Release(); reportKuramaError(err) end
            end
        end)
        state.removalConn = WS.DescendantRemoving:Connect(KuramaCombat.Forget)
        for _, obj in ipairs(WS:GetChildren()) do
            KuramaCombat.Visual(obj)
            local name = obj.Name:lower()
            if name == "visuals" or name == "effects" or name == "vfx" or name == "raids" then
                for _, nested in ipairs(obj:GetDescendants()) do KuramaCombat.Visual(nested) end
            end
        end
        for _, obj in ipairs(boss.Model:GetDescendants()) do KuramaCombat.Visual(obj) end
    end
    if visuals ~= state.visuals then
        state.visuals = visuals
        if visuals then for _, obj in ipairs(visuals:GetDescendants()) do KuramaCombat.Visual(obj) end end
    end
end
function KuramaCombat.AttackPoint(boss)
    -- Within the dumped 6x6x6 Fist hitbox, rather than 18 studs above it.
    return boss.Root.Position - boss.Root.CFrame.LookVector * math.clamp(Config.KuramaMeleeDistance, 2, 6)
end
function KuramaCombat.FlatDistance(a, b)
    local dx, dz = a.X - b.X, a.Z - b.Z
    return math.sqrt(dx * dx + dz * dz)
end
function KuramaCombat.Clearance(position, areas)
    local margin = math.huge
    for _, area in ipairs(areas) do
        -- Circle/blast footprints stay dangerous regardless of hover height.
        local distance = area.circle and KuramaCombat.FlatDistance(position, area.position) or (position - area.position).Magnitude
        margin = math.min(margin, distance - area.radius)
    end
    return margin
end
function KuramaCombat.Landing(position, boss)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {char, boss.Model}
    if KuramaCombat.State.visuals then table.insert(exclude, KuramaCombat.State.visuals) end
    params.FilterDescendantsInstances = exclude
    params.RespectCanCollide = true
    local hit = WS:Raycast(position + Vector3.new(0, 80, 0), Vector3.new(0, -240, 0), params)
    if not hit or hit.Normal.Y < 0.6 then return nil end
    return hit.Position + Vector3.new(0, math.clamp(Config.KuramaHeight, 8, 40), 0)
end
function KuramaCombat.Escape(boss, areas)
    local state = KuramaCombat.State
    local minimum = 150 -- beyond the diagonal corners of a 200x200 melee AoE box
    local function valid(position)
        return position and KuramaCombat.FlatDistance(position, boss.Root.Position) >= minimum
            and KuramaCombat.Clearance(position, areas) >= 4
    end
    -- Hold a world-space safe spot. Boss motion must not drag the retreat into a circle.
    if valid(state.safePosition) then
        local landing = KuramaCombat.Landing(state.safePosition, boss)
        if valid(landing) then return landing end
    end
    local candidates = {}
    local preferred = math.clamp(Config.KuramaDodgeRadius, minimum, 240)
    for _, radius in ipairs({preferred, minimum, math.min(240, preferred + 50), 240}) do
        for i = 0, 31 do
            local angle = i * math.pi / 16
            local position = boss.Root.Position + Vector3.new(math.cos(angle) * radius, Config.KuramaHeight, math.sin(angle) * radius)
            if valid(position) then table.insert(candidates, position) end
        end
    end
    -- Prefer the shortest safe escape, rather than teleporting through every ring.
    table.sort(candidates, function(a, b)
        local aCost = KuramaCombat.FlatDistance(a, hrp.Position) + math.abs(KuramaCombat.FlatDistance(a, boss.Root.Position) - preferred) * 2
        local bCost = KuramaCombat.FlatDistance(b, hrp.Position) + math.abs(KuramaCombat.FlatDistance(b, boss.Root.Position) - preferred) * 2
        return aCost < bCost
    end)
    for _, position in ipairs(candidates) do
        local landing = KuramaCombat.Landing(position, boss)
        if valid(landing) then return landing end
    end
    return nil -- Never label the "least bad" point inside an overlapping circle as safe.
end
function KuramaCombat.Evade(boss)
    local state = KuramaCombat.State
    state.sensing = true
    local ok, err = pcall(KuramaCombat.Bind, boss)
    state.sensing = false
    if not ok then error(err) end
    local attackPos = KuramaCombat.AttackPoint(boss)
    local areas = KuramaCombat.Areas()
    local circleCount = 0
    if Config.KuramaAvoidAttacks then
        local velocity = hrp.AssemblyLinearVelocity or Vector3.zero
        local predicted = hrp.Position + velocity * 0.25
        for _, area in ipairs(areas) do
            if area.circle then circleCount += 1 end
            local distance = area.circle and KuramaCombat.FlatDistance or function(a, b) return (a - b).Magnitude end
            local nearPlayer = distance(area.position, hrp.Position) <= area.radius
            local nearNext = distance(area.position, predicted) <= area.radius
            local nearAttack = distance(area.position, attackPos) <= area.radius
            local bossVFX = not area.circle and (area.position - boss.Root.Position).Magnitude < 220
            if nearPlayer or nearNext or nearAttack or bossVFX then
                KuramaCombat.Warn("Warning: " .. area.name, 1)
            end
        end
    end
    if not Config.KuramaAvoidAttacks or tick() >= state.untilTime then
        state.retreat = nil
        state.safePosition = nil
        return false
    end
    KuramaCombat.Release()
    local pos = KuramaCombat.Escape(boss, areas)
    if not pos then
        Window.RaidAction = "Danger — no verified circle-free landing; attacks paused"
        return true
    end
    state.safePosition = pos
    local cf = CFrame.new(pos, boss.Root.Position)
    char:PivotTo(cf)
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    Window.RaidAction = "Evading (" .. circleCount .. " circle/blast zones) — " .. (state.reason or "attack wind-up")
    return true -- Critical: no orbit, heal, M1, or new skill after a dodge in this tick.
end
function KuramaCombat.Step(boss)
    if not ScriptRunning or not hum or hum.Health <= 0 then KuramaCombat.Stop(true); return end
    if KuramaCombat.Evade(boss) then return end
    if char:GetAttribute("Meditation") or char:GetAttribute("Downed") or char:GetAttribute("Stunned") then
        KuramaCombat.Release()
        Window.RaidAction = "Waiting — charging / downed / stunned"
        return
    end
    local state = KuramaCombat.State
    if state.busy then return end
    local cf = CFrame.new(KuramaCombat.AttackPoint(boss), boss.Root.Position)
    char:PivotTo(cf)
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    if Config.AutoEquipWeapon and not char:FindFirstChildOfClass("Tool") then
        local backpack = plr:FindFirstChild("Backpack")
        local tool = backpack and backpack:FindFirstChildOfClass("Tool")
        if tool then hum:EquipTool(tool) end
    end
    if Remotes.AbilityEvent then
        Remotes.AbilityEvent:FireServer("UpdateMouse", boss.Root.Position, cf.LookVector)
    end
    if Config.KuramaMoves and tick() >= state.nextMove then
        local slot = state.nextSlot
        state.nextSlot = slot % 4 + 1
        state.nextMove = tick() + 0.85
        if KuramaCombat.Cast(slot) then Window.RaidAction = "Casting slot " .. slot; return end
    end
    KuramaCombat.Punch(Config.KuramaPunches)
    Window.RaidAction = Config.KuramaPunches and "Punching — native M1 combo" or "Waiting for moves"
end

-- Every-frame safety monitor is independent of yielding abilities and the slower UI loop.
do
    local lastSafety = 0
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if not ScriptRunning or tick() == lastSafety then return end
        lastSafety = tick()
        local ok, err = pcall(function()
            if not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) or not char or not char.Parent
                or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
                if KuramaCombat.State.boss or KuramaCombat.State.punching then KuramaCombat.Stop(true) end
                return
            end
            if KuramaCombat.State.slot and tick() >= KuramaCombat.State.releaseAt then KuramaCombat.Release() end
            local boss = findKurama()
            if boss then KuramaCombat.Evade(boss) else KuramaCombat.Stop(true) end
        end)
        if not ok then KuramaCombat.Release(); reportKuramaError(err) end
    end))
end

startAutoKuramaRaid = function()
    if kuramaRaidRunning or not ScriptRunning then return end
    kuramaRaidRunning = true

    task.spawn(function()
        while ScriptRunning and Config.AutoKuramaRaid do
            local ok, err = pcall(function()
                if not char or not char.Parent or not hrp or not hrp.Parent then
                    char = plr.Character
                    if char then
                        hrp = char:FindFirstChild("HumanoidRootPart")
                        hum = char:FindFirstChildOfClass("Humanoid")
                    end
                    task.wait(0.5)
                    return
                end

                local kurama = findKurama()
                if kurama and isModelAlive(kurama.Model) and kurama.Root then
                    -- The fight AI owns movement/combat when enabled, not both engines.
                    if Config.AutoPlayKuramaFight then return end
                    KuramaCombat.Step(kurama)
                else
                    KuramaCombat.Stop(true)
                    -- Kurama not spawned / in lobby / cleared
                    if Config.AutoEnterRaidGate then
                        interactWithPrompts({"raid", "kurama", "nine", "kyuubi", "portal", "gate", "enter"})
                    end

                    if Config.AutoCollectRaidLoot then
                        interactWithPrompts({"open", "claim", "collect", "chest", "reward", "scroll", "loot"})
                    end
                end
            end)
            if not ok then KuramaCombat.Release(); reportKuramaError(err) end
            task.wait(0.1)
        end
        kuramaRaidRunning = false
        if not Config.AutoPlayKuramaFight then KuramaCombat.Stop(true) end
    end)
end

-----------------------------------------------
-- AUTO-PLAY KURAMA FIGHT AI (dodge / heal / mode awakening)
-- Shares the native raid controller. Defense always runs before optional healing
-- and awakening; a retreat is never overwritten by a same-tick orbit teleport.
-----------------------------------------------
local kuramaFightState = {
    orbitAngle = 0,
    lastHeal = 0,
    lastMode = 0,
    lastDodge = 0,
}

local function readModeStacks()
    local candidates = { "ModeStacks", "Stacks", "Rage", "ChakraStacks", "AwakeningStacks" }
    local best = 0
    local function consider(v)
        v = tonumber(v)
        if v and v > best then best = v end
    end
    if char then for _, a in ipairs(candidates) do consider(char:GetAttribute(a)) end end
    if hrp then for _, a in ipairs(candidates) do consider(hrp:GetAttribute(a)) end end
    local data = getPlayerData()
    if data then for _, a in ipairs(candidates) do consider(data[a]) end end
    return best
end

local function tryHeal()
    KuramaCombat.Release()
    -- 1) Prefer a dedicated healing Tool (Medkit / Potion / Scroll of Healing)
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():match("heal") then
                pcall(function() t:Activate() end)
                return true
            end
        end
        local bp = plr:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():match("heal") and hum then
                    pcall(function() hum:EquipTool(t) end)
                    task.wait(0.1)
                    if not ScriptRunning or not Config.AutoPlayKuramaFight
                        or (Config.KuramaAvoidAttacks and tick() < KuramaCombat.State.untilTime) then return true end
                    pcall(function() t:Activate() end)
                    return true
                end
            end
        end
    end
    -- 2) Fall back to the class heal ability (slot 5 = R is the usual heal slot)
    return KuramaCombat.Cast(5)
end

local function activateMode()
    return KuramaCombat.Cast(7)
end

local function runKuramaFightAI()
    if not ScriptRunning or not Config.AutoPlayKuramaFight then return end
    if not char or not char.Parent or not hrp or not hrp.Parent then return end

    local kurama = findKurama()
    if not kurama or not kurama.Root or not isModelAlive(kurama.Model) or not hum or hum.Health <= 0 then
        KuramaCombat.Stop(true)
        return
    end

    local now = tick()
    if KuramaCombat.Evade(kurama) then return end
    if KuramaCombat.State.busy then return end

    -- --- Self-heal ---
    if hum then
        local hpPct = (hum.Health / math.max(hum.MaxHealth, 1)) * 100
        if hpPct <= Config.KuramaHealThreshold and (now - kuramaFightState.lastHeal) > 3 then
            kuramaFightState.lastHeal = now
            if tryHeal() then return end -- pause a beat while healing
        end
    end

    -- --- Mode awakening at max stacks ---
    if (now - kuramaFightState.lastMode) > 5 then
        local stacks = readModeStacks()
        if stacks >= Config.KuramaModeStacks then
            kuramaFightState.lastMode = now
            if activateMode() then
                Window:Notify({ Title = "Kurama AI", Description = "Requested awakening at " .. stacks .. " stacks.", Lifetime = 4 })
                return
            end
        end
    end
    KuramaCombat.Step(kurama)
end

-----------------------------------------------
-- STRICT ALIVE DAMAGEABLE MOBS SCANNER
-----------------------------------------------
local function getMobs()
    if not ScriptRunning then return {} end
    local mobs = {}
    local searchedModels = {}

    local activeFilter = Config.CustomTargetInput ~= "" and Config.CustomTargetInput or Config.TargetType
    if Config.LiveTargetSelect and Config.LiveTargetSelect ~= "All Live Mobs" and Config.CustomTargetInput == "" then
        activeFilter = Config.LiveTargetSelect
    end

    -- Smart Quest Tracker Target Override
    if Config.AutoSmartQuestTracker then
        local qText = scanActiveQuestObjective()
        if qText:find("dna") or qText:find("boss") then
            activeFilter = "Bosses Only"
        elseif qText:find("mugetsu") then
            activeFilter = "Mugetsu"
        elseif qText:find("red eye") then
            activeFilter = "Dual Eyes (Sharingan/Rinnegan/Crimson)"
        end
    end

    -- Kurama farming must use the same cached, strict boss resolver as the raid engine.
    local lowerFilter = activeFilter:lower()
    if lowerFilter:find("kurama", 1, true) or lowerFilter:find("koroma", 1, true) then
        local boss = findKurama()
        if not boss then return {} end
        return {{Model = boss.Model, Humanoid = boss.Hum, TargetPart = boss.Root, IsBoss = true}}
    end

    local function scan(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") and child ~= char and not searchedModels[child] then
                searchedModels[child] = true
                local eHum = child:FindFirstChildOfClass("Humanoid")
                local targetPart = child:FindFirstChild("HumanoidRootPart") 
                    or child:FindFirstChild("Head") 
                    or child:FindFirstChild("Torso") 
                    or child:FindFirstChild("LowerTorso") 
                    or child:FindFirstChildOfClass("BasePart")

                local mobName = child.Name:lower()
                -- Strict Alive check (Humanoid.Health > 0 and MaxHealth > 1)
                -- FIX: interactables like "Log" / "Attack Dummy" are one-HP models,
                -- so OnlyAliveMobs hid them and farm did nothing; exempt non-humanoid targets.
                local isInteractable = eHum == nil and targetPart ~= nil
                    and (mobName:find("log") or mobName:find("dummy") or mobName:find("bush") or mobName:find("trunk"))
                local isAlive = targetPart and (eHum == nil and isInteractable or (eHum and (eHum.Health > 0) and (eHum.MaxHealth > 1)))
                if not Config.OnlyAliveMobs then isAlive = (targetPart ~= nil) end

                if isAlive then
                    local isBoss = mobName:find("boss") or mobName:find("bone") or (eHum and eHum.MaxHealth > 3000)
                    
                    local matchesFilter = true
                    if activeFilter == "Bosses Only" then
                        if not isBoss then matchesFilter = false end
                    elseif activeFilter == "Dual Eyes (Sharingan/Rinnegan/Crimson)" then
                        -- FIX: the actual quest mobs are named Red/White Eyes members, not "Dual Eyes"
                        if not (mobName:find("red eyes") or mobName:find("white eye") or mobName:find("rinnegan") or mobName:find("sharingan") or mobName:find("crimson")) then matchesFilter = false end
                    elseif activeFilter == "Log" or activeFilter == "Attack Dummy" then
                        -- Quest interactables: loose match (Log/Trunk/Bush, Attack/Training Dummy)
                        local key = (activeFilter == "Log") and "log" or "dummy"
                        if not (mobName:find(key) or (key == "log" and (mobName:find("trunk") or mobName:find("bush")))) then
                            matchesFilter = false
                        end
                    elseif activeFilter == "Monster of Sand (Yin/Yang Farm)" then
                        -- FIX: live names vary ("Monster of Sand" / "Sand Beast" / "Monster")
                        if not (mobName:find("monster") or mobName:find("sand beast")) then matchesFilter = false end
                    elseif activeFilter == "Mugetsu" then
                        if not mobName:find("mugetsu") then matchesFilter = false end
                    elseif activeFilter == "Bone (Global Boss)" then
                        if not mobName:find("bone") then matchesFilter = false end
                    elseif activeFilter == "Kurama (Raid Boss)" or activeFilter == "Koroma" or activeFilter:lower():find("kurama") or activeFilter:lower():find("koroma") then
                        if not (mobName:find("kurama") or mobName:find("koroma") or mobName:find("nine") or mobName:find("kyuubi") or mobName:find("fox") or (eHum and eHum.MaxHealth >= 500000)) then
                            matchesFilter = false
                        end
                    elseif activeFilter ~= "All Mobs" and activeFilter ~= "All Live Mobs" and activeFilter ~= "" then
                        if not mobName:find(activeFilter:lower()) then
                            matchesFilter = false
                        end
                    end

                    if matchesFilter then
                        table.insert(mobs, {Model = child, Humanoid = eHum, TargetPart = targetPart, IsBoss = isBoss})
                    end
                end
            elseif child:IsA("Folder") and child ~= char and not child:IsDescendantOf(char) then
                scan(child)
            end
        end
    end

    for _, container in ipairs(getEntitySearchContainers()) do
        scan(container)
    end

    return mobs
end

local function getClosestMob()
    if not ScriptRunning or not hrp or not hrp.Parent then return nil end
    local best, bestDist = nil, 99999
    for _, mob in ipairs(getMobs()) do
        local d = (mob.TargetPart.Position - hrp.Position).Magnitude
        if d < bestDist then
            bestDist = d
            best = mob
        end
    end
    return best
end

-----------------------------------------------
-- NOCLIP & TRUE GOD MODE IMMORTALITY ENGINE
-----------------------------------------------
local noclipConn = RunService.Stepped:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        -- God Mode Immortality Suite
        if Config.GodMode and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) and hum and hum.Parent then
            -- 1. Death State & Ragdoll Bypass
            if Config.DeathStateBypass then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end

            -- 2. Touch Damage Nullification: blocks enemy hitboxes, lava, AOEs
            if Config.TouchDamageNullifier and char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanTouch then
                        part.CanTouch = false
                    end
                end
            end

            -- 3. Visual & Client-side Health Lock
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end

        -- Noclip Collisions
        if Config.AutoFarm or Config.Noclip or Config.AutoKuramaRaid or Config.AutoPlayKuramaFight then
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)
table.insert(Connections, noclipConn)

-----------------------------------------------
-- INFINITE CHAKRA, STAMINA & GOD MODE REFILL
-----------------------------------------------
local lastEmergencyEscape, lastReserveTick, lastPunchTick = 0, 0, 0
local lastMeditationToggle = false
local lastDodgeCheck, lastBlockPress, lastDodgeMove, noMobSince = 0, 0, 0, tick()
local heartbeatConn = RunService.Heartbeat:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        -- God Mode Health Lock & Knockback Protection
        if Config.GodMode and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) and hum and hum.Health > 0 and hrp then
            hum.Health = hum.MaxHealth

            -- Knockback dampener (prevents fling / void kill)
            local v = hrp.AssemblyLinearVelocity
            if v.Magnitude > 75 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, math.clamp(v.Y, -20, 20), 0)
                hrp.AssemblyAngularVelocity = Vector3.zero
            end

            -- Emergency Escape: If HP drops below threshold, escape to safety and meditate
            -- (FIX: fired every Heartbeat, pinning you to the sky; now once per 8s)
            if Config.EmergencyEscape then
                local hpPercent = (hum.Health / math.max(hum.MaxHealth, 1)) * 100
                if hpPercent <= Config.EscapeThreshold and (tick() - lastEmergencyEscape) > 8 then
                    lastEmergencyEscape = tick()
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 65, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    if Remotes.MeditationEvent then
                        Remotes.MeditationEvent:FireServer({ Action = "Start" }) -- VERIFIED payload
                    end
                end
            end
        end

        -- Infinite Chakra/Stamina (FIX: spammed remotes every frame -> lag; now refresh 1s)
        if (tick() - lastReserveTick) > 1 then
            lastReserveTick = tick()
            if Config.InfiniteChakra and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) and Remotes.MeditationEvent then
                local chakra = char:GetAttribute("Chakra") or char:GetAttribute("chakra")
                if chakra == nil or chakra < 95 then
                    -- VERIFIED payloads: {Action="Start"} begins charging, {Action="Complete"} collects
                    lastMeditationToggle = not lastMeditationToggle
                    Remotes.MeditationEvent:FireServer({ Action = lastMeditationToggle and "Start" or "Complete" })
                end
            end
            -- NOTE: Infinite Stamina removed — stamina is a client-side value in this game,
            -- there is no IncrementStamina remote (verified in decompiled StaminaService).
        end

        -- Auto Puncher (FIX: toggle existed but was never wired to any click loop)
        if Config.AutoPuncher and VIM and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight)
            and (Config.AutoFarm or Config.AutoTrainingRoom)
            and (tick() - lastPunchTick) >= Config.PunchSpeed then
            lastPunchTick = tick()
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end

        -- Movement Boosts
        if hum and hum.Health > 0 then
            if Config.SpeedBoost and hum.WalkSpeed ~= Config.SpeedValue then hum.WalkSpeed = Config.SpeedValue end
            if Config.JumpBoost and hum.JumpPower ~= Config.JumpValue then hum.JumpPower = Config.JumpValue end
        end

        -- Auto-Dodge & Auto-Block (FIX: these toggles existed but no dodge logic ever ran)
        if not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) and (Config.AutoDodge or Config.AutoBlock)
            and hum and hum.Health > 0 and (tick() - lastDodgeCheck) > 0.4 then
            lastDodgeCheck = tick()
            local mob = getClosestMob and getClosestMob() or nil
            if mob and mob.TargetPart and hrp then
                local d = (mob.TargetPart.Position - hrp.Position).Magnitude
                if Config.AutoBlock and d <= Config.DodgeDistance * 1.5 and (tick() - lastBlockPress) > 3 then
                    lastBlockPress = tick()
                    pcall(function()
                        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.35)
                        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    end)
                end
                if Config.AutoDodge and d <= Config.DodgeDistance and (tick() - lastDodgeMove) > 2.5 then
                    lastDodgeMove = tick()
                    pcall(function()
                        local mode = tostring(Config.DodgeMode or "")
                        if mode:find("Kawarimi") then
                            -- substitution: appear behind the attacker
                            char:PivotTo(mob.TargetPart.CFrame * CFrame.new(0, 1.5, 3))
                        elseif mode:find("Sky") then
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 70, 0)
                        elseif mode:find("Block") then
                            -- pure block mode: handled by AutoBlock above
                        else -- Sharingan / Orbit Glide: lateral orbit dash
                            local dir = hrp.CFrame.RightVector * (math.random() > 0.5 and 1 or -1)
                            hrp.AssemblyLinearVelocity = dir.Unit * 65 + Vector3.new(0, 25, 0)
                        end
                    end)
                end
            end
        end
    end)
end)
table.insert(Connections, heartbeatConn)

-----------------------------------------------
-- AUTO WEAPON EQUIP & COMBAT DAMAGE ENGINE (WITH HITBOX EXTENDER)
-----------------------------------------------
-- (m1Tick is forward-declared near the top so the Kurama engine shares it)
local function equipWeaponAndAttack(mobModel, targetPos)
    if not ScriptRunning or not Config.AutoFarm then return end
    pcall(function()
        -- 1. Auto Equip Weapon from Backpack if not holding one
        if Config.AutoEquipWeapon and char then
            local equippedTool = char:FindFirstChildOfClass("Tool")
            if not equippedTool then
                local backpack = plr:FindFirstChild("Backpack")
                if backpack then
                    local tool = backpack:FindFirstChildOfClass("Tool")
                    if tool then
                        hum:EquipTool(tool)
                        task.wait(0.05)
                        equippedTool = tool
                    end
                end
            end

            if equippedTool then
                equippedTool:Activate()
                if Config.HitboxExtender and equippedTool:FindFirstChild("Handle") then
                    equippedTool.Handle.Size = Vector3.new(30, 30, 30)
                end
            end
        end

        -- 2. Virtual input: real M1 click every swing; jutsu keys only when AutoJutsu is on
        if VIM and mobModel then
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
        if Config.AutoJutsu and VIM and mobModel then
            local moveKeys = {
                Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V
            }
            for _, key in ipairs(moveKeys) do
                pcall(function()
                    VIM:SendKeyEvent(true, key, false, game)
                    task.wait(0.005)
                    VIM:SendKeyEvent(false, key, false, game)
                end)
            end
        end

        -- 3. Fire Combat Remotes — VERIFIED decompiled protocol:
        -- CombatEvent:FireServer("M1", {Action="HitConnection", Character=..., Victim=..., Tick=1..5, Air=bool})
        -- (the old "LightAttack"/"Attack" variants do not exist in this game)
        if Remotes.CombatEvent and mobModel then
            m1Tick = (m1Tick % 5) + 1 -- attack combo ticks 1..5 like the real weapon code
            Remotes.CombatEvent:FireServer("M1", {
                Action = "HitConnection",
                Character = char,
                Victim = mobModel,
                Tick = m1Tick,
                Air = false
            })
            Remotes.CombatEvent:FireServer("M1", {
                Action = "SwingSFX",
                Character = char,
                Tick = m1Tick
            })
        end

        -- 4. Ability casts — VERIFIED protocol:
        -- aim: AbilityEvent:FireServer("UpdateMouse", position, lookVector)
        -- cast: AbilityFunction:InvokeServer("KeyPressed", slotIndex(1-7 = Z,X,C,V,R,T,G), rmbHeld)
        if Config.AutoJutsu and Remotes.AbilityEvent then
            local look = hrp and hrp.CFrame.LookVector or Vector3.new(0, 0, -1)
            Remotes.AbilityEvent:FireServer("UpdateMouse", targetPos, look)
            if Remotes.AbilityFunction then
                for slot = 1, 3 do
                    pcall(function()
                        Remotes.AbilityFunction:InvokeServer("KeyPressed", slot, false)
                    end)
                end
            end
        end

        -- 5. Kunai spam disabled: real KunaiHit needs a server-issued projectile UUID.
    end)
end

-----------------------------------------------
-- AUTO FARM LOOP WITH BEHIND-TARGET POSITION LOCK
-----------------------------------------------
local farmRunning = false

local function startAutoFarm()
    if farmRunning or not ScriptRunning then return end
    farmRunning = true

    while ScriptRunning and Config.AutoFarm do
        -- Raid/fight modes have their own attack positions; ordinary farming must not overwrite them.
        if Config.AutoKuramaRaid or Config.AutoPlayKuramaFight then
            task.wait(0.15)
            continue
        end
        pcall(function()
            if not hrp or not hrp.Parent then
                char = plr.Character
                if char then
                    hrp = char:FindFirstChild("HumanoidRootPart")
                    hum = char:FindFirstChildOfClass("Humanoid")
                end
                if not hrp then task.wait(1); return end
            end

            local mob = getClosestMob()
            if mob and mob.TargetPart then
                ensureAnchor()
                
                -- Position Character 3 studs behind mob back & slightly elevated for 100% melee reach
                local targetCFrame = mob.TargetPart.CFrame
                local reachCFrame = targetCFrame * CFrame.new(0, Config.FarmHeight, 3)

                -- Dual PivotTo & CFrame Teleport Lock
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:PivotTo(reachCFrame)
                    hrp.CFrame = reachCFrame
                end
                
                if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end
                if bodyGyro then bodyGyro.CFrame = reachCFrame end

                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                -- Execute Complete Combat & Weapon Damage Engine
                equipWeaponAndAttack(mob.Model, targetCFrame.Position)
                -- Farm HUD kill counter: count deaths since last look
                if not farmLastTarget or farmLastTarget ~= mob.Model then
                    farmLastTarget = mob.Model
                elseif farmLastTarget and not farmLastTarget.Parent then
                    killCount += 1
                    farmLastTarget = nil
                end
            else
                removeAnchor()
            end
        end)

        task.wait(Config.AttackSpeed)
    end

    removeAnchor()
    farmRunning = false
end

-----------------------------------------------
-- HELPER: GET CURRENT PLAYER CLAN / ELEMENT / EYE
-----------------------------------------------
local function getCurrentPlayerData()
    local clanName, elementName, eyeName = "", "", ""
    pcall(function()
        local dataFolder = plr:FindFirstChild("Data") or plr:FindFirstChild("Stats") or RS:FindFirstChild("ReplicatedData")
        if dataFolder then
            if dataFolder:FindFirstChild("Clan") then clanName = tostring(dataFolder.Clan.Value) end
            if dataFolder:FindFirstChild("Element") then elementName = tostring(dataFolder.Element.Value) end
            if dataFolder:FindFirstChild("Eye") then eyeName = tostring(dataFolder.Eye.Value) end
        end
        if plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("Interface") then
            local ui = plr.PlayerGui.Interface
            if ui:FindFirstChild("Clan") and ui.Clan:FindFirstChild("Text") then clanName = ui.Clan.Text end
            if ui:FindFirstChild("Element") and ui.Element:FindFirstChild("Text") then elementName = ui.Element.Text end
        end
    end)
    return clanName, elementName, eyeName
end

-----------------------------------------------
-- LEVEL-BASED AUTO QUEST ENGINE
-----------------------------------------------

-- Gets player level from any known data path (forward-declared; updateHUDs uses it)
getPlayerLevel = function()
    local level = 1
    pcall(function()
        local data = plr:FindFirstChild("Data") or plr:FindFirstChild("Stats")
        if data then
            local lv = data:FindFirstChild("Level") or data:FindFirstChild("Lvl")
            if lv then level = lv.Value; return end
        end
        local ls = plr:FindFirstChild("leaderstats")
        if ls then
            local lv = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl")
            if lv then level = lv.Value; return end
        end
        local attr = plr:GetAttribute("Level") or plr:GetAttribute("Lvl")
        if attr then level = attr end
    end)
    return level
end

-- Tier table: each entry defines min level, NPC name, NPC position, quests to accept, and farm target mob
local LevelQuestTiers = {
    -- Quest IDs verified from decompiled Modules/Data/Quests source
    {
        minLevel = 1, maxLevel = 4,
        npcName = "Aruka",
        npcPos = Vector3.new(1134.7, 10.3, -1204.9),
        quests = { "Combat Training!", "Start Journey" },
        farmTarget = "Log",
        farmTime = 90,
    },
    {
        minLevel = 5, maxLevel = 14,
        npcName = "Chiraku",
        npcPos = Vector3.new(221.7, 45.7, -158.6),
        quests = { "Defeat Logs", "Clean Green Bush 20 Times", "Destroy Trunk 15 Times" },
        farmTarget = "Log",
        farmTime = 90,
    },
    {
        minLevel = 15, maxLevel = 24,
        npcName = "Aruka",
        npcPos = Vector3.new(1134.7, 10.3, -1204.9),
        quests = { "Defeat the Icy Limited", "Defeat the Demon Brothers Limited", "Hit the Trunk with 15 Shurikens" },
        farmTarget = "Icy",
        farmTime = 120,
    },
    {
        minLevel = 25, maxLevel = 39,
        npcName = "High Muty",
        npcPos = Vector3.new(1023.0, 8.4, -1206.6),
        quests = {
            "Defeat 5 Wind Element Ninjas",
            "Defeat 5 Water Element Ninjas",
            "Defeat 5 Fire Element Ninjas",
            "Defeat 5 Earth Element Ninjas",
            "Defeat 5 Lightning Element Ninjas",
        },
        farmTarget = "Chunin Ninja",
        farmTime = 150,
    },
    {
        minLevel = 40, maxLevel = 55,
        npcName = "Stone Leo",
        npcPos = Vector3.new(995.4, 10.0, -1291.8),
        quests = {
            "Defeat Copycat Rotate",
            "Defeat White Eyes Rotate",
            "Defeat Snake Rotate",
            "Defeat One of the Sound Three (Dosu)",
        },
        farmTarget = "Copycat",
        farmTime = 180,
    },
    {
        minLevel = 56, maxLevel = 79,
        npcName = "Red Eyes Leader",
        npcPos = Vector3.new(-1767.7, 72.0, 2499.3),
        quests = {
            "Defeat 3 White Zetsus",
            "Defeat 5 White Zetsus",
            "Defeat 10 White Zetsus",
            "Defeat Hat Rotate",
        },
        farmTarget = "White Eyes",
        farmTime = 240,
    },
    {
        minLevel = 80, maxLevel = 9999,
        npcName = "Danzu",
        npcPos = Vector3.new(2266.9, 410.0, -506.6),
        quests = {
            "Defeat Immortal",
            "Defeat Immortal Rotate",
            "Defeat Aruka Rotate",
            "Defeat Rakura Rotate",
        },
        farmTarget = "Immortal",
        farmTime = 360,
    },
}

-- Returns the tier matching the player's current level
local function getQuestTier(level)
    for _, tier in ipairs(LevelQuestTiers) do
        if level >= tier.minLevel and level <= tier.maxLevel then
            return tier
        end
    end
    return LevelQuestTiers[#LevelQuestTiers]
end

-- Teleports character to a Vector3 position
local function tpToPos(pos)
    if char and hrp then
        char:PivotTo(CFrame.new(pos + Vector3.new(0, 4, 0)))
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    end
end

-- Fires the quest remote to accept a quest — VERIFIED payload:
-- QuestEvent:FireServer({ Job = "GiveQuest", QuestId = "..." })
-- (the old "START_QUEST:"/"Accept" strings are invented and were ignored by the server)
local function acceptQuestByName(questName)
    if not Remotes.QuestEvent then return end
    pcall(function()
        if Remotes.QuestEvent:IsA("RemoteFunction") then
            Remotes.QuestEvent:InvokeServer({ Job = "GiveQuest", QuestId = questName })
        else
            Remotes.QuestEvent:FireServer({ Job = "GiveQuest", QuestId = questName })
        end
    end)
end

-- Quest completion is server-side; re-accepting repeatables refreshes progress.
-- Daily missions: verified payload is the string "GetMissions" on DailyQuestsRemote.
local function claimAllQuests()
    if Remotes.DailyQuestsRemote then
        pcall(function() Remotes.DailyQuestsRemote:FireServer("GetMissions") end)
    end
end

-- Main engine state
local levelQuestState = {
    lastTierIndex = -1,
    running = false,
}

-- Dedicated state-machine loop: ACCEPT -> FARM -> CLAIM -> repeat
-- Runs in its own thread so farming is never interrupted by NPC TPs
task.spawn(function()
    while ScriptRunning do
        if not Config.AutoLevelQuest then
            levelQuestState.running = false
            task.wait(1)
            continue
        end

        levelQuestState.running = true

        -- =====================
        -- PHASE 1: ACCEPT QUESTS
        -- =====================
        -- FIX: guard against non-numeric level values (some servers use StringValue)
        local level = tonumber(getPlayerLevel()) or 1
        local tier  = getQuestTier(level)

        -- Compute tier index for change detection
        local tierIndex = 0
        for i, t in ipairs(LevelQuestTiers) do
            if t == tier then tierIndex = i; break end
        end

        -- Notify on tier change
        if tierIndex ~= levelQuestState.lastTierIndex then
            levelQuestState.lastTierIndex = tierIndex
            Window:Notify({
                Title = "Level Quest Engine",
                Description = "Lv " .. level .. " | NPC: " .. tier.npcName .. " | Farm: " .. tier.farmTarget,
                Lifetime = 6
            })
        end

        -- TP to quest-giver NPC
        tpToPos(tier.npcPos)
        task.wait(2)

        -- Fire accept for every quest in tier
        for _, questName in ipairs(tier.quests) do
            acceptQuestByName(questName)
            task.wait(0.4)
        end

        -- =====================
        -- PHASE 2: FARM MOBS
        -- =====================
        -- Wipe CustomTargetInput override so TargetType is actually used
        Config.CustomTargetInput = ""
        Config.LiveTargetSelect  = "All Live Mobs"
        Config.TargetType        = tier.farmTarget
        -- Enable AutoFarm automatically if it isn't already on
        if not Config.AutoFarm then
            Config.AutoFarm = true
        end
        -- Refresh the live mob scanner immediately with the new target
        pcall(scanLiveMobs)

        Window:Notify({
            Title = "Quest Engine → FARMING",
            Description = "Target set: " .. tier.farmTarget .. " | Farming for " .. tier.farmTime .. "s...",
            Lifetime = 4
        })

        -- Stay in farm phase for tier.farmTime seconds
        -- Break early if player levels into a new tier
        local farmStart = tick()
        while ScriptRunning and Config.AutoLevelQuest and (tick() - farmStart) < tier.farmTime do
            local currentTier = getQuestTier(getPlayerLevel())
            if currentTier ~= tier then break end
            task.wait(2)
        end

        if not ScriptRunning or not Config.AutoLevelQuest then continue end

        -- =====================
        -- PHASE 3: CLAIM REWARDS
        -- =====================
        Window:Notify({
            Title = "Quest Engine → CLAIMING",
            Description = "Returning to " .. tier.npcName .. " to claim rewards...",
            Lifetime = 4
        })

        tpToPos(tier.npcPos)
        task.wait(2)
        claimAllQuests()
        task.wait(1)
        -- FIX: verify arrival; if the NPC area failed, retry via landmark teleport engine
        if hrp and tier.npcPos and (hrp.Position - tier.npcPos).Magnitude > 120 then
            pcall(function() smartTeleportToZone(tier.npcName) end)
        end

        -- Loop back to ACCEPT phase
    end
end)

-- Stub so the main loop hook doesn't error
local function runAutoLevelQuestEngine() end

-----------------------------------------------
-- GAME MECHANICS, SPINNER & AUTO-STOP LOOP (SLOT SUPPORT)
-----------------------------------------------
local lastCheck = 0
local function handleGameMechanics()
    if not ScriptRunning or (tick() - lastCheck) < 1.0 then return end
    lastCheck = tick()

    pcall(function()
        -- Auto Refresh Live Mobs Scan
        scanLiveMobs()

        -- Auto Spinner target detection — VERIFIED data source:
        -- ReplicatedData PlayerData.Clans[i] / Elements[i] / Family (there are NO spin remotes;
        -- rolls happen through the Bag gacha UI with ClanSpins/ElementSpins/FamilySpins tokens)
        local data = getPlayerData()
        if data and type(data.Clans) == "table" then
            local gotTarget = false
            for _, clan in ipairs(data.Clans) do
                if tostring(clan):lower():find(Config.TargetClanRarity:lower()) then gotTarget = true end
            end
            if gotTarget and Config.AutoSpinClan then
                Config.AutoSpinClan = false
                pcall(function() clanSpinToggle:SetValue(false) end)
                Window:Notify({ Title = "SPIN SUCCESS!", Description = "Got target clan (" .. Config.TargetClanRarity .. ") in your slots! Check the Bag menu to equip it.", Lifetime = 10 })
            end
            local gotElem = false
            if type(data.Elements) == "table" then
                for _, element in ipairs(data.Elements) do
                    if tostring(element):lower():find(Config.TargetElementRarity:lower()) then gotElem = true end
                end
            end
            if gotElem and Config.AutoSpinElement then
                Config.AutoSpinElement = false
                pcall(function() elementSpinToggle:SetValue(false) end)
                Window:Notify({ Title = "SPIN SUCCESS!", Description = "Got target element (" .. Config.TargetElementRarity .. ") in your slots!", Lifetime = 10 })
            end
            if Config.AutoSpinEye and data.Eye and tostring(data.Eye) ~= "" and tostring(data.Eye):lower() ~= "none" then
                Config.AutoSpinEye = false
                pcall(function() eyeSpinToggle:SetValue(false) end)
                Window:Notify({ Title = "SPIN SUCCESS!", Description = "Eye detected: " .. tostring(data.Eye), Lifetime = 10 })
            end
        end

        -- Dual Eyes / Tenseigan quest automator — VERIFIED GiveQuest job with real quest IDs
        -- from Modules/Data/Quests/SkillQuests (DualEyes + Tenseigan).
        if Config.AutoDualEyesQuest and Remotes.QuestEvent and (tick() - lastEyeQuestAccept) > 30 then
            lastEyeQuestAccept = tick()
            for _, questId in ipairs({ "Drive for Scientific Advancement", "Sacrifices must be Made", "Are you ready?", "Reincarnate of the Truth" }) do
                acceptQuestByName(questId)
            end
        end

        -- Shukaku Quiz Solver: real dialogue protocol is DialogueEvent:FireServer(dialogueId, indexTree)
        -- Best-effort: step any active dialogue's option 1/2 while the toggle is on.
        if Config.AutoShukakuQuiz and Remotes.DialogueEvent then
            local ansChoice = (Config.QuizVariant == "Variant 1 (Offensive)") and 1 or 2
            pcall(function()
                Remotes.DialogueEvent:FireServer("SandBeastQuiz", { ansChoice })
            end)
        end

        -- (FIX: skill tree / exams / minigames / meditate / mastery / rank up / quests /
        -- dailies / stat allocation were duplicated here AND in runModeActivationEngine,
        -- causing double remote fires every second; they now live only in that engine)

        -- Auto Raids: keep the Kurama engine alive
        if Config.AutoKuramaRaid and not kuramaRaidRunning then
            startAutoKuramaRaid()
        end

        -- Bone Global Boss Auto Teleport (FIX: only real boss rigs now, not any "bone" part)
        if Config.AutoTeleportBone and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) then
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("Model") then
                    local h = obj:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 and h.MaxHealth > 1000 and obj.Name:lower():find("bone") then
                        local bHRP = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("BasePart")
                        if bHRP and char then
                            char:PivotTo(bHRP.CFrame * CFrame.new(0, Config.FarmHeight, 0))
                        end
                        break
                    end
                end
            end
        end
    end)
end

-----------------------------------------------
-- HUD BUILDERS (Farm Stats / Quest Progress)
-----------------------------------------------
local function ensureScreenGui(name, titleText)
    local pg = plr:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end
    local gui = pg:FindFirstChild(name)
    if gui then return gui end
    gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.Size = UDim2.fromOffset(240, 92)
    frame.Position = UDim2.new(1, -252, 0, 90)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -12, 0, 20)
    title.Position = UDim2.fromOffset(8, 4)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 200, 60)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = titleText
    title.Parent = frame
    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.Size = UDim2.new(1, -16, 1, -30)
    body.Position = UDim2.fromOffset(8, 26)
    body.BackgroundTransparency = 1
    body.TextColor3 = Color3.fromRGB(235, 235, 235)
    body.TextSize = 13
    body.Font = Enum.Font.Gotham
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextWrapped = true
    body.Text = "..."
    body.Parent = frame
    gui.Parent = pg
    return gui
end

-----------------------------------------------
-- MODE ACTIVATION ENGINE (FIX: toggles existed but nothing ran them)
-----------------------------------------------
local function runModeActivationEngine()
    if not ScriptRunning then return end
    pcall(function()
        -- Mode activators — VERIFIED: abilities are cast per hotbar SLOT via
        -- AbilityFunction:InvokeServer("KeyPressed", slotIndex, rmbHeld); slot 7 = G (mode).
        if not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight)
            and (Config.AutoRinnegan or Config.AutoTailedBeast or Config.AutoSusanoo) and (tick() - lastModePress) > 5 then
            lastModePress = tick()
            if Remotes.AbilityFunction then
                pcall(function() Remotes.AbilityFunction:InvokeServer("KeyPressed", 7, false) end)
            end
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
            end)
        end

        -- Auto Tomoe Evolve: Tomoe growth is passive (use the eyes); the TomoeEvent remote
        -- only toggles "skip animations" (verified). Nothing to fire for evolution itself.

        -- Auto Meditate — VERIFIED payloads {Action="Start"} / {Action="Complete"}
        if Config.AutoMeditate and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) and Remotes.MeditationEvent then
            local chakra = char:GetAttribute("Chakra") or char:GetAttribute("chakra")
            if chakra == nil or chakra < 95 then
                lastMeditationToggle = not lastMeditationToggle
                Remotes.MeditationEvent:FireServer({ Action = lastMeditationToggle and "Start" or "Complete" })
            end
        end

        -- Auto Mastery: VERIFIED protocol needs an exercise-machine UUID from the training tool
        -- ({Action="Start", ExerciseType=..., Duration=..., UUID=...}). No UUID = server ignores.
        -- Kept as a no-op note; use Auto Training Room (farm dummies) for mastery instead.

        -- Auto Rank Up: rank progression is quest-based (RankQuests); the NinjaRank remote only
        -- accepts {ID="ChangeCategory", Category=..., Title=..., Village=...} — no "RankUp" job.

        -- Auto Exams / Balancing / ChakraMinigame: these remotes are server->client push only
        -- (verified: no client FireServer paths for answers/success), so there is nothing to fire.

        -- Auto Skill Tree — VERIFIED payload {Job="UnlockSkill", NodeID=...}; NodeIDs are
        -- ability IDs from Definitions.AbilityConfig. Best-effort: unlock everything affordable.
        if Config.AutoSkillTree and Remotes.SkillTree and Shared.AbilityConfig then
            for nodeID, _ in pairs(Shared.AbilityConfig) do
                pcall(function()
                    if Remotes.SkillTree:IsA("RemoteFunction") then
                        Remotes.SkillTree:InvokeServer({ Job = "UnlockSkill", NodeID = nodeID })
                    else
                        Remotes.SkillTree:FireServer({ Job = "UnlockSkill", NodeID = nodeID })
                    end
                end)
            end
        end

        -- Auto Quests: re-accept the tier's quests periodically (VERIFIED GiveQuest job)
        if Config.AutoQuests and Remotes.QuestEvent and (tick() - lastAutoQuestAccept) > 15 then
            lastAutoQuestAccept = tick()
            local tier = getQuestTier(tonumber(getPlayerLevel()) or 1)
            for _, questName in ipairs(tier.quests) do
                acceptQuestByName(questName)
            end
        end

        -- Auto Claim Dailies — VERIFIED: DailyFunction:InvokeServer("Claim"), missions via "GetMissions"
        if Config.AutoClaimDailies and Remotes.DailyFunction then
            pcall(function()
                Remotes.DailyFunction:InvokeServer("Claim")
            end)
        end
        if Config.AutoClaimDailies and Remotes.DailyQuestsRemote then
            pcall(function() Remotes.DailyQuestsRemote:FireServer("GetMissions") end)
        end

        -- Auto Allocate Stats — VERIFIED: {Job="IncreaseLevel", ID=statID} on a RemoteFunction
        if Config.AutoAllocateStats and Remotes.AttributesRemote then
            for _ = 1, 5 do
                if not allocateOnePoint(Config.StatPriority) then break end
            end
        end

        -- Shukaku Quiz Solver: real dialogue protocol is DialogueEvent:FireServer(dialogueId, indexTree)
        -- Best-effort: step any active dialogue's option 1/2 while the toggle is on.
        if Config.AutoShukakuQuiz and Remotes.DialogueEvent then
            local ansChoice = (Config.QuizVariant == "Variant 1 (Offensive)") and 1 or 2
            pcall(function()
                Remotes.DialogueEvent:FireServer("SandBeastQuiz", { ansChoice })
            end)
        end

        -- Auto Exams / Balancing / Chakra Minigame: their remotes are server->client push
        -- (no client fire paths for answers/success in the decompiled source) — inert here.

        -- Infinite Mount Dash — VERIFIED signature: FireServer(bool dashing)
        if Config.InfiniteMountDash and Remotes.ToadMountDash then
            Remotes.ToadMountDash:FireServer(true)
        end

        -- Auto Chest / Drop Collector — walks nearby prompts (chest/loot/reward)
        if Config.AutoChestCollect then
            interactWithPrompts({"open", "claim", "collect", "chest", "reward", "loot", "scroll", "pickup"})
        end

        -- Smart Mob Relocator: no matching mobs nearby -> TP to nearest landmark
        if Config.SmartRelocator and Config.AutoFarm and not getClosestMob() and (tick() - lastEmergencyEscape) > 6 then
            lastEmergencyEscape = tick()
            local best, bestDist = nil, math.huge
            for name, pos in pairs(FallbackTeleports) do
                local d = hrp and (pos - hrp.Position).Magnitude or 0
                if d < bestDist then best, bestDist = name, d end
            end
            if best then smartTeleportToZone(best) end
        end

        -- Auto Training Room: farm attack dummies for mastery XP
        if Config.AutoTrainingRoom and not Config.AutoFarm then
            Config.TargetType = "Attack Dummy"
            Config.AutoFarm = true
        end

        -- Auto Server Hop (FIX: was a dead toggle; rejoins when no matching mobs for X seconds)
        if Config.AutoServerHop then
            if getClosestMob() then
                noMobSince = tick()
            elseif (tick() - noMobSince) >= (Config.ServerHopNoMobTime or 30) then
                noMobSince = tick()
                Window:Notify({ Title = "Server Hop", Description = "No matching mobs for " .. (Config.ServerHopNoMobTime or 30) .. "s — hopping...", Lifetime = 4 })
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, plr)
                end)
            end
        else
            noMobSince = tick()
        end

        -- Boss Spawn Notifier + optional auto-TP (once per spawn, per boss name)
        if (Config.BossNotifier or Config.AutoTPOnBossSpawn) and (tick() - sessionStart) > 5 then
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("Model") then
                    local h = obj:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 and h.MaxHealth >= 40000 and not notifiedBosses[obj.Name] then
                        notifiedBosses[obj.Name] = true
                        if Config.BossNotifier then
                            Window:Notify({ Title = "BOSS SPAWNED", Description = obj.Name .. " is alive! (" .. math.floor(h.MaxHealth) .. " HP)", Lifetime = 6 })
                        end
                        if Config.AutoTPOnBossSpawn and not (Config.AutoKuramaRaid or Config.AutoPlayKuramaFight) then
                            local root = getEntityRoot(obj)
                            if root and char then
                                char:PivotTo(CFrame.new(root.Position + Vector3.new(0, 12, 0)))
                            end
                        end
                    end
                end
            end
        end
    end)
end

-----------------------------------------------
-- HUD UPDATER (Farm Stats / Quest Progress)
-----------------------------------------------
local function updateHUDs()
    if not ScriptRunning then return end
    pcall(function()
        local minutes = math.max((tick() - sessionStart) / 60, 0.01)
        if Config.ShowFarmHUD then
            local gui = ensureScreenGui("NTFarmHUD", "Farm Stats")
            if gui and gui:FindFirstChild("Panel") then
                gui.Panel.Body.Text = string.format(
                    "Lv: %s | Kills: %d (%.1f/min)\nTarget: %s | Farm: %s",
                    tostring(getPlayerLevel()), killCount, killCount / minutes,
                    tostring(Config.TargetType), Config.AutoFarm and "ON" or "OFF")
            end
        end
        if Config.ShowQuestHUD then
            local gui = ensureScreenGui("NTQuestHUD", "Quest Progress")
            if gui and gui:FindFirstChild("Panel") then
                local q = scanActiveQuestObjective()
                gui.Panel.Body.Text = (q ~= "" and q) or "No active quest objective found."
            end
        end
    end)
end

-----------------------------------------------
-- ESP Visuals Updater (FIX: full workspace re-scan + recreate every second
-- caused flicker & lag; now incremental add/remove with cached highlights)
-----------------------------------------------
local function updateESP()
    if not ScriptRunning then clearESP(); return end
    if not Config.MobESP and not Config.NPCESP then
        if next(espCache) then clearESP() end
        return
    end

    local seen = {}
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local root = getEntityRoot(obj)
            if h and root and h.Health > 0 then
                local isMob = h.MaxHealth > 1
                if (isMob and Config.MobESP) or (not isMob and Config.NPCESP) then
                    seen[obj] = true
                    if not espCache[obj] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = isMob
                            and (h.MaxHealth >= 40000 and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 60, 60))
                            or Color3.fromRGB(0, 255, 150)
                        hl.FillTransparency = isMob and 0.5 or 0.6
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Adornee = obj
                        hl.Parent = obj

                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 140, 0, 50)
                        bb.StudsOffset = Vector3.new(0, 4, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = root

                        local nm = Instance.new("TextLabel", bb)
                        nm.Size = UDim2.new(1, 0, 0.5, 0)
                        nm.BackgroundTransparency = 1
                        nm.Text = ((isMob and h.MaxHealth >= 40000) and "[BOSS] " or "") .. obj.Name
                            .. (isMob and (" [" .. math.floor(h.Health) .. " HP]") or "")
                        nm.TextColor3 = isMob and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(120, 255, 180)
                        nm.TextSize = 12
                        nm.Font = Enum.Font.GothamBold

                        local dl = Instance.new("TextLabel", bb)
                        dl.Name = "Dist"
                        dl.Size = UDim2.new(1, 0, 0.4, 0)
                        dl.Position = UDim2.new(0, 0, 0.5, 0)
                        dl.BackgroundTransparency = 1
                        dl.TextColor3 = Color3.fromRGB(200, 200, 255)
                        dl.TextSize = 10
                        dl.Font = Enum.Font.Gotham

                        espCache[obj] = { Highlight = hl, Billboard = bb, DistLabel = dl }
                    end
                    local entry = espCache[obj]
                    if entry and entry.DistLabel and hrp then
                        entry.DistLabel.Text = math.floor((root.Position - hrp.Position).Magnitude) .. " studs"
                    end
                end
            end
        end
    end

    -- Remove entries whose entity died/despawned (cheap: only iterate cache)
    for model, entry in pairs(espCache) do
        if not seen[model] then
            pcall(function()
                if entry.Highlight then entry.Highlight:Destroy() end
                if entry.Billboard then entry.Billboard:Destroy() end
            end)
            espCache[model] = nil
        end
    end
end

-----------------------------------------------
-- OPTIONAL COMMUNITY ACTIONS — no modal or network request on startup
-----------------------------------------------
local discordInvite = "https://discord.gg/dmawtf"
local inviteCode = "dmawtf"

do
    local community = tabs.Settings:AddLeftGroupbox("Community")
    community:AddLabel("Updates and announcements\n" .. discordInvite, true)
    community:AddButton("Copy Discord Invite", Window:Callback(function()
        if not setclipboard then
            Window:Notify({Title = "Clipboard", Description = "Clipboard access is unavailable. " .. discordInvite})
            return
        end
        setclipboard(discordInvite)
        Window:Notify({Title = "Clipboard", Description = "Discord invite copied."})
    end))
    community:AddButton("Open Invite in Discord", Window:Callback(function()
        local req = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
        if not req then
            Window:Notify({Title = "Community", Description = "Open this link manually: " .. discordInvite})
            return
        end
        local http = game:GetService("HttpService")
        req({Url = "http://127.0.0.1:6463/rpc?v=1", Method = "POST",
            Headers = {["Content-Type"] = "application/json", Origin = "https://discord.com"},
            Body = http:JSONEncode({cmd = "INVITE_BROWSER", args = {code = inviteCode}, nonce = http:GenerateGUID(false)})})
        Window:Notify({Title = "Community", Description = "Sent invite request to Discord."})
    end))
end

local function updateDashboard()
    if not ScriptRunning or Window.Destroyed then return end
    Window:SyncConfig()
    local dashboard = Window.Dashboard
    dashboard.Level:SetText("Level: " .. tostring(getPlayerLevel()) .. " / " .. tostring(getMaxLevel()))
    local boss = kuramaCache.target
    if boss and boss.Model:IsDescendantOf(WS) and isModelAlive(boss.Model) then
        dashboard.Boss:SetText("Kurama: " .. boss.Name .. " | HP: " .. tostring(math.floor(boss.Hum.Health)))
    else
        dashboard.Boss:SetText(kuramaCache.nextScan > 0 and "Kurama: not detected / not streamed" or "Kurama: use Check Kurama to scan")
    end
    local mode = Config.AutoPlayKuramaFight and "Kurama fight AI" or Config.AutoKuramaRaid and "Kurama raid"
        or Config.AutoFarm and "Auto farm" or "Idle"
    dashboard.Mode:SetText("Mode: " .. mode .. (Config.AutoRebirthLoop and " + rebirth loop" or ""))
    Window.RaidStatus:SetText("Combat: " .. (Window.RaidAction or "Idle"))
    dashboard.Rebirth:SetText("Rebirth: [" .. RebirthState.phase .. "] " .. RebirthState.note)
    rebirthStatusLabel:SetText("[" .. RebirthState.phase .. "] " .. RebirthState.note)
    local count = 0
    for _, remote in pairs(Remotes) do if remote then count += 1 end end
    dashboard.Remotes:SetText("Remotes: " .. count .. " handles resolved")
    dashboard.Error:SetText("Last error: " .. (Window.LastError or "none"):sub(1, 240))
    Window.ControlsHelp:SetText((Window.MenuKey.Value or "RightControl") .. ": show / hide menu\nEND or DELETE: stop and unload\nClosing the menu does not stop active features.")
end

-----------------------------------------------
-- BACKGROUND LOOPS (WITH STRICT SCRIPTRUNNING CHECKS)
-----------------------------------------------
-- Restore before the background schedulers can save defaults over a selected profile.
do
    if loadSettings() then
        Window:Notify({Title = "Configs", Description = "Restored profile: " .. ConfigStore.Selected, Lifetime = 6})
        if Config.AutoRebirthLoop then
            RebirthState.lastRaidState = nil
            rebirthSetPhase("IDLE", "Resumed from saved settings")
        end
    end
    if Window.RefreshProfiles then Window.RefreshProfiles() end
    local ok, err = NinjaRuntime.UpdateState()
    if not ok and Config.AutoExecute then Window.LastError = "Auto-execute: " .. tostring(err) end
end
-----------------------------------------------
-- MAIN BACKGROUND LOOP (FIX: old 1s loop re-scanned workspace 6+ times per
-- second when HUDs/ESP/farm all polled; now each subsystem runs at its own rate)
-----------------------------------------------
task.spawn(function()
    local lastESP, lastHUD, lastMech = 0, 0, 0
    while ScriptRunning do
        local now = tick()
        if (now - lastMech) >= 1 then
            lastMech = now
            pcall(handleGameMechanics)
            pcall(runModeActivationEngine)
            -- (runRebirthLoop has its own dedicated 1s loop with the status label)
        end
        if (now - lastESP) >= 0.5 then
            lastESP = now
            pcall(updateESP)
        end
        if (now - lastHUD) >= 1 then
            lastHUD = now
            pcall(updateHUDs)
            pcall(updateDashboard)
        end
        task.wait(0.25)
    end
end)

task.spawn(function()
    while ScriptRunning do
        if Config.AutoFarm and not farmRunning then
            task.spawn(startAutoFarm)
        end
        task.wait(0.15)
    end
end)

-----------------------------------------------
-- AUTO-PLAY KURAMA FIGHT AI LOOP
-----------------------------------------------
task.spawn(function()
    while ScriptRunning do
        if Config.AutoPlayKuramaFight then
            local ok, err = pcall(runKuramaFightAI)
            if not ok then KuramaCombat.Release(); reportKuramaError(err) end
        end
        task.wait(0.15)
    end
end)

-----------------------------------------------
-- AUTO-LEVEL ENGINE (drives the tiered quest engine until max level)
-----------------------------------------------
task.spawn(function()
    while ScriptRunning do
        if Config.AutoLevelTo200 then
            local lvl = tonumber(getPlayerLevel()) or 1
            local maxL = getMaxLevel()
            Config.AutoLevelQuest = lvl < maxL
        end
        task.wait(3)
    end
end)

-----------------------------------------------
-- SETTINGS AUTOSAVE
-----------------------------------------------
task.spawn(function()
    while ScriptRunning do
        task.wait(15)
        if not ScriptRunning then break end
        pcall(saveSettings)
    end
end)

Window:SyncConfig()
if not Window.Library.Toggled then Window.Library:Toggle() end
Window:Notify({Title = "dma.wtf / Ninja Time v8.1", Description = "Ready. " .. Window.MenuKey.Value .. " toggles the menu; END / DELETE unloads."})
print("[dma.wtf / Ninja Time v8.1] Interface ready; native Kurama combat and attack avoidance loaded.")
