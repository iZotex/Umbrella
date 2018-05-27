local AutoBottle = {}


AutoBottle.optionEnable = Menu.AddOptionBool({ "Utility" }, "Auto Bottle")
    function AutoBottle.OnUpdate()
	if not Menu.IsEnabled(AutoBottle.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	local Use = NPC.GetItem(myHero, "item_bottle", true)
	if Use and NPC.HasModifier(myHero, "modifier_fountain_aura_buff") and Ability.IsReady(Use) then
	if Entity.GetHealth(myHero) < Entity.GetMaxHealth(myHero) or NPC.GetMana(myHero) < NPC.GetMaxMana(myHero) then
	if not NPC.HasModifier(myHero, "modifier_bottle_regeneration") and not NPC.IsChannellingAbility(myHero) then
				Ability.CastNoTarget(Use)
			end
		end
	end
end

return AutoBottle
