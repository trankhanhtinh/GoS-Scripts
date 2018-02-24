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
-- Current version: 1.0.1
-- Intermediate GoS script which supports only ADC champions.
-- Features:
-- + Supports Ashe, Caitlyn
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
-- 1.0.1
-- + Added Caitlyn
-- 1.0
-- + Initial release
-- + Imported Ashe & Utility

local GSVer = 1.01

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

Heal = (GetCastName(myHero,SUMMONER_1):lower():find("summonerheal") and SUMMONER_1 or (GetCastName(myHero,SUMMONER_2):lower():find("summonerheal") and SUMMONER_2 or nil))
Barrier = (GetCastName(myHero,SUMMONER_1):lower():find("summonerbarrier") and SUMMONER_1 or (GetCastName(myHero,SUMMONER_2):lower():find("summonerbarrier") and SUMMONER_2 or nil))

OnTick(function(myHero)
	target = GetCurrentTarget()
	Items()
	LevelUp()
	SS()
end)

OnDraw(function(myHero)
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			DrawAA = WorldToScreen(1,GetOrigin(enemy).x, GetOrigin(enemy).y, GetOrigin(enemy).z)
			AALeft = (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy))/(GetBonusDmg(myHero)+GetBaseDamage(myHero))
			DrawText("AA Left: "..tostring(math.ceil(AALeft)), 17, DrawAA.x-33, DrawAA.y+10, 0xff00bfff)
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
		elseif "Caitlyn" == GetObjectName(myHero) then
			leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
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
			else
				for _, ally in pairs(GetAllyHeroes()) do
					if ValidTarget(ally) then
						if (GetCurrentHP(ally) / GetMaxHP(ally)) <= UtilityMenu.SS.HealAlly:Value() then
							CastSpell(Heal)
						end
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

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U v1.0<font color='#1E90FF'>] <font color='#00BFFF'>Ashe loaded successfully!")
local AsheMenu = Menu("[GoS-U] Ashe", "[GoS-U] Ashe")
AsheMenu:Menu("Auto", "Auto")
AsheMenu.Auto:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.Auto:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)
AsheMenu:Menu("Combo", "Combo")
AsheMenu.Combo:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.Combo:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.Combo:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.Combo:Slider('Distance','Distance: R', 2000, 0, 10000, 100)
AsheMenu.Combo:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
AsheMenu.Combo:Slider('HP','HP-Manager: R', 40, 0, 100, 5)
AsheMenu:Menu("Harass", "Harass")
AsheMenu.Harass:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.Harass:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)
AsheMenu:Menu("KillSteal", "KillSteal")
AsheMenu.KillSteal:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.KillSteal:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.KillSteal:Slider('Distance','Distance: R', 2000, 0, 10000, 100)
AsheMenu:Menu("LaneClear", "LaneClear")
AsheMenu.LaneClear:Boolean('UseQ', 'Use Q [Rangers Focus]', true)
AsheMenu.LaneClear:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)
AsheMenu:Menu("AntiGapcloser", "Anti-Gapcloser")
AsheMenu.AntiGapcloser:Boolean('UseW', 'Use W [Volley]', true)
AsheMenu.AntiGapcloser:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.AntiGapcloser:Slider('DistanceW','Distance: W', 200, 0, 500, 25)
AsheMenu.AntiGapcloser:Slider('DistanceR','Distance: R', 200, 0, 500, 25)
AsheMenu:Menu("Interrupter", "Interrupter")
AsheMenu.Interrupter:Boolean('UseR', 'Use R [Crystal Arrow]', true)
AsheMenu.Interrupter:Slider('Distance','Distance: R', 400, 0, 1000, 50)
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
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)) < AsheWDmg then
						useW(enemy)
					end
				end
			end
		elseif CanUseSpell(myHero,_R) == READY then
			if AsheMenu.KillSteal.UseR:Value() then
				if ValidTarget(enemy, AsheMenu.KillSteal.Distance:Value()) then
					local AsheRDmg = (200*GetCastLevel(myHero,_R))+(GetBonusAP(myHero))
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)) < AsheRDmg then
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

PrintChat("<font color='#1E90FF'>[<font color='#00BFFF'>GoS-U v1.0<font color='#1E90FF'>] <font color='#00BFFF'>Caitlyn loaded successfully!")
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
CaitlynMenu.AntiGapcloser:Slider('DistanceW','Distance: W', 300, 0, 500, 25)
CaitlynMenu.AntiGapcloser:Slider('DistanceE','Distance: E', 200, 0, 500, 25)
CaitlynMenu:Menu("Interrupter", "Interrupter")
CaitlynMenu.Interrupter:Boolean('UseW', 'Use W [Yordle Snap Trap]', true)
CaitlynMenu.Interrupter:Slider('Distance','Distance: W', 500, 0, 1000, 50)
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
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)) < CaitlynRDmg then
						DrawCircle(enemy,200,5,25,0xffffd700)
					end
				end
			end
		elseif CanUseSpell(myHero,_Q) == READY then
			if CaitlynMenu.KillSteal.UseQ:Value() then
				if ValidTarget(enemy, CaitlynQ.range) then
					local CaitlynQDmg = ((40*GetCastLevel(myHero,_Q)-10)+((0.1*GetCastLevel(myHero,_Q)+1.2)*(GetBonusDmg(myHero)+GetBaseDamage(myHero))))/3
					if (GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)) < CaitlynQDmg then
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
end
