local AutoChen = {}

AutoChen.ComboKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "0. Combo Key", Enum.ButtonCode.KEY_SPACE)
AutoChen.OnlyUnitsComboKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "1. Only Units Combo Key", Enum.ButtonCode.KEY_LSHIFT)
AutoChen.CallUnitsKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "2. Call Units Key", Enum.ButtonCode.KEY_4)
AutoChen.CastTowardKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "3. Cast Toward Key", Enum.ButtonCode.KEY_5)
AutoChen.SaveLowestFriendlyHeroKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "4. Save Friendly Hero Key", Enum.ButtonCode.KEY_TAB)
AutoChen.PersuadeKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "5. Persuade Key", Enum.ButtonCode.KEY_7)
AutoChen.DominateKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "6. Dominate Key", Enum.ButtonCode.KEY_8)
AutoChen.FarmKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "7. Farm Key", Enum.ButtonCode.KEY_9)
AutoChen.CallUnitsGoInvisKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "8. Call Units and Go Invisible Key", Enum.ButtonCode.KEY_G)
AutoChen.ResetRangeKey = Menu.AddKeyOption({"Hero Specific", "Chen"}, "9. Reset Range Key", Enum.ButtonCode.KEY_T)
AutoChen.Font = Renderer.LoadFont("Tahoma", 24, Enum.FontWeight.EXTRABOLD)

function AutoChen.OnGameStart()
  AutoChen.ResetGlobalVariables()
end

AutoChen.UseHeroList = {
  "npc_dota_hero_chen",
  "npc_dota_hero_lycan",
  "npc_dota_hero_beastmaster"
}

function AutoChen.OnPersuadeKey()

end

function AutoChen.OnDominateKey()

end

function AutoChen.OnCallUnitsKey()

end

function AutoChen.OnCallUnitsAndGoInvisibleKey()

end

function AutoChen.OnComboKeyDown()

end

function AutoChen.OnNeutralComboKeyDown()

end

function AutoChen.OnFarmKey()

end

function AutoChen.OnCastTowardMouseKey()

end

function AutoChen.OnSendBackKey()

end

function AutoChen.OnUpdate()
  if not GameRules.GetGameState() == 5 then return end
  if not Heroes.GetLocal() then return end
  for _, UnitName in ipairs(AutoChen.UseHeroList) do
    if UnitName == NPC.GetUnitName(Heroes.GetLocal()) then 
      if not AutoChen.Delay then 
        AutoChen.ResetGlobalVariables()
      end
      local myHero = Heroes.GetLocal()
      local myMana = NPC.GetMana(myHero)
      local myStr = Hero.GetStrengthTotal(myHero)
      local myAgi = Hero.GetAgilityTotal(myHero)
      local myInt = Hero.GetIntellectTotal(myHero)
      local myAttackRange = NPC.GetAttackRange(myHero)
      local mySpellAmp = 1 + (myInt * 0.07142857142) / 100
      local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
      local neutralEnemy = Input.GetNearestUnitToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
      local mousePos = Input.GetWorldCursorPos()
      local faith = NPC.GetAbility(myHero, "chen_test_of_faith")
      local penitence = NPC.GetAbility(myHero, "chen_penitence")
      local hand = NPC.GetAbility(myHero, "chen_hand_of_god")
      local persuasion = NPC.GetAbility(myHero, "chen_holy_persuasion")
      local attackPoint = 0.5
      local persuasionRange
      local hand_heal_amount
      local faith_max_damage
      local penitence_amp
      if faith then
        faith_max_damage = 100 * Ability.GetLevel(faith) * mySpellAmp
        faith_heal_amount = 50 * Ability.GetLevel(faith) * mySpellAmp
      end
      if penitence then
        penitence_amp = 1 + (12 + (Ability.GetLevel(penitence) * 6)) / 100
      end
      if hand then
        if NPC.GetAbility(myHero, "special_bonus_unique_chen_2") then
          hand_heal_amount = 325 + 100 * Ability.GetLevel(hand)
        else
          hand_heal_amount = 125 + 100 * Ability.GetLevel(hand)
        end
      end
      if persuasion then
        persuasionRange = Ability.GetCastRange(persuasion)
      end
      if persuasion and Menu.IsKeyDownOnce(AutoChen.CallUnitsKey) then
        Ability.CastTarget(persuasion, myHero)
      end
      if persuasion and Menu.IsKeyDownOnce(AutoChen.PersuadeKey) then
        AutoChen.PersuadeBestEnemyInRange()
      end
      if Menu.IsKeyDownOnce(AutoChen.DominateKey) then
        AutoChen.DominateBestEnemyInRange()
      end
      if persuasion and Menu.IsKeyDownOnce(AutoChen.CallUnitsGoInvisKey) then
        AutoChen.CallAndGoInvis()
      end
      if Entity.IsAlive(myHero) and not Entity.IsDormant(myHero) and Entity.GetHealth(myHero) > 0 then
        AutoChen.AutoSave()
      end
      if Menu.IsKeyDown(AutoChen.ComboKey) and enemy ~= nil and Entity.IsAlive(myHero) and not Entity.IsDormant(myHero) and Entity.GetHealth(myHero) > 0 then
        AutoChen.UseHeroAbilities()
      end
      if Menu.IsKeyDown(AutoChen.ComboKey) and enemy ~= nil then
        AutoChen.UseUnitAbilities()
      end
      if Menu.IsKeyDown(AutoChen.OnlyUnitsComboKey) and enemy ~= nil then
        AutoChen.UseUnitAbilities()
      end
      AutoChen.AutoBuff()
      if Menu.IsKeyDown(AutoChen.FarmKey) then
        AutoChen.UseUnitAbilitiesOnNPC()
      end
      AutoChen.ReadyToInvisCheck()
      AutoChen.AutoRaiseDead()
      if Menu.IsKeyDown(AutoChen.CastTowardKey) then
        AutoChen.UseShockwaveTowardCursor()
      end
      if Menu.IsKeyDown(AutoChen.SaveLowestFriendlyHeroKey) then
        AutoChen.SaveLowestFriendlyHero()
      end
      AutoChen.EnragedWildkinTornadoFollowEnemy() 
    end
  end
end

function AutoChen.OnDraw()
  if not GameRules.GetGameState() == 5 then return end
  local myHero = Heroes.GetLocal()
  if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_chen" then return end
  AutoChen.ControlOrderAwareness()
  AutoChen.SaveAwareness()
  AutoChen.CampAwareness()
  Log.Write(tostring(Ability.GetCooldownTimeLeft(NPC.GetAbility(Heroes.GetLocal(), "chen_penitence"))))

  for _, npc in ipairs(NPC.GetUnitsInRadius(myHero, 99999, Enum.TeamType.TEAM_FRIEND)) do
    if NPC.HasModifier(npc, "modifier_dominated") and not NPC.HasModifier(npc, "modifier_chen_holy_persuasion") and Entity.IsAlive(npc) and not Entity.IsDormant(npc) and Entity.GetHealth(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
      local pos3 = Entity.GetAbsOrigin(npc)
      local x3, y3, visible3 = Renderer.WorldToScreen(pos3)
      if visible3 and npc then
        Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(AutoChen.Font, x3+15, y3, "D", 1)
      end
    end

    if NPC.HasModifier(npc, "modifier_chen_test_of_faith_teleport") and Entity.IsAlive(npc) and not Entity.IsDormant(npc) and Entity.GetHealth(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
      local mod1 = AutoChen.round(Modifier.GetDieTime(NPC.GetModifier(npc, "modifier_chen_test_of_faith_teleport")) - GameRules.GetGameTime(), 1)
      local pos1 = Entity.GetAbsOrigin(npc)
      local pos2 = Entity.GetAbsOrigin(myHero)
      local x1, y1, visible1 = Renderer.WorldToScreen(pos1)
      local x2, y2, visible2 = Renderer.WorldToScreen(pos2)
      if visible1 and npc and mod1 and GameRules.GetGameTime() <= Modifier.GetDieTime(NPC.GetModifier(npc, "modifier_chen_test_of_faith_teleport")) then
        Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(AutoChen.Font, x1+15, y1+15, "(" .. tostring(mod1) .. ")", 1)
      end
      if visible2 and npc and mod1 and GameRules.GetGameTime() <= Modifier.GetDieTime(NPC.GetModifier(npc, "modifier_chen_test_of_faith_teleport")) then
        Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(AutoChen.Font, x2+15, y2+15, "(" .. tostring(mod1) .. ")", 1)
      end
    end
    if Entity.IsAlive(npc) and not Entity.IsDormant(npc) and not NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and not NPC.IsStructure(npc) and Entity.GetHealth(npc) and not Entity.IsHero(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
      local pos = Entity.GetAbsOrigin(npc)
      local x, y, visible = Renderer.WorldToScreen(pos)
      if visible and npc then
        local SpellCount = 0
        Renderer.SetDrawColor(255, 255, 255, 255)
        for _, spell in ipairs(AutoChen.InteractiveAbilities) do
          if NPC.GetAbility(npc, spell) then
            SpellCount = SpellCount + 1
            if SpellCount == 3 then
              if Ability.GetCooldownTimeLeft(NPC.GetAbility(npc, spell)) > 0 then
                Renderer.DrawText(AutoChen.Font, x-15, y-15, "\n" .. "\n" .. tostring(math.ceil(Ability.GetCooldownTimeLeft(NPC.GetAbility(npc, spell)))), 1) -- tostring(Ability.GetName(NPC.GetAbility(npc, spell))) .. " " ..
              end
            elseif SpellCount == 2 then
              if Ability.GetCooldownTimeLeft(NPC.GetAbility(npc, spell)) > 0 then
                Renderer.DrawText(AutoChen.Font, x-15, y-15, "\n" .. tostring(math.ceil(Ability.GetCooldownTimeLeft(NPC.GetAbility(npc, spell)))), 1) --tostring(Ability.GetName(NPC.GetAbility(npc, spell))) .. " " ..
              end
            else
              if Ability.GetCooldownTimeLeft(NPC.GetAbility(npc, spell)) > 0 then
                Renderer.DrawText(AutoChen.Font, x-15, y-15, tostring(math.ceil(Ability.GetCooldownTimeLeft(NPC.GetAbility(npc, spell)))), 1) --tostring(Ability.GetName(NPC.GetAbility(npc, spell))) .. " "
              end
            end
          end
        end
      end
    end
  end

  if GameRules.GetGameTime() - AutoChen.CircleDrawTime > 5 then
    Engine.ExecuteCommand("dota_range_display " .. tostring(NPC.GetAttackRange(myHero)))
    AutoChen.CircleDrawTime = GameRules.GetGameTime()
  end

  if Menu.IsKeyDownOnce(AutoChen.ResetRangeKey) then
    for _, value in ipairs(AutoChen.MyParticles) do
      Particle.Destroy(value)
    end
    AutoChen.DrawnRange = nil
  end

  if AutoChen.DrawnRange == nil then
    for _, value in ipairs(AutoChen.RangeAbilityItems) do
      local myability = NPC.GetAbility(myHero, value)
      if not myability then 
        myability = NPC.GetItem(myHero, value, true)
      end
      if myability then
        local radius = Ability.GetCastRange(myability)
        local offset = radius * .125
        local particle = Particle.Create("particles\\ui_mouseactions\\drag_selected_ring.vpcf", Enum.ParticleAttachment.PATTACH_ABSORIGIN_FOLLOW, myHero)
        table.insert(AutoChen.MyParticles, particle)
        local color = Vector(0, 255, 0) -- green
        if value == "item_sheepstick" then
          color = Vector(255, 255, 255) -- white
        elseif value == "item_orchid" or value == "item_bloodthorn" then
          color = Vector(255, 128, 0) -- orange
        elseif value == "item_rod_of_atos" then
          -- color = Vector(0, 0, 255) -- blue
          color = Vector(255, 255, 0) -- yellow
        elseif value == "item_veil_of_discord" then
          color = Vector(127, 0, 255) -- purple
        elseif value == "item_ethereal_blade" then
          Vector(0, 255, 0) -- green
          color = Vector(0, 255, 255) -- cyan
        elseif value == "item_dagon" or value == "item_dagon_2" or value == "item_dagon_3" or value == "item_dagon_4" or value == "item_dagon_5" then
          color = Vector(255, 0, 0) -- red
        elseif value == "chen_penitence" then
          color = Vector(255, 0, 255) -- pink
        elseif value == "chen_test_of_faith" then
          color = Vector(127, 127, 127) -- grey
        end
        if offset then
          Particle.SetControlPoint(particle, 1, color) -- color
          Particle.SetControlPoint(particle, 3, Vector(10, 0, 0)) -- dotted movement
          Particle.SetControlPoint(particle, 2, Vector(radius+offset, 255, 0)) -- radius, transparency, unknown
          Particle.SetControlPoint(particle, 0, Entity.GetAbsOrigin(myHero)) -- follow
        end
      end
    end
    AutoChen.DrawnRange = 1
  end



end

function AutoChen.DoesTableContain(table, element)
  for _, value in pairs(table) do
    if value[1] == element then
      return value[2]
    end
  end
  return false
end

function AutoChen.ResetGlobalVariables()
  AutoChen.MyParticles = {}
  AutoChen.RangeAbilityTable = {}
  AutoChen.MyUnits = {}
  AutoChen.CampUnits = {}
  AutoChen.AutoBuffTime = 0
  AutoChen.TornadoMoveTime = 0
  AutoChen.RaiseDeadTime = 0
  AutoChen.TricksterMoveTime = 0
  AutoChen.ProjectileTime = 0
  AutoChen.ItemUseTime = 0
  AutoChen.HeroAbilityUseTime = 0
  AutoChen.UnitAbilityUseTime = 0
  AutoChen.Delay = .05
  AutoChen.StunTime = 0
  AutoChen.StunDuration = 0
  AutoChen.AttackOrderTime = 0
  AutoChen.MoveOrderTime = 0
  AutoChen.FarmManaThreshold = 0.35
  AutoChen.CircleDrawTime = 0
  AutoChen.OrbWalkTime = 0
  AutoChen.CheckDeadTime = 0
  AutoChen.MoveNPCOrderTime = 0
  AutoChen.AttackNPCOrderTime = 0
  AutoChen.ReadyToInvisTime = nil
  AutoChen.TornadoCheckTime = 0
end

function AutoChen.GetUnit(table, element)
  for _, value in pairs(table) do
    if value[1] == element then
      return true
    end
  end
  return false
end

function AutoChen.GetUnitCreationTime(table, element)
  for _, value in pairs(table) do
    if value[1] == element then
      return value[2]
    end
  end
  return false
end

function AutoChen.ControlOrderAwareness()
  -- -- awareness of which units will die when persuaded over etc
  -- local myHero = Heroes.GetLocal()

  -- for i = 1, NPCs.Count() do
  --   local npc = NPCs.Get(i)
  --   local pos = NPC.GetAbsOrigin(npc)
  --   local x, y, visible = Renderer.WorldToScreen(pos)
  --   local unitTime

  --   if npc and Entity.IsNPC(npc) and Entity.IsAlive(npc) and Entity.GetHealth(npc) > 0 and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) and NPC.HasModifier(npc, "modifier_chen_holy_persuasion") then
  --     for k, v in ipairs(AutoChen.AghsUsefulCreepNameList) do
  --       if v == NPC.GetUnitName(npc) then
  --         if AutoChen.GetUnit(AutoChen.MyUnits, npc) then
  --           unitTime = AutoChen.GetUnitCreationTime(AutoChen.MyUnits, npc)
  --         else
  --           unitTime = GameRules.GetGameTime()
  --           table.insert(AutoChen.MyUnits, {npc, unitTime})
  --         end
  --       end
  --     end
  --   end
  -- end

  -- for i = 1, NPCs.Count() do
  --   local npc = NPCs.Get(i)
  --   local pos = NPC.GetAbsOrigin(npc)
  --   local x, y, visible = Renderer.WorldToScreen(pos)
  --   local unitTime
  --   for k, npc in ipairs(AutoChen.MyUnits) do
  --     if npc[1] and Entity.IsNPC(npc[1]) and Entity.IsAlive(npc[1]) and Entity.GetHealth(npc[1]) > 0 and (Entity.GetOwner(myHero) == Entity.GetOwner(npc[1]) or Entity.OwnedBy(npc[1], myHero)) and NPC.HasModifier(npc[1], "modifier_chen_holy_persuasion") then

  --       if visible and npc and unitTime ~= nil then
  --         unitTime = math.floor(unitTime / 60)
  --         Renderer.SetDrawColor(255, 255, 255, 200) -- white
  --         Renderer.DrawText(AutoChen.Font, x+15, y, unitTime, 1)
  --       end
  --     end
  --   end
  -- end
end

function AutoChen.CampAwareness()
  -- awareness of neutral creeps on map
  local myHero = Heroes.GetLocal()

  for i = 1, NPCs.Count() do
    local npc = NPCs.Get(i)
    if npc and Entity.IsNPC(npc) and NPC.IsNeutral(npc) and not NPC.IsStructure(npc) and not NPC.IsLaneCreep(npc) and not NPC.IsRoshan(npc) and Entity.IsAlive(npc) and Entity.GetOwner(myHero) ~= Entity.GetOwner(npc) and not Entity.OwnedBy(npc, myHero) then
      local pos = Entity.GetAbsOrigin(npc)
      local x, y, visible = Renderer.WorldToScreen(pos)
      local unitTime

      if AutoChen.GetUnit(AutoChen.CampUnits, npc) then
        unitTime = AutoChen.GetUnitCreationTime(AutoChen.CampUnits, npc)
      else
        unitTime = GameRules.GetGameTime()
        table.insert(AutoChen.CampUnits, {npc, unitTime})
      end

      unitTime = math.floor(unitTime / 60)

      if visible and npc then
        if NPC.IsWaitingToSpawn(npc) then
          Renderer.SetDrawColor(255, 0, 0, 200) -- red
        else
          Renderer.SetDrawColor(255, 255, 255, 200) -- white
        end
        local fullname = tostring(NPC.GetUnitName(npc))
        if fullname == "npc_dota_neutral_alpha_wolf" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "wolf" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_big_thunder_lizard" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "liz" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_black_dragon" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "dragon" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_centaur_khan" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "centaur" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_enraged_wildkin" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "bird" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_granite_golem" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "golem" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_satyr_hellcaller" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "satyr" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_dark_troll_warlord" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "troll" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_polar_furbolg_ursa_warrior" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "ursa" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_prowler_shaman" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "prowler" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_harpy_storm" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "harpy" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_ghost" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "ghost" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_forest_troll_high_priest" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "priest" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_kobold_taskmaster" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "kobold" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_satyr_trickster" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "trick" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_mud_golem" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "mud" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_ogre_magi" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "ogre" .. " " .. unitTime, 1)
        end
        if fullname == "npc_dota_neutral_gnoll_assassin" then
          Renderer.DrawText(AutoChen.Font, x+15, y, "poison" .. " " .. unitTime, 1)
        end
      end
    end
  end
end

function AutoChen.AutoRaiseDead()
  local myHero = Heroes.GetLocal()
  if GameRules.GetGameTime() - AutoChen.RaiseDeadTime > 0.2 then
    for i = 1, NPCs.Count() do
      local npc = NPCs.Get(i)
      if Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero) then
        if NPC.HasAbility(npc, "dark_troll_warlord_raise_dead") and Entity.IsAlive(npc) then
          local RaiseDead = NPC.GetAbility(npc, "dark_troll_warlord_raise_dead")
          local npcMana = NPC.GetMana(npc)
          local npcLocation = Entity.GetAbsOrigin(npc) 
          if Ability.IsReady(RaiseDead) and Ability.IsCastable(RaiseDead, npcMana) and not Ability.IsInAbilityPhase(RaiseDead) and Ability.GetCooldownTimeLeft(RaiseDead) == 0.0 then
            for i = 1, NPCs.Count() do
              local npc = NPCs.Get(i)
              if Entity.GetHealth(npc) <= 0 and not Entity.IsDormant(npc) and (Entity.GetAbsOrigin(npc)-npcLocation):Length2D() < 500 then -- change to 550 if no problems?
                Ability.CastNoTarget(RaiseDead)
                AutoChen.RaiseDeadTime = GameRules.GetGameTime()
                break
              end
            end
          end
        end
      end
    end
  end
end

function AutoChen.SaveLowestFriendlyHero()
  local myHero = Heroes.GetLocal()
  local persuasion = NPC.GetAbility(myHero, "chen_holy_persuasion")
  local persuasionRange
  if persuasion then
    persuasionRange = Ability.GetCastRange(persuasion)
  end
  if not persuasion then return end
  local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
  if target ~= myHero then
    Ability.CastTarget(persuasion, target)
  end
end

function AutoChen.SaveAwareness()
  local myHero = Heroes.GetLocal()
  local persuasion = NPC.GetAbility(myHero, "chen_holy_persuasion")
  local persuasionRange
  if persuasion then
    persuasionRange = Ability.GetCastRange(persuasion)
  end

  if not persuasion then return end
  local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_FRIEND)
  if target ~= myHero then
    if target == nil then return end
    local pos = Entity.GetAbsOrigin(target)
    local x, y, visible = Renderer.WorldToScreen(pos)
    if visible and target then
      Renderer.SetDrawColor(255, 255, 255, 255)
      Renderer.DrawText(AutoChen.Font, x+15, y, "Save", 1)
    end
  end
end

function AutoChen.EnragedWildkinTornadoFollowEnemy()
  local myHero = Heroes.GetLocal()
  if GameRules.GetGameTime() - AutoChen.TornadoMoveTime > 0.2 then
    for i = 1, NPCs.Count() do
      local npc = NPCs.Get(i)
      if Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero) then
        if NPC.GetUnitName(npc) == "npc_dota_enraged_wildkin_tornado" then
          local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(npc), Enum.TeamType.TEAM_ENEMY)
          if enemy and NPC.IsPositionInRange(npc, Entity.GetAbsOrigin(enemy), 4000) then
            NPC.MoveTo(npc, AutoChen.GetPredictedPosition(enemy, 1))
            AutoChen.TornadoMoveTime = GameRules.GetGameTime()
          end
        end
      end
    end
  end
end

function AutoChen.ReadyToCast(npc, ability)
  if not ability then return false end
  if AutoChen.IsSuitableToCastSpell(npc) and not AutoChen.IsDisabled(npc) and Ability.IsReady(ability) and Ability.IsCastable(ability, NPC.GetMana(npc)) and not Ability.IsChannelling(ability) and Ability.GetCooldownTimeLeft(ability) == 0.0 then
    return true
  else 
    return false
  end
end

function AutoChen.PersuadeBestEnemyInRange()
  local myHero = Heroes.GetLocal()
  local persuasion = NPC.GetAbility(myHero, "chen_holy_persuasion")
  local persuasionRange
  if persuasion then
    persuasionRange = Ability.GetCastRange(persuasion)
  end
  local aghs = NPC.GetItem(myHero, "item_ultimate_scepter", true)
  local myHeroLocation = Entity.GetAbsOrigin(myHero)

  if AutoChen.ReadyToCast(myHero, persuasion) then
    for i = 1, NPCs.Count() do
      local npc = NPCs.Get(i)
      if Entity.GetHealth(npc) > 0 and not Entity.IsSameTeam(myHero, npc) and not Entity.IsDormant(npc) and not NPC.IsWaitingToSpawn(npc) then
        if (Entity.GetAbsOrigin(npc)-myHeroLocation):Length2D() <= persuasionRange then
          if aghs then
            for k, v in ipairs(AutoChen.AghsUsefulCreepNameList) do
              if v == NPC.GetUnitName(npc) then
                Ability.CastTarget(persuasion, npc)
                return
              end
            end
          else
            for k, v in ipairs(AutoChen.UsefulCreepNameList) do
              if v == NPC.GetUnitName(npc) then
                Ability.CastTarget(persuasion, npc)
                return
              end
            end
          end
        end
      end
    end
  end
end

function AutoChen.DominateBestEnemyInRange()
  local myHero = Heroes.GetLocal()
  local dominateItem = NPC.GetItem(myHero, "item_helm_of_the_dominator", true)
  local dominateRange
  if dominateItem then
    dominateRange = Ability.GetCastRange(dominateItem)
  end
  local myHeroLocation = Entity.GetAbsOrigin(myHero)

  if AutoChen.ReadyToCast(myHero, dominateItem) then
    for i = 1, NPCs.Count() do
      local npc = NPCs.Get(i)
      if Entity.GetHealth(npc) > 0 and not Entity.IsSameTeam(myHero, npc) and not Entity.IsDormant(npc) and not NPC.IsWaitingToSpawn(npc) then
        if (Entity.GetAbsOrigin(npc)-myHeroLocation):Length2D() <= dominateRange then
          for k, v in ipairs(AutoChen.UsefulCreepNameList) do
            if v == NPC.GetUnitName(npc) then
              Ability.CastTarget(dominateItem, npc)
              return
            end
          end
        end
      end
    end
  end
end

function AutoChen.CallAndGoInvis()
  local myHero = Heroes.GetLocal()
  local myMana = NPC.GetMana(myHero)
  local persuasion = NPC.GetAbility(myHero, "chen_holy_persuasion")
  local shadow_blade = NPC.GetItem(myHero, "item_invis_sword", true)
  local silver_edge = NPC.GetItem(myHero, "item_silver_edge", true)
  if silver_edge and Ability.IsReady(silver_edge) and Ability.IsCastable(silver_edge, myMana) and not Ability.IsInAbilityPhase(silver_edge) then
    if persuasion and Ability.IsReady(persuasion) and Ability.IsCastable(persuasion, myMana) and not Ability.IsInAbilityPhase(persuasion) then
      Ability.CastTarget(persuasion, myHero)
      AutoChen.ReadyToInvisTime = GameRules.GetGameTime() + Ability.GetCastPoint(persuasion) + .05
    elseif not persuasion or not Ability.IsReady(persuasion) then
      AutoChen.ReadyToInvisTime = GameRules.GetGameTime()
    end
    return
  end
  if shadow_blade and Ability.IsReady(shadow_blade) and Ability.IsCastable(shadow_blade, myMana) and not Ability.IsInAbilityPhase(shadow_blade) then
    if persuasion and Ability.IsReady(persuasion) and Ability.IsCastable(persuasion, myMana) and not Ability.IsInAbilityPhase(persuasion) then
      Ability.CastTarget(persuasion, myHero)
      AutoChen.ReadyToInvisTime = GameRules.GetGameTime() + Ability.GetCastPoint(persuasion) + .05
    elseif not persuasion or not Ability.IsReady(persuasion) then
      AutoChen.ReadyToInvisTime = GameRules.GetGameTime()
    end
    return
  end
end

function AutoChen.ReadyToInvisCheck()
  local myHero = Heroes.GetLocal()
  local myMana = NPC.GetMana(myHero)
  if not AutoChen.ReadyToInvisTime then return end
  local shadow_blade = NPC.GetItem(myHero, "item_invis_sword", true)
  local silver_edge = NPC.GetItem(myHero, "item_silver_edge", true)
  if GameRules.GetGameTime() >= AutoChen.ReadyToInvisTime then
    AutoChen.ReadyToInvisTime = nil
    if silver_edge and Ability.IsReady(silver_edge) and Ability.IsCastable(silver_edge, myMana) and not Ability.IsInAbilityPhase(silver_edge) then
      Ability.CastNoTarget(silver_edge)
    end
    if shadow_blade and Ability.IsReady(shadow_blade) and Ability.IsCastable(shadow_blade, myMana) and not Ability.IsInAbilityPhase(shadow_blade) then
      Ability.CastNoTarget(shadow_blade)
    end
  end
end

function AutoChen.castLinearPrediction(myHero, enemy, adjustmentVariable)

  if not myHero then return end
  if not enemy then return end

  local enemyRotation = Entity.GetRotation(enemy):GetVectors()
  enemyRotation:SetZ(0)
  local enemyOrigin = Entity.GetAbsOrigin(enemy)
  enemyOrigin:SetZ(0)


  local cosGamma = (Entity.GetAbsOrigin(myHero) - enemyOrigin):Dot2D(enemyRotation:Scaled(100)) / ((Entity.GetAbsOrigin(myHero) - enemyOrigin):Length2D() * enemyRotation:Scaled(100):Length2D())
  if enemyRotation and enemyOrigin then
    if not NPC.IsRunning(enemy) then
      return enemyOrigin
    else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(AutoChen.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
    end
  end
end

function AutoChen.GetMoveSpeed(enemy)

  if not enemy then return end

  local base_speed = NPC.GetBaseSpeed(enemy)
  local bonus_speed = NPC.GetMoveSpeed(enemy) - NPC.GetBaseSpeed(enemy)
  local modifierHex
  local modSheep = NPC.GetModifier(enemy, "modifier_sheepstick_debuff")
  local modLionVoodoo = NPC.GetModifier(enemy, "modifier_lion_voodoo")
  local modShamanVoodoo = NPC.GetModifier(enemy, "modifier_shadow_shaman_voodoo")

  if modSheep then
    modifierHex = modSheep
  end
  if modLionVoodoo then
    modifierHex = modLionVoodoo
  end
  if modShamanVoodoo then
    modifierHex = modShamanVoodoo
  end

  if modifierHex then
    if math.max(Modifier.GetDieTime(modifierHex) - GameRules.GetGameTime(), 0) > 0 then
      return 140 + bonus_speed
    end
  end

  if NPC.HasModifier(enemy, "modifier_invoker_ice_wall_slow_debuff") then
    return 100
  end

  if NPC.HasModifier(enemy, "modifier_invoker_cold_snap_freeze") or NPC.HasModifier(enemy, "modifier_invoker_cold_snap") then
    return (base_speed + bonus_speed) * 0.5
  end

  if NPC.HasModifier(enemy, "modifier_spirit_breaker_charge_of_darkness") then
    local chargeAbility = NPC.GetAbility(enemy, "spirit_breaker_charge_of_darkness")
    if chargeAbility then
      local specialAbility = NPC.GetAbility(enemy, "special_bonus_unique_spirit_breaker_2")
      if specialAbility then
        if Ability.GetLevel(specialAbility) < 1 then
          return Ability.GetLevel(chargeAbility) * 50 + 550
        else
          return Ability.GetLevel(chargeAbility) * 50 + 1050
        end
      end
    end
  end

  return base_speed + bonus_speed
end

function AutoChen.UseUnitAbilities()
  local myHero = Heroes.GetLocal()
  local myMana = NPC.GetMana(myHero)
  local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)

  if enemy and GameRules.GetGameTime() - AutoChen.UnitAbilityUseTime >= AutoChen.Delay then
    for _, npc in ipairs(NPC.GetUnitsInRadius(myHero, 99999, Enum.TeamType.TEAM_FRIEND)) do
      if Entity.IsAlive(npc) and not Entity.IsDormant(npc) and Entity.GetHealth(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
        for _, ability in ipairs(AutoChen.InteractiveAbilities) do
          if ability ~= "dark_troll_warlord_raise_dead" and ability ~= "forest_troll_high_priest_heal" and ability ~= "enraged_wildkin_tornado" and ability ~= "ogre_magi_frost_armor" and ability ~= "big_thunder_lizard_frenzy" then
            if NPC.HasAbility(npc, ability) and Ability.IsCastable(NPC.GetAbility(npc, ability), NPC.GetMana(npc)) and Ability.IsReady(NPC.GetAbility(npc, ability)) and not Ability.IsInAbilityPhase(NPC.GetAbility(npc, ability)) and not NPC.IsLinkensProtected(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
              if Ability.GetCastRange(NPC.GetAbility(npc, ability)) > 0 then
                if ability == "satyr_hellcaller_shockwave" then
                  if NPC.HasAbility(npc, ability) and Ability.IsCastable(NPC.GetAbility(npc, ability), NPC.GetMana(npc)) and Ability.IsReady(NPC.GetAbility(npc, ability)) and not Ability.IsInAbilityPhase(NPC.GetAbility(npc, ability)) and NPC.IsPositionInRange(npc, AutoChen.GetPredictedPosition(enemy, (((Entity.GetAbsOrigin(npc) - Entity.GetAbsOrigin(enemy)):Length2D()/900)+0.5)), 1580) then
                    Ability.CastPosition(NPC.GetAbility(npc, ability), Entity.GetAbsOrigin(npc) + (AutoChen.GetPredictedPosition(enemy, (((Entity.GetAbsOrigin(npc) - Entity.GetAbsOrigin(enemy)):Length2D()/900)+0.5)) - Entity.GetAbsOrigin(npc)):Normalized():Scaled(700))
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                  end
                  return
                end
                if NPC.IsEntityInRange(npc, enemy, Ability.GetCastRange(NPC.GetAbility(npc, ability)) + NPC.GetCastRangeBonus(npc)) then
                  if ability == "black_dragon_fireball" then
                    Ability.CastPosition(NPC.GetAbility(npc, ability), Entity.GetAbsOrigin(enemy))
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                  if ability == "spawnlord_master_freeze" or ability == "dark_troll_warlord_ensnare" or ability == "mud_golem_hurl_boulder" then
                    if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                      return
                    end
                    if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration then
                      Ability.CastTarget(NPC.GetAbility(npc, ability), enemy)
                      AutoChen.StunTime = GameRules.GetGameTime()
                      if ability == "spawnlord_master_freeze" then
                        AutoChen.StunDuration = 2
                      end
                      if ability == "dark_troll_warlord_ensnare" then
                        AutoChen.StunDuration = 1.75
                      end
                      if ability == "mud_golem_hurl_boulder" then
                        AutoChen.StunDuration = 0.6
                      end
                      AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                      return
                    end
                  end
                  Ability.CastTarget(NPC.GetAbility(npc, ability), enemy)
                  AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                  return
                end
              end

              if Ability.GetCastRange(NPC.GetAbility(npc, ability)) == 0 then
                if ability == "big_thunder_lizard_slam" then
                  if NPC.IsEntityInRange(npc, enemy, 250) then
                    Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                end
                if ability == "centaur_khan_war_stomp" then
                  if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                    return
                  end
                  if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration and NPC.IsPositionInRange(npc, AutoChen.GetPredictedPosition(enemy, 0.4), 250) and NPC.IsPositionInRange(npc, Entity.GetAbsOrigin(enemy), 250) then
                    Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                    AutoChen.StunTime = GameRules.GetGameTime() - 0.4
                    AutoChen.StunDuration = 2
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                end
                if ability == "polar_furbolg_ursa_warrior_thunder_clap" then
                  if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                    return
                  end
                  if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration and NPC.IsPositionInRange(npc, AutoChen.GetPredictedPosition(enemy, 0.4), 300) and NPC.IsPositionInRange(npc, Entity.GetAbsOrigin(enemy), 300) then
                    Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                end

                if ability == "satyr_trickster_purge" then
                  if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                    return
                  end
                  if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration and NPC.IsPositionInRange(npc, AutoChen.GetPredictedPosition(enemy, 0.2), 350) then
                    Ability.CastTarget(NPC.GetAbility(npc, ability), enemy)
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  elseif NPC.IsPositionInRange(npc, Entity.GetAbsOrigin(enemy), 340) then
                    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Entity.GetAbsOrigin(enemy), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
                  end
                end
                if NPC.IsEntityInRange(npc, enemy, NPC.GetAttackRange(npc)) then
                  if ability ~= "big_thunder_lizard_slam" then
                    Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                end

                if ability == "necronomicon_archer_purge" then
                  if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                    return
                  end
                  if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration and NPC.IsPositionInRange(npc, AutoChen.GetPredictedPosition(enemy, 0.3), 600) then
                    Ability.CastTarget(NPC.GetAbility(npc, ability), enemy)
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                end

              end
            end
          end
        end
      end
    end
  end

  if not enemy or not Entity.IsAlive(enemy) or Entity.IsDormant(enemy) or Entity.GetHealth(enemy) <= 0 or not NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 900, 0) then
    if GameRules.GetGameTime() - AutoChen.MoveNPCOrderTime > 0.05 then
      for i = 1, NPCs.Count() do
        local npc = NPCs.Get(i)
        if Entity.GetHealth(npc) > 0 and Entity.IsSameTeam(myHero, npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) and npc ~= myHero and NPC.GetUnitName(npc) ~= "npc_dota_courier" then
          Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
          -- Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS, nil)
        end
      AutoChen.MoveNPCOrderTime = GameRules.GetGameTime()
      end
    end
  end
  if enemy and NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 900, 0) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ATTACK_IMMUNE) then
    if GameRules.GetGameTime() - AutoChen.AttackNPCOrderTime > 0.96  then
      for i = 1, NPCs.Count() do
        local npc = NPCs.Get(i)
        if Entity.GetHealth(npc) > 0 and Entity.IsSameTeam(myHero, npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) and npc ~= myHero and NPC.GetUnitName(npc) ~= "npc_dota_courier" then
          Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, enemy, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
          -- Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, enemy, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS, nil)
        end
      AutoChen.AttackNPCOrderTime = GameRules.GetGameTime()
      end
    end
  end

  if GameRules.GetGameTime() - AutoChen.TricksterMoveTime > .25 then
    for _, npc in ipairs(NPC.GetUnitsInRadius(myHero, 99999, Enum.TeamType.TEAM_FRIEND)) do
      if Entity.IsAlive(npc) and not Entity.IsDormant(npc) and Entity.GetHealth(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) and Entity.IsNPC(npc) then
        if NPC.GetUnitName(npc) == "npc_dota_neutral_satyr_trickster" then
          Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
          AutoChen.TricksterMoveTime = GameRules.GetGameTime()
        end
      end
    end
  end

end

function AutoChen.UseUnitAbilitiesOnNPC()
  local myHero = Heroes.GetLocal()
  local myMana = NPC.GetMana(myHero)
  local enemy = Input.GetNearestUnitToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
  if not enemy or not Entity.IsAlive(enemy) or Entity.IsDormant(enemy) or Entity.GetHealth(enemy) <= 0 or not NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 900, 0) then
    if GameRules.GetGameTime() - AutoChen.MoveNPCOrderTime > 0.05 then
      for i = 1, NPCs.Count() do
        local npc = NPCs.Get(i)
        if Entity.GetHealth(npc) > 0 and Entity.IsSameTeam(myHero, npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) and NPC.GetUnitName(npc) ~= "npc_dota_courier" then
          Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
          -- Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS, nil)
        end
      AutoChen.MoveNPCOrderTime = GameRules.GetGameTime()
      end
      return
    end
  end
  if enemy and NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 900, 0) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ATTACK_IMMUNE) then
    if GameRules.GetGameTime() - AutoChen.AttackNPCOrderTime > 0.96  then
      for i = 1, NPCs.Count() do
        local npc = NPCs.Get(i)
        if Entity.GetHealth(npc) > 0 and Entity.IsSameTeam(myHero, npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) and NPC.GetUnitName(npc) ~= "npc_dota_courier" then
          Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, enemy, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
          -- Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, enemy, Vector(0, 0, 0), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS, nil)
        end
      AutoChen.AttackNPCOrderTime = GameRules.GetGameTime()
      end
      return
    end
  end
  if GameRules.GetGameTime() - AutoChen.UnitAbilityUseTime < AutoChen.Delay then return end
  for _, npc in ipairs(NPC.GetUnitsInRadius(myHero, 99999, Enum.TeamType.TEAM_FRIEND)) do
    if Entity.IsAlive(npc) and not Entity.IsDormant(npc) and Entity.GetHealth(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
      for _, ability in ipairs(AutoChen.InteractiveAbilities) do
        if ability ~= "dark_troll_warlord_raise_dead" and ability ~= "forest_troll_high_priest_heal" and ability ~= "enraged_wildkin_tornado" and ability ~= "ogre_magi_frost_armor" and ability ~= "big_thunder_lizard_frenzy" and ability ~= "dark_troll_warlord_ensnare" then
          if NPC.HasAbility(npc, ability) and Ability.IsCastable(NPC.GetAbility(npc, ability), NPC.GetMana(npc)) and Ability.IsReady(NPC.GetAbility(npc, ability)) and not Ability.IsInAbilityPhase(NPC.GetAbility(npc, ability)) and not NPC.IsLinkensProtected(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then
            if Ability.GetCastRange(NPC.GetAbility(npc, ability)) > 0 then
              if NPC.IsEntityInRange(npc, enemy, Ability.GetCastRange(NPC.GetAbility(npc, ability)) + NPC.GetCastRangeBonus(npc)) then
                if ability == "black_dragon_fireball" then
                  Ability.CastPosition(NPC.GetAbility(npc, ability), Entity.GetAbsOrigin(enemy))
                  AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                  return
                end
                if ability == "spawnlord_master_freeze" or ability == "dark_troll_warlord_ensnare" or ability == "mud_golem_hurl_boulder" then
                  if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                    return
                  end
                  if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration then
                    Ability.CastTarget(NPC.GetAbility(npc, ability), enemy)
                    AutoChen.StunTime = GameRules.GetGameTime()
                    if ability == "spawnlord_master_freeze" then
                      AutoChen.StunDuration = 2
                    end
                    if ability == "dark_troll_warlord_ensnare" then
                      AutoChen.StunDuration = 1.75
                    end
                    if ability == "mud_golem_hurl_boulder" then
                      AutoChen.StunDuration = 0.6
                    end
                    AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                    return
                  end
                end
                Ability.CastTarget(NPC.GetAbility(npc, ability), enemy)
                AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                return
              end
            end

            if Ability.GetCastRange(NPC.GetAbility(npc, ability)) == 0 then
              if ability == "big_thunder_lizard_slam" then
                if NPC.IsEntityInRange(npc, enemy, 250) then
                  Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                  AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                  return
                end
              end
              if ability == "centaur_khan_war_stomp" then
                if ((NPC.IsStunned(enemy) or NPC.HasModifier(enemy, "modifier_rooted") or NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED)) and GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration) or GameRules.GetGameTime() < AutoChen.StunTime + AutoChen.StunDuration then
                  return
                end
                if GameRules.GetGameTime() >= AutoChen.StunTime + AutoChen.StunDuration and NPC.IsPositionInRange(npc, AutoChen.GetPredictedPosition(enemy, 0.4), 250) and NPC.IsPositionInRange(npc, Entity.GetAbsOrigin(enemy), 250) then
                  Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                  AutoChen.StunTime = GameRules.GetGameTime()
                  AutoChen.StunDuration = 2
                  AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                  return
                end
              end
              if NPC.IsEntityInRange(npc, enemy, NPC.GetAttackRange(npc)) then
                if ability ~= "big_thunder_lizard_slam" then
                  Ability.CastNoTarget(NPC.GetAbility(npc, ability))
                  AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
                  return
                end
              end
            end
          end
        end
      end
    end
  end
end

function AutoChen.UseShockwaveTowardCursor()
  if GameRules.GetGameTime() - AutoChen.UnitAbilityUseTime < AutoChen.Delay then return end
  local myHero = Heroes.GetLocal()
  for _, npc in ipairs(NPC.GetUnitsInRadius(myHero, 99999, Enum.TeamType.TEAM_FRIEND)) do
    if Entity.IsAlive(npc) and not Entity.IsDormant(npc) and Entity.GetHealth(npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
      for _, ability in ipairs(AutoChen.InteractiveAbilities) do
        if ability == "satyr_hellcaller_shockwave" then
          if NPC.HasAbility(npc, ability) and Ability.IsCastable(NPC.GetAbility(npc, ability), NPC.GetMana(npc)) and Ability.IsReady(NPC.GetAbility(npc, ability)) and not Ability.IsInAbilityPhase(NPC.GetAbility(npc, ability)) then
            Ability.CastPosition(NPC.GetAbility(npc, ability), Entity.GetAbsOrigin(npc) + (Input.GetWorldCursorPos() - Entity.GetAbsOrigin(npc)):Normalized():Scaled(700))
            AutoChen.UnitAbilityUseTime = GameRules.GetGameTime()
          end
        end
      end
    end
  end
end

function AutoChen.UseHeroAbilities()
  if GameRules.GetGameTime() - AutoChen.HeroAbilityUseTime > AutoChen.Delay then
    local myHero = Heroes.GetLocal()
    local myMana = NPC.GetMana(myHero)
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local myInt = Hero.GetIntellectTotal(myHero)
    local mySpellAmp = 1 + (myInt * 0.07142857142) / 100
    local faith = NPC.GetAbility(myHero, "chen_test_of_faith")
    local penitence = NPC.GetAbility(myHero, "chen_penitence")
    local faith_max_damage
    local penitence_amp
    if faith then
      faith_max_damage = 100 * Ability.GetLevel(faith) * mySpellAmp
    end
    if penitence then
      penitence_amp = 1 + (12 + (Ability.GetLevel(penitence) * 6)) / 100
    end
    local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local hex = NPC.GetItem(myHero, "item_sheepstick", true)
    local blood = NPC.GetItem(myHero, "item_bloodthorn", true)
    local eBlade = NPC.GetItem(myHero, "item_ethereal_blade", true)
    local orchid = NPC.GetItem(myHero, "item_orchid", true)

    if Entity.IsAlive(myHero) and not Entity.IsDormant(myHero) and Entity.GetHealth(myHero) and AutoChen.IsSuitableToCastSpell(myHero) and AutoChen.CanCastSpellOn(enemy) and not AutoChen.IsDisabled(myHero) and enemy and Entity.IsAlive(enemy) and not Entity.IsDormant(enemy) and Entity.GetHealth(enemy) > 0 and NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), 900, 0) then
      if penitence and NPC.IsEntityInRange(myHero, enemy, Ability.GetCastRange(penitence)) and not Ability.IsChannelling(penitence) and Ability.IsReady(penitence) and not Ability.IsInAbilityPhase(penitence) and GameRules.GetGameTime() - AutoChen.HeroAbilityUseTime > AutoChen.Delay then
        Ability.CastTarget(penitence, enemy)
        AutoChen.HeroAbilityUseTime = GameRules.GetGameTime()
        return
      end
      if faith and NPC.IsEntityInRange(myHero, enemy, Ability.GetCastRange(faith)) and not Ability.IsChannelling(faith) and Ability.IsReady(faith) and not Ability.IsInAbilityPhase(faith) and GameRules.GetGameTime() - AutoChen.HeroAbilityUseTime > AutoChen.Delay then
        if veil and Ability.IsReady(veil) and Ability.IsCastable(veil, myMana) then
          return
        end
        if blood and Ability.IsReady(blood) and Ability.IsCastable(blood, myMana) then
          return
        end
        if orchid and Ability.IsReady(orchid) and Ability.IsCastable(orchid, myMana) then
          return
        end
        if eBlade and Ability.IsReady(eBlade) and Ability.IsCastable(eBlade, myMana) then
          return
        end
        if hex and Ability.IsReady(hex) and Ability.IsCastable(hex, myMana) then
          return
        end
        Ability.CastTarget(faith, enemy)
        AutoChen.HeroAbilityUseTime = GameRules.GetGameTime()
        return
      end
    end
  end
end

function AutoChen.AutoBuff()
  local myHero = Heroes.GetLocal()
  local myMana = NPC.GetMana(myHero)
  if GameRules.GetGameTime() - AutoChen.AutoBuffTime > 0.2 then
    for i = 1, NPCs.Count() do
      local npc = NPCs.Get(i)
      if Entity.GetHealth(npc) > 0 and Entity.IsSameTeam(myHero, npc) and (Entity.GetOwner(myHero) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, myHero)) then
        for key, ability_name in ipairs(AutoChen.BuffAbilities) do
          if NPC.HasAbility(npc, ability_name) then
            local theAbility = NPC.GetAbility(npc, ability_name)
            local npcMana = NPC.GetMana(npc)
            if Ability.IsReady(theAbility) and Ability.IsCastable(theAbility, npcMana) then 
              local range = Ability.GetCastRange(theAbility)
              -- buff heroes
              for i = 1, NPCs.Count() do
                local target = NPCs.Get(i)
                if Entity.GetHealth(target) > 0 and Entity.IsSameTeam(myHero, target) and not NPC.IsStructure(target) and not NPC.IsIllusion(target) and not NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and NPC.IsHero(target) and NPC.IsPositionInRange(npc, NPC.GetAbsOrigin(target), range) then
                  if ability_name == "ogre_magi_frost_armor" and not NPC.HasModifier(target, "modifier_ogre_magi_frost_armor") then
                    Ability.CastTarget(theAbility, target)
                  elseif ability_name == "big_thunder_lizard_frenzy" and not NPC.HasModifier(target, "modifier_big_thunder_lizard_frenzy") and NPC.IsAttacking(target) then
                    Ability.CastTarget(theAbility, target)
                  elseif ability_name == "forest_troll_high_priest_heal" and Entity.GetHealth(target) < Entity.GetMaxHealth(target) then
                    Ability.CastTarget(theAbility, target)
                  end
                end
              end
              -- buff neutrals
              for i = 1, NPCs.Count() do
                local target = NPCs.Get(i)
                if Entity.GetHealth(target) > 0 and Entity.IsSameTeam(myHero, target) and not NPC.IsStructure(target) and not NPC.IsIllusion(target) and not NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) and not NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) and NPC.IsNeutral(target) and NPC.IsPositionInRange(npc, NPC.GetAbsOrigin(target), range) then
                  if ability_name == "ogre_magi_frost_armor" and not NPC.HasModifier(target, "modifier_ogre_magi_frost_armor") then
                    Ability.CastTarget(theAbility, target)
                  elseif ability_name == "big_thunder_lizard_frenzy" and not NPC.HasModifier(target, "modifier_big_thunder_lizard_frenzy") and NPC.IsAttacking(target) then
                    Ability.CastTarget(theAbility, target)
                  elseif ability_name == "forest_troll_high_priest_heal" and Entity.GetHealth(target) < Entity.GetMaxHealth(target) then
                    Ability.CastTarget(theAbility, target)
                  end
                end
              end
            end
          end
        end
      end
    end
    AutoChen.AutoBuffTime = GameRules.GetGameTime()
  end
end

function AutoChen.AutoSave()
  if GameRules.GetGameTime() - AutoChen.HeroAbilityUseTime < AutoChen.Delay then return end
  local myHero = Heroes.GetLocal()
  local myMana = NPC.GetMana(myHero)
  local faith = NPC.GetAbility(myHero, "chen_test_of_faith")
  local hand = NPC.GetAbility(myHero, "chen_hand_of_god")
  local myInt = Hero.GetIntellectTotal(myHero)
  local mySpellAmp = 1 + (myInt * 0.07142857142) / 100
  local hand_heal_amount
  if faith then
    faith_max_damage = 100 * Ability.GetLevel(faith) * mySpellAmp
    faith_heal_amount = 50 * Ability.GetLevel(faith) * mySpellAmp
  end
  if hand then
    if NPC.GetAbility(myHero, "special_bonus_unique_chen_2") then
      hand_heal_amount = 325 + 100 * Ability.GetLevel(hand)
    else
      hand_heal_amount = 125 + 100 * Ability.GetLevel(hand)
    end
  end
  if Entity.GetHealth(myHero) <= Entity.GetMaxHealth(myHero) * 0.35 and Ability.IsReady(hand) and Ability.IsCastable(hand, myMana) and not NPC.IsIllusion(myHero) then
    Ability.CastNoTarget(hand)
    AutoChen.HeroAbilityUseTime = GameRules.GetGameTime()
    return
  end
  if Entity.GetHealth(myHero) <= Entity.GetMaxHealth(myHero) * 0.35 and Ability.IsReady(faith) and Ability.IsCastable(faith, myMana) and not NPC.IsIllusion(myHero) then
    Ability.CastTarget(faith, myHero)
    AutoChen.HeroAbilityUseTime = GameRules.GetGameTime()
    return
  end
  for _, v in ipairs(Wrap.HeroesInRadius(myHero, 900, Enum.TeamType.TEAM_FRIEND)) do
    if Entity.IsHero(npc) and not NPC.IsIllusion(npc) and Entity.GetHealth(npc) <= Entity.GetMaxHealth(npc) * 0.35 and Ability.IsReady(hand) and Ability.IsCastable(hand, myMana) then
      Ability.CastNoTarget(hand)
      AutoChen.HeroAbilityUseTime = GameRules.GetGameTime()
      return
    end
  end
end

function AutoChen.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- return best position to cast certain spells
-- eg. axe's call, void's chrono, enigma's black hole
-- input  : unitsAround, radius
-- return : positon (a vector)
function AutoChen.BestPosition(unitsAround, radius)
  if not unitsAround or #unitsAround <= 0 then return nil end
  local enemyNum = #unitsAround

  if enemyNum == 1 then return Entity.GetAbsOrigin(unitsAround[1]) end

  -- find all mid points of every two enemy heroes,
  -- then find out the best position among these.
  -- O(n^3) complexity
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

-- return predicted position
function AutoChen.GetPredictedPosition(npc, delay)
  local pos = Entity.GetAbsOrigin(npc)
  if AutoChen.CantMove(npc) then return pos end
  if not NPC.IsRunning(npc) or not delay then return pos end
  local dir = Entity.GetRotation(npc):GetForward():Normalized()
  local speed = AutoChen.GetMoveSpeed(npc)
  return pos + dir:Scaled(speed * delay)
end

function AutoChen.GetMoveSpeed(npc)
  local base_speed = NPC.GetBaseSpeed(npc)
  local bonus_speed = NPC.GetMoveSpeed(npc) - NPC.GetBaseSpeed(npc)
  -- when affected by ice wall, assume move speed as 100 for convenience
  if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return 100 end
  -- when get hexed,  move speed = 140/100 + bonus_speed
  if AutoChen.GetHexTimeLeft(npc) > 0 then return 140 + bonus_speed end
  return base_speed + bonus_speed
end

-- return true if is protected by lotus orb or AM's aghs
function AutoChen.IsLotusProtected(npc)
  if NPC.HasModifier(npc, "modifier_item_lotus_orb_active") then return true end
  local shield = NPC.GetAbility(npc, "antimage_spell_shield")
  if shield and Ability.IsReady(shield) and NPC.HasItem(npc, "item_ultimate_scepter", true) then
    return true
  end
  return false
end

-- return true if this npc is disabled, return false otherwise
function AutoChen.IsDisabled(npc)
  if not Entity.IsAlive(npc) then return true end
  if NPC.IsStunned(npc) then return true end
  if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end
  return false
end

-- return true if can cast spell on this npc, return false otherwise
function AutoChen.CanCastSpellOn(npc)
  if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
  if NPC.IsStructure(npc) then return false end --or not NPC.IsKillable(npc)
  if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return false end
  if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end
  if NPC.HasModifier(npc, "modifier_abaddon_borrowed_time") then return false end
  return true
end

-- check if it is safe to cast spell or item on enemy
-- in case enemy has blademail or lotus.
-- Caster will take double damage if target has both lotus and blademail
function AutoChen.IsSafeToCast(myHero, enemy, magic_damage)
  if not myHero or not enemy or not magic_damage then return true end
  if magic_damage <= 0 then return true end
  local counter = 0
  if NPC.HasModifier(enemy, "modifier_item_lotus_orb_active") then counter = counter + 1 end
  if NPC.HasModifier(enemy, "modifier_item_blade_mail_reflect") then counter = counter + 1 end
  local reflect_damage = counter * magic_damage * NPC.GetMagicalArmorDamageMultiplier(myHero)
  return Entity.GetHealth(myHero) > reflect_damage
end

-- situations that ally need to be saved
function AutoChen.NeedToBeSaved(npc)
  if not npc or NPC.IsIllusion(npc) or not Entity.IsAlive(npc) then return false end
  if NPC.IsStunned(npc) or NPC.IsSilenced(npc) then return true end
  if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_ROOTED) then return true end
  --if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_DISARMED) then return true end
  if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_HEXED) then return true end
  --if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_PASSIVES_DISABLED) then return true end
  --if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_BLIND) then return true end
  if Entity.GetHealth(npc) <= 0.2 * Entity.GetMaxHealth(npc) then return true end
  return false
end


function AutoChen.IsAncientCreep(npc)
  if not npc then return false end

  for i, name in ipairs(AutoChen.AncientCreepNameList) do
    if name and NPC.GetUnitName(npc) == name then return true end
  end

  return false
end

function AutoChen.CantMove(npc)
  if not npc then return false end

  if NPC.IsRooted(npc) or AutoChen.GetStunTimeLeft(npc) >= 1 then return true end
  if NPC.HasModifier(npc, "modifier_axe_berserkers_call") then return true end
  if NPC.HasModifier(npc, "modifier_legion_commander_duel") then return true end

  return false
end

-- only able to get stun modifier. no specific modifier for root or hex.
function AutoChen.GetStunTimeLeft(npc)
  local mod = NPC.GetModifier(npc, "modifier_stunned")
  if not mod then return 0 end
  return math.max(Modifier.GetDieTime(mod) - GameRules.GetGameTime(), 0)
end

-- hex only has three types: sheepstick, lion's hex, shadow shaman's hex
function AutoChen.GetHexTimeLeft(npc)
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

-- return false for conditions that are not suitable to cast spell (like TPing, being invisible)
-- return true otherwise
function AutoChen.IsSuitableToCastSpell(myHero)
  if NPC.IsSilenced(myHero) or NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
  --if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
  if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
  if NPC.IsChannellingAbility(myHero) then return false end
  return true
end

function AutoChen.IsSuitableToUseItem(myHero)
  if NPC.IsStunned(myHero) or not Entity.IsAlive(myHero) then return false end
  if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then return false end
  if NPC.HasModifier(myHero, "modifier_teleporting") then return false end
  if NPC.IsChannellingAbility(myHero) then return false end
  return true
end

-- return true if: (1) channeling ability; (2) TPing
function AutoChen.IsChannellingAbility(npc, target)
  if NPC.HasModifier(npc, "modifier_teleporting") then return true end
  if NPC.IsChannellingAbility(npc) then return true end

  return false
end

function AutoChen.IsAffectedByDoT(npc)
  if not npc then return false end

  if NPC.HasModifier(npc, "modifier_item_radiance_debuff") then return true end
  if NPC.HasModifier(npc, "modifier_item_urn_damage") then return true end
  if NPC.HasModifier(npc, "modifier_alchemist_acid_spray") then return true end
  if NPC.HasModifier(npc, "modifier_cold_feet") then return true end
  if NPC.HasModifier(npc, "modifier_ice_blast") then return true end
  if NPC.HasModifier(npc, "modifier_axe_battle_hunger") then return true end
  if NPC.HasModifier(npc, "modifier_bane_fiends_grip") then return true end
  if NPC.HasModifier(npc, "modifier_batrider_firefly") then return true end
  if NPC.HasModifier(npc, "modifier_rattletrap_battery_assault") then return true end
  if NPC.HasModifier(npc, "modifier_crystal_maiden_frostbite") then return true end
  if NPC.HasModifier(npc, "modifier_crystal_maiden_freezing_field") then return true end
  if NPC.HasModifier(npc, "modifier_dazzle_poison_touch") then return true end
  if NPC.HasModifier(npc, "modifier_disruptor_static_storm") then return true end
  if NPC.HasModifier(npc, "modifier_disruptor_thunder_strike") then return true end
  if NPC.HasModifier(npc, "modifier_doom_bringer_doom") then return true end
  if NPC.HasModifier(npc, "modifier_doom_bringer_scorched_earth_effect") then return true end
  if NPC.HasModifier(npc, "modifier_dragon_knight_corrosive_breath_dot") then return true end
  if NPC.HasModifier(npc, "modifier_earth_spirit_magnetize") then return true end
  if NPC.HasModifier(npc, "modifier_ember_spirit_flame_guard") then return true end
  if NPC.HasModifier(npc, "modifier_enigma_malefice") then return true end
  if NPC.HasModifier(npc, "modifier_brewmaster_fire_permanent_immolation") then return true end
  if NPC.HasModifier(npc, "modifier_gyrocopter_rocket_barrage") then return true end
  if NPC.HasModifier(npc, "modifier_huskar_burning_spear_debuff") then return true end
  if NPC.HasModifier(npc, "modifier_invoker_ice_wall_slow_debuff") then return true end
  if NPC.HasModifier(npc, "modifier_invoker_chaos_meteor_burn") then return true end
  if NPC.HasModifier(npc, "modifier_jakiro_dual_breath_burn") then return true end
  if NPC.HasModifier(npc, "modifier_jakiro_macropyre") then return true end
  if NPC.HasModifier(npc, "modifier_juggernaut_blade_fury") then return true end
  if NPC.HasModifier(npc, "modifier_leshrac_diabolic_edict") then return true end
  if NPC.HasModifier(npc, "modifier_leshrac_pulse_nova") then return true end
  if NPC.HasModifier(npc, "modifier_ogre_magi_ignite") then return true end
  if NPC.HasModifier(npc, "modifier_phoenix_fire_spirit_burn") then return true end
  if NPC.HasModifier(npc, "modifier_phoenix_icarus_dive_burn") then return true end
  if NPC.HasModifier(npc, "modifier_phoenix_sun_debuff") then return true end
  if NPC.HasModifier(npc, "modifier_pudge_rot") then return true end
  if NPC.HasModifier(npc, "modifier_pugna_life_drain") then return true end
  if NPC.HasModifier(npc, "modifier_queenofpain_shadow_strike") then return true end
  if NPC.HasModifier(npc, "modifier_razor_eye_of_the_storm") then return true end
  if NPC.HasModifier(npc, "modifier_sandking_sand_storm") then return true end
  if NPC.HasModifier(npc, "modifier_silencer_curse_of_the_silent") then return true end
  if NPC.HasModifier(npc, "modifier_sniper_shrapnel_slow") then return true end
  if NPC.HasModifier(npc, "modifier_shredder_chakram_debuff") then return true end
  if NPC.HasModifier(npc, "modifier_treant_leech_seed") then return true end
  if NPC.HasModifier(npc, "modifier_abyssal_underlord_firestorm_burn") then return true end
  if NPC.HasModifier(npc, "modifier_venomancer_venomous_gale") then return true end
  if NPC.HasModifier(npc, "modifier_venomancer_poison_nova") then return true end
  if NPC.HasModifier(npc, "modifier_viper_viper_strike") then return true end
  if NPC.HasModifier(npc, "modifier_warlock_shadow_word") then return true end
  if NPC.HasModifier(npc, "modifier_warlock_golem_permanent_immolation_debuff") then return true end
  if NPC.HasModifier(npc, "modifier_maledict") then return true end

  return false
end

AutoChen.AncientCreepNameList = {
  "npc_dota_neutral_black_drake",
  "npc_dota_neutral_black_dragon",
  "npc_dota_neutral_blue_dragonspawn_sorcerer",
  "npc_dota_neutral_blue_dragonspawn_overseer",
  "npc_dota_neutral_granite_golem",
  "npc_dota_neutral_elder_jungle_stalker",
  "npc_dota_neutral_prowler_acolyte",
  "npc_dota_neutral_prowler_shaman",
  "npc_dota_neutral_rock_golem",
  "npc_dota_neutral_small_thunder_lizard",
  "npc_dota_neutral_jungle_stalker",
  "npc_dota_neutral_big_thunder_lizard",
  "npc_dota_roshan"
}

AutoChen.BuffAbilities = {
  "forest_troll_high_priest_heal",
  "big_thunder_lizard_frenzy",
  "ogre_magi_frost_armor"
}

AutoChen.CreepNameList = {
  "npc_dota_neutral_alpha_wolf",
  "npc_dota_neutral_big_thunder_lizard",
  "npc_dota_neutral_black_dragon",
  "npc_dota_neutral_black_drake",
  "npc_dota_neutral_blue_dragonspawn_overseer",
  "npc_dota_neutral_blue_dragonspawn_sorcerer",
  "npc_dota_neutral_centaur_khan",
  "npc_dota_neutral_centaur_outrunner",
  "npc_dota_neutral_dark_troll",
  "npc_dota_neutral_dark_troll_warlord",
  "npc_dota_neutral_elder_jungle_stalker",
  "npc_dota_neutral_enraged_wildkin",
  "npc_dota_neutral_fel_beast",
  "npc_dota_neutral_forest_troll_berserker",
  "npc_dota_neutral_forest_troll_high_priest",
  "npc_dota_neutral_ghost",
  "npc_dota_neutral_giant_wolf",
  "npc_dota_neutral_gnoll_assassin",
  "npc_dota_neutral_granite_golem",
  "npc_dota_neutral_harpy_scout",
  "npc_dota_neutral_harpy_storm",
  "npc_dota_neutral_jungle_stalker",
  "npc_dota_neutral_kobold",
  "npc_dota_neutral_kobold_taskmaster",
  "npc_dota_neutral_kobold_tunneler",
  "npc_dota_neutral_mud_golem",
  "npc_dota_neutral_ogre_magi",
  "npc_dota_neutral_ogre_mauler",
  "npc_dota_neutral_polar_furbolg_champion",
  "npc_dota_neutral_polar_furbolg_ursa_warrior",
  "npc_dota_neutral_rock_golem",
  "npc_dota_neutral_satyr_hellcaller",
  "npc_dota_neutral_satyr_soulstealer",
  "npc_dota_neutral_satyr_trickster",
  "npc_dota_neutral_small_thunder_lizard",
  "npc_dota_neutral_wildkin",
  "npc_dota_neutral_prowler_shaman",
  "npc_dota_neutral_prowler_acolyte"
}

AutoChen.UsefulCreepNameList = {
  "npc_dota_neutral_satyr_hellcaller",
  "npc_dota_neutral_dark_troll_warlord",
  "npc_dota_neutral_centaur_khan",
  "npc_dota_neutral_enraged_wildkin",
  "npc_dota_neutral_alpha_wolf",
  "npc_dota_neutral_ogre_magi",
  "npc_dota_neutral_polar_furbolg_ursa_warrior",
  "npc_dota_neutral_harpy_storm",
  "npc_dota_neutral_mud_golem",
  "npc_dota_neutral_ghost",
  "npc_dota_neutral_forest_troll_high_priest",
  "npc_dota_neutral_kobold_taskmaster",
  "npc_dota_invoker_forged_spirit",
  "npc_dota_beastmaster_boar_4",
  "npc_dota_beastmaster_boar_3",
  "npc_dota_beastmaster_boar_2",
  "npc_dota_beastmaster_boar",
  "npc_dota_beastmaster_boar_1",
  "npc_dota_necronomicon_archer_3",
  "npc_dota_necronomicon_warrior_3",
  "npc_dota_necronomicon_warrior_2",
  "npc_dota_necronomicon_archer_2",
  "npc_dota_necronomicon_warrior_1",
  "npc_dota_necronomicon_archer_1",
  "npc_dota_lycan_wolf4",
  "npc_dota_lycan_wolf3",
  "npc_dota_beastmaster_hawk_4",
  "npc_dota_beastmaster_hawk_3",
  "npc_dota_beastmaster_hawk_2",
  "npc_dota_beastmaster_hawk_1",
  "npc_dota_beastmaster_hawk"
}

AutoChen.AghsUsefulCreepNameList = {
  "npc_dota_neutral_granite_golem",
  "npc_dota_neutral_black_dragon",
  "npc_dota_neutral_big_thunder_lizard",
  "npc_dota_neutral_satyr_hellcaller",
  "npc_dota_neutral_dark_troll_warlord",
  "npc_dota_neutral_centaur_khan",
  "npc_dota_neutral_enraged_wildkin",
  "npc_dota_neutral_alpha_wolf",
  "npc_dota_neutral_ogre_magi",
  "npc_dota_neutral_polar_furbolg_ursa_warrior",
  "npc_dota_neutral_prowler_acolyte",
  "npc_dota_neutral_prowler_shaman",
  "npc_dota_neutral_harpy_storm",
  "npc_dota_neutral_mud_golem",
  "npc_dota_neutral_ghost",
  "npc_dota_neutral_forest_troll_high_priest",
  "npc_dota_neutral_kobold_taskmaster",
  "npc_dota_invoker_forged_spirit",
  "npc_dota_beastmaster_boar_4",
  "npc_dota_beastmaster_boar_3",
  "npc_dota_beastmaster_boar_2",
  "npc_dota_beastmaster_boar",
  "npc_dota_beastmaster_boar_1",
  "npc_dota_necronomicon_archer_3",
  "npc_dota_necronomicon_warrior_3",
  "npc_dota_necronomicon_warrior_2",
  "npc_dota_necronomicon_archer_2",
  "npc_dota_necronomicon_warrior_1",
  "npc_dota_necronomicon_archer_1",
  "npc_dota_lycan_wolf4",
  "npc_dota_lycan_wolf3",
  "npc_dota_beastmaster_hawk_4",
  "npc_dota_beastmaster_hawk_3",
  "npc_dota_beastmaster_hawk_2",
  "npc_dota_beastmaster_hawk_1",
  "npc_dota_beastmaster_hawk"
}

AutoChen.InteractiveAbilities = {
  "forest_troll_high_priest_heal",
  "harpy_storm_chain_lightning",
  "centaur_khan_war_stomp",
  "satyr_trickster_purge",
  "satyr_soulstealer_mana_burn",
  "ogre_magi_frost_armor",
  "mud_golem_hurl_boulder",
  "satyr_hellcaller_shockwave",
  "polar_furbolg_ursa_warrior_thunder_clap",
  "enraged_wildkin_tornado",
  "dark_troll_warlord_ensnare",
  "dark_troll_warlord_raise_dead",
  "black_dragon_fireball",
  "big_thunder_lizard_slam",
  "big_thunder_lizard_frenzy",
  "spawnlord_master_stomp",
  "spawnlord_master_freeze",
  "necronomicon_archer_purge"
}

AutoChen.HeroAbilities = {
  "chen_penitence",
  "chen_test_of_faith",
  "chen_test_of_faith_teleport",
  "chen_holy_persuasion",
  "chen_hand_of_god",
  "special_bonus_movement_speed_30",
  "special_bonus_cast_range_125",
  "special_bonus_hp_250",
  "special_bonus_unique_chen_3",
  "special_bonus_gold_income_15",
  "special_bonus_unique_chen_4",
  "special_bonus_unique_chen_1",
  "special_bonus_unique_chen_2"
}

AutoChen.RangeAbilityItems = {
  "item_sheepstick",
  "item_orchid",
  "item_bloodthorn",
  "item_rod_of_atos",
  "item_veil_of_discord",
  "item_ethereal_blade",
  "item_dagon",
  "item_dagon_2",
  "item_dagon_3",
  "item_dagon_4",
  "item_dagon_5",
  "chen_penitence",
  "chen_test_of_faith"
}

AutoChen.Items = {
  "item_abyssal_blade",
  "item_aegis",
  "item_aether_lens",
  "item_ancient_janggo",
  "item_arcane_boots",
  "item_armlet",
  "item_assault",
  "item_banana",
  "item_basher",
  "item_belt_of_strength",
  "item_bfury",
  "item_black_king_bar",
  "item_blade_mail",
  "item_blade_of_alacrity",
  "item_blades_of_attack",
  "item_blight_stone",
  "item_bloodstone",
  "item_bloodthorn",
  "item_boots",
  "item_boots_of_elves",
  "item_bottle",
  "item_bracer",
  "item_branches",
  "item_broadsword",
  "item_buckler",
  "item_butterfly",
  "item_chainmail",
  "item_cheese",
  "item_circlet",
  "item_clarity",
  "item_claymore",
  "item_cloak",
  "item_courier",
  "item_crimson_guard",
  "item_cyclone",
  "item_dagon",
  "item_dagon_2",
  "item_dagon_3",
  "item_dagon_4",
  "item_dagon_5",
  "item_demon_edge",
  "item_desolator",
  "item_diffusal_blade",
  "item_diffusal_blade_2",
  "item_dragon_lance",
  "item_dust",
  "item_eagle",
  "item_echo_sabre",
  "item_enchanted_mango",
  "item_energy_booster",
  "item_ethereal_blade",
  "item_faerie_fire",
  "item_flask",
  "item_flying_courier",
  "item_force_staff",
  "item_gauntlets",
  "item_gem",
  "item_ghost",
  "item_glimmer_cape",
  "item_gloves",
  "item_greater_crit",
  "item_greevil_whistle",
  "item_greevil_whistle_toggle",
  "item_guardian_greaves",
  "item_halloween_candy_corn",
  "item_halloween_rapier",
  "item_hand_of_midas",
  "item_headdress",
  "item_heart",
  "item_heavens_halberd",
  "item_helm_of_iron_will",
  "item_helm_of_the_dominator",
  "item_hood_of_defiance",
  "item_hurricane_pike",
  "item_hyperstone",
  "item_infused_raindrop",
  "item_invis_sword",
  "item_iron_talon",
  "item_javelin",
  "item_lesser_crit",
  "item_lifesteal",
  "item_lotus_orb",
  "item_maelstrom",
  "item_magic_stick",
  "item_magic_wand",
  "item_manta",
  "item_mantle",
  "item_mask_of_madness",
  "item_medallion_of_courage",
  "item_mekansm",
  "item_mithril_hammer",
  "item_mjollnir",
  "item_monkey_king_bar",
  "item_moon_shard",
  "item_mystery_arrow",
  "item_mystery_hook",
  "item_mystery_missile",
  "item_mystery_toss",
  "item_mystery_vacuum",
  "item_mystic_staff",
  "item_necronomicon",
  "item_necronomicon_2",
  "item_necronomicon_3",
  "item_null_talisman",
  "item_oblivion_staff",
  "item_octarine_core",
  "item_ogre_axe",
  "item_orb_of_venom",
  "item_orchid",
  "item_pers",
  "item_phase_boots",
  "item_pipe",
  "item_platemail",
  "item_point_booster",
  "item_poor_mans_shield",
  "item_power_treads",
  "item_present",
  "item_quarterstaff",
  "item_quelling_blade",
  "item_radiance",
  "item_rapier",
  "item_reaver",
  "item_recipe_abyssal_blade",
  "item_recipe_aether_lens",
  "item_recipe_ancient_janggo",
  "item_recipe_arcane_boots",
  "item_recipe_armlet",
  "item_recipe_assault",
  "item_recipe_basher",
  "item_recipe_bfury",
  "item_recipe_black_king_bar",
  "item_recipe_blade_mail",
  "item_recipe_bloodstone",
  "item_recipe_bloodthorn",
  "item_recipe_bracer",
  "item_recipe_buckler",
  "item_recipe_butterfly",
  "item_recipe_crimson_guard",
  "item_recipe_cyclone",
  "item_recipe_dagon",
  "item_recipe_dagon_2",
  "item_recipe_dagon_3",
  "item_recipe_dagon_4",
  "item_recipe_dagon_5",
  "item_recipe_desolator",
  "item_recipe_diffusal_blade",
  "item_recipe_diffusal_blade_2",
  "item_recipe_dragon_lance",
  "item_recipe_echo_sabre",
  "item_recipe_ethereal_blade",
  "item_recipe_force_staff",
  "item_recipe_glimmer_cape",
  "item_recipe_greater_crit",
  "item_recipe_guardian_greaves",
  "item_recipe_hand_of_midas",
  "item_recipe_headdress",
  "item_recipe_heart",
  "item_recipe_heavens_halberd",
  "item_recipe_helm_of_the_dominator",
  "item_recipe_hood_of_defiance",
  "item_recipe_hurricane_pike",
  "item_recipe_invis_sword",
  "item_recipe_iron_talon",
  "item_recipe_lesser_crit",
  "item_recipe_lotus_orb",
  "item_recipe_maelstrom",
  "item_recipe_magic_wand",
  "item_recipe_manta",
  "item_recipe_mask_of_madness",
  "item_recipe_medallion_of_courage",
  "item_recipe_mekansm",
  "item_recipe_mjollnir",
  "item_recipe_monkey_king_bar",
  "item_recipe_moon_shard",
  "item_recipe_necronomicon",
  "item_recipe_necronomicon_2",
  "item_recipe_necronomicon_3",
  "item_recipe_null_talisman",
  "item_recipe_oblivion_staff",
  "item_recipe_octarine_core",
  "item_recipe_orchid",
  "item_recipe_pers",
  "item_recipe_phase_boots",
  "item_recipe_pipe",
  "item_recipe_poor_mans_shield",
  "item_recipe_power_treads",
  "item_recipe_radiance",
  "item_recipe_rapier",
  "item_recipe_refresher",
  "item_recipe_ring_of_aquila",
  "item_recipe_ring_of_basilius",
  "item_recipe_rod_of_atos",
  "item_recipe_sange",
  "item_recipe_sange_and_yasha",
  "item_recipe_satanic",
  "item_recipe_sheepstick",
  "item_recipe_shivas_guard",
  "item_recipe_silver_edge",
  "item_recipe_skadi",
  "item_recipe_solar_crest",
  "item_recipe_soul_booster",
  "item_recipe_soul_ring",
  "item_recipe_sphere",
  "item_recipe_tranquil_boots",
  "item_recipe_travel_boots",
  "item_recipe_travel_boots_2",
  "item_recipe_ultimate_scepter",
  "item_recipe_urn_of_shadows",
  "item_recipe_vanguard",
  "item_recipe_veil_of_discord",
  "item_recipe_vladmir",
  "item_recipe_ward_dispenser",
  "item_recipe_wraith_band",
  "item_recipe_yasha",
  "item_refresher",
  "item_relic",
  "item_ring_of_aquila",
  "item_ring_of_basilius",
  "item_ring_of_health",
  "item_ring_of_protection",
  "item_ring_of_regen",
  "item_river_painter",
  "item_river_painter2",
  "item_river_painter3",
  "item_river_painter4",
  "item_river_painter5",
  "item_river_painter6",
  "item_river_painter7",
  "item_robe",
  "item_rod_of_atos",
  "item_sange",
  "item_sange_and_yasha",
  "item_satanic",
  "item_shadow_amulet",
  "item_sheepstick",
  "item_shivas_guard",
  "item_silver_edge",
  "item_skadi",
  "item_slippers",
  "item_smoke_of_deceit",
  "item_sobi_mask",
  "item_solar_crest",
  "item_soul_booster",
  "item_soul_ring",
  "item_sphere",
  "item_staff_of_wizardry",
  "item_stout_shield",
  "item_talisman_of_evasion",
  "item_tango",
  "item_tango_single",
  "item_tome_of_knowledge",
  "item_tpscroll",
  "item_tranquil_boots",
  "item_travel_boots",
  "item_travel_boots_2",
  "item_ultimate_orb",
  "item_ultimate_scepter",
  "item_urn_of_shadows",
  "item_vanguard",
  "item_veil_of_discord",
  "item_vitality_booster",
  "item_vladmir",
  "item_void_stone",
  "item_ward_dispenser",
  "item_ward_observer",
  "item_ward_sentry",
  "item_wind_lace",
  "item_winter_cake",
  "item_winter_coco",
  "item_winter_cookie",
  "item_winter_greevil_chewy",
  "item_winter_greevil_garbage",
  "item_winter_greevil_treat",
  "item_winter_ham",
  "item_winter_kringle",
  "item_winter_mushroom",
  "item_winter_skates",
  "item_winter_stocking",
  "item_wraith_band",
  "item_yasha"
}

AutoChen.InteractiveItems = {
  "item_sheepstick",
  "item_orchid",
  "item_bloodthorn",
  "item_rod_of_atos",
  "item_veil_of_discord",
  "item_heavens_halberd",
  "item_abyssal_blade",
  "item_diffusal_blade",
  "item_diffusal_blade_2",
  "item_ethereal_blade",
  "item_medallion_of_courage",
  "item_shivas_guard",
  "item_solar_crest",
  "item_hurricane_pike",
  "item_satanic",
  "item_ancient_janggo",
  "item_dagon",
  "item_dagon_2",
  "item_dagon_3",
  "item_dagon_4",
  "item_dagon_5",
  "item_black_king_bar",
  "item_pipe",
  "item_blade_mail",
  "item_buckler",
  "item_hood_of_defiance",
  "item_lotus_orb",
  "item_manta",
  "item_mask_of_madness",
  "item_mjollnir",
  "item_necronomicon",
  "item_necronomicon_2",
  "item_necronomicon_3",
  "item_urn_of_shadows",
}

AutoChen.InteractiveAutoItems = {
  "item_magic_stick",
  "item_magic_wand",
  "item_mekansm",
  "item_guardian_greaves",
  "item_arcane_boots"
}

return AutoChen
