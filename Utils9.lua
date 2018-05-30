local Utils9 = {}

Utils9.AncientCreepNameList = {
    "npc_dota_neutral_black_drake",
    "npc_dota_neutral_black_dragon",
    "npc_dota_neutral_granite_golem",
    "npc_dota_neutral_prowler_acolyte",
    "npc_dota_neutral_prowler_shaman",
    "npc_dota_neutral_rock_golem",
    "npc_dota_neutral_big_thunder_lizard",
    "npc_dota_neutral_small_thunder_lizard",
    "npc_dota_roshan"
}

function Utils9.BestPosition(unitsAround, radius)
    if not unitsAround or #unitsAround <= 0 then return nil end
    local enemyNum = #unitsAround

	if enemyNum == 1 then return Entity.GetAbsOrigin(unitsAround[1]) end

	
	local maxNum = 1
	local bestPos = Entity.GetAbsOrigin(unitsAround[1])
	for i = 1, enemyNum-1 do
		for j = i+1, enemyNum do
			if unitsAround[i] and unitsAround[j] then
				local pos1 = Entity.GetAbsOrigin(unitsAround[i])
				local pos2 = Entity.GetAbsOrigin(unitsAround[j])
				local mid = pos1:__add(pos2):Scaled(0.5)

				local heroesNum = 0
				for k = 1, enemyNum do
					if NPC.IsPositionInRange(unitsAround[k], mid, radius, 0) then
						heroesNum = heroesNum + 1
					end
				end

				if heroesNum > maxNum then
					maxNum = heroesNum
					bestPos = mid
				end

			end
		end
	end

	return bestPos
end


function Utils9.GetPredictedPosition(npc, delay)
    local pos = Entity.GetAbsOrigin(npc)
    if Utils9.CantMove(npc) then return pos end
    if not NPC.IsRunning(npc) or not delay then return pos end

    local dir = Entity.GetRotation(npc):GetForward():Normalized()
    local speed = Utils9.GetMoveSpeed(npc)

    return pos + dir:Scaled(speed * delay)
end

function Utils9.GetMoveSpeed(npc)
    local base_speed = NPC.GetBaseSpeed(npc)
    local bonus_speed = NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)

    
    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return 100 end

    
    if Utils9.GetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end

    return base_speed + bonus_speed
end


function Utils9.IsLotusProtected(npc)
	if NPC.HasModifier(npc, "modifier_item_lotus_orb_active") then return true end

	local shield = NPC.GetAbility(npc, "antimage_spell_shield")
	if shield and Ability.IsReady(shield) and NPC.HasItem(npc, "item_ultimate_scepter", true) then
		return true
	end

	return false
end


function Utils9.IsLinkensProtected(npc)
    local shield = NPC.GetAbility(npc, "antimage_spell_shield")
	if shield and Ability.IsReady(shield) and NPC.HasItem(npc, "item_ultimate_scepter", true) then
		return true
	end

    return NPC.IsLinkensProtected(npc)
end


function Utils9.IsDisabled(npc)
	if not Entity.IsAlive(npc) then return true end
	if NPC.IsStunned(npc) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end

    return false
end


function Utils9.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.IsStructure(npc) or not NPC.IsKillable(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end

	return true
end


function Utils9.IsSafeToCast(myHero, enemy, magic_damage)
    if not myHero or not enemy or not magic_damage then return true end
    if magic_damage <= 0 then return true end

    local counter = 0
    if NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") then counter = counter + 1 end
    if NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") then counter = counter + 1 end

    local reflect_damage = counter * magic_damage * NPC.GetMagicalArmorDamageMultiplier(myHero)
    return Entity.GetHealth(myHero) > reflect_damage
end


function Utils9.NeedToBeSaved(npc)
	if not npc or NPC.IsIllusion(npc) or not Entity.IsAlive(npc) then return false end

	if NPC.IsStunned(npc) or NPC.IsSilenced(npc) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ROOTED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_DISARMED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_PASSIVES_DISABLED) then return true end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_BLIND) then return true end

	if Entity.GetHealth(npc) <= 0.3 * Entity.GetMaxHealth(npc) then return true end

	return false
end


function Utils9.PopDefensiveItems(myHero)
	if not myHero then return end

   
    if NPC.HasItem(myHero, "item_blade_mail", true) then
    	local item = NPC.GetItem(myHero, "item_blade_mail", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

   
    if NPC.HasItem(myHero, "item_hood_of_defiance", true) then
    	local item = NPC.GetItem(myHero, "item_hood_of_defiance", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

   
    if NPC.HasItem(myHero, "item_pipe", true) then
    	local item = NPC.GetItem(myHero, "item_pipe", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end


    if NPC.HasItem(myHero, "item_buckler", true) then
    	local item = NPC.GetItem(myHero, "item_buckler", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

   
    if NPC.HasItem(myHero, "item_crimson_guard", true) then
    	local item = NPC.GetItem(myHero, "item_crimson_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end


    if NPC.HasItem(myHero, "item_shivas_guard", true) then
    	local item = NPC.GetItem(myHero, "item_shivas_guard", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastNoTarget(item)
    	end
    end

    -- lotus orb
    if NPC.HasItem(myHero, "item_lotus_orb", true) then
    	local item = NPC.GetItem(myHero, "item_lotus_orb", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

    -- mjollnir
    if NPC.HasItem(myHero, "item_mjollnir", true) then
    	local item = NPC.GetItem(myHero, "item_mjollnir", true)
    	if Ability.IsCastable(item, NPC.GetMana(myHero)) then
    		Ability.CastTarget(item, myHero)
    	end
    end

end

function Utils9.IsAncientCreep(npc)
    if not npc then return false end

    for i, name in ipairs(Utils9.AncientCreepNameList) do
        if name and NPC.GetUnitName(npc) == name then return true end
    end

    return false
end

function Utils9.CantMove(npc)
    if not npc then return false end

    if NPC.IsRooted(npc) or Utils9.GetStunTimeLeft(npc) >= 1 then return true end
    if NPC.HasModifier(npc, "modifier_axe_berserkers_call") then return true end
    if NPC.HasModifier(npc, "modifier_legion_commander_duel") then return true end

    return false
end


Utils9.StunModifiers = {
    "modifier_stunned",
    "modifier_bashed",
    "modifier_antimage_mana_void",
    "modifier_bane_fiends_grip",
    "modifier_batrider_flaming_lasso",
    "modifier_beastmaster_primal_roar",
    "modifier_enigma_black_hole",
    "modifier_faceless_void_chronosphere",
    "modifier_kunkka_ghostship",
    "modifier_luna_eclipse",
    "modifier_magnataur_reverse_polarity",
    "modifier_medusa_stone_gaze",
    "modifier_naga_siren_song_of_the_siren",
    "modifier_necrolyte_reapers_scythe",
    "modifier_pangolier_gyroshell",
    "modifier_phoenix_supernova",
    "modifier_puck_dream_coil",
    "modifier_pudge_dismember",
    "modifier_rattletrap_hookshot",
    "modifier_sniper_assassinate",
    "modifier_tidehunter_ravage",
    "modifier_tusk_walrus_punch",
    "modifier_warlock_rain_of_chaos",
    "modifier_windrunner_focusfire",
    "modifier_winter_wyvern_winters_curse_aura"
}


Utils9.SleepModifiers = {
    "modifier_bane_nightmare",
    "modifier_elder_titan_echo_stomp",
    "modifier_naga_siren_song_of_the_siren"
}


Utils9.RootModifiers = {
    "modifier_abyssal_underlord_pit_of_malice_ensare",
    "modifier_crystal_maiden_frostbite",
    "modifier_dark_troll_warlord_ensnare",
    "modifier_dark_willow_bramble_maze",
    "modifier_ember_spirit_searing_chains",
    "modifier_lone_druid_spirit_bear_entangle_effect",
    "modifier_meepo_earthbind",
    "modifier_naga_siren_ensnare",
    "modifier_oracle_fortunes_end_purge",
    "modifier_rod_of_atos_debuff",
    "modifier_spawnlord_master_freeze",
    "modifier_techies_stasis_trap_stunned",
    "modifier_treant_natures_guise_root",
    "modifier_treant_overgrowth"
}


Utils9.TauntModifiers = {
    "modifier_axe_berserkers_call",
    "modifier_legion_commander_duel",
    "modifier_winter_wyvern_winters_curse"
}


function Utils9.GetStunTimeLeft(npc)
    local mod = NPC.GetModifier(npc, "modifier_stunned")
    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end


function Utils9.GetFixTimeLeft(npc)
    for i, val in ipairs(Utils9.StunModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    for i, val in ipairs(Utils9.SleepModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    for i, val in ipairs(Utils9.RootModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    for i, val in ipairs(Utils9.TauntModifiers) do
        local mod = NPC.GetModifier(npc, val)
        if mod then return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0) end
    end

    return 0
end


function Utils9.GetHexTimeLeft(npc)
    local mod
    local mod1 = NPC.GetModifier(npc, "modifier_sheepstick_debuff")
    local mod2 = NPC.GetModifier(npc, "modifier_lion_voodoo")
    local mod3 = NPC.GetModifier(npc, "modifier_shadow_shaman_voodoo")

    if mod1 then mod = mod1 end
    if mod2 then mod = mod2 end
    if mod3 then mod = mod3 end

    if not mod then return 0 end
    return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end


function Utils9.IsSuitableToCastSpell(myHero)
    if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end

    return true
end

function Utils9.IsSuitableToUseItem(myHero)
    if NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
    if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
    if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
    if NPC.IsChannellingAbility(myHero) then return false end

    return true
end


function Utils9.IsChannellingAbility(npc)
    if NPC.HasModifier(npc, "modifier_teleporting") then return true end
    if NPC.IsChannellingAbility(npc) then return true end

    return false
end

function Utils9.IsAffectedByDoT(npc)
    if not npc then return false end

    if NPC.HasModifier(npc, "modifier_item_radiance_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_item_urn_damage") then return true end
    if NPC.HasModifier(npc, "modifier_abyssal_underlord_firestorm_burn") then return true end
    if NPC.HasModifier(npc, "modifier_alchemist_acid_spray") then return true end
    if NPC.HasModifier(npc, "modifier_axe_battle_hunger") then return true end
    if NPC.HasModifier(npc, "modifier_bane_fiends_grip") then return true end
    if NPC.HasModifier(npc, "modifier_batrider_firefly") then return true end
    if NPC.HasModifier(npc, "modifier_brewmaster_fire_permanent_immolation") then return true end
    if NPC.HasModifier(npc, "modifier_cold_feet") then return true end
    if NPC.HasModifier(npc, "modifier_crystal_maiden_freezing_field") then return true end
    if NPC.HasModifier(npc, "modifier_crystal_maiden_frostbite") then return true end
    if NPC.HasModifier(npc, "modifier_dazzle_poison_touch") then return true end
    if NPC.HasModifier(npc, "modifier_disruptor_static_storm") then return true end
    if NPC.HasModifier(npc, "modifier_disruptor_thunder_strike") then return true end
    if NPC.HasModifier(npc, "modifier_doom_bringer_doom") then return true end
    if NPC.HasModifier(npc, "modifier_doom_bringer_scorched_earth_effect") then return true end
    if NPC.HasModifier(npc, "modifier_dragon_knight_corrosive_breath_dot") then return true end
    if NPC.HasModifier(npc, "modifier_earth_spirit_magnetize") then return true end
    if NPC.HasModifier(npc, "modifier_ember_spirit_flame_guard") then return true end
    if NPC.HasModifier(npc, "modifier_enigma_malefice") then return true end
    if NPC.HasModifier(npc, "modifier_gyrocopter_rocket_barrage") then return true end
    if NPC.HasModifier(npc, "modifier_huskar_burning_spear_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_ice_blast") then return true end
    if NPC.HasModifier(npc, "modifier_invoker_chaos_meteor_burn") then return true end
    if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_jakiro_dual_breath_burn") then return true end
    if NPC.HasModifier(npc, "modifier_jakiro_macropyre") then return true end
    if NPC.HasModifier(npc, "modifier_juggernaut_blade_fury") then return true end
    if NPC.HasModifier(npc, "modifier_leshrac_diabolic_edict") then return true end
    if NPC.HasModifier(npc, "modifier_leshrac_pulse_nova") then return true end
    if NPC.HasModifier(npc, "modifier_maledict") then return true end
    if NPC.HasModifier(npc, "modifier_ogre_magi_ignite") then return true end
    if NPC.HasModifier(npc, "modifier_phoenix_fire_spirit_burn") then return true end
    if NPC.HasModifier(npc, "modifier_phoenix_icarus_dive_burn") then return true end
    if NPC.HasModifier(npc, "modifier_phoenix_sun_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_pudge_rot") then return true end
    if NPC.HasModifier(npc, "modifier_pugna_life_drain") then return true end
    if NPC.HasModifier(npc, "modifier_queenofpain_shadow_strike") then return true end
    if NPC.HasModifier(npc, "modifier_rattletrap_battery_assault") then return true end
    if NPC.HasModifier(npc, "modifier_razor_eye_of_the_storm") then return true end
    if NPC.HasModifier(npc, "modifier_sandking_sand_storm") then return true end
    if NPC.HasModifier(npc, "modifier_silencer_curse_of_the_silent") then return true end
    if NPC.HasModifier(npc, "modifier_sniper_shrapnel_slow") then return true end
    if NPC.HasModifier(npc, "modifier_shredder_chakram_debuff") then return true end
    if NPC.HasModifier(npc, "modifier_treant_leech_seed") then return true end
    if NPC.HasModifier(npc, "modifier_venomancer_poison_nova") then return true end
    if NPC.HasModifier(npc, "modifier_venomancer_venomous_gale") then return true end
    if NPC.HasModifier(npc, "modifier_viper_viper_strike") then return true end
    if NPC.HasModifier(npc, "modifier_warlock_shadow_word") then return true end
    if NPC.HasModifier(npc, "modifier_warlock_golem_permanent_immolation_debuff") then return true end

    return false
end


function Utils9.GetCastRange(myHero, ability)
    return Ability.GetCastRange(ability)
   
end

function Utils9.GetSafeDirection(myHero)
    local mid = Vector()
    local pos = Entity.GetAbsOrigin(myHero)

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not Entity.IsSameTeam(myHero, enemy) then
            mid = mid + Entity.GetAbsOrigin(enemy)
        end
	end

    mid:Set(mid:GetX()/Heroes.Count(), mid:GetY()/Heroes.Count(), mid:GetZ()/Heroes.Count())
    return (pos + pos - mid):Normalized()
end

return Utils9
