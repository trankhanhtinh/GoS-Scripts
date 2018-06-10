
require 'utils'
require 'Vector'
require 'FF15Menu'

local TableInsert = table.insert
local TableRemove = table.remove

function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end

delayedActions = {}
function DelayAction(func, delay, args)
	if not delayedActionsExecuter then
		function delayedActionsExecuter()
			for i, funcs in pairs(delayedActions) do
				if i <= RiotClock.time then
					for _, f in ipairs(funcs) do 
						f.func(unpack(f.args or {})) 
					end
					delayedActions[i] = nil
				end
			end
		end
		AddEvent(Events.OnTick , delayedActionsExecuter)                
	end
	local time = RiotClock.time + (delay or 0)
	if delayedActions[time] then 
		table.insert(delayedActions[time], { func = func, args = args })
	else 
		delayedActions[time] = { { func = func, args = args } }
	end
end

function GetMousePos()
	return pwHud.hudManager.activeVirtualCursorPos
end

local function class()
	local cls = {}
	cls.__index = cls
	return setmetatable(cls, {__call = function (c, ...)
		local instance = setmetatable({}, cls)
		if cls.__init then
			cls.__init(instance, ...)
		end
		return instance
	end})
end

JustEvade = class()

function OnLoad()
	EMenu = Menu("JustEvade", "JustEvade")
	JustEvade()
end

function JustEvade:__init()
	self.JustEvade = false
	self.ReCalc = false
	self.DetSpells = {}
	EMenu:sub("Main", "Main Settings")
	EMenu.Main:checkbox("Evade", "Enable Evade", true)
	EMenu.Main:checkbox("Dodge", "Dodge Spells", true)
	EMenu.Main:checkbox("Draw", "Draw Spells", true)
	EMenu.Main:checkbox("SafePos", "Draw Safe Position", true)
	EMenu.Main:checkbox("RP", "Recalculate Path", false)
	EMenu.Main:list("Pathfinding", "Pathfinding Type", 3, {"Basic", "Mouse", "Effective"})
	EMenu:sub("Misc", "Misc Settings")
	EMenu.Misc:key("SD", "Stop Dodging", string.byte("A"))
	EMenu.Misc:key("DD", "Dodge Only Dangerous", string.byte("N"))
	EMenu.Misc:slider("DE","Delay Before Enabling OW", 0, 1, 0.25, 0.01)
	EMenu.Misc:slider("TE","Extended Timer On Evade", 0, 1, 0, 0.01)
	EMenu.Misc:slider("ER","Extra Spell Radius", 0, 100, 20, 5)
	EMenu:sub("Spells", "Spell Settings")
	DelayAction(function()
		for _,spell in pairs(self.Spells) do
			for l,k in pairs(ObjectManager:GetEnemyHeroes()) do
				if spell.charName == k.charName then
					EMenu.Spells:sub(_,""..spell.charName.." | "..spell.displayName)
					EMenu.Spells[_]:checkbox("Dodge".._, "Dodge Spell", true)
					EMenu.Spells[_]:checkbox("Draw".._, "Draw Spell", true)
				end
			end
		end
	end, 0.1)
	AddEvent(Events.OnTick, function() self:Dodge() end)
	AddEvent(Events.OnDraw, function() self:Draw() end)
	AddEvent(Events.OnProcessSpell, function(...) self:OnProcessSpell(...) end)

self.Spells = {
	["AatroxQ"]={charName="Aatrox",slot=_Q,type="circular",displayName="Dark Flight",danger=2,speed=450,range=650,delay=0.25,radius=275,collision=false},
	["AatroxE"]={charName="Aatrox",slot=_E,type="linear",displayName="Blades of Torment",danger=1,speed=1250,range=1000,delay=0.25,radius=120,collision=false},
	["AhriOrbofDeception"]={charName="Ahri",slot=_Q,type="linear",displayName="Orb of Deception",danger=1,speed=2500,range=880,delay=0.25,radius=100,collision=false},
	["AhriSeduce"]={charName="Ahri",slot=_E,type="linear",displayName="Charm",danger=1,speed=1550,range=975,delay=0.25,radius=60,collision=true},
	["Pulverize"]={charName="Alistar",slot=_Q,type="circular",displayName="Pulverize",danger=1,speed=math.huge,range=0,delay=0.25,radius=365,collision=false},
	["BandageToss"]={charName="Amumu",slot=_Q,type="linear",displayName="Bandage Toss",danger=1,speed=2000,range=1100,delay=0.25,radius=80,collision=true},
	["Tantrum"]={charName="Amumu",slot=_E,type="circular",displayName="Tantrum",danger=2,speed=math.huge,range=0,delay=0.25,radius=350,collision=false},
	["CurseoftheSadMummy"]={charName="Amumu",slot=_R,type="circular",displayName="Curse of the Sad Mummy",danger=3,speed=math.huge,range=0,delay=0.25,radius=550,collision=false},
	["FlashFrost"]={charName="Anivia",slot=_Q,type="linear",displayName="Flash Frost",danger=1,speed=850,range=1075,delay=0.25,radius=110,collision=false},
	["InfernalGuardian"]={charName="Annie",slot=_R,type="circular",displayName="Summon Tibbers",danger=3,speed=math.huge,range=600,delay=0.25,radius=290,collision=false},
	["EnchantedCrystalArrow"]={charName="Ashe",slot=_R,type="linear",displayName="Enchanted Crystal Arrow",danger=2,speed=1600,range=25000,delay=0.25,radius=130,collision=false},
	["AurelionSolQ"]={charName="AurelionSol",slot=_Q,type="linear",displayName="Starsurge",danger=1,speed=850,range=1075,delay=0.25,radius=210,collision=false},
	["AurelionSolR"]={charName="AurelionSol",slot=_R,type="linear",displayName="Voice of Light",danger=2,speed=4500,range=1500,delay=0.35,radius=120,collision=false},
	["BardQ"]={charName="Bard",slot=_Q,type="linear",displayName="Cosmic Binding",danger=1,speed=1500,range=950,delay=0.25,radius=60,collision=true},
	["BardR"]={charName="Bard",slot=_R,type="circular",displayName="Tempered Fate",danger=2,speed=2100,range=3400,delay=0.5,radius=350,collision=false},
	["RocketGrab"]={charName="Blitzcrank",slot=_Q,type="linear",displayName="Rocket Grab",danger=1,speed=1800,range=925,delay=0.25,radius=70,collision=true},
	["StaticField"]={charName="Blitzcrank",slot=_R,type="circular",displayName="Static Field",danger=2,speed=math.huge,range=0,delay=0.25,radius=600,collision=false},
	["BrandQ"]={charName="Brand",slot=_Q,type="linear",displayName="Sear",danger=1,speed=1600,range=1050,delay=0.25,radius=60,collision=true},
	["BrandW"]={charName="Brand",slot=_W,type="circular",displayName="Pillar of Flame",danger=2,speed=math.huge,range=900,delay=0.85,radius=250,collision=false},
	["BraumQ"]={charName="Braum",slot=_Q,type="linear",displayName="Winter's Bite",danger=1,speed=1700,range=1000,delay=0.25,radius=60,collision=true},
	["BraumRWrapper"]={charName="Braum",slot=_R,type="linear",displayName="Glacial Fissure",danger=1,speed=1400,range=1250,delay=0.5,radius=115,collision=false},
	["CaitlynPiltoverPeacemaker"]={charName="Caitlyn",slot=_Q,type="linear",displayName="Piltover Peacemaker",danger=1,speed=2200,range=1250,delay=0.625,radius=90,collision=false},
	["CaitlynYordleTrap"]={charName="Caitlyn",slot=_W,type="circular",displayName="Yordle Snap Trap",danger=2,speed=math.huge,range=800,delay=0.25,radius=75,collision=false},
	["CaitlynEntrapmentMissile"]={charName="Caitlyn",slot=_E,type="linear",displayName="90 Caliber Net",danger=1,speed=1600,range=750,delay=0.25,radius=70,collision=true},
	["CamilleE"]={charName="Camille",slot=_E,type="linear",displayName="Hookshot",danger=1,speed=1900,range=800,delay=0,radius=60,collision=false},
	["CamilleEDash2"]={charName="Camille",slot=_E,type="linear",displayName="Hookshot",danger=1,speed=1900,range=400,delay=0,radius=60,collision=false},
	["CassiopeiaQ"]={charName="Cassiopeia",slot=_Q,type="circular",displayName="Noxious Blast",danger=1,speed=math.huge,range=850,delay=0.4,radius=150,collision=false},
	["CassiopeiaW"]={charName="Cassiopeia",slot=_W,type="circular",displayName="Miasma",danger=1,speed=2500,range=800,delay=0.25,radius=160,collision=false},
	["Rupture"]={charName="Chogath",slot=_Q,type="circular",displayName="Rupture",danger=1,speed=math.huge,range=950,delay=0.5,radius=250,collision=false},
	["PhosphorusBomb"]={charName="Corki",slot=_Q,type="circular",displayName="Phosphorus Bomb",danger=1,speed=1000,range=825,delay=0.25,radius=250,collision=false},
	["CarpetBomb"]={charName="Corki",slot=_W,type="linear",displayName="Valkyrie",danger=1,speed=650,range=600,delay=0,radius=100,collision=false},
	["CarpetBombMega"]={charName="Corki",slot=_W,type="linear",displayName="Special Delivery",danger=1,speed=1500,range=1800,delay=0,radius=100,collision=false},
	["MissileBarrageMissile"]={charName="Corki",slot=_R,type="linear",displayName="Missile Barrage",danger=1,speed=2000,range=1225,delay=0.175,radius=40,collision=true},
	["MissileBarrageMissile2"]={charName="Corki",slot=_R,type="linear",displayName="Missile Barrage",danger=1,speed=2000,range=1225,delay=0.175,radius=40,collision=true},
	["DianaArc"]={charName="Diana",slot=_Q,type="circular",displayName="Crescent Strike",danger=2,speed=1400,range=900,delay=0.25,radius=205,collision=false},
	["InfectedCleaverMissileCast"]={charName="DrMundo",slot=_Q,type="linear",displayName="Infected Cleaver",danger=1,speed=2000,range=975,delay=0.25,radius=60,collision=true},
	["DravenDoubleShot"]={charName="Draven",slot=_E,type="linear",displayName="Stand Aside",danger=2,speed=1400,range=1050,delay=0.25,radius=130,collision=false},
	["DravenRCast"]={charName="Draven",slot=_R,type="linear",displayName="Whirling Death",danger=2,speed=2000,range=25000,delay=0.5,radius=160,collision=false},
	["EkkoQ"]={charName="Ekko",slot=_Q,type="linear",displayName="Timewinder",danger=1,speed=1650,range=1075,delay=0.25,radius=120,collision=false},
	["EkkoW"]={charName="Ekko",slot=_W,type="circular",displayName="Parallel Convergence",danger=1,speed=1650,range=1600,delay=3.75,radius=400,collision=false},
	["EkkoR"]={charName="Ekko",slot=_R,type="circular",displayName="Chronobreak",danger=3,speed=1650,range=1600,delay=0.25,radius=375,collision=false},
	["EliseHumanE"]={charName="Elise",slot=_E,type="linear",displayName="Cocoon",danger=1,speed=1600,range=1075,delay=0.25,radius=55,collision=true},
	["EvelynnQ"]={charName="Evelynn",slot=_Q,type="linear",displayName="Hate Spike",danger=1,speed=2200,range=800,delay=0.25,radius=35,collision=true},
	["EzrealMysticShot"]={charName="Ezreal",slot=_Q,type="linear",displayName="Mystic Shot",danger=1,speed=2000,range=1150,delay=0.25,radius=60,collision=true},
	["EzrealEssenceFlux"]={charName="Ezreal",slot=_W,type="linear",displayName="Essence Flux",danger=1,speed=1600,range=1000,delay=0.25,radius=80,collision=false},
	["EzrealTrueshotBarrage"]={charName="Ezreal",slot=_R,type="linear",displayName="Trueshot Barrage",danger=2,speed=2000,range=25000,delay=1,radius=160,collision=false},
	["FioraW"]={charName="Fiora",slot=_W,type="linear",displayName="Riposte",danger=1,speed=3200,range=750,delay=0.75,radius=70,collision=false},
	["FizzR"]={charName="Fizz",slot=_R,type="linear",displayName="Chum the Waters",danger=2,speed=1300,range=1300,delay=0.25,radius=80,collision=false},
	["GalioQ"]={charName="Galio",slot=_Q,type="circular",displayName="Winds of War",danger=1,speed=1150,range=825,delay=0.25,radius=250,collision=false},
	["GalioE"]={charName="Galio",slot=_E,type="linear",displayName="Justice Punch",danger=2,speed=1800,range=650,delay=0.45,radius=160,collision=false},
	["GalioR"]={charName="Galio",slot=_R,type="circular",displayName="Hero's Entrance",danger=2,speed=math.huge,range=5500,delay=2.75,radius=650,collision=false},
	["GangplankR"]={charName="Gangplank",slot=_R,type="circular",displayName="Cannon Barrage",danger=2,speed=math.huge,range=25000,delay=0.25,radius=600,collision=false},
	["GnarQ"]={charName="Gnar",slot=_Q,type="linear",displayName="Boomerang Throw",danger=1,speed=2500,range=1100,delay=0.25,radius=55,collision=false},
	["GnarE"]={charName="Gnar",slot=_E,type="circular",displayName="Hop",danger=2,speed=900,range=475,delay=0.25,radius=160,collision=false},
	["GnarBigQ"]={charName="Gnar",slot=_Q,type="linear",displayName="Boulder Toss",danger=1,speed=2100,range=1100,delay=0.5,radius=90,collision=true},
	["GnarBigW"]={charName="Gnar",slot=_W,type="linear",displayName="Wallop",danger=1,speed=math.huge,range=550,delay=0.6,radius=100,collision=false},
	["GnarBigE"]={charName="Gnar",slot=_E,type="circular",displayName="Crunch",danger=2,speed=800,range=600,delay=0.25,radius=375,collision=false},
	["GnarR"]={charName="Gnar",slot=_R,type="circular",displayName="GNAR!",danger=3,speed=math.huge,range=0,delay=0.25,radius=475,collision=false},
	["GragasQ"]={charName="Gragas",slot=_Q,type="circular",displayName="Barrel Roll",danger=1,speed=1000,range=850,delay=0.25,radius=250,collision=false},
	["GragasE"]={charName="Gragas",slot=_E,type="linear",displayName="Body Slam",danger=2,speed=900,range=600,delay=0.25,radius=170,collision=true},
	["GragasR"]={charName="Gragas",slot=_R,type="circular",displayName="Explosive Cask",danger=3,speed=1800,range=1000,delay=0.25,radius=400,collision=false},
	["GravesQLineSpell"]={charName="Graves",slot=_Q,type="linear",displayName="End of the Line",danger=1,speed=2000,range=925,delay=0.25,radius=20,collision=false},
	["GravesSmokeGrenade"]={charName="Graves",slot=_W,type="circular",displayName="Smoke Screen",danger=1,speed=1450,range=950,delay=0.15,radius=250,collision=false},
	["GravesChargeShot"]={charName="Graves",slot=_R,type="linear",displayName="Collateral Damage",danger=2,speed=2100,range=1000,delay=0.25,radius=100,collision=false},
	["HecarimRapidSlash"]={charName="Hecarim",slot=_Q,type="circular",displayName="Collateral Damage",danger=1,speed=math.huge,range=0,delay=0,radius=350,collision=false},
	["HecarimUlt"]={charName="Hecarim",slot=_R,type="linear",displayName="Onslaught of Shadows",danger=2,speed=1100,range=1000,delay=0.01,radius=230,collision=false},
	["HeimerdingerW"]={charName="Heimerdinger",slot=_W,type="linear",displayName="Hextech Micro-Rockets",danger=1,speed=2050,range=1325,delay=0.25,radius=60,collision=true},
	["HeimerdingerE"]={charName="Heimerdinger",slot=_E,type="circular",displayName="CH-2 Electron Storm Grenade",danger=1,speed=1200,range=970,delay=0.25,radius=250,collision=false},
	["HeimerdingerEUlt"]={charName="Heimerdinger",slot=_E,type="circular",displayName="CH-3X Lightning Grenade",danger=2,speed=1200,range=970,delay=0.25,radius=250,collision=false},
	["IllaoiQ"]={charName="Illaoi",slot=_Q,type="linear",displayName="Tentacle Smash",danger=1,speed=math.huge,range=850,delay=0.75,radius=100,collision=false},
	["IllaoiE"]={charName="Illaoi",slot=_E,type="linear",displayName="Test of Spirit",danger=1,speed=1900,range=900,delay=0.25,radius=50,collision=true},
	["IllaoiR"]={charName="Illaoi",slot=_R,type="circular",displayName="Leap of Faith",danger=3,speed=math.huge,range=0,delay=0.5,radius=450,collision=false},
	["IreliaW2"]={charName="Irelia",slot=_W,type="circular",displayName="Defiant Dance",danger=1,speed=math.huge,range=0,delay=0,radius=275,collision=false},
	["IreliaW2"]={charName="Irelia",slot=_W,type="linear",displayName="Defiant Dance",danger=1,speed=math.huge,range=825,delay=0.25,radius=90,collision=false},
	["IreliaE"]={charName="Irelia",slot=_E,type="circular",displayName="Flawless Duet",danger=1,speed=2000,range=900,delay=0,radius=90,collision=false},
	["IreliaE2"]={charName="Irelia",slot=_E,type="circular",displayName="Flawless Duet",danger=1,speed=2000,range=900,delay=0,radius=90,collision=false},
	["IreliaR"]={charName="Irelia",slot=_R,type="linear",displayName="Vanguard's Edge",danger=2,speed=2000,range=1000,delay=0.4,radius=160,collision=false},
	["IvernQ"]={charName="Ivern",slot=_Q,type="linear",displayName="Rootcaller",danger=1,speed=1300,range=1075,delay=0.25,radius=80,collision=true},
	["HowlingGale"]={charName="Janna",slot=_Q,type="linear",displayName="Howling Gale",danger=1,speed=667,range=1750,delay=0,radius=100,collision=false},
	["JarvanIVDragonStrike"]={charName="JarvanIV",slot=_Q,type="linear",displayName="Dragon Strike",danger=1,speed=math.huge,range=770,delay=0.4,radius=60,collision=false},
	["JarvanIVDemacianStandard"]={charName="JarvanIV",slot=_E,type="circular",displayName="Demacian Standard",danger=1,speed=3440,range=860,delay=0,radius=175,collision=false},
	["JayceShockBlast"]={charName="Jayce",slot=_Q,type="linear",displayName="Shock Blast",danger=1,speed=1450,range=1175,delay=0.214,radius=70,collision=true},
	["JayceShockBlastWallMis"]={charName="Jayce",slot=_Q,type="linear",displayName="Shock Blast",danger=2,speed=2350,range=1900,delay=0.214,radius=115,collision=true},
	["JhinW"]={charName="Jhin",slot=_W,type="linear",displayName="Deadly Flourish",danger=1,speed=5000,range=3000,delay=0.75,radius=40,collision=false},
	["JhinE"]={charName="Jhin",slot=_E,type="circular",displayName="Captive Audience",danger=1,speed=1600,range=750,delay=0.25,radius=120,collision=false},
	["JhinRShot"]={charName="Jhin",slot=_R,type="linear",displayName="Curtain Call",danger=2,speed=5000,range=3500,delay=0.25,radius=80,collision=false},
	["JinxW"]={charName="Jinx",slot=_W,type="linear",displayName="Zap!",danger=1,speed=3300,range=1450,delay=0.6,radius=60,collision=true},
	["JinxE"]={charName="Jinx",slot=_E,type="circular",displayName="Flame Chompers!",danger=1,speed=1100,range=900,delay=1.5,radius=120,collision=false},
	["JinxR"]={charName="Jinx",slot=_R,type="linear",displayName="Mega Death Rocket!",danger=2,speed=1700,range=25000,delay=0.6,radius=140,collision=false},
	["KaisaW"]={charName="Kaisa",slot=_W,type="linear",displayName="Void Seeker",danger=1,speed=1750,range=3000,delay=0.4,radius=100,collision=true},
	["KalistaMysticShot"]={charName="Kalista",slot=_Q,type="linear",displayName="Pierce",danger=1,speed=2400,range=1150,delay=0.35,radius=40,collision=true},
	["KarmaQ"]={charName="Karma",slot=_Q,type="linear",displayName="Inner Flame",danger=1,speed=1700,range=950,delay=0.25,radius=60,collision=true},
	["KarmaQMantra"]={charName="Karma",slot=_Q,type="linear",displayName="Inner Flame",danger=2,speed=1700,range=950,delay=0.25,radius=80,collision=true},
	["KarthusLayWasteA1"]={charName="Karthus",slot=_Q,type="circular",displayName="Lay Waste",danger=1,speed=math.huge,range=875,delay=0.625,radius=200,collision=false},
	["KarthusLayWasteA2"]={charName="Karthus",slot=_Q,type="circular",displayName="Lay Waste",danger=1,speed=math.huge,range=875,delay=0.625,radius=200,collision=false},
	["KarthusLayWasteA3"]={charName="Karthus",slot=_Q,type="circular",displayName="Lay Waste",danger=1,speed=math.huge,range=875,delay=0.625,radius=200,collision=false},
	["Riftwalk"]={charName="Kassadin",slot=_R,type="circular",displayName="Riftwalk",danger=2,speed=math.huge,range=500,delay=0.25,radius=300,collision=false},
	["KatarinaE"]={charName="Katarina",slot=_E,type="circular",displayName="Shunpo",danger=2,speed=math.huge,range=725,delay=0.15,radius=150,collision=false},
	["KatarinaR"]={charName="Katarina",slot=_R,type="circular",displayName="Death Lotus",danger=2,speed=math.huge,range=0,delay=0,radius=550,collision=false},
	["KaynQ"]={charName="Kayn",slot=_Q,type="circular",displayName="Reaping Slash",danger=2,speed=math.huge,range=0,delay=0.15,radius=350,collision=false},
	["KaynW"]={charName="Kayn",slot=_W,type="linear",displayName="Blade's Reach",danger=1,speed=math.huge,range=700,delay=0.55,radius=90,collision=false},
	["KennenShurikenHurlMissile1"]={charName="Kennen",slot=_Q,type="linear",displayName="Thundering Shuriken",danger=1,speed=1700,range=1050,delay=0.175,radius=50,collision=true},
	["KhazixW"]={charName="Khazix",slot=_W,type="linear",displayName="Void Spike",danger=1,speed=1700,range=1000,delay=0.25,radius=70,collision=true},
	["KhazixWLong"]={charName="Khazix",slot=_W,type="threeway",displayName="Void Spike",danger=2,speed=1700,range=1000,delay=0.25,radius=70,angle=50,collision=true},
	["KhazixE"]={charName="Khazix",slot=_E,type="circular",displayName="Leap",danger=2,speed=1000,range=700,delay=0.25,radius=320,collision=false},
	["KhazixELong"]={charName="Khazix",slot=_E,type="circular",displayName="Leap",danger=2,speed=1000,range=900,delay=0.25,radius=320,collision=false},
	["KledQ"]={charName="Kled",slot=_Q,type="linear",displayName="Beartrap on a Rope",danger=1,speed=1600,range=800,delay=0.25,radius=45,collision=true},
	["KledEDash"]={charName="Kled",slot=_E,type="linear",displayName="Jousting",danger=2,speed=1100,range=550,delay=0,radius=90,collision=false},
	["KogMawQ"]={charName="KogMaw",slot=_Q,type="linear",displayName="Caustic Spittle",danger=1,speed=1650,range=1175,delay=0.25,radius=70,collision=true},
	["KogMawVoidOoze"]={charName="KogMaw",slot=_E,type="linear",displayName="Void Ooze",danger=1,speed=1400,range=1280,delay=0.25,radius=120,collision=false},
	["KogMawLivingArtillery"]={charName="KogMaw",slot=_R,type="circular",displayName="Living Artillery",danger=1,speed=math.huge,range=1800,delay=0.85,radius=200,collision=false},
	["LeBlancW"]={charName="Leblanc",slot=_W,type="circular",displayName="Distortion",danger=2,speed=1450,range=600,delay=0.25,radius=260,collision=false},
	["LeBlancE"]={charName="Leblanc",slot=_E,type="linear",displayName="Ethereal Chains",danger=1,speed=1750,range=925,delay=0.25,radius=55,collision=true},
	["LeBlancRW"]={charName="Leblanc",slot=_W,type="circular",displayName="Distortion",danger=2,speed=1450,range=600,delay=0.25,radius=260,collision=false},
	["LeBlancRE"]={charName="Leblanc",slot=_E,type="linear",displayName="Ethereal Chains",danger=1,speed=1750,range=925,delay=0.25,radius=55,collision=true},
	["BlindMonkQOne"]={charName="LeeSin",slot=_Q,type="linear",displayName="Sonic Wave",danger=1,speed=1800,range=1200,delay=0.25,radius=60,collision=true},
	["BlindMonkEOne"]={charName="LeeSin",slot=_E,type="circular",displayName="Tempest",danger=2,speed=math.huge,range=0,delay=0.25,radius=350,collision=false},
	["LeonaZenithBlade"]={charName="Leona",slot=_E,type="linear",displayName="Zenith Blade",danger=1,speed=2000,range=875,delay=0.25,radius=70,collision=false},
	["LeonaSolarFlare"]={charName="Leona",slot=_R,type="circular",displayName="Solar Flare",danger=3,speed=math.huge,range=1200,delay=0.625,radius=250,collision=false},
	["LissandraQ"]={charName="Lissandra",slot=_Q,type="linear",displayName="Ice Shard",danger=1,speed=2200,range=825,delay=0.251,radius=75,collision=false},
	["LissandraW"]={charName="Lissandra",slot=_W,type="circular",displayName="Ring of Frost",danger=2,speed=math.huge,range=0,delay=0.25,radius=450,collision=false},
	["LissandraE"]={charName="Lissandra",slot=_E,type="linear",displayName="Glacial Path",danger=1,speed=850,range=1050,delay=0.25,radius=125,collision=false},
	["LucianQ"]={charName="Lucian",slot=_Q,type="linear",displayName="Piercing Light",danger=1,speed=math.huge,range=900,delay=0.5,radius=65,collision=false},
	["LucianW"]={charName="Lucian",slot=_W,type="linear",displayName="Ardent Blaze",danger=1,speed=1600,range=900,delay=0.25,radius=55,collision=false},
	["LucianR"]={charName="Lucian",slot=_R,type="linear",displayName="The Culling",danger=2,speed=2800,range=1200,delay=0.01,radius=110,collision=true},
	["LuluQ"]={charName="Lulu",slot=_Q,type="linear",displayName="Glitterlance",danger=1,speed=1450,range=925,delay=0.25,radius=60,collision=false},
	["LuxLightBinding"]={charName="Lux",slot=_Q,type="linear",displayName="Light Binding",danger=1,speed=1200,range=1175,delay=0.25,radius=50,collision=true},
	["LuxLightStrikeKugel"]={charName="Lux",slot=_E,type="circular",displayName="Lucent Singularity",danger=2,speed=1200,range=1000,delay=0.25,radius=310,collision=false},
	["LuxMaliceCannon"]={charName="Lux",slot=_R,type="linear",displayName="Final Spark",danger=2,speed=math.huge,range=3340,delay=1.375,radius=120,collision=false},
	["Landslide"]={charName="Malphite",slot=_E,type="circular",displayName="Ground Slam",danger=2,speed=math.huge,range=0,delay=0.242,radius=200,collision=false},
	["UFSlash"]={charName="Malphite",slot=_R,type="circular",displayName="Unstoppable Force",danger=3,speed=1835,range=1000,delay=0,radius=300,collision=false},
	["MaokaiQ"]={charName="Maokai",slot=_Q,type="linear",displayName="Bramble Smash",danger=1,speed=1600,range=600,delay=0.375,radius=110,collision=false},
	["MissFortuneScattershot"]={charName="MissFortune",slot=_E,type="circular",displayName="Make It Rain",danger=2,speed=math.huge,range=1000,delay=0.5,radius=400,collision=false},
	["DarkBindingMissile"]={charName="Morgana",slot=_Q,type="linear",displayName="Dark Binding",danger=1,speed=1200,range=1175,delay=0.25,radius=70,collision=true},
	["TormentedSoil"]={charName="Morgana",slot=_W,type="circular",displayName="Tormented Soil",danger=2,speed=math.huge,range=900,delay=0.25,radius=325,collision=false},
	["NamiQ"]={charName="Nami",slot=_Q,type="circular",displayName="Aqua Prison",danger=1,speed=math.huge,range=875,delay=0.95,radius=200,collision=false},
	["NamiR"]={charName="Nami",slot=_R,type="linear",displayName="Tidal Wave",danger=2,speed=850,range=2750,delay=0.5,radius=250,collision=false},
	["NasusE"]={charName="Nasus",slot=_E,type="circular",displayName="Spirit Fire",danger=2,speed=math.huge,range=650,delay=0.25,radius=400,collision=false},
	["NautilusAnchorDrag"]={charName="Nautilus",slot=_Q,type="linear",displayName="Dredge Line",danger=2,speed=2000,range=1100,delay=0.25,radius=90,collision=true},
	["JavelinToss"]={charName="Nidalee",slot=_Q,type="linear",displayName="Javelin Toss",danger=1,speed=1300,range=1500,delay=0.25,radius=40,collision=true},
	["Bushwhack"]={charName="Nidalee",slot=_W,type="circular",displayName="Bushwhack",danger=1,speed=math.huge,range=900,delay=0.25,radius=85,collision=true},
	["Pounce"]={charName="Nidalee",slot=_W,type="circular",displayName="Pounce",danger=2,speed=1750,range=750,delay=0.25,radius=200,collision=false},
	["NocturneDuskbringer"]={charName="Nocturne",slot=_Q,type="linear",displayName="Duskbringer",danger=1,speed=1600,range=1200,delay=0.25,radius=60,collision=false},
	["AbsoluteZero"]={charName="Nunu",slot=_R,type="circular",displayName="Absolute Zero",danger=3,speed=math.huge,range=0,delay=0.01,radius=650,collision=false},
	["OlafAxeThrowCast"]={charName="Olaf",slot=_Q,type="linear",displayName="Undertow",danger=1,speed=1600,range=1000,delay=0.25,radius=90,collision=false},
	["OrianaIzunaCommand"]={charName="Orianna",slot=_Q,type="linear",displayName="Command Attack",danger=1,speed=1400,range=825,delay=0.25,radius=80,collision=false},
	["OrianaDissonanceCommand"]={charName="Orianna",slot=_W,type="circular",displayName="Command Dissonance",proj="OrianaDissonanceCommand-",danger=2,speed=math.huge,range=0,delay=0.25,radius=250,collision=false},
	["OrianaRedactCommand"]={charName="Orianna",slot=_E,type="linear",displayName="Command Protect",proj="orianaredact",danger=1,speed=1400,range=1100,delay=0.25,radius=80,collision=false},
	["OrianaDetonateCommand"]={charName="Orianna",slot=_R,type="circular",displayName="Command Shockwave",proj="OrianaDetonateCommand-",danger=3,speed=math.huge,range=0,delay=0.5,radius=325,collision=false},
	["OrnnQ"]={charName="Ornn",slot=_Q,type="linear",displayName="Volcanic Rupture",danger=1,speed=1800,range=800,delay=0.3,radius=65,collision=false},
	["OrnnE"]={charName="Ornn",slot=_E,type="linear",displayName="Searing Charge",danger=2,speed=1800,range=800,delay=0.35,radius=150,collision=false},
	["OrnnR"]={charName="Ornn",slot=_R,type="linear",displayName="Call of the Forge God",danger=2,speed=1650,range=2500,delay=0.5,radius=250,collision=false},
	["OrnnRCharge"]={charName="Ornn",slot=_R,type="linear",displayName="Call of the Forge God",danger=2,speed=1650,range=2500,delay=0.25,radius=200,collision=true},
	["PantheonRFall"]={charName="Pantheon",slot=_R,type="circular",displayName="Grand Skyfall",danger=2,speed=math.huge,range=5500,delay=2.25,radius=700,collision=false},
	["PoppyQSpell"]={charName="Poppy",slot=_Q,type="linear",displayName="Hammer Shock",danger=1,speed=math.huge,range=430,delay=1.32,radius=85,collision=false},
	["PoppyRSpell"]={charName="Poppy",slot=_R,type="linear",displayName="Keeper's Verdict",danger=2,speed=2000,range=1900,delay=0.333,radius=100,collision=false},
	["PykeQMelee"]={charName="Pyke",slot=_Q,type="linear",displayName="Bone Skewer",danger=2,speed=math.huge,range=400,delay=0.25,radius=70,collision=false},
	["PykeQRange"]={charName="Pyke",slot=_Q,type="linear",displayName="Bone Skewer",danger=2,speed=2000,range=1100,delay=0.2,radius=70,collision=true},
	["QuinnQ"]={charName="Quinn",slot=_Q,type="linear",displayName="Blinding Assault",danger=1,speed=1550,range=1025,delay=0.25,radius=60,collision=true},
	["RakanQ"]={charName="Rakan",slot=_Q,type="linear",displayName="Gleaming Quill",danger=1,speed=1850,range=900,delay=0.25,radius=65,collision=true},
	["RakanW"]={charName="Rakan",slot=_W,type="circular",displayName="Grand Entrance",danger=2,speed=2050,range=600,delay=0,radius=250,collision=false},
	["RekSaiQBurrowed"]={charName="Reksai",slot=_Q,type="linear",displayName="Prey Seeker",danger=1,speed=1950,range=1650,delay=0.125,radius=65,collision=true},
	["RenektonCleave"]={charName="Renekton",slot=_Q,type="circular",displayName="Cull the Meek",danger=2,speed=math.huge,range=0,delay=0.25,radius=325,collision=false},
	["RenektonSliceAndDice"]={charName="Renekton",slot=_E,type="linear",displayName="Slice and Dice",danger=2,speed=1125,range=450,delay=0.25,radius=45,collision=false},
	["RengarW"]={charName="Rengar",slot=_W,type="circular",displayName="Battle Roar",danger=2,speed=math.huge,range=0,delay=0.25,radius=450,collision=false},
	["RengarE"]={charName="Rengar",slot=_E,type="linear",displayName="Bola Strike",danger=1,speed=1500,range=1000,delay=0.25,radius=70,collision=true},
	["RivenMartyr"]={charName="Riven",slot=_W,type="circular",displayName="Ki Burst",danger=2,speed=math.huge,range=0,delay=0.267,radius=135,collision=false},
	["RumbleGrenade"]={charName="Rumble",slot=_E,type="linear",displayName="Electro Harpoon",danger=1,speed=2000,range=850,delay=0.25,radius=60,collision=true},
	["RyzeQ"]={charName="Ryze",slot=_Q,type="linear",displayName="Overload",danger=1,speed=1700,range=1000,delay=0.25,radius=55,collision=true},
	["SejuaniWDummy"]={charName="Sejuani",slot=_W,type="linear",displayName="Winter's Wrath",danger=1,speed=math.huge,range=600,delay=1,radius=65,collision=false},
	["SejuaniR"]={charName="Sejuani",slot=_R,type="linear",displayName="Glacial Prison",danger=3,speed=1600,range=1300,delay=0.25,radius=120,collision=false},
	["ShenE"]={charName="Shen",slot=_E,type="linear",displayName="Shadow Dash",danger=2,speed=1200,range=600,delay=0,radius=60,collision=false},
	["ShyvanaFireball"]={charName="Shyvana",slot=_E,type="linear",displayName="Flame Breath",danger=1,speed=1575,range=925,delay=0.25,radius=60,collision=false},
	["ShyvanaTransformLeap"]={charName="Shyvana",slot=_R,type="linear",displayName="Dragon's Descent",danger=2,speed=1130,range=850,delay=0.25,radius=160,collision=false},
	["ShyvanaFireballDragon2"]={charName="Shyvana",slot=_E,type="linear",displayName="Flame Breath",danger=1,speed=1575,range=925,delay=0.333,radius=60,collision=false},
	["MegaAdhesive"]={charName="Singed",slot=_W,type="circular",displayName="Mega Adhesive",danger=2,speed=math.huge,range=1000,delay=0.25,radius=265,collision=false},
	["SionQ"]={charName="Sion",slot=_Q,type="linear",displayName="Decimating Smash",danger=2,speed=math.huge,range=600,delay=0,radius=300,collision=false},
	["SionE"]={charName="Sion",slot=_E,type="linear",displayName="Roar of the Slayer",danger=1,speed=1800,range=725,delay=0.25,radius=80,collision=false},
	["SivirQ"]={charName="Sivir",slot=_Q,type="linear",displayName="Boomerang Blade",danger=1,speed=1350,range=1250,delay=0.25,radius=90,collision=false},
	["SkarnerVirulentSlash"]={charName="Skarner",slot=_Q,type="circular",displayName="Crystal Slash",danger=2,speed=math.huge,range=0,delay=0.25,radius=350,collision=false},
	["SkarnerFracture"]={charName="Skarner",slot=_E,type="linear",displayName="Fracture",danger=1,speed=1500,range=1000,delay=0.25,radius=70,collision=false},
	["SonaR"]={charName="Sona",slot=_R,type="linear",displayName="Crescendo",danger=2,speed=2400,range=900,delay=0.25,radius=140,collision=false},
	["SorakaQ"]={charName="Soraka",slot=_Q,type="circular",displayName="Crescendo",danger=1,speed=1150,range=800,delay=0.25,radius=235,collision=false},
	["SorakaE"]={charName="Soraka",slot=_E,type="circular",displayName="Equinox",danger=1,speed=math.huge,range=925,delay=0.25,radius=300,collision=false},
	["SwainW"]={charName="Swain",slot=_W,type="circular",displayName="Vision of Empire",danger=1,speed=math.huge,range=3500,delay=0.25,radius=325,collision=false},
	["SwainE"]={charName="Swain",slot=_E,type="linear",displayName="Nevermove",danger=1,speed=935,range=850,delay=0.25,radius=85,collision=false},
	["SyndraQ"]={charName="Syndra",slot=_Q,type="circular",displayName="Dark Sphere",danger=1,speed=math.huge,range=800,delay=0.625,radius=200,collision=false},
	["SyndraWCast"]={charName="Syndra",slot=_W,type="circular",displayName="Force of Will",danger=1,speed=1450,range=950,delay=0.25,radius=225,collision=false},
	["SyndraEMissile"]={charName="Syndra",slot=_E,type="linear",displayName="Scatter the Weak",danger=2,speed=1600,range=1250,delay=0.25,radius=60,collision=false},
	["TahmKenchQ"]={charName="TahmKench",slot=_Q,type="linear",displayName="Tongue Lash",danger=1,speed=2800,range=800,delay=0.25,radius=70,collision=true},
	["TaliyahQ"]={charName="Taliyah",slot=_Q,type="linear",displayName="Threaded Volley",danger=1,speed=3600,range=1000,delay=0.25,radius=100,collision=true},
	["TaliyahWVC"]={charName="Taliyah",slot=_W,type="circular",displayName="Seismic Shove",danger=2,speed=math.huge,range=900,delay=0.6,radius=150,collision=false},
	["TalonR"]={charName="Talon",slot=_R,type="circular",displayName="Shadow Assault",danger=2,speed=math.huge,range=0,delay=0.25,radius=550,collision=false},
	["TeemoRCast"]={charName="Teemo",slot=_R,type="circular",displayName="Noxious Trap",danger=1,speed=math.huge,range=900,delay=1.25,radius=200,collision=false},
	["ThreshQ"]={charName="Thresh",slot=_Q,type="linear",displayName="Death Sentence",danger=1,speed=1900,range=1100,delay=0.5,radius=70,collision=true},
	["ThreshEFlay"]={charName="Thresh",slot=_E,type="linear",displayName="Flay",proj="ThreshEMissile1",danger=2,speed=math.huge,range=400,delay=0.389,radius=110,collision=false},
	["TristanaW"]={charName="Tristana",slot=_W,type="circular",displayName="Rocket Jump",danger=2,speed=1100,range=900,delay=0.25,radius=250,collision=false},
	["TrundleCircle"]={charName="Trundle",slot=_E,type="circular",displayName="Pillar of Ice",danger=2,speed=math.huge,range=1000,delay=0.25,radius=375,collision=false},
	["TryndamereE"]={charName="Tryndamere",slot=_E,type="linear",displayName="Spinning Slash",danger=2,speed=1300,range=660,delay=0,radius=225,collision=false},
	["WildCards"]={charName="TwistedFate",slot=_Q,type="threeway",displayName="Wild Cards",danger=1,speed=1000,range=1450,delay=0.25,radius=40,angle=28,collision=false},
	["TwitchVenomCask"]={charName="Twitch",slot=_W,type="circular",displayName="Venom Cask",danger=2,speed=1400,range=950,delay=0.25,radius=340,collision=false},
	["UrgotQ"]={charName="Urgot",slot=_Q,type="circular",displayName="Corrosive Charge",danger=1,speed=math.huge,range=800,delay=0.6,radius=215,collision=false},
	["UrgotE"]={charName="Urgot",slot=_E,type="linear",displayName="Disdain",danger=2,speed=1050,range=475,delay=0.45,radius=100,collision=false},
	["UrgotR"]={charName="Urgot",slot=_R,type="linear",displayName="Fear Beyond Death",danger=2,speed=3200,range=1600,delay=0.4,radius=80,collision=false},
	["VarusQ"]={charName="Varus",slot=_Q,type="linear",displayName="Piercing Arrow",danger=1,speed=1900,range=1625,delay=0,radius=70,collision=false},
	["VarusE"]={charName="Varus",slot=_E,type="circular",displayName="Hail of Arrows",danger=2,speed=1500,range=925,delay=0.242,radius=280,collision=false},
	["VarusR"]={charName="Varus",slot=_R,type="linear",displayName="Chain of Corruption",danger=2,speed=1950,range=1075,delay=0.242,radius=120,collision=false},
	["VeigarBalefulStrike"]={charName="Veigar",slot=_Q,type="linear",displayName="Baleful Strike",danger=1,speed=2200,range=950,delay=0.25,radius=70,collision=true},
	["VeigarDarkMatter"]={charName="Veigar",slot=_W,type="circular",displayName="Dark Matter",danger=1,speed=math.huge,range=900,delay=1.25,radius=225,collision=false},
	["VeigarEventHorizon"]={charName="Veigar",slot=_E,type="annular",displayName="Event Horizon",danger=2,speed=math.huge,range=700,delay=0.75,radius=375,collision=false},
	["VelKozQ"]={charName="VelKoz",slot=_Q,type="linear",displayName="Plasma Fission",danger=1,speed=1300,range=1050,delay=0.251,radius=50,collision=true},
	["VelkozQMissileSplit"]={charName="VelKoz",slot=_Q,type="linear",displayName="Plasma Fission",proj="VelkozQMissileSplit",danger=1,speed=2100,range=1050,delay=0.251,radius=45,collision=true},
	["VelKozW"]={charName="VelKoz",slot=_W,type="linear",displayName="Void Rift",danger=1,speed=1700,range=1050,delay=0.25,radius=87.5,collision=false},
	["VelKozE"]={charName="VelKoz",slot=_E,type="circular",displayName="Tectonic Disruption",danger=2,speed=math.huge,range=850,delay=0.75,radius=235,collision=false},
	["ViQ"]={charName="Vi",slot=_Q,type="linear",displayName="Vault Breaker",danger=2,speed=1500,range=725,delay=0,radius=90,collision=false},
	["ViktorGravitonField"]={charName="Viktor",slot=_W,type="circular",displayName="Gravity Field",danger=1,speed=math.huge,range=700,delay=1.333,radius=290,collision=false},
	["ViktorDeathRay"]={charName="Viktor",slot=_E,type="linear",displayName="Death Ray",danger=1,speed=1050,range=1025,delay=0,radius=80,collision=false},
	["VladimirHemoplague"]={charName="Vladimir",slot=_R,type="circular",displayName="Hemoplague",danger=3,speed=math.huge,range=700,delay=0.389,radius=350,collision=true},
	["WarwickR"]={charName="Warwick",slot=_R,type="linear",displayName="Infinite Duress",danger=2,speed=1800,range=3000,delay=0.1,radius=45,collision=false},
	["XayahQ"]={charName="Xayah",slot=_Q,type="linear",displayName="Double Daggers",danger=1,speed=2075,range=1100,delay=0.5,radius=45,collision=false},
	["XerathArcanopulse2"]={charName="Xerath",slot=_Q,type="linear",displayName="Arcanopulse",danger=1,speed=math.huge,range=1400,delay=0.5,radius=90,collision=false},
	["XerathArcaneBarrage2"]={charName="Xerath",slot=_W,type="circular",displayName="Eye of Destruction",danger=2,speed=math.huge,range=1100,delay=0.7,radius=235,collision=false},
	["XerathMageSpear"]={charName="Xerath",slot=_E,type="linear",displayName="Shocking Orb",danger=1,speed=1350,range=1050,delay=0.2,radius=60,collision=true},
	["XerathRMissileWrapper"]={charName="Xerath",slot=_R,type="circular",displayName="Rite of the Arcane",danger=2,speed=math.huge,range=6160,delay=0.7,radius=200,collision=false},
	["XinZhaoW"]={charName="XinZhao",slot=_W,type="linear",displayName="Wind Becomes Lightning",danger=2,speed=math.huge,range=900,delay=0.5,radius=45,collision=false},
	["XinZhaoR"]={charName="XinZhao",slot=_R,type="circular",displayName="Crescent Guard",danger=2,speed=math.huge,range=0,delay=0.325,radius=550,collision=false},
	["YasuoQW"]={charName="Yasuo",slot=_Q,type="linear",displayName="Steel Tempest",danger=1,speed=math.huge,range=475,delay=0.339,radius=40,collision=false},
	["YasuoQ2W"]={charName="Yasuo",slot=_Q,type="linear",displayName="Steel Wind Rising",danger=1,speed=math.huge,range=475,delay=0.339,radius=40,collision=false},
	["YasuoQ3W"]={charName="Yasuo",slot=_Q,type="linear",displayName="Gathering Storm",danger=1,speed=1200,range=1000,delay=0.339,radius=90,collision=false},
	["YorickW"]={charName="Yorick",slot=_W,type="annular",displayName="Dark Procession",danger=2,speed=math.huge,range=600,delay=0.25,radius=300,collision=false},
	["ZacQ"]={charName="Zac",slot=_Q,type="linear",displayName="Stretching Strikes",danger=1,speed=2800,range=800,delay=0.33,radius=80,collision=true},
	["ZacW"]={charName="Zac",slot=_W,type="circular",displayName="Unstable Matter",danger=2,speed=math.huge,range=0,delay=0.25,radius=350,collision=false},
	["ZacE"]={charName="Zac",slot=_E,type="circular",displayName="Elastic Slingshot",danger=2,speed=1330,range=1800,delay=0,radius=300,collision=false},
	["ZacR"]={charName="Zac",slot=_R,type="circular",displayName="Let's Bounce!",danger=3,speed=math.huge,range=1000,delay=0,radius=300,collision=false},
	["ZedQ"]={charName="Zed",slot=_Q,type="linear",displayName="Razor Shuriken",danger=1,speed=1700,range=900,delay=0.25,radius=50,collision=false},
	["ZedW"]={charName="Zed",slot=_W,type="linear",displayName="Living Shadow",danger=2,speed=1750,range=650,delay=0.25,radius=60,collision=false},
	["ZedE"]={charName="Zed",slot=_E,type="circular",displayName="Shadow Slash",danger=2,speed=math.huge,range=0,delay=0.25,radius=290,collision=false},
	["ZiggsQ"]={charName="Ziggs",slot=_Q,type="circular",displayName="Bouncing Bomb",danger=1,speed=3000,range=1400,delay=0.25,radius=130,collision=false},
	["ZiggsW"]={charName="Ziggs",slot=_W,type="circular",displayName="Satchel Charge",danger=1,speed=2000,range=1000,delay=0.25,radius=280,collision=false},
	["ZiggsE"]={charName="Ziggs",slot=_E,type="circular",displayName="Hexplosive Minefield",danger=2,speed=1800,range=900,delay=0.25,radius=250,collision=false},
	["ZiggsR"]={charName="Ziggs",slot=_R,type="circular",displayName="Mega Inferno Bomb",danger=3,speed=1600,range=5300,delay=0.375,radius=550,collision=false},
	["ZileanQ"]={charName="Zilean",slot=_Q,type="circular",displayName="Time Bomb",danger=2,speed=math.huge,range=900,delay=0.8,radius=180,collision=false},
	["ZileanQAttachAudio"]={charName="Zilean",slot=_Q,type="circular",displayName="Time Bomb",danger=2,speed=math.huge,range=900,delay=0.8,radius=180,collision=false},
	["ZoeQ"]={charName="Zoe",slot=_Q,type="linear",displayName="Paddle Star",danger=1,speed=1200,range=800,delay=0.25,radius=50,collision=true},
	["ZoeQRecast"]={charName="Zoe",slot=_Q,type="linear",displayName="Paddle Star",danger=1,speed=2500,range=1600,delay=0,radius=70,collision=true},
	["ZoeE"]={charName="Zoe",slot=_E,type="linear",displayName="Sleepy Trouble Bubble",danger=2,speed=1700,range=800,delay=0.3,radius=50,collision=true},
	["ZyraE"]={charName="Zyra",slot=_E,type="linear",displayName="Grasping Roots",danger=1,speed=1150,range=1100,delay=0.25,radius=70,collision=false},
	["ZyraR"]={charName="Zyra",slot=_R,type="circular",displayName="Stranglethorns",danger=3,speed=math.huge,range=700,delay=1.775,radius=575,collision=false},
}
end

function JustEvade:Dodge()
	if myHero.isDead then return end
	if self.JustEvade and self.SafePos ~= nil then
		if GetDistance(self.SafePos,myHero.position) > myHero.boundingRadius and self.Timer+EMenu.Misc.TE:get() > RiotClock.time then
			if EMenu.Misc.DD:get() and self.DangerLvL <= 2 or EMenu.Misc.SD:get() then return end
			MoveToVec(self.SafePos:ToDX3())
			return
		else
			DelayAction(function()
				self.JustEvade = false
			end, EMenu.Misc.DE:get())
		end
	end
	for _,spell in pairs(self.DetSpells) do
		if EMenu.Main.Evade:get() and EMenu.Main.Dodge:get() and EMenu.Spells[spell.name]["Dodge"..spell.name]:get() then
			local speed = self.Spells[spell.name].speed
			local range = self.Spells[spell.name].range
			local delay = self.Spells[spell.name].delay
			local radius = self.Spells[spell.name].radius
			local type = self.Spells[spell.name].type
			local danger = self.Spells[spell.name].danger
			local collision = self.Spells[spell.name].collision
			local b = myHero.boundingRadius
			if type == "linear" then
				if speed and speed ~= math.huge then
					if spell.startTime+range/speed+delay+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						local p = spell.startPos+Vector(Vector(spell.endPos)-spell.startPos):Normalized()*(speed*(RiotClock.time-delay-spell.startTime)-radius)
						local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(Vector(p),spell.endPos,Vector(myHero.position))
						local BPos = Vector(pointSegment.x, myHero.position, pointSegment.y)
                        if BPos and GetDistance(myHero.position, BPos) < (radius+b+EMenu.Misc.ER:get()+10) then
							self.JustEvade = true
							if self.ReCalc then
								self.SafePos = self:Pathfinding(spell.startPos,spell.endPos,radius,radius2,b,BPos,type)
								if not EMenu.Main.RP:get() then
									self.ReCalc = false
								end
							end
							self.Timer = spell.startTime+range/speed+delay+self:AdditionalTime(spell.source, spell.slot)
							self.DangerLvl = danger
						end
					else
						TableRemove(self.DetSpells, _)
					end
				elseif speed and speed == math.huge then
					if spell.startTime+delay+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						if GetDistance(myHero.position,spell.endPos) < radius+b+EMenu.Misc.ER:get() then
							self.JustEvade = true
							if self.ReCalc then
								self.SafePos = self:Pathfinding(spell.startPos,spell.endPos,radius,radius2,b,BPos,type)
								if not EMenu.Main.RP:get() then
									self.ReCalc = false
								end
							end
							self.Timer = spell.startTime+delay+self:AdditionalTime(spell.source, spell.slot)
							self.DangerLvl = danger
						end
					else
						TableRemove(self.DetSpells, _)
					end
				end
			end
			if type == "circular" then
				if speed and speed ~= math.huge then
					if spell.startTime+range/speed+delay+0.5+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						if GetDistance(myHero.position,spell.endPos) < (radius+b+EMenu.Misc.ER:get()) then
							self.JustEvade = true
							if self.ReCalc then
								self.SafePos = self:Pathfinding(spell.startPos,spell.endPos,radius,radius2,b,BPos,type)
								if not EMenu.Main.RP:get() then
									self.ReCalc = false
								end
							end
							self.Timer = spell.startTime+range/speed+delay+self:AdditionalTime(spell.source, spell.slot)
							self.DangerLvl = danger
						end
					else
						TableRemove(self.DetSpells, _)
					end
				elseif speed and speed == math.huge then
					if spell.startTime+delay+0.5+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						if GetDistance(myHero.position,spell.endPos) < (radius+b+EMenu.Misc.ER:get()) then
							self.JustEvade = true
							if self.ReCalc then
								self.SafePos = self:Pathfinding(spell.startPos,spell.endPos,radius,radius2,b,BPos,type)
								if not EMenu.Main.RP:get() then
									self.ReCalc = false
								end
							end
							self.Timer = spell.startTime+delay+self:AdditionalTime(spell.source, spell.slot)
							self.DangerLvl = danger
						end
					else
						TableRemove(self.DetSpells, _)
					end
				end
			end
		end
	end
end

function JustEvade:Pathfinding(startPos, endPos, radius, radius2, boundingRadius, bPos, type)
	if myHero.isDead then return end
	if EMenu.Main.Pathfinding:get() == 1 then
		local Pos1 = myHero.position+Vector(Vector(myHero.position)-endPos):Normalized():Perpendicular()*(radius+boundingRadius+EMenu.Misc.ER:get()+10)
		local Pos2 = myHero.position+Vector(Vector(myHero.position)-endPos):Normalized():Perpendicular2()*(radius+boundingRadius+EMenu.Misc.ER:get()+10)
		if GetDistance(Pos1, startPos) < GetDistance(Pos2, startPos) then
			return Pos1
		else
			return Pos2
		end
	elseif EMenu.Main.Pathfinding:get() == 2 then
		local MPos = Vector(myHero.position)+Vector(Vector(GetMousePos())-myHero.position):Normalized()*radius
		if type == "linear" then
			local Pos1 = Vector(MPos)+Vector(Vector(MPos)-endPos):Normalized():Perpendicular()*(radius+boundingRadius+EMenu.Misc.ER:get())
			local Pos2 = Vector(MPos)+Vector(Vector(MPos)-endPos):Normalized():Perpendicular2()*(radius+boundingRadius+EMenu.Misc.ER:get())
			if GetDistance(Vector(MPos)+Vector(Vector(MPos)-endPos):Normalized():Perpendicular2(),bPos) > GetDistance(Vector(MPos)+Vector(Vector(MPos)-endPos):Normalized():Perpendicular(),bPos) then
				return Pos2
			else
				return Pos1
			end
		elseif type == "circular" then
			local Pos1 = Vector(endPos)+(myHero.position-Vector(endPos)):Normalized()*(radius+boundingRadius+EMenu.Misc.ER:get())
			local Pos2 = Vector(endPos)+(Vector(MPos)-Vector(endPos)):Normalized()*(radius+boundingRadius+EMenu.Misc.ER:get())
			if MPos and GetDistance(MPos, Path1) > GetDistance(MPos, Path2) then
				return Pos2
			else
				return Pos1
			end
		end
	elseif EMenu.Main.Pathfinding:get() == 3 then
		if type == "linear" then
			local DPos = Vector(VectorIntersection(startPos,endPos,myHero.position+(Vector(startPos)-Vector(endPos)):Perpendicular(),myHero.position).x,endPos.y,VectorIntersection(startPos,endPos,myHero.position+(Vector(startPos)-Vector(endPos)):Perpendicular(),myHero.position).y)
			if GetDistance(myHero.position+Vector(startPos-endPos):Perpendicular(),DPos) >= GetDistance(myHero.position+Vector(startPos-endPos):Perpendicular2(),DPos) then
				local Pos1 = DPos+Vector(startPos-endPos):Perpendicular():Normalized()*(radius+boundingRadius+EMenu.Misc.ER:get())
				return Pos1
			else
				local Pos2 = DPos+Vector(startPos-endPos):Perpendicular2():Normalized()*(radius+boundingRadius+EMenu.Misc.ER:get())
				return Pos2
			end
		elseif type == "circular" then
			local Pos = Vector(endPos)+(myHero.position-Vector(endPos)):Normalized()*(radius+boundingRadius+EMenu.Misc.ER:get())
			return Pos
		end
	end
end

function JustEvade:Draw()
	if self.JustEvade and self.SafePos and EMenu.Main.SafePos:get() then
		DrawHandler:Circle3D(self.SafePos:ToDX3(),myHero.boundingRadius,0xFFFFFFFF)
	end
	for _,spell in pairs(self.DetSpells) do
		if EMenu.Main.Evade:get() and EMenu.Main.Draw:get() and EMenu.Spells[spell.name]["Draw"..spell.name]:get() then
			local speed = self.Spells[spell.name].speed
			local range = self.Spells[spell.name].range
			local delay = self.Spells[spell.name].delay
			local radius = self.Spells[spell.name].radius
			local type = self.Spells[spell.name].type
			local collision = self.Spells[spell.name].collision
			if type == "linear" then
				if speed ~= math.huge then
					if spell.startTime+range/speed+delay+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						local pos = spell.startPos+Vector(Vector(spell.endPos)-spell.startPos):Normalized()*(speed*(RiotClock.time-delay-spell.startTime)-radius)
						self:DrawRectangleOutline(spell.startPos, spell.endPos, (spell.startTime+delay < RiotClock.time and pos or nil), radius)
					else
						TableRemove(self.DetSpells, _)
					end
				elseif speed == math.huge then
					if spell.startTime+delay+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						self:DrawRectangleOutline(spell.startPos, spell.endPos, nil, radius)
					else
						TableRemove(self.DetSpells, _)
					end
				end
			end
			if type == "circular" then
				if speed ~= math.huge then
					if spell.startTime+range/speed+delay+0.5+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						DrawHandler:Circle3D(spell.endPos:ToDX3(),radius,0xFFFFFFFF)
						DrawHandler:Circle3D(spell.endPos:ToDX3(),radius+EMenu.Misc.ER:get(),0xFFFFFFFF)
					else
						TableRemove(self.DetSpells, _)
					end
				elseif speed == math.huge then
					if spell.startTime+delay+0.5+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
						DrawHandler:Circle3D(spell.endPos:ToDX3(),radius,0xFFFFFFFF)
						DrawHandler:Circle3D(spell.endPos:ToDX3(),radius+EMenu.Misc.ER:get(),0xFFFFFFFF)
					else
						TableRemove(self.DetSpells, _)
					end
				end
			end
			if type == "annular" then
				if spell.startTime+delay+self:AdditionalTime(spell.source, spell.slot) > RiotClock.time then
					DrawHandler:Circle3D(spell.endPos:ToDX3(),radius,0xFFFFFFFF)
					DrawHandler:Circle3D(spell.endPos:ToDX3(),radius/1.5,0xFFFFFFFF)
				else
					TableRemove(self.DetSpells, _)
				end
			end
		end
	end
end

function GetLine(line, radius)
	local x1, y1, x2, y2 = line.startPos.x, line.startPos.y, line.endPos.x, line.endPos.y
	local L = math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
	local resultLine = {}
	x = x1 + radius * (y2 - y1) / L
	y = y1 + radius * (x1 - x2) / L
	resultLine.startPos = D3DXVECTOR2(x, y)
	x = x2 + radius * (y2 - y1) / L
	y = y2 + radius * (x1 - x2) / L
	resultLine.endPos = D3DXVECTOR2(x, y)
	return resultLine
end

function JustEvade:DrawRectangleOutline(startPos, endPos, pos, radius)
	local RLine = {}
	RLine.startPos = Renderer:WorldToScreen(D3DXVECTOR3(startPos.x, 0, startPos.z))
	RLine.endPos = Renderer:WorldToScreen(D3DXVECTOR3(endPos.x, 0, endPos.z))
	local z1 = GetLine(RLine, radius/2)
	local z2 = GetLine(RLine, -radius/2)
	DrawHandler:Line(z1.startPos, z1.endPos, 0xFFFFFFFF)
	DrawHandler:Line(z2.startPos, z2.endPos, 0xFFFFFFFF)
	DrawHandler:Line(z1.endPos, z2.endPos, 0xFFFFFFFF)
	DrawHandler:Line(z1.startPos, z2.startPos, 0xFFFFFFFF)
	if EMenu.Misc.ER:get() > 0 then
		local z3 = GetLine(RLine, (radius+EMenu.Misc.ER:get())/2)
		local z4 = GetLine(RLine, -(radius+EMenu.Misc.ER:get())/2)
		DrawHandler:Line(z3.startPos, z3.endPos, 0xFFFFFFFF)
		DrawHandler:Line(z4.startPos, z4.endPos, 0xFFFFFFFF)
		DrawHandler:Line(z3.endPos, z4.endPos, 0xFFFFFFFF)
		DrawHandler:Line(z3.startPos, z4.startPos, 0xFFFFFFFF)
	end
	if pos then
		DrawHandler:Circle3D(pos:ToDX3(),radius,0xFFFFFFFF)
	end
end

function JustEvade:AdditionalTime(unit, spell)
	if unit.charName == "Caitlyn" and spell == 1 then return 1 end
	if unit.charName == "Gangplank" and spell == 3 then return 2 end
	if unit.charName == "Gragas" and spell == 0 then return 1 end
	if unit.charName == "Graves" and spell == 0 then return 1 end
	if unit.charName == "Irelia" and spell == 3 then return 1 end
	if unit.charName == "Jhin" and spell == 2 then return 1 end
	if unit.charName == "Jinx" and spell == 2 then return 1 end
	if unit.charName == "Katarina" and spell == 3 then return 2.5 end
	if unit.charName == "MissFortune" and spell == 3 then return 3 end
	if unit.charName == "Morgana" and spell == 1 then return 1 end
	if unit.charName == "Nasus" and spell == 2 then return 1 end
	if unit.charName == "Nidalee" and spell == 1 then return 1 end
	if unit.charName == "Nunu" and spell == 3 then return 3 end
	if unit.charName == "Pantheon" and spell == 3 then return 2.5 end
	if unit.charName == "Rakan" and spell == 1 then return 1 end
	if unit.charName == "Singed" and spell == 1 then return 1 end
	if unit.charName == "Sion" and spell == 0 then return 2 end
	if unit.charName == "Soraka" and spell == 2 then return 1 end
	if unit.charName == "Swain" and spell == 1 then return 1.5 end
	if unit.charName == "Teemo" and spell == 3 then return 1 end
	if unit.charName == "Veigar" and spell == 2 then return 3.5 end
	if unit.charName == "Zac" and spell == 3 then return 2.5 end
	if unit.charName == "Ziggs" and spell == 1 then return 1 end
	if unit.charName == "Ziggs" and spell == 2 then return 1 end
	if unit.charName == "Zilean" and spell == 0 then return 1 end
	return 0
end

function JustEvade:OnProcessSpell(unit, spell)
	if spell and unit ~= myHero then
		if self.Spells[spell.spellData.name] then
			self.ReCalc = true
			local SpellDet = self.Spells[spell.spellData.name]
			local SType = SpellDet.type
			local SRange = SpellDet.range
			local startPos = Vector(spell.startPos)
			local placementPos = Vector(spell.endPos)
			if SType == "linear" then
				local endPos = startPos-(startPos-placementPos):Normalized()*SRange
				s = {slot = SpellDet.slot, source = unit, startTime = RiotClock.time, startPos = startPos, endPos = endPos, name = spell.spellData.name}
				TableInsert(self.DetSpells, s)
			elseif SType == "circular" or SType == "annular" then
				if SRange > 0 then
					if GetDistance(unit.position, spell.endPos) > SRange then
						local endPos = startPos-(startPos-placementPos):Normalized()*SRange
						s = {slot = SpellDet.slot, source = unit, startTime = RiotClock.time, startPos = startPos, endPos = endPos, name = spell.spellData.name}
						TableInsert(self.DetSpells, s)
					else
						local endPos = placementPos
						s = {slot = SpellDet.slot, source = unit, startTime = RiotClock.time, startPos = startPos, endPos = endPos, name = spell.spellData.name}
						TableInsert(self.DetSpells, s)
					end
				else
					local endPos = unit.position
					s = {slot = SpellDet.slot, source = unit, startTime = RiotClock.time, startPos = startPos, endPos = endPos, name = spell.spellData.name}
					TableInsert(self.DetSpells, s)
				end
			end
		end
	end
end
