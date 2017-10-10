-- Campeon:
if GetObjectName(GetMyHero()) ~= "Ryze" then return end
local ver = "1"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat("New version found! " .. data)
        PrintChat("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/rrayy/GoS/master/RayRyze.lua", SCRIPT_PATH .. "RayRyze.lua", function() PrintChat("Update Complete, please 2x F6!") return end)
    else
        PrintChat("No updates found!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/rrayy/GoS/master/Versions/RayRyze.version", AutoUpdate)

require ("OpenPredict")
require ("DamageLib")
-- Menu:
local RyzeMenu = Menu("Ryze", "Ryzerino")
-- Combo Menu:
RyzeMenu:SubMenu("Combo", "Combo")
RyzeMenu.Combo:rray Boolean("Q", "Use Q", true)
RyzeMenu.Combo:rray Boolean("W", "Use W", true)
RyzeMenu.Combo:rray Boolean("E", "Use E", true)
RyzeMenu.Combo:rray Slider("PRED", "Prediction", 70, 0, 100, 1)
-- Auto Last Hit Menu:
RyzeMenu:SubMenu("ALHM", "Auto lastHit")
RyzeMenu.ALHM:Boolean("ALH", "Use E", true)
RyzeMenu.ALHM:Slider("ManaALH", "Min. Mana", 30, 0, 100, 1)
-- LaneClear:
RyzeMenu:SubMenu("Farm", "Jungle/Lane")
RyzeMenu.Farm:Boolean("Q", "Use Q", true)
RyzeMenu.Farm:Boolean("W", "Use W", true)
RyzeMenu.Farm:Boolean("E", "Use E", true)
RyzeMenu.Farm:Slider("Mana", "Min. Mana", 70, 0, 100, 1)
-- Harass:
RyzeMenu:SubMenu("Harass", "Harass")
RyzeMenu.Harass:Boolean("Q", "Use Q", true)
RyzeMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
-- KS:
RyzeMenu:SubMenu("KS", "KillSteal")
RyzeMenu.KS:Boolean("Q", "Use Q", true)
-- Misc:
RyzeMenu:SubMenu('Misc', 'Misc')
RyzeMenu.Misc:Boolean('Tear', 'Auto Stack Tear', false)
RyzeMenu.Misc:Slider("ManaTear", "Min. Mana Stack", 80, 0, 100, 1)
--`SpellHability:
local Spells = {
 Q = { delay = 0.250, speed = 1700, width = 55, range = 1000 },
 W = { range = myHero:GetSpellData(_W).range },
 E = { range = myHero:GetSpellData(_E).range }
}
-- OrbWalker Detection:
function Mode()
	if _G.IOW_Loaded and IOW:Mode() then
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		return SLW:Mode()
	end
end
-- Ticking:
OnTick(function()
	target = GetCurrentTarget()
	         Combo()
             Limpieza()
             Harass()
             AutoLastHit()
             AutoStack()
	    end)  
-- Cast RyzeQ:
function RyzeQ()	
local QpI = GetPrediction(target, Spells.Q)
	if IsReady(_Q) and ValidTarget(target, GetCastRange(myHero, _Q)) and QpI and QpI.hitChance >= (RyzeMenu.Combo.PRED:Value()/100) and not QpI:mCollision(1) then
		CastSkillShot(_Q, QpI.castPos)
	end
end
-- Cast RyzeW:
function RyzeW()	
		CastTargetSpell(target ,_W)
end 
-- Cast RyzeE:
function RyzeE()	
		CastTargetSpell(target ,_E)
end 
-- WaveClear:
function Limpieza()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= RyzeMenu.Farm.Mana:Value() /100) then
-- LaneClear:
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if RyzeMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
							CastTargetSpell(minion ,_E)
						end	
					if RyzeMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
					end
				end	
-- Jungle:
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if RyzeMenu.Farm.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
							CastTargetSpell(mob ,_E)
						end	
					if RyzeMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
						end
					end
				end
			end
		end
	end
function Combo()
	if Mode() == "Combo" then
		if RyzeMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			RyzeE()
		end	
		if RyzeMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			RyzeQ()
		end	
		if RyzeMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			RyzeW()
		end	
end
end
function Harass()
	if Mode() == "Harass" then
	 if (myHero.mana/myHero.maxMana >= RyzeMenu.Harass.Mana:Value() /100) then
		if RyzeMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			RyzeQ()
		end	
	 end
end
end
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if RyzeMenu.KS.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				RyzeQ()
				end
			end
		end
	end
function AutoLastHit()
if (myHero.mana/myHero.maxMana >= RyzeMenu.ALHM.ManaALH:Value() /100) then
if Mode() ~= "Combo" then
	  	if Ready(_E) and RyzeMenu.ALHM.ALH:Value() then 
	  			for _, minion in pairs(minionManager.objects) do
	  				if IsObjectAlive(minion) and GetTeam(minion) ~= MINION_ALLY and GetDistance(minion) <= 700 and GetCurrentHP(minion) < getdmg("E", minion) then
	  					CastTargetSpell(minion, _E)
	  				end
	  			end
	  		end
end
end
end
function AutoStack()
	if GotBuff(myHero,"recall") == 0 then
	if RyzeMenu.Misc.Tear:Value() then
		if IsObjectAlive(myHero) then
		if (myHero.mana/myHero.maxMana >= RyzeMenu.Misc.ManaTear:Value() /100) then
			for _, enemy in pairs(GetEnemyHeroes()) do
				if GetDistance(myHero, enemy) > 3000 then
					if not UnderTurret(myHero, enemyTurret) then
						if GetItemSlot(myHero, 3070) > 0 then
							if Ready(_Q) then
								CastSkillShot(_Q, GetOrigin(myHero))
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
