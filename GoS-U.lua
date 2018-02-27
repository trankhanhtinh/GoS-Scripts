--  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄               ▄         ▄ 
-- ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌             ▐░▌       ▐░▌
-- ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀              ▐░▌       ▐░▌
-- ▐░▌          ▐░▌       ▐░▌▐░▌                       ▐░▌       ▐░▌
-- ▐░▌ ▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌
-- ▐░▌▐░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌
-- ▐░▌ ▀▀▀▀▀▀█░▌▐░▌       ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌
-- ▐░▌       ▐░▌▐░▌       ▐░▌          ▐░▌             ▐░▌       ▐░▌
-- ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌             ▐░█▄▄▄▄▄▄▄█░▌
-- ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌             ▐░░░░░░░░░░░▌
--  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀               ▀▀▀▀▀▀▀▀▀▀▀ 
-- ==================
-- == Introduction ==
-- ==================
-- Current version: 1.0.7
-- Intermediate GoS script which supports only ADC champions.
-- Features:
-- + Supports Ashe, Caitlyn, Corki, Draven, Ezreal, Jhin, Jinx, Kalista
-- + 4 choosable predictions (GoS, IPrediction, GPrediction, OpenPredict) + CurrentPos casting,
-- + 3 managers (Enemies-around, Mana, HP),
-- + Configurable casting settings (Auto, Combo, Harass),
-- + Different types of making combat,
-- + Advanced farm logic (LastHit & LaneClear).
-- + Additional Anti-Gapcloser and Interrupter,
-- + Spell range drawings (circular),
-- + Special damage indicator over HP bar of enemy,
-- + Offensive items usage & stacking tear,
-- + Includes GoS-U Utility
-- (Summoner spells & items usage, Auto-LevelUp, killable AA drawings)
-- ==================
-- == Requirements ==
-- ==================
-- + Orbwalker: IOW/GosWalk
-- ===============
-- == Changelog ==
-- ===============
-- 1.0.7
-- + Added Kalista
-- 1.0.6
-- + Added Jinx
-- + Restored modes for Ezreal's W
-- 1.0.5.1
-- + Removed modes from Ezreal's W
-- 1.0.5
-- + Added Jhin
-- 1.0.4
-- + Added Ezreal
-- 1.0.3
-- + Added Draven & BaseUlt
-- 1.0.2
-- + Added Corki
-- 1.0.1
-- + Added Caitlyn
-- 1.0
-- + Initial release
-- + Imported Ashe & Utility

local GSVer = 1.07

function AutoUpdate(data)
	local num = tonumber(data)
	if num > GSVer then
		PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>New version found! " .. data)
		PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Downloading update, please wait...")
		DownloadFileAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/GoS-U.lua", SCRIPT_PATH .. "GoS-U.lua", function() PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Successfully updated. Please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/GoS-U.version", AutoUpdate)

require('Inspired')
require('IPrediction')
require('OpenPredict')

function Mode()
	if _G.IOW_Loaded and IOW:Mode() then
		return IOW:Mode()
	elseif GoSWalkLoaded and GoSWalk.CurrentMode then
		return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
	end
end

OnProcessSpell(function(unit, spell)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			DelayAction(function()
				AA = true
			end, GetWindUp(myHero)+0.01)
		else
			AA = false
		end
	end
end)

CHANELLING_SPELLS = {
    ["Caitlyn"]                     = {_R},
    ["Darius"]                      = {_R},
    ["FiddleSticks"]                = {_W, _R},
    ["Galio"]                       = {_W},
    ["Gragas"]                      = {_W},
    ["Janna"]                       = {_R},
    ["Karthus"]                     = {_R},
    ["Katarina"]                    = {_R},
    ["Lucian"]                      = {_R},
    ["Malzahar"]                    = {_R},
    ["MasterYi"]                    = {_W},
    ["MissFortune"]                 = {_R},
    ["Nunu"]                        = {_R},
    ["Pantheon"]                    = {_E, _R},
    ["Shen"]                        = {_R},
    ["Sion"]                        = {_Q},
    ["TahmKench"]                   = {_R},
    ["TwistedFate"]                 = {_R},
    ["Warwick"]                     = {_R},
    ["Varus"]                       = {_Q},
    ["VelKoz"]                      = {_R},
    ["Vi"]                          = {_Q},
    ["Xerath"]                      = {_Q, _R},
    ["Zac"]                         = {_E},
}

GAPCLOSER_SPELLS = {
    ["Aatrox"]                      = {_Q},
    ["Akali"]                       = {_R},
    ["Alistar"]                     = {_W},
    ["Amumu"]                       = {_Q},
    ["Corki"]                       = {_W},
    ["Diana"]                       = {_R},
    ["Elise"]                       = {_Q, _E},
    ["FiddleSticks"]                = {_R},
    ["Ezreal"]                      = {_E},
    ["Fiora"]                       = {_Q},
    ["Fizz"]                        = {_Q},
    ["Galio"]                       = {_E},
    ["Gnar"]                        = {_E},
    ["Gragas"]                      = {_E},
    ["Graves"]                      = {_E},
    ["Hecarim"]                     = {_R},
    ["Irelia"]                      = {_Q},
    ["JarvanIV"]                    = {_Q, _R},
    ["Jax"]                         = {_Q},
    ["Jayce"]                       = {_Q},
    ["Katarina"]                    = {_E},
    ["Kassadin"]                    = {_R},
    ["Kennen"]                      = {_E},
    ["KhaZix"]                      = {_E},
    ["Lissandra"]                   = {_E},
    ["LeBlanc"]                     = {_W, _R},
    ["LeeSin"]                      = {_Q, _W},
    ["Leona"]                       = {_E},
    ["Lucian"]                      = {_E},
    ["Malphite"]                    = {_R},
    ["MasterYi"]                    = {_Q},
    ["MonkeyKing"]                  = {_E},
    ["Nautilus"]                    = {_Q},
    ["Nocturne"]                    = {_R},
    ["Olaf"]                        = {_R},
    ["Ornn"]                        = {_E},
    ["Pantheon"]                    = {_W, _R},
    ["Poppy"]                       = {_E},
    ["RekSai"]                      = {_E},
    ["Renekton"]                    = {_E},
    ["Riven"]                       = {_Q, _E},
    ["Rengar"]                      = {_R},
    ["Sejuani"]                     = {_Q},
    ["Sion"]                        = {_R},
    ["Shen"]                        = {_E},
    ["Shyvana"]                     = {_R},
    ["Talon"]                       = {_E},
    ["Thresh"]                      = {_Q},
    ["Tristana"]                    = {_W},
    ["Tryndamere"]                  = {_E},
    ["Udyr"]                        = {_E},
    ["Urgot"]                       = {_E},
    ["Volibear"]                    = {_Q},
    ["Vi"]                          = {_Q},
    ["XinZhao"]                     = {_E},
    ["Yasuo"]                       = {_E},
    ["Zac"]                         = {_E},
    ["Ziggs"]                       = {_W},
    ["Zoe"]                         = {_R},
}

local UtilityMenu = Menu("[GoS-U] Utility", "[GoS-U] Utility")
UtilityMenu:Menu("BaseUlt", "BaseUlt")
UtilityMenu.BaseUlt:Boolean('BU', 'Enable BaseUlt', true)
UtilityMenu:Menu("Draws", "Draws")
UtilityMenu.Draws:Boolean('DrawAA', 'Draw Killable AAs', true)
UtilityMenu:Menu("Items", "Items")
UtilityMenu.Items:Boolean('UseBC', 'Use Bilgewater Cutlass', true)
UtilityMenu.Items:Boolean('UseBOTRK', 'Use BOTRK', true)
UtilityMenu.Items:Boolean('UseHG', 'Use Hextech Gunblade', true)
UtilityMenu.Items:Boolean('UseMS', 'Use Mercurial Scimitar', true)
UtilityMenu.Items:Boolean('UseQS', 'Use Quicksilver Sash', true)
UtilityMenu.Items:Slider("OI","%HP To Use Offensive Items", 15, 0, 100, 5)
UtilityMenu:Menu("LevelUp", "LevelUp")
UtilityMenu.LevelUp:Boolean('LvlUp', 'Enable Level-Up', true)
UtilityMenu:Menu("SS", "Summoner Spells")
UtilityMenu.SS:Boolean('UseHeal', 'Use Heal', true)
UtilityMenu.SS:Boolean('UseSave', 'Save Ally Using Heal', true)
UtilityMenu.SS:Boolean('UseBarrier', 'Use Barrier', true)
UtilityMenu.SS:Slider("HealMe","%HP To Use Heal: MyHero", 15, 0, 100, 5)
UtilityMenu.SS:Slider("HealAlly","%HP To Use Heal: Ally", 15, 0, 100, 5)
UtilityMenu.SS:Slider("BarrierMe","%HP To Use Barrier", 15, 0, 100, 5)

SpawnPos = nil
Recalling = {}
local GlobalTimer = 0
OnObjectLoad(function(Object)
	if GetObjectType(Object) == Obj_AI_SpawnPoint and GetTeam(Object) ~= GetTeam(myHero) then
		SpawnPos = Object
	end
end)
OnCreateObj(function(Object)
	if GetObjectType(Object) == Obj_AI_SpawnPoint and GetTeam(Object) ~= GetTeam(myHero) then
		SpawnPos = Object
	end
end)
function BaseUlt()
	if UtilityMenu.BaseUlt.BU:Value() then
		if CanUseSpell(myHero, _R) == READY then
			for i, recall in pairs(Recalling) do
				if GetObjectName(myHero) == "Ashe" then
					local AsheRDmg = (200*GetCastLevel(myHero,_R))+GetBonusAP(myHero)
					if AsheRDmg >= (GetCurrentHP(recall.champ)+GetMagicResist(recall.champ)+GetHPRegen(recall.champ)*20) and SpawnPos ~= nil then
						local RecallTime = recall.duration-(GetGameTimer()-recall.start)+GetLatency()/2000
						local HitTime = 0.25+GetDistance(SpawnPos)/1600+GetLatency()/2000
						if RecallTime < HitTime and HitTime < 7.8 and HitTime-RecallTime < 1.5 then
							CastSkillShot(_R, GetOrigin(SpawnPos))
						end
					end
				elseif GetObjectName(myHero) == "Draven" then
					local DravenRDmg = (80*GetCastLevel(myHero,_R)+60)+(0.88*GetBonusDmg(myHero))
					if DravenRDmg >= (GetCurrentHP(recall.champ)+GetArmor(recall.champ)+GetHPRegen(recall.champ)*20) and SpawnPos ~= nil then
						local RecallTime = recall.duration-(GetGameTimer()-recall.start)+GetLatency()/2000
						local HitTime = 0.5+GetDistance(SpawnPos)/2000+GetLatency()/2000
						if RecallTime < HitTime and HitTime < 7.8 and HitTime-RecallTime < 1.5 then
							local Timer = GetTickCount()
							if (GlobalTimer + 12500) < Timer then
								CastSkillShot(_R, GetOrigin(SpawnPos))
								GlobalTimer = Timer
							end
						end
					end
				elseif GetObjectName(myHero) == "Ezreal" then
					local EzrealRDmg = (150*GetCastLevel(myHero,_R)+200)+GetBonusDmg(myHero)+(0.9*GetBonusAP(myHero))
					if EzrealRDmg >= (GetCurrentHP(recall.champ)+GetMagicResist(recall.champ)+GetHPRegen(recall.champ)*20) and SpawnPos ~= nil then
						local RecallTime = recall.duration-(GetGameTimer()-recall.start)+GetLatency()/2000
						local HitTime = 1+GetDistance(SpawnPos)/2000+GetLatency()/2000
						if RecallTime < HitTime and HitTime < 7.8 and HitTime-RecallTime < 1.5 then
							CastSkillShot(_R, GetOrigin(SpawnPos))
						end
					end
				elseif GetObjectName(myHero) == "Jinx" then
					local JinxRDmg = math.max(50*GetCastLevel(myHero,_R)+75+GetBonusDmg(myHero)+(0.05*GetCastLevel(myHero,_R)+0.2)*(GetMaxHP(recall.champ)-GetCurrentHP(recall.champ)))
					if JinxRDmg >= (GetCurrentHP(recall.champ)+GetMagicResist(recall.champ)+GetHPRegen(recall.champ)*20) and SpawnPos ~= nil then
						local RecallTime = recall.duration-(GetGameTimer()-recall.start)+GetLatency()/2000
						JinxRSpeed = GetDistance(SpawnPos) > 1350 and (2295000+(GetDistance(SpawnPos)-1350)*2200)/GetDistance(SpawnPos) or 700
						local HitTime = 0.6+GetDistance(SpawnPos)/JinxRSpeed+GetLatency()/2000
						if RecallTime < HitTime and HitTime < 7.8 and HitTime-RecallTime < 1.5 then
							CastSkillShot(_R, GetOrigin(SpawnPos))
						end
					end
				end
			end
		end
	end
end
OnProcessRecall(function(unit,recall)
	if GetTeam(unit) ~= GetTeam(myHero) then 
		if recall.isStart then
			table.insert(Recalling, {champ = unit, start = GetGameTimer(), duration = (recall.totalTime/1000)})
		else
			for i, recall in pairs(Recalling) do
				if recall.champ == unit then
					table.remove(Recalling, i)
				end
			end
		end
	end
end)

Heal = (GetCastName(myHero,SUMMONER_1):lower():find("summonerheal") and SUMMONER_1 or (GetCastName(myHero,SUMMONER_2):lower():find("summonerheal") and SUMMONER_2 or nil))
Barrier = (GetCastName(myHero,SUMMONER_1):lower():find("summonerbarrier") and SUMMONER_1 or (GetCastName(myHero,SUMMONER_2):lower():find("summonerbarrier") and SUMMONER_2 or nil))

OnTick(function(myHero)
	target = GetCurrentTarget()
	BaseUlt()
	Items()
	LevelUp()
	SS()
end)

OnDraw(function(myHero)
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			DrawAA = WorldToScreen(1,GetOrigin(enemy).x, GetOrigin(enemy).y, GetOrigin(enemy).z)
			AALeft = (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy))/(GetBonusDmg(myHero)+GetBaseDamage(myHero))
			DrawText("AA Left: "..tostring(math.ceil(AALeft)), 17, DrawAA.x-38, DrawAA.y+10, 0xff00bfff)
		end
	end
end)

function Items()
	if Mode() == "Combo" then
		if (GetCurrentHP(target) / GetMaxHP(target)) <= UtilityMenu.Items.OI:Value() then
			if UtilityMenu.Items.UseBC:Value() then
				if GetItemSlot(myHero, 3144) >= 1 and ValidTarget(target, 550) then
					if CanUseSpell(myHero, GetItemSlot(myHero, 3144)) == READY then
						CastTargetSpell(target, GetItemSlot(myHero, 3144))
					end
				end
			end
			if UtilityMenu.Items.UseBOTRK:Value() then
				if GetItemSlot(myHero, 3153) >= 1 and ValidTarget(target, 550) then
					if CanUseSpell(myHero, GetItemSlot(myHero, 3153)) == READY then
						CastTargetSpell(target, GetItemSlot(myHero, 3153))
					end
				end
			end
			if UtilityMenu.Items.UseHG:Value() then
				if GetItemSlot(myHero, 3146) >= 1 and ValidTarget(target, 700) then
					if CanUseSpell(myHero, GetItemSlot(myHero, 3146)) == READY then
						CastTargetSpell(target, GetItemSlot(myHero, 3146))
					end
				end
			end
		end
		if UtilityMenu.Items.UseMS:Value() then
			if GetItemSlot(myHero, 3139) >= 1 then
				if CanUseSpell(myHero, GetItemSlot(myHero, 3139)) == READY then
					if GotBuff(myHero, "veigareventhorizonstun") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "slow") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "knockup") > 0 then
						CastSpell(GetItemSlot(myHero, 3139))
					end
				end
			end
		end
		if UtilityMenu.Items.UseQS:Value() then
			if GetItemSlot(myHero, 3140) >= 1 then
				if CanUseSpell(myHero, GetItemSlot(myHero, 3140)) == READY then
					if GotBuff(myHero, "veigareventhorizonstun") > 0 or GotBuff(myHero, "caitlynyordletrapsight") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "slow") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "knockup") > 0 then
						CastSpell(GetItemSlot(myHero, 3140))
					end
				end
			end
		end
	end
end

function LevelUp()
	if UtilityMenu.LevelUp.LvlUp:Value() then
		if "Ashe" == GetObjectName(myHero) then
			leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif "Caitlyn" == GetObjectName(myHero) or "Draven" == GetObjectName(myHero) or "Jhin" == GetObjectName(myHero) or "Jinx" == GetObjectName(myHero) then
			leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif "Corki" == GetObjectName(myHero) or "Ezreal" == GetObjectName(myHero) then
			leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif "Kalista" == GetObjectName(myHero) then
			leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		end
	end
end

function SS()
	if UtilityMenu.SS.UseHeal:Value() then
		if Heal then
			if (GetCurrentHP(myHero)/GetMaxHP(myHero))*100 <= UtilityMenu.SS.HealMe:Value() then
				CastSpell(Heal)
			end
			for _, ally in pairs(GetAllyHeroes()) do
				if ValidTarget(ally, 850) then
					if (GetCurrentHP(ally)/GetMaxHP(ally))*100 <= UtilityMenu.SS.HealAlly:Value() then
						CastTargetSpell(ally, Heal)
					end
				end
			end
		end
	end
	if UtilityMenu.SS.UseBarrier:Value() then
		if Barrier then
			if (GetCurrentHP(myHero)/GetMaxHP(myHero))*100 <= UtilityMenu.SS.BarrierMe:Value() then
				CastSpell(Barrier)
			end
		end
	end
end

-- Ashe

if "Ashe" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Ashe loaded successfully!")
local AsheMenu = Menu("[GoS-U] Ashe", "[GoS-U] Ashe")
AsheMenu:Menu("Auto", "Auto")
AsheMenu.Auto:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
AsheMenu:Menu("Combo", "Combo")
AsheMenu.Combo:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.Combo:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.Combo:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.Combo:Slider('Distance','Distance: R', 2000, 100, 10000, 100)
AsheMenu.Combo:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
AsheMenu.Combo:Slider('HP','HP-Manager: R', 40, 0, 100, 5)
AsheMenu:Menu("Harass", "Harass")
AsheMenu.Harass:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.Harass:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
AsheMenu:Menu("KillSteal", "KillSteal")
AsheMenu.KillSteal:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.KillSteal:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.KillSteal:Slider('Distance','Distance: R', 2000, 100, 10000, 100)
AsheMenu:Menu("LaneClear", "LaneClear")
AsheMenu.LaneClear:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.LaneClear:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
AsheMenu:Menu("AntiGapcloser", "Anti-Gapcloser")
AsheMenu.AntiGapcloser:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.AntiGapcloser:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.AntiGapcloser:Slider('DistanceW','Distance: W', 200, 25, 500, 25)
AsheMenu.AntiGapcloser:Slider('DistanceR','Distance: R', 200, 25, 500, 25)
AsheMenu:Menu("Interrupter", "Interrupter")
AsheMenu.Interrupter:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.Interrupter:Slider('Distance','Distance: R', 400, 50, 1000, 50)
AsheMenu:Menu("Prediction", "Prediction")
AsheMenu.Prediction:DropDown("PredictionW", "Prediction: W", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
AsheMenu.Prediction:DropDown("PredictionR", "Prediction: R", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
AsheMenu:Menu("Drawings", "Drawings")
AsheMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
AsheMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
AsheMenu.Drawings:Boolean('DrawDMG', 'Draw Max QWR Damage', true)

local AsheW = { range = 1200, radius = 20, width = 40, speed = 2000, delay = 0.25, type = "line", collision = true, source = myHero, col = {"minion","yasuowall"}}
local AsheR = { range = AsheMenu.Combo.Distance:Value(), radius = 125, width = 250, speed = 1600, delay = 0.25, type = "line", collision = false, source = myHero }

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	LaneClear()
	AntiGapcloser()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if AsheMenu.Drawings.DrawW:Value() then DrawCircle(pos,AsheW.range,1,25,0xff4169e1) end
if AsheMenu.Drawings.DrawR:Value() then DrawCircle(pos,AsheR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local QDmg = (0.05*GetCastLevel(myHero,_Q)+1)+(GetBonusDmg(myHero)+GetBaseDamage(myHero))
		local WDmg = (15*GetCastLevel(myHero,_W)+5)+(GetBonusDmg(myHero)+GetBaseDamage(myHero))
		local RDmg = (200*GetCastLevel(myHero,_R))+(GetBonusAP(myHero))
		local ComboDmg = QDmg + WDmg + RDmg
		local WRDmg = WDmg + RDmg
		local QRDmg = QDmg + RDmg
		local QWDmg = QDmg + WDmg
		if ValidTarget(enemy) then
			if AsheMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	CastSpell(_Q)
end
function useW(target)
	if GetDistance(target) < AsheW.range then
		if AsheMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif AsheMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),AsheW.speed,AsheW.delay*1000,AsheW.range,AsheW.width,true,true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif AsheMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,AsheW,false,true)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif AsheMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="Volley", range=AsheW.range, speed=AsheW.speed, delay=AsheW.delay, width=AsheW.width, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(AsheW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif AsheMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetLinearAOEPrediction(target,AsheW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useR(target)
	if GetDistance(target) < AsheR.range then
		if AsheMenu.Prediction.PredictionR:Value() == 1 then
			CastSkillShot(_R,GetOrigin(target))
		elseif AsheMenu.Prediction.PredictionR:Value() == 2 then
			local RPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),AsheR.speed,AsheR.delay*1000,AsheR.range,AsheR.width,false,false)
			if RPred.HitChance == 1 then
				CastSkillShot(_R, RPred.PredPos)
			end
		elseif AsheMenu.Prediction.PredictionR:Value() == 3 then
			local RPred = _G.gPred:GetPrediction(target,myHero,AsheR,false,false)
			if RPred and RPred.HitChance >= 3 then
				CastSkillShot(_R, RPred.CastPosition)
			end
		elseif AsheMenu.Prediction.PredictionR:Value() == 4 then
			local RSpell = IPrediction.Prediction({name="EnchantedCrystalArrow", range=AsheR.range, speed=AsheR.speed, delay=AsheR.delay, width=AsheR.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(AsheR.range)
			local x, y = RSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_R, y.x, y.y, y.z)
			end
		elseif AsheMenu.Prediction.PredictionR:Value() == 5 then
			local RPrediction = GetLinearAOEPrediction(target,AsheR)
			if RPrediction.hitChance > 0.9 then
				CastSkillShot(_R, RPrediction.castPos)
			end
		end
	end
end

-- Auto

function Auto()
	if AsheMenu.Auto.UseW:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AsheMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, AsheW.range) then
					useW(target)
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if AsheMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, GetRange(myHero)+GetHitBox(myHero)) then
					if GotBuff(myHero,"asheqcastready") == 4 then
						useQ(target)
					end
				end
			end
		end
		if AsheMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY and AA == true then
				if ValidTarget(target, AsheW.range) then
					useW(target)
				end
			end
		end
		if AsheMenu.Combo.UseR:Value() then
			if CanUseSpell(myHero,_R) == READY then
				if ValidTarget(target, AsheR.range) then
					if 100*GetCurrentHP(target)/GetMaxHP(target) < AsheMenu.Combo.HP:Value() then
						if EnemiesAround(myHero, AsheR.range+GetRange(myHero)) >= AsheMenu.Combo.X:Value() then
							useR(target)
						end
					end
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if AsheMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AsheMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY then
					if ValidTarget(target, GetRange(myHero)+GetHitBox(myHero)) then
						if GotBuff(myHero,"asheqcastready") == 4 then
							useQ(target)
						end
					end
				end
			end
		end
		if AsheMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AsheMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY and AA == true then
					if ValidTarget(target, AsheW.range) then
						useW(target)
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if AsheMenu.KillSteal.UseW:Value() then
				if ValidTarget(enemy, AsheW.range) then
					local AsheWDmg = (15*GetCastLevel(myHero,_W)+5)+(GetBonusDmg(myHero)+GetBaseDamage(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < AsheWDmg then
						useW(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if AsheMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, AsheMenu.KillSteal.Distance:Value()) then
					local AsheRDmg = (200*GetCastLevel(myHero,_R))+(GetBonusAP(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < AsheRDmg then
						useR(enemy)
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if AsheMenu.LaneClear.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AsheMenu.LaneClear.MP:Value() then
				if CanUseSpell(myHero,_W) == READY and AA == true then
					local BestPos, BestHit = GetFarmPosition(AsheW.range, 230, MINION_ENEMY)
					if BestPos and BestHit > 3 then
						CastSkillShot(_W, BestPos)
					end
				end
			end
		end
		if AsheMenu.LaneClear.UseQ:Value() then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AsheMenu.LaneClear.MP:Value() then
						if ValidTarget(minion, GetRange(myHero)+GetHitBox(myHero)) then
							if CanUseSpell(myHero,_Q) == READY then
								CastSpell(_Q)
							end
						end
					end
				end
			end
		end
	end
end

-- Anti-Gapcloser

function AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if AsheMenu.AntiGapcloser.UseW:Value() then
				if ValidTarget(antigap, AsheMenu.AntiGapcloser.DistanceW:Value()) then
					useW(antigap)
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if AsheMenu.AntiGapcloser.UseR:Value() then
				if ValidTarget(antigap, AsheMenu.AntiGapcloser.DistanceR:Value()) then
					useR(antigap)
				end
			end
		end
	end
end

-- Interrupter

OnProcessSpell(function(unit, spell)
	if AsheMenu.Interrupter.UseR:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, AsheMenu.Interrupter.Distance:Value()) then
				if CanUseSpell(myHero,_R) == READY then
					local UnitName = GetObjectName(enemy)
					local UnitChanellingSpells = CHANELLING_SPELLS[UnitName]
					local UnitGapcloserSpells = GAPCLOSER_SPELLS[UnitName]
					if UnitChanellingSpells then
						for _, slot in pairs(UnitChanellingSpells) do
							if spell.name == GetCastName(enemy, slot) then useR(enemy) end
						end
					elseif UnitGapcloserSpells then
						for _, slot in pairs(UnitGapcloserSpells) do
							if spell.name == GetCastName(enemy, slot) then useR(enemy) end
						end
					end
				end
			end
		end
    end
end)

-- Caitlyn

elseif "Caitlyn" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Caitlyn loaded successfully!")
local CaitlynMenu = Menu("[GoS-U] Caitlyn", "[GoS-U] Caitlyn")
CaitlynMenu:Menu("Auto", "Auto")
CaitlynMenu.Auto:Boolean('UseQ', 'Use Q [Piltover Peacemaker]', true)
CaitlynMenu.Auto:Boolean('UseW', 'Use W [Yordle Snap Trap]', true)
CaitlynMenu.Auto:DropDown("ModeQ", "Cast Mode: Q", 2, {"Standard", "On Immobile"})
CaitlynMenu.Auto:DropDown("ModeW", "Cast Mode: W", 2, {"Standard", "On Immobile"})
CaitlynMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
CaitlynMenu:Menu("Combo", "Combo")
CaitlynMenu.Combo:Boolean('UseQ', 'Use Q [Piltover Peacemaker]', true)
CaitlynMenu.Combo:Boolean('UseW', 'Use W [Yordle Snap Trap]', true)
CaitlynMenu.Combo:Boolean('UseE', 'Use E [90 Caliber Net]', true)
CaitlynMenu.Combo:DropDown("ModeQ", "Cast Mode: Q", 1, {"Standard", "On Immobile"})
CaitlynMenu.Combo:DropDown("ModeW", "Cast Mode: W", 1, {"Standard", "On Immobile"})
CaitlynMenu:Menu("Harass", "Harass")
CaitlynMenu.Harass:Boolean('UseQ', 'Use Q [Piltover Peacemaker]', true)
CaitlynMenu.Harass:Boolean('UseW', 'Use W [Yordle Snap Trap]', true)
CaitlynMenu.Harass:Boolean('UseE', 'Use E [90 Caliber Net]', true)
CaitlynMenu.Harass:DropDown("ModeQ", "Cast Mode: Q", 1, {"Standard", "On Immobile"})
CaitlynMenu.Harass:DropDown("ModeW", "Cast Mode: W", 2, {"Standard", "On Immobile"})
CaitlynMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
CaitlynMenu:Menu("KillSteal", "KillSteal")
CaitlynMenu.KillSteal:Boolean('UseQ', 'Use Q [Piltover Peacemaker]', true)
CaitlynMenu.KillSteal:Boolean('UseR', 'Draw Killable With R', true)
CaitlynMenu:Menu("LaneClear", "LaneClear")
CaitlynMenu.LaneClear:Boolean('UseQ', 'Use Q [Piltover Peacemaker]', true)
CaitlynMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
CaitlynMenu:Menu("AntiGapcloser", "Anti-Gapcloser")
CaitlynMenu.AntiGapcloser:Boolean('UseW', 'Use W [Yordle Snap Trap]', true)
CaitlynMenu.AntiGapcloser:Boolean('UseE', 'Use E [90 Caliber Net]', true)
CaitlynMenu.AntiGapcloser:Slider('DistanceW','Distance: W', 300, 25, 500, 25)
CaitlynMenu.AntiGapcloser:Slider('DistanceE','Distance: E', 200, 25, 500, 25)
CaitlynMenu:Menu("Interrupter", "Interrupter")
CaitlynMenu.Interrupter:Boolean('UseW', 'Use W [Yordle Snap Trap]', true)
CaitlynMenu.Interrupter:Slider('Distance','Distance: W', 500, 50, 1000, 50)
CaitlynMenu:Menu("Prediction", "Prediction")
CaitlynMenu.Prediction:DropDown("PredictionQ", "Prediction: Q", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
CaitlynMenu.Prediction:DropDown("PredictionW", "Prediction: W", 5, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
CaitlynMenu.Prediction:DropDown("PredictionE", "Prediction: E", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
CaitlynMenu:Menu("Drawings", "Drawings")
CaitlynMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
CaitlynMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
CaitlynMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
CaitlynMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
CaitlynMenu.Drawings:Boolean('DrawDMG', 'Draw Max QWER Damage', true)

local CaitlynQ = { range = 1250, radius = 60, width = 120, speed = 2200, delay = 0.625, type = "line", collision = false, source = myHero, col = {"yasuowall"}}
local CaitlynW = { range = 800, radius = 75, width = 150, speed = math.huge, delay = 0.25, type = "circular", collision = false, source = myHero }
local CaitlynE = { range = 750, radius = 65, width = 130, speed = 1500, delay = 0.25, type = "line", collision = true, source = myHero, col = {"minion","yasuowall"}}
local CaitlynR = { range = GetCastRange(myHero,_R) }

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	LaneClear()
	AntiGapcloser()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if CaitlynMenu.Drawings.DrawQ:Value() then DrawCircle(pos,CaitlynQ.range,1,25,0xff00bfff) end
if CaitlynMenu.Drawings.DrawW:Value() then DrawCircle(pos,CaitlynW.range,1,25,0xff4169e1) end
if CaitlynMenu.Drawings.DrawE:Value() then DrawCircle(pos,CaitlynE.range,1,25,0xff1e90ff) end
if CaitlynMenu.Drawings.DrawR:Value() then DrawCircle(pos,CaitlynR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	local QDmg = (40*GetCastLevel(myHero,_Q)-10)+((0.1*GetCastLevel(myHero,_Q)+1.2)*(GetBonusDmg(myHero)+GetBaseDamage(myHero)))
	local WDmg = (50*GetCastLevel(myHero,_W)-10)+((0.15*GetCastLevel(myHero,_W)+0.25)*GetBonusDmg(myHero))
	local EDmg = (40*GetCastLevel(myHero,_E)+30)+(0.8*GetBonusAP(myHero))
	local RDmg = (225*GetCastLevel(myHero,_R)+25)+(2*GetBonusDmg(myHero))
	local ComboDmg = QDmg + WDmg + EDmg + RDmg
	local WERDmg = WDmg + EDmg + RDmg
	local QERDmg = QDmg + EDmg + RDmg
	local QWRDmg = QDmg + WDmg + RDmg
	local QWEDmg = QDmg + WDmg + EDmg
	local ERDmg = EDmg + RDmg
	local WRDmg = WDmg + RDmg
	local QRDmg = QDmg + RDmg
	local WEDmg = WDmg + EDmg
	local QEDmg = QDmg + EDmg
	local QWDmg = QDmg + WDmg
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			if CaitlynMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWEDmg), 0xff008080)
				elseif Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ERDmg), 0xff008080)
				elseif Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	if GetDistance(target) < CaitlynQ.range then
		if CaitlynMenu.Prediction.PredictionQ:Value() == 1 then
			CastSkillShot(_Q,GetOrigin(target))
		elseif CaitlynMenu.Prediction.PredictionQ:Value() == 2 then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),CaitlynQ.speed,CaitlynQ.delay*1000,CaitlynQ.range,CaitlynQ.width,false,true)
			if QPred.HitChance == 1 then
				CastSkillShot(_Q, QPred.PredPos)
			end
		elseif CaitlynMenu.Prediction.PredictionQ:Value() == 3 then
			local qPred = _G.gPred:GetPrediction(target,myHero,CaitlynQ,false,true)
			if qPred and qPred.HitChance >= 3 then
				CastSkillShot(_Q, qPred.CastPosition)
			end
		elseif CaitlynMenu.Prediction.PredictionQ:Value() == 4 then
			local QSpell = IPrediction.Prediction({name="CaitlynPiltoverPeacemaker", range=CaitlynQ.range, speed=CaitlynQ.speed, delay=CaitlynQ.delay, width=CaitlynQ.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(CaitlynQ.range)
			local x, y = QSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_Q, y.x, y.y, y.z)
			end
		elseif CaitlynMenu.Prediction.PredictionQ:Value() == 5 then
			local QPrediction = GetLinearAOEPrediction(target,CaitlynQ)
			if QPrediction.hitChance > 0.9 then
				CastSkillShot(_Q, QPrediction.castPos)
			end
		end
	end
end
function useW(target)
	if GetDistance(target) < CaitlynW.range then
		if CaitlynMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif CaitlynMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),CaitlynW.speed,CaitlynW.delay*1000,CaitlynW.range,CaitlynW.width,false,true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif CaitlynMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,CaitlynW,true,false)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif CaitlynMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="CaitlynYordleTrap", range=CaitlynW.range, speed=CaitlynW.speed, delay=CaitlynW.delay, width=CaitlynW.width, type="circular", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(CaitlynW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif CaitlynMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetCircularAOEPrediction(target,CaitlynW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useE(target)
	if GetDistance(target) < CaitlynE.range then
		if CaitlynMenu.Prediction.PredictionE:Value() == 1 then
			CastSkillShot(_E,GetOrigin(target))
		elseif CaitlynMenu.Prediction.PredictionE:Value() == 2 then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),CaitlynE.speed,CaitlynE.delay*1000,CaitlynE.range,CaitlynE.width,true,false)
			if EPred.HitChance == 1 then
				CastSkillShot(_E, EPred.PredPos)
			end
		elseif CaitlynMenu.Prediction.PredictionE:Value() == 3 then
			local EPred = _G.gPred:GetPrediction(target,myHero,CaitlynE,false,true)
			if EPred and EPred.HitChance >= 3 then
				CastSkillShot(_E, EPred.CastPosition)
			end
		elseif CaitlynMenu.Prediction.PredictionE:Value() == 4 then
			local ESpell = IPrediction.Prediction({name="CaitlynEntrapmentMissile", range=CaitlynE.range, speed=CaitlynE.speed, delay=CaitlynE.delay, width=CaitlynE.width, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(CaitlynE.range)
			local x, y = ESpell:Predict(target)
			if x > 2 then
				CastSkillShot(_E, y.x, y.y, y.z)
			end
		elseif CaitlynMenu.Prediction.PredictionE:Value() == 5 then
			local EPrediction = GetLinearAOEPrediction(target,CaitlynE)
			if EPrediction.hitChance > 0.9 then
				CastSkillShot(_E, EPrediction.castPos)
			end
		end
	end
end

-- Auto

function Auto()
	if CaitlynMenu.Auto.UseQ:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CaitlynMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, CaitlynQ.range) then
					if CaitlynMenu.Auto.ModeQ:Value() == 1 then
						useQ(target)
					elseif CaitlynMenu.Auto.ModeQ:Value() == 2 then
						if GotBuff(target, "veigareventhorizonstun") > 0 or GotBuff(target, "Stun") > 0 or GotBuff(target, "Taunt") > 0 or GotBuff(target, "Slow") > 0 or GotBuff(target, "Snare") > 0 or GotBuff(target, "Charm") > 0 or GotBuff(target, "Suppression") > 0 or GotBuff(target, "Flee") > 0 or GotBuff(target, "Knockup") > 0 then
							useQ(target)
						end
					end
				end
			end
		end
	end
	if CaitlynMenu.Auto.UseW:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CaitlynMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, CaitlynW.range) then
					if CaitlynMenu.Auto.ModeW:Value() == 1 then
						useW(target)
					elseif CaitlynMenu.Auto.ModeW:Value() == 2 then
						if GotBuff(target, "veigareventhorizonstun") > 0 or GotBuff(target, "Stun") > 0 or GotBuff(target, "Taunt") > 0 or GotBuff(target, "Slow") > 0 or GotBuff(target, "Snare") > 0 or GotBuff(target, "Charm") > 0 or GotBuff(target, "Suppression") > 0 or GotBuff(target, "Flee") > 0 or GotBuff(target, "Knockup") > 0 then
							useW(target)
						end
					end
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if CaitlynMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY and AA == true then
				if ValidTarget(target, CaitlynQ.range) then
					if CaitlynMenu.Combo.ModeQ:Value() == 1 then
						useQ(target)
					elseif CaitlynMenu.Combo.ModeQ:Value() == 2 then
						if GotBuff(target, "veigareventhorizonstun") > 0 or GotBuff(target, "Stun") > 0 or GotBuff(target, "Taunt") > 0 or GotBuff(target, "Slow") > 0 or GotBuff(target, "Snare") > 0 or GotBuff(target, "Charm") > 0 or GotBuff(target, "Suppression") > 0 or GotBuff(target, "Flee") > 0 or GotBuff(target, "Knockup") > 0 then
							useQ(target)
						end
					end
				end
			end
		end
		if CaitlynMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY and AA == true then
				if ValidTarget(target, CaitlynW.range) then
					if CaitlynMenu.Combo.ModeW:Value() == 1 then
						useW(target)
					elseif CaitlynMenu.Combo.ModeW:Value() == 2 then
						if GotBuff(target, "veigareventhorizonstun") > 0 or GotBuff(target, "Stun") > 0 or GotBuff(target, "Taunt") > 0 or GotBuff(target, "Slow") > 0 or GotBuff(target, "Snare") > 0 or GotBuff(target, "Charm") > 0 or GotBuff(target, "Suppression") > 0 or GotBuff(target, "Flee") > 0 or GotBuff(target, "Knockup") > 0 then
							useW(target)
						end
					end
				end
			end
		end
		if CaitlynMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY then
				if ValidTarget(target, CaitlynE.range+GetHitBox(myHero)) then
					useE(target)
				elseif ValidTarget(target, 400+GetRange(myHero)+GetHitBox(myHero)) then
					local EPos = Vector(myHero)+(Vector(myHero)-Vector(target))
					CastSkillShot(_E, EPos)
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if CaitlynMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CaitlynMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					if ValidTarget(target, CaitlynQ.range) then
						if CaitlynMenu.Harass.ModeQ:Value() == 1 then
							useQ(target)
						elseif CaitlynMenu.Harass.ModeQ:Value() == 2 then
							if GotBuff(target, "veigareventhorizonstun") > 0 or GotBuff(target, "Stun") > 0 or GotBuff(target, "Taunt") > 0 or GotBuff(target, "Slow") > 0 or GotBuff(target, "Snare") > 0 or GotBuff(target, "Charm") > 0 or GotBuff(target, "Suppression") > 0 or GotBuff(target, "Flee") > 0 or GotBuff(target, "Knockup") > 0 then
								useQ(target)
							end
						end
					end
				end
			end
		end
		if CaitlynMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CaitlynMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY and AA == true then
					if ValidTarget(target, CaitlynW.range) then
						if CaitlynMenu.Harass.ModeW:Value() == 1 then
							useW(target)
						elseif CaitlynMenu.Harass.ModeW:Value() == 2 then
							if GotBuff(target, "veigareventhorizonstun") > 0 or GotBuff(target, "Stun") > 0 or GotBuff(target, "Taunt") > 0 or GotBuff(target, "Slow") > 0 or GotBuff(target, "Snare") > 0 or GotBuff(target, "Charm") > 0 or GotBuff(target, "Suppression") > 0 or GotBuff(target, "Flee") > 0 or GotBuff(target, "Knockup") > 0 then
								useW(target)
							end
						end
					end
				end
			end
		end
		if CaitlynMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CaitlynMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, CaitlynE.range+GetHitBox(myHero)) then
						useE(target)
					elseif ValidTarget(target, 400+GetRange(myHero)+GetHitBox(myHero)) then
						local EPos = Vector(myHero)+(Vector(myHero)-Vector(target))
						CastSkillShot(_E, EPos)
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_R) == READY then
			if CaitlynMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, CaitlynR.range) then
					local CaitlynRDmg = (225*GetCastLevel(myHero,_R)+25)+(2*GetBonusDmg(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < CaitlynRDmg then
						DrawCircle(enemy,200,5,25,0xffffd700)
					end
				end
			end
		elseif CanUseSpell(myHero,_Q) == READY then
			if CaitlynMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, CaitlynQ.range) then
					local CaitlynQDmg = ((40*GetCastLevel(myHero,_Q)-10)+((0.1*GetCastLevel(myHero,_Q)+1.2)*(GetBonusDmg(myHero)+GetBaseDamage(myHero))))/3
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < CaitlynQDmg then
						useQ(enemy)
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if CaitlynMenu.LaneClear.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CaitlynMenu.LaneClear.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					local BestPos, BestHit = GetLineFarmPosition(CaitlynQ.range, CaitlynQ.range, MINION_ENEMY)
					if BestPos and BestHit > 4 then
						CastSkillShot(_Q, BestPos)
					end
				end
			end
		end
	end
end

-- Anti-Gapcloser

function AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if CaitlynMenu.AntiGapcloser.UseW:Value() then
				if ValidTarget(antigap, CaitlynMenu.AntiGapcloser.DistanceW:Value()) then
					useW(antigap)
				end
			end
		elseif CanUseSpell(myHero,_E) == READY then
			if CaitlynMenu.AntiGapcloser.UseE:Value() then
				if ValidTarget(antigap, CaitlynMenu.AntiGapcloser.DistanceE:Value()) then
					local EPos = Vector(myHero)+(Vector(myHero)-Vector(antigap))
					CastSkillShot(_E, EPos)
				end
			end
		end
	end
end

-- Interrupter

OnProcessSpell(function(unit, spell)
	if CaitlynMenu.Interrupter.UseW:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, CaitlynMenu.Interrupter.Distance:Value()) then
				if CanUseSpell(myHero,_W) == READY then
					local UnitName = GetObjectName(enemy)
					local UnitChanellingSpells = CHANELLING_SPELLS[UnitName]
					local UnitGapcloserSpells = GAPCLOSER_SPELLS[UnitName]
					if UnitGapcloserSpells then
						for _, slot in pairs(UnitGapcloserSpells) do
							if spell.name == GetCastName(enemy, slot) then useW(enemy) end
						end
					end
				end
			end
		end
    end
end)

-- Corki

elseif "Corki" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Corki loaded successfully!")
local CorkiMenu = Menu("[GoS-U] Corki", "[GoS-U] Corki")
CorkiMenu:Menu("Auto", "Auto")
CorkiMenu.Auto:Boolean('UseQ', 'Use Q [Phosphorus Bomb]', true)
CorkiMenu.Auto:Boolean('UseR', 'Use R [Missile Barrage]', true)
CorkiMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
CorkiMenu:Menu("Combo", "Combo")
CorkiMenu.Combo:Boolean('UseQ', 'Use Q [Phosphorus Bomb]', true)
CorkiMenu.Combo:Boolean('UseW', 'Use W [Valkyrie]', true)
CorkiMenu.Combo:Boolean('UseE', 'Use E [Gatling Gun]', true)
CorkiMenu.Combo:Boolean('UseR', 'Use R [Missile Barrage]', true)
CorkiMenu:Menu("Harass", "Harass")
CorkiMenu.Harass:Boolean('UseQ', 'Use Q [Phosphorus Bomb]', true)
CorkiMenu.Harass:Boolean('UseW', 'Use W [Valkyrie]', true)
CorkiMenu.Harass:Boolean('UseE', 'Use E [Gatling Gun]', true)
CorkiMenu.Harass:Boolean('UseR', 'Use R [Missile Barrage]', true)
CorkiMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
CorkiMenu:Menu("KillSteal", "KillSteal")
CorkiMenu.KillSteal:Boolean('UseQ', 'Use Q [Phosphorus Bomb]', true)
CorkiMenu.KillSteal:Boolean('UseR', 'Use R [Missile Barrage]', true)
CorkiMenu:Menu("LaneClear", "LaneClear")
CorkiMenu.LaneClear:Boolean('UseQ', 'Use Q [Phosphorus Bomb]', true)
CorkiMenu.LaneClear:Boolean('UseE', 'Use E [Gatling Gun]', true)
CorkiMenu.LaneClear:Boolean('UseR', 'Use R [Missile Barrage]', true)
CorkiMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
CorkiMenu:Menu("Prediction", "Prediction")
CorkiMenu.Prediction:DropDown("PredictionQ", "Prediction: Q", 5, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
CorkiMenu.Prediction:DropDown("PredictionW", "Prediction: W", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
CorkiMenu.Prediction:DropDown("PredictionR", "Prediction: R", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
CorkiMenu:Menu("Drawings", "Drawings")
CorkiMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
CorkiMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
CorkiMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
CorkiMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
CorkiMenu.Drawings:Boolean('DrawDMG', 'Draw Max QWER Damage', true)

local CorkiQ = { range = 825, radius = 250, width = 500, speed = 1000, delay = 0.25, type = "circular", collision = false, source = myHero }
local CorkiW = { range = GetCastRange(myHero,_W), radius = 100, width = 200, speed = 1500, delay = 0, type = "line", collision = false, source = myHero }
local CorkiE = { range = 600 }
local CorkiR = { range = 1225, radius = 35, width = 70, speed = 1950, delay = 0.175, type = "line", collision = true, source = myHero, col = {"minion","yasuowall"}}

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	LaneClear()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if CorkiMenu.Drawings.DrawQ:Value() then DrawCircle(pos,CorkiQ.range,1,25,0xff00bfff) end
if CorkiMenu.Drawings.DrawW:Value() then DrawCircle(pos,CorkiW.range,1,25,0xff4169e1) end
if CorkiMenu.Drawings.DrawE:Value() then DrawCircle(pos,CorkiE.range,1,25,0xff1e90ff) end
if CorkiMenu.Drawings.DrawR:Value() then DrawCircle(pos,CorkiR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local QDmg = (45*GetCastLevel(myHero,_Q)+30)+(0.5*GetBonusDmg(myHero))+(0.5*GetBonusAP(myHero))
		local WDmg = (75*GetCastLevel(myHero,_W)+75)+GetBonusAP(myHero)
		local EDmg = (60*GetCastLevel(myHero,_E)+20)+(1.6*GetBonusDmg(myHero))
		local RDmg = (50*GetCastLevel(myHero,_R)+100)+((0.6*GetCastLevel(myHero,_R)-0.3)*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))+(0.4*GetBonusAP(myHero))
		local ComboDmg = QDmg + WDmg + EDmg + RDmg
		local WERDmg = WDmg + EDmg + RDmg
		local QERDmg = QDmg + EDmg + RDmg
		local QWRDmg = QDmg + WDmg + RDmg
		local QWEDmg = QDmg + WDmg + EDmg
		local ERDmg = EDmg + RDmg
		local WRDmg = WDmg + RDmg
		local QRDmg = QDmg + RDmg
		local WEDmg = WDmg + EDmg
		local QEDmg = QDmg + EDmg
		local QWDmg = QDmg + WDmg
		if ValidTarget(enemy) then
			if CorkiMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWEDmg), 0xff008080)
				elseif Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ERDmg), 0xff008080)
				elseif Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	if GetDistance(target) < CorkiQ.range then
		if CorkiMenu.Prediction.PredictionQ:Value() == 1 then
			CastSkillShot(_Q,GetOrigin(target))
		elseif CorkiMenu.Prediction.PredictionQ:Value() == 2 then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),CorkiQ.speed,CorkiQ.delay*1000,CorkiQ.range,CorkiQ.radius,false,true)
			if QPred.HitChance == 1 then
				CastSkillShot(_Q, QPred.PredPos)
			end
		elseif CorkiMenu.Prediction.PredictionQ:Value() == 3 then
			local qPred = _G.gPred:GetPrediction(target,myHero,CorkiQ,true,false)
			if qPred and qPred.HitChance >= 3 then
				CastSkillShot(_Q, qPred.CastPosition)
			end
		elseif CorkiMenu.Prediction.PredictionQ:Value() == 4 then
			local QSpell = IPrediction.Prediction({name="PhosphorusBomb", range=CorkiQ.range, speed=CorkiQ.speed, delay=CorkiQ.delay, width=CorkiQ.radius, type="circular", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(CorkiQ.range)
			local x, y = QSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_Q, y.x, y.y, y.z)
			end
		elseif CorkiMenu.Prediction.PredictionQ:Value() == 5 then
			local QPrediction = GetCircularAOEPrediction(target,CorkiQ)
			if QPrediction.hitChance > 0.9 then
				CastSkillShot(_Q, QPrediction.castPos)
			end
		end
	end
end
function useW(target)
	if GetDistance(target) < CorkiW.range then
		if CorkiMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif CorkiMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),CorkiW.speed,CorkiW.delay*1000,CorkiW.range,CorkiW.width,false,true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif CorkiMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,CorkiW,true,false)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif CorkiMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="CarpetBomb", range=CorkiW.range, speed=CorkiW.speed, delay=CorkiW.delay, width=CorkiW.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(CorkiW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif CorkiMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetLinearAOEPrediction(target,CorkiW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useE(target)
	CastSkillShot(_E, GetOrigin(target))
end
function useR(target)
	if GetDistance(target) < CorkiR.range then
		if CorkiMenu.Prediction.PredictionR:Value() == 1 then
			CastSkillShot(_R,GetOrigin(target))
		elseif CorkiMenu.Prediction.PredictionR:Value() == 2 then
			local RPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),CorkiR.speed,CorkiR.delay*1000,CorkiR.range,CorkiR.width,true,false)
			if RPred.HitChance == 1 then
				CastSkillShot(_R, RPred.PredPos)
			end
		elseif CorkiMenu.Prediction.PredictionR:Value() == 3 then
			local RPred = _G.gPred:GetPrediction(target,myHero,CorkiR,false,true)
			if RPred and RPred.HitChance >= 3 then
				CastSkillShot(_R, RPred.CastPosition)
			end
		elseif CorkiMenu.Prediction.PredictionR:Value() == 4 then
			local RSpell = IPrediction.Prediction({name="MissileBarrageMissile", range=CorkiR.range, speed=CorkiR.speed, delay=CorkiR.delay, width=CorkiR.width, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(CorkiR.range)
			local x, y = RSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_R, y.x, y.y, y.z)
			end
		elseif CorkiMenu.Prediction.PredictionR:Value() == 5 then
			local RPrediction = GetLinearAOEPrediction(target,CorkiR)
			if RPrediction.hitChance > 0.9 then
				CastSkillShot(_R, RPrediction.castPos)
			end
		end
	end
end

-- Auto

function Auto()
	if CorkiMenu.Auto.UseQ:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, CorkiQ.range) then
					useQ(target)
				end
			end
		end
	end
	if CorkiMenu.Auto.UseR:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_R) == READY then
				if ValidTarget(target, CorkiR.range) then
					useR(target)
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if CorkiMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY and AA == true then
				if ValidTarget(target, CorkiQ.range) then
					useQ(target)
				end
			end
		end
		if CorkiMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, CorkiW.range) then
					useW(target)
				end
			end
		end
		if CorkiMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY then
				if ValidTarget(target, CorkiE.range) then
					useE(target)
				end
			end
		end
		if CorkiMenu.Combo.UseR:Value() then
			if CanUseSpell(myHero,_R) == READY and AA == true then
				if ValidTarget(target, CorkiR.range) then
					useR(target)
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if CorkiMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					if ValidTarget(target, CorkiQ.range) then
						useQ(target)
					end
				end
			end
		end
		if CorkiMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY then
					if ValidTarget(target, CorkiW.range) then
						useW(target)
					end
				end
			end
		end
		if CorkiMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, CorkiE.range) then
						useE(target)
					end
				end
			end
		end
		if CorkiMenu.Harass.UseR:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_R) == READY and AA == true then
					if ValidTarget(target, CorkiR.range) then
						useR(target)
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_Q) == READY then
			if CorkiMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, CorkiQ.range) then
					local CorkiQDmg = (45*GetCastLevel(myHero,_Q)+30)+(0.5*GetBonusDmg(myHero))+(0.5*GetBonusAP(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < CorkiQDmg then
						useQ(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if CorkiMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, CorkiR.range) then
					local CorkiRDmg = (25*GetCastLevel(myHero,_R)+50)+((0.3*GetCastLevel(myHero,_R)-0.15)*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))+(0.2*GetBonusAP(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < CorkiRDmg then
						useR(enemy)
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if CorkiMenu.LaneClear.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.LaneClear.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					local BestPos, BestHit = GetFarmPosition(CorkiQ.range, CorkiQ.radius, MINION_ENEMY)
					if BestPos and BestHit > 3 then
						CastSkillShot(_Q, BestPos)
					end
				end
			end
		end
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if CorkiMenu.LaneClear.UseE:Value() then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.LaneClear.MP:Value() then
						if ValidTarget(minion, CorkiE.range) then
							if CanUseSpell(myHero,_E) == READY then
								CastSkillShot(_E, GetOrigin(minion))
							end
						end
					end
				end
				if CorkiMenu.LaneClear.UseR:Value() then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > CorkiMenu.LaneClear.MP:Value() then
						if ValidTarget(minion, CorkiR.range) then
							if CanUseSpell(myHero,_R) == READY then
								CastSkillShot(_R, GetOrigin(minion))
							end
						end
					end
				end
			end
		end
	end
end

-- Draven

elseif "Draven" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Draven loaded successfully!")
local DravenMenu = Menu("[GoS-U] Draven", "[GoS-U] Draven")
DravenMenu:Menu("Combo", "Combo")
DravenMenu.Combo:Boolean('UseQ', 'Use Q [Spinning Axe]', true)
DravenMenu.Combo:Boolean('UseW', 'Use W [Blood Rush]', true)
DravenMenu.Combo:Boolean('UseE', 'Use E [Stand Aside]', true)
DravenMenu.Combo:Boolean('UseR', 'Use R [Whirling Death]', true)
DravenMenu.Combo:Slider('Distance','Distance: R', 2000, 100, 10000, 100)
DravenMenu.Combo:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
DravenMenu.Combo:Slider('HP','HP-Manager: R', 40, 0, 100, 5)
DravenMenu:Menu("Harass", "Harass")
DravenMenu.Harass:Boolean('UseQ', 'Use Q [Spinning Axe]', true)
DravenMenu.Harass:Boolean('UseW', 'Use W [Blood Rush]', true)
DravenMenu.Harass:Boolean('UseE', 'Use E [Stand Aside]', true)
DravenMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
DravenMenu:Menu("KillSteal", "KillSteal")
DravenMenu.KillSteal:Boolean('UseE', 'Use E [Stand Aside]', true)
DravenMenu.KillSteal:Boolean('UseR', 'Use R [Whirling Death]', true)
DravenMenu.KillSteal:Slider('Distance','Distance: R', 2000, 100, 10000, 100)
DravenMenu:Menu("LaneClear", "LaneClear")
DravenMenu.LaneClear:Boolean('UseQ', 'Use Q [Spinning Axe]', true)
DravenMenu.LaneClear:Boolean('UseE', 'Use E [Stand Aside]', true)
DravenMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
DravenMenu:Menu("AntiGapcloser", "Anti-Gapcloser")
DravenMenu.AntiGapcloser:Boolean('UseE', 'Use E [Stand Aside]', true)
DravenMenu.AntiGapcloser:Slider('Distance','Distance: E', 400, 25, 500, 25)
DravenMenu:Menu("Interrupter", "Interrupter")
DravenMenu.Interrupter:Boolean('UseE', 'Use E [Stand Aside]', true)
DravenMenu.Interrupter:Slider('Distance','Distance: E', 700, 50, 1000, 50)
DravenMenu:Menu("Prediction", "Prediction")
DravenMenu.Prediction:DropDown("PredictionE", "Prediction: E", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
DravenMenu.Prediction:DropDown("PredictionR", "Prediction: R", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
DravenMenu:Menu("Drawings", "Drawings")
DravenMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
DravenMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
DravenMenu.Drawings:Boolean('DrawDMG', 'Draw Max QER Damage', true)

local DravenE = { range = 1050, radius = 120, width = 240, speed = 1400, delay = 0.25, type = "line", collision = false, source = myHero }
local DravenR = { range = DravenMenu.Combo.Distance:Value(), radius = 130, width = 260, speed = 2000, delay = 0.5, type = "line", collision = false, source = myHero }

OnTick(function(myHero)
	target = GetCurrentTarget()
	Combo()
	Harass()
	KillSteal()
	LaneClear()
	AntiGapcloser()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if DravenMenu.Drawings.DrawE:Value() then DrawCircle(pos,DravenE.range,1,25,0xff1e90ff) end
if DravenMenu.Drawings.DrawR:Value() then DrawCircle(pos,DravenR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	local QDmg = (5*GetCastLevel(myHero,_Q)+30)+((0.1*GetCastLevel(myHero,_Q)+0.55)*GetBonusDmg(myHero))
	local EDmg = (35*GetCastLevel(myHero,_E)+40)+(0.5*GetBonusDmg(myHero))
	local RDmg = (200*GetCastLevel(myHero,_R)+150)+(2.2*GetBonusDmg(myHero))
	local ComboDmg = QDmg + EDmg + RDmg
	local QRDmg = QDmg + RDmg
	local ERDmg = EDmg + RDmg
	local QEDmg = QDmg + EDmg
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			if DravenMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
				elseif Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QEDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	CastSpell(_Q)
end
function useW(target)
	CastSpell(_W)
end
function useE(target)
	if GetDistance(target) < DravenE.range then
		if DravenMenu.Prediction.PredictionE:Value() == 1 then
			CastSkillShot(_E,GetOrigin(target))
		elseif DravenMenu.Prediction.PredictionE:Value() == 2 then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),DravenE.speed,DravenE.delay*1000,DravenE.range,DravenE.width,true,true)
			if EPred.HitChance == 1 then
				CastSkillShot(_E, EPred.PredPos)
			end
		elseif DravenMenu.Prediction.PredictionE:Value() == 3 then
			local EPred = _G.gPred:GetPrediction(target,myHero,DravenE,true,false)
			if EPred and EPred.HitChance >= 3 then
				CastSkillShot(_E, EPred.CastPosition)
			end
		elseif DravenMenu.Prediction.PredictionE:Value() == 4 then
			local ESpell = IPrediction.Prediction({name="DravenDoubleShot", range=DravenE.range, speed=DravenE.speed, delay=DravenE.delay, width=DravenE.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(DravenE.range)
			local x, y = ESpell:Predict(target)
			if x > 2 then
				CastSkillShot(_E, y.x, y.y, y.z)
			end
		elseif DravenMenu.Prediction.PredictionE:Value() == 5 then
			local EPrediction = GetLinearAOEPrediction(target,DravenE)
			if EPrediction.hitChance > 0.9 then
				CastSkillShot(_E, EPrediction.castPos)
			end
		end
	end
end
function useR(target)
	if GetDistance(target) < DravenR.range then
		if DravenMenu.Prediction.PredictionR:Value() == 1 then
			CastSkillShot(_R,GetOrigin(target))
		elseif DravenMenu.Prediction.PredictionR:Value() == 2 then
			local RPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),DravenR.speed,DravenR.delay*1000,DravenR.range,DravenR.width,true,true)
			if RPred.HitChance == 1 then
				CastSkillShot(_R, RPred.PredPos)
			end
		elseif DravenMenu.Prediction.PredictionR:Value() == 3 then
			local RPred = _G.gPred:GetPrediction(target,myHero,DravenR,true,false)
			if RPred and RPred.HitChance >= 3 then
				CastSkillShot(_R, RPred.CastPosition)
			end
		elseif DravenMenu.Prediction.PredictionR:Value() == 4 then
			local RSpell = IPrediction.Prediction({name="DravenRCast", range=DravenR.range, speed=DravenR.speed, delay=DravenR.delay, width=DravenR.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(DravenR.range)
			local x, y = RSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_R, y.x, y.y, y.z)
			end
		elseif DravenMenu.Prediction.PredictionR:Value() == 5 then
			local RPrediction = GetLinearAOEPrediction(target,DravenR)
			if RPrediction.hitChance > 0.9 then
				CastSkillShot(_R, RPrediction.castPos)
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if DravenMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, GetRange(myHero)+GetHitBox(myHero)) then
					useQ(target)
				end
			end
		end
		if DravenMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, 1000) then
					useW(target)
				end
			end
		end
		if DravenMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY and AA == true then
				if ValidTarget(target, DravenE.range) then
					useE(target)
				end
			end
		end
		if DravenMenu.Combo.UseR:Value() then
			if CanUseSpell(myHero,_R) == READY then
				if ValidTarget(target, DravenR.range) then
					if 100*GetCurrentHP(target)/GetMaxHP(target) < DravenMenu.Combo.HP:Value() then
						if EnemiesAround(myHero, DravenR.range) >= DravenMenu.Combo.X:Value() then
							useR(target)
						end
					end
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if DravenMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > DravenMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY then
					if ValidTarget(target, GetRange(myHero)+GetHitBox(myHero)) then
						useQ(target)
					end
				end
			end
		end
		if DravenMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > DravenMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY then
					if ValidTarget(target, 1000) then
						useW(target)
					end
				end
			end
		end
		if DravenMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > DravenMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY and AA == true then
					if ValidTarget(target, DravenE.range) then
						useE(target)
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_E) == READY then
			if DravenMenu.KillSteal.UseE:Value() then
				if ValidTarget(enemy, DravenE.range) then
					local DravenEDmg = (35*GetCastLevel(myHero,_E)+40)+(0.5*GetBonusDmg(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < DravenEDmg then
						useE(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if DravenMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, DravenMenu.KillSteal.Distance:Value()) then
					local DravenRDmg = (40*GetCastLevel(myHero,_R)+30)+(0.44*GetBonusDmg(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < DravenRDmg then
						useR(enemy)
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if DravenMenu.LaneClear.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > DravenMenu.LaneClear.MP:Value() then
				if CanUseSpell(myHero,_E) == READY and AA == true then
					local BestPos, BestHit = GetLineFarmPosition(DravenE.range, DravenE.radius, MINION_ENEMY)
					if BestPos and BestHit > 5 then
						CastSkillShot(_E, BestPos)
					end
				end
			end
		end
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if DravenMenu.LaneClear.UseQ:Value() then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > DravenMenu.LaneClear.MP:Value() then
						if ValidTarget(minion, GetRange(myHero)+GetHitBox(myHero)) then
							if CanUseSpell(myHero,_Q) == READY then
								CastSpell(_Q)
							end
						end
					end
				end
			end
		end
	end
end

-- Anti-Gapcloser

function AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_E) == READY then
			if DravenMenu.AntiGapcloser.UseE:Value() then
				if ValidTarget(antigap, DravenMenu.AntiGapcloser.Distance:Value()) then
					useE(antigap)
				end
			end
		end
	end
end

-- Interrupter

OnProcessSpell(function(unit, spell)
	if DravenMenu.Interrupter.UseE:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, DravenMenu.Interrupter.Distance:Value()) then
				if CanUseSpell(myHero,_E) == READY then
					local UnitName = GetObjectName(enemy)
					local UnitChanellingSpells = CHANELLING_SPELLS[UnitName]
					local UnitGapcloserSpells = GAPCLOSER_SPELLS[UnitName]
					if UnitChanellingSpells then
						for _, slot in pairs(UnitChanellingSpells) do
							if spell.name == GetCastName(enemy, slot) then useE(enemy) end
						end
					elseif UnitGapcloserSpells then
						for _, slot in pairs(UnitGapcloserSpells) do
							if spell.name == GetCastName(enemy, slot) then useE(enemy) end
						end
					end
				end
			end
		end
    end
end)

-- Ezreal

elseif "Ezreal" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Ezreal loaded successfully!")
local EzrealMenu = Menu("[GoS-U] Ezreal", "[GoS-U] Ezreal")
EzrealMenu:Menu("Auto", "Auto")
EzrealMenu.Auto:Boolean('UseQ', 'Use Q [Mystic Shot]', true)
EzrealMenu.Auto:Boolean('UseW', 'Use W [Essence Flux]', true)
EzrealMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
EzrealMenu:Menu("Combo", "Combo")
EzrealMenu.Combo:Boolean('UseQ', 'Use Q [Mystic Shot]', true)
EzrealMenu.Combo:Boolean('UseW', 'Use W [Essence Flux]', true)
EzrealMenu.Combo:Boolean('UseE', 'Use E [Arcane Shift]', true)
EzrealMenu.Combo:Boolean('UseR', 'Use R [Trueshot Barrage]', true)
EzrealMenu.Combo:DropDown("ModeW", "Cast Mode: W", 2, {"On Ally", "On Enemy"})
EzrealMenu.Combo:Slider('Distance','Distance: R', 2000, 100, 10000, 100)
EzrealMenu.Combo:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
EzrealMenu.Combo:Slider('HP','HP-Manager: R', 40, 0, 100, 5)
EzrealMenu:Menu("Harass", "Harass")
EzrealMenu.Harass:Boolean('UseQ', 'Use Q [Mystic Shot]', true)
EzrealMenu.Harass:Boolean('UseW', 'Use W [Essence Flux]', true)
EzrealMenu.Harass:Boolean('UseE', 'Use E [Arcane Shift]', false)
EzrealMenu.Harass:DropDown("ModeW", "Cast Mode: W", 1, {"On Ally", "On Enemy"})
EzrealMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
EzrealMenu:Menu("KillSteal", "KillSteal")
EzrealMenu.KillSteal:Boolean('UseQ', 'Use Q [Mystic Shot]', true)
EzrealMenu.KillSteal:Boolean('UseR', 'Use R [Trueshot Barrage]', true)
EzrealMenu.KillSteal:Slider('Distance','Distance: R', 2000, 100, 10000, 100)
EzrealMenu:Menu("LastHit", "LastHit")
EzrealMenu.LastHit:Boolean('UseQ', 'Use Q [Mystic Shot]', true)
EzrealMenu.LastHit:Slider("MP","Mana-Manager", 40, 0, 100, 5)
EzrealMenu:Menu("LaneClear", "LaneClear")
EzrealMenu.LaneClear:Boolean('UseQ', 'Use Q [Mystic Shot]', false)
EzrealMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
EzrealMenu:Menu("Prediction", "Prediction")
EzrealMenu.Prediction:DropDown("PredictionQ", "Prediction: Q", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
EzrealMenu.Prediction:DropDown("PredictionW", "Prediction: W", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
EzrealMenu.Prediction:DropDown("PredictionR", "Prediction: R", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
EzrealMenu:Menu("Drawings", "Drawings")
EzrealMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
EzrealMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
EzrealMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
EzrealMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
EzrealMenu.Drawings:Boolean('DrawDMG', 'Draw Max QWER Damage', true)

local EzrealQ = { range = 1150, radius = 60, width = 120, speed = 2000, delay = 0.25, type = "line", collision = true, source = myHero, col = {"minion","yasuowall"}}
local EzrealW = { range = 1000, radius = 80, width = 160, speed = 1550, delay = 0.25, type = "line", collision = false, source = myHero, col = {"yasuowall"}}
local EzrealE = { range = 475 }
local EzrealR = { range = EzrealMenu.Combo.Distance:Value(), radius = 160, width = 320, speed = 2000, delay = 1, type = "line", collision = false, source = myHero, col = {"yasuowall"}}

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	LastHit()
	LaneClear()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if EzrealMenu.Drawings.DrawQ:Value() then DrawCircle(pos,EzrealQ.range,1,25,0xff00bfff) end
if EzrealMenu.Drawings.DrawW:Value() then DrawCircle(pos,EzrealW.range,1,25,0xff4169e1) end
if EzrealMenu.Drawings.DrawE:Value() then DrawCircle(pos,EzrealE.range,1,25,0xff1e90ff) end
if EzrealMenu.Drawings.DrawR:Value() then DrawCircle(pos,EzrealMenu.Combo.Distance:Value(),1,25,0xff0000ff) end
end

function DrawDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local QDmg = (25*GetCastLevel(myHero,_Q)-10)+(1.1*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))+(0.4*GetBonusAP(myHero))
		local WDmg = (45*GetCastLevel(myHero,_W)+25)+(0.8*GetBonusAP(myHero))
		local EDmg = (50*GetCastLevel(myHero,_E)+30)+(0.5*GetBonusDmg(myHero))+(0.75*GetBonusAP(myHero))
		local RDmg = (150*GetCastLevel(myHero,_R)+200)+GetBonusDmg(myHero)+(0.9*GetBonusAP(myHero))
		local ComboDmg = QDmg + WDmg + EDmg + RDmg
		local WERDmg = WDmg + EDmg + RDmg
		local QERDmg = QDmg + EDmg + RDmg
		local QWRDmg = QDmg + WDmg + RDmg
		local QWEDmg = QDmg + WDmg + EDmg
		local ERDmg = EDmg + RDmg
		local WRDmg = WDmg + RDmg
		local QRDmg = QDmg + RDmg
		local WEDmg = WDmg + EDmg
		local QEDmg = QDmg + EDmg
		local QWDmg = QDmg + WDmg
		if ValidTarget(enemy) then
			if EzrealMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWEDmg), 0xff008080)
				elseif Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ERDmg), 0xff008080)
				elseif Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	if GetDistance(target) < EzrealQ.range then
		if EzrealMenu.Prediction.PredictionQ:Value() == 1 then
			CastSkillShot(_Q,GetOrigin(target))
		elseif EzrealMenu.Prediction.PredictionQ:Value() == 2 then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),EzrealQ.speed,EzrealQ.delay*1000,EzrealQ.range,EzrealQ.width,true,false)
			if QPred.HitChance == 1 then
				CastSkillShot(_Q, QPred.PredPos)
			end
		elseif EzrealMenu.Prediction.PredictionQ:Value() == 3 then
			local qPred = _G.gPred:GetPrediction(target,myHero,EzrealQ,false,true)
			if qPred and qPred.HitChance >= 3 then
				CastSkillShot(_Q, qPred.CastPosition)
			end
		elseif EzrealMenu.Prediction.PredictionQ:Value() == 4 then
			local QSpell = IPrediction.Prediction({name="EzrealMysticShot", range=EzrealQ.range, speed=EzrealQ.speed, delay=EzrealQ.delay, width=EzrealQ.width, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(EzrealQ.range)
			local x, y = QSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_Q, y.x, y.y, y.z)
			end
		elseif EzrealMenu.Prediction.PredictionQ:Value() == 5 then
			local QPrediction = GetLinearAOEPrediction(target,EzrealQ)
			if QPrediction.hitChance > 0.9 then
				CastSkillShot(_Q, QPrediction.castPos)
			end
		end
	end
end
function useW(target)
	if GetDistance(target) < EzrealW.range then
		if EzrealMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif EzrealMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),EzrealW.speed,EzrealW.delay*1000,EzrealW.range,EzrealW.width,false,true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif EzrealMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,EzrealW,false,true)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif EzrealMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="EzrealEssenceFlux", range=EzrealW.range, speed=EzrealW.speed, delay=EzrealW.delay, width=EzrealW.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(EzrealW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif EzrealMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetLinearAOEPrediction(target,EzrealW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useR(target)
	if GetDistance(target) < EzrealR.range then
		if EzrealMenu.Prediction.PredictionR:Value() == 1 then
			CastSkillShot(_R,GetOrigin(target))
		elseif EzrealMenu.Prediction.PredictionR:Value() == 2 then
			local RPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),EzrealR.speed,EzrealR.delay*1000,EzrealR.range,EzrealR.width,false,true)
			if RPred.HitChance == 1 then
				CastSkillShot(_R, RPred.PredPos)
			end
		elseif EzrealMenu.Prediction.PredictionR:Value() == 3 then
			local RPred = _G.gPred:GetPrediction(target,myHero,EzrealR,false,true)
			if RPred and RPred.HitChance >= 3 then
				CastSkillShot(_R, RPred.CastPosition)
			end
		elseif EzrealMenu.Prediction.PredictionR:Value() == 4 then
			local RSpell = IPrediction.Prediction({name="EzrealTrueshotBarrage", range=EzrealR.range, speed=EzrealR.speed, delay=EzrealR.delay, width=EzrealR.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(EzrealR.range)
			local x, y = RSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_R, y.x, y.y, y.z)
			end
		elseif EzrealMenu.Prediction.PredictionR:Value() == 5 then
			local RPrediction = GetLinearAOEPrediction(target,EzrealR)
			if RPrediction.hitChance > 0.9 then
				CastSkillShot(_R, RPrediction.castPos)
			end
		end
	end
end

-- Auto

function Auto()
	if EzrealMenu.Auto.UseQ:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, EzrealQ.range) then
					useQ(target)
				end
			end
		end
	end
	if EzrealMenu.Auto.UseW:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, EzrealW.range) then
					useW(target)
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if EzrealMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY and AA == true then
				if ValidTarget(target, EzrealQ.range) then
					useQ(target)
				end
			end
		end
		if EzrealMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY and AA == true then
				if EzrealMenu.Combo.ModeW:Value() == 1 then
					for _, ally in pairs(GoS:GetAllyHeroes()) do
						if ValidTarget(ally, EzrealW.range) and GetDistance(ally, target) >= EzrealW.range+GetRange(myHero) then
							useW(ally)
						elseif ValidTarget(target, EzrealW.range) then
							useW(target)
						end
					end
				elseif EzrealMenu.Combo.ModeW:Value() == 2 then
					if ValidTarget(target, EzrealW.range) then
						useW(target)
					end
				end
			end
		end
		if EzrealMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY then
				if ValidTarget(target, EzrealE.range+GetRange(myHero)) then
					CastSkillShot(_E, GetMousePos())
				end
			end
		end
		if EzrealMenu.Combo.UseR:Value() then
			if CanUseSpell(myHero,_R) == READY then
				if ValidTarget(target, EzrealR.range) then
					if 100*GetCurrentHP(target)/GetMaxHP(target) < EzrealMenu.Combo.HP:Value() then
						if EnemiesAround(myHero, EzrealR.range+GetRange(myHero)) >= EzrealMenu.Combo.X:Value() then
							useR(target)
						end
					end
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if EzrealMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					if ValidTarget(target, EzrealQ.range) then
						useQ(target)
					end
				end
			end
		end
		if EzrealMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY and AA == true then
					if EzrealMenu.Harass.ModeW:Value() == 1 then
						for _, ally in pairs(GoS:GetAllyHeroes()) do
							if ValidTarget(ally, EzrealW.range) and GetDistance(ally, target) >= EzrealW.range+GetRange(myHero) then
								useW(ally)
							elseif ValidTarget(target, EzrealW.range) then
								useW(target)
							end
						end
					elseif EzrealMenu.Harass.ModeW:Value() == 2 then
						if ValidTarget(target, EzrealW.range) then
							useW(target)
						end
					end
				end
			end
		end
		if EzrealMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, EzrealE.range+GetRange(myHero)) then
						CastSkillShot(_E, GetMousePos())
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_Q) == READY then
			if EzrealMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, EzrealQ.range) then
					local EzrealQDmg = (25*GetCastLevel(myHero,_Q)-10)+(1.1*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))+(0.4*GetBonusAP(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < EzrealQDmg then
						useQ(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if EzrealMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, EzrealMenu.KillSteal.Distance:Value()) then
					local EzrealRDmg = (45*GetCastLevel(myHero,_R)+60)+(0.3*GetBonusDmg(myHero))+(0.27*GetBonusAP(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < EzrealRDmg then
						useR(enemy)
					end
				end
			end
		end
	end
end

-- LastHit

function LastHit()
	if Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if ValidTarget(minion, EzrealQ.range) then
					if EzrealMenu.LastHit.UseQ:Value() then
						if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.LastHit.MP:Value() then
							if CanUseSpell(myHero,_Q) == READY then
								local EzrealQDmg = (25*GetCastLevel(myHero,_Q)-10)+(1.1*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))+(0.4*GetBonusAP(myHero))
								if GetCurrentHP(minion) < EzrealQDmg then
									local QPredMin = GetLinearAOEPrediction(minion,EzrealQ)
									if QPredMin.hitChance > 0.9 then
										CastSkillShot(_Q, QPredMin.castPos)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if EzrealMenu.LaneClear.UseQ:Value() then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > EzrealMenu.LaneClear.MP:Value() then
						if ValidTarget(minion, EzrealQ.range) then
							if CanUseSpell(myHero,_Q) == READY and AA == true then
								CastSkillShot(_Q, GetOrigin(minion))
							end
						end
					end
				end
			end
		end
	end
end

-- Jhin

elseif "Jhin" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Jhin loaded successfully!")
local JhinMenu = Menu("[GoS-U] Jhin", "[GoS-U] Jhin")
JhinMenu:Menu("Auto", "Auto")
JhinMenu.Auto:Boolean('UseQ', 'Use Q [Dancing Grenade]', true)
JhinMenu.Auto:DropDown("ModeQ", "Cast Mode: Q", 2, {"Standard", "Bounce"})
JhinMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
JhinMenu:Menu("Combo", "Combo")
JhinMenu.Combo:Boolean('UseQ', 'Use Q [Dancing Grenade]', true)
JhinMenu.Combo:Boolean('UseW', 'Use W [Deadly Flourish]', true)
JhinMenu.Combo:Boolean('UseE', 'Use E [Captive Audience]', true)
JhinMenu.Combo:DropDown("ModeQ", "Cast Mode: Q", 1, {"Standard", "Bounce"})
JhinMenu:Menu("Harass", "Harass")
JhinMenu.Harass:Boolean('UseQ', 'Use Q [Dancing Grenade]', true)
JhinMenu.Harass:Boolean('UseW', 'Use W [Deadly Flourish]', true)
JhinMenu.Harass:Boolean('UseE', 'Use E [Captive Audience]', true)
JhinMenu.Harass:DropDown("ModeQ", "Cast Mode: Q", 2, {"Standard", "Bounce"})
JhinMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
JhinMenu:Menu("KillSteal", "KillSteal")
JhinMenu.KillSteal:Boolean('UseW', 'Use W [Deadly Flourish]', true)
JhinMenu.KillSteal:Key("UseR", "Use R [Curtain Call]", string.byte("A"))
JhinMenu.KillSteal:Boolean('UseRD', 'Draw Killable With R', true)
JhinMenu:Menu("LaneClear", "LaneClear")
JhinMenu.LaneClear:Boolean('UseQ', 'Use Q [Dancing Grenade]', true)
JhinMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
JhinMenu:Menu("AntiGapcloser", "Anti-Gapcloser")
JhinMenu.AntiGapcloser:Boolean('UseW', 'Use W [Deadly Flourish]', true)
JhinMenu.AntiGapcloser:Slider('Distance','Distance: W', 400, 25, 500, 25)
JhinMenu:Menu("Interrupter", "Interrupter")
JhinMenu.Interrupter:Boolean('UseW', 'Use W [Deadly Flourish]', true)
JhinMenu.Interrupter:Slider('Distance','Distance: W', 400, 50, 1000, 50)
JhinMenu:Menu("Prediction", "Prediction")
JhinMenu.Prediction:DropDown("PredictionW", "Prediction: W", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
JhinMenu.Prediction:DropDown("PredictionE", "Prediction: E", 5, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
JhinMenu.Prediction:DropDown("PredictionR", "Prediction: R", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
JhinMenu:Menu("Drawings", "Drawings")
JhinMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
JhinMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
JhinMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
JhinMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
JhinMenu.Drawings:Boolean('DrawDMG', 'Draw Max QWE Damage', true)

local JhinQ = { range = 550 }
local JhinW = { range = 3000, radius = 40, width = 80, speed = 5000, delay = 0.75, type = "line", collision = false, source = myHero, col = {"yasuowall"}}
local JhinE = { range = 750, radius = 140, width = 280, speed = 1650, delay = 0.25, type = "circular", collision = false, source = myHero }
local JhinR = { range = 3500, radius = 80, width = 160, speed = 5000, delay = 0.25, type = "line", collision = false, source = myHero, col = {"yasuowall"}}

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	KillSteal2()
	LaneClear()
	AntiGapcloser()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if JhinMenu.Drawings.DrawQ:Value() then DrawCircle(pos,JhinQ.range,1,25,0xff00bfff) end
if JhinMenu.Drawings.DrawW:Value() then DrawCircle(pos,JhinW.range,1,25,0xff4169e1) end
if JhinMenu.Drawings.DrawE:Value() then DrawCircle(pos,JhinE.range,1,25,0xff1e90ff) end
if JhinMenu.Drawings.DrawR:Value() then DrawCircle(pos,JhinR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local QDmg = (25*GetCastLevel(myHero,_Q)+20)+((0.05*GetCastLevel(myHero,_Q)+0.35)*(GetBonusDmg(myHero)+GetBaseDamage(myHero)))+(0.6*GetBonusAP(myHero))
		local WDmg = (35*GetCastLevel(myHero,_W)+15)+(0.5*(GetBonusDmg(myHero)+GetBaseDamage(myHero)))
		local EDmg = (60*GetCastLevel(myHero,_E)-40)+(1.2*(GetBonusDmg(myHero)+GetBaseDamage(myHero)))+GetBonusAP(myHero)
		local ComboDmg = QDmg + WDmg + EDmg
		local WEDmg = WDmg + EDmg
		local QEDmg = QDmg + EDmg
		local QWDmg = QDmg + WDmg
		if ValidTarget(enemy) then
			if JhinMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	CastTargetSpell(target, _Q)
end
function useW(target)
	if GetDistance(target) < JhinW.range then
		if JhinMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif JhinMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),JhinW.speed,JhinW.delay*1000,JhinW.range,JhinW.width,false,true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif JhinMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,JhinW,false,true)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif JhinMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="JhinW", range=JhinW.range, speed=JhinW.speed, delay=JhinW.delay, width=JhinW.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(JhinW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif JhinMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetLinearAOEPrediction(target,JhinW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useE(target)
	if GetDistance(target) < JhinE.range then
		if JhinMenu.Prediction.PredictionE:Value() == 1 then
			CastSkillShot(_E,GetOrigin(target))
		elseif JhinMenu.Prediction.PredictionE:Value() == 2 then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),JhinE.speed,JhinE.delay*1000,JhinE.range,JhinE.width,false,true)
			if EPred.HitChance == 1 then
				CastSkillShot(_E, EPred.PredPos)
			end
		elseif JhinMenu.Prediction.PredictionE:Value() == 3 then
			local EPred = _G.gPred:GetPrediction(target,myHero,JhinE,true,false)
			if EPred and EPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif JhinMenu.Prediction.PredictionE:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="JhinE", range=JhinE.range, speed=JhinE.speed, delay=JhinE.delay, width=JhinE.width, type="circular", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(JhinE.range)
			local x, y = ESpell:Predict(target)
			if x > 2 then
				CastSkillShot(_E, y.x, y.y, y.z)
			end
		elseif JhinMenu.Prediction.PredictionE:Value() == 5 then
			local EPrediction = GetCircularAOEPrediction(target,JhinE)
			if EPrediction.hitChance > 0.9 then
				CastSkillShot(_E, EPrediction.castPos)
			end
		end
	end
end

-- Auto

function Auto()
	if JhinMenu.Auto.UseQ:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JhinMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, JhinQ.range) then
					if JhinMenu.Auto.ModeQ:Value() == 1 then
						useQ(target)
					elseif JhinMenu.Auto.ModeQ:Value() == 2 then
						for _, minion in pairs(minionManager.objects) do
							if GetTeam(minion) == MINION_ENEMY then
								if EnemiesAround(minion, 400) >= 1 then
									useQ(minion)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if JhinMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY and AA == true then
				if ValidTarget(target, JhinQ.range) then
					if JhinMenu.Combo.ModeQ:Value() == 1 then
						useQ(target)
					elseif JhinMenu.Combo.ModeQ:Value() == 2 then
						for _, minion in pairs(minionManager.objects) do
							if GetTeam(minion) == MINION_ENEMY then
								if EnemiesAround(minion, 400) >= 1 then
									useQ(minion)
								end
							end
						end
					end
				end
			end
		end
		if JhinMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY and AA == true then
				if ValidTarget(target, JhinW.range) then
					useW(target)
				end
			end
		end
		if JhinMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY then
				if ValidTarget(target, JhinE.range) then
					useE(target)
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if JhinMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JhinMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					if ValidTarget(target, JhinQ.range) then
						if JhinMenu.Harass.ModeQ:Value() == 1 then
							useQ(target)
						elseif JhinMenu.Harass.ModeQ:Value() == 2 then
							for _, minion in pairs(minionManager.objects) do
								if GetTeam(minion) == MINION_ENEMY then
									if EnemiesAround(minion, 400) >= 1 then
										useQ(minion)
									end
								end
							end
						end
					end
				end
			end
		end
		if JhinMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JhinMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY and AA == true then
					if ValidTarget(target, JhinW.range) then
						useW(target)
					end
				end
			end
		end
		if JhinMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JhinMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, JhinE.range) then
						useE(target)
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if JhinMenu.KillSteal.UseW:Value() then
				if ValidTarget(enemy, JhinW.range) then
					local JhinWDmg = (35*GetCastLevel(myHero,_W)+15)+(0.5*(GetBonusDmg(myHero)+GetBaseDamage(myHero)))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < JhinWDmg then
						useW(enemy)
					end
				end
			end
		end
	end
end
function KillSteal2()
	if CanUseSpell(myHero,_R) == READY then
		if JhinMenu.KillSteal.UseR:Value() then
			local EnemyToHit = ClosestEnemy(GetMousePos())
			if JhinMenu.Prediction.PredictionR:Value() == 1 then
				CastSkillShot(_R,GetOrigin(EnemyToHit))
			elseif JhinMenu.Prediction.PredictionR:Value() == 2 then
				local RPred = GetPredictionForPlayer(GetOrigin(myHero),EnemyToHit,GetMoveSpeed(target),JhinR.speed,JhinR.delay*1000,JhinR.range,JhinR.width,false,true)
				if RPred.HitChance == 1 then
					CastSkillShot(_R, RPred.PredPos)
				end
			elseif JhinMenu.Prediction.PredictionR:Value() == 3 then
				local RPred = _G.gPred:GetPrediction(EnemyToHit,myHero,JhinR,false,false)
				if RPred and RPred.HitChance >= 3 then
					CastSkillShot(_R, RPred.CastPosition)
				end
			elseif JhinMenu.Prediction.PredictionR:Value() == 4 then
				local RSpell = IPrediction.Prediction({name="JhinRCast", range=JhinR.range, speed=JhinR.speed, delay=JhinR.delay, width=JhinR.width, type="linear", collision=false})
				local x, y = RSpell:Predict(EnemyToHit)
				if x > 2 then
					CastSkillShot(_R, y.x, y.y, y.z)
				end
			elseif JhinMenu.Prediction.PredictionR:Value() == 5 then
				local RPrediction = GetCircularAOEPrediction(EnemyToHit,JhinR)
				if RPrediction.hitChance > 0.9 then
					CastSkillShot(_R, RPrediction.castPos)
				end
			end
		end
		for _, enemy in pairs(GetEnemyHeroes()) do
			local JhinRDmg = ((75*GetCastLevel(myHero,_R)-25)+0.2*(GetBonusDmg(myHero)+GetBaseDamage(myHero))*(1+(100-GetPercentHP(enemy))*1.025))*4
			if ValidTarget(enemy) then
				if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*4) < JhinRDmg then
					if JhinMenu.KillSteal.UseRD:Value() then
						DrawCircle(enemy,100,5,25,0xffffd700)
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if JhinMenu.LaneClear.UseQ:Value() then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JhinMenu.LaneClear.MP:Value() then
						if ValidTarget(minion, JhinQ.range) then
							if CanUseSpell(myHero,_Q) == READY then
								CastTargetSpell(minion, _Q)
							end
						end
					end
				end
			end
		end
	end
end

-- Anti-Gapcloser

function AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if JhinMenu.AntiGapcloser.UseW:Value() then
				if ValidTarget(antigap, JhinMenu.AntiGapcloser.Distance:Value()) then
					useW(antigap)
				end
			end
		end
	end
end

-- Interrupter

OnProcessSpell(function(unit, spell)
	if JhinMenu.Interrupter.UseW:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, JhinMenu.Interrupter.Distance:Value()) then
				if CanUseSpell(myHero,_W) == READY then
					local UnitName = GetObjectName(enemy)
					local UnitChanellingSpells = CHANELLING_SPELLS[UnitName]
					local UnitGapcloserSpells = GAPCLOSER_SPELLS[UnitName]
					if UnitGapcloserSpells then
						for _, slot in pairs(UnitGapcloserSpells) do
							if spell.name == GetCastName(enemy, slot) then useW(enemy) end
						end
					end
				end
			end
		end
    end
end)

-- Jinx

elseif "Jinx" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Jinx loaded successfully!")
local JinxMenu = Menu("[GoS-U] Jinx", "[GoS-U] Jinx")
JinxMenu:Menu("Auto", "Auto")
JinxMenu.Auto:Boolean('UseW', 'Use W [Zap!]', true)
JinxMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
JinxMenu:Menu("Combo", "Combo")
JinxMenu.Combo:Boolean('UseQ', 'Use Q [Switcheroo!]', true)
JinxMenu.Combo:Boolean('UseW', 'Use W [Zap!]', true)
JinxMenu.Combo:Boolean('UseE', 'Use E [Flame Chompers!]', true)
JinxMenu.Combo:Boolean('UseR', 'Use R [Death Rocket!]', true)
JinxMenu.Combo:Slider('Distance','Distance: R', 4000, 100, 10000, 100)
JinxMenu.Combo:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
JinxMenu.Combo:Slider('HP','HP-Manager: R', 40, 0, 100, 5)
JinxMenu:Menu("Harass", "Harass")
JinxMenu.Harass:Boolean('UseQ', 'Use Q [Switcheroo!]', true)
JinxMenu.Harass:Boolean('UseW', 'Use W [Zap!]', true)
JinxMenu.Harass:Boolean('UseE', 'Use E [Flame Chompers!]', true)
JinxMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
JinxMenu:Menu("KillSteal", "KillSteal")
JinxMenu.KillSteal:Boolean('UseW', 'Use W [Zap!]', true)
JinxMenu.KillSteal:Boolean('UseR', 'Use R [Death Rocket!]', true)
JinxMenu.KillSteal:Slider('Distance','Distance: R', 4000, 100, 10000, 100)
JinxMenu:Menu("LaneClear", "LaneClear")
JinxMenu.LaneClear:Boolean('UseQ', 'Use Q [Switcheroo!]', true)
JinxMenu.LaneClear:Boolean('UseE', 'Use E [Flame Chompers!]', true)
JinxMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
JinxMenu:Menu("AntiGapcloser", "Anti-Gapcloser")
JinxMenu.AntiGapcloser:Boolean('UseW', 'Use W [Zap!]', true)
JinxMenu.AntiGapcloser:Boolean('UseE', 'Use E [Flame Chompers!]', true)
JinxMenu.AntiGapcloser:Slider('DistanceW','Distance: W', 400, 25, 500, 25)
JinxMenu.AntiGapcloser:Slider('DistanceE','Distance: E', 300, 25, 500, 25)
JinxMenu:Menu("Interrupter", "Interrupter")
JinxMenu.Interrupter:Boolean('UseE', 'Use E [Flame Chompers!]', true)
JinxMenu.Interrupter:Slider('Distance','Distance: E', 400, 50, 1000, 50)
JinxMenu:Menu("Prediction", "Prediction")
JinxMenu.Prediction:DropDown("PredictionW", "Prediction: W", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
JinxMenu.Prediction:DropDown("PredictionE", "Prediction: E", 5, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
JinxMenu.Prediction:DropDown("PredictionR", "Prediction: R", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
JinxMenu:Menu("Drawings", "Drawings")
JinxMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
JinxMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
JinxMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
JinxMenu.Drawings:Boolean('DrawDMG', 'Draw Max WER Damage', true)

local JinxW = { range = 1450, radius = 45, width = 90, speed = 3200, delay = 0.6, type = "line", collision = true, source = myHero, col = {"minion","yasuowall"}}
local JinxE = { range = 900, radius = 100, width = 200, speed = 2570, delay = 0.75, type = "circular", collision = false, source = myHero }
local JinxR = { range = JinxMenu.Combo.Distance:Value(), radius = 110, width = 220, speed = 1700, delay = 0.6, type = "line", collision = false, source = myHero }

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	LaneClear()
	AntiGapcloser()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if JinxMenu.Drawings.DrawW:Value() then DrawCircle(pos,JinxW.range,1,25,0xff4169e1) end
if JinxMenu.Drawings.DrawE:Value() then DrawCircle(pos,JinxE.range,1,25,0xff1e90ff) end
if JinxMenu.Drawings.DrawR:Value() then DrawCircle(pos,JinxR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local WDmg = (50*GetCastLevel(myHero,_Q)-40)+(1.4*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))
		local EDmg = (50*GetCastLevel(myHero,_W)+20)+GetBonusAP(myHero)
		local RDmg = (100*GetCastLevel(myHero,_R)+150)+(1.5*GetBonusDmg(myHero))+((0.05*GetCastLevel(myHero,_R)+0.2)*(GetMaxHP(enemy)-GetCurrentHP(enemy)))
		local ComboDmg = WDmg + EDmg + RDmg
		local ERDmg = EDmg + RDmg
		local WRDmg = WDmg + RDmg
		local WEDmg = WDmg + EDmg
		if ValidTarget(enemy) then
			if JinxMenu.Drawings.DrawDMG:Value() then
				if Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ERDmg), 0xff008080)
				elseif Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WEDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	CastSpell(_Q)
end
function useW(target)
	if GetDistance(target) < JinxW.range then
		if JinxMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif JinxMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),JinxW.speed,JinxW.delay*1000,JinxW.range,JinxW.width,true,false)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif JinxMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,JinxW,false,true)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif JinxMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="JinxW", range=JinxW.range, speed=JinxW.speed, delay=JinxW.delay, width=JinxW.width, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(JinxW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif JinxMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetLinearAOEPrediction(target,JinxW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useE(target)
	if GetDistance(target) < JinxE.range then
		if JinxMenu.Prediction.PredictionE:Value() == 1 then
			CastSkillShot(_E,GetOrigin(target))
		elseif JinxMenu.Prediction.PredictionE:Value() == 2 then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),JinxE.speed,JinxE.delay*1000,JinxE.range,JinxE.width,false,true)
			if EPred.HitChance == 1 then
				CastSkillShot(_E, EPred.PredPos)
			end
		elseif JinxMenu.Prediction.PredictionE:Value() == 3 then
			local EPred = _G.gPred:GetPrediction(target,myHero,JinxE,true,false)
			if EPred and EPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif JinxMenu.Prediction.PredictionE:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="JinxE", range=JinxE.range, speed=JinxE.speed, delay=JinxE.delay, width=JinxE.width, type="circular", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(JinxE.range)
			local x, y = ESpell:Predict(target)
			if x > 2 then
				CastSkillShot(_E, y.x, y.y, y.z)
			end
		elseif JinxMenu.Prediction.PredictionE:Value() == 5 then
			local EPrediction = GetCircularAOEPrediction(target,JinxE)
			if EPrediction.hitChance > 0.9 then
				CastSkillShot(_E, EPrediction.castPos)
			end
		end
	end
end
function useR(target)
	if GetDistance(target) < JinxR.range then
		if JinxMenu.Prediction.PredictionR:Value() == 1 then
			CastSkillShot(_R,GetOrigin(target))
		elseif JinxMenu.Prediction.PredictionR:Value() == 2 then
			local RPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),JinxR.speed,JinxR.delay*1000,JinxR.range,JinxR.width,false,false)
			if RPred.HitChance == 1 then
				CastSkillShot(_R, RPred.PredPos)
			end
		elseif JinxMenu.Prediction.PredictionR:Value() == 3 then
			local RPred = _G.gPred:GetPrediction(target,myHero,JinxR,false,false)
			if RPred and RPred.HitChance >= 3 then
				CastSkillShot(_R, RPred.CastPosition)
			end
		elseif JinxMenu.Prediction.PredictionR:Value() == 4 then
			local RSpell = IPrediction.Prediction({name="JinxR", range=JinxR.range, speed=JinxR.speed, delay=JinxR.delay, width=JinxR.width, type="linear", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(JinxR.range)
			local x, y = RSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_R, y.x, y.y, y.z)
			end
		elseif JinxMenu.Prediction.PredictionR:Value() == 5 then
			local RPrediction = GetLinearAOEPrediction(target,JinxR)
			if RPrediction.hitChance > 0.9 then
				CastSkillShot(_R, RPrediction.castPos)
			end
		end
	end
end
OnUpdateBuff(function(unit,buff)
	if unit == myHero and buff.Name == "jinxqicon" then
		Q2 = false
	end
end)
OnRemoveBuff(function(unit,buff)
	if unit == myHero and buff.Name == "jinxqicon" then
		Q2 = true
	end
end)

-- Auto

function Auto()
	if JinxMenu.Auto.UseW:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JinxMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, JinxW.range) then
					useW(target)
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if JinxMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, GetRange(myHero)+GetHitBox(myHero)) then
					if Q2 then
						if EnemiesAround(target, 150) <= 1 then
							useQ(target)
						end
					else
						if EnemiesAround(target, 150) > 1 then
							useQ(target)
						end
					end
				end
			end
		end
		if JinxMenu.Combo.UseW:Value() then
			if CanUseSpell(myHero,_W) == READY and AA == true then
				if ValidTarget(target, JinxW.range) then
					useW(target)
				end
			end
		end
		if JinxMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY and AA == true then
				if ValidTarget(target, JinxE.range) then
					useE(target)
				end
			end
		end
		if JinxMenu.Combo.UseR:Value() then
			if CanUseSpell(myHero,_R) == READY then
				if ValidTarget(target, JinxR.range) then
					if 100*GetCurrentHP(target)/GetMaxHP(target) < JinxMenu.Combo.HP:Value() then
						if EnemiesAround(myHero, JinxR.range+GetRange(myHero)) >= JinxMenu.Combo.X:Value() then
							useR(target)
						end
					end
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if JinxMenu.Harass.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, GetRange(myHero)+GetHitBox(myHero)) then
					if Q2 then
						if EnemiesAround(target, 150) <= 1 then
							useQ(target)
						end
					else
						if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JinxMenu.Harass.MP:Value() then
							if EnemiesAround(target, 150) > 1 then
								useQ(target)
							end
						end
					end
				end
			end
		end
		if JinxMenu.Harass.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JinxMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_W) == READY and AA == true then
					if ValidTarget(target, JinxW.range) then
						useW(target)
					end
				end
			end
		end
		if JinxMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JinxMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, JinxE.range) then
						useE(target)
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if JinxMenu.KillSteal.UseW:Value() then
				if ValidTarget(enemy, JinxW.range) then
					local JinxWDmg = (15*GetCastLevel(myHero,_W)+5)+(GetBonusDmg(myHero)+GetBaseDamage(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2) < JinxWDmg then
						useW(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if JinxMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, JinxMenu.KillSteal.Distance:Value()) and GetDistance(enemy, myHero) >= 1500 then
					local JinxRDmg = math.max(50*GetCastLevel(myHero,_R)+75+GetBonusDmg(myHero)+(0.05*GetCastLevel(myHero,_R)+0.2)*(GetMaxHP(enemy)-GetCurrentHP(enemy)))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*8) < JinxRDmg then
						useR(enemy)
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if JinxMenu.LaneClear.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JinxMenu.LaneClear.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					local BestPos, BestHit = GetFarmPosition(JinxE.range, JinxE.range, MINION_ENEMY)
					if BestPos and BestHit > 3 then
						CastSkillShot(_E, BestPos)
					end
				end
			end
		end
		if JinxMenu.LaneClear.UseQ:Value() then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if ValidTarget(minion, GetRange(myHero)+GetHitBox(myHero)) then
						if CanUseSpell(myHero,_Q) == READY then
							if Q2 then
								if MinionsAround(minion, 150) <= 1 then
									useQ(minion)
								end
							else
								if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > JinxMenu.LaneClear.MP:Value() then
									if MinionsAround(minion, 150) > 1 then
										useQ(minion)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

-- Anti-Gapcloser

function AntiGapcloser()
	for i,antigap in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_W) == READY then
			if JinxMenu.AntiGapcloser.UseW:Value() then
				if ValidTarget(antigap, JinxMenu.AntiGapcloser.DistanceW:Value()) then
					useW(antigap)
				end
			end
		elseif CanUseSpell(myHero,_E) == READY then
			if JinxMenu.AntiGapcloser.UseE:Value() then
				if ValidTarget(antigap, JinxMenu.AntiGapcloser.DistanceE:Value()) then
					useE(antigap)
				end
			end
		end
	end
end

-- Interrupter

OnProcessSpell(function(unit, spell)
	if JinxMenu.Interrupter.UseE:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, JinxMenu.Interrupter.Distance:Value()) then
				if CanUseSpell(myHero,_E) == READY then
					local UnitName = GetObjectName(enemy)
					local UnitChanellingSpells = CHANELLING_SPELLS[UnitName]
					local UnitGapcloserSpells = GAPCLOSER_SPELLS[UnitName]
					if UnitGapcloserSpells then
						for _, slot in pairs(UnitGapcloserSpells) do
							if spell.name == GetCastName(enemy, slot) then useE(enemy) end
						end
					end
				end
			end
		end
    end
end)

-- Kalista

elseif "Kalista" == GetObjectName(myHero) then

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U<font color='#1E90FF'>] <font color='#00BFFF'>Kalista loaded successfully!")
local KalistaMenu = Menu("[GoS-U] Kalista", "[GoS-U] Kalista")
KalistaMenu:Menu("Auto", "Auto")
KalistaMenu.Auto:Boolean('UseW', 'Use W [Sentinel]', true)
KalistaMenu.Auto:Boolean('UseR', 'Use R [Fates Call]', true)
KalistaMenu.Auto:Slider("MP","Mana-Manager: W", 40, 0, 100, 5)
KalistaMenu.Auto:Slider('HP','HP-Manager: R', 20, 0, 100, 5)
KalistaMenu:Menu("ERend", "E [Rend]")
KalistaMenu.ERend:Boolean('ResetE', 'Use E (Reset)', true)
KalistaMenu.ERend:Boolean('OutOfAA', 'Use E (Out Of AA)', true)
KalistaMenu.ERend:Slider("MS","Minimum Spears", 6, 0, 20, 1)
KalistaMenu:Menu("Combo", "Combo")
KalistaMenu.Combo:Boolean('UseQ', 'Use Q [Pierce]', true)
KalistaMenu.Combo:Boolean('UseE', 'Use E [Rend]', true)
KalistaMenu:Menu("Harass", "Harass")
KalistaMenu.Harass:Boolean('UseQ', 'Use Q [Pierce]', true)
KalistaMenu.Harass:Boolean('UseE', 'Use E [Rend]', true)
KalistaMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
KalistaMenu:Menu("KillSteal", "KillSteal")
KalistaMenu.KillSteal:Boolean('UseQ', 'Use Q [Pierce]', true)
KalistaMenu.KillSteal:Boolean('UseE', 'Use E [Rend]', true)
KalistaMenu:Menu("LastHit", "LastHit")
KalistaMenu.LastHit:Boolean('UseE', 'Use E [Rend]', true)
KalistaMenu:Menu("LaneClear", "LaneClear")
KalistaMenu.LaneClear:Boolean('UseQ', 'Use Q [Pierce]', true)
KalistaMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
KalistaMenu:Menu("Prediction", "Prediction")
KalistaMenu.Prediction:DropDown("PredictionQ", "Prediction: Q", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
KalistaMenu:Menu("Drawings", "Drawings")
KalistaMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
KalistaMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
KalistaMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
KalistaMenu.Drawings:Boolean('DrawDMG', 'Draw Max QE Damage', true)

local KalistaQ = { range = 1150, radius = 35, width = 70, speed = 2100, delay = 0.35, type = "line", collision = true, source = myHero, col = {"minion","yasuowall"}}
local KalistaE = { range = 1000 }
local KalistaR = { range = 1200 }

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	Harass()
	KillSteal()
	LastHit()
	LaneClear()
end)
OnDraw(function(myHero)
	Ranges()
	DrawDamage()
end)

function Ranges()
local pos = GetOrigin(myHero)
if KalistaMenu.Drawings.DrawQ:Value() then DrawCircle(pos,KalistaQ.range,1,25,0xff00bfff) end
if KalistaMenu.Drawings.DrawE:Value() then DrawCircle(pos,KalistaE.range,1,25,0xff1e90ff) end
if KalistaMenu.Drawings.DrawR:Value() then DrawCircle(pos,KalistaR.range,1,25,0xff0000ff) end
end

function DrawDamage()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local QDmg = (60*GetCastLevel(myHero,_Q)-50)+(GetBaseDamage(myHero)+GetBonusDmg(myHero))
		local EDmg = (10*GetCastLevel(myHero,_E)+10+(0.6*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))+(((4*GetCastLevel(myHero,_E)+6)+((0.025*GetCastLevel(myHero,_E)+0.175)*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))*(GotBuff(enemy,"kalistaexpungemarker")-1))
		local ComboDmg = QDmg + EDmg
		if ValidTarget(enemy) then
			if KalistaMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				end
			end
		end
	end
end

function useQ(target)
	if GetDistance(target) < KalistaQ.range then
		if KalistaMenu.Prediction.PredictionQ:Value() == 1 then
			CastSkillShot(_Q,GetOrigin(target))
		elseif KalistaMenu.Prediction.PredictionQ:Value() == 2 then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),KalistaQ.speed,KalistaQ.delay*1000,KalistaQ.range,KalistaQ.width,true,false)
			if QPred.HitChance == 1 then
				CastSkillShot(_Q, QPred.PredPos)
			end
		elseif KalistaMenu.Prediction.PredictionQ:Value() == 3 then
			local qPred = _G.gPred:GetPrediction(target,myHero,KalistaQ,false,true)
			if qPred and qPred.HitChance >= 3 then
				CastSkillShot(_Q, qPred.CastPosition)
			end
		elseif KalistaMenu.Prediction.PredictionQ:Value() == 4 then
			local QSpell = IPrediction.Prediction({name="KalistaMysticShot", range=KalistaQ.range, speed=KalistaQ.speed, delay=KalistaQ.delay, width=KalistaQ.width, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(KalistaQ.range)
			local x, y = QSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_Q, y.x, y.y, y.z)
			end
		elseif KalistaMenu.Prediction.PredictionQ:Value() == 5 then
			local QPrediction = GetLinearAOEPrediction(target,KalistaQ)
			if QPrediction.hitChance > 0.9 then
				CastSkillShot(_Q, QPrediction.castPos)
			end
		end
	end
end

-- Auto

function Auto()
	if KalistaMenu.Auto.UseW:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > KalistaMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if EnemiesAround(myHero, 2500) == 0 then
					if GetDistance(Vector(9882.892, -71.24, 4438.446)) < GetDistance(Vector(5087.77, -71.24, 10471.3808)) and GetDistance(Vector(9882.892, -71.24, 4438.446)) < 5200 then
						CastSkillShot(_W,9882.892, -71.24, 4438.446)
					elseif GetDistance(Vector(5087.77, -71.24, 10471.3808)) < 5200 then
						CastSkillShot(_W,5087.77, -71.24, 10471.3808)
					end
				end
			end
		end
	end
	if KalistaMenu.Auto.UseR:Value() then
		for _, ally in pairs(GetAllyHeroes()) do
			if CanUseSpell(myHero,_R) == READY and GotBuff(ally,"kalistacoopstrikeally") == 1 then
				if ValidTarget(ally, KalistaR.range) and EnemiesAround(ally, 1500) >= 1 then
					if (GetCurrentHP(ally)/GetMaxHP(ally))*100 <= KalistaMenu.Auto.HP:Value() then
						CastSpell(_R)
					end
				end
			end
		end
	end
end

-- Combo

function Combo()
	if Mode() == "Combo" then
		if KalistaMenu.Combo.UseQ:Value() then
			if CanUseSpell(myHero,_Q) == READY and AA == true then
				if ValidTarget(target, KalistaQ.range) then
					useQ(target)
				end
			end
		end
		if KalistaMenu.Combo.UseE:Value() then
			if CanUseSpell(myHero,_E) == READY then
				if ValidTarget(target, KalistaE.range) then
					if GetDistance(target, myHero) <= GetRange(myHero) then
						if KalistaMenu.ERend.ResetE:Value() then
							for i,minion in pairs(minionManager.objects) do
								if GetTeam(minion) == MINION_ENEMY then		
									if GotBuff(minion,"kalistaexpungemarker") >= 1 then
										local KalistaEDmg = (10*GetCastLevel(myHero,_E)+10+(0.6*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))+(((4*GetCastLevel(myHero,_E)+6)+((0.025*GetCastLevel(myHero,_E)+0.175)*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))*(GotBuff(minion,"kalistaexpungemarker")-1))
										if GetCurrentHP(minion) < KalistaEDmg then
											if GotBuff(target,"kalistaexpungemarker") >= KalistaMenu.ERend.MS:Value() then
												CastSpell(_E)
											end
										end
									end
								end
							end
						end
					elseif GetDistance(target, myHero) >= GetRange(myHero) then
						if KalistaMenu.ERend.OutOfAA:Value() then
							if GotBuff(target,"kalistaexpungemarker") >= KalistaMenu.ERend.MS:Value() then
								CastSpell(_E)
							end
						end
					end
				end
			end
		end
	end
end

-- Harass

function Harass()
	if Mode() == "Harass" then
		if KalistaMenu.Harass.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > KalistaMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_Q) == READY and AA == true then
					if ValidTarget(target, KalistaQ.range) then
						useQ(target)
					end
				end
			end
		end
		if KalistaMenu.Harass.UseE:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > KalistaMenu.Harass.MP:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, KalistaE.range) then
						if GetDistance(target, myHero) <= GetRange(myHero) then
							if KalistaMenu.ERend.ResetE:Value() then
								for i,minion in pairs(minionManager.objects) do
									if GetTeam(minion) == MINION_ENEMY then		
										if GotBuff(minion,"kalistaexpungemarker") >= 1 then
											local KalistaEDmg = (10*GetCastLevel(myHero,_E)+10+(0.6*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))+(((4*GetCastLevel(myHero,_E)+6)+((0.025*GetCastLevel(myHero,_E)+0.175)*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))*(GotBuff(minion,"kalistaexpungemarker")-1))
											if GetCurrentHP(minion) < KalistaEDmg then
												if GotBuff(target,"kalistaexpungemarker") >= KalistaMenu.ERend.MS:Value() then
													CastSpell(_E)
												end
											end
										end
									end
								end
							end
						elseif GetDistance(target, myHero) >= GetRange(myHero) then
							if KalistaMenu.ERend.OutOfAA:Value() then
								if GotBuff(target,"kalistaexpungemarker") >= KalistaMenu.ERend.MS:Value() then
									CastSpell(_E)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- KillSteal

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_Q) == READY then
			if KalistaMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, KalistaQ.range) then
					local KalistaQDmg = (60*GetCastLevel(myHero,_Q)-50)+(GetBaseDamage(myHero)+GetBonusDmg(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2) < KalistaQDmg then
						useQ(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_E) == READY then
			if KalistaMenu.KillSteal.UseE:Value() then
				if ValidTarget(enemy, KalistaE.range) and GotBuff(enemy,"kalistaexpungemarker") >= 1 then
					local KalistaEDmg = (10*GetCastLevel(myHero,_E)+10+(0.6*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))+(((4*GetCastLevel(myHero,_E)+6)+((0.025*GetCastLevel(myHero,_E)+0.175)*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))*(GotBuff(enemy,"kalistaexpungemarker")-1))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)) < KalistaEDmg then
						CastSpell(_E)
					end
				end
			end
		end
	end
end

-- LastHit

function LastHit()
	if Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if ValidTarget(minion, KalistaE.range) and GotBuff(minion,"kalistaexpungemarker") >= 1 then
					if KalistaMenu.LastHit.UseE:Value() then
						if CanUseSpell(myHero,_E) == READY then
							local KalistaEDmg = (10*GetCastLevel(myHero,_E)+10+(0.6*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))+(((4*GetCastLevel(myHero,_E)+6)+((0.025*GetCastLevel(myHero,_E)+0.175)*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))*(GotBuff(minion,"kalistaexpungemarker")-1))
							if GetCurrentHP(minion)+GetDmgShield(minion) < KalistaEDmg then
								CastSpell(_E)
							end
						end
					end
				end
			end
		end
	end
end

-- LaneClear

function LaneClear()
	if Mode() == "LaneClear" then
		if KalistaMenu.LaneClear.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > KalistaMenu.LaneClear.MP:Value() then
				for _, minion in pairs(minionManager.objects) do
					if GetTeam(minion) == MINION_ENEMY then
						if ValidTarget(minion, KalistaQ.range) then
							if CanUseSpell(myHero,_Q) == READY then
								CastSkillShot(_Q, GetOrigin(minion))
							end
						end
					end
				end
			end
		end
	end
end
end
