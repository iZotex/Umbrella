local TeamBottle = {}

TeamBottle.optionEnable = Menu.AddOptionBool({ "Utility" }, "Team Bottle")

function TeamBottle.OnUpdate()
    
	if not Menu.IsEnabled(TeamBottle.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	local Bottle = NPC.GetItem(myHero, "item_bottle", true)
	
	
	if Bottle and NPC.HasModifier(myHero, "modifier_fountain_aura_buff") and Ability.IsReady(Bottle) then
		for i = 1, Heroes.Count() do
			local hero = Heroes.Get(i)
			local myTeam = Entity.GetTeamNum( myHero )
			local sameTeam = Entity.GetTeamNum(hero) == myTeam
			if sameTeam and hero ~= myHero then
				if NPC.IsPositionInRange(myHero,Entity.GetAbsOrigin(hero), 600, 0) then
					if not NPC.HasModifier(hero, "modifier_bottle_regeneration") then 
                     Ability.CastTarget(Bottle,hero)					
						
					end
					
				end
			end 
		end
	end
end

return TeamBottle
