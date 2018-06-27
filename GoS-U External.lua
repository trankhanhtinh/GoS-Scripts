--            ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄               ▄         ▄ 
--           ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌             ▐░▌       ▐░▌
--           ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀              ▐░▌       ▐░▌
--           ▐░▌          ▐░▌       ▐░▌▐░▌                       ▐░▌       ▐░▌
--           ▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌
--           ▐░▌▐░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌
--           ▐░▌ ▀▀▀▀▀▀█░▌▐░▌       ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌
--           ▐░▌       ▐░▌▐░▌       ▐░▌          ▐░▌             ▐░▌       ▐░▌
--           ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌             ▐░█▄▄▄▄▄▄▄█░▌
--           ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌             ▐░░░░░░░░░░░▌
--            ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀               ▀▀▀▀▀▀▀▀▀▀▀
-- ...###.########.##.....##.########.########.########..##....##....###....##.......###..
-- ..##...##........##...##.....##....##.......##.....##.###...##...##.##...##.........##.
-- .##....##.........##.##......##....##.......##.....##.####..##..##...##..##..........##
-- .##....######......###.......##....######...########..##.##.##.##.....##.##..........##
-- .##....##.........##.##......##....##.......##...##...##..####.#########.##..........##
-- ..##...##........##...##.....##....##.......##....##..##...###.##.....##.##.........##.
-- ...###.########.##.....##....##....########.##.....##.##....##.##.....##.########.###..
-- ==================
-- == Introduction ==
-- ==================
-- Current version: 1.0.3 BETA
-- Intermediate GoS script which supports only ADC champions.
-- Features:
-- + Supports Ashe, Ezreal, Jinx, Vayne
-- + 2 choosable predictions (HPrediction, TPrediction),
-- + 3 managers (Enemies-around, Mana, HP),
-- + Configurable casting settings (Auto, Combo, Harass),
-- + Different types of making combat,
-- + Advanced farm logic (LastHit & LaneClear).
-- + Additional Anti-Gapcloser,
-- + Spell range drawings (circular),
-- + Special damage indicator over HP bar of enemy,
-- + Offensive items usage & stacking tear,
-- + Includes GoS-U Utility
-- (Summoner spells & items usage, Auto-LevelUp, killable AA drawings)
-- ==================
-- == Requirements ==
-- ==================
-- + Orbwalker: GoS, IC
-- + Predictions: HPred, TPred
-- ===============
-- == Changelog ==
-- ===============
-- 1.0.3 BETA
-- + Added Kalista
-- 1.0.2.3 BETA
-- + Updated calc damage for Patch 8.13
-- + Improved R spell casting
-- + Minor changes
-- 1.0.2.2 BETA
-- + Fixed menu value check
-- 1.0.2.1 BETA
-- + Improved Jinx's spells logic
-- 1.0.2 BETA
-- + Added Vayne
-- 1.0.1 BETA
-- + Added Ezreal
-- + Fixed spell casting
-- 1.0 BETA
-- + Initial release

if FileExist(COMMON_PATH .. "MapPositionGOS.lua") then
	require 'MapPositionGOS'
else
	PrintChat("MapPositionGOS.lua missing!")
end
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

---------------
-- Functions --
---------------

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

function CalcPhysicalDamage(source, target, amount)
	local ArmorPenPercent = source.armorPenPercent
	local ArmorPenFlat = source.armorPen * (0.6 + (0.4 * (target.levelData.lvl / 18))) 
	local BonusArmorPen = source.bonusArmorPenPercent
	if source.type == Obj_AI_Minion then
		ArmorPenPercent = 1
		ArmorPenFlat = 0
		BonusArmorPen = 1
	elseif source.type == Obj_AI_Turret then
		ArmorPenFlat = 0
		BonusArmorPen = 1
		if source.charName:find("3") or source.charName:find("4") then
			ArmorPenPercent = 0.25
		else
			ArmorPenPercent = 0.7
		end	
		if target.type == Obj_AI_Minion then
			amount = amount * 1.25
			if target.charName:find("MinionSiege") then
				amount = amount * 0.7
			end
			return amount
		end
	end
	local armor = target.armor
	local bonusArmor = target.bonusArmor
	local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)
	if armor < 0 then
		value = 2 - 100 / (100 - armor)
	elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
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

function EnableAll()
	if _G.SDK then
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	else
		GOS.BlockMovement = false
		GOS.BlockAttack = false
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

function GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function GetBestCircularFarmPos(range, radius)
	local BestPos = nil
	local MostHit = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy and not m.dead then
			local Count = MinionsAround(m.pos, radius, 300-myHero.team)
			if Count > MostHit then
				MostHit = Count
				BestPos = m.pos
			end
		end
	end
	return BestPos, MostHit
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

function GetPercentMana(unit)
	return 100*unit.mana/unit.maxMana
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

function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function MinionsAround(pos, range, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == team and not m.dead and GetDistance(pos, m.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
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
			return "Clear"
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

-------------
-- Utility --
-------------

class "GoSuUtility"

function GoSuUtility:__init()
	Callback.Add("Tick", function() self:UtilityTick() end)
	Callback.Add("Draw", function() self:UtilityDraw() end)
	Callback.Add("ProcessRecall", function(unit, recall) self:ProcessRecall(unit, recall) end)
	self:UtilityMenu()
	self.HitTime = 0
	Enemies = {}
	EnemiesData = {}
	Recalling = {}
	Item_HK = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isMe then
			goto A
		end
		if unit.isEnemy then 
			EnemiesData[unit.networkID] = 0
			table.insert(Enemies, unit)
		end
		::A::
	end
	for i = 1, Game.ObjectCount() do
		local object = Game.Object(i)
		if object.isAlly or object.type ~= Obj_AI_SpawnPoint then 
			goto A
		end
		EnemySpawnPos = object
		break
		::A::
	end
end

function GoSuUtility:UtilityMenu()
	self.UMenu = MenuElement({type = MENU, id = "GoSuUtility", name = "[GoS-U] Utility"})
	self.UMenu:MenuElement({id = "BaseUlt", name = "BaseUlt", type = MENU})
	self.UMenu.BaseUlt:MenuElement({id = "BU", name = "Enable BaseUlt", value = true})
	
	self.UMenu:MenuElement({id = "Draws", name = "Draws", type = MENU})
	self.UMenu.Draws:MenuElement({id = "DrawAA", name = "Draw Killable AAs", value = true})
	self.UMenu.Draws:MenuElement({id = "DrawJng", name = "Draw Jungler Info", value = true})
	
	self.UMenu:MenuElement({id = "Items", name = "Items", type = MENU})
	self.UMenu.Items:MenuElement({id = "UseBC", name = "Use Bilgewater Cutlass", value = true})
	self.UMenu.Items:MenuElement({id = "UseBOTRK", name = "Use BOTRK", value = true})
	self.UMenu.Items:MenuElement({id = "UseHG", name = "Use Hextech Gunblade", value = true})
	self.UMenu.Items:MenuElement({id = "UseMS", name = "Use Mercurial Scimitar", value = true})
	self.UMenu.Items:MenuElement({id = "UseQS", name = "Use Quicksilver Sash", value = true})
	self.UMenu.Items:MenuElement({id = "OI", name = "%HP To Use Offensive Items", value = 35, min = 0, max = 100, step = 5})
	
	self.UMenu:MenuElement({id = "SS", name = "Summoner Spells", type = MENU})
	self.UMenu.SS:MenuElement({id = "UseHeal", name = "Use Heal", value = true})
	self.UMenu.SS:MenuElement({id = "UseSave", name = "Save Ally Using Heal", value = true})
	self.UMenu.SS:MenuElement({id = "UseBarrier", name = "Use Barrier", value = true})
	self.UMenu.SS:MenuElement({id = "HealMe", name = "%HP To Use Heal: MyHero", value = 15, min = 0, max = 100, step = 5})
	self.UMenu.SS:MenuElement({id = "HealAlly", name = "%HP To Use Heal: Ally", value = 15, min = 0, max = 100, step = 5})
	self.UMenu.SS:MenuElement({id = "BarrierMe", name = "%HP To Use Barrier", value = 15, min = 0, max = 100, step = 5})
end

function GoSuUtility:UtilityTick()
	target = GetTarget(5000)
	Item_HK[ITEM_1] = HK_ITEM_1
	Item_HK[ITEM_2] = HK_ITEM_2
	Item_HK[ITEM_3] = HK_ITEM_3
	Item_HK[ITEM_4] = HK_ITEM_4
	Item_HK[ITEM_5] = HK_ITEM_5
	Item_HK[ITEM_6] = HK_ITEM_6
	Item_HK[ITEM_7] = HK_ITEM_7
	self:BaseUlt()
	self:Items()
	self:SS()
end

function GoSuUtility:ProcessRecall(unit, recall)
	if not unit.isEnemy then return end
	if recall.isStart then
    	table.insert(Recalling, {object = unit, start = Game.Timer(), duration = (recall.totalTime/1000)})
    else
      	for i, recallunits in pairs(Recalling) do
        	if recallunits.object.networkID == unit.networkID then
          		table.remove(Recalling, i)
        	end
      	end
    end
end

function GetRecallData(unit)
	for i, recall in pairs(Recalling) do
		if recall.object.networkID == unit.networkID then
			return {isRecalling = true, RecallTime = recall.start+recall.duration-Game.Timer()}
		end
	end
	return {isRecalling = false, RecallTime = 0}
end

function GoSuUtility:BaseUlt()
	for i, enemy in pairs(Enemies) do
		if enemy.visible then
			EnemiesData[enemy.networkID] = Game.Timer()
		end
	end
	if not self.UMenu.BaseUlt.BU:Value() or myHero.dead or not IsReady(_R) then return end
	for i, enemy in pairs(Enemies) do
		if enemy.valid and not enemy.dead and GetRecallData(enemy).isRecalling then
			if myHero.charName == "Ashe" then
				local AsheRDmg = CalcMagicalDamage(myHero, enemy, (({200, 400, 600})[myHero:GetSpellData(_R).level] + myHero.ap))
				if AsheRDmg >= (enemy.health + enemy.hpRegen * 20) then
					local Distance = enemy.pos:DistanceTo(EnemySpawnPos.pos)
					local Delay = 0.25
					local Speed = 1600
					local HitTime = Distance / Speed + Delay
					local RecallTime = GetRecallData(enemy).RecallTime
					self.HitTime = HitTime
					if RecallTime - HitTime > 0.1 then return end
					DisableAll()
					local CastPos = myHero.pos-(myHero.pos-EnemySpawnPos.pos):Normalized()*300
					Control.SetCursorPos(CastPos)
					Control.CastSpell(HK_R, CastPos)
					DelayAction(EnableAll,0.3)
					self.HitTime = 0
				end
			elseif myHero.charName == "Ezreal" then
				local EzrealRDmg = (0.3*(({350, 500, 650})[myHero:GetSpellData(_R).level] + myHero.bonusDamage + 0.9 * myHero.ap))
				if EzrealRDmg >= (enemy.health + enemy.hpRegen * 20 + enemy.magicResist) then
					local Distance = enemy.pos:DistanceTo(EnemySpawnPos.pos)
					local Delay = 1
					local Speed = 2000
					local HitTime = Distance / Speed + Delay
					local RecallTime = GetRecallData(enemy).RecallTime
					self.HitTime = HitTime
					if RecallTime - HitTime > 0.1 then return end
					DisableAll()
					local CastPos = myHero.pos-(myHero.pos-EnemySpawnPos.pos):Normalized()*300
					Control.SetCursorPos(CastPos)
					Control.CastSpell(HK_R, CastPos)
					DelayAction(EnableAll,1.05)
					self.HitTime = 0
				end
			elseif myHero.charName == "Jinx" then
				local JinxRDmg = (({250, 350, 450})[myHero:GetSpellData(_R).level] + ({25, 30, 35})[myHero:GetSpellData(_R).level] / 100 * (enemy.maxHealth - enemy.health) + 1.5 * myHero.totalDamage)
				if JinxRDmg >= (enemy.health + enemy.hpRegen * 20 + enemy.armor) then
					local Distance = enemy.pos:DistanceTo(EnemySpawnPos.pos)
					local Delay = 0.6
					local Speed = Distance > 1350 and (2295000 + (Distance - 1350) * 2200) / Distance or 1700
					local HitTime = Distance / Speed + Delay
					local RecallTime = GetRecallData(enemy).RecallTime
					self.HitTime = HitTime
					if RecallTime - HitTime > 0.1 then return end
					DisableAll()
					local CastPos = myHero.pos-(myHero.pos-EnemySpawnPos.pos):Normalized()*300
					Control.SetCursorPos(CastPos)
					Control.CastSpell(HK_R, CastPos)
					DelayAction(EnableAll,0.65)
					self.HitTime = 0
				end
			end
		end
	end
end

function GoSuUtility:UtilityDraw()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if self.UMenu.Draws.DrawJng:Value() then
			SmiteSlot = (enemy:GetSpellData(SUMMONER_1).name:lower():find("Smite") and SUMMONER_1 or (enemy:GetSpellData(SUMMONER_2).name:lower():find("Smite") and SUMMONER_2 or nil))
			if SmiteSlot then
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
		if self.UMenu.Draws.DrawAA:Value() then
			if ValidTarget(enemy) then
				AALeft = enemy.health / myHero.totalDamage
				Draw.Text("AA Left: "..tostring(math.ceil(AALeft)), 17, enemy.pos2D.x-38, enemy.pos2D.y+10, Draw.Color(0xFF00BFFF))
			end
		end
	end
end

function GoSuUtility:Items()
	if target == nil then return end
	if EnemiesAround(myHero, 1000) >= 1 then
		if (target.health / target.maxHealth)*100 <= self.UMenu.Items.OI:Value() then
			if self.UMenu.Items.UseBC:Value() then
				if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then
					if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
						Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
					end
				end
			end
			if self.UMenu.Items.UseBOTRK:Value() then
				if GetItemSlot(myHero, 3153) > 0 and ValidTarget(target, 550) then
					if myHero:GetSpellData(GetItemSlot(myHero, 3153)).currentCd == 0 then
						Control.CastSpell(Item_HK[GetItemSlot(myHero, 3153)], target)
					end
				end
			end
			if self.UMenu.Items.UseHG:Value() then
				if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then
					if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
						Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
					end
				end
			end
		end
	end
	if self.UMenu.Items.UseMS:Value() then
		if GetItemSlot(myHero, 3139) > 0 then
			if myHero:GetSpellData(GetItemSlot(myHero, 3139)).currentCd == 0 then
				if IsImmobile(myHero) then
					Control.CastSpell(Item_HK[GetItemSlot(myHero, 3139)], myHero)
				end
			end
		end
	end
	if self.UMenu.Items.UseQS:Value() then
		if GetItemSlot(myHero, 3140) > 0 then
			if myHero:GetSpellData(GetItemSlot(myHero, 3140)).currentCd == 0 then
				if IsImmobile(myHero) then
					Control.CastSpell(Item_HK[GetItemSlot(myHero, 3140)], myHero)
				end
			end
		end
	end
end

function GoSuUtility:SS()
	if EnemiesAround(myHero, 2500) >= 1 then
		if self.UMenu.SS.UseHeal:Value() then
			if myHero.alive and myHero.health > 0 and GetPercentHP(myHero) <= self.UMenu.SS.HealMe:Value() then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and IsReady(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and IsReady(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2)
				end
				for _, ally in pairs(GetAllyHeroes()) do
					if ValidTarget(ally, 850) then
						if ally.alive and ally.health > 0 and GetPercentHP(ally) <= self.UMenu.SS.HealAlly:Value() then
							if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and IsReady(SUMMONER_1) then
								Control.CastSpell(HK_SUMMONER_1, ally.pos)
							elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and IsReady(SUMMONER_2) then
								Control.CastSpell(HK_SUMMONER_2, ally.pos)
							end
						end
					end
				end
			end
		end
		if self.UMenu.SS.UseBarrier:Value() then
			if myHero.alive and myHero.health > 0 and GetPercentHP(myHero) <= self.UMenu.SS.BarrierMe:Value() then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and IsReady(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_2)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and IsReady(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_1)
				end
			end
		end
	end
end

class "Ashe"

local HeroIcon = "https://d1u5p3l4wpay3k.cloudfront.net/lolesports_gamepedia_en/4/4a/AsheSquare.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/2/2a/Ranger%27s_Focus_2.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/5/5d/Volley.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/2/28/Enchanted_Crystal_Arrow.png"

function Ashe:Menu()
	self.AsheMenu = MenuElement({type = MENU, id = "Ashe", name = "[GoS-U] Ashe", leftIcon = HeroIcon})
	self.AsheMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.AsheMenu.Auto:MenuElement({id = "UseW", name = "Use W [Volley]", value = true, leftIcon = WIcon})
	self.AsheMenu.Auto:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.AsheMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.AsheMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Ranger's Focus]", value = true, leftIcon = QIcon})
	self.AsheMenu.Combo:MenuElement({id = "UseW", name = "Use W [Volley]", value = true, leftIcon = WIcon})
	self.AsheMenu.Combo:MenuElement({id = "UseR", name = "Use R [Enchanted Crystal Arrow]", value = true, leftIcon = RIcon})
	self.AsheMenu.Combo:MenuElement({id = "Distance", name = "Distance: R", value = 2000, min = 100, max = 5000, step = 50})
	self.AsheMenu.Combo:MenuElement({id = "X", name = "Minimum Enemies: R", value = 1, min = 0, max = 5, step = 1})
	self.AsheMenu.Combo:MenuElement({id = "HP", name = "HP-Manager: R", value = 40, min = 0, max = 100, step = 5})
	
	self.AsheMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.AsheMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Ranger's Focus]", value = true, leftIcon = QIcon})
	self.AsheMenu.Harass:MenuElement({id = "UseW", name = "Use W [Volley]", value = true, leftIcon = WIcon})
	self.AsheMenu.Harass:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.AsheMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.AsheMenu.KillSteal:MenuElement({id = "UseW", name = "Use W [Volley]", value = true, leftIcon = WIcon})
	self.AsheMenu.KillSteal:MenuElement({id = "UseR", name = "Use R [Enchanted Crystal Arrow]", value = true, leftIcon = RIcon})
	self.AsheMenu.KillSteal:MenuElement({id = "Distance", name = "Distance: R", value = 2000, min = 100, max = 5000, step = 50})
	
	self.AsheMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.AsheMenu.LaneClear:MenuElement({id = "UseQ", name = "Use Q [Ranger's Focus]", value = true, leftIcon = QIcon})
	self.AsheMenu.LaneClear:MenuElement({id = "UseW", name = "Use W [Volley]", value = true, leftIcon = WIcon})
	self.AsheMenu.LaneClear:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.AsheMenu:MenuElement({id = "AntiGapcloser", name = "Anti-Gapcloser", type = MENU})
	self.AsheMenu.AntiGapcloser:MenuElement({id = "UseW", name = "Use W [Volley]", value = true, leftIcon = WIcon})
	self.AsheMenu.AntiGapcloser:MenuElement({id = "DistanceW", name = "Distance: W", value = 400, min = 25, max = 500, step = 25})
	
	self.AsheMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.AsheMenu.HitChance:MenuElement({id = "HPredHit", name = "HitChance: HPrediction", value = 1, min = 1, max = 5, step = 1})
	self.AsheMenu.HitChance:MenuElement({id = "TPredHit", name = "HitChance: TPrediction", value = 1, min = 0, max = 5, step = 1})
	
	self.AsheMenu:MenuElement({id = "Prediction", name = "Prediction", type = MENU})
	self.AsheMenu.Prediction:MenuElement({id = "PredictionW", name = "Prediction: W", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.AsheMenu.Prediction:MenuElement({id = "PredictionR", name = "Prediction: R", drop = {"HPrediction", "TPrediction"}, value = 2})
	
	self.AsheMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.AsheMenu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.AsheMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
end

function Ashe:Spells()
	AsheW = {speed = 1500, range = 1200, delay = 0.25, width = 20, collision = true, aoe = true, type = "line"}
	AsheR = {speed = 1600, range = 25000, delay = 0.25, width = 130, collision = false, aoe = false, type = "line"}
end

function Ashe:__init()
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ashe:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	self:Auto()
	self:KillSteal()
	self:AntiGapcloser()
	if Mode() == "Combo" then
		self:Combo()
	elseif Mode() == "Harass" then
		self:Harass()
	elseif Mode() == "Clear" then
		self:LaneClear()
	end
end

function Ashe:Draw()
	if myHero.dead then return end
	if self.AsheMenu.Drawings.DrawW:Value() then Draw.Circle(myHero.pos, AsheW.range, 1, Draw.Color(255, 65, 105, 225)) end
	if self.AsheMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, self.AsheMenu.Combo.Distance:Value(), 1, Draw.Color(255, 0, 0, 255)) end
end

function Ashe:UseW(target)
	if self.AsheMenu.Prediction.PredictionW:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, AsheW.range, AsheW.delay, AsheW.speed, AsheW.width, self.AsheMenu.HitChance.HPredHit:Value(), AsheW.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, AsheW.range) then
			Control.CastSpell(HK_W, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, AsheW.range, AsheW.delay, AsheW.speed, AsheW.width, AsheW.collision, self.AsheMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, AsheW.range) then
				Control.CastSpell(HK_W, aimPosition)
			end
		end
	elseif self.AsheMenu.Prediction.PredictionW:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, AsheW.delay, AsheW.width, AsheW.range, AsheW.speed, myHero.pos, AsheW.collision, AsheW.type)
		if (HitChance >= self.AsheMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_W, castpos)
		end
	end
end

function Ashe:UseR(target)
	if self.AsheMenu.Prediction.PredictionR:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, AsheR.range, AsheR.delay, AsheR.speed, AsheR.width, self.AsheMenu.HitChance.HPredHit:Value(), AsheR.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, AsheR.range) then
			local RCastPos = myHero.pos-(myHero.pos-Vector(aimPosition)):Normalized()*300
			Control.SetCursorPos(RCastPos)
			Control.CastSpell(HK_R, RCastPos)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, AsheR.range, AsheR.delay, AsheR.speed, AsheR.width, AsheR.collision, self.AsheMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, AsheR.range) then
				local RCastPos = myHero.pos-(myHero.pos-Vector(aimPosition)):Normalized()*300
				Control.SetCursorPos(RCastPos)
				Control.CastSpell(HK_R, RCastPos)
			end
		end
	elseif self.AsheMenu.Prediction.PredictionR:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, AsheR.delay, AsheR.width, AsheR.range, AsheR.speed, myHero.pos, AsheR.collision, AsheR.type)
		if (HitChance >= self.AsheMenu.HitChance.TPredHit:Value() ) then
			local RCastPos = myHero.pos-(myHero.pos-Vector(castpos)):Normalized()*300
			Control.SetCursorPos(RCastPos)
			Control.CastSpell(HK_R, RCastPos)
		end
	end
end

function Ashe:Auto()
	if target == nil then return end
	if self.AsheMenu.Auto.UseW:Value() then
		if GetPercentMana(myHero) > self.AsheMenu.Auto.MP:Value() then
			if IsReady(_W) then
				if ValidTarget(target, AsheW.range) then
					self:UseW(target)
				end
			end
		end
	end
end

function Ashe:Combo()
	if target == nil then return end
	if self.AsheMenu.Combo.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, myHero.range+100) then
				if GotBuff(myHero, "asheqcastready") == 4 then
					Control.CastSpell(HK_Q)
				end
			end
		end
	end
	if self.AsheMenu.Combo.UseW:Value() then
		if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, AsheW.range) then
				self:UseW(target)
			end
		end
	end
	if self.AsheMenu.Combo.UseR:Value() then
		if IsReady(_R) then
			if ValidTarget(target, self.AsheMenu.Combo.Distance:Value()) then
				if GetPercentHP(target) < self.AsheMenu.Combo.HP:Value() then
					if EnemiesAround(myHero, self.AsheMenu.Combo.Distance:Value()+myHero.range) >= self.AsheMenu.Combo.X:Value() then
						self:UseR(target)
					end
				end
			end
		end
	end
end

function Ashe:Harass()
	if target == nil then return end
	if self.AsheMenu.Harass.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, myHero.range+100) then
				if GotBuff(myHero, "asheqcastready") == 4 then
					Control.CastSpell(HK_Q)
				end
			end
		end
	end
	if self.AsheMenu.Harass.UseW:Value() then
		if GetPercentMana(myHero) > self.AsheMenu.Harass.MP:Value() then
			if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, AsheW.range) then
					self:UseW(target)
				end
			end
		end
	end
end

function Ashe:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_R) then
			if self.AsheMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, self.AsheMenu.KillSteal.Distance:Value()) then
					local AsheRDmg = CalcMagicalDamage(myHero, enemy, (({200, 400, 600})[myHero:GetSpellData(_R).level] + myHero.ap))
					if (enemy.health + enemy.hpRegen * 6) < AsheRDmg then
						self:UseR(enemy)
					end
				end
			end
		elseif IsReady(_W) then
			if self.AsheMenu.KillSteal.UseW:Value() then
				if ValidTarget(enemy, AsheW.range) then
					local AsheWDmg = CalcPhysicalDamage(myHero, enemy, (({20, 35, 50, 65, 80})[myHero:GetSpellData(_W).level] + myHero.totalDamage))
					if (enemy.health + enemy.hpRegen * 4) < AsheWDmg then
						self:UseW(enemy)
					end
				end
			end
		end
	end
end

function Ashe:LaneClear()
	if self.AsheMenu.LaneClear.UseW:Value() then
		if GetPercentMana(myHero) > self.AsheMenu.LaneClear.MP:Value() then
			if IsReady(_W) then
				local BestPos, BestHit = GetBestLinearFarmPos(AsheW.range, AsheW.width*9)
				if BestPos and BestHit >= 3 then
					Control.SetCursorPos(BestPos)
					Control.CastSpell(HK_W, BestPos)
				end
			end
		end
	end
	if self.AsheMenu.LaneClear.UseQ:Value() then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.isEnemy then
				if ValidTarget(minion, myHero.range) then
					if GotBuff(myHero, "asheqcastready") == 4 then
						Control.CastSpell(HK_Q)
					end
				end
			end
		end
	end
end

function Ashe:AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if IsReady(_W) then
			if self.AsheMenu.AntiGapcloser.UseW:Value() then
				if ValidTarget(antigap, self.AsheMenu.AntiGapcloser.DistanceW:Value()) then
					self:UseW(antigap)
				end
			end
		end
	end
end

class "Ezreal"

local HeroIcon = "http://i1.17173cdn.com/1tx6lh/YWxqaGBf/images/hero/ezreal_square_0.jpg"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/5/5a/Mystic_Shot.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/9/9e/Essence_Flux.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/f/fb/Arcane_Shift.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/0/02/Trueshot_Barrage.png"

function Ezreal:Menu()
	self.EzrealMenu = MenuElement({type = MENU, id = "Ezreal", name = "[GoS-U] Ezreal", leftIcon = HeroIcon})
	self.EzrealMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.EzrealMenu.Auto:MenuElement({id = "UseQ", name = "Use Q [Mystic Shot]", value = true, leftIcon = QIcon})
	self.EzrealMenu.Auto:MenuElement({id = "UseW", name = "Use W [Essence Flux]", value = true, leftIcon = WIcon})
	self.EzrealMenu.Auto:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.EzrealMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.EzrealMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Mystic Shot]", value = true, leftIcon = QIcon})
	self.EzrealMenu.Combo:MenuElement({id = "UseW", name = "Use W [Essence Flux]", value = true, leftIcon = WIcon})
	self.EzrealMenu.Combo:MenuElement({id = "UseE", name = "Use E [Arcane Shift]", value = true, leftIcon = EIcon})
	self.EzrealMenu.Combo:MenuElement({id = "UseR", name = "Use R [Trueshot Barrage]", value = true, leftIcon = RIcon})
	self.EzrealMenu.Combo:MenuElement({id = "Distance", name = "Distance: R", value = 2000, min = 100, max = 5000, step = 50})
	self.EzrealMenu.Combo:MenuElement({id = "X", name = "Minimum Enemies: R", value = 1, min = 0, max = 5, step = 1})
	self.EzrealMenu.Combo:MenuElement({id = "HP", name = "HP-Manager: R", value = 40, min = 0, max = 100, step = 5})
	
	self.EzrealMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.EzrealMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Mystic Shot]", value = true, leftIcon = QIcon})
	self.EzrealMenu.Harass:MenuElement({id = "UseW", name = "Use W [Essence Flux]", value = true, leftIcon = WIcon})
	self.EzrealMenu.Harass:MenuElement({id = "UseE", name = "Use E [Arcane Shift]", value = true, leftIcon = WIcon})
	self.EzrealMenu.Harass:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.EzrealMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.EzrealMenu.KillSteal:MenuElement({id = "UseR", name = "Use R [Trueshot Barrage]", value = true, leftIcon = RIcon})
	self.EzrealMenu.KillSteal:MenuElement({id = "Distance", name = "Distance: R", value = 2000, min = 100, max = 5000, step = 50})
	
	self.EzrealMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.EzrealMenu.LaneClear:MenuElement({id = "UseQ", name = "Use Q [Mystic Shot]", value = false, leftIcon = QIcon})
	self.EzrealMenu.LaneClear:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.EzrealMenu:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
	self.EzrealMenu.LastHit:MenuElement({id = "UseQ", name = "Use Q [Mystic Shot]", value = true, leftIcon = QIcon})
	self.EzrealMenu.LastHit:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.EzrealMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.EzrealMenu.HitChance:MenuElement({id = "HPredHit", name = "HitChance: HPrediction", value = 1, min = 1, max = 5, step = 1})
	self.EzrealMenu.HitChance:MenuElement({id = "TPredHit", name = "HitChance: TPrediction", value = 1, min = 0, max = 5, step = 1})
	
	self.EzrealMenu:MenuElement({id = "Prediction", name = "Prediction", type = MENU})
	self.EzrealMenu.Prediction:MenuElement({id = "PredictionQ", name = "Prediction: Q", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.EzrealMenu.Prediction:MenuElement({id = "PredictionW", name = "Prediction: W", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.EzrealMenu.Prediction:MenuElement({id = "PredictionR", name = "Prediction: R", drop = {"HPrediction", "TPrediction"}, value = 2})
	
	self.EzrealMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.EzrealMenu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.EzrealMenu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.EzrealMenu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	self.EzrealMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
end

function Ezreal:Spells()
	EzrealQ = {speed = 2000, range = 1150, delay = 0.25, width = 60, collision = true, aoe = false, type = "line"}
	EzrealW = {speed = 1600, range = 1000, delay = 0.25, width = 80, collision = false, aoe = true, type = "line"}
	EzrealE = {range = 475}
	EzrealR = {speed = 2000, range = 25000, delay = 1, width = 160, collision = false, aoe = true, type = "line"}
end

function Ezreal:__init()
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ezreal:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	self:Auto()
	self:KillSteal()
	if Mode() == "Combo" then
		self:Combo()
	elseif Mode() == "Harass" then
		self:Harass()
	elseif Mode() == "Clear" then
		self:LaneClear()
		self:LastHit()
	end
end

function Ezreal:Draw()
	if myHero.dead then return end
	if self.EzrealMenu.Drawings.DrawQ:Value() then Draw.Circle(myHero.pos, EzrealQ.range, 1, Draw.Color(255, 0, 191, 255)) end
	if self.EzrealMenu.Drawings.DrawW:Value() then Draw.Circle(myHero.pos, EzrealW.range, 1, Draw.Color(255, 65, 105, 225)) end
	if self.EzrealMenu.Drawings.DrawE:Value() then Draw.Circle(myHero.pos, EzrealE.range, 1, Draw.Color(255, 30, 144, 255)) end
	if self.EzrealMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, self.EzrealMenu.Combo.Distance:Value(), 1, Draw.Color(255, 0, 0, 255)) end
end

function Ezreal:UseQ(target)
	if self.EzrealMenu.Prediction.PredictionQ:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, EzrealQ.range, EzrealQ.delay, EzrealQ.speed, EzrealQ.width, self.EzrealMenu.HitChance.HPredHit:Value(), EzrealQ.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, EzrealQ.range) then
			Control.CastSpell(HK_Q, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, EzrealQ.range, EzrealQ.delay, EzrealQ.speed, EzrealQ.width, EzrealQ.collision, self.EzrealMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, EzrealQ.range) then
				Control.CastSpell(HK_Q, aimPosition)
			end
		end
	elseif self.EzrealMenu.Prediction.PredictionQ:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, EzrealQ.delay, EzrealQ.width, EzrealQ.range, EzrealQ.speed, myHero.pos, EzrealQ.collision, EzrealQ.type)
		if (HitChance >= self.EzrealMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_Q, castpos)
		end
	end
end

function Ezreal:UseW(target)
	if self.EzrealMenu.Prediction.PredictionW:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, EzrealW.range, EzrealW.delay, EzrealW.speed, EzrealW.width, self.EzrealMenu.HitChance.HPredHit:Value(), EzrealW.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, EzrealW.range) then
			Control.CastSpell(HK_W, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, EzrealW.range, EzrealW.delay, EzrealW.speed, EzrealW.width, EzrealW.collision, self.EzrealMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, EzrealW.range) then
				Control.CastSpell(HK_W, aimPosition)
			end
		end
	elseif self.EzrealMenu.Prediction.PredictionW:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, EzrealW.delay, EzrealW.width, EzrealW.range, EzrealW.speed, myHero.pos, EzrealW.collision, EzrealW.type)
		if (HitChance >= self.EzrealMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_W, castpos)
		end
	end
end

function Ezreal:UseR(target)
	if self.EzrealMenu.Prediction.PredictionR:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, EzrealR.range, EzrealR.delay, EzrealR.speed, EzrealR.width, self.EzrealMenu.HitChance.HPredHit:Value(), EzrealR.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, EzrealR.range) then
			local RCastPos = myHero.pos-(myHero.pos-Vector(aimPosition)):Normalized()*300
			Control.SetCursorPos(RCastPos)
			Control.CastSpell(HK_R, RCastPos)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, EzrealR.range, EzrealR.delay, EzrealR.speed, EzrealR.width, EzrealR.collision, self.EzrealMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, EzrealR.range) then
				local RCastPos = myHero.pos-(myHero.pos-Vector(castpos)):Normalized()*300
				Control.SetCursorPos(RCastPos)
				Control.CastSpell(HK_R, RCastPos)
			end
		end
	elseif self.EzrealMenu.Prediction.PredictionR:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, EzrealR.delay, EzrealR.width, EzrealR.range, EzrealR.speed, myHero.pos, EzrealR.collision, EzrealR.type)
		if (HitChance >= self.EzrealMenu.HitChance.TPredHit:Value() ) then
			local RCastPos = myHero.pos-(myHero.pos-Vector(aimPosition)):Normalized()*300
			Control.SetCursorPos(RCastPos)
			Control.CastSpell(HK_R, RCastPos)
		end
	end
end

function Ezreal:Auto()
	if target == nil then return end
	if self.EzrealMenu.Auto.UseQ:Value() then
		if GetPercentMana(myHero) > self.EzrealMenu.Auto.MP:Value() then
			if IsReady(_Q) then
				if ValidTarget(target, EzrealQ.range) then
					self:UseQ(target)
				end
			end
		end
	end
	if self.EzrealMenu.Auto.UseW:Value() then
		if GetPercentMana(myHero) > self.EzrealMenu.Auto.MP:Value() then
			if IsReady(_W) then
				if ValidTarget(target, EzrealW.range) then
					self:UseW(target)
				end
			end
		end
	end
end

function Ezreal:Combo()
	if target == nil then return end
	if self.EzrealMenu.Combo.UseQ:Value() then
		if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, EzrealQ.range) then
				self:UseQ(target)
			end
		end
	end
	if self.EzrealMenu.Combo.UseW:Value() then
		if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, EzrealW.range) then
				self:UseW(target)
			end
		end
	end
	if self.EzrealMenu.Combo.UseE:Value() then
		if IsReady(_E) then
			if ValidTarget(target, EzrealE.range+myHero.range) then
				Control.CastSpell(HK_E, mousePos)
			end
		end
	end
	if self.EzrealMenu.Combo.UseR:Value() then
		if IsReady(_R) then
			if ValidTarget(target, self.EzrealMenu.Combo.Distance:Value()) then
				if GetPercentHP(target) < self.EzrealMenu.Combo.HP:Value() then
					if EnemiesAround(myHero, self.EzrealMenu.Combo.Distance:Value()+myHero.range) >= self.EzrealMenu.Combo.X:Value() then
						self:UseR(target)
					end
				end
			end
		end
	end
end

function Ezreal:Harass()
	if target == nil then return end
	if self.EzrealMenu.Harass.UseQ:Value() then
		if GetPercentMana(myHero) > self.EzrealMenu.Harass.MP:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, EzrealQ.range) then
					self:UseQ(target)
				end
			end
		end
	end
	if self.EzrealMenu.Harass.UseW:Value() then
		if GetPercentMana(myHero) > self.EzrealMenu.Harass.MP:Value() then
			if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, EzrealW.range) then
					self:UseW(target)
				end
			end
		end
	end
end

function Ezreal:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_R) then
			if self.EzrealMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, self.EzrealMenu.KillSteal.Distance:Value()) then
					local EzrealRDmg = CalcMagicalDamage(myHero, enemy, (0.3*(({350, 500, 650})[myHero:GetSpellData(_R).level] + myHero.bonusDamage + 0.9 * myHero.ap)))
					if (enemy.health + enemy.hpRegen * 6) < EzrealRDmg then
						self:UseR(enemy)
					end
				end
			end
		end
	end
end

function Ezreal:LaneClear()
	if self.EzrealMenu.LaneClear.UseQ:Value() then
		if GetPercentMana(myHero) > self.EzrealMenu.LaneClear.MP:Value() then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion and minion.isEnemy then
					if ValidTarget(minion, EzrealQ.range) then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end
		end
	end
end

function Ezreal:LastHit()
	if self.EzrealMenu.LastHit.UseQ:Value() then
		if GetPercentMana(myHero) > self.EzrealMenu.LastHit.MP:Value() then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion and minion.isEnemy then
					if ValidTarget(minion, EzrealQ.range) then
						local EzrealQDmg = (({15, 40, 65, 90, 115})[myHero:GetSpellData(_Q).level] + 1.1 * myHero.bonusDamage + 0.4 * myHero.ap)
						if minion.health < EzrealQDmg then
							local castpos,HitChance, pos = TPred:GetBestCastPosition(minion, EzrealQ.delay, EzrealQ.width, EzrealQ.range, EzrealQ.speed, myHero.pos, EzrealQ.collision, EzrealQ.type)
							if HitChance >= 1 then
								Control.CastSpell(HK_Q, castpos)
							end
						end
					end
				end
			end
		end
	end
end

class "Jinx"

local HeroIcon = "https://www.mobafire.com/images/avatars/jinx-classic.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/d/dd/Switcheroo%21.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/7/76/Zap%21.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/b/bb/Flame_Chompers%21.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/a8/Super_Mega_Death_Rocket%21.png"

function Jinx:Menu()
	self.JinxMenu = MenuElement({type = MENU, id = "Jinx", name = "[GoS-U] Jinx", leftIcon = HeroIcon})
	self.JinxMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.JinxMenu.Auto:MenuElement({id = "UseW", name = "Use W [Zap!]", value = true, leftIcon = WIcon})
	self.JinxMenu.Auto:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.JinxMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.JinxMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Switcheroo!]", value = true, leftIcon = QIcon})
	self.JinxMenu.Combo:MenuElement({id = "UseW", name = "Use W [Zap!]", value = true, leftIcon = WIcon})
	self.JinxMenu.Combo:MenuElement({id = "UseE", name = "Use E [Flame Chompers!]", value = true, leftIcon = EIcon})
	self.JinxMenu.Combo:MenuElement({id = "UseR", name = "Use R [Mega Death Rocket!]", value = true, leftIcon = RIcon})
	self.JinxMenu.Combo:MenuElement({id = "Distance", name = "Distance: R", value = 2000, min = 100, max = 5000, step = 50})
	self.JinxMenu.Combo:MenuElement({id = "ModeE", name = "Cast Mode: E", drop = {"Standard", "On Immobile"}, value = 1})
	self.JinxMenu.Combo:MenuElement({id = "X", name = "Minimum Enemies: R", value = 1, min = 0, max = 5, step = 1})
	self.JinxMenu.Combo:MenuElement({id = "HP", name = "HP-Manager: R", value = 40, min = 0, max = 100, step = 5})
	
	self.JinxMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.JinxMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Switcheroo!]", value = true, leftIcon = QIcon})
	self.JinxMenu.Harass:MenuElement({id = "UseW", name = "Use W [Zap!]", value = true, leftIcon = WIcon})
	self.JinxMenu.Harass:MenuElement({id = "UseE", name = "Use E [Flame Chompers!]", value = true, leftIcon = EIcon})
	self.JinxMenu.Harass:MenuElement({id = "ModeE", name = "Cast Mode: E", drop = {"Standard", "On Immobile"}, value = 2})
	self.JinxMenu.Harass:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.JinxMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.JinxMenu.KillSteal:MenuElement({id = "UseW", name = "Use W [Zap!]", value = true, leftIcon = WIcon})
	self.JinxMenu.KillSteal:MenuElement({id = "UseR", name = "Use R [Mega Death Rocket!]", value = true, leftIcon = RIcon})
	self.JinxMenu.KillSteal:MenuElement({id = "Distance", name = "Distance: R", value = 2000, min = 100, max = 5000, step = 50})
	
	self.JinxMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.JinxMenu.LaneClear:MenuElement({id = "UseQ", name = "Use Q [Switcheroo!]", value = false, leftIcon = QIcon})
	self.JinxMenu.LaneClear:MenuElement({id = "UseE", name = "Use E [Flame Chompers!]", value = false, leftIcon = EIcon})
	self.JinxMenu.LaneClear:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.JinxMenu:MenuElement({id = "AntiGapcloser", name = "Anti-Gapcloser", type = MENU})
	self.JinxMenu.AntiGapcloser:MenuElement({id = "UseW", name = "Use W [Zap!]", value = true, leftIcon = WIcon})
	self.JinxMenu.AntiGapcloser:MenuElement({id = "UseE", name = "Use E [Flame Chompers!]", value = true, leftIcon = EIcon})
	self.JinxMenu.AntiGapcloser:MenuElement({id = "DistanceW", name = "Distance: W", value = 400, min = 25, max = 500, step = 25})
	self.JinxMenu.AntiGapcloser:MenuElement({id = "DistanceE", name = "Distance: E", value = 300, min = 25, max = 500, step = 25})
	
	self.JinxMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.JinxMenu.HitChance:MenuElement({id = "HPredHit", name = "HitChance: HPrediction", value = 1, min = 1, max = 5, step = 1})
	self.JinxMenu.HitChance:MenuElement({id = "TPredHit", name = "HitChance: TPrediction", value = 1, min = 0, max = 5, step = 1})
	
	self.JinxMenu:MenuElement({id = "Prediction", name = "Prediction", type = MENU})
	self.JinxMenu.Prediction:MenuElement({id = "PredictionW", name = "Prediction: W", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.JinxMenu.Prediction:MenuElement({id = "PredictionE", name = "Prediction: E", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.JinxMenu.Prediction:MenuElement({id = "PredictionR", name = "Prediction: R", drop = {"HPrediction", "TPrediction"}, value = 2})
	
	self.JinxMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.JinxMenu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.JinxMenu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	self.JinxMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
end

function Jinx:Spells()
	JinxW = {speed = 3300, range = 1450, delay = 0.6, width = 60, collision = true, aoe = false, type = "line"}
	JinxE = {speed = 1100, range = 900, delay = 1.5, width = 120, collision = false, aoe = true, type = "circular"}
	JinxR = {speed = 1700, range = 25000, delay = 0.6, width = 140, collision = false, aoe = false, type = "line"}
end

function Jinx:__init()
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Jinx:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	self:Auto()
	self:KillSteal()
	self:AntiGapcloser()
	if Mode() == "Combo" then
		self:Combo()
	elseif Mode() == "Harass" then
		self:Harass()
	elseif Mode() == "Clear" then
		self:LaneClear()
	end
end

function Jinx:Draw()
	if myHero.dead then return end
	if self.JinxMenu.Drawings.DrawW:Value() then Draw.Circle(myHero.pos, JinxW.range, 1, Draw.Color(255, 65, 105, 225)) end
	if self.JinxMenu.Drawings.DrawE:Value() then Draw.Circle(myHero.pos, JinxE.range, 1, Draw.Color(255, 30, 144, 255)) end
	if self.JinxMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, self.JinxMenu.Combo.Distance:Value(), 1, Draw.Color(255, 0, 0, 255)) end
end

function Jinx:UseW(target)
	if self.JinxMenu.Prediction.PredictionW:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, JinxW.range, JinxW.delay, JinxW.speed, JinxW.width, self.JinxMenu.HitChance.HPredHit:Value(), JinxW.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, JinxW.range) then
			Control.CastSpell(HK_W, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, JinxW.range, JinxW.delay, JinxW.speed, JinxW.width, JinxW.collision, self.JinxMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, JinxW.range) then
				Control.CastSpell(HK_W, aimPosition)
			end
		end
	elseif self.JinxMenu.Prediction.PredictionW:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, JinxW.delay, JinxW.width, JinxW.range, JinxW.speed, myHero.pos, JinxW.collision, JinxW.type)
		if (HitChance >= self.JinxMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_W, castpos)
		end
	end
end

function Jinx:UseE(target)
	if self.JinxMenu.Prediction.PredictionE:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, JinxE.range, JinxE.delay, JinxE.speed, JinxE.width, self.JinxMenu.HitChance.HPredHit:Value(), JinxE.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, JinxE.range) then
			Control.CastSpell(HK_E, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, JinxE.range, JinxE.delay, JinxE.speed, JinxE.width, JinxE.collision, self.JinxMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, JinxE.range) then
				Control.CastSpell(HK_E, aimPosition)
			end
		end
	elseif self.JinxMenu.Prediction.PredictionE:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, JinxE.delay, JinxE.width, JinxE.range, JinxE.speed, myHero.pos, JinxE.collision, JinxE.type)
		if (HitChance >= self.JinxMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_E, castpos)
		end
	end
end

function Jinx:UseR(target)
	if self.JinxMenu.Prediction.PredictionR:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, JinxR.range, JinxR.delay, JinxR.speed, JinxR.width, self.JinxMenu.HitChance.HPredHit:Value(), JinxR.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, JinxR.range) then
			local RCastPos = myHero.pos-(myHero.pos-Vector(aimPosition)):Normalized()*300
			Control.SetCursorPos(RCastPos)
			Control.CastSpell(HK_R, RCastPos)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, JinxR.range, JinxR.delay, JinxR.speed, JinxR.width, JinxR.collision, self.JinxMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, JinxR.range) then
				local RCastPos = myHero.pos-(myHero.pos-Vector(aimPosition)):Normalized()*300
				Control.SetCursorPos(RCastPos)
				Control.CastSpell(HK_R, RCastPos)
			end
		end
	elseif self.JinxMenu.Prediction.PredictionR:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, JinxR.delay, JinxR.width, JinxR.range, JinxR.speed, myHero.pos, JinxR.collision, JinxR.type)
		if (HitChance >= self.JinxMenu.HitChance.TPredHit:Value() ) then
			local RCastPos = myHero.pos-(myHero.pos-Vector(castpos)):Normalized()*300
			Control.SetCursorPos(RCastPos)
			Control.CastSpell(HK_R, RCastPos)
		end
	end
end

function Jinx:Auto()
	if target == nil then return end
	if self.JinxMenu.Auto.UseW:Value() then
		if GetPercentMana(myHero) > self.JinxMenu.Auto.MP:Value() then
			if IsReady(_W) then
				if ValidTarget(target, JinxW.range) and GetDistance(myHero.pos, target.pos) > 500 then
					self:UseW(target)
				end
			end
		end
	end
end

function Jinx:Combo()
	if target == nil then return end
	if self.JinxMenu.Combo.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, myHero.range) then
				if myHero:GetSpellData(_Q).toggleState == 2 then
					if EnemiesAround(target, 150) <= 1 then
						Control.CastSpell(HK_Q)
					end
				else
					if EnemiesAround(target, 150) > 1 then
						Control.CastSpell(HK_Q)
					end
				end
			elseif ValidTarget(target, myHero.range+200) then
				if GetDistance(myHero.pos, target.pos) > 600 and myHero:GetSpellData(_Q).toggleState == 1 then
					Control.CastSpell(HK_Q)
				elseif GetDistance(myHero.pos, target.pos) < 600 and myHero:GetSpellData(_Q).toggleState == 2 then
					Control.CastSpell(HK_Q)
				end
			end
		end
	end
	if self.JinxMenu.Combo.UseW:Value() then
		if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, JinxW.range) and GetDistance(myHero.pos, target.pos) > 500 then
				self:UseW(target)
			end
		end
	end
	if self.JinxMenu.Combo.UseE:Value() then
		if IsReady(_E) then
			if ValidTarget(target, JinxE.range) then
				if self.JinxMenu.Combo.ModeE:Value() == 1 then
					self:UseE(target)
				elseif self.JinxMenu.Combo.ModeE:Value() == 2 then
					if IsImmobile(target) then
						self:UseE(target)
					end
				end
			end
		end
	end
	if self.JinxMenu.Combo.UseR:Value() then
		if IsReady(_R) then
			if ValidTarget(target, self.JinxMenu.Combo.Distance:Value()) then
				if GetPercentHP(target) < self.JinxMenu.Combo.HP:Value() then
					if EnemiesAround(myHero, self.JinxMenu.Combo.Distance:Value()+myHero.range) >= self.JinxMenu.Combo.X:Value() then
						self:UseR(target)
					end
				end
			end
		end
	end
end

function Jinx:Harass()
	if target == nil then return end
	if self.JinxMenu.Harass.UseQ:Value() then
		if IsReady(_Q) then
			if ValidTarget(target, myHero.range) then
				if myHero:GetSpellData(_Q).toggleState == 2 then
					if EnemiesAround(target, 150) <= 1 then
						Control.CastSpell(HK_Q)
					end
				else
					if GetPercentMana(myHero) > self.JinxMenu.Harass.MP:Value() then
						if EnemiesAround(target, 150) > 1 then
							Control.CastSpell(HK_Q)
						end
					end
				end
			elseif ValidTarget(target, myHero.range+200) then
				if GetDistance(myHero.pos, target.pos) > 600 and myHero:GetSpellData(_Q).toggleState == 1 and GetPercentMana(myHero) > self.JinxMenu.Harass.MP:Value() then
					Control.CastSpell(HK_Q)
				elseif GetDistance(myHero.pos, target.pos) < 600 and myHero:GetSpellData(_Q).toggleState == 2 then
					Control.CastSpell(HK_Q)
				end
			end
		end
	end
	if self.JinxMenu.Harass.UseW:Value() then
		if GetPercentMana(myHero) > self.JinxMenu.Harass.MP:Value() then
			if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, JinxW.range) and GetDistance(myHero.pos, target.pos) > 500 then
					self:UseW(target)
				end
			end
		end
	end
	if self.JinxMenu.Harass.UseE:Value() then
		if GetPercentMana(myHero) > self.JinxMenu.Harass.MP:Value() then
			if IsReady(_E) then
				if ValidTarget(target, JinxE.range) then
					if self.JinxMenu.Harass.ModeE:Value() == 1 then
						self:UseE(target)
					elseif self.JinxMenu.Harass.ModeE:Value() == 2 then
						if IsImmobile(target) then
							self:UseE(target)
						end
					end
				end
			end
		end
	end
end

function Jinx:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_R) then
			if self.JinxMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, self.JinxMenu.KillSteal.Distance:Value()) then
					local JinxRDmg = CalcPhysicalDamage(myHero, enemy, (({125, 175, 225})[myHero:GetSpellData(_R).level] + 0.75 * myHero.bonusDamage + (({0.25, 0.3, 0.35})[myHero:GetSpellData(_R).level])*(enemy.maxHealth - enemy.health)))
					if (enemy.health + enemy.hpRegen * 6) < JinxRDmg then
						self:UseR(enemy)
					end
				end
			end
		elseif IsReady(_W) then
			if self.JinxMenu.KillSteal.UseW:Value() then
				if ValidTarget(enemy, JinxW.range) then
					local JinxWDmg = CalcPhysicalDamage(myHero, enemy, (({10, 60, 110, 160, 210})[myHero:GetSpellData(_W).level] + 1.6 * myHero.totalDamage))
					if (enemy.health + enemy.hpRegen * 4) < JinxWDmg then
						self:UseW(enemy)
					end
				end
			end
		end
	end
end

function Jinx:LaneClear()
	if self.JinxMenu.LaneClear.UseE:Value() then
		if GetPercentMana(myHero) > self.JinxMenu.LaneClear.MP:Value() then
			if IsReady(_E) then
				local BestPos, BestHit = GetBestCircularFarmPos(JinxE.range, JinxE.width)
				if BestPos and BestHit >= 3 then
					Control.SetCursorPos(BestPos)
					Control.CastSpell(HK_E, BestPos)
				end
			end
		end
	end
	if self.JinxMenu.LaneClear.UseQ:Value() then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.isEnemy then
				if ValidTarget(minion, myHero.range) then
					if myHero:GetSpellData(_Q).toggleState == 2 then
						if MinionsAround(minion.pos, 150, minion.team) <= 1 then
							Control.CastSpell(HK_Q)
						end
					else
						if GetPercentMana(myHero) > self.JinxMenu.LaneClear.MP:Value() then
							if MinionsAround(minion.pos, 150, minion.team) > 1 then
								Control.CastSpell(HK_Q)
							end
						end
					end
				end
			end
		end
	end
end

function Jinx:AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if IsReady(_W) then
			if self.JinxMenu.AntiGapcloser.UseW:Value() then
				if ValidTarget(antigap, self.JinxMenu.AntiGapcloser.DistanceW:Value()) then
					self:UseW(antigap)
				end
			end
		elseif IsReady(_E) then
			if self.JinxMenu.AntiGapcloser.UseE:Value() then
				if ValidTarget(antigap, self.JinxMenu.AntiGapcloser.DistanceE:Value()) then
					self:UseE(antigap)
				end
			end
		end
	end
end

class "Kalista"

local HeroIcon = "https://www.mobafire.com/images/champion/square/kalista.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/9/9b/Pierce.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/9/91/Sentinel.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/b/b8/Rend.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e9/Fate%27s_Call.png"

function Kalista:Menu()
	self.KalistaMenu = MenuElement({type = MENU, id = "Kalista", name = "[GoS-U] Kalista", leftIcon = HeroIcon})
	self.KalistaMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.KalistaMenu.Auto:MenuElement({id = "UseR", name = "Use R [Fate's Call]", value = true, leftIcon = RIcon})
	self.KalistaMenu.Auto:MenuElement({id = "HP", name = "HP-Manager: R", value = 20, min = 0, max = 100, step = 5})
	
	self.KalistaMenu:MenuElement({id = "ERend", name = "E [Rend]", type = MENU})
	self.KalistaMenu.ERend:MenuElement({id = "ResetE", name = "Use E (Reset)", value = true})
	self.KalistaMenu.ERend:MenuElement({id = "OutOfAA", name = "Use E (Out Of AA)", value = true})
	self.KalistaMenu.ERend:MenuElement({id = "MS", name = "Minimum Spears", value = 6, min = 0, max = 20, step = 1})
	
	self.KalistaMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.KalistaMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Pierce]", value = true, leftIcon = QIcon})
	self.KalistaMenu.Combo:MenuElement({id = "UseE", name = "Use E [Rend]", value = true, leftIcon = EIcon})
	
	self.KalistaMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.KalistaMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Pierce]", value = true, leftIcon = QIcon})
	self.KalistaMenu.Harass:MenuElement({id = "UseE", name = "Use E [Rend]", value = true, leftIcon = EIcon})
	self.KalistaMenu.Harass:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.KalistaMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.KalistaMenu.KillSteal:MenuElement({id = "UseQ", name = "Use Q [Pierce]", value = true, leftIcon = QIcon})
	self.KalistaMenu.KillSteal:MenuElement({id = "UseE", name = "Use E [Rend]", value = true, leftIcon = EIcon})
	
	self.KalistaMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.KalistaMenu.LaneClear:MenuElement({id = "UseQ", name = "Use Q [Pierce]", value = false, leftIcon = QIcon})
	self.KalistaMenu.LaneClear:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.KalistaMenu:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
	self.KalistaMenu.LastHit:MenuElement({id = "UseE", name = "Use E [Rend]", value = true, leftIcon = EIcon})
	self.KalistaMenu.LastHit:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.KalistaMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.KalistaMenu.HitChance:MenuElement({id = "HPredHit", name = "HitChance: HPrediction", value = 1, min = 1, max = 5, step = 1})
	self.KalistaMenu.HitChance:MenuElement({id = "TPredHit", name = "HitChance: TPrediction", value = 1, min = 0, max = 5, step = 1})
	
	self.KalistaMenu:MenuElement({id = "Prediction", name = "Prediction", type = MENU})
	self.KalistaMenu.Prediction:MenuElement({id = "PredictionW", name = "Prediction: W", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.KalistaMenu.Prediction:MenuElement({id = "PredictionE", name = "Prediction: E", drop = {"HPrediction", "TPrediction"}, value = 2})
	self.KalistaMenu.Prediction:MenuElement({id = "PredictionR", name = "Prediction: R", drop = {"HPrediction", "TPrediction"}, value = 2})
	
	self.KalistaMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.KalistaMenu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.KalistaMenu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	self.KalistaMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
end

function Kalista:Spells()
	KalistaQ = {speed = 2400, range = 1150, delay = 0.35, width = 40, collision = true, aoe = false, type = "line"}
	KalistaE = {range = 1000}
	KalistaR = {range = 1200}
end

function Kalista:__init()
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Kalista:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	self:Auto()
	self:KillSteal()
	if Mode() == "Combo" then
		self:Combo()
	elseif Mode() == "Harass" then
		self:Harass()
	elseif Mode() == "Clear" then
		self:LaneClear()
		self:LastHit()
	end
end

function Kalista:Draw()
	if myHero.dead then return end
	if self.KalistaMenu.Drawings.DrawQ:Value() then Draw.Circle(myHero.pos, KalistaQ.range, 1, Draw.Color(255, 0, 191, 255)) end
	if self.KalistaMenu.Drawings.DrawE:Value() then Draw.Circle(myHero.pos, KalistaE.range, 1, Draw.Color(255, 30, 144, 255)) end
	if self.KalistaMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, KalistaR.range, 1, Draw.Color(255, 0, 0, 255)) end
end

function Kalista:UseQ(target)
	if self.KalistaMenu.Prediction.PredictionW:Value() == 1 then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, KalistaQ.range, KalistaQ.delay, KalistaQ.speed, KalistaQ.width, self.KalistaMenu.HitChance.HPredHit:Value(), KalistaQ.collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, KalistaQ.range) then
			Control.CastSpell(HK_Q, aimPosition)
		else
			local hitChance, aimPosition = HPred:GetUnreliableTarget(myHero.pos, KalistaQ.range, KalistaQ.delay, KalistaQ.speed, KalistaQ.width, KalistaQ.collision, self.KalistaMenu.HitChance.HPredHit:Value(), nil)
			if hitChance and HPred:IsInRange(myHero.pos, aimPosition, KalistaQ.range) then
				Control.CastSpell(HK_Q, aimPosition)
			end
		end
	elseif self.KalistaMenu.Prediction.PredictionW:Value() == 2 then
		local castpos,HitChance, pos = TPred:GetBestCastPosition(target, KalistaQ.delay, KalistaQ.width, KalistaQ.range, KalistaQ.speed, myHero.pos, KalistaQ.collision, KalistaQ.type)
		if (HitChance >= self.KalistaMenu.HitChance.TPredHit:Value() ) then
			Control.CastSpell(HK_Q, castpos)
		end
	end
end

function Kalista:Auto()
	if target == nil then return end
	if self.KalistaMenu.Auto.UseR:Value() then
		for _, ally in pairs(GetAllyHeroes()) do
			if IsReady(_R) and GotBuff(ally, "kalistacoopstrikeally") == 1 then
				if ValidTarget(ally, KalistaR.range) and EnemiesAround(ally, 1500) >= 1 then
					if GetPercentHP(ally) <= self.KalistaMenu.Auto.HP:Value() then
						Control.CastSpell(HK_R)
					end
				end
			end
		end
	end
end

function Kalista:Combo()
	if target == nil then return end
	if self.KalistaMenu.Combo.UseQ:Value() then
		if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, KalistaQ.range) then
				self:UseQ(target)
			end
		end
	end
	if self.KalistaMenu.Combo.UseE:Value() then
		if IsReady(_E) then
			if ValidTarget(target, KalistaE.range) then
				if GetDistance(target.pos, myHero.pos) <= myHero.range then
					if self.KalistaMenu.ERend.ResetE:Value() then
						for i = 1, Game.MinionCount() do
							local minion = Game.Minion(i)
							if minion and minion.isEnemy then
								if ValidTarget(minion, KalistaE.range) and GotBuff(minion, "kalistaexpungemarker") >= 1 then
									local KalistaEDmg = ((({20, 30, 40, 50, 60})[myHero:GetSpellData(_E).level] + (0.6 * myHero.totalDamage)) + (({10, 14, 19, 25, 32})[myHero:GetSpellData(_E).level] + ((0.025 * myHero:GetSpellData(_E).level + 0.175) * myHero.totalDamage)) * (GotBuff(minion,"kalistaexpungemarker")-1))
									if minion.health < KalistaEDmg then
										if GotBuff(target, "kalistaexpungemarker") >= self.KalistaMenu.ERend.MS:Value() then
											Control.CastSpell(HK_E)
										end
									end
								end
							end
						end
					end
				elseif GetDistance(target.pos, myHero.pos) >= myHero.range then
					if self.KalistaMenu.ERend.OutOfAA:Value() then
						if GotBuff(target, "kalistaexpungemarker") >= self.KalistaMenu.ERend.MS:Value() then
							Control.CastSpell(HK_E)
						end
					end
				end
			end
		end
	end
end

function Kalista:Harass()
	if target == nil then return end
	if GetPercentMana(myHero) > self.KalistaMenu.Harass.MP:Value() then
		if self.KalistaMenu.Harass.UseQ:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, KalistaQ.range) then
					self:UseQ(target)
				end
			end
		end
		if self.KalistaMenu.Harass.UseE:Value() then
			if IsReady(_E) then
				if ValidTarget(target, KalistaE.range) then
					if GetDistance(target.pos, myHero.pos) <= myHero.range then
						if self.KalistaMenu.ERend.ResetE:Value() then
							for i = 1, Game.MinionCount() do
								local minion = Game.Minion(i)
								if minion and minion.isEnemy then
									if ValidTarget(minion, KalistaE.range) and GotBuff(minion, "kalistaexpungemarker") >= 1 then
										local KalistaEDmg = ((({20, 30, 40, 50, 60})[myHero:GetSpellData(_E).level] + (0.6 * myHero.totalDamage)) + (({10, 14, 19, 25, 32})[myHero:GetSpellData(_E).level] + ((0.025 * myHero:GetSpellData(_E).level + 0.175) * myHero.totalDamage)) * (GotBuff(minion,"kalistaexpungemarker")-1))
										if minion.health < KalistaEDmg then
											if GotBuff(target, "kalistaexpungemarker") >= self.KalistaMenu.ERend.MS:Value() then
												Control.CastSpell(HK_E)
											end
										end
									end
								end
							end
						end
					elseif GetDistance(target.pos, myHero.pos) >= myHero.range then
						if self.KalistaMenu.ERend.OutOfAA:Value() then
							if GotBuff(target, "kalistaexpungemarker") >= self.KalistaMenu.ERend.MS:Value() then
								Control.CastSpell(HK_E)
							end
						end
					end
				end
			end
		end
	end
end

function Kalista:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_Q) then
			if self.KalistaMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, KalistaQ.range) then
					local KalistaQDmg = CalcPhysicalDamage(myHero, enemy, (({10, 70, 130, 190, 250})[myHero:GetSpellData(_Q).level] + myHero.totalDamage))
					if (enemy.health + enemy.hpRegen * 2) < KalistaQDmg then
						self:UseQ(enemy)
					end
				end
			end
		elseif IsReady(_E) then
			if self.KalistaMenu.KillSteal.UseE:Value() then
				if ValidTarget(enemy, KalistaE.range) then
					if GotBuff(enemy, "kalistaexpungemarker") > 0 then
						local KalistaEDmg = CalcPhysicalDamage(myHero, enemy, ((({20, 30, 40, 50, 60})[myHero:GetSpellData(_E).level] + (0.6 * myHero.totalDamage)) + (({10, 14, 19, 25, 32})[myHero:GetSpellData(_E).level] + ((0.025 * myHero:GetSpellData(_E).level + 0.175) * myHero.totalDamage)) * (GotBuff(enemy,"kalistaexpungemarker")-1)))
						if (enemy.health + enemy.hpRegen * 2) < KalistaEDmg then
							Control.CastSpell(HK_E)
						end
					end
				end
			end
		end
	end
end

function Kalista:LaneClear()
	if self.KalistaMenu.LaneClear.UseQ:Value() then
		if GetPercentMana(myHero) > self.KalistaMenu.LaneClear.MP:Value() then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion and minion.isEnemy and minion.alive then
					if ValidTarget(minion, KalistaQ.range) then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end
		end
	end
end

function Kalista:LastHit()
	if self.KalistaMenu.LastHit.UseE:Value() then
		if GetPercentMana(myHero) > self.KalistaMenu.LastHit.MP:Value() then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion and minion.isEnemy and minion.alive then
					if ValidTarget(minion, KalistaE.range) then
						if GotBuff(minion, "kalistaexpungemarker") > 0 then
							local KalistaEDmg = ((({20, 30, 40, 50, 60})[myHero:GetSpellData(_E).level] + (0.6 * myHero.totalDamage)) + (({10, 14, 19, 25, 32})[myHero:GetSpellData(_E).level] + ((0.025 * myHero:GetSpellData(_E).level + 0.175) * myHero.totalDamage)) * (GotBuff(minion,"kalistaexpungemarker")-1))
							if minion.health < KalistaEDmg then
								Control.CastSpell(HK_E)
							end
						end
					end
				end
			end
		end
	end
end

class "Vayne"

local HeroIcon = "http://cdn.playzone.cz/large_pictures/picture-large-241972.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/8/8d/Tumble.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/6/66/Condemn.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/b/b4/Final_Hour.png"

function Vayne:Menu()
	self.VayneMenu = MenuElement({type = MENU, id = "Vayne", name = "[GoS-U] Vayne", leftIcon = HeroIcon})
	self.VayneMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
	self.VayneMenu.Auto:MenuElement({id = "UseE", name = "Use E [Condemn]", value = true, leftIcon = EIcon})
	self.VayneMenu.Auto:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.VayneMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.VayneMenu.Combo:MenuElement({id = "UseQ", name = "Use Q [Tumble]", value = true, leftIcon = QIcon})
	self.VayneMenu.Combo:MenuElement({id = "UseE", name = "Use E [Condemn]", value = true, leftIcon = EIcon})
	self.VayneMenu.Combo:MenuElement({id = "UseR", name = "Use R [Final Hour]", value = true, leftIcon = RIcon})
	self.VayneMenu.Combo:MenuElement({id = "ModeQ", name = "Cast Mode: Q", drop = {"Standard", "On Stacked"}, value = 2})
	self.VayneMenu.Combo:MenuElement({id = "X", name = "Minimum Enemies: R", value = 1, min = 0, max = 5, step = 1})
	self.VayneMenu.Combo:MenuElement({id = "HP", name = "HP-Manager: R", value = 40, min = 0, max = 100, step = 5})
	
	self.VayneMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.VayneMenu.Harass:MenuElement({id = "UseQ", name = "Use Q [Tumble]", value = true, leftIcon = QIcon})
	self.VayneMenu.Harass:MenuElement({id = "UseE", name = "Use E [Condemn]", value = true, leftIcon = EIcon})
	self.VayneMenu.Harass:MenuElement({id = "ModeQ", name = "Cast Mode: Q", drop = {"Standard", "On Stacked"}, value = 1})
	self.VayneMenu.Harass:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.VayneMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
	self.VayneMenu.KillSteal:MenuElement({id = "UseE", name = "Use E [Condemn]", value = true, leftIcon = EIcon})
	
	self.VayneMenu:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
	self.VayneMenu.LastHit:MenuElement({id = "UseQ", name = "Use Q [Tumble]", value = true, leftIcon = QIcon})
	self.VayneMenu.LastHit:MenuElement({id = "MP", name = "Mana-Manager", value = 40, min = 0, max = 100, step = 5})
	
	self.VayneMenu:MenuElement({id = "AntiGapcloser", name = "Anti-Gapcloser", type = MENU})
	self.VayneMenu.AntiGapcloser:MenuElement({id = "UseE", name = "Use E [Condemn]", value = true, leftIcon = EIcon})
	self.VayneMenu.AntiGapcloser:MenuElement({id = "Distance", name = "Distance: E", value = 175, min = 25, max = 500, step = 25})
	
	self.VayneMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.VayneMenu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.VayneMenu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	
	self.VayneMenu:MenuElement({id = "Misc", name = "Misc", type = MENU})
	self.VayneMenu.Misc:MenuElement({id = "BlockAA", name = "Block AA While Stealthed", value = true})
	self.VayneMenu.Misc:MenuElement({id = "Distance", name = "Distance: E", value = 400, min = 100, max = 475, step = 5})
end

function Vayne:Spells()
	VayneQ = {range = 300}
	VayneE = {speed = 2000, range = 550, delay = 0.25}
end

function Vayne:__init()
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Vayne:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	self:Auto()
	self:KillSteal()
	self:AntiGapcloser()
	if Mode() == "Combo" then
		self:Combo()
	elseif Mode() == "Harass" then
		self:Harass()
	elseif Mode() == "Clear" then
		self:LastHit()
	end
end

function Vayne:Draw()
	if myHero.dead then return end
	if self.VayneMenu.Drawings.DrawQ:Value() then Draw.Circle(myHero.pos, VayneQ.range, 1, Draw.Color(255, 0, 191, 255)) end
	if self.VayneMenu.Drawings.DrawE:Value() then Draw.Circle(myHero.pos, VayneE.range, 1, Draw.Color(255, 30, 144, 255)) end
end

function Vayne:UseE(target)
	local VayneEStun = target:GetPrediction(VayneE.speed,VayneE.delay)
	for Length = 0, self.VayneMenu.Misc.Distance:Value(), 50 do
		local TotalPos = VayneEStun + Vector(VayneEStun-Vector(myHero.pos)):Normalized() * Length
		if MapPosition:inWall(TotalPos) then
			Control.CastSpell(HK_E, target)
			break
		end
	end
end

function Vayne:Auto()
	if target == nil then return end
	if self.VayneMenu.Auto.UseE:Value() then
		if GetPercentMana(myHero) > self.VayneMenu.Auto.MP:Value() then
			if IsReady(_E) then
				if ValidTarget(target, VayneE.range) then
					self:UseE(target)
				end
			end
		end
	end
	if self.VayneMenu.Misc.BlockAA:Value() then
		if GotBuff(myHero, "vaynetumblefade") > 0 then
			if _G.SDK then
				_G.SDK.Orbwalker:SetAttack(false)
			else
				GOS.BlockAttack = true
			end
		else
			if _G.SDK then
				_G.SDK.Orbwalker:SetAttack(true)
			else
				GOS.BlockAttack = false
			end
		end
	end
end

function Vayne:Combo()
	if target == nil then return end
	if self.VayneMenu.Combo.UseQ:Value() then
		if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, VayneQ.range+myHero.range) then
				if self.VayneMenu.Combo.ModeQ:Value() == 1 then
					Control.CastSpell(HK_Q, mousePos)
				elseif self.VayneMenu.Combo.ModeQ:Value() == 2 then
					if GotBuff(target, "VayneSilveredDebuff") >= 2 then 
						Control.CastSpell(HK_Q, mousePos)
					end
				end
			end
		end
	end
	if self.VayneMenu.Combo.UseE:Value() then
		if IsReady(_E) and myHero.attackData.state ~= STATE_WINDUP then
			if ValidTarget(target, VayneE.range) then
				self:UseE(target)
			end
		end
	end
	if self.VayneMenu.Combo.UseR:Value() then
		if IsReady(_R) then
			if ValidTarget(target, myHero.range+500) then
				if GetPercentHP(target) < self.VayneMenu.Combo.HP:Value() then
					if EnemiesAround(myHero, VayneQ.range+myHero.range+100) >= self.VayneMenu.Combo.X:Value() then
						Control.CastSpell(HK_R)
					end
				end
			end
		end
	end
end

function Vayne:Harass()
	if target == nil then return end
	if self.VayneMenu.Harass.UseQ:Value() then
		if GetPercentMana(myHero) > self.VayneMenu.Harass.MP:Value() then
			if IsReady(_Q) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, VayneQ.range+myHero.range) then
					if self.VayneMenu.Harass.ModeQ:Value() == 1 then
						Control.CastSpell(HK_Q, mousePos)
					elseif self.VayneMenu.Harass.ModeQ:Value() == 2 then
						if GotBuff(target, "VayneSilveredDebuff") >= 2 then 
							Control.CastSpell(HK_Q, mousePos)
						end
					end
				end
			end
		end
	end
	if self.VayneMenu.Harass.UseE:Value() then
		if GetPercentMana(myHero) > self.VayneMenu.Harass.MP:Value() then
			if IsReady(_E) and myHero.attackData.state ~= STATE_WINDUP then
				if ValidTarget(target, VayneE.range) then
					self:UseE(target)
				end
			end
		end
	end
end

function Vayne:KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_E) and myHero.attackData.state ~= STATE_WINDUP then
			if self.VayneMenu.KillSteal.UseE:Value() then
				if ValidTarget(enemy, VayneE.range) then
					local VayneEDmg = CalcPhysicalDamage(myHero, enemy, (({50, 90, 120, 155, 190})[myHero:GetSpellData(_E).level] + 0.5 * myHero.bonusDamage))
					if (enemy.health + enemy.hpRegen * 2) < VayneEDmg then
						self:UseE(enemy)
					end
				end
			end
		end
	end
end

function Vayne:LastHit()
	if self.VayneMenu.LastHit.UseQ:Value() then
		if GetPercentMana(myHero) > self.VayneMenu.LastHit.MP:Value() then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion and minion.isEnemy then
					if ValidTarget(minion, myHero.range) then
						local VayneQDmg = (((0.05 * myHero:GetSpellData(_Q).level + 0.45) * myHero.totalDamage) + myHero.totalDamage)
						if minion.health < VayneQDmg then
							Control.CastSpell(HK_Q, mousePos)
						end
					end
				end
			end
		end
	end
end

function Vayne:AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if IsReady(_E) then
			if self.VayneMenu.AntiGapcloser.UseE:Value() then
				if ValidTarget(antigap, self.VayneMenu.AntiGapcloser.Distance:Value()) then
					self:UseE(antigap)
				end
			end
		end
	end
end

function OnLoad()
	GoSuUtility()
	if _G[myHero.charName] then
		_G[myHero.charName]()
	end
end
