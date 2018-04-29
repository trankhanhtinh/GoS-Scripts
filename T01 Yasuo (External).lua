
--  _______  _______  ____     __   __  _______  _______  __   __  _______ 
-- |       ||  _    ||    |   |  | |  ||   _   ||       ||  | |  ||       |
-- |_     _|| | |   | |   |   |  |_|  ||  |_|  ||  _____||  | |  ||   _   |
--   |   |  | | |   | |   |   |       ||       || |_____ |  |_|  ||  | |  |
--   |   |  | |_|   | |   |   |_     _||       ||_____  ||       ||  |_|  |
--   |   |  |       | |   |     |   |  |   _   | _____| ||       ||       |
--   |___|  |_______| |___|     |___|  |__| |__||_______||_______||_______|
--
-- Current version: 1.0.1
-- ===============
-- == Changelog ==
-- ===============
-- 1.0.1
-- + Added offensive items usage
-- 1.0
-- + Initial release

require "Eternal Prediction"
require "HPred"
require "TPred"

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

function GetBestLinearFarmPos(range, width)
	local BestPos = nil
	local MostHit = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy and not m.dead then
			local EndPos = myHero.pos + (m.pos - myHero.pos):Normalized() * range
			local Count = MinionsOnLine(myHero.pos, EndPos, width, 300-myHero.team)
			if Count > MostHit then
				MostHit = Count
				BestPos = m.pos
			end
		end
	end
	return BestPos, MostHit
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

function GetHeroByHandle(handle)
	for i = 1, Game.HeroCount() do
		local hr = Game.Hero(i)
		if hr.handle == handle then
			return hr
		end
	end
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
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	else
		return _G.GOS:GetTarget(range,"AD")
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

function IsImmobile(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 18 or buff.type == 22 or buff.type == 24 or buff.type == 28 or buff.type == 29 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false
end

function IsKnocked(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 29 or buff.type == 30 or buff.type == 31) and buff.count > 0 then
			return true
		end
	end
	return false
end

function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function MinionsOnLine(startpos, endpos, width, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == team and not m.dead then
			local w = width + m.boundingRadius
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startpos, endpos, m.pos)
			if isOnSegment and GetDistanceSqr(pointSegment, m.pos) < w^2 and GetDistanceSqr(startpos, endpos) > GetDistanceSqr(startpos, m.pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function Mode()
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return "LaneClear"
		end
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

class "Yasuo"

local HeroIcon = "https://www.mobafire.com/images/avatars/yasuo-classic.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e5/Steel_Tempest.png"
local Q3Icon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/4/4b/Steel_Tempest_3.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/6/61/Wind_Wall.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/f/f8/Sweeping_Blade.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/c/c6/Last_Breath.png"
local ETravel = true

function Yasuo:Menu()
	self.YasuoMenu = MenuElement({type = MENU, id = "Yasuo", name = "[GoS-U] Yasuo", leftIcon = HeroIcon})
	self.YasuoMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.YasuoMenu.Auto:MenuElement({id = "UseQ", name = "Use Q [Steel Tempest]", value = true, leftIcon = QIcon})
	self.YasuoMenu.Auto:MenuElement({id = "UseQ3", name = "Use Q3 [Gathering Storm]", value = true, leftIcon = Q3Icon})
	
	self.YasuoMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.YasuoMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Steel Tempest]", value = true, leftIcon = QIcon})
	self.YasuoMenu.Combo:MenuElement({id = "UseQ3", name = "Use Q3 [Gathering Storm]", value = true, leftIcon = Q3Icon})
	self.YasuoMenu.Combo:MenuElement({id = "UseW", name = "Use W [Wind Wall]", value = true, leftIcon = WIcon})
	self.YasuoMenu.Combo:MenuElement({id = "UseE", name = "Use E [Sweeping Blade]", value = true, leftIcon = EIcon})
	self.YasuoMenu.Combo:MenuElement({id = "UseR", name = "Use R [Last Breath]", value = true, leftIcon = RIcon})
	self.YasuoMenu.Combo:MenuElement({id = "X", name = "Minimum Enemies: R", value = 1, min = 0, max = 5, step = 1})
	self.YasuoMenu.Combo:MenuElement({id = "HP", name = "HP-Manager: R", value = 40, min = 0, max = 100, step = 5})
	
	self.YasuoMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.YasuoMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Steel Tempest]", value = true, leftIcon = QIcon})
	self.YasuoMenu.Harass:MenuElement({id = "UseQ3", name = "Use Q3 [Gathering Storm]", value = true, leftIcon = Q3Icon})
	self.YasuoMenu.Harass:MenuElement({id = "UseW", name = "Use W [Wind Wall]", value = true, leftIcon = WIcon})
	self.YasuoMenu.Harass:MenuElement({id = "UseE", name = "Use E [Sweeping Blade]", value = true, leftIcon = EIcon})
	
	self.YasuoMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.YasuoMenu.KillSteal:MenuElement({id = "UseR", name = "Use R [Last Breath]", value = true, leftIcon = RIcon})

	self.YasuoMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.YasuoMenu.LaneClear:MenuElement({id = "UseQ", name = "Use Q [Steel Tempest]", value = true, leftIcon = QIcon})
	self.YasuoMenu.LaneClear:MenuElement({id = "UseQ3", name = "Use Q3 [Gathering Storm]", value = true, leftIcon = Q3Icon})
	self.YasuoMenu.LaneClear:MenuElement({id = "UseE", name = "Use E [Sweeping Blade]", value = false, leftIcon = EIcon})
	
	self.YasuoMenu:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
	self.YasuoMenu.LastHit:MenuElement({id = "UseE", name = "Use E [Sweeping Blade]", value = true, leftIcon = EIcon})
	
	self.YasuoMenu:MenuElement({id = "AntiGapcloser", name = "Anti-Gapcloser", type = MENU})
	self.YasuoMenu.AntiGapcloser:MenuElement({id = "UseQ3", name = "Use Q3 [Gathering Storm]", value = true, leftIcon = Q3Icon})
	self.YasuoMenu.AntiGapcloser:MenuElement({id = "Distance", name = "Distance: Q3", value = 400, min = 25, max = 500, step = 25})
	
	self.YasuoMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.YasuoMenu.HitChance:MenuElement({id = "HPredHit", name = "HitChance: HPrediction", value = 1, min = 1, max = 5, step = 1})
	self.YasuoMenu.HitChance:MenuElement({id = "TPredHit", name = "HitChance: TPrediction", value = 1, min = 0, max = 5, step = 1})
	
	self.YasuoMenu:MenuElement({id = "Prediction", name = "Prediction", type = MENU})
	self.YasuoMenu.Prediction:MenuElement({id = "PredictionQ", name = "Prediction: Q", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.YasuoMenu.Prediction:MenuElement({id = "PredictionQ3", name = "Prediction: Q3", drop = {"HPrediction", "TPrediction"}, value = 2})
	
	self.YasuoMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.YasuoMenu.Drawings:MenuElement({id = "DrawQE", name = "Draw QE Range", value = true})
	self.YasuoMenu.Drawings:MenuElement({id = "DrawQ3", name = "Draw Q3 Range", value = true})
	self.YasuoMenu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.YasuoMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	self.YasuoMenu.Drawings:MenuElement({id = "DrawAA", name = "Draw Killable AAs", value = true})
	self.YasuoMenu.Drawings:MenuElement({id = "DrawJng", name = "Draw Jungler Info", value = true})
	
	self.YasuoMenu:MenuElement({id = "Items", name = "Items", type = MENU})
	self.YasuoMenu.Items:MenuElement({id = "UseBC", name = "Use Bilgewater Cutlass", value = true})
	self.YasuoMenu.Items:MenuElement({id = "UseBOTRK", name = "Use BOTRK", value = true})
	self.YasuoMenu.Items:MenuElement({id = "UseHG", name = "Use Hextech Gunblade", value = true})
	self.YasuoMenu.Items:MenuElement({id = "UseMS", name = "Use Mercurial Scimitar", value = true})
	self.YasuoMenu.Items:MenuElement({id = "UseQS", name = "Use Quicksilver Sash", value = true})
	self.YasuoMenu.Items:MenuElement({id = "OI", name = "%HP To Use Offensive Items", value = 35, min = 0, max = 100, step = 5})
end

function Yasuo:Spells()
	YasuoQ = {speed = math.huge, range = 475, delay = 0.25, width = 40, collision = false, aoe = true, type = "line"}
	YasuoQPred = Prediction:SetSpell(YasuoQ, TYPE_LINE, true)
	YasuoQ3 = {speed = 1200, range = 1000, delay = 0.25, width = 90, collision = false, aoe = true, type = "line"}
	YasuoQ3Pred = Prediction:SetSpell(YasuoQ3, TYPE_LINE, true)
	YasuoW = {range = 400}
	YasuoE = {range = 475}
	YasuoR = {range = 1400}
end

function Yasuo:__init()
	Item_HK = {}
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Yasuo:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	target = GetTarget(1400)
	Item_HK[ITEM_1] = HK_ITEM_1
	Item_HK[ITEM_2] = HK_ITEM_2
	Item_HK[ITEM_3] = HK_ITEM_3
	Item_HK[ITEM_4] = HK_ITEM_4
	Item_HK[ITEM_5] = HK_ITEM_5
	Item_HK[ITEM_6] = HK_ITEM_6
	Item_HK[ITEM_7] = HK_ITEM_7
	self:Items1()
	self:Items2()
	self:Auto()
	self:Combo()
	self:Harass()
	self:KillSteal()
	self:LaneClear()
	self:LastHit()
	self:AntiGapcloser()
end

function Yasuo:Items1()
	if EnemiesAround(myHero, 1000) >= 1 then
		if (target.health / target.maxHealth)*100 <= self.YasuoMenu.Items.OI:Value() then
			if self.YasuoMenu.Items.UseBC:Value() then
				if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then
					if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
						Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
					end
				end
			end
			if self.YasuoMenu.Items.UseBOTRK:Value() then
				if GetItemSlot(myHero, 3153) > 0 and ValidTarget(target, 550) then
					if myHero:GetSpellData(GetItemSlot(myHero, 3153)).currentCd == 0 then
						Control.CastSpell(Item_HK[GetItemSlot(myHero, 3153)], target)
					end
				end
			end
			if self.YasuoMenu.Items.UseHG:Value() then
				if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then
					if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
						Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
					end
				end
			end
		end
	end
end

function Yasuo:Items2()
	if self.YasuoMenu.Items.UseMS:Value() then
		if GetItemSlot(myHero, 3139) > 0 then
			if myHero:GetSpellData(GetItemSlot(myHero, 3139)).currentCd == 0 then
				if IsImmobile(myHero) then
					Control.CastSpell(Item_HK[GetItemSlot(myHero, 3139)], myHero)
				end
			end
		end
	end
	if self.YasuoMenu.Items.UseQS:Value() then
		if GetItemSlot(myHero, 3140) > 0 then
			if myHero:GetSpellData(GetItemSlot(myHero, 3140)).currentCd == 0 then
				if IsImmobile(myHero) then
					Control.CastSpell(Item_HK[GetItemSlot(myHero, 3140)], myHero)
				end
			end
		end
	end
end

function Yasuo:Draw()
	if myHero.dead then return end
	if self.YasuoMenu.Drawings.DrawQE:Value() then Draw.Circle(myHero.pos, YasuoQ.range, 1, Draw.Color(255, 0, 191, 255)) end
	if self.YasuoMenu.Drawings.DrawQ3:Value() then Draw.Circle(myHero.pos, YasuoQ3.range, 1, Draw.Color(255, 65, 105, 225)) end
	if self.YasuoMenu.Drawings.DrawW:Value() then Draw.Circle(myHero.pos, YasuoW.range, 1, Draw.Color(255, 30, 144, 255)) end
	if self.YasuoMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, YasuoR.range, 1, Draw.Color(255, 0, 0, 255)) end
	for i, enemy in pairs(GetEnemyHeroes()) do
		if self.YasuoMenu.Drawings.DrawJng:Value() then
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
		if self.YasuoMenu.Drawings.DrawAA:Value() then
			if ValidTarget(enemy) then
				AALeft = enemy.health / myHero.totalDamage
				Draw.Text("AA Left: "..tostring(math.ceil(AALeft)), 17, enemy.pos2D.x-38, enemy.pos2D.y+10, Draw.Color(0xFF00BFFF))
			end
		end
	end
end

function Yasuo:UseQ(target)
	if self.YasuoMenu.Prediction.PredictionQ:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, YasuoQ.range, YasuoQ.delay, YasuoQ.speed, YasuoQ.width, self.YasuoMenu.HitChance.HPredHit:Value(), YasuoQ.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, YasuoQ.range) then
			Control.CastSpell(HK_Q, aimPosition)
			Control.SetCursorPos(aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, YasuoQ.range, YasuoQ.delay, YasuoQ.speed, YasuoQ.width, YasuoQ.collision, self.YasuoMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, YasuoQ.range) then
				Control.SetCursorPos(aimPosition)
				Control.CastSpell(HK_Q, aimPosition)
			end
		end
	elseif self.YasuoMenu.Prediction.PredictionQ:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, YasuoQ.delay, YasuoQ.width, YasuoQ.range, YasuoQ.speed, myHero.pos, YasuoQ.collision, YasuoQ.type)
		if (HitChance >= self.YasuoMenu.HitChance.TPredHit:Value() ) then
			Control.SetCursorPos(castpos)
			Control.CastSpell(HK_Q, castpos)
		end
	end
end

function Yasuo:UseQ3(target)
	if self.YasuoMenu.Prediction.PredictionQ3:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, YasuoQ3.range, YasuoQ3.delay, YasuoQ3.speed, YasuoQ3.width, self.YasuoMenu.HitChance.HPredHit:Value(), YasuoQ3.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, YasuoQ3.range) then
			Control.CastSpell(HK_Q, aimPosition)
			Control.SetCursorPos(aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, YasuoQ3.range, YasuoQ3.delay, YasuoQ3.speed, YasuoQ3.width, YasuoQ3.collision, self.YasuoMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, YasuoQ3.range) then
				Control.SetCursorPos(aimPosition)
				Control.CastSpell(HK_Q, aimPosition)
			end
		end
	elseif self.YasuoMenu.Prediction.PredictionQ3:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, YasuoQ3.delay, YasuoQ3.width, YasuoQ3.range, YasuoQ3.speed, myHero.pos, YasuoQ3.collision, YasuoQ3.type)
		if (HitChance >= self.YasuoMenu.HitChance.TPredHit:Value() ) then
			Control.SetCursorPos(castpos)
			Control.CastSpell(HK_Q, castpos)
		end
	end
end

function Yasuo:Auto()
	if target == nil then return end
	if IsReady(_Q) then
		if self.YasuoMenu.Auto.UseQ:Value() then
			if GotBuff(myHero, "YasuoQ3W") == 0 then
				if ValidTarget(target, YasuoQ.range) then
					self:UseQ(target)
				end
			end
		end
		if self.YasuoMenu.Auto.UseQ3:Value() then
			if GotBuff(myHero, "YasuoQ3W") > 0 and ETravel then
				if ValidTarget(target, YasuoQ3.range) then
					self:UseQ3(target)
				end
			end
		end
	end
end

function Yasuo:Combo()
	if target == nil then return end
	if Mode() == "Combo" then
		if self.YasuoMenu.Combo.UseQ:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if GotBuff(myHero, "YasuoQ3W") == 0 then
					if ValidTarget(target, YasuoQ.range) then
						self:UseQ(target)
					end
				end
			end
		end
		if self.YasuoMenu.Combo.UseQ3:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if GotBuff(myHero, "YasuoQ3W") > 0 and ETravel then
					if ValidTarget(target, YasuoQ3.range) then
						self:UseQ3(target)
					end
				end
			end
		end
		if self.YasuoMenu.Combo.UseE:Value() then
			if IsReady(_E) then
				if GetDistance(target.pos) < YasuoE.range and GetDistance(target.pos) > myHero.range then
					if GotBuff(target, "YasuoDashWrapper") == 0 then
						Control.SetCursorPos(target)
						Control.CastSpell(HK_E, target)
					end
				elseif GetDistance(target.pos) < YasuoE.range+1300 and GetDistance(target.pos) > myHero.range then
					for i = 1, Game.MinionCount() do
						local minion = Game.Minion(i)
						if minion and minion.isEnemy then
							if GetDistance(minion.pos) <= YasuoE.range and GotBuff(minion, "YasuoDashWrapper") == 0 then
								local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(myHero.pos, target.pos, minion.pos)
								if isOnSegment and GetDistance(pointSegment, minion.pos) < 300 then
									Control.SetCursorPos(minion)
									Control.CastSpell(HK_E, minion)
									ETravel = false
									DelayAction(function() ETravel = true end, 0.61)
								end
							end
						end
					end
				end
			end
		end
		if self.YasuoMenu.Combo.UseR:Value() then
			if IsReady(_R) then
				if ValidTarget(target, YasuoR.range) and IsKnocked(target) then
					if GetPercentHP(target) < self.YasuoMenu.Combo.HP:Value() then
						if EnemiesAround(myHero, YasuoR.range) >= self.YasuoMenu.Combo.X:Value() then
							Control.CastSpell(HK_R, target)
						end
					end
				end
			end
		end
	end
end

function Yasuo:Harass()
	if target == nil then return end
	if Mode() == "Harass" then
		if self.YasuoMenu.Harass.UseQ:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if GotBuff(myHero, "YasuoQ3W") == 0 then
					if ValidTarget(target, YasuoQ.range) then
						self:UseQ(target)
					end
				end
			end
		end
		if self.YasuoMenu.Harass.UseQ3:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if GotBuff(myHero, "YasuoQ3W") > 0 and ETravel then
					if ValidTarget(target, YasuoQ3.range) then
						self:UseQ3(target)
					end
				end
			end
		end
		if self.YasuoMenu.Harass.UseE:Value() then
			if IsReady(_E) then
				if GetDistance(target.pos) < YasuoE.range and GetDistance(target.pos) > myHero.range then
					if GotBuff(target, "YasuoDashWrapper") == 0 then
						Control.SetCursorPos(target)
						Control.CastSpell(HK_E, target)
					end
				elseif GetDistance(target.pos) < YasuoE.range+1300 and GetDistance(target.pos) > myHero.range then
					for i = 1, Game.MinionCount() do
						local minion = Game.Minion(i)
						if minion and minion.isEnemy then
							if GetDistance(minion.pos) <= YasuoE.range and GotBuff(minion, "YasuoDashWrapper") == 0 then
								local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(myHero.pos, target.pos, minion.pos)
								if isOnSegment and GetDistance(pointSegment, minion.pos) < 300 then
									Control.SetCursorPos(minion)
									Control.CastSpell(HK_E, minion)
									ETravel = false
									DelayAction(function() ETravel = true end, 0.61)
								end
							end
						end
					end
				end
			end
		end
	end
end

function Yasuo:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_R) then
			if self.YasuoMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, YasuoR.range) and IsKnocked(enemy) then
					local YasuoRDmg = (({200, 300, 400})[myHero:GetSpellData(_R).level] + 1.5 * myHero.bonusDamage)
					if (enemy.health + enemy.hpRegen * 6 + enemy.armor) < YasuoRDmg then
						Control.CastSpell(HK_R, target)
					end
				end
			end
		end
	end
end

function Yasuo:LaneClear()
	if Mode() == "LaneClear" then
		if self.YasuoMenu.LaneClear.UseQ3:Value() then
			if IsReady(_Q) and GotBuff(myHero, "YasuoQ3W") > 0 then
				local BestPos, BestHit = GetBestLinearFarmPos(YasuoQ3.range, YasuoQ3.width)
				if BestPos and BestHit >= 3 then
					Control.SetCursorPos(BestPos)
					Control.CastSpell(HK_Q, BestPos)
				end
			end
		end
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.isEnemy then
				if self.YasuoMenu.LaneClear.UseQ:Value() then
					if IsReady(_Q) and GotBuff(myHero, "YasuoQ3W") == 0 then
						if ValidTarget(minion, YasuoQ.range) then
							Control.SetCursorPos(minion)
							Control.CastSpell(HK_Q, minion)
						end
					end
				end
				if self.YasuoMenu.LaneClear.UseE:Value() then
					if IsReady(_E) then
						if ValidTarget(minion, YasuoE.range) then
							Control.SetCursorPos(minion)
							Control.CastSpell(HK_E, minion)
						end
					end
				end
			end
		end
	end
end

function Yasuo:LastHit()
	if Mode() == "LaneClear" then
		if self.YasuoMenu.LastHit.UseE:Value() then
			if IsReady(_E) then
				for i = 1, Game.MinionCount() do
					local minion = Game.Minion(i)
					if minion and minion.isEnemy then
						if GotBuff(minion, "YasuoDashWrapper") == 0 then
							local YasuoEDmg = ((({60, 70, 80, 90, 100})[myHero:GetSpellData(_E).level]) + 0.2 * myHero.bonusDamage)
							if minion.health < YasuoEDmg then
								Control.SetCursorPos(minion)
								Control.CastSpell(HK_E, minion)
							end
						end
					end
				end
			end
		end
	end
end

function Yasuo:AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if IsReady(_Q) and GotBuff(myHero, "YasuoQ3W") > 0 then
			if self.YasuoMenu.AntiGapcloser.UseQ3:Value() then
				if ValidTarget(antigap, self.YasuoMenu.AntiGapcloser.Distance:Value()) then
					self:UseQ3(antigap)
				end
			end
		end
	end
end

function OnLoad()
	Yasuo()
end