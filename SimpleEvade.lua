
Callback.Add("Load", function()
	SEMenu = Menu("SimpleEvade", "SimpleEvade")
	SimpleEvade()
	require 'MapPositionGOS'
end)

class 'SimpleEvade'

function SimpleEvade:__init()
	self.GlobalUlts = {["EzrealTrueshotBarrage"]={s=true},["EnchantedCrystalArrow"]={s=true},["DravenRCast"]={s=true},["JinxR"]={s=true},["GangplankR"]={s=true}}
	self.EndPosition = nil
	self.Object1 = {}
	self.ASD = false
	self.MPosition = nil
	self.MPosition2 = nil
	self.MPosition3 = nil
	self.MPosition4 = nil
	self.MV = nil
	self.OPosition = nil
	self.PathA = nil
	self.PathA2 = nil
	self.PathB = nil
	self.PathB2 = nil
	self.PathC = nil
	self.PathC2 = nil
	self.PathD = nil
	self.PathD2 = nil
	self.SpSlot = {[_Q]="Q",[_W]="W",[_E]="E",[_R]="R"}
	self.YasuoWall = {}
	SEMenu:Boolean("Print", "Print Names", false)
	SEMenu:SubMenu("Spells", "Spell Settings")
	DelayAction(function()
		for _,i in pairs(self.Spells) do
			for l,k in pairs(GetEnemyHeroes()) do
				if not self.Spells[_] then return end
				if i.charName == k.charName then
					if not SEMenu.Spells[_] then SEMenu.Spells:Menu(_,""..i.charName.." "..self.SpSlot[i.slot].." | "..i.displayName) end
						SEMenu.Spells[_]:Boolean("Dodge".._, "Dodge Spell", true)
						SEMenu.Spells[_]:Boolean("Draw".._, "Draw Spell", true)
				end
			end
		end
	end,.1)
	Callback.Add("Tick", function() self:TickP() end)
	Callback.Add("ProcessSpell", function(unit, spellProc) self:Detection(unit,spellProc) end)
	Callback.Add("CreateObj", function(obj) self:CreateObject(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteObject(obj) end)
	Callback.Add("Draw", function() self:DrawP() end)
	Callback.Add("ProcessWaypoint", function(unit,wp) self:PrWp(unit,wp) end)
	Callback.Add("WndMsg", function(s1,s2) self:WndMsg(s1,s2) end)
	Callback.Add("IssueOrder", function(order) self:BlockMov(order) end)

self.Spells = {
	["AatroxQ"]={charName="Aatrox",slot=_Q,type="circular",displayName="Dark Flight",killTime=0,speed=450,range=650,delay=0.25,radius=275,hitbox=true,aoe=true,cc=true,mcollision=false},
	["AatroxE"]={charName="Aatrox",slot=_E,type="linear",displayName="Blades of Torment",killTime=0,speed=1200,range=1000,delay=0.25,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["AhriOrbofDeception"]={charName="Ahri",slot=_Q,type="linear",displayName="Orb of Deception",killTime=0,speed=1700,range=880,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["AhriSeduce"]={charName="Ahri",slot=_E,type="linear",displayName="Charm",killTime=0,speed=1600,range=975,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["Pulverize"]={charName="Alistar",slot=_Q,type="circular",displayName="Pulverize",killTime=0,speed=math.huge,range=0,delay=0.25,radius=365,hitbox=true,aoe=true,cc=true,mcollision=false},
	["BandageToss"]={charName="Amumu",slot=_Q,type="linear",displayName="Bandage Toss",killTime=0,speed=2000,range=1100,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=true},
	["Tantrum"]={charName="Amumu",slot=_E,type="circular",displayName="Tantrum",killTime=0,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["CurseoftheSadMummy"]={charName="Amumu",slot=_R,type="circular",displayName="Curse of the Sad Mummy",killTime=0,speed=math.huge,range=0,delay=0.25,radius=550,hitbox=false,aoe=true,cc=true,mcollision=false},
	["FlashFrost"]={charName="Anivia",slot=_Q,type="linear",displayName="Flash Frost",killTime=0,speed=850,range=1075,delay=0.25,radius=225,hitbox=true,aoe=true,cc=true,mcollision=false},
	["Incinerate"]={charName="Annie",slot=_W,type="conic",displayName="Incinerate",killTime=0,speed=math.huge,range=600,delay=0.25,radius=50,angle=50,hitbox=false,aoe=true,cc=false,mcollision=false},
	["InfernalGuardian"]={charName="Annie",slot=_R,type="circular",displayName="Summon Tibbers",killTime=0,speed=math.huge,range=600,delay=0.25,radius=290,hitbox=true,aoe=true,cc=false,mcollision=false},
	["Volley"]={charName="Ashe",slot=_W,type="conic",displayName="Volley",killTime=0,speed=2000,range=1200,delay=0.25,radius=20,angle=57.5,hitbox=true,aoe=true,cc=true,mcollision=true},
	["EnchantedCrystalArrow"]={charName="Ashe",slot=_R,type="linear",displayName="Enchanted Crystal Arrow",killTime=0,speed=1600,range=25000,delay=0.25,radius=125,hitbox=true,aoe=false,cc=true,mcollision=false},
	["AurelionSolQ"]={charName="AurelionSol",slot=_Q,type="linear",displayName="Starsurge",killTime=0,speed=600,range=1075,delay=0.25,radius=210,hitbox=true,aoe=true,cc=true,mcollision=false},
	["AurelionSolE"]={charName="AurelionSol",slot=_E,type="linear",displayName="Comet of Legend",killTime=0,speed=600,range=7000,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["AurelionSolR"]={charName="AurelionSol",slot=_R,type="linear",displayName="Voice of Light",killTime=0,speed=4285,range=1500,delay=0.35,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["BardQ"]={charName="Bard",slot=_Q,type="linear",displayName="Cosmic Binding",killTime=0,speed=1500,range=950,delay=0.25,radius=80,hitbox=true,aoe=true,cc=true,mcollision=true},
	["BardR"]={charName="Bard",slot=_R,type="circular",displayName="Tempered Fate",killTime=0,speed=2100,range=3400,delay=0.5,radius=350,hitbox=true,aoe=true,cc=true,mcollision=false},
	["RocketGrab"]={charName="Blitzcrank",slot=_Q,type="linear",displayName="Rocket Grab",killTime=0,speed=1750,range=925,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=true},
	["StaticField"]={charName="Blitzcrank",slot=_R,type="circular",displayName="Static Field",killTime=0,speed=math.huge,range=0,delay=0.25,radius=600,hitbox=false,aoe=true,cc=true,mcollision=false},
	["BrandQ"]={charName="Brand",slot=_Q,type="linear",displayName="Sear",killTime=0,speed=1550,range=1050,delay=0.25,radius=65,hitbox=true,aoe=false,cc=true,mcollision=true},
	["BrandW"]={charName="Brand",slot=_W,type="circular",displayName="Pillar of Flame",killTime=0,speed=math.huge,range=900,delay=0.625,radius=250,hitbox=true,aoe=true,cc=false,mcollision=false},
	["BraumQ"]={charName="Braum",slot=_Q,type="linear",displayName="Winter's Bite",killTime=0,speed=1670,range=1000,delay=0.25,radius=60,hitbox=true,aoe=true,cc=true,mcollision=true},
	["BraumRWrapper"]={charName="Braum",slot=_Q,type="linear",displayName="Glacial Fissure",killTime=0,speed=1400,range=1250,delay=0.5,radius=115,hitbox=true,aoe=true,cc=true,mcollision=false},
	["CaitlynPiltoverPeacemaker"]={charName="Caitlyn",slot=_Q,type="linear",displayName="Piltover Peacemaker",killTime=0,speed=2200,range=1250,delay=0.625,radius=90,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CaitlynYordleTrap"]={charName="Caitlyn",slot=_W,type="circular",displayName="Yordle Snap Trap",killTime=1,speed=math.huge,range=800,delay=0.25,radius=75,hitbox=true,aoe=false,cc=true,mcollision=false},
	["CaitlynEntrapmentMissile"]={charName="Caitlyn",slot=_E,type="linear",displayName="90 Caliber Net",killTime=0,speed=1500,range=750,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["CamilleW"]={charName="Camille",slot=_W,type="conic",displayName="Tactical Sweep",killTime=0,speed=math.huge,range=610,delay=0.75,radius=80,angle=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["CamilleE"]={charName="Camille",slot=_E,type="linear",displayName="Hookshot",killTime=0,speed=1350,range=800,delay=0.25,radius=45,hitbox=true,aoe=false,cc=true,mcollision=false},
	["CassiopeiaQ"]={charName="Cassiopeia",slot=_Q,type="circular",displayName="Noxious Blast",killTime=0,speed=math.huge,range=850,delay=0.4,radius=150,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CassiopeiaR"]={charName="Cassiopeia",slot=_R,type="conic",displayName="Petrifying Gaze",killTime=0,speed=math.huge,range=825,delay=0.5,radius=80,angle=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["Rupture"]={charName="Chogath",slot=_Q,type="circular",displayName="Rupture",killTime=0,speed=math.huge,range=950,delay=0.5,radius=350,hitbox=true,aoe=true,cc=true,mcollision=false},
	["FeralScream"]={charName="Chogath",slot=_W,type="conic",displayName="Feral Scream",killTime=0,speed=math.huge,range=650,delay=0.5,radius=60,angle=60,hitbox=false,aoe=true,cc=true,mcollision=false},
	["PhosphorusBomb"]={charName="Corki",slot=_Q,type="circular",displayName="Phosphorus Bomb",killTime=0,speed=1000,range=825,delay=0.25,radius=250,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CarpetBomb"]={charName="Corki",slot=_W,type="linear",displayName="Valkyrie",killTime=0,speed=650,range=600,delay=0,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CarpetBombMega"]={charName="Corki",slot=_W,type="linear",displayName="Special Delivery",killTime=0,speed=1500,range=1800,delay=0,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["MissileBarrageMissile"]={charName="Corki",slot=_R,type="linear",displayName="Missile Barrage",killTime=0,speed=1950,range=1225,delay=0.175,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["MissileBarrageMissile2"]={charName="Corki",slot=_R,type="linear",displayName="Missile Barrage",killTime=0,speed=1950,range=1225,delay=0.175,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["DariusAxeGrabCone"]={charName="Darius",slot=_E,type="conic",displayName="Apprehend",killTime=0,speed=math.huge,range=535,delay=0.25,radius=50,angle=50,hitbox=false,aoe=true,cc=true,mcollision=false},
	["DianaArc"]={charName="Diana",slot=_Q,type="circular",displayName="Crescent Strike",killTime=0,speed=1400,range=900,delay=0.25,radius=205,hitbox=true,aoe=true,cc=false,mcollision=false},
	["InfectedCleaverMissileCast"]={charName="DrMundo",slot=_Q,type="linear",displayName="Infected Cleaver",killTime=0,speed=1850,range=975,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["DravenDoubleShot"]={charName="Draven",slot=_E,type="linear",displayName="Stand Aside",killTime=0,speed=1400,range=1050,delay=0.25,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["DravenRCast"]={charName="Draven",slot=_R,type="linear",displayName="Whirling Death",killTime=0,speed=2000,range=25000,delay=0.5,radius=130,hitbox=true,aoe=true,cc=false,mcollision=false},
	["EkkoQ"]={charName="Ekko",slot=_Q,type="linear",displayName="Timewinder",killTime=0,speed=1650,range=1075,delay=0.25,radius=135,hitbox=true,aoe=true,cc=true,mcollision=false},
	["EkkoW"]={charName="Ekko",slot=_W,type="circular",displayName="Parallel Convergence",killTime=0,speed=1650,range=1600,delay=3.75,radius=400,hitbox=true,aoe=true,cc=true,mcollision=false},
	["EkkoR"]={charName="Ekko",slot=_R,type="circular",displayName="Chronobreak",killTime=0,speed=1650,range=1600,delay=0.25,radius=375,hitbox=false,aoe=true,cc=false,mcollision=false},
	["EliseHumanE"]={charName="Elise",slot=_E,type="linear",displayName="Cocoon",killTime=0,speed=1600,range=1075,delay=0.25,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["EvelynnQ"]={charName="Evelynn",slot=_Q,type="linear",displayName="Hate Spike",killTime=0,speed=2200,range=800,delay=0.25,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["EvelynnR"]={charName="Evelynn",slot=_R,type="conic",displayName="Last Caress",killTime=0,speed=math.huge,range=450,delay=0.35,radius=180,angle=180,hitbox=false,aoe=true,cc=false,mcollision=false},
	["EzrealMysticShot"]={charName="Ezreal",slot=_Q,type="linear",displayName="Mystic Shot",killTime=0,speed=2000,range=1150,delay=0.25,radius=80,hitbox=true,aoe=false,cc=false,mcollision=true},
	["EzrealEssenceFlux"]={charName="Ezreal",slot=_W,type="linear",displayName="Essence Flux",killTime=0,speed=1550,range=1000,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["EzrealTrueshotBarrage"]={charName="Ezreal",slot=_R,type="linear",displayName="Trueshot Barrage",killTime=0,speed=2000,range=25000,delay=1,radius=160,hitbox=true,aoe=true,cc=false,mcollision=false},
	["FioraW"]={charName="Fiora",slot=_W,type="linear",displayName="Riposte",killTime=0,speed=math.huge,range=750,delay=0.75,radius=85,hitbox=true,aoe=true,cc=true,mcollision=false},
	["FizzR"]={charName="Fizz",slot=_R,type="linear",displayName="Chum the Waters",killTime=0,speed=1300,range=1300,delay=0.25,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GalioQ"]={charName="Galio",slot=_Q,type="circular",displayName="Winds of War",killTime=0,speed=1150,range=825,delay=0.25,radius=150,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GalioE"]={charName="Galio",slot=_E,type="linear",displayName="Justice Punch",killTime=0,speed=1400,range=650,delay=0.45,radius=160,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GalioR"]={charName="Galio",slot=_R,type="circular",displayName="Hero's Entrance",killTime=0,speed=math.huge,range=5500,delay=2.75,radius=500,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GangplankR"]={charName="Gangplank",slot=_R,type="circular",displayName="Cannon Barrage",killTime=2,speed=math.huge,range=25000,delay=0.25,radius=600,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarQ"]={charName="Gnar",slot=_Q,type="linear",displayName="Boomerang Throw",killTime=0,speed=1700,range=1100,delay=0.25,radius=55,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarE"]={charName="Gnar",slot=_E,type="circular",displayName="Hop",killTime=0,speed=900,range=475,delay=0.25,radius=160,hitbox=true,aoe=false,cc=true,mcollision=false},
	["GnarBigQ"]={charName="Gnar",slot=_Q,type="linear",displayName="Boulder Toss",killTime=0,speed=2100,range=1100,delay=0.5,radius=90,hitbox=true,aoe=true,cc=true,mcollision=true},
	["GnarBigW"]={charName="Gnar",slot=_W,type="linear",displayName="Wallop",killTime=0,speed=math.huge,range=550,delay=0.6,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarBigE"]={charName="Gnar",slot=_E,type="circular",displayName="Crunch",killTime=0,speed=800,range=600,delay=0.25,radius=375,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarR"]={charName="Gnar",slot=_R,type="circular",displayName="GNAR!",killTime=0,speed=math.huge,range=0,delay=0.25,radius=475,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GragasQ"]={charName="Gragas",slot=_Q,type="circular",displayName="Barrel Roll",killTime=1,speed=1000,range=850,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GragasE"]={charName="Gragas",slot=_E,type="linear",displayName="Body Slam",killTime=0,speed=900,range=600,delay=0.25,radius=170,hitbox=true,aoe=true,cc=true,mcollision=true},
	["GragasR"]={charName="Gragas",slot=_R,type="circular",displayName="Explosive Cask",killTime=0,speed=1800,range=1000,delay=0.25,radius=400,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GravesQLineSpell"]={charName="Graves",slot=_Q,type="linear",displayName="End of the Line",killTime=0,speed=3700,range=925,delay=0.25,radius=40,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GravesQLineMis"]={charName="Graves",slot=_Q,type="rectangular",displayName="End of the Line",killTime=0,speed=math.huge,range=925,delay=0.25,radius2=250,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GravesSmokeGrenade"]={charName="Graves",slot=_W,type="circular",displayName="Smoke Screen",killTime=0,speed=1450,range=950,delay=0.15,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GravesChargeShot"]={charName="Graves",slot=_R,type="linear",displayName="Collateral Damage",killTime=0,speed=1950,range=1000,delay=0.25,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GravesChargeShotFxMissile"]={charName="Graves",slot=_R,type="conic",displayName="Collateral Damage",killTime=0,speed=math.huge,range=800,delay=0.3,radius=80,angle=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["HecarimRapidSlash"]={charName="Hecarim",slot=_Q,type="circular",displayName="Collateral Damage",killTime=0,speed=math.huge,range=0,delay=0,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["HecarimUlt"]={charName="Hecarim",slot=_R,type="linear",displayName="Onslaught of Shadows",killTime=0,speed=1200,range=1000,delay=0.01,radius=210,hitbox=true,aoe=true,cc=true,mcollision=false},
	["HeimerdingerW"]={charName="Heimerdinger",slot=_W,type="linear",displayName="Hextech Micro-Rockets",killTime=0,speed=2050,range=1325,delay=0.25,radius=70,angle=10,hitbox=true,aoe=true,cc=false,mcollision=true},
	["HeimerdingerE"]={charName="Heimerdinger",slot=_E,type="circular",displayName="CH-2 Electron Storm Grenade",killTime=0,speed=1200,range=970,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["HeimerdingerEUlt"]={charName="Heimerdinger",slot=_E,type="circular",displayName="CH-3X Lightning Grenade",killTime=0,speed=1200,range=970,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["IllaoiQ"]={charName="Illaoi",slot=_Q,type="linear",displayName="Tentacle Smash",killTime=0,speed=math.huge,range=850,delay=0.75,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["IllaoiE"]={charName="Illaoi",slot=_E,type="linear",displayName="Test of Spirit",killTime=0,speed=1800,range=900,delay=0.25,radius=45,hitbox=true,aoe=false,cc=false,mcollision=true},
	["IllaoiR"]={charName="Illaoi",slot=_R,type="circular",displayName="Leap of Faith",killTime=2,speed=math.huge,range=0,delay=0.5,radius=450,hitbox=false,aoe=true,cc=false,mcollision=false},
	["IreliaW2"]={charName="Irelia",slot=_W,type="circular",displayName="Defiant Dance",killTime=0,speed=math.huge,range=0,delay=0.25,radius=275,hitbox=false,aoe=true,cc=false,mcollision=false},
	["IreliaW2"]={charName="Irelia",slot=_W,type="linear",displayName="Defiant Dance",killTime=0,speed=math.huge,range=825,delay=0.25,radius=90,hitbox=false,aoe=true,cc=false,mcollision=false},
	["IreliaE"]={charName="Irelia",slot=_E,type="circular",displayName="Flawless Duet",killTime=0,speed=2000,range=900,delay=0,radius=90,hitbox=true,aoe=true,cc=true,mcollision=false},
	["IreliaR"]={charName="Irelia",slot=_R,type="linear",displayName="Vanguard's Edge",killTime=0,speed=1900,range=1000,delay=0.4,radius=135,hitbox=true,aoe=true,cc=true,mcollision=false},
	["IvernQ"]={charName="Ivern",slot=_Q,type="linear",displayName="Rootcaller",killTime=0,speed=1300,range=1075,delay=0.25,radius=50,hitbox=true,aoe=false,cc=true,mcollision=true},
	["HowlingGale"]={charName="Janna",slot=_Q,type="linear",displayName="Howling Gale",killTime=0,speed=1167,range=1750,delay=0,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["JarvanIVDragonStrike"]={charName="JarvanIV",slot=_Q,type="linear",displayName="Dragon Strike",killTime=0,speed=math.huge,range=770,delay=0.4,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["JarvanIVDemacianStandard"]={charName="JarvanIV",slot=_E,type="circular",displayName="Demacian Standard",killTime=0,speed=3440,range=860,delay=0,radius=175,hitbox=true,aoe=true,cc=false,mcollision=false},
	["JayceShockBlast"]={charName="Jayce",slot=_Q,type="linear",displayName="Shock Blast",killTime=0,speed=1450,range=1050,delay=0.214,radius=75,hitbox=true,aoe=true,cc=false,mcollision=true},
	["JayceShockBlastWallMis"]={charName="Jayce",slot=_Q,type="linear",displayName="Shock Blast",killTime=0,speed=1890,range=2030,delay=0.214,radius=105,hitbox=true,aoe=true,cc=false,mcollision=true},
	["JhinW"]={charName="Jhin",slot=_W,type="linear",displayName="Deadly Flourish",killTime=0,speed=5000,range=3000,delay=0.75,radius=40,hitbox=true,aoe=false,cc=true,mcollision=false},
	["JhinE"]={charName="Jhin",slot=_E,type="circular",displayName="Captive Audience",killTime=2,speed=1650,range=750,delay=0.25,radius=140,hitbox=true,aoe=false,cc=true,mcollision=false},
	["JhinRShot"]={charName="Jhin",slot=_R,type="linear",displayName="Curtain Call",killTime=0,speed=5000,range=3500,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=false},
	["JinxW"]={charName="Jinx",slot=_W,type="linear",displayName="Zap!",killTime=0,speed=3200,range=1450,delay=0.6,radius=50,hitbox=true,aoe=false,cc=true,mcollision=true},
	["JinxE"]={charName="Jinx",slot=_E,type="circular",displayName="Flame Chompers!",killTime=1.5,speed=2570,range=900,delay=1.5,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["JinxR"]={charName="Jinx",slot=_R,type="linear",displayName="Mega Death Rocket!",killTime=0,speed=1700,range=25000,delay=0.6,radius=110,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KaisaW"]={charName="Kaisa",slot=_W,type="linear",displayName="Void Seeker",killTime=0,speed=1750,range=3000,delay=0.4,radius=65,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KalistaMysticShot"]={charName="Kalista",slot=_Q,type="linear",displayName="Pierce",killTime=0,speed=2100,range=1150,delay=0.35,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KarmaQ"]={charName="Karma",slot=_Q,type="linear",displayName="Inner Flame",killTime=0,speed=1750,range=950,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=true},
	["KarmaQMantra"]={charName="Karma",slot=_Q,type="linear",displayName="Inner Flame",killTime=0,speed=1750,range=950,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=true},
	["KarthusLayWasteA1"]={charName="Karthus",slot=_Q,type="circular",displayName="Lay Waste",killTime=0,speed=math.huge,range=875,delay=0.75,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KarthusLayWasteA2"]={charName="Karthus",slot=_Q,type="circular",displayName="Lay Waste",killTime=0,speed=math.huge,range=875,delay=0.75,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KarthusLayWasteA3"]={charName="Karthus",slot=_Q,type="circular",displayName="Lay Waste",killTime=0,speed=math.huge,range=875,delay=0.75,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ForcePulse"]={charName="Kassadin",slot=_E,type="conic",displayName="Force Pulse",killTime=0,speed=math.huge,range=600,delay=0.25,radius=80,angle=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["Riftwalk"]={charName="Kassadin",slot=_R,type="circular",displayName="Riftwalk",killTime=0,speed=math.huge,range=500,delay=0.25,radius=300,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KatarinaE"]={charName="Katarina",slot=_E,type="circular",displayName="Shunpo",killTime=0,speed=math.huge,range=725,delay=0.15,radius=150,hitbox=true,aoe=false,cc=false,mcollision=false},
	["KatarinaR"]={charName="Katarina",slot=_R,type="circular",displayName="Death Lotus",killTime=2.5,speed=math.huge,range=0,delay=0,radius=550,hitbox=false,aoe=true,cc=false,mcollision=false},
	["KaynQ"]={charName="Kayn",slot=_Q,type="circular",displayName="Reaping Slash",killTime=0,speed=math.huge,range=0,delay=0.15,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["KaynW"]={charName="Kayn",slot=_W,type="linear",displayName="Blade's Reach",killTime=0,speed=math.huge,range=700,delay=0.55,radius=90,hitbox=true,aoe=true,cc=true,mcollision=false},
	["KennenShurikenHurlMissile1"]={charName="Kennen",slot=_Q,type="linear",displayName="Thundering Shuriken",killTime=0,speed=1650,range=1050,delay=0.175,radius=45,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KhazixW"]={charName="Khazix",slot=_W,type="linear",displayName="Void Spike",killTime=0,speed=1650,range=1000,delay=0.25,radius=60,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KhazixWLong"]={charName="Khazix",slot=_W,type="linear",displayName="Void Spike",killTime=0,speed=1650,range=1000,delay=0.25,radius=70,hitbox=true,aoe=true,cc=true,mcollision=true},
	["KhazixE"]={charName="Khazix",slot=_E,type="circular",displayName="Leap",killTime=0,speed=1400,range=700,delay=0.25,radius=320,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KhazixELong"]={charName="Khazix",slot=_E,type="circular",displayName="Leap",killTime=0,speed=1400,range=900,delay=0.25,radius=320,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KledQ"]={charName="Kled",slot=_Q,type="linear",displayName="Beartrap on a Rope",killTime=0,speed=1400,range=800,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["KledRiderQ"]={charName="Kled",slot=_Q,type="conic",displayName="Pocket Pistol",killTime=0,speed=math.huge,range=700,delay=0.25,radius=25,angle=25,hitbox=false,aoe=true,cc=false,mcollision=false},
	["KledEDash"]={charName="Kled",slot=_E,type="linear",displayName="Jousting",killTime=0,speed=1100,range=550,delay=0,radius=90,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KogMawQ"]={charName="KogMaw",slot=_Q,type="linear",displayName="Caustic Spittle",killTime=0,speed=1600,range=1175,delay=0.25,radius=60,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KogMawVoidOoze"]={charName="KogMaw",slot=_E,type="linear",displayName="Void Ooze",killTime=0,speed=1350,range=1280,delay=0.25,radius=115,hitbox=true,aoe=true,cc=true,mcollision=false},
	["KogMawLivingArtillery"]={charName="KogMaw",slot=_R,type="circular",displayName="Living Artillery",killTime=0,speed=math.huge,range=1800,delay=0.85,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LeBlancW"]={charName="LeBlanc",slot=_W,type="circular",displayName="Distortion",killTime=0,speed=1600,range=600,delay=0.25,radius=260,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LeBlancE"]={charName="LeBlanc",slot=_E,type="linear",displayName="Ethereal Chains",killTime=0,speed=1750,range=925,delay=0.25,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["LeBlancRW"]={charName="LeBlanc",slot=_W,type="circular",displayName="Distortion",killTime=0,speed=1600,range=600,delay=0.25,radius=260,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LeBlancRE"]={charName="LeBlanc",slot=_E,type="linear",displayName="Ethereal Chains",killTime=0,speed=1750,range=925,delay=0.25,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["BlinkMonkQOne"]={charName="LeeSin",slot=_Q,type="linear",displayName="Sonic Wave",killTime=0,speed=1750,range=1200,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["BlinkMonkEOne"]={charName="LeeSin",slot=_E,type="circular",displayName="Tempest",killTime=0,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["LeonaZenithBlade"]={charName="Leona",slot=_E,type="linear",displayName="Zenith Blade",killTime=0,speed=2000,range=875,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=false},
	["LeonaSolarFlare"]={charName="Leona",slot=_R,type="circular",displayName="Solar Flare",killTime=0,speed=math.huge,range=1200,delay=0.625,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LissandraQ"]={charName="Lissandra",slot=_Q,type="linear",displayName="Ice Shard",killTime=0,speed=2400,range=825,delay=0.251,radius=65,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LissandraW"]={charName="Lissandra",slot=_W,type="circular",displayName="Ring of Frost",killTime=0,speed=math.huge,range=0,delay=0.25,radius=450,hitbox=false,aoe=true,cc=true,mcollision=false},
	["LissandraE"]={charName="Lissandra",slot=_E,type="linear",displayName="Glacial Path",killTime=0,speed=850,range=1050,delay=0.25,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LucianQ"]={charName="Lucian",slot=_Q,type="linear",displayName="Piercing Light",killTime=0,speed=math.huge,range=900,delay=0.5,radius=65,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LucianW"]={charName="Lucian",slot=_W,type="linear",displayName="Ardent Blaze",killTime=0,speed=1600,range=900,delay=0.25,radius=65,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LucianR"]={charName="Lucian",slot=_R,type="linear",displayName="The Culling",killTime=0,speed=2800,range=1200,delay=0.01,radius=75,hitbox=true,aoe=false,cc=false,mcollision=true},
	["LuluQ"]={charName="Lulu",slot=_Q,type="linear",displayName="Glitterlance",killTime=0,speed=1500,range=925,delay=0.25,radius=45,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LuxLightBinding"]={charName="Lux",slot=_Q,type="linear",displayName="Light Binding",killTime=0,speed=1200,range=1175,delay=0.25,radius=60,hitbox=true,aoe=true,cc=true,mcollision=true},
	["LuxLightStrikeKugel"]={charName="Lux",slot=_E,type="circular",displayName="Lucent Singularity",killTime=0,speed=1300,range=1000,delay=0.25,radius=350,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LuxMaliceCannon"]={charName="Lux",slot=_R,type="linear",displayName="Final Spark",killTime=0,speed=math.huge,range=3340,delay=1.375,radius=115,hitbox=true,aoe=true,cc=true,mcollision=false},
	["Landslide"]={charName="Malphite",slot=_E,type="circular",displayName="Ground Slam",killTime=0,speed=math.huge,range=0,delay=0.242,radius=200,hitbox=false,aoe=true,cc=true,mcollision=false},
	["UFSlash"]={charName="Malphite",slot=_R,type="circular",displayName="Unstoppable Force",killTime=0,speed=2170,range=1000,delay=0,radius=300,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MalzaharQ"]={charName="Malzahar",slot=_Q,type="rectangular",displayName="Call of the Void",killTime=0,speed=math.huge,range=900,delay=0.25,radius2=400,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MaokaiQ"]={charName="Maokai",slot=_Q,type="linear",displayName="Bramble Smash",killTime=0,speed=1600,range=600,delay=0.375,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MissFortuneScattershot"]={charName="MissFortune",slot=_E,type="circular",displayName="Make It Rain",killTime=2,speed=math.huge,range=1000,delay=0.5,radius=400,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MissFortuneBulletTime"]={charName="MissFortune",slot=_R,type="conic",displayName="Bullet Time",killTime=3,speed=math.huge,range=1400,delay=0.001,radius=40,angle=40,hitbox=false,aoe=true,cc=false,mcollision=false},
	["MordekaiserSiphonOfDestruction"]={charName="Mordekaiser",slot=_E,type="conic",displayName="Siphon of Destruction",killTime=0,speed=math.huge,range=675,delay=0.25,radius=50,angle=50,hitbox=false,aoe=true,cc=false,mcollision=false},
	["DarkBindingMissile"]={charName="Morgana",slot=_Q,type="linear",displayName="Dark Binding",killTime=0,speed=1200,range=1175,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["TormentedSoil"]={charName="Morgana",slot=_W,type="circular",displayName="Tormented Soil",killTime=1,speed=math.huge,range=900,delay=0.25,radius=325,hitbox=true,aoe=true,cc=false,mcollision=false},
	["NamiQ"]={charName="Nami",slot=_Q,type="circular",displayName="Aqua Prison",killTime=0,speed=math.huge,range=875,delay=0.95,radius=200,hitbox=true,aoe=true,cc=true,mcollision=false},
	["NamiR"]={charName="Nami",slot=_R,type="linear",displayName="Tidal Wave",killTime=0,speed=850,range=2750,delay=0.5,radius=215,hitbox=true,aoe=true,cc=true,mcollision=false},
	["NasusE"]={charName="Nasus",slot=_E,type="circular",displayName="Spirit Fire",killTime=5,speed=math.huge,range=650,delay=0.25,radius=400,hitbox=true,aoe=true,cc=false,mcollision=false},
	["NautilusAnchorDrag"]={charName="Nautilus",slot=_Q,type="linear",displayName="Dredge Line",killTime=0,speed=2000,range=1100,delay=0.25,radius=75,hitbox=true,aoe=false,cc=true,mcollision=true},
	["JavelinToss"]={charName="Nidalee",slot=_Q,type="linear",displayName="Javelin Toss",killTime=0,speed=1300,range=1500,delay=0.25,radius=45,hitbox=true,aoe=true,cc=false,mcollision=true},
	["Bushwhack"]={charName="Nidalee",slot=_W,type="circular",displayName="Bushwhack",killTime=1,speed=math.huge,range=900,delay=0.25,radius=85,hitbox=true,aoe=false,cc=false,mcollision=true},
	["Pounce"]={charName="Nidalee",slot=_W,type="circular",displayName="Pounce",killTime=0,speed=1750,range=750,delay=0.25,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["Swipe"]={charName="Nidalee",slot=_E,type="conic",displayName="Swipe",killTime=0,speed=math.huge,range=300,delay=0.25,radius=180,angle=180,hitbox=false,aoe=true,cc=false,mcollision=false},
	["NocturneDuskbringer"]={charName="Nocturne",slot=_Q,type="linear",displayName="Duskbringer",killTime=0,speed=1600,range=1200,delay=0.25,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["AbsoluteZero"]={charName="Nunu",slot=_R,type="circular",displayName="Absolute Zero",killTime=3,speed=math.huge,range=0,delay=0.01,radius=650,hitbox=false,aoe=true,cc=true,mcollision=false},
	["OlafAxeThrowCast"]={charName="Olaf",slot=_Q,type="linear",displayName="Undertow",killTime=0,speed=1550,range=1000,delay=0.25,radius=80,hitbox=true,aoe=true,cc=true,mcollision=false},
	["OrianaIzunaCommand"]={charName="Orianna",slot=_Q,type="linear",displayName="Command Attack",killTime=0,speed=1400,range=825,delay=0.25,radius=175,hitbox=true,aoe=true,cc=false,mcollision=false},
	["OrianaDissonanceCommand"]={charName="Orianna",slot=_W,type="circular",displayName="Command Dissonance",killTime=0,proj="OrianaDissonanceCommand-",speed=math.huge,range=0,delay=0.25,radius=250,hitbox=false,aoe=true,cc=true,mcollision=false},
	["OrianaRedactCommand"]={charName="Orianna",slot=_E,type="linear",displayName="Command Protect",killTime=0,proj="orianaredact",speed=1400,range=1100,delay=0.25,radius=55,hitbox=true,aoe=true,cc=false,mcollision=false},
	["OrianaDetonateCommand"]={charName="Orianna",slot=_R,type="circular",displayName="Command Shockwave",killTime=0,proj="OrianaDetonateCommand-",speed=math.huge,range=0,delay=0.5,radius=325,hitbox=false,aoe=true,cc=true,mcollision=false},
	["OrnnQ"]={charName="Ornn",slot=_Q,type="linear",displayName="Volcanic Rupture",killTime=0,speed=2000,range=800,delay=0.3,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["OrnnW"]={charName="Ornn",slot=_W,type="linear",displayName="Bellows Breath",killTime=0,speed=math.huge,range=550,delay=0.25,radius=110,hitbox=true,aoe=true,cc=false,mcollision=false},
	["OrnnE"]={charName="Ornn",slot=_E,type="linear",displayName="Searing Charge",killTime=0,speed=1780,range=800,delay=0.35,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["OrnnR"]={charName="Ornn",slot=_R,type="linear",displayName="Call of the Forge God",killTime=0,speed=1200,range=2500,delay=0.5,radius=225,hitbox=true,aoe=true,cc=true,mcollision=false},
	["PantheonE"]={charName="Pantheon",slot=_E,type="conic",displayName="Heartseeker Strike",killTime=0,speed=math.huge,range=0,delay=0.389,radius=80,angle=80,hitbox=false,aoe=true,cc=false,mcollision=false},
	["PantheonRFall"]={charName="Pantheon",slot=_R,type="circular",displayName="Grand Skyfall",killTime=2.5,speed=math.huge,range=5500,delay=0.25,radius=700,hitbox=true,aoe=true,cc=true,mcollision=false},
	["PoppyQSpell"]={charName="Poppy",slot=_Q,type="linear",displayName="Hammer Shock",killTime=0,speed=math.huge,range=430,delay=1.32,radius=85,hitbox=true,aoe=true,cc=true,mcollision=false},
	["PoppyRSpell"]={charName="Poppy",slot=_R,type="linear",displayName="Keeper's Verdict",killTime=0,speed=1600,range=1900,delay=0.6,radius=80,hitbox=true,aoe=true,cc=true,mcollision=false},
	["QuinnQ"]={charName="Quinn",slot=_Q,type="linear",displayName="Blinding Assault",killTime=0,speed=1550,range=1025,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["RakanQ"]={charName="Rakan",slot=_Q,type="linear",displayName="Gleaming Quill",killTime=0,speed=1800,range=900,delay=0.25,radius=60,hitbox=true,aoe=false,cc=false,mcollision=true},
	["RakanW"]={charName="Rakan",slot=_W,type="circular",displayName="Grand Entrance",killTime=0,speed=2150,range=600,delay=0,radius=250,hitbox=true,aoe=true,cc=false,mcollision=false},
	["RekSaiQBurrowed"]={charName="Reksai",slot=_Q,type="linear",displayName="Prey Seeker",killTime=0,speed=2100,range=1650,delay=0.125,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["RenektonCleave"]={charName="Renekton",slot=_Q,type="circular",displayName="Cull the Meek",killTime=0,speed=math.huge,range=0,delay=0.25,radius=325,hitbox=false,aoe=true,cc=false,mcollision=false},
	["RenektonSliceAndDice"]={charName="Renekton",slot=_E,type="linear",displayName="Slice and Dice",killTime=0,speed=1125,range=450,delay=0.25,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["RengarW"]={charName="Rengar",slot=_W,type="circular",displayName="Battle Roar",killTime=0,speed=math.huge,range=0,delay=0.25,radius=450,hitbox=false,aoe=true,cc=false,mcollision=false},
	["RengarE"]={charName="Rengar",slot=_E,type="linear",displayName="Bola Strike",killTime=0,speed=1500,range=1000,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["RivenMartyr"]={charName="Riven",slot=_W,type="circular",displayName="Ki Burst",killTime=0,speed=math.huge,range=0,delay=0.267,radius=135,hitbox=false,aoe=true,cc=true,mcollision=false},
	["RivenIzunaBlade"]={charName="Riven",slot=_R,type="conic",displayName="Blade of the Exile",killTime=0,speed=1600,range=900,delay=0.25,radius=50,angle=50,hitbox=true,aoe=true,cc=false,mcollision=false},
	["RumbleGrenade"]={charName="Rumble",slot=_E,type="linear",displayName="Electro Harpoon",killTime=0,speed=2000,range=850,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=true},
	["RumbleCarpetBombDummy"]={charName="Rumble",slot=_R,type="linear",displayName="The Equalizer",killTime=0,speed=1600,range=1700,delay=0.583,radius=130,hitbox=true,aoe=true,cc=true,mcollision=false},
	["RyzeQ"]={charName="Ryze",slot=_Q,type="linear",displayName="Overload",killTime=0,speed=1700,range=1000,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["SejuaniQ"]={charName="Sejuani",slot=_Q,type="linear",displayName="Arctic Assault",killTime=0,speed=1300,range=650,delay=0.25,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SejuaniW"]={charName="Sejuani",slot=_W,type="conic",displayName="Winter's Wrath",killTime=0.25,speed=math.huge,range=600,delay=0.25,radius=75,angle=75,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SejuaniR"]={charName="Sejuani",slot=_R,type="linear",displayName="Glacial Prison",killTime=0,speed=1650,range=1300,delay=0.25,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ShenE"]={charName="Shen",slot=_E,type="linear",displayName="Shadow Dash",killTime=0,speed=1200,range=600,delay=0,radius=60,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ShyvanaFireball"]={charName="Shyvana",slot=_E,type="linear",displayName="Flame Breath",killTime=0,speed=1575,range=925,delay=0.25,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ShyvanaTransformLeap"]={charName="Shyvana",slot=_R,type="linear",displayName="Dragon's Descent",killTime=0,speed=1130,range=850,delay=0.25,radius=160,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ShyvanaFireballDragon2"]={charName="Shyvana",slot=_E,type="linear",displayName="Flame Breath",killTime=0,speed=1575,range=925,delay=0.333,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["MegaAdhesive"]={charName="Singed",slot=_W,type="circular",displayName="Mega Adhesive",killTime=3,speed=math.huge,range=1000,delay=0.25,radius=265,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SionQ"]={charName="Sion",slot=_Q,type="linear",displayName="Decimating Smash",killTime=2,speed=math.huge,range=600,delay=0,radius=300,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SionE"]={charName="Sion",slot=_E,type="linear",displayName="Roar of the Slayer",killTime=0,speed=1900,range=725,delay=0.25,radius=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SivirQ"]={charName="Sivir",slot=_Q,type="linear",displayName="Boomerang Blade",killTime=0,speed=1350,range=1250,delay=0.25,radius=75,hitbox=true,aoe=true,cc=false,mcollision=false},
	["SkarnerVirulentSlash"]={charName="Skarner",slot=_Q,type="circular",displayName="Crystal Slash",killTime=0.25,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["SkarnerFracture"]={charName="Skarner",slot=_E,type="linear",displayName="Fracture",killTime=0,speed=1500,range=1000,delay=0.25,radius=70,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SonaR"]={charName="Sona",slot=_R,type="linear",displayName="Crescendo",killTime=0,speed=2250,range=900,delay=0.25,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SorakaQ"]={charName="Soraka",slot=_Q,type="circular",displayName="Crescendo",killTime=0,speed=1150,range=800,delay=0.25,radius=235,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SorakaE"]={charName="Soraka",slot=_E,type="circular",displayName="Equinox",killTime=1.5,speed=math.huge,range=925,delay=0.25,radius=300,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SwainQ"]={charName="Swain",slot=_Q,type="conic",displayName="Death's Hand",killTime=0.25,speed=math.huge,range=725,delay=0.25,radius=45,angle=45,hitbox=false,aoe=true,cc=false,mcollision=false},
	["SwainW"]={charName="Swain",slot=_W,type="circular",displayName="Vision of Empire",killTime=1.5,speed=math.huge,range=3500,delay=0.25,radius=325,hitbox=false,aoe=true,cc=false,mcollision=false},
	["SwainE"]={charName="Swain",slot=_E,type="linear",displayName="Nevermove",killTime=0,speed=1550,range=850,delay=0.25,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SyndraQ"]={charName="Syndra",slot=_Q,type="circular",displayName="Dark Sphere",killTime=0,speed=math.huge,range=800,delay=0.625,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["SyndraWCast"]={charName="Syndra",slot=_W,type="circular",displayName="Force of Will",killTime=0,speed=1450,range=950,delay=0.25,radius=225,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SyndraE"]={charName="Syndra",slot=_E,type="conic",displayName="Scatter the Weak",killTime=0,speed=2500,range=700,delay=0.25,radius=40,angle=40,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SyndraEMissile"]={charName="Syndra",slot=_E,type="linear",displayName="Scatter the Weak",killTime=0,speed=1600,range=1250,delay=0.25,radius=50,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TahmKenchQ"]={charName="TahmKench",slot=_Q,type="linear",displayName="Tongue Lash",killTime=0,speed=2670,range=800,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=true},
	["TaliyahQ"]={charName="Taliyah",slot=_Q,type="linear",displayName="Threaded Volley",killTime=0,speed=2850,range=1000,delay=0.25,radius=100,hitbox=true,aoe=false,cc=false,mcollision=true},
	["TaliyahWVC"]={charName="Taliyah",slot=_W,type="circular",displayName="Seismic Shove",killTime=0,speed=math.huge,range=900,delay=0.6,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TaliyahE"]={charName="Taliyah",slot=_E,type="conic",displayName="Unraveled Earth",killTime=0,speed=2000,range=800,delay=0.25,radius=80,angle=80,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TalonW"]={charName="Talon",slot=_W,type="conic",displayName="Rake",killTime=0,speed=1850,range=650,delay=0.25,radius=35,angle=35,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TalonR"]={charName="Talon",slot=_R,type="circular",displayName="Shadow Assault",killTime=0,speed=math.huge,range=0,delay=0.25,radius=550,hitbox=false,aoe=true,cc=false,mcollision=false},
	["TeemoRCast"]={charName="Teemo",slot=_R,type="circular",displayName="Noxious Trap",killTime=2,speed=math.huge,range=900,delay=1.25,radius=200,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ThreshQ"]={charName="Thresh",slot=_Q,type="linear",displayName="Death Sentence",killTime=0,speed=1900,range=1100,delay=0.5,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["ThreshEFlay"]={charName="Thresh",slot=_E,type="linear",displayName="Flay",killTime=0,proj="ThreshEMissile1",speed=math.huge,range=400,delay=0.389,radius=95,hitbox=false,aoe=true,cc=true,mcollision=false},
	["TristanaW"]={charName="Tristana",slot=_W,type="circular",displayName="Rocket Jump",killTime=0,speed=1100,range=900,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TrundleCircle"]={charName="Trundle",slot=_E,type="circular",displayName="Pillar of Ice",killTime=0.25,speed=math.huge,range=1000,delay=0.25,radius=375,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TryndamereE"]={charName="Tryndamere",slot=_E,type="linear",displayName="Spinning Slash",killTime=0,speed=1300,range=660,delay=0,radius=225,hitbox=true,aoe=true,cc=false,mcollision=false},
	["WildCards"]={charName="TwistedFate",slot=_Q,type="linear",displayName="Wild Cards",killTime=0,speed=1000,range=1450,delay=0.25,radius=35,hitbox=true,aoe=true,cc=false,mcollision=false},
	["TwitchVenomCask"]={charName="Twitch",slot=_W,type="circular",displayName="Venom Cask",killTime=0,speed=1400,range=950,delay=0.25,radius=340,hitbox=true,aoe=true,cc=true,mcollision=false},
	["UrgotQ"]={charName="Urgot",slot=_Q,type="circular",displayName="Corrosive Charge",killTime=0,speed=math.huge,range=800,delay=0.6,radius=215,hitbox=true,aoe=true,cc=true,mcollision=false},
	["UrgotE"]={charName="Urgot",slot=_E,type="linear",displayName="Disdain",killTime=0,speed=1050,range=475,delay=0.45,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["UrgotR"]={charName="Urgot",slot=_R,type="linear",displayName="Fear Beyond Death",killTime=0,speed=3200,range=1600,delay=0.4,radius=70,hitbox=true,aoe=false,cc=true,mcollision=false},
	["VarusQ"]={charName="Varus",slot=_Q,type="linear",displayName="Piercing Arrow",killTime=0,speed=1850,range=1625,delay=0,radius=40,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VarusE"]={charName="Varus",slot=_E,type="circular",displayName="Hail of Arrows",killTime=0,speed=1500,range=925,delay=0.242,radius=280,hitbox=true,aoe=true,cc=true,mcollision=false},
	["VarusR"]={charName="Varus",slot=_R,type="linear",displayName="Chain of Corruption",killTime=0,speed=1850,range=1075,delay=0.242,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["VeigarBalefulStrike"]={charName="Veigar",slot=_Q,type="linear",displayName="Baleful Strike",killTime=0,speed=2000,range=950,delay=0.25,radius=60,hitbox=true,aoe=true,cc=false,mcollision=true},
	["VeigarDarkMatter"]={charName="Veigar",slot=_W,type="circular",displayName="Dark Matter",killTime=0,speed=math.huge,range=900,delay=1.25,radius=225,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VeigarEventHorizon"]={charName="Veigar",slot=_E,type="annular",displayName="Event Horizon",killTime=3.5,speed=math.huge,range=700,delay=0.75,radius=375,hitbox=true,aoe=true,cc=true,mcollision=false},
	["VelKozQ"]={charName="VelKoz",slot=_Q,type="linear",displayName="Plasma Fission",killTime=0,speed=1235,range=1050,delay=0.251,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["VelkozQMissileSplit"]={charName="VelKoz",slot=_Q,type="linear",displayName="Plasma Fission",killTime=0,proj="VelkozQMissileSplit",speed=2100,range=1050,delay=0.251,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["VelKozW"]={charName="VelKoz",slot=_W,type="linear",displayName="Void Rift",killTime=0,speed=1500,range=1050,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VelKozE"]={charName="VelKoz",slot=_E,type="circular",displayName="Tectonic Disruption",killTime=0,speed=math.huge,range=850,delay=0.75,radius=235,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ViQ"]={charName="Vi",slot=_Q,type="linear",displayName="Vault Breaker",killTime=0,speed=1400,range=725,delay=0,radius=55,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ViktorGravitonField"]={charName="Viktor",slot=_W,type="circular",displayName="Gravity Field",killTime=0,speed=math.huge,range=700,delay=1.333,radius=290,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ViktorDeathRay"]={charName="Viktor",slot=_E,type="linear",displayName="Death Ray",killTime=0,speed=1350,range=1025,delay=0,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VladimirHemoplague"]={charName="Vladimir",slot=_R,type="circular",displayName="Hemoplague",killTime=0,speed=math.huge,range=700,delay=0.389,radius=350,hitbox=true,aoe=true,cc=false,mcollision=true},
	["WarwickR"]={charName="Warwick",slot=_R,type="linear",displayName="Infinite Duress",killTime=0,speed=1800,range=3000,delay=0.1,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XayahQ"]={charName="Xayah",slot=_Q,type="linear",displayName="Double Daggers",killTime=0,speed=2075,range=1100,delay=0.5,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XayahE"]={charName="Xayah",slot=_E,type="linear",displayName="Bladecaller",killTime=0,speed=5700,range=2000,delay=0,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XayahR"]={charName="Xayah",slot=_R,type="conic",displayName="Featherstorm",killTime=0,speed=4400,range=1100,delay=1.5,radius=40,angle=40,hitbox=false,aoe=true,cc=false,mcollision=false},
	["XerathArcanopulse2"]={charName="Xerath",slot=_Q,type="linear",displayName="Arcanopulse",killTime=0,speed=math.huge,range=1400,delay=0.5,radius=75,hitbox=false,aoe=true,cc=false,mcollision=false},
	["XerathArcaneBarrage2"]={charName="Xerath",slot=_W,type="circular",displayName="Eye of Destruction",killTime=0,speed=math.huge,range=1100,delay=0.5,radius=235,hitbox=true,aoe=true,cc=true,mcollision=false},
	["XerathMageSpearMissile"]={charName="Xerath",slot=_E,type="linear",displayName="Shocking Orb",killTime=0,speed=1350,range=1050,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["XerathRMissileWrapper"]={charName="Xerath",slot=_R,type="circular",displayName="Rite of the Arcane",killTime=0,speed=math.huge,range=6160,delay=0.6,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XinZhaoW"]={charName="XinZhao",slot=_W,type="conic",displayName="Wind Becomes Lightning",killTime=0,speed=math.huge,range=125,delay=0,radius=180,angle=180,hitbox=false,aoe=true,cc=false,mcollision=false},
	["XinZhaoW"]={charName="XinZhao",slot=_W,type="linear",displayName="Wind Becomes Lightning",killTime=0,speed=math.huge,range=900,delay=0.5,radius=45,hitbox=true,aoe=true,cc=true,mcollision=false},
	["XinZhaoR"]={charName="XinZhao",slot=_R,type="circular",displayName="Crescent Guard",killTime=0,speed=math.huge,range=0,delay=0.325,radius=550,hitbox=false,aoe=true,cc=true,mcollision=false},
	["YasuoQW"]={charName="Yasuo",slot=_Q,type="linear",displayName="Steel Tempest",killTime=0,speed=math.huge,range=475,delay=0.339,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["YasuoQ2W"]={charName="Yasuo",slot=_Q,type="linear",displayName="Steel Wind Rising",killTime=0,speed=math.huge,range=475,delay=0.339,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["YasuoQ3W"]={charName="Yasuo",slot=_Q,type="linear",displayName="Gathering Storm",killTime=0,speed=1500,range=1000,delay=0.339,radius=75,hitbox=true,aoe=true,cc=true,mcollision=false},
	["YorickW"]={charName="Yorick",slot=_W,type="annular",displayName="Dark Procession",killTime=4,speed=math.huge,range=600,delay=0.25,radius=300,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZacQ"]={charName="Zac",slot=_Q,type="linear",displayName="Stretching Strikes",killTime=0,speed=math.huge,range=800,delay=0.33,radius=85,hitbox=true,aoe=true,cc=true,mcollision=true},
	["ZacW"]={charName="Zac",slot=_W,type="circular",displayName="Unstable Matter",killTime=0.25,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["ZacE"]={charName="Zac",slot=_E,type="circular",displayName="Elastic Slingshot",killTime=0,speed=1330,range=1800,delay=0,radius=300,hitbox=false,aoe=true,cc=true,mcollision=false},
	["ZacR"]={charName="Zac",slot=_R,type="circular",displayName="Let's Bounce!",killTime=2.5,speed=math.huge,range=1000,delay=0,radius=300,hitbox=false,aoe=true,cc=true,mcollision=false},
	["ZedQ"]={charName="Zed",slot=_Q,type="linear",displayName="Razor Shuriken",killTime=0,speed=1700,range=900,delay=0.25,radius=50,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZedW"]={charName="Zed",slot=_W,type="linear",displayName="Living Shadow",killTime=0,speed=1750,range=650,delay=0.25,radius=40,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZedE"]={charName="Zed",slot=_E,type="circular",displayName="Shadow Slash",killTime=0,speed=math.huge,range=0,delay=0.25,radius=290,hitbox=false,aoe=true,cc=true,mcollision=false},
	["ZiggsQSpell"]={charName="Ziggs",slot=_Q,type="circular",displayName="Bouncing Bomb",killTime=0,speed=1700,range=1400,delay=0.5,radius=180,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZiggsQSpell2"]={charName="Ziggs",slot=_Q,type="circular",displayName="Bouncing Bomb",killTime=0,speed=1700,range=1400,delay=0.47,radius=180,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZiggsQSpell3"]={charName="Ziggs",slot=_Q,type="circular",displayName="Bouncing Bomb",killTime=0,speed=1700,range=1400,delay=0.44,radius=180,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZiggsW"]={charName="Ziggs",slot=_W,type="circular",displayName="Satchel Charge",killTime=4,speed=2000,range=1000,delay=0.25,radius=325,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZiggsE"]={charName="Ziggs",slot=_E,type="circular",displayName="Hexplosive Minefield",killTime=1,speed=1800,range=900,delay=0.25,radius=325,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZiggsR"]={charName="Ziggs",slot=_R,type="circular",displayName="Mega Inferno Bomb",killTime=0,speed=1500,range=5300,delay=0.375,radius=550,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZileanQ"]={charName="Zilean",slot=_Q,type="circular",displayName="Time Bomb",killTime=3,speed=2050,range=900,delay=0.25,radius=180,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZileanQAttachAudio"]={charName="Zilean",slot=_Q,type="circular",displayName="Time Bomb",killTime=3,speed=2050,range=900,delay=0.25,radius=180,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZoeQ"]={charName="Zoe",slot=_Q,type="linear",displayName="Paddle Star",killTime=0,speed=1280,range=800,delay=0.25,radius=40,hitbox=true,aoe=false,cc=false,mcollision=true},
	["ZoeQRecast"]={charName="Zoe",slot=_Q,type="linear",displayName="Paddle Star",killTime=0,speed=2370,range=1600,delay=0,radius=40,hitbox=true,aoe=false,cc=false,mcollision=true},
	["ZoeE"]={charName="Zoe",slot=_E,type="linear",displayName="Sleepy Trouble Bubble",killTime=0,speed=1950,range=800,delay=0.3,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["ZyraQ"]={charName="Zyra",slot=_Q,type="rectangular",displayName="Deadly Spines",killTime=0,speed=math.huge,range=800,delay=0.625,radius2=400,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZyraE"]={charName="Zyra",slot=_E,type="linear",displayName="Grasping Roots",killTime=0,speed=1150,range=1100,delay=0.25,radius=60,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZyraR"]={charName="Zyra",slot=_R,type="circular",displayName="Stranglethorns",killTime=0,speed=math.huge,range=700,delay=1.775,radius=575,hitbox=true,aoe=true,cc=true,mcollision=false},
}
offer = 0
end

local function dRectangleOutline(s, e, w, t, c, v)
	local z1 = s+Vector(Vector(e)-s):perpendicular():normalized()*w/2
	local z2 = s+Vector(Vector(e)-s):perpendicular2():normalized()*w/2
	local z3 = e+Vector(Vector(s)-e):perpendicular():normalized()*w/2
	local z4 = e+Vector(Vector(s)-e):perpendicular2():normalized()*w/2
	local z5 = s+Vector(Vector(e)-s):perpendicular():normalized()*w
	local z6 = s+Vector(Vector(e)-s):perpendicular2():normalized()*w
	local c1 = WorldToScreen(0,z1)
	local c2 = WorldToScreen(0,z2)
	local c3 = WorldToScreen(0,z3)
	local c4 = WorldToScreen(0,z4)
	local c5 = WorldToScreen(0,z5)
	local c6 = WorldToScreen(0,z6)
	if v then
		DrawLine(c5.x,c5.y,c6.x,c6.y,t,ARGB(255,128,223,223))
	else
		DrawLine(c5.x,c5.y,c6.x,c6.y,t,ARGB(255,128,223,223))
	end
	DrawLine(c2.x,c2.y,c3.x,c3.y,t,c)
	DrawLine(c3.x,c3.y,c4.x,c4.y,t,c)
	DrawLine(c1.x,c1.y,c4.x,c4.y,t,c)
end

local function DrawRectangle(s,e,r,r2,t,c)
    local spos = Vector(e) - (Vector(e) - Vector(s)):normalized():perpendicular() * (r2 or 400)
    local epos = Vector(e) + (Vector(e) - Vector(s)):normalized():perpendicular() * (r2 or 400)
	local ePos = Vector(epos)
	local sPos = Vector(spos)
	local dVec = Vector(ePos - sPos)
	local sVec = dVec:normalized():perpendicular()*((r)*.5)
	local TopD1 = WorldToScreen(0,sPos-sVec)
	local TopD2 = WorldToScreen(0,sPos+sVec)
	local BotD1 = WorldToScreen(0,ePos-sVec)
	local BotD2 = WorldToScreen(0,ePos+sVec)
	DrawLine(TopD1.x,TopD1.y,TopD2.x,TopD2.y,t,c)
	DrawLine(TopD1.x,TopD1.y,BotD1.x,BotD1.y,t,c)
	DrawLine(TopD2.x,TopD2.y,BotD2.x,BotD2.y,t,c)
	DrawLine(BotD1.x,BotD1.y,BotD2.x,BotD2.y,t,c)
end

local function DrawCone(v1,v2,angle,width,color)
	angle = angle * math.pi / 180
	v1 = Vector(v1)
	v2 = Vector(v2)
	local a1 = Vector(Vector(v2)-Vector(v1)):rotated(0,-angle*.5,0)
	local a2 = nil
	DrawLine3D(v1.x,v1.y,v1.z,v1.x+a1.x,v1.y+a1.y,v1.z+a1.z,width,color)
	for i = -angle*.5,angle*.5,angle*.1 do
		a2 = Vector(v2-v1):rotated(0,i,0)
		DrawLine3D(v1.x+a2.x,v1.y+a2.y,v1.z+a2.z,v1.x+a1.x,v1.y+a1.y,v1.z+a1.z,width,color)
		a1 = a2
	end    
	DrawLine3D(v1.x,v1.y,v1.z,v1.x+a1.x,v1.y+a1.y,v1.z+a1.z,width,color)
end

local function DrawArrow(s, e, w, c)
	local s2 = e-((s-e):normalized()*75):perpendicular()+(s-e):normalized()*75
	local s3 = e-((s-e):normalized()*75):perpendicular2()+(s-e):normalized()*75
	DrawLine3D(s.x,s.y,s.z,e.x,e.y,e.z,w,c)
	DrawLine3D(s2.x,s2.y,s2.z,e.x,e.y,e.z,w,c)
	DrawLine3D(s3.x,s3.y,s3.z,e.x,e.y,e.z,w,c)	
end

local ta = {_G.HoldPosition, _G.AttackUnit}
local function DisableHoldPosition(boolean)
	if boolean then
		_G.HoldPosition, _G.AttackUnit = function() end, function() end
	else
		_G.HoldPosition, _G.AttackUnit = ta[1], ta[2]
	end
end

local function DisableAll(b)
	if b then
		if _G.IOW then
			IOW.movementEnabled = false
			IOW.attacksEnabled = false
		elseif _G.GoSWalkLoaded then
			_G.GoSWalk:EnableMovement(false)
			_G.GoSWalk:EnableAttack(false)
		end
		BlockF7OrbWalk(true)
		BlockF7Dodge(true)
		BlockInput(true)
	else
		if _G.IOW then
			IOW.movementEnabled = true
			IOW.attacksEnabled = true
		elseif _G.GoSWalkLoaded then
			_G.GoSWalk:EnableMovement(true)
			_G.GoSWalk:EnableAttack(true)
		end
		BlockF7OrbWalk(false)
		BlockF7Dodge(false)
		BlockInput(false)
	end
end

function SimpleEvade:WndMsg(s1,s2)
	if s2 == string.byte("Y") and s1 == 257 then
		self:Skillshot()
		offer = offer+1
	end
end

function SimpleEvade:Skillshot()
		local s = {}
		s.spell = {}
		s.p = {}
		s.p.startPos = Vector(2874,95,2842)
		s.spell.name = "DarkBindingMissile"..offer
		s.spell.charName = myHero.charName
		s.spell.proj = nil
        s.spell.killTime = 0.25
        s.spell.mcollision = true
        s.spell.dangerous = false
        s.spell.radius = 120
        s.spell.speed = 250
        s.spell.delay = 0.25
		s.spell.range = 1200
        s.p.endPos = Vector(2104,95,3196)
        s.spell.type = "linear"
        s.uDodge = false 
        s.caster = myHero
        s.mpos = nil
		s.debug = true
        s.startTime = os.clock()
        self.Object1[s.spell.name] = s
		DelayAction(function() self.Object1[s.spell.name] = nil end,s.spell.range/s.spell.speed - s.spell.delay)
end

function SimpleEvade:TickP()
	heroes[myHero.networkID] = nil
	for _,i in pairs(self.Object1) do
		if i.o and i.spell.type == "linear" and GetDistance(myHero,i.o) >= 6200 and not self.GlobalUlts[_] then return end
		if i.p and i.spell.type == "circular" and GetDistance(myHero,i.p.endPos) >= 6200 and not self.GlobalUlts[_] then return end
		if i.p and i.spell.type == "conic" and GetDistance(myHero,i.p.endPos) >= 6200 and not self.GlobalUlts[_] then return end
		if i.p and i.spell.type == "rectangular" and GetDistance(myHero,i.p.endPos) >= 6200 and not self.GlobalUlts[_] then return end
		if not i.jp or not i.safe then
			self.ASD = false
			DisableHoldPosition(false)
			DisableAll(false)
		end
		if i.o then
			i.p = {}
			i.p.startPos = Vector(i.o.startPos)
			i.p.endPos = Vector(i.o.endPos)
		end
		if i.p then
			self:CleanObj(_,i) 
			self:Dodge(_,i) 
			self:Pathfinding(_,i)
			self:UDodge(_,i)
			self:Mpos(_,i)
		end
	end
end

function SimpleEvade:DrawP()
	for _,i in pairs(self.Object1) do
		if i.o and i.spell.type == "linear" and GetDistance(myHero,i.o) >= 3000 and not self.GlobalUlts[_] then return end
		if i.p and i.spell.type == "circular" and GetDistance(myHero,i.p.endPos) >= 3000 and not self.GlobalUlts[_] then return end
		if i.p and i.spell.type == "conic" and GetDistance(myHero,i.p.endPos) >= 3000 and not self.GlobalUlts[_] then return end
		if i.p and i.spell.type == "rectangular" and GetDistance(myHero,i.p.endPos) >= 3000 and not self.GlobalUlts[_] then return end
		if i.o then
			i.p = {}
			i.p.startPos = Vector(i.o.startPos)
			i.p.endPos = Vector(i.o.endPos)
		end
		if i.p then
			if i.spell.type ~= ("circular" or "annular") then self.EndPosition = Vector(i.p.startPos)+Vector(Vector(i.p.endPos)-i.p.startPos):normalized()*i.spell.range end
			self.OPosition = self:sObjpos(_,i)
			self:Drawings(_,i)
			self:Drawings2(_,i)
		end
	self:HeroCollsion(_,i)
	self:MinionCollision(_,i)
	self:WallCollision(_,i)
	end
end

function SimpleEvade:MinionCollision(_,i)
	if i.spell.type == "linear" and i.spell.mcollision and i.p and i.debug and not i.hcoll and not i.wcoll then
		if i.debug then i.spell.range2 = 1200 else i.spell.range2 = self.Spells[_].range end
		for m,p in pairs(minionManager.objects) do
			if p and p.alive and p.team == MINION_ALLY and GetDistance(p.pos,i.p.startPos) < i.spell.range2 then
				local vP = VectorPointProjectionOnLineSegment(Vector(self.OPosition),i.p.endPos,Vector(p))
				if vP and GetDistance(vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.p.startPos,vP)
					i.mcoll = true
				else
					i.spell.range = i.spell.range2
				end
			end
		end
	end
end

function SimpleEvade:HeroCollsion(_,i)
	if i.spell.type == "linear" and i.spell.mcollision and i.p and i.debug and not i.mcoll and not i.wcoll then
		if i.debug then i.spell.range2 = 1200 else i.spell.range2 = self.Spells[_].range end
		for m,p in pairs(heroes) do
			if p and p.alive and p.team == MINION_ALLY and GetDistance(p.pos,i.p.startPos) < i.spell.range2 then
				local vP = VectorPointProjectionOnLineSegment(Vector(self.OPosition),i.p.endPos,Vector(p))
				if vP and GetDistance(vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.p.startPos,vP)
					i.hcoll = true
				else
					i.spell.range = i.spell.range2
				end
			end
		end
	end
end

function SimpleEvade:WallCollision(_,i)
	if i.spell.type == "linear" and i.spell.mcollision and i.p and i.debug and not i.mcoll and not i.hcoll then
		if i.debug then i.spell.range2 = 1200 else i.spell.range2 = self.Spells[_].range end
		for m,p in pairs(self.YasuoWall) do
			if p.obj and p.obj.valid and p.obj.spellOwner.team == MINION_ALLY and GetDistance(p.obj.pos,i.p.startPos) < i.spell.range2 then
				local vP = VectorPointProjectionOnLineSegment(Vector(self.OPosition),i.p.endPos,Vector(p.obj))
				if vP and GetDistance(vP,p.obj.pos) < (i.spell.radius+p.obj.boundingRadius) then
					i.spell.range = GetDistance(i.p.startPos,vP)
					i.wcoll = true
				else
					i.spell.range = i.spell.range2
				end
			end
		end
	end
end

function SimpleEvade:sObjpos(_,i)
	if i.spell.speed ~= math.huge and i.p then
		return i.p.startPos+Vector(Vector(self.EndPosition)-i.p.startPos):normalized()*(i.spell.speed*(os.clock()-i.startTime) + (i.spell.radius+myHero.boundingRadius)/2)
	else
		return Vector(i.p.startPos)
	end
end

function SimpleEvade:sCircPos(_,i)
	if i.p then
		return (i.spell.radius*(os.clock()-(i.spell.killTime + GetDistance(i.caster,i.p.endPos)/i.spell.speed + i.spell.delay)-i.startTime) + i.spell.radius)
	end
end

function SimpleEvade:Status()
	DrawText("Evade : ON", 400, myHero.pos2D.x-50,  myHero.pos2D.y, ARGB(255,255,255,255))
end

function SimpleEvade:Position()
return Vector(myHero) + Vector(Vector(self.MV) - myHero.pos):normalized() * myHero.ms/2
end

function SimpleEvade:PrWp(unit, wp)
  if wp and unit == myHero and wp.index == 1 then
	self.MV = wp.position
  end
end

function SimpleEvade:CleanObj(_,i)
	if i.o and not i.o.valid and i.spell.type ~= "circular" then
		self.Object1[_] = nil
	elseif i.spell.type == "circular" and i.spell.killTime then
		DelayAction(function() self.Object1[_] = nil end, i.spell.killTime + GetDistance(i.caster,i.p.endPos))
	end
end

function SimpleEvade:Mpos(_,i)
	if i.spell.type == "circular" then 
		if i.p and GetDistance(myHero,i.p.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.MPosition then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.MPosition = GetMousePos()
			end
		else
			self.MPosition = nil
			i.mpos = nil
		end
	elseif i.spell.type == "linear" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.MPosition2 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.MPosition2 = GetMousePos()
			end	
		else
			self.MPosition2 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "rectangular" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.MPosition3 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.MPosition3 = GetMousePos()
			end	
		else
			self.MPosition3 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "conic" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.MPosition4 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.MPosition4 = GetMousePos()
			end	
		else
			self.MPosition4 = nil
			i.mpos = nil
		end
	end
end

function SimpleEvade:UDodge(_,i)
	if not i.uDodge then
		if i.safe and i.spell.type == "linear" then
			if GetDistance(self.OPosition)/i.spell.speed + i.spell.delay < GetDistance(i.safe)/myHero.ms then 
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "circular" and i.p then
			if GetDistance(i.p.endPos)/i.spell.speed + i.spell.delay < GetDistance(i.safe)/myHero.ms then
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "rectangular" and i.p then
			if GetDistance(i.p.endPos)/i.spell.speed + i.spell.delay < GetDistance(i.safe)/myHero.ms then
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "conic" and i.p then
			if GetDistance(i.p.endPos)/i.spell.speed + i.spell.delay < GetDistance(i.safe)/myHero.ms then
				i.uDodge = true 
			end
		end
	end
end

function SimpleEvade:Pathfinding(_,i)
	if i.debug then
		if i.spell.type == "linear" and i.p then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.EndPosition)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.EndPosition) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(Vector(self.OPosition),i.p.endPos,v3)
				local jp2 = Vector(VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).x,i.p.endPos.y,VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).y)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
					if GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular2(),jp2) then
						self.ASD = true
						self.PathA = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.PathA) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					else
						self.ASD = true
						self.PathA = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.PathA) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					end
				else
					self.ASD = false
					self.PathA = nil
					self.PathA2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			end
		elseif i.spell.type == "circular" then
			if _ == "AbsoluteZero" then
				i.p.endPos = Vector(i.caster.pos)
			else
				i.p.endPos = Vector(i.p.endPos)
			end
			if GetDistance(myHero,i.p.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe then
				self.ASD = true
				self.PathB = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				if not MapPosition:inWall(self.PathB) then
						i.safe = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					else
						i.safe = i.p.endPos + Vector(self.PathB-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				end
				i.isEvading = true
			else
				self.ASD = false
				self.PathB = nil
				self.PathB2 = nil
				i.isEvading = false
				DisableHoldPosition(false)
				DisableAll(false)
			end
		elseif i.spell.type == "rectangular" then
			local startp = Vector(i.p.endPos) - (Vector(i.p.endPos) - Vector(i.p.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
			local endp = Vector(i.p.endPos) + (Vector(i.p.endPos) - Vector(i.p.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
			if GetDistance(startp) < i.spell.range + myHero.boundingRadius and GetDistance(endp) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(startp,endp,v3)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos then
					self.ASD = true
					self.PathC = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if not MapPosition:inWall(self.PathC) then
							i.safe = Vector(myHero)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe =  Vector(myHero)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
					i.isEvading = true
				end
			else
				self.ASD = false
				self.PathC = nil
				i.isEvading = false
				DisableHoldPosition(false)
				DisableAll(false)
			end
		elseif i.spell.type == "conic" then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.EndPosition)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.EndPosition) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(i.p.startPos,i.p.endPos,v3)
				local jp2 = Vector(VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).x,i.p.endPos.y,VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).y)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
					if GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular2(),jp2) then
						self.ASD = true
						self.PathA = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.PathA) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					else
						self.ASD = true
						self.PathA = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.PathA) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					end
				else
					self.ASD = false
					self.PathA = nil
					self.PathA2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			end
		end
	else
		if i.spell.type == "linear" and i.p then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.EndPosition)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.EndPosition) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(Vector(self.OPosition),i.p.endPos,v3)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
					self.ASD = true
					self.PathA = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					self.PathA2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular(),i.jp) then
						if not MapPosition:inWall(self.PathA2) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					else
						if not MapPosition:inWall(self.PathA) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else 
							i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					end
					i.isEvading = true
				else
					self.ASD = false
					self.PathA = nil
					self.PathA2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			end
		elseif i.spell.type == "circular" then
			if _ == "AbsoluteZero" then
				i.p.endPos = Vector(i.caster.pos)
			else
				i.p.endPos = Vector(i.p.endPos)
			end
			if GetDistance(myHero,i.p.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos then
				self.ASD = true
				self.PathB = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				self.PathB2 = Vector(i.p.endPos) + (Vector(i.mpos) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				if self.MPosition and GetDistance(self.MPosition,self.PathB) > GetDistance(self.MPosition,self.PathB2) then
					if not MapPosition:inWall(self.PathB2) then
							i.safe = Vector(i.p.endPos) + (Vector(i.mpos) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe = i.p.endPos + Vector(self.PathB2-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
				else
					if not MapPosition:inWall(self.PathB) then
							i.safe = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe = i.p.endPos + Vector(self.PathB-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
				end
				i.isEvading = true
			else
				self.ASD = false
				self.PathB = nil
				self.PathB2 = nil
				i.isEvading = false
				DisableHoldPosition(false)
				DisableAll(false)
			end
		elseif i.spell.type == "rectangular" then
			local startp = Vector(i.p.endPos) - (Vector(i.p.endPos) - Vector(i.p.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
			local endp = Vector(i.p.endPos) + (Vector(i.p.endPos) - Vector(i.p.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
			if GetDistance(startp) < i.spell.range + myHero.boundingRadius and GetDistance(endp) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(startp,endp,v3)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos then
					self.ASD = true
					self.PathC = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					self.PathC2 = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if GetDistance(Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular(),i.jp) then
						if not MapPosition:inWall(self.PathC2) then
								i.safe = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else
								i.safe = i.p.endPos + Vector(self.PathC-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					else
						if not MapPosition:inWall(self.PathC) then
								i.safe = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else
								i.safe = i.p.endPos + Vector(self.PathC-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end					
					end
					i.isEvading = true
				end
			else
				self.ASD = false
				self.PathC = nil
				i.isEvading = false
				DisableHoldPosition(false)
				DisableAll(false)
			end
		elseif i.spell.type == "conic" then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.EndPosition)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.EndPosition) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(i.p.startPos,i.p.endPos,v3)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
					self.ASD = true
					self.PathA = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					self.PathA2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular(),i.jp) then
						if not MapPosition:inWall(self.PathA2) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					else
						if not MapPosition:inWall(self.PathA) then
							i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else 
							i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					end
					i.isEvading = true
				else
					self.ASD = false
					self.PathA = nil
					self.PathA2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			end
		end
	end
end

function SimpleEvade:Drawings(_,i)
	if i.debug or SEMenu.Spells[_]["Draw".._]:Value() then
		if i.spell.type == "linear" then
			local sPos = Vector(self.OPosition)
			local ePos = Vector(self.EndPosition)
			dRectangleOutline(sPos, ePos, i.spell.radius+myHero.boundingRadius*2, 1, ARGB(255,255,255,255), i.debug)
		end
		if i.spell.type == "circular" then
			if _ == "AbsoluteZero" then
				i.p.endPos = Vector(i.caster.pos)
			else
				i.p.endPos = Vector(i.p.endPos)
			end
			DrawCircle(i.p.endPos,i.spell.radius,1,75,ARGB(255,255,255,255))
		end
		if i.spell.type == "rectangular" then
			DrawRectangle(i.p.startPos,i.p.endPos,i.spell.radius+myHero.boundingRadius,i.spell.radius2,1,ARGB(255,255,255,255))
		end
		if i.spell.type == "conic" then
			DrawCone(i.p.startPos,Vector(self.EndPosition),i.spell.angle or 40,1,ARGB(255,255,255,255))
		end
		if i.spell.type == "annular" then
			DrawCircle(i.p.endPos.x,i.p.endPos.y,i.p.endPos.z,i.spell.radius,1,75,ARGB(255,255,255,255))
			DrawCircle(i.p.endPos.x,i.p.endPos.y,i.p.endPos.z,i.spell.radius/1.5,1,75,ARGB(255,255,255,255))
		end
		if i.jp and (GetDistance(myHero,i.jp) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "linear" then
			i.safe = nil
		elseif i.p and (GetDistance(myHero,i.p.endPos) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "circular" then
			i.safe = nil
		elseif i.jp and (GetDistance(myHero,i.jp) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "rectangular" then
			i.safe = nil
		elseif i.jp and (GetDistance(myHero,i.jp) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "conic" then
			i.safe = nil
		end
	end
end

function SimpleEvade:Drawings2(_,i)
	if i.safe and (i.debug or SEMenu.Spells[_]["Draw".._]:Value()) then
		DrawArrow(myHero.pos,i.safe,1,ARGB(255,255,255,0))
	end
end

function SimpleEvade:Dodge(_,i)
	if i.debug or SEMenu.Spells[_]["Dodge".._]:Value() then
		if myHero.isSpellShielded then return end
		if i.safe then
			if self.ASD == true then 
				DisableHoldPosition(true)
				DisableAll(true) 
			else 
				DisableHoldPosition(false)
				DisableAll(false) 
			end
			MoveToXYZ(i.safe)
		else
			DisableHoldPosition(false)
			DisableAll(false)
		end
	end
end

function SimpleEvade:BlockMov(order)
	for _,i in pairs(self.Object1) do
		if order.flag ~= 3 and order.position then
			if i.jp and i.spell.type == "linear" then
				if (GetDistance(order.position,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.p and i.spell.type == "circular" then
				if (GetDistance(order.position,i.p.endPos) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.jp and i.spell.type == "rectangular" then
				if (GetDistance(order.position,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.jp and i.spell.type == "conic" then
				if (GetDistance(order.position,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			end
		end
	end
end

function SimpleEvade:CreateObject(obj)
	if obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == MINION_ENEMY then
		for _,l in pairs(self.Spells) do
			if not self.Object1[obj.spellName] and self.Spells[obj.spellName] and (l.proj == obj.spellName or _ == obj.spellName or obj.spellName:lower():find(_:lower()) or obj.spellName:lower():find(l.proj:lower())) then
				if not self.Object1[obj.spellName] then self.Object1[obj.spellName] = {} end
				self.Object1[obj.spellName].o = obj
				self.Object1[obj.spellName].caster = obj.spellOwner
				self.Object1[obj.spellName].mpos = nil
				self.Object1[obj.spellName].uDodge = nil
				self.Object1[obj.spellName].startTime = os.clock()
				self.Object1[obj.spellName].spell = l
			end
		end
	end
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		if not self.YasuoWall[obj.spellName] then self.YasuoWall[obj.spellName] = {} end
		self.YasuoWall[obj.spellName].obj = obj
	end
end

function SimpleEvade:Detection(unit,spellProc)
	if unit and unit.isHero and unit.team == MINION_ENEMY then
		if SEMenu.Print:Value() then
			print(spellProc.name)
		end
		for _,l in pairs(self.Spells) do
			if not self.Object1[spellProc.name] and self.Spells[spellProc.name] and _ == spellProc.name then
				if not self.Object1[spellProc.name] then self.Object1[spellProc.name] = {} end
				self.Object1[spellProc.name].p = spellProc
				self.Object1[spellProc.name].spell = l
				self.Object1[spellProc.name].caster = unit
				self.Object1[spellProc.name].mpos = nil
				self.Object1[spellProc.name].uDodge = nil
				self.Object1[spellProc.name].startTime = os.clock()+l.delay
				self.Object1[spellProc.name].TarE = (Vector(spellProc.endPos) - Vector(unit.pos)):normalized()*l.range
				if l.killTime and l.type == "circular" then
					DelayAction(function() self.Object1[spellProc.name] = nil end, l.killTime + GetDistance(unit,spellProc.endPos)/l.speed + l.delay)
				elseif l.killTime > 0 and l.type ~= "circular" then
					DelayAction(function() self.Object1[spellProc.name] = nil end, l.killTime + 1.3*GetDistance(myHero.pos,spellProc.startPos)/l.speed+l.delay)
				else
					DelayAction(function() self.Object1[spellProc.name] = nil end, l.range/l.speed + l.delay/2)
				end
			elseif l.killName == spellProc.name then
				self.Object1[_] = nil				
			end
		end
	end
end

function SimpleEvade:DeleteObject(obj)
	if obj and obj.isSpell and self.Object1[obj.spellName] and self.Spells[obj.spellName].type ~= "circular" then
			self.Object1[obj.spellName] = nil
	end	
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		self.YasuoWall[obj.spellName] = nil
	end
end
