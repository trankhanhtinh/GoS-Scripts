--
-- __________________  ____   ____  __.       __               .__               
-- \__    ___/\   _  \/_   | |    |/ _|____ _/  |______ _______|__| ____ _____   
--   |    |   /  /_\  \|   | |      < \__  \\   __\__  \\_  __ \  |/    \\__  \  
--   |    |   \  \_/   \   | |    |  \ / __ \|  |  / __ \|  | \/  |   |  \/ __ \_
--   |____|    \_____  /___| |____|__ (____  /__| (____  /__|  |__|___|  (____  /
--                   \/              \/    \/          \/              \/     \/ 
--
-- Current version: 1.0.1
-- ===============
-- == Changelog ==
-- ===============
-- 1.0.1
-- + Optimized code
-- 1.0
-- + Initial release

if FileExist(COMMON_PATH .. "HPred.lua") then
	require 'HPred'
else
	PrintChat("HPred.lua missing!")
end
if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
else
	PrintChat("TPred.lua missing!")
end

function CalcMagicalDamage(source, target, amount)
	local mr = target.magicResist
	local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)
	if mr < 0 then
		value = 2 - 100 / (100 - mr)
	elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
		value = 1
	end
	return math.max(0, math.floor(value * amount))
end

function DisableAll()
	if _G.SDK then
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
	else
		GOS.BlockMovement = true
		GOS.BlockAttack = true
	end
end

function EnemiesAround(pos, range)
	local N = 0
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if ValidTarget(hero,range + hero.boundingRadius) and hero.isEnemy and not hero.dead then
			N = N + 1
		end
	end
	return N
end

function GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myHero.pos
	local dx = Pos1.x - Pos2.x
	local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return dx^2 + dz^2
end

function GetDistance(Pos1, Pos2)
	return math.sqrt(GetDistanceSqr(Pos1, Pos2))
end

function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function GetItemSlot(unit, id)
	for i = ITEM_1, ITEM_7 do
		if unit:GetItemData(i).itemID == id then
			return i
		end
	end
	return 0
end

function GetPercentHP(unit)
	return 100*unit.health/unit.maxHealth
end

function GetTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	else
		return _G.GOS:GetTarget(range,"AP")
	end
end

function GotBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff.count
		end
	end
	return 0
end

function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Mode()
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
	elseif _G.gsoSDK then
		return _G.gsoSDK.Orbwalker:GetMode()
	else
		return GOS.GetMode()
	end
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end

class "Katarina"

local HeroIcon = "http://ddragon.leagueoflegends.com/cdn/8.10.1/img/champion/Katarina.png"
local IgniteIcon = "http://pm1.narvii.com/5792/0ce6cda7883a814a1a1e93efa05184543982a1e4_hq.jpg"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/eb/Bouncing_Blade.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/aa/Preparation.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/7/72/Shunpo.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/b/ba/Voracity.png"
local Daggers = {}
local IS = {}

function Katarina:Menu()
	self.KatarinaMenu = MenuElement({type = MENU, id = "Katarina", name = "[T01] Katarina", leftIcon = HeroIcon})
	self.KatarinaMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.KatarinaMenu.Auto:MenuElement({id = "UseQ", name = "Use Q [Bouncing Blade]", value = true, leftIcon = QIcon})
	
	self.KatarinaMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.KatarinaMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Bouncing Blade]", value = true, leftIcon = QIcon})
	self.KatarinaMenu.Combo:MenuElement({id = "UseW", name = "Use W [Preparation]", value = true, leftIcon = WIcon})
	self.KatarinaMenu.Combo:MenuElement({id = "UseE", name = "Use E [Shunpo]", value = true, leftIcon = EIcon})
	self.KatarinaMenu.Combo:MenuElement({id = "UseR", name = "Use R [Death Lotus]", value = true, leftIcon = RIcon})
	self.KatarinaMenu.Combo:MenuElement({id = "ModeE", name = "Cast Mode: E", drop = {"Enemy", "Dagger"}, value = 2})
	self.KatarinaMenu.Combo:MenuElement({id = "X", name = "Minimum Enemies: R", value = 1, min = 0, max = 5, step = 1})
	self.KatarinaMenu.Combo:MenuElement({id = "HP", name = "HP-Manager: R", value = 40, min = 0, max = 100, step = 5})
	
	self.KatarinaMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.KatarinaMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Bouncing Blade]", value = true, leftIcon = QIcon})
	self.KatarinaMenu.Harass:MenuElement({id = "UseW", name = "Use W [Preparation]", value = true, leftIcon = WIcon})
	self.KatarinaMenu.Harass:MenuElement({id = "UseE", name = "Use E [Shunpo]", value = true, leftIcon = EIcon})
	self.KatarinaMenu.Harass:MenuElement({id = "ModeE", name = "Cast Mode: E", drop = {"Enemy", "Dagger"}, value = 1})
	
	self.KatarinaMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.KatarinaMenu.KillSteal:MenuElement({id = "UseQ", name = "Use Q [Bouncing Blade]", value = false, leftIcon = QIcon})
	self.KatarinaMenu.KillSteal:MenuElement({id = "UseE", name = "Use E [Shunpo]", value = true, leftIcon = EIcon})
	self.KatarinaMenu.KillSteal:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true, leftIcon = IgniteIcon})
	
	self.KatarinaMenu:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
	self.KatarinaMenu.LastHit:MenuElement({id = "UseQ", name = "Use Q [Bouncing Blade]", value = true, leftIcon = QIcon})
	
	self.KatarinaMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.KatarinaMenu.LaneClear:MenuElement({id = "UseQ", name = "Use Q [Bouncing Blade]", value = false, leftIcon = QIcon})
	self.KatarinaMenu.LaneClear:MenuElement({id = "UseE", name = "Use E [Shunpo]", value = false, leftIcon = EIcon})
	
	self.KatarinaMenu:MenuElement({id = "Dodge", name = "Dodge", type = MENU})
	self.KatarinaMenu.Dodge:MenuElement({id = "UseE", name = "Use E [Shunpo]", value = true, leftIcon = EIcon})
	
	self.KatarinaMenu:MenuElement({id = "Flee", name = "Flee", type = MENU})
	self.KatarinaMenu.Flee:MenuElement({id = "UseW", name = "Use W [Preparation]", value = true, leftIcon = QIcon})
	self.KatarinaMenu.Flee:MenuElement({id = "UseE", name = "Use E [Shunpo]", value = true, leftIcon = EIcon})
	
	self.KatarinaMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.KatarinaMenu.HitChance:MenuElement({id = "HPredHit", name = "HitChance: HPrediction", value = 1, min = 1, max = 5, step = 1})
	self.KatarinaMenu.HitChance:MenuElement({id = "TPredHit", name = "HitChance: TPrediction", value = 1, min = 0, max = 5, step = 1})
	
	self.KatarinaMenu:MenuElement({id = "Prediction", name = "Prediction", type = MENU})
	self.KatarinaMenu.Prediction:MenuElement({id = "PredictionE", name = "Prediction: E", drop = {"HPrediction", "TPrediction"}, value = 2})
	
	self.KatarinaMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.KatarinaMenu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.KatarinaMenu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.KatarinaMenu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	self.KatarinaMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	self.KatarinaMenu.Drawings:MenuElement({id = "DrawTD", name = "Draw Killable Enemy", value = false})
	self.KatarinaMenu.Drawings:MenuElement({id = "DrawJng", name = "Draw Jungler Info", value = true})
	
	self.KatarinaMenu:MenuElement({id = "Items", name = "Items", type = MENU})
	self.KatarinaMenu.Items:MenuElement({id = "UseBC", name = "Use Bilgewater Cutlass", value = true})
	self.KatarinaMenu.Items:MenuElement({id = "UseHG", name = "Use Hextech Gunblade", value = true})
	self.KatarinaMenu.Items:MenuElement({id = "OI", name = "%HP To Use Offensive Items", value = 35, min = 0, max = 100, step = 5})
end

function Katarina:Spells()
	KatarinaQ = {range = 625}
	KatarinaW = {range = 340}
	KatarinaE = {speed = math.huge, range = 725, delay = 0.15, width = 100, collision = false, aoe = true, type = "circular"}
	KatarinaR = {range = 550}
end

function Katarina:__init()
	Counter = 0
	TotalDmg = 0
	Item_HK = {}
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Katarina:Tick()
	if myHero.dead then return end
	target = GetTarget(1000)
	Item_HK[ITEM_1] = HK_ITEM_1
	Item_HK[ITEM_2] = HK_ITEM_2
	Item_HK[ITEM_3] = HK_ITEM_3
	Item_HK[ITEM_4] = HK_ITEM_4
	Item_HK[ITEM_5] = HK_ITEM_5
	Item_HK[ITEM_6] = HK_ITEM_6
	Item_HK[ITEM_7] = HK_ITEM_7
	self:Calc()
	if GotBuff(myHero, "katarinarsound") == 0 then
		self:Auto()
		self:KillSteal()
		if Mode() == "Combo" then
			self:Combo()
		elseif Mode() == "Harass" then
			self:Harass()
		elseif Mode() == "Clear" then
			self:LaneClear()
			self:LastHit()
		elseif Mode() == "Flee" then
			self:Flee()
		end
	end
end

local Spells = {
	["Alistar"] = {"Pulverize"},
	["Amumu"] = {"BandageToss", "CurseoftheSadMummy"},
	["Annie"] = {"InfernalGuardian"},
	["Ashe"] = {"EnchantedCrystalArrow"},
	["AurelionSol"] = {"AurelionSolR"},
	["Bard"] = {"BardR"},
	["Blitzcrank"] = {"RocketGrab", "StaticField"},
	["Braum"] = {"BraumR"},
	["CassiopeiaR"] = {"CassiopeiaR"},
	["Draven"] = {"DravenRCast"},
	["EvelynnR"] = {"EvelynnR"},
	["Ekko"] = {"EkkoR"},
	["Ezreal"] = {"EzrealTrueshotBarrage"},
	["Fizz"] = {"FizzR"},
	["Galio"] = {"GalioR"},
	["Gangplank"] = {"GangplankR"},
	["Gnar"] = {"GnarR"},
	["Gragas"] = {"GragasR"},
	["Graves"] = {"GravesChargeShot"},
	["Hecarim"] = {"HecarimUlt"},
	["Illaoi"] = {"IllaoiR"},
	["Irelia"] = {"IreliaR"},
	["Jinx"] = {"JinxR"},
	["Kassadin"] = {"Riftwalk"},
	["Katarina"] = {"KatarinaR"},
	["Leona"] = {"LeonaSolarFlare"},
	["Lux"] = {"LuxMaliceCannonMis"},
	["MissFortune"] = {"MissFortuneBulletTime"},
	["Nami"] = {"NamiRMissile"},
	["Nautilus"] = {"NautilusAnchorDragMissile"},
	["Nunu"] = {"AbsoluteZero"},
	["Orianna"] = {"OrianaDetonateCommand"},
	["Ornn"] = {"OrnnRCharge"},
	["Pantheon"] = {"PantheonRFall"},
	["Riven"] = {"RivenIzunaBlade"},
	["Sejuani"] = {"SejuaniR"},
	["Shyvana"] = {"ShyvanaTransformLeap"},
	["Urgot"] = {"UrgotR"},
	["Varus"] = {"VarusR"},
	["Zac"] = {"ZacR"},
	["Ziggs"] = {"ZiggsR"},
	["Zyra"] = {"ZyraR"},
}

function Katarina:Calc()
	if self.KatarinaMenu.Drawings.DrawTD:Value() then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if myHero.levelData.lvl >= 0 and myHero.levelData.lvl <= 5 then
				DaggerDmg = CalcMagicalDamage(myHero, enemy, ((({[1]=68,[2]=72,[3]=77,[4]=82,[5]=89,[6]=96,[7]=103,[8]=112,[9]=121,[10]=131,[11]=142,[12]=154,[13]=166,[14]=180,[15]=194,[16]=208,[17]=224,[18]=240})[myHero.levelData.lvl]) + myHero.bonusDamage + 0.55 * myHero.ap))
			elseif myHero.levelData.lvl >= 6 and myHero.levelData.lvl <= 10 then
				DaggerDmg = CalcMagicalDamage(myHero, enemy, ((({[1]=68,[2]=72,[3]=77,[4]=82,[5]=89,[6]=96,[7]=103,[8]=112,[9]=121,[10]=131,[11]=142,[12]=154,[13]=166,[14]=180,[15]=194,[16]=208,[17]=224,[18]=240})[myHero.levelData.lvl]) + myHero.bonusDamage + 0.7 * myHero.ap))
			elseif myHero.levelData.lvl >= 11 and myHero.levelData.lvl <= 15 then
				DaggerDmg = CalcMagicalDamage(myHero, enemy, ((({[1]=68,[2]=72,[3]=77,[4]=82,[5]=89,[6]=96,[7]=103,[8]=112,[9]=121,[10]=131,[11]=142,[12]=154,[13]=166,[14]=180,[15]=194,[16]=208,[17]=224,[18]=240})[myHero.levelData.lvl]) + myHero.bonusDamage + 0.85 * myHero.ap))
			elseif myHero.levelData.lvl >= 16 and myHero.levelData.lvl <= 18 then
				DaggerDmg = CalcMagicalDamage(myHero, enemy, ((({[1]=68,[2]=72,[3]=77,[4]=82,[5]=89,[6]=96,[7]=103,[8]=112,[9]=121,[10]=131,[11]=142,[12]=154,[13]=166,[14]=180,[15]=194,[16]=208,[17]=224,[18]=240})[myHero.levelData.lvl]) + myHero.bonusDamage + myHero.ap))
			end
			if myHero:GetSpellData(_Q).level > 0 then
				QDmg = CalcMagicalDamage(myHero, enemy, ((({75, 105, 135, 165, 195})[myHero:GetSpellData(_Q).level]) + 0.3 * myHero.ap))
			else
				QDmg = 0
			end
			if myHero:GetSpellData(_E).level > 0 then
				EDmg = CalcMagicalDamage(myHero, enemy, ((({15, 30, 45, 60, 75})[myHero:GetSpellData(_E).level]) + 0.5 * myHero.totalDamage + 0.25 * myHero.ap))
			else
				EDmg = 0
			end
			if myHero:GetSpellData(_R).level > 0 then
				RDmg = CalcMagicalDamage(myHero, enemy, ((({375, 562.5, 750})[myHero:GetSpellData(_R).level]) + 3.3 * myHero.bonusDamage + 2.85 * myHero.ap))
			else
				RDmg = 0
			end
			if IsReady(_Q) and IsReady(_W) and IsReady(_E) and IsReady(_R) then
				TotalDmg = 2*DaggerDmg+QDmg+EDmg+RDmg
			elseif IsReady(_W) and IsReady(_E) and IsReady(_R) then
				TotalDmg = DaggerDmg+EDmg+RDmg
			elseif IsReady(_Q) and IsReady(_E) and IsReady(_R) then
				TotalDmg = QDmg+DaggerDmg+EDmg+RDmg
			elseif IsReady(_Q) and IsReady(_W) and IsReady(_R) then
				TotalDmg = QDmg+2*DaggerDmg+RDmg
			elseif IsReady(_Q) and IsReady(_W) and IsReady(_E) then
				TotalDmg = QDmg+2*DaggerDmg+EDmg
			elseif IsReady(_E) and IsReady(_R) then
				TotalDmg = EDmg+RDmg
			elseif IsReady(_W) and IsReady(_R) then
				TotalDmg = DaggerDmg+RDmg
			elseif IsReady(_Q) and IsReady(_R) then
				TotalDmg = QDmg+DaggerDmg+RDmg
			elseif IsReady(_W) and IsReady(_E) then
				TotalDmg = DaggerDmg+EDmg
			elseif IsReady(_Q) and IsReady(_E) then
				TotalDmg = QDmg+DaggerDmg+EDmg
			elseif IsReady(_Q) and IsReady(_W) then
				TotalDmg = QDmg+2*DaggerDmg
			elseif IsReady(_Q) then
				TotalDmg = QDmg+DaggerDmg
			elseif IsReady(_W) then
				TotalDmg = DaggerDmg
			elseif IsReady(_E) then
				TotalDmg = EDmg
			elseif IsReady(_R) then
				TotalDmg = RDmg
			end
		end
	end
	if self.KatarinaMenu.Dodge.UseE:Value() then
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i);
			if hero.isEnemy then
				if hero.activeSpell.valid and hero.activeSpell.width > 0 and hero.activeSpell.range > 0 then
					local t = Spells[hero.charName]
					if t then
						for j = 1, #t do
							if hero.activeSpell.name == t[j] then
								if hero.activeSpell.speed > 0 then
									if IS[hero.networkID] == nil then
										IS[hero.networkID] = {
										startPos = hero.activeSpell.startPos, 
										endPos = hero.activeSpell.startPos+Vector(hero.activeSpell.startPos,hero.activeSpell.placementPos):Normalized()*hero.activeSpell.range, 
										radius = hero.activeSpell.width, 
										speed = hero.activeSpell.speed, 
										startTime = hero.activeSpell.startTime
										}
									end
								else
									if IS[hero.networkID] == nil then
										IS[hero.networkID] = {
										startPos = hero.activeSpell.startPos, 
										endPos = hero.activeSpell.startPos+Vector(hero.activeSpell.startPos,hero.activeSpell.placementPos):Normalized()*hero.activeSpell.range, 
										radius = hero.activeSpell.width, 
										speed = 9999, 
										startTime = hero.activeSpell.startTime
										}
									end
								end
							end
						end
					end
				end
			end
		end
		for key, v in pairs(IS) do
			local SpellHit = v.startPos+Vector(v.startPos,v.endPos):Normalized()*GetDistance(myHero.pos,v.startPos)
			local SpellPosition = v.startPos+Vector(v.startPos,v.endPos):Normalized()*(v.speed*(Game.Timer()-v.startTime)*3)
			local Dodge = SpellPosition + Vector(v.startPos,v.endPos):Normalized()*(v.speed*0.1)
			if GetDistanceSqr(SpellHit,SpellPosition) <= GetDistanceSqr(Dodge,SpellPosition) and GetDistance(SpellHit,v.startPos)-v.radius-myHero.boundingRadius <= GetDistance(v.startPos,v.endPos) then
				if GetDistanceSqr(myHero.pos,SpellHit) < (v.radius+myHero.boundingRadius)^2 then
					if IsReady(_E) then
						for i = 1, Game.MinionCount() do
							local minion = Game.Minion(i)
							if minion and minion.isTargetable then
								if GetDistance(minion.pos, myHero.pos) < KatarinaE.range then
									local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(Vector(v.startPos), Vector(v.endPos), minion.pos)
									if pointLine and GetDistance(pointSegment, minion.pos) > v.radius+minion.boundingRadius then
										Control.CastSpell(HK_E, minion.pos)
									end
								end
							end
						end
					end
				end
			end
			if (GetDistanceSqr(SpellPosition,v.startPos) >= GetDistanceSqr(v.startPos,v.endPos)) then
				IS[key] = nil
			end
		end
	end
end

function Katarina:Draw()
	if myHero.dead then return end
	if self.KatarinaMenu.Drawings.DrawQ:Value() then Draw.Circle(myHero.pos, KatarinaQ.range, 1, Draw.Color(255, 255, 62, 150)) end
	if self.KatarinaMenu.Drawings.DrawW:Value() then Draw.Circle(myHero.pos, KatarinaW.range, 1, Draw.Color(255, 238, 58, 140)) end
	if self.KatarinaMenu.Drawings.DrawE:Value() then Draw.Circle(myHero.pos, KatarinaE.range, 1, Draw.Color(255, 205, 50, 120)) end
	if self.KatarinaMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, KatarinaR.range, 1, Draw.Color(255, 139, 34, 82)) end
	for i, enemy in pairs(GetEnemyHeroes()) do
		if self.KatarinaMenu.Drawings.DrawJng:Value() then
			if enemy:GetSpellData(SUMMONER_1).name == "SummonerSmite" or enemy:GetSpellData(SUMMONER_2).name == "SummonerSmite" then
				Smite = true
			else
				Smite = false
			end
			if Smite then
				if enemy.alive then
					if ValidTarget(enemy) then
						if GetDistance(myHero.pos, enemy.pos) > 3000 then
							Draw.Text("Jungler: Visible", 17, myHero.pos2D.x-45, myHero.pos2D.y+10, Draw.Color(0xFF32CD32))
						else
							Draw.Text("Jungler: Near", 17, myHero.pos2D.x-43, myHero.pos2D.y+10, Draw.Color(0xFFFF0000))
						end
					else
						Draw.Text("Jungler: Invisible", 17, myHero.pos2D.x-55, myHero.pos2D.y+10, Draw.Color(0xFFFFD700))
					end
				else
					Draw.Text("Jungler: Dead", 17, myHero.pos2D.x-45, myHero.pos2D.y+10, Draw.Color(0xFF32CD32))
				end
			end
		end
		if self.KatarinaMenu.Drawings.DrawTD:Value() then
			if ValidTarget(enemy) then
				if enemy.health < TotalDmg then
					Draw.Circle(enemy.pos, 100, 20, Draw.Color(255, 220, 20, 60))
				end
			end
		end
	end
end

function Katarina:UseE(target)
	if self.KatarinaMenu.Prediction.PredictionE:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, KatarinaE.range, KatarinaE.delay, KatarinaE.speed, KatarinaE.width, self.KatarinaMenu.HitChance.HPredHit:Value(), KatarinaE.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, KatarinaE.range) then
			Control.CastSpell(HK_E, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, KatarinaE.range, KatarinaE.delay, KatarinaE.speed, KatarinaE.width, KatarinaE.collision, self.KatarinaMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, KatarinaE.range) then
				Control.CastSpell(HK_E, aimPosition)
			end
		end
	elseif self.KatarinaMenu.Prediction.PredictionE:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, KatarinaE.delay, KatarinaE.width, KatarinaE.range, KatarinaE.speed, myHero.pos, KatarinaE.collision, KatarinaE.type)
		if (HitChance >= self.KatarinaMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_E, castpos)
		end
	end
end

function Katarina:Auto()
	if target == nil then return end
	if self.KatarinaMenu.Auto.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, KatarinaQ.range) then
				Control.CastSpell(HK_Q, target.pos)
			end
		end
	end
end

function Katarina:Combo()
	if target == nil then return end
	if self.KatarinaMenu.Combo.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, KatarinaQ.range) then
				Control.CastSpell(HK_Q, target)
			end
		end
	end
	if self.KatarinaMenu.Combo.UseW:Value() then
		if IsReady(_W) then
			if ValidTarget(target, KatarinaW.range) then
				Control.CastSpell(HK_W)
			end
		end
	end
	if self.KatarinaMenu.Combo.UseE:Value() then
		if IsReady(_E) then
			if ValidTarget(target, KatarinaE.range+KatarinaE.width) then
				if self.KatarinaMenu.Combo.ModeE:Value() == 1 then
					self:UseE(target)
				elseif self.KatarinaMenu.Combo.ModeE:Value() == 2 then
					if Counter + 100 > GetTickCount() then return end
					for i = 0, Game.ObjectCount() do
						local object = Game.Object(i)
						if object and object.name:lower():find("katarina_base_dagger_ground_indicator") then
							local DaggerPos = object.pos
							if GetDistance(target.pos, DaggerPos) < KatarinaW.range then
								Control.CastSpell(HK_E, DaggerPos)
							end
						end
					end
					Counter = GetTickCount()
				end
			end
		end
	end
	if self.KatarinaMenu.Combo.UseR:Value() then
		if IsReady(_R) then
			if ValidTarget(target, KatarinaR.range) then
				if GetPercentHP(target) < self.KatarinaMenu.Combo.HP:Value() then
					if EnemiesAround(myHero, KatarinaR.range) >= self.KatarinaMenu.Combo.X:Value() then
						Control.CastSpell(HK_R)
					end
				end
			end
		end
	end
	if (target.health / target.maxHealth)*100 <= self.KatarinaMenu.Items.OI:Value() then
		if self.KatarinaMenu.Items.UseBC:Value() then
			if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then
				if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
					Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
				end
			end
		end
		if self.KatarinaMenu.Items.UseHG:Value() then
			if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then
				if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
					Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
				end
			end
		end
	end
end

function Katarina:Harass()
	if target == nil then return end
	if self.KatarinaMenu.Harass.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, KatarinaQ.range) then
				Control.CastSpell(HK_Q, target)
			end
		end
	end
	if self.KatarinaMenu.Harass.UseW:Value() then
		if IsReady(_W) then
			if ValidTarget(target, KatarinaW.range) then
				Control.CastSpell(HK_W)
			end
		end
	end
	if self.KatarinaMenu.Harass.UseE:Value() then
		if IsReady(_E) then
			if ValidTarget(target, KatarinaE.range+KatarinaE.width) then
				if self.KatarinaMenu.Harass.ModeE:Value() == 1 then
					self:UseE(target)
				elseif self.KatarinaMenu.Harass.ModeE:Value() == 2 then
					if Counter + 100 > GetTickCount() then return end
					for i = 0, Game.ObjectCount() do
						local object = Game.Object(i)
						if object and object.name:lower():find("katarina_base_dagger_ground_indicator") then
							local DaggerPos = object.pos
							if GetDistance(target.pos, DaggerPos) < KatarinaW.range then
								Control.CastSpell(HK_E, DaggerPos)
							end
						end
					end
					Counter = GetTickCount()
				end
			end
		end
	end
end

function Katarina:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_E) then
			if self.KatarinaMenu.KillSteal.UseE:Value() then
				if ValidTarget(enemy, KatarinaE.range) then
					if enemy.health < EDmg then
						Control.CastSpell(HK_E, enemy)
					end
				end
			end
		elseif IsReady(_Q) then
			if self.KatarinaMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, KatarinaQ.range) then
					if enemy.health < QDmg then
						Control.CastSpell(HK_Q, enemy)
					end
				end
			end
		end
	end
	if self.KatarinaMenu.KillSteal.UseIgnite:Value() then
		local IgniteDmg = (55 + 25 * myHero.levelData.lvl)
		if ValidTarget(enemy, 600) and enemy.health + enemy.shieldAD < IgniteDmg then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and IsReady(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1, enemy)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and IsReady(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2, enemy)
			end
		end
	end
end

function Katarina:LastHit()
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.isEnemy then
			if self.KatarinaMenu.LastHit.UseQ:Value() then
				if IsReady(_Q) and GotBuff(myHero, "katarinarsound") == 0 then
					if ValidTarget(minion, KatarinaQ.range) then
						local KatarinaQDmg = ((({75, 105, 135, 165, 195})[myHero:GetSpellData(_Q).level]) + 0.3 * myHero.ap)
						if minion.health < KatarinaQDmg then
							Control.CastSpell(HK_Q, minion.pos)
						end
					end
				end
			end
		end
	end
end

function Katarina:LaneClear()
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.isEnemy then
			if self.KatarinaMenu.LaneClear.UseQ:Value() then
				if IsReady(_Q) and GotBuff(myHero, "katarinarsound") == 0 then
					if ValidTarget(minion, KatarinaQ.range) then
						Control.CastSpell(HK_Q, minion.pos)
					end
				end
			end
			if self.KatarinaMenu.LaneClear.UseE:Value() then
				if IsReady(_E) and GotBuff(myHero, "katarinarsound") == 0 then
					if ValidTarget(minion, KatarinaE.range) then
						if Counter + 100 > GetTickCount() then return end
						for i = 0, Game.ObjectCount() do
							local object = Game.Object(i)
							if object and object.name:lower():find("katarina_base_dagger_ground_indicator") then
								local DaggerPos = object.pos
								if GetDistance(minion.pos, DaggerPos) < KatarinaW.range then
									Control.CastSpell(HK_E, DaggerPos)
								end
							end
						end
						Counter = GetTickCount()
					end
				end
			end
		end
	end
end

function Katarina:Flee()
	if self.KatarinaMenu.Flee.UseE:Value() then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion then
				if GetDistance(minion.pos) <= KatarinaE.range then
					if IsReady(_E) then
						Control.CastSpell(HK_E, mousendPos)
					elseif IsReady(_W) then
						Control.CastSpell(HK_W)
					end
				end
			end
		end
	end
end

function OnLoad()
	Katarina()
end
