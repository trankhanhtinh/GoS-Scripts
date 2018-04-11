
Callback.Add("Load", function()	
	SimpleEvade()
	require 'MapPositionGOS'
end)

class 'SimpleEvade'

function SimpleEvade:__init()
	self.supportedtypes = {["linear"]={supported=true},["circular"]={supported=true},["conic"]={supported=true},["rectangular"]={supported=true}}
	self.globalults = {["EzrealTrueshotBarrage"]={s=true},["EnchantedCrystalArrow"]={s=true},["DravenRCast"]={s=true},["JinxR"]={s=true},["GangplankR"]={s=true}}
	self.endposs = nil
	self.obj = {}
	self.asd = false
	self.mposs = nil
	self.mposs2 = nil
	self.mposs3 = nil
	self.mposs4 = nil
	self.mV = nil
	self.opos = nil
	self.patha = nil
	self.patha2 = nil
	self.pathb = nil
	self.pathb2 = nil
	self.pathc = nil
	self.pathc2 = nil
	self.pathd = nil
	self.pathd2 = nil
	self.YasuoWall = {} 
	Callback.Add("Tick", function() self:Tickp() end)
	Callback.Add("ProcessSpell", function(unit, spellProc) self:Detection(unit,spellProc) end)
	Callback.Add("CreateObj", function(obj) self:CreateObject(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteObject(obj) end)
	Callback.Add("Draw", function() self:Drawp() end)
	Callback.Add("ProcessWaypoint", function(unit,wp) self:prwp(unit,wp) end)
	Callback.Add("WndMsg", function(s1,s2) self:WndMsg(s1,s2) end)
	Callback.Add("IssueOrder", function(order) self:BlockMov(order) end)

self.Spells = {
	["AatroxQ"]={charName="Aatrox",slot=_Q,type="circular",killTime=0,speed=450,range=650,delay=0.25,radius=275,hitbox=true,aoe=true,cc=true,mcollision=false},
	["AatroxE"]={charName="Aatrox",slot=_E,type="linear",killTime=0,speed=1200,range=1000,delay=0.25,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["AhriOrbofDeception"]={charName="Ahri",slot=_Q,type="linear",killTime=0,speed=1700,range=880,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["AhriSeduce"]={charName="Ahri",slot=_E,type="linear",killTime=0,speed=1600,range=975,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["Pulverize"]={charName="Alistar",slot=_Q,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=365,hitbox=true,aoe=true,cc=true,mcollision=false},
	["BandageToss"]={charName="Amumu",slot=_Q,type="linear",killTime=0,speed=2000,range=1100,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=true},
	["Tantrum"]={charName="Amumu",slot=_E,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["CurseoftheSadMummy"]={charName="Amumu",slot=_R,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=550,hitbox=false,aoe=true,cc=true,mcollision=false},
	["FlashFrost"]={charName="Anivia",slot=_Q,type="linear",killTime=0,speed=850,range=1075,delay=0.25,radius=225,hitbox=true,aoe=true,cc=true,mcollision=false},
	["Incinerate"]={charName="Annie",slot=_W,type="conic",killTime=0,speed=math.huge,range=600,delay=0.25,radius=50,angle=50,hitbox=false,aoe=true,cc=false,mcollision=false},
	["InfernalGuardian"]={charName="Annie",slot=_R,type="circular",killTime=0,speed=math.huge,range=600,delay=0.25,radius=290,hitbox=true,aoe=true,cc=false,mcollision=false},
	["Volley"]={charName="Ashe",slot=_W,type="conic",killTime=0,speed=2000,range=1200,delay=0.25,radius=20,angle=57.5,hitbox=true,aoe=true,cc=true,mcollision=true},
	["EnchantedCrystalArrow"]={charName="Ashe",slot=_R,type="linear",killTime=0,speed=1600,range=25000,delay=0.25,radius=125,hitbox=true,aoe=false,cc=true,mcollision=false},
	["AurelionSolQ"]={charName="AurelionSol",slot=_Q,type="linear",killTime=0,speed=600,range=1075,delay=0.25,radius=210,hitbox=true,aoe=true,cc=true,mcollision=false},
	["AurelionSolE"]={charName="AurelionSol",slot=_E,type="linear",killTime=0,speed=600,range=7000,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["AurelionSolR"]={charName="AurelionSol",slot=_R,type="linear",killTime=0,speed=4285,range=1500,delay=0.35,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["BardQ"]={charName="Bard",slot=_Q,type="linear",killTime=0,speed=1500,range=950,delay=0.25,radius=80,hitbox=true,aoe=true,cc=true,mcollision=true},
	["BardR"]={charName="Bard",slot=_R,type="circular",killTime=0,speed=2100,range=3400,delay=0.5,radius=350,hitbox=true,aoe=true,cc=true,mcollision=false},
	["RocketGrab"]={charName="Blitzcrank",slot=_Q,type="linear",killTime=0,speed=1750,range=925,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=true},
	["StaticField"]={charName="Blitzcrank",slot=_R,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=600,hitbox=false,aoe=true,cc=true,mcollision=false},
	["BrandQ"]={charName="Brand",slot=_Q,type="linear",killTime=0,speed=1550,range=1050,delay=0.25,radius=65,hitbox=true,aoe=false,cc=true,mcollision=true},
	["BrandW"]={charName="Brand",slot=_W,type="circular",killTime=0,speed=math.huge,range=900,delay=0.625,radius=250,hitbox=true,aoe=true,cc=false,mcollision=false},
	["BraumQ"]={charName="Braum",slot=_Q,type="linear",killTime=0,speed=1670,range=1000,delay=0.25,radius=60,hitbox=true,aoe=true,cc=true,mcollision=true},
	["BraumRWrapper"]={charName="Braum",slot=_Q,type="linear",killTime=0,speed=1400,range=1250,delay=0.5,radius=115,hitbox=true,aoe=true,cc=true,mcollision=false},
	["CaitlynPiltoverPeacemaker"]={charName="Caitlyn",slot=_Q,type="linear",killTime=0,speed=2200,range=1250,delay=0.625,radius=90,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CaitlynYordleTrap"]={charName="Caitlyn",slot=_W,type="circular",killTime=1.5,speed=math.huge,range=800,delay=0.25,radius=75,hitbox=true,aoe=false,cc=true,mcollision=false},
	["CaitlynEntrapmentMissile"]={charName="Caitlyn",slot=_E,type="linear",killTime=0,speed=1500,range=750,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["CamilleW"]={charName="Camille",slot=_W,type="conic",killTime=0,speed=math.huge,range=610,delay=0.75,radius=80,angle=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["CamilleE"]={charName="Camille",slot=_E,type="linear",killTime=0,speed=1350,range=800,delay=0.25,radius=45,hitbox=true,aoe=false,cc=true,mcollision=false},
	["CassiopeiaQ"]={charName="Cassiopeia",slot=_Q,type="circular",killTime=0,speed=math.huge,range=850,delay=0.4,radius=150,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CassiopeiaR"]={charName="Cassiopeia",slot=_R,type="conic",killTime=0,speed=math.huge,range=825,delay=0.5,radius=80,angle=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["Rupture"]={charName="ChoGath",slot=_Q,type="circular",killTime=0,speed=math.huge,range=950,delay=0.5,radius=175,hitbox=true,aoe=true,cc=true,mcollision=false},
	["FeralScream"]={charName="ChoGath",slot=_W,type="conic",killTime=0,speed=math.huge,range=650,delay=0.5,radius=60,angle=60,hitbox=false,aoe=true,cc=true,mcollision=false},
	["PhosphorusBomb"]={charName="Corki",slot=_Q,type="circular",killTime=0,speed=1000,range=825,delay=0.25,radius=250,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CarpetBomb"]={charName="Corki",slot=_W,type="linear",killTime=0,speed=650,range=600,delay=0,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["CarpetBombMega"]={charName="Corki",slot=_W,type="linear",killTime=0,speed=1500,range=1800,delay=0,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["MissileBarrageMissile"]={charName="Corki",slot=_R,type="linear",killTime=0,speed=1950,range=1225,delay=0.175,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["MissileBarrageMissile2"]={charName="Corki",slot=_R,type="linear",killTime=0,speed=1950,range=1225,delay=0.175,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["DariusAxeGrabCone"]={charName="Darius",slot=_E,type="conic",killTime=0,speed=math.huge,range=535,delay=0.25,radius=50,angle=50,hitbox=false,aoe=true,cc=true,mcollision=false},
	["DianaArc"]={charName="Diana",slot=_Q,type="circular",killTime=0,speed=1400,range=900,delay=0.25,radius=205,hitbox=true,aoe=true,cc=false,mcollision=false},
	["InfectedCleaverMissileCast"]={charName="DrMundo",slot=_Q,type="linear",killTime=0,speed=1850,range=975,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["DravenDoubleShot"]={charName="Draven",slot=_E,type="linear",killTime=0,speed=1400,range=1050,delay=0.25,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["DravenRCast"]={charName="Draven",slot=_R,type="linear",killTime=0,speed=2000,range=25000,delay=0.5,radius=130,hitbox=true,aoe=true,cc=false,mcollision=false},
	["EkkoQ"]={charName="Ekko",slot=_Q,type="linear",killTime=0,speed=1650,range=1075,delay=0.25,radius=135,hitbox=true,aoe=true,cc=true,mcollision=false},
	["EkkoW"]={charName="Ekko",slot=_W,type="circular",killTime=0,speed=1650,range=1600,delay=3.75,radius=400,hitbox=true,aoe=true,cc=true,mcollision=false},
	["EkkoR"]={charName="Ekko",slot=_R,type="circular",killTime=0,speed=1650,range=1600,delay=0.25,radius=375,hitbox=false,aoe=true,cc=false,mcollision=false},
	["EliseHumanE"]={charName="Elise",slot=_E,type="linear",killTime=0,speed=1600,range=1075,delay=0.25,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["EvelynnQ"]={charName="Evelynn",slot=_Q,type="linear",killTime=0,speed=2200,range=800,delay=0.25,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["EvelynnR"]={charName="Evelynn",slot=_R,type="conic",killTime=0,speed=math.huge,range=450,delay=0.35,radius=180,angle=180,hitbox=false,aoe=true,cc=false,mcollision=false},
	["EzrealMysticShot"]={charName="Ezreal",slot=_Q,type="linear",killTime=0,speed=2000,range=1150,delay=0.25,radius=80,hitbox=true,aoe=false,cc=false,mcollision=true},
	["EzrealEssenceFlux"]={charName="Ezreal",slot=_W,type="linear",killTime=0,speed=1550,range=1000,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["EzrealTrueshotBarrage"]={charName="Ezreal",slot=_R,type="linear",killTime=0,speed=2000,range=25000,delay=1,radius=160,hitbox=true,aoe=true,cc=false,mcollision=false},
	["FioraW"]={charName="Fiora",slot=_W,type="linear",killTime=0,speed=math.huge,range=750,delay=0.75,radius=85,hitbox=true,aoe=true,cc=true,mcollision=false},
	["FizzR"]={charName="Fizz",slot=_R,type="linear",killTime=0,speed=1300,range=1300,delay=0.25,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GalioQ"]={charName="Galio",slot=_Q,type="circular",killTime=0,speed=1150,range=825,delay=0.25,radius=150,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GalioE"]={charName="Galio",slot=_E,type="linear",killTime=0,speed=1400,range=650,delay=0.45,radius=160,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GalioR"]={charName="Galio",slot=_R,type="circular",killTime=0,speed=math.huge,range=5500,delay=2.75,radius=500,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GangplankR"]={charName="Gangplank",slot=_R,type="circular",killTime=2,speed=math.huge,range=25000,delay=0.25,radius=600,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarQ"]={charName="Gnar",slot=_Q,type="linear",killTime=0,speed=1700,range=1100,delay=0.25,radius=55,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarE"]={charName="Gnar",slot=_E,type="circular",killTime=0,speed=900,range=475,delay=0.25,radius=160,hitbox=true,aoe=false,cc=true,mcollision=false},
	["GnarBigQ"]={charName="Gnar",slot=_Q,type="linear",killTime=0,speed=2100,range=1100,delay=0.5,radius=90,hitbox=true,aoe=true,cc=true,mcollision=true},
	["GnarBigW"]={charName="Gnar",slot=_W,type="linear",killTime=0,speed=math.huge,range=550,delay=0.6,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarBigE"]={charName="Gnar",slot=_E,type="circular",killTime=0,speed=800,range=600,delay=0.25,radius=375,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GnarR"]={charName="Gnar",slot=_R,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=475,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GragasQ"]={charName="Gragas",slot=_Q,type="circular",killTime=4.25,speed=1000,range=850,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GragasE"]={charName="Gragas",slot=_E,type="linear",killTime=0,speed=900,range=600,delay=0.25,radius=170,hitbox=true,aoe=true,cc=true,mcollision=true},
	["GragasR"]={charName="Gragas",slot=_R,type="circular",killTime=0,speed=1800,range=1000,delay=0.25,radius=400,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GravesQLineSpell"]={charName="Graves",slot=_Q,type="linear",killTime=0,speed=3700,range=925,delay=0.25,radius=40,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GravesQLineMis"]={charName="Graves",slot=_Q,type="rectangle",killTime=0,speed=math.huge,range=925,delay=0.25,radius2=250,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GravesSmokeGrenade"]={charName="Graves",slot=_W,type="circular",killTime=0,speed=1450,range=950,delay=0.15,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["GravesChargeShot"]={charName="Graves",slot=_R,type="linear",killTime=0,speed=1950,range=1000,delay=0.25,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["GravesChargeShotFxMissile"]={charName="Graves",slot=_R,type="conic",killTime=0,speed=math.huge,range=800,delay=0.3,radius=80,angle=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["HecarimRapidSlash"]={charName="Hecarim",slot=_Q,type="circular",killTime=0.25,speed=math.huge,range=0,delay=0,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["HecarimUlt"]={charName="Hecarim",slot=_R,type="linear",killTime=0,speed=1200,range=1000,delay=0.01,radius=210,hitbox=true,aoe=true,cc=true,mcollision=false},
	["HeimerdingerW"]={charName="Heimerdinger",slot=_W,type="linear",killTime=0,speed=2050,range=1325,delay=0.25,radius=70,angle=10,hitbox=true,aoe=true,cc=false,mcollision=true},
	["HeimerdingerE"]={charName="Heimerdinger",slot=_E,type="circular",killTime=0,speed=1200,range=970,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["HeimerdingerEUlt"]={charName="Heimerdinger",slot=_E,type="circular",killTime=0,speed=1200,range=970,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["IllaoiQ"]={charName="Illaoi",slot=_Q,type="linear",killTime=0,speed=math.huge,range=850,delay=0.75,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["IllaoiE"]={charName="Illaoi",slot=_E,type="linear",killTime=0,speed=1800,range=900,delay=0.25,radius=45,hitbox=true,aoe=false,cc=false,mcollision=true},
	["IllaoiR"]={charName="Illaoi",slot=_R,type="circular",killTime=2,speed=math.huge,range=0,delay=0.5,radius=450,hitbox=false,aoe=true,cc=false,mcollision=false},
	["IreliaW2"]={charName="Irelia",slot=_W,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=275,hitbox=false,aoe=true,cc=false,mcollision=false},
	["IreliaW2"]={charName="Irelia",slot=_W,type="linear",killTime=0,speed=math.huge,range=825,delay=0.25,radius=90,hitbox=false,aoe=true,cc=false,mcollision=false},
	["IreliaE"]={charName="Irelia",slot=_E,type="circular",killTime=0,speed=2000,range=900,delay=0,radius=90,hitbox=true,aoe=true,cc=true,mcollision=false},
	["IreliaR"]={charName="Irelia",slot=_R,type="linear",killTime=0,speed=1900,range=1000,delay=0.4,radius=135,hitbox=true,aoe=true,cc=true,mcollision=false},
	["IvernQ"]={charName="Ivern",slot=_Q,type="linear",killTime=0,speed=1300,range=1075,delay=0.25,radius=50,hitbox=true,aoe=false,cc=true,mcollision=true},
	["HowlingGale"]={charName="Janna",slot=_Q,type="linear",killTime=0,speed=1167,range=1750,delay=0,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["JarvanIVDragonStrike"]={charName="JarvanIV",slot=_Q,type="linear",killTime=0,speed=math.huge,range=770,delay=0.4,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["JarvanIVDemacianStandard"]={charName="JarvanIV",slot=_E,type="circular",killTime=0,speed=3440,range=860,delay=0,radius=175,hitbox=true,aoe=true,cc=false,mcollision=false},
	["JayceShockBlast"]={charName="Jayce",slot=_Q,type="linear",killTime=0,speed=1450,range=1050,delay=0.214,radius=75,hitbox=true,aoe=true,cc=false,mcollision=true},
	["JayceShockBlastWallMis"]={charName="Jayce",slot=_Q,type="linear",killTime=0,speed=1890,range=2030,delay=0.214,radius=105,hitbox=true,aoe=true,cc=false,mcollision=true},
	["JhinW"]={charName="Jhin",slot=_W,type="linear",killTime=0,speed=5000,range=3000,delay=0.75,radius=40,hitbox=true,aoe=false,cc=true,mcollision=false},
	["JhinE"]={charName="Jhin",slot=_E,type="circular",killTime=2,speed=1650,range=750,delay=0.25,radius=140,hitbox=true,aoe=false,cc=true,mcollision=false},
	["JhinRShot"]={charName="Jhin",slot=_R,type="linear",killTime=0,speed=5000,range=3500,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=false},
	["JinxW"]={charName="Jinx",slot=_W,type="linear",killTime=0,speed=3200,range=1450,delay=0.6,radius=50,hitbox=true,aoe=false,cc=true,mcollision=true},
	["JinxE"]={charName="Jinx",slot=_E,type="circular",killTime=1.5,speed=2570,range=900,delay=1.5,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["JinxR"]={charName="Jinx",slot=_R,type="linear",killTime=0,speed=1700,range=25000,delay=0.6,radius=110,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KaisaW"]={charName="Kaisa",slot=_W,type="linear",killTime=0,speed=1750,range=3000,delay=0.4,radius=65,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KalistaMysticShot"]={charName="Kalista",slot=_Q,type="linear",killTime=0,speed=2100,range=1150,delay=0.35,radius=35,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KarmaQ"]={charName="Karma",slot=_Q,type="linear",killTime=0,speed=1750,range=950,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=true},
	["KarmaQMantra"]={charName="Karma",slot=_Q,type="linear",killTime=0,speed=1750,range=950,delay=0.25,radius=80,hitbox=true,aoe=false,cc=true,mcollision=true},
	["KarthusLayWasteA1"]={charName="Karthus",slot=_Q,type="circular",killTime=0,speed=math.huge,range=875,delay=0.5,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KarthusLayWasteA2"]={charName="Karthus",slot=_Q,type="circular",killTime=0,speed=math.huge,range=875,delay=0.5,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KarthusLayWasteA3"]={charName="Karthus",slot=_Q,type="circular",killTime=0,speed=math.huge,range=875,delay=0.5,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ForcePulse"]={charName="Kassadin",slot=_E,type="conic",killTime=0,speed=math.huge,range=600,delay=0.25,radius=80,angle=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["Riftwalk"]={charName="Kassadin",slot=_R,type="circular",killTime=0,speed=math.huge,range=500,delay=0.25,radius=300,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KatarinaE"]={charName="Katarina",slot=_E,type="circular",killTime=0,speed=math.huge,range=725,delay=0.15,radius=150,hitbox=true,aoe=false,cc=false,mcollision=false},
	["KatarinaR"]={charName="Katarina",slot=_R,type="circular",killTime=2.5,speed=math.huge,range=0,delay=0,radius=550,hitbox=false,aoe=true,cc=false,mcollision=false},
	["KaynQ"]={charName="Kayn",slot=_Q,type="circular",killTime=0,speed=math.huge,range=0,delay=0.15,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["KaynW"]={charName="Kayn",slot=_W,type="linear",killTime=0,speed=math.huge,range=700,delay=0.55,radius=90,hitbox=true,aoe=true,cc=true,mcollision=false},
	["KennenShurikenHurlMissile1"]={charName="Kennen",slot=_Q,type="linear",killTime=0,speed=1650,range=1050,delay=0.175,radius=45,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KhaZixW"]={charName="KhaZix",slot=_W,type="linear",killTime=0,speed=1650,range=1000,delay=0.25,radius=60,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KhaZixWLong"]={charName="KhaZix",slot=_W,type="linear",killTime=0,speed=1650,range=1000,delay=0.25,radius=70,hitbox=true,aoe=true,cc=true,mcollision=true},
	["KhaZixE"]={charName="KhaZix",slot=_E,type="circular",killTime=0,speed=1400,range=700,delay=0.25,radius=320,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KhaZixELong"]={charName="KhaZix",slot=_E,type="circular",killTime=0,speed=1400,range=900,delay=0.25,radius=320,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KledQ"]={charName="Kled",slot=_Q,type="linear",killTime=0,speed=1400,range=800,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["KledEDash"]={charName="Kled",slot=_E,type="linear",killTime=0,speed=1100,range=550,delay=0,radius=90,hitbox=true,aoe=true,cc=false,mcollision=false},
	["KledRiderQ"]={charName="Kled",slot=_Q,type="conic",killTime=0,speed=math.huge,range=700,delay=0.25,radius=25,angle=25,hitbox=false,aoe=true,cc=false,mcollision=false},
	["KogMawQ"]={charName="KogMaw",slot=_Q,type="linear",killTime=0,speed=1600,range=1175,delay=0.25,radius=60,hitbox=true,aoe=false,cc=false,mcollision=true},
	["KogMawVoidOoze"]={charName="KogMaw",slot=_E,type="linear",killTime=0,speed=1350,range=1280,delay=0.25,radius=115,hitbox=true,aoe=true,cc=true,mcollision=false},
	["KogMawLivingArtillery"]={charName="KogMaw",slot=_R,type="circular",killTime=0,speed=math.huge,range=1800,delay=0.85,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LeBlancW"]={charName="LeBlanc",slot=_W,type="circular",killTime=0,speed=1600,range=600,delay=0.25,radius=260,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LeBlancE"]={charName="LeBlanc",slot=_E,type="linear",killTime=0,speed=1750,range=925,delay=0.25,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["LeBlancRW"]={charName="LeBlanc",slot=_W,type="circular",killTime=0,speed=1600,range=600,delay=0.25,radius=260,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LeBlancRE"]={charName="LeBlanc",slot=_E,type="linear",killTime=0,speed=1750,range=925,delay=0.25,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["BlinkMonkQOne"]={charName="LeeSin",slot=_Q,type="linear",killTime=0,speed=1750,range=1200,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["BlinkMonkEOne"]={charName="LeeSin",slot=_E,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["LeonaZenithBlade"]={charName="Leona",slot=_E,type="linear",killTime=0,speed=2000,range=875,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=false},
	["LeonaSolarFlare"]={charName="Leona",slot=_R,type="circular",killTime=0,speed=math.huge,range=1200,delay=0.625,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LissandraQ"]={charName="Lissandra",slot=_Q,type="linear",killTime=0,speed=2400,range=825,delay=0.251,radius=65,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LissandraW"]={charName="Lissandra",slot=_W,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=450,hitbox=false,aoe=true,cc=true,mcollision=false},
	["LissandraE"]={charName="Lissandra",slot=_E,type="linear",killTime=0,speed=850,range=1050,delay=0.25,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LucianQ"]={charName="Lucian",slot=_Q,type="linear",killTime=0,speed=math.huge,range=900,delay=0.5,radius=65,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LucianW"]={charName="Lucian",slot=_W,type="linear",killTime=0,speed=1600,range=900,delay=0.25,radius=65,hitbox=true,aoe=true,cc=false,mcollision=false},
	["LucianR"]={charName="Lucian",slot=_R,type="linear",killTime=0,speed=2800,range=1200,delay=0.01,radius=75,hitbox=true,aoe=false,cc=false,mcollision=true},
	["LuluQ"]={charName="Lulu",slot=_Q,type="linear",killTime=0,speed=1500,range=925,delay=0.25,radius=45,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LuxLightBinding"]={charName="Lux",slot=_Q,type="linear",killTime=0,speed=1200,range=1175,delay=0.25,radius=60,hitbox=true,aoe=true,cc=true,mcollision=true},
	["LuxLightStrikeKugel"]={charName="Lux",slot=_E,type="circular",killTime=5,speed=1300,range=1000,delay=0.25,radius=350,hitbox=true,aoe=true,cc=true,mcollision=false},
	["LuxMaliceCannon"]={charName="Lux",slot=_R,type="linear",killTime=0,speed=math.huge,range=3340,delay=1,radius=115,hitbox=true,aoe=true,cc=true,mcollision=false},
	["Landslide"]={charName="Malphite",slot=_E,type="circular",killTime=0,speed=math.huge,range=0,delay=0.242,radius=200,hitbox=false,aoe=true,cc=true,mcollision=false},
	["UFSlash"]={charName="Malphite",slot=_R,type="circular",killTime=0,speed=2170,range=1000,delay=0,radius=300,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MalzaharQ"]={charName="Malzahar",slot=_Q,type="rectangle",killTime=0,speed=math.huge,range=900,delay=0.25,radius2=400,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MaokaiQ"]={charName="Maokai",slot=_Q,type="linear",killTime=0,speed=1600,range=600,delay=0.375,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MissFortuneScattershot"]={charName="MissFortune",slot=_E,type="circular",killTime=2,speed=math.huge,range=1000,delay=0.5,radius=400,hitbox=true,aoe=true,cc=true,mcollision=false},
	["MissFortuneBulletTime"]={charName="MissFortune",slot=_R,type="conic",killTime=0,speed=math.huge,range=1400,delay=0.001,radius=40,angle=40,hitbox=false,aoe=true,cc=false,mcollision=false},
	["MordekaiserSiphonOfDestruction"]={charName="Mordekaiser",slot=_E,type="conic",killTime=0,speed=math.huge,range=675,delay=0.25,radius=50,angle=50,hitbox=false,aoe=true,cc=false,mcollision=false},
	["DarkBindingMissile"]={charName="Morgana",slot=_Q,type="linear",killTime=0,speed=1200,range=1175,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["TormentedSoil"]={charName="Morgana",slot=_W,type="circular",killTime=5,speed=math.huge,range=900,delay=0.25,radius=325,hitbox=true,aoe=true,cc=false,mcollision=false},
	["NamiQ"]={charName="Nami",slot=_Q,type="circular",killTime=0,speed=math.huge,range=875,delay=0.95,radius=200,hitbox=true,aoe=true,cc=true,mcollision=false},
	["NamiR"]={charName="Nami",slot=_R,type="linear",killTime=0,speed=850,range=2750,delay=0.5,radius=215,hitbox=true,aoe=true,cc=true,mcollision=false},
	["NasusE"]={charName="Nasus",slot=_E,type="circular",killTime=5,speed=math.huge,range=650,delay=0.25,radius=400,hitbox=true,aoe=true,cc=false,mcollision=false},
	["NautilusAnchorDrag"]={charName="Nautilus",slot=_Q,type="linear",killTime=0,speed=2000,range=1100,delay=0.25,radius=75,hitbox=true,aoe=false,cc=true,mcollision=true},
	["JavelinToss"]={charName="Nidalee",slot=_Q,type="linear",killTime=0,speed=1300,range=1500,delay=0.25,radius=45,hitbox=true,aoe=true,cc=false,mcollision=true},
	["Bushwhack"]={charName="Nidalee",slot=_W,type="circular",killTime=1,speed=math.huge,range=900,delay=0.25,radius=85,hitbox=true,aoe=false,cc=false,mcollision=true},
	["Pounce"]={charName="Nidalee",slot=_W,type="circular",killTime=0,speed=1750,range=750,delay=0.25,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["Swipe"]={charName="Nidalee",slot=_E,type="conic",killTime=0,speed=math.huge,range=300,delay=0.25,radius=180,angle=180,hitbox=false,aoe=true,cc=false,mcollision=false},
	["NocturneDuskbringer"]={charName="Nocturne",slot=_Q,type="linear",killTime=0,speed=1600,range=1200,delay=0.25,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["AbsoluteZero"]={charName="Nunu",slot=_R,type="circular",killTime=3,speed=math.huge,range=0,delay=0.01,radius=650,hitbox=false,aoe=true,cc=true,mcollision=false},
	["OlafAxeThrowCast"]={charName="Olaf",slot=_Q,type="linear",killTime=0,speed=1550,range=1000,delay=0.25,radius=80,hitbox=true,aoe=true,cc=true,mcollision=false},
	["OrianaIzunaCommand"]={charName="Orianna",slot=_Q,type="linear",killTime=0,speed=1400,range=825,delay=0.25,radius=175,hitbox=true,aoe=true,cc=false,mcollision=false},
	["OrianaDissonanceCommand"]={charName="Orianna",slot=_W,type="circular",killTime=0,proj="OrianaDissonanceCommand-",speed=math.huge,range=0,delay=0.25,radius=250,hitbox=false,aoe=true,cc=true,mcollision=false},
	["OrianaRedactCommand"]={charName="Orianna",slot=_E,type="linear",killTime=0,proj="orianaredact",speed=1400,range=1100,delay=0.25,radius=55,hitbox=true,aoe=true,cc=false,mcollision=false},
	["OrianaDetonateCommand"]={charName="Orianna",slot=_R,type="circular",killTime=0,proj="OrianaDetonateCommand-",speed=math.huge,range=0,delay=0.5,radius=325,hitbox=false,aoe=true,cc=true,mcollision=false},
	["OrnnQ"]={charName="Ornn",slot=_Q,type="linear",killTime=0,speed=2000,range=800,delay=0.3,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["OrnnW"]={charName="Ornn",slot=_W,type="linear",killTime=0,speed=math.huge,range=550,delay=0.25,radius=110,hitbox=true,aoe=true,cc=false,mcollision=false},
	["OrnnE"]={charName="Ornn",slot=_E,type="linear",killTime=0,speed=1780,range=800,delay=0.35,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["OrnnR"]={charName="Ornn",slot=_R,type="linear",killTime=0,speed=1200,range=2500,delay=0.5,radius=225,hitbox=true,aoe=true,cc=true,mcollision=false},
	["PantheonE"]={charName="Pantheon",slot=_E,type="conic",killTime=0,speed=math.huge,range=0,delay=0.389,radius=80,angle=80,hitbox=false,aoe=true,cc=false,mcollision=false},
	["PantheonRFall"]={charName="Pantheon",slot=_R,type="circular",killTime=2.5,speed=math.huge,range=5500,delay=0.25,radius=700,hitbox=true,aoe=true,cc=true,mcollision=false},
	["PoppyQSpell"]={charName="Poppy",slot=_Q,type="linear",killTime=0,speed=math.huge,range=430,delay=1.32,radius=85,hitbox=true,aoe=true,cc=true,mcollision=false},
	["PoppyRSpell"]={charName="Poppy",slot=_R,type="linear",killTime=0,speed=1600,range=1900,delay=0.6,radius=80,hitbox=true,aoe=true,cc=true,mcollision=false},
	["QuinnQ"]={charName="Quinn",slot=_Q,type="linear",killTime=0,speed=1550,range=1025,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["RakanQ"]={charName="Rakan",slot=_Q,type="linear",killTime=0,speed=1800,range=900,delay=0.25,radius=60,hitbox=true,aoe=false,cc=false,mcollision=true},
	["RakanW"]={charName="Rakan",slot=_W,type="circular",killTime=0,speed=2150,range=600,delay=0,radius=250,hitbox=true,aoe=true,cc=false,mcollision=false},
	["RekSaiQBurrowed"]={charName="RekSai",slot=_Q,type="linear",killTime=0,speed=2100,range=1650,delay=0.125,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["RenektonCleave"]={charName="Renekton",slot=_Q,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=325,hitbox=false,aoe=true,cc=false,mcollision=false},
	["RenektonSliceAndDice"]={charName="Renekton",slot=_E,type="linear",killTime=0,speed=1125,range=450,delay=0.25,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["RengarW"]={charName="Rengar",slot=_W,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=450,hitbox=false,aoe=true,cc=false,mcollision=false},
	["RengarE"]={charName="Rengar",slot=_E,type="linear",killTime=0,speed=1500,range=1000,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["RivenMartyr"]={charName="Riven",slot=_W,type="circular",killTime=0,speed=math.huge,range=0,delay=0.267,radius=135,hitbox=false,aoe=true,cc=true,mcollision=false},
	["RivenIzunaBlade"]={charName="Riven",slot=_R,type="conic",killTime=0,speed=1600,range=900,delay=0.25,radius=50,angle=50,hitbox=true,aoe=true,cc=false,mcollision=false},
	["RumbleGrenade"]={charName="Rumble",slot=_E,type="linear",killTime=0,speed=2000,range=850,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=true},
	["RumbleCarpetBombDummy"]={charName="Rumble",slot=_R,type="rectangle",killTime=0,speed=1600,range=1700,delay=0.583,radius=130,hitbox=true,aoe=true,cc=true,mcollision=false},
	["RyzeQ"]={charName="Ryze",slot=_Q,type="linear",killTime=0,speed=1700,range=1000,delay=0.25,radius=50,hitbox=true,aoe=false,cc=false,mcollision=true},
	["SejuaniQ"]={charName="Sejuani",slot=_Q,type="linear",killTime=0,speed=1300,range=650,delay=0.25,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SejuaniW"]={charName="Sejuani",slot=_W,type="conic",killTime=0,speed=math.huge,range=600,delay=0.25,radius=75,angle=75,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SejuaniR"]={charName="Sejuani",slot=_R,type="linear",killTime=0,speed=1650,range=1300,delay=0.25,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ShenE"]={charName="Shen",slot=_E,type="linear",killTime=0,speed=1200,range=600,delay=0,radius=60,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ShyvanaFireball"]={charName="Shyvana",slot=_E,type="linear",killTime=0,speed=1575,range=925,delay=0.25,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ShyvanaTransformLeap"]={charName="Shyvana",slot=_R,type="linear",killTime=0,speed=1130,range=850,delay=0.25,radius=160,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ShyvanaFireballDragon2"]={charName="Shyvana",slot=_E,type="linear",killTime=0,speed=1575,range=925,delay=0.333,radius=60,hitbox=true,aoe=true,cc=false,mcollision=false},
	["MegaAdhesive"]={charName="Singed",slot=_W,type="circular",killTime=3,speed=math.huge,range=1000,delay=0.25,radius=265,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SionQ"]={charName="Sion",slot=_Q,type="linear",killTime=2,speed=math.huge,range=600,delay=0,radius=300,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SionE"]={charName="Sion",slot=_E,type="linear",killTime=0,speed=1900,range=725,delay=0.25,radius=80,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SivirQ"]={charName="Sivir",slot=_Q,type="linear",killTime=0,speed=1350,range=1250,delay=0.25,radius=75,hitbox=true,aoe=true,cc=false,mcollision=false},
	["SkarnerVirulentSlash"]={charName="Skarner",slot=_Q,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["SkarnerFracture"]={charName="Skarner",slot=_E,type="linear",killTime=0,speed=1500,range=1000,delay=0.25,radius=70,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SonaR"]={charName="Sona",slot=_R,type="linear",killTime=0,speed=2250,range=900,delay=0.25,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SorakaQ"]={charName="Soraka",slot=_Q,type="circular",killTime=0,speed=1150,range=800,delay=0.25,radius=235,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SorakaE"]={charName="Soraka",slot=_E,type="circular",killTime=1.5,speed=math.huge,range=925,delay=0.25,radius=300,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SwainQ"]={charName="Swain",slot=_Q,type="conic",killTime=0,speed=math.huge,range=725,delay=0.25,radius=45,angle=45,hitbox=false,aoe=true,cc=false,mcollision=false},
	["SwainW"]={charName="Swain",slot=_W,type="circular",killTime=1.5,speed=math.huge,range=3500,delay=0.25,radius=325,hitbox=false,aoe=true,cc=false,mcollision=false},
	["SwainE"]={charName="Swain",slot=_E,type="linear",killTime=0,speed=1550,range=850,delay=0.25,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SyndraQ"]={charName="Syndra",slot=_Q,type="circular",killTime=0,speed=math.huge,range=800,delay=0.625,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["SyndraWCast"]={charName="Syndra",slot=_W,type="circular",killTime=0,speed=1450,range=950,delay=0.25,radius=225,hitbox=true,aoe=true,cc=true,mcollision=false},
	["SyndraE"]={charName="Syndra",slot=_E,type="conic",killTime=0,speed=2500,range=700,delay=0.25,radius=40,angle=40,hitbox=false,aoe=true,cc=true,mcollision=false},
	["SyndraEMissile"]={charName="Syndra",slot=_E,type="linear",killTime=0,speed=1600,range=1250,delay=0.25,radius=50,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TahmKenchQ"]={charName="TahmKench",slot=_Q,type="linear",killTime=0,speed=2670,range=800,delay=0.25,radius=70,hitbox=true,aoe=false,cc=true,mcollision=true},
	["TaliyahQ"]={charName="Taliyah",slot=_Q,type="linear",killTime=0,speed=2850,range=1000,delay=0.25,radius=100,hitbox=true,aoe=false,cc=false,mcollision=true},
	["TaliyahWVC"]={charName="Taliyah",slot=_W,type="circular",killTime=0,speed=math.huge,range=900,delay=0.6,radius=150,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TaliyahE"]={charName="Taliyah",slot=_E,type="conic",killTime=0,speed=2000,range=800,delay=0.25,radius=80,angle=80,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TalonW"]={charName="Talon",slot=_W,type="conic",killTime=0,speed=1850,range=650,delay=0.25,radius=35,angle=35,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TalonR"]={charName="Talon",slot=_R,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=550,hitbox=false,aoe=true,cc=false,mcollision=false},
	["TeemoRCast"]={charName="Teemo",slot=_R,type="circular",killTime=2,speed=math.huge,range=900,delay=1.25,radius=200,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ThreshQ"]={charName="Thresh",slot=_Q,type="linear",killTime=0,speed=1900,range=1100,delay=0.5,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["ThreshEFlay"]={charName="Thresh",slot=_E,type="linear",killTime=0,proj="ThreshEMissile1",speed=math.huge,range=400,delay=0.389,radius=95,hitbox=false,aoe=true,cc=true,mcollision=false},
	["TristanaW"]={charName="Tristana",slot=_W,type="circular",killTime=0,speed=1100,range=900,delay=0.25,radius=250,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TrundleCircle"]={charName="Trundle",slot=_E,type="circular",killTime=0,speed=math.huge,range=1000,delay=0.25,radius=375,hitbox=true,aoe=true,cc=true,mcollision=false},
	["TryndamereE"]={charName="Tryndamere",slot=_E,type="linear",killTime=0,speed=1300,range=660,delay=0,radius=225,hitbox=true,aoe=true,cc=false,mcollision=false},
	["WildCards"]={charName="TwistedFate",slot=_Q,type="linear",killTime=0,speed=1000,range=1450,delay=0.25,radius=35,hitbox=true,aoe=true,cc=false,mcollision=false},
	["TwitchVenomCask"]={charName="Twitch",slot=_W,type="circular",killTime=0,speed=1400,range=950,delay=0.25,radius=340,hitbox=true,aoe=true,cc=true,mcollision=false},
	["UrgotQ"]={charName="Urgot",slot=_Q,type="circular",killTime=0,speed=math.huge,range=800,delay=0.6,radius=215,hitbox=true,aoe=true,cc=true,mcollision=false},
	["UrgotE"]={charName="Urgot",slot=_E,type="linear",killTime=0,speed=1050,range=475,delay=0.45,radius=100,hitbox=true,aoe=true,cc=true,mcollision=false},
	["UrgotR"]={charName="Urgot",slot=_R,type="linear",killTime=0,speed=3200,range=1600,delay=0.4,radius=70,hitbox=true,aoe=false,cc=true,mcollision=false},
	["VarusQ"]={charName="Varus",slot=_Q,type="linear",killTime=0,speed=1850,range=1625,delay=0,radius=40,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VarusE"]={charName="Varus",slot=_E,type="circular",killTime=0,speed=1500,range=925,delay=0.242,radius=280,hitbox=true,aoe=true,cc=true,mcollision=false},
	["VarusR"]={charName="Varus",slot=_R,type="linear",killTime=0,speed=1850,range=1075,delay=0.242,radius=120,hitbox=true,aoe=true,cc=true,mcollision=false},
	["VayneTumble"]={charName="Vayne",slot=_Q,type="linear",killTime=0,speed=900,range=300,delay=0.25,radius=45,hitbox=true,aoe=false,cc=false,mcollision=false},
	["VeigarBalefulStrike"]={charName="Veigar",slot=_Q,type="linear",killTime=0,speed=2000,range=950,delay=0.25,radius=60,hitbox=true,aoe=true,cc=false,mcollision=true},
	["VeigarDarkMatter"]={charName="Veigar",slot=_W,type="circular",killTime=0,speed=math.huge,range=900,delay=1.25,radius=225,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VeigarEventHorizon"]={charName="Veigar",slot=_E,type="annular",killTime=3.5,speed=math.huge,range=700,delay=0.75,radius=375,hitbox=true,aoe=true,cc=true,mcollision=false},
	["VelKozQ"]={charName="VelKoz",slot=_Q,type="linear",killTime=0,speed=1235,range=1050,delay=0.251,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["VelkozQMissileSplit"]={charName="VelKoz",slot=_Q,type="linear",killTime=0,proj="VelkozQMissileSplit",speed=2100,range=1050,delay=0.251,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["VelKozW"]={charName="VelKoz",slot=_W,type="linear",killTime=0,speed=1500,range=1050,delay=0.25,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VelKozE"]={charName="VelKoz",slot=_E,type="circular",killTime=0,speed=math.huge,range=850,delay=0.75,radius=235,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ViQ"]={charName="Vi",slot=_Q,type="linear",killTime=0,speed=1400,range=725,delay=0,radius=55,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ViktorGravitonField"]={charName="Viktor",slot=_W,type="circular",killTime=0,speed=math.huge,range=700,delay=1.333,radius=290,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ViktorDeathRay"]={charName="Viktor",slot=_E,type="linear",killTime=0,speed=1350,range=1025,delay=0,radius=80,hitbox=true,aoe=true,cc=false,mcollision=false},
	["VladimirHemoplague"]={charName="Vladimir",slot=_R,type="circular",speed=math.huge,range=700,delay=0.389,radius=350,hitbox=true,aoe=true,cc=false,mcollision=true},
	["WarwickR"]={charName="Warwick",slot=_R,type="linear",killTime=0,speed=1800,range=3000,delay=0.1,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XayahQ"]={charName="Xayah",slot=_Q,type="linear",killTime=0,speed=2075,range=1100,delay=0.5,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XayahE"]={charName="Xayah",slot=_E,type="linear",killTime=0.25,speed=5700,range=2000,delay=0,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XayahR"]={charName="Xayah",slot=_R,type="conic",killTime=0,speed=4400,range=1100,delay=1.5,radius=40,angle=40,hitbox=false,aoe=true,cc=false,mcollision=false},
	["XerathArcanopulse2"]={charName="Xerath",slot=_Q,type="linear",killTime=0,speed=math.huge,range=1400,delay=0.5,radius=75,hitbox=false,aoe=true,cc=false,mcollision=false},
	["XerathArcaneBarrage2"]={charName="Xerath",slot=_W,type="circular",killTime=0,speed=math.huge,range=1100,delay=0.5,radius=235,hitbox=true,aoe=true,cc=true,mcollision=false},
	["XerathMageSpearMissile"]={charName="Xerath",slot=_E,type="linear",killTime=0,speed=1350,range=1050,delay=0.25,radius=60,hitbox=true,aoe=false,cc=true,mcollision=true},
	["XerathRMissileWrapper"]={charName="Xerath",slot=_R,type="circular",killTime=0,speed=math.huge,range=6160,delay=0.6,radius=200,hitbox=true,aoe=true,cc=false,mcollision=false},
	["XinZhaoW"]={charName="XinZhao",slot=_W,type="conic",killTime=0.25,speed=math.huge,range=125,delay=0,radius=180,angle=180,hitbox=false,aoe=true,cc=false,mcollision=false},
	["XinZhaoW"]={charName="XinZhao",slot=_W,type="linear",killTime=0,speed=math.huge,range=900,delay=0.5,radius=45,hitbox=true,aoe=true,cc=true,mcollision=false},
	["XinZhaoR"]={charName="XinZhao",slot=_R,type="circular",killTime=0,speed=math.huge,range=0,delay=0.325,radius=550,hitbox=false,aoe=true,cc=true,mcollision=false},
	["YasuoQ"]={charName="Yasuo",slot=_Q,type="linear",killTime=0,speed=math.huge,range=475,delay=0.339,radius=45,hitbox=true,aoe=true,cc=false,mcollision=false},
	["YasuoQ3"]={charName="Yasuo",slot=_Q,type="linear",killTime=0,speed=1500,range=1000,delay=0.339,radius=75,hitbox=true,aoe=true,cc=true,mcollision=false},
	["YorickW"]={charName="Yorick",slot=_W,type="annular",killTime=4,speed=math.huge,range=600,delay=0.25,radius=300,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZacQ"]={charName="Zac",slot=_Q,type="linear",killTime=0,speed=math.huge,range=800,delay=0.33,radius=85,hitbox=true,aoe=true,cc=true,mcollision=true},
	["ZacW"]={charName="Zac",slot=_W,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=350,hitbox=false,aoe=true,cc=false,mcollision=false},
	["ZacE"]={charName="Zac",slot=_E,type="circular",killTime=0,speed=1330,range=1800,delay=0,radius=300,hitbox=false,aoe=true,cc=true,mcollision=false},
	["ZacR"]={charName="Zac",slot=_R,type="circular",killTime=2.5,speed=math.huge,range=1000,delay=0,radius=300,hitbox=false,aoe=true,cc=true,mcollision=false},
	["ZedQ"]={charName="Zed",slot=_Q,type="linear",killTime=0,speed=1700,range=900,delay=0.25,radius=50,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZedW"]={charName="Zed",slot=_W,type="linear",killTime=0,speed=1750,range=650,delay=0.25,radius=40,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZedE"]={charName="Zed",slot=_E,type="circular",killTime=0,speed=math.huge,range=0,delay=0.25,radius=290,hitbox=false,aoe=true,cc=true,mcollision=false},
	["ZiggsQSpell"]={charName="Ziggs",slot=_Q,type="circular",killTime=0,speed=1700,range=1400,delay=0.5,radius=180,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZiggsQSpell2"]={charName="Ziggs",slot=_Q,type="circular",killTime=0,speed=1700,range=1400,delay=0.47,radius=180,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZiggsQSpell3"]={charName="Ziggs",slot=_Q,type="circular",killTime=0,speed=1700,range=1400,delay=0.44,radius=180,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZiggsW"]={charName="Ziggs",slot=_W,type="circular",killTime=4,speed=2000,range=1000,delay=0.25,radius=325,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZiggsE"]={charName="Ziggs",slot=_E,type="circular",killTime=2,speed=1800,range=900,delay=0.25,radius=325,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZiggsR"]={charName="Ziggs",slot=_R,type="circular",killTime=0,speed=1500,range=5300,delay=0.375,radius=550,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZileanQ"]={charName="Zilean",slot=_Q,type="circular",killTime=3,speed=2050,range=900,delay=0.25,radius=180,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZoeQ"]={charName="Zoe",slot=_Q,type="linear",killTime=0,speed=1280,range=800,delay=0.25,radius=40,hitbox=true,aoe=false,cc=false,mcollision=true},
	["ZoeQRecast"]={charName="Zoe",slot=_Q,type="linear",killTime=0,speed=2370,range=1600,delay=0,radius=40,hitbox=true,aoe=false,cc=false,mcollision=true},
	["ZoeE"]={charName="Zoe",slot=_E,type="linear",killTime=0,speed=1950,range=800,delay=0.3,radius=55,hitbox=true,aoe=false,cc=true,mcollision=true},
	["ZyraQ"]={charName="Zyra",slot=_Q,type="rectangle",killTime=0,speed=math.huge,range=800,delay=0.625,radius2=400,radius=100,hitbox=true,aoe=true,cc=false,mcollision=false},
	["ZyraE"]={charName="Zyra",slot=_E,type="linear",killTime=0,speed=1150,range=1100,delay=0.25,radius=60,hitbox=true,aoe=true,cc=true,mcollision=false},
	["ZyraR"]={charName="Zyra",slot=_R,type="circular",killTime=0,speed=math.huge,range=700,delay=1.775,radius=575,hitbox=true,aoe=true,cc=true,mcollision=false},
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
        self.obj[s.spell.name] = s
		DelayAction(function() self.obj[s.spell.name] = nil end,s.spell.range/s.spell.speed - s.spell.delay)
end

function SimpleEvade:Tickp()
	heroes[myHero.networkID] = nil
	for _,i in pairs(self.obj) do
		if i.o and i.spell.type == "linear" and GetDistance(myHero,i.o) >= 6200 and not self.globalults[_] then return end
		if i.p and i.spell.type == "circular" and GetDistance(myHero,i.p.endPos) >= 6200 and not self.globalults[_] then return end
		if i.p and i.spell.type == "conic" and GetDistance(myHero,i.p.endPos) >= 6200 and not self.globalults[_] then return end
		if i.p and i.spell.type == "rectangular" and GetDistance(myHero,i.p.endPos) >= 6200 and not self.globalults[_] then return end
		if not i.jp or not i.safe then
			self.asd = false
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

function SimpleEvade:Drawp()
	for _,i in pairs(self.obj) do
		if i.o and i.spell.type == "linear" and GetDistance(myHero,i.o) >= 3000 and not self.globalults[_] then return end
		if i.p and i.spell.type == "circular" and GetDistance(myHero,i.p.endPos) >= 3000 and not self.globalults[_] then return end
		if i.p and i.spell.type == "conic" and GetDistance(myHero,i.p.endPos) >= 3000 and not self.globalults[_] then return end
		if i.p and i.spell.type == "rectangular" and GetDistance(myHero,i.p.endPos) >= 3000 and not self.globalults[_] then return end
		if i.o then
			i.p = {}
			i.p.startPos = Vector(i.o.startPos)
			i.p.endPos = Vector(i.o.endPos)
		end
		if i.p then
			if i.spell.type ~= ("circular" or "annular") then self.endposs = Vector(i.p.startPos)+Vector(Vector(i.p.endPos)-i.p.startPos):normalized()*i.spell.range end
			self.opos = self:sObjpos(_,i)
			self:Drawings(_,i)
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
				local vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,Vector(p))
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
				local vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,Vector(p))
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
				local vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,Vector(p.obj))
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
		return i.p.startPos+Vector(Vector(self.endposs)-i.p.startPos):normalized()*(i.spell.speed*(os.clock()-i.startTime) + (i.spell.radius+myHero.boundingRadius)/2)
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
return Vector(myHero) + Vector(Vector(self.mV) - myHero.pos):normalized() * myHero.ms/2
end

function SimpleEvade:prwp(unit, wp)
  if wp and unit == myHero and wp.index == 1 then
	self.mV = wp.position
  end
end

function SimpleEvade:CleanObj(_,i)
	if i.o and not i.o.valid and i.spell.type ~= "circular" then
		self.obj[_] = nil
	elseif i.spell.type == "circular" and i.spell.killTime then
		DelayAction(function() self.obj[_] = nil end, i.spell.killTime + GetDistance(i.caster,i.p.endPos))
	end
end

function SimpleEvade:Mpos(_,i)
	if i.spell.type == "circular" then 
		if i.p and GetDistance(myHero,i.p.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs = GetMousePos()
			end
		else
			self.mposs = nil
			i.mpos = nil
		end
	elseif i.spell.type == "linear" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs2 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs2 = GetMousePos()
			end	
		else
			self.mposs2 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "rectangular" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs3 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs3 = GetMousePos()
			end	
		else
			self.mposs3 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "conic" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs4 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs4 = GetMousePos()
			end	
		else
			self.mposs4 = nil
			i.mpos = nil
		end
	end
end

function SimpleEvade:UDodge(_,i)
	if not i.uDodge then
		if i.safe and i.spell.type == "linear" then
			if GetDistance(self.opos)/i.spell.speed + i.spell.delay < GetDistance(i.safe)/myHero.ms then 
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
				i.p.endPos = Vector(self.endposs)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.endposs) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,v3)
				local jp2 = Vector(VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).x,i.p.endPos.y,VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).y)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
					if GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular2(),jp2) then
						self.asd = true
						self.patha = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.patha) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					else
						self.asd = true
						self.patha = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.patha) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					end
				else
					self.asd = false
					self.patha = nil
					self.patha2 = nil
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
				self.asd = true
				self.pathb = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				if not MapPosition:inWall(self.pathb) then
						i.safe = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					else
						i.safe = i.p.endPos + Vector(self.pathb-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				end
				i.isEvading = true
			else
				self.asd = false
				self.pathb = nil
				self.pathb2 = nil
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
					self.asd = true
					self.pathc = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if not MapPosition:inWall(self.pathc) then
							i.safe = Vector(myHero)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe =  Vector(myHero)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
					i.isEvading = true
				end
			else
				self.asd = false
				self.pathc = nil
				i.isEvading = false
				DisableHoldPosition(false)
				DisableAll(false)
			end
		elseif i.spell.type == "conic" then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.endposs)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.endposs) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(i.p.startPos,i.p.endPos,v3)
				local jp2 = Vector(VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).x,i.p.endPos.y,VectorIntersection(i.p.startPos,i.p.endPos,myHero.pos+(Vector(i.p.startPos)-Vector(i.p.endPos)):perpendicular(),myHero.pos).y)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
					if GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.p.startPos-i.p.endPos):perpendicular2(),jp2) then
						self.asd = true
						self.patha = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.patha) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					else
						self.asd = true
						self.patha = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.patha) then
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.p.startPos - i.p.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					end
				else
					self.asd = false
					self.patha = nil
					self.patha2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			end
		end
	else
		if i.spell.type == "linear" and i.p then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.endposs)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.endposs) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,v3)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
					self.asd = true
					self.patha = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					self.patha2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular(),i.jp) then
						if not MapPosition:inWall(self.patha2) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					else
						if not MapPosition:inWall(self.patha) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else 
							i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					end
					i.isEvading = true
				else
					self.asd = false
					self.patha = nil
					self.patha2 = nil
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
				self.asd = true
				self.pathb = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				self.pathb2 = Vector(i.p.endPos) + (Vector(i.mpos) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
				if self.mposs and GetDistance(self.mposs,self.pathb) > GetDistance(self.mposs,self.pathb2) then
					if not MapPosition:inWall(self.pathb2) then
							i.safe = Vector(i.p.endPos) + (Vector(i.mpos) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe = i.p.endPos + Vector(self.pathb2-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
				else
					if not MapPosition:inWall(self.pathb) then
							i.safe = Vector(i.p.endPos) + (GetOrigin(myHero) - Vector(i.p.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe = i.p.endPos + Vector(self.pathb-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
				end
				i.isEvading = true
			else
				self.asd = false
				self.pathb = nil
				self.pathb2 = nil
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
					self.asd = true
					self.pathc = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					self.pathc2 = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if GetDistance(Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular(),i.jp) then
						if not MapPosition:inWall(self.pathc2) then
								i.safe = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else
								i.safe = i.p.endPos + Vector(self.pathc-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					else
						if not MapPosition:inWall(self.pathc) then
								i.safe = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else
								i.safe = i.p.endPos + Vector(self.pathc-i.p.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end					
					end
					i.isEvading = true
				end
			else
				self.asd = false
				self.pathc = nil
				i.isEvading = false
				DisableHoldPosition(false)
				DisableAll(false)
			end
		elseif i.spell.type == "conic" then
				i.p.startPos = Vector(i.p.startPos)
				i.p.endPos = Vector(self.endposs)
			if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(self.endposs) < i.spell.range + myHero.boundingRadius then
				local v3 = Vector(myHero)
				local jp = VectorPointProjectionOnLineSegment(i.p.startPos,i.p.endPos,v3)
				i.jp = jp
				if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
					self.asd = true
					self.patha = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					self.patha2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular(),i.jp) then
						if not MapPosition:inWall(self.patha2) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					else
						if not MapPosition:inWall(self.patha) then
							i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else 
							i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.p.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
					end
					i.isEvading = true
				else
					self.asd = false
					self.patha = nil
					self.patha2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			end
		end
	end
end

function SimpleEvade:Drawings(_,i)
	if i.spell.type == "linear" then
		local sPos = Vector(self.opos)
		local ePos = Vector(self.endposs)
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
		DrawCone(i.p.startPos,Vector(self.endposs),i.spell.angle or 40,1,ARGB(255,255,255,255))
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

function SimpleEvade:Dodge(_,i)
	if myHero.isSpellShielded then return end
	if i.safe then
		if self.asd == true then 
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

function SimpleEvade:BlockMov(order)
	for _,i in pairs(self.obj) do
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
			if not self.obj[obj.spellName] and self.Spells[obj.spellName] and (l.proj == obj.spellName or _ == obj.spellName or obj.spellName:lower():find(_:lower()) or obj.spellName:lower():find(l.proj:lower())) then
				if not self.obj[obj.spellName] then self.obj[obj.spellName] = {} end
				self.obj[obj.spellName].o = obj
				self.obj[obj.spellName].caster = obj.spellOwner
				self.obj[obj.spellName].mpos = nil
				self.obj[obj.spellName].uDodge = nil
				self.obj[obj.spellName].startTime = os.clock()
				self.obj[obj.spellName].spell = l
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
		for _,l in pairs(self.Spells) do
			if not self.obj[spellProc.name] and self.Spells[spellProc.name] and _ == spellProc.name then
				if not self.obj[spellProc.name] then self.obj[spellProc.name] = {} end
				self.obj[spellProc.name].p = spellProc
				self.obj[spellProc.name].spell = l
				self.obj[spellProc.name].caster = unit
				self.obj[spellProc.name].mpos = nil
				self.obj[spellProc.name].uDodge = nil
				self.obj[spellProc.name].startTime = os.clock()+l.delay
				self.obj[spellProc.name].TarE = (Vector(spellProc.endPos) - Vector(unit.pos)):normalized()*l.range
				if l.killTime and l.type == "circular" then
					DelayAction(function() self.obj[spellProc.name] = nil end, l.killTime + GetDistance(unit,spellProc.endPos)/l.speed + l.delay)
				elseif l.killTime > 0 and l.type ~= "circular" then
					DelayAction(function() self.obj[spellProc.name] = nil end, l.killTime + 1.3*GetDistance(myHero.pos,spellProc.startPos)/l.speed+l.delay)
				else
					DelayAction(function() self.obj[spellProc.name] = nil end, l.range/l.speed + l.delay/2)
				end
			elseif l.killName == spellProc.name then
				self.obj[_] = nil				
			end
		end
	end
end

function SimpleEvade:DeleteObject(obj)
	if obj and obj.isSpell and self.obj[obj.spellName] and self.Spells[obj.spellName].type ~= "circular" then
			self.obj[obj.spellName] = nil
	end	
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		self.YasuoWall[obj.spellName] = nil
	end
end
