local events = {
    {
        name = "EVENT_BUCKED_OFF",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "rider" },
            { type = "int", name = "mount" },
            { type = "int", name = "value_2" }
        }
    },
    {
        name = "EVENT_CALCULATE_LOOT",
        group = 0,
        size = 26,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "inventory_item" },
            { type = "int", name = "consumable_action" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "value_25" },
        }
    },
    {
        name = "EVENT_CALM_PED",
        group = 0,
        size = 4,
        data = {
            { type = "int",  name = "initiator_entity" },
            { type = "int",  name = "target_entity" },
            { type = "int",  name = "calm_type" },
            { type = "bool", name = "is_fully_calmed" },
        }
    },
    {
        name = "EVENT_CARRIABLE_UPDATE_CARRY_STATE",
        group = 0,
        size = 5,
        data = {
            { type = "int",  name = "target_entity" },
            { type = "int",  name = "perpitrator_entity" },
            { type = "int",  name = "carrier_entity" },
            { type = "bool", name = "is_on_horse" },
            { type = "bool", name = "is_on_ground" },
        }
    },
    {
        name = "EVENT_CARRIABLE_PROMPT_INFO_REQUEST",
        group = 0,
        size = 6,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "carriable_action" },
            { type = "int", name = "value_2" },
            { type = "int", name = "vehicle_entity" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
        }
    },
    {
        name = "EVENT_CARRIABLE_VEHICLE_STOW_START",
        group = 0,
        size = 5,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "vehicle_entity" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
        }
    },
    {
        name = "EVENT_CARRIABLE_VEHICLE_STOW_COMPLETE",
        group = 0,
        size = 3,
        data = {
            { type = "int",  name = "value_0" },
            { type = "int",  name = "vehicle_entity" },
            { type = "bool", name = "is_item_to_add_cancelled" },
        }
    },
    {
        name = "EVENT_CHALLENGE_GOAL_COMPLETE",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "challenge_goal" },
        }
    },
    {
        name = "EVENT_CHALLENGE_GOAL_UPDATE",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "challenge_goal" },
        }
    },
    {
        name = "EVENT_CHALLENGE_REWARD",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "challenge_reward" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
        }
    },
    {
        name = "EVENT_CONTAINER_INTERACTION",
        group = 0,
        size = 4,
        data = {
            { type = "int",  name = "initiator_entity" },
            { type = "int",  name = "target_entity" },
            { type = "int",  name = "value_2" },
            { type = "bool", name = "is_container_closed_after_interaction" },
        }
    },
    {
        name = "EVENT_CRIME_CONFIRMED",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "crime_type" },
            { type = "int", name = "criminal_entity" },
            { type = "int", name = "witness_entity" },
        }
    },
    {
        name = "EVENT_DAILY_CHALLENGE_STREAK_COMPLETED",
        group = 0,
        size = 1,
        data = {
            { type = "bool", name = "is_daily_challenge_streak_completed" },
        }
    },
    {
        name = "EVENT_ENTITY_BROKEN",
        group = 0,
        size = 9,
        data = {
            { type = "int",   name = "target_entity" },
            { type = "int",   name = "value_1" },
            { type = "int",   name = "value_2" },
            { type = "int",   name = "value_3" },
            { type = "int",   name = "value_4" },
            { type = "int",   name = "value_5" },
            { type = "float", name = "coord_x" },
            { type = "float", name = "coord_y" },
            { type = "float", name = "coord_z" },
        }
    },
    {
        name = "EVENT_ENTITY_DAMAGED",
        group = 0,
        size = 9,
        data = {
            { type = "int",   name = "target_entity" },
            { type = "int",   name = "initiator_entity" },
            { type = "int",   name = "weapon" },
            { type = "int",   name = "ammo" },
            { type = "float", name = "damage_amount" },
            { type = "int",   name = "value_5" },
            { type = "float", name = "coord_x" },
            { type = "float", name = "coord_y" },
            { type = "float", name = "coord_z" },
        }
    },
    {
        name = "EVENT_ENTITY_DESTROYED",
        group = 0,
        size = 9,
        data = {
            { type = "int",   name = "target_entity" },
            { type = "int",   name = "initiator_entity" },
            { type = "int",   name = "weapon" },
            { type = "int",   name = "ammo" },
            { type = "float", name = "damage_amount" },
            { type = "int",   name = "value_5" },
            { type = "float", name = "coord_x" },
            { type = "float", name = "coord_y" },
            { type = "float", name = "coord_z" },
        }
    },
    {
        name = "EVENT_ENTITY_DISARMED",
        group = 0,
        size = 4,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "weapon" },
            { type = "int", name = "value_3" },
        }
    },
    {
        name = "EVENT_ENTITY_EXPLOSION",
        group = 0,
        size = 6,
        data = {
            { type = "int",   name = "initiator_entity" },
            { type = "int",   name = "value_1" },
            { type = "int",   name = "weapon" },
            { type = "float", name = "coord_x" },
            { type = "float", name = "coord_y" },
            { type = "float", name = "coord_z" },
        }
    },
    {
        name = "EVENT_ENTITY_HOGTIED",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "value_2" },
        }
    },
    {
        name = "EVENT_HEADSHOT_BLOCKED_BY_HAT",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
        }
    },
    {
        name = "EVENT_HELP_TEXT_REQUEST",
        group = 0,
        size = 4,
        data = {
            { type = "int", name = "entity" },
            { type = "int", name = "help_text" },
            { type = "int", name = "value_2" },
            { type = "int", name = "inventory_item" },
        }
    },
    {
        name = "EVENT_HITCH_ANIMAL",
        group = 0,
        size = 4,
        data = {
            { type = "int",  name = "initiator_entity" },
            { type = "int",  name = "target_entity" },
            { type = "bool", name = "is_animal_hitched" },
            { type = "int",  name = "hitching_type" },
        }
    },
    {
        name = "EVENT_HOGTIED_ENTITY_PICKED_UP",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
        }
    },
    {
        name = "EVENT_HORSE_BROKEN",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "event_type" },
        }
    },
    {
        name = "EVENT_IMPENDING_SAMPLE_PROMPT",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "inventory_item" }
        }
    },
    {
        name = "EVENT_INVENTORY_ITEM_PICKED_UP",
        group = 0,
        size = 5,
        data = {
            { type = "int",  name = "inventory_item" },
            { type = "int",  name = "entity_model" },
            { type = "bool", name = "is_item_was_used" },
            { type = "bool", name = "is_item_was_bought" },
            { type = "int",  name = "target_entity" }
        }
    },
    {
        name = "EVENT_INVENTORY_ITEM_REMOVED",
        group = 0,
        size = 1,
        data = {
            { type = "int", value = "inventory_item" }
        }
    },
    {
        name = "EVENT_ITEM_PROMPT_INFO_REQUEST",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "prompt_info" },
            { type = "int", name = "inventory_item" }
        }
    },
    {
        name = "EVENT_LOOT",
        group = 0,
        size = 36,
        data = {
            { type = "int", name = "num_given_rewards" },
            { type = "int", name = "reward" },
            { type = "int", name = "inventory_item" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "num" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "weapon" },
            { type = "int", name = "value_23" },
            { type = "int", name = "value_24" },
            { type = "int", name = "value_25" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "looted_entity_model" },
            { type = "int", name = "looted_composite" },
            { type = "int", name = "value_30" },
            { type = "int", name = "value_31" },
            { type = "int", name = "value_32" },
            { type = "int", name = "value_33" },
            { type = "int", name = "value_34" },
            { type = "int", name = "value_35" }
        }
    },
    {
        name = "EVENT_LOOT_COMPLETE",
        group = 0,
        size = 3,
        data = {
            { type = "int",  name = "initiator_entity" },
            { type = "int",  name = "target_entity" },
            { type = "bool", name = "is_loot_success" }
        }
    },
    {
        name = "EVENT_LOOT_PLANT_START",
        group = 0,
        size = 36,
        data = {
            { type = "int", name = "num_given_rewards" },
            { type = "int", name = "reward" },
            { type = "int", name = "inventory_item" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "num" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "weapon" },
            { type = "int", name = "value_23" },
            { type = "int", name = "value_24" },
            { type = "int", name = "value_25" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "looted_entity_model" },
            { type = "int", name = "looted_composite" },
            { type = "int", name = "value_30" },
            { type = "int", name = "value_31" },
            { type = "int", name = "value_32" },
            { type = "int", name = "value_33" },
            { type = "int", name = "value_34" },
            { type = "int", name = "value_35" }
        }
    },
    {
        name = "EVENT_LOOT_VALIDATION_FAIL",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "fail_reason" },
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_MISS_INTENDED_TARGET",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "weapon" }
        }
    },
    {
        name = "EVENT_MOUNT_OVERSPURRED",
        group = 0,
        size = 6,
        data = {
            { type = "int",   name = "initiator_entity" },
            { type = "int",   name = "target_entity" },
            { type = "float", name = "horse_rage_amount" },
            { type = "int",   name = "num_overspurred" },
            { type = "int",   name = "max_num_overspurred" },
            { type = "int",   name = "value_5" }
        }
    },
    {
        name = "EVENT_NETWORK_AWARD_CLAIMED",
        group = 1,
        size = 12,
        data = {
            { type = "int", name = "request" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "result_code" },
            { type = "int", name = "award" },
            { type = "int", name = "awarded_xp_amount" },
            { type = "int", name = "awarded_rank_amount" },
            { type = "int", name = "awarded_cash_amount" },
            { type = "int", name = "awarded_gold_amount" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" }
        }
    },
    {
        name = "EVENT_NETWORK_BOUNTY_REQUEST_COMPLETE",
        group = 1,
        size = 7,
        data = {
            { type = "int", name = "request" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "result_code" },
            { type = "int", name = "total_value" },
            { type = "int", name = "pay_off_value" }
        }
    },
    {
        name = "EVENT_NETWORK_BULLET_IMPACTED_MULTIPLE_PEDS",
        group = 1,
        size = 4,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "num_impacted" },
            { type = "int", name = "num_killed" },
            { type = "int", name = "num_incapacitated" }
        }
    },
    {
        name = "EVENT_NETWORK_CASHINVENTORY_TRANSACTION",
        group = 1,
        size = 6,
        data = {
            { type = "int", name = "transaction" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "result_code" },
            { type = "int", name = "items_amount" },
            { type = "int", name = "action" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_CREATION",
        group = 1,
        size = 10,
        data = {
            { type = "bool", name = "is_creation_successful" },
            { type = "int",  name = "crew" },
            { type = "int",  name = "value_2" },
            { type = "int",  name = "value_3" },
            { type = "int",  name = "value_4" },
            { type = "int",  name = "value_5" },
            { type = "int",  name = "value_6" },
            { type = "int",  name = "value_7" },
            { type = "int",  name = "value_8" },
            { type = "int",  name = "value_9" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_DISBANDED",
        group = 1,
        size = 2,
        data = {
            { type = "bool", name = "is_disbanding_successful" },
            { type = "int",  name = "value_1" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_INVITE_RECEIVED",
        group = 1,
        size = 11,
        data = {
            { type = "int", name = "crew" },
            { type = "int", name = "inviter" },
            { type = "int", name = "inviter_name" },
            { type = "int", name = "inviter_rank" },
            { type = "int", name = "inviter_rank_icon" },
            { type = "int", name = "inviter_rank_icon_color" },
            { type = "int", name = "inviter_rank_icon_bg_color" },
            { type = "int", name = "inviter_rank_icon_border_color" },
            { type = "int", name = "inviter_rank_icon_border_color" },
            { type = "int", name = "inviter_rank_icon_border_color" },
            { type = "int", name = "has_message" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_JOINED",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "joined_crew" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_KICKED",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "kicked_crew" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_LEFT",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "left_crew" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_NETWORK_CREW_RANK_CHANGE",
        group = 1,
        size = 7,
        data = {
            { type = "int", name = "crew" },
            { type = "int", name = "rank_order" },
            { type = "int", name = "promotion" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" }
        }
    },
    {
        name = "EVENT_NETWORK_DAMAGE_ENTITY",
        group = 1,
        size = 32,
        data = {
            { type = "int",   name = "target_entity" },
            { type = "int",   name = "initiator_entity" },
            { type = "float", name = "damage_amount" },
            { type = "bool",  name = "is_victim_destroyed" },
            { type = "bool",  name = "is_victim_incapacitated" },
            { type = "int",   name = "weapon" },
            { type = "int",   name = "ammo" },
            { type = "int",   name = "instigated_weapon" },
            { type = "float", name = "victim_speed" },
            { type = "float", name = "damager_speed" },
            { type = "bool",  name = "is_responsible_for_collision" },
            { type = "bool",  name = "is_headshot" },
            { type = "bool",  name = "is_with_melee_weapon" },
            { type = "bool",  name = "is_victim_executed" },
            { type = "bool",  name = "victim_bled_out" },
            { type = "bool",  name = "damager_was_scoped_in" },
            { type = "bool",  name = "damager_special_ability_active" },
            { type = "bool",  name = "victim_hogtied" },
            { type = "bool",  name = "victim_mounted" },
            { type = "bool",  name = "victim_in_vehicle" },
            { type = "bool",  name = "victim_in_cover" },
            { type = "bool",  name = "damager_shot_last_bullet" },
            { type = "bool",  name = "victim_killed_by_stealth" },
            { type = "bool",  name = "victim_killed_by_takedown" },
            { type = "bool",  name = "victim_knocked_out" },
            { type = "bool",  name = "is_victim_tranquilized" },
            { type = "bool",  name = "victim_killed_by_standard_melee" },
            { type = "bool",  name = "victim_mission_entity" },
            { type = "bool",  name = "victim_fleeing" },
            { type = "bool",  name = "victim_in_combat" },
            { type = "int",   name = "value_30" },
            { type = "bool",  name = "is_suicide" }
        }
    },
    {
        name = "EVENT_NETWORK_GANG",
        group = 1,
        size = 18,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "event_type" },
            { type = "int", name = "sender" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
        }
    },
    {
        name = "EVENT_NETWORK_GANG_WAYPOINT_CHANGED",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "waypoint_type" },
            { type = "int", name = "waypoint" },
            { type = "int", name = "type" }
        }
    },
    {
        name = "EVENT_NETWORK_HOGTIE_BEGIN",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_NETWORK_HOGTIE_END",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_NETWORK_HUB_UPDATE",
        group = 1,
        size = 1,
        data = {
            { type = "int", name = "update" }
        }
    },
    {
        name = "EVENT_NETWORK_INCAPACITATED_ENTITY",
        group = 1,
        size = 4,
        data = {
            { type = "int",   name = "target_entity" },
            { type = "int",   name = "initiator_entity" },
            { type = "int",   name = "weapon" },
            { type = "float", name = "damage_amount" }
        }
    },
    {
        name = "EVENT_NETWORK_LASSO_ATTACH",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_NETWORK_LASSO_DETACH",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_NETWORK_LOOT_CLAIMED",
        group = 1,
        size = 9,
        data = {
            { type = "int", name = "request" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "result_code" },
            { type = "int", name = "loot_entity_model" },
            { type = "int", name = "value_6" },
            { type = "int", name = "status" },
            { type = "int", name = "value_8" }
        }
    },
    {
        name = "EVENT_NETWORK_MINIGAME_REQUEST_COMPLETE",
        group = 1,
        size = 6,
        data = {
            { type = "int",  name = "request" },
            { type = "int",  name = "value_1" },
            { type = "int",  name = "value_2" },
            { type = "int",  name = "value_3" },
            { type = "bool", name = "isSuccess" },
            { type = "int",  name = "MinigameErrorCodeHash" }
        }
    },
    {
        name = "EVENT_NETWORK_PED_DISARMED",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "weapon" }
        }
    },
    {
        name = "EVENT_NETWORK_PED_HAT_SHOT_OFF",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "weapon" }
        }
    },
    {
        name = "EVENT_NETWORK_PERMISSION_CHECK_RESULT",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "request" },
            { type = "int", name = "result_code" }
        }
    },
    {
        name = "EVENT_NETWORK_PICKUP_COLLECTION_FAILED",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "player" },
            { type = "int", name = "pickup_type" }
        }
    },
    {
        name = "EVENT_NETWORK_PICKUP_RESPAWNED",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_COLLECTED_PICKUP",
        group = 1,
        size = 8,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "pickup_type" },
            { type = "int", name = "value_3" },
            { type = "int", name = "pickup_entity_model" },
            { type = "int", name = "pickup_ammo_amount" },
            { type = "int", name = "pickup_ammo_type" },
            { type = "int", name = "value_7" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_COLLECTED_PORTABLE_PICKUP",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "collected_pickup_network" },
            { type = "int", name = "player" },
            { type = "int", name = "value_2" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_DROPPED_PORTABLE_PICKUP",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "dropped_pickup_network" },
            { type = "int", name = "player" },
            { type = "int", name = "value_2" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_JOIN_SCRIPT",
        group = 1,
        size = 41,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "player" },
            { type = "int", name = "value_9" },
            { type = "int", name = "value_10" },
            { type = "int", name = "NumThreads" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" },
            { type = "int", name = "value_23" },
            { type = "int", name = "value_24" },
            { type = "int", name = "value_25" },
            { type = "int", name = "value_26" },
            { type = "int", name = "value_27" },
            { type = "int", name = "value_28" },
            { type = "int", name = "value_29" },
            { type = "int", name = "value_30" },
            { type = "int", name = "value_31" },
            { type = "int", name = "value_32" },
            { type = "int", name = "value_33" },
            { type = "int", name = "value_34" },
            { type = "int", name = "value_35" },
            { type = "int", name = "value_36" },
            { type = "int", name = "value_37" },
            { type = "int", name = "value_38" },
            { type = "int", name = "value_39" },
            { type = "int", name = "participant" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_LEFT_SCRIPT",
        group = 1,
        size = 41,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "player" },
            { type = "int", name = "value_9" },
            { type = "int", name = "value_10" },
            { type = "int", name = "NumThreads" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" },
            { type = "int", name = "value_23" },
            { type = "int", name = "value_24" },
            { type = "int", name = "value_25" },
            { type = "int", name = "value_26" },
            { type = "int", name = "value_27" },
            { type = "int", name = "value_28" },
            { type = "int", name = "value_29" },
            { type = "int", name = "value_30" },
            { type = "int", name = "value_31" },
            { type = "int", name = "value_32" },
            { type = "int", name = "value_33" },
            { type = "int", name = "value_34" },
            { type = "int", name = "value_35" },
            { type = "int", name = "value_36" },
            { type = "int", name = "value_37" },
            { type = "int", name = "value_38" },
            { type = "int", name = "value_39" },
            { type = "int", name = "participant" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_JOIN_SESSION",
        group = 1,
        size = 10,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "player" },
            { type = "int", name = "value_9" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_LEFT_SESSION",
        group = 1,
        size = 10,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "player" },
            { type = "int", name = "value_9" }
        }
    },
    {
        name = "EVENT_NETWORK_PLAYER_MISSED_SHOT",
        group = 1,
        size = 9,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "weapon" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" },
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_CREATED",
        group = 1,
        size = 10,
        data = {
            { type = "bool", name = "isSuccess" },
            { type = "int",  name = "posse" },
            { type = "int",  name = "value_2" },
            { type = "int",  name = "value_3" },
            { type = "int",  name = "value_4" },
            { type = "int",  name = "value_5" },
            { type = "int",  name = "value_6" },
            { type = "int",  name = "value_7" },
            { type = "int",  name = "value_8" },
            { type = "int",  name = "value_9" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_DATA_CHANGED",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_DISBANDED",
        group = 1,
        size = 2,
        data = {
            { type = "bool", name = "is_success" },
            { type = "int",  name = "posse" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_EX_ADMIN_DISBANDED",
        group = 1,
        size = 9,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_EX_INACTIVE_DISBANDED",
        group = 1,
        size = 10,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_JOINED",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "is_success" },
            { type = "int", name = "posse" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_LEADER_SET_ACTIVE",
        group = 1,
        size = 23,
        data = {
            { type = "int", name = "posse" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "network_gamer_handle" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_LEFT",
        group = 1,
        size = 1,
        data = {
            { type = "int", name = "posse" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_MEMBER_DISBANDED",
        group = 1,
        size = 23,
        data = {
            { type = "int", name = "posse" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "network_gamer_handle" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_MEMBER_JOINED",
        group = 1,
        size = 23,
        data = {
            { type = "int", name = "posse" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "network_gamer_handle" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_MEMBER_KICKED",
        group = 1,
        size = 23,
        data = {
            { type = "int", name = "posse" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "network_gamer_handle" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_MEMBER_LEFT",
        group = 1,
        size = 23,
        data = {
            { type = "int", name = "posse" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "network_gamer_handle" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" }
        }
    },
    {
        name = "EVENT_NETWORK_POSSE_MEMBER_SET_ACTIVE",
        group = 1,
        size = 23,
        data = {
            { type = "int", name = "posse" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "network_gamer_handle" },
            { type = "int", name = "value_10" },
            { type = "int", name = "value_11" },
            { type = "int", name = "value_12" },
            { type = "int", name = "value_13" },
            { type = "int", name = "value_14" },
            { type = "int", name = "value_15" },
            { type = "int", name = "value_16" },
            { type = "int", name = "value_17" },
            { type = "int", name = "value_18" },
            { type = "int", name = "value_19" },
            { type = "int", name = "value_20" },
            { type = "int", name = "value_21" },
            { type = "int", name = "value_22" }
        }
    },
    {
        name = "EVENT_NETWORK_PROJECTILE_ATTACHED",
        group = 1,
        size = 6,
        data = {
            { type = "int",   name = "initiator_entity" },
            { type = "int",   name = "target_entity" },
            { type = "float", name = "coord_x" },
            { type = "float", name = "coord_y" },
            { type = "float", name = "coord_z" },
            { type = "int",   name = "weapon" }
        }
    },
    {
        name = "EVENT_NETWORK_PROJECTILE_NO_DAMAGE_IMPACT",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "ammo" }
        }
    },
    {
        name = "EVENT_NETWORK_REVIVED_ENTITY",
        group = 1,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_NETWORK_SESSION_EVENT",
        group = 1,
        size = 10,
        data = {
            { type = "int", name = "event_type" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "value_8" },
            { type = "int", name = "value_9" }
        }
    },
    {
        name = "EVENT_NETWORK_SESSION_MERGE_END",
        group = 1,
        size = 1,
        data = {
            { type = "int", name = "session_message" }
        }
    },
    {
        name = "EVENT_NETWORK_SESSION_MERGE_START",
        group = 1,
        size = 1,
        data = {
            { type = "int", name = "session_message" }
        }
    },
    {
        name = "EVENT_NETWORK_VEHICLE_LOOTED",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "value_2" }
        }
    },
    {
        name = "EVENT_NETWORK_VEHICLE_UNDRIVABLE",
        group = 1,
        size = 3,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "value_2" }
        }
    },
    {
        name = "EVENT_OBJECT_INTERACTION",
        group = 0,
        size = 10,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "inventory_item" },
            { type = "int", name = "inventory_item_quantity" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "value_6" },
            { type = "int", name = "value_7" },
            { type = "int", name = "scenario_point" },
            { type = "int", name = "value_9" }
        }
    },
    {
        name = "EVENT_PED_ANIMAL_INTERACTION",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "interaction_type" }
        }
    },
    {
        name = "EVENT_PED_CREATED",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_PED_DESTROYED",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_PED_HAT_KNOCKED_OFF",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "hat_entity" }
        }
    },
    {
        name = "EVENT_PED_WHISTLE",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "whistle_type" }
        }
    },
    {
        name = "EVENT_PICKUP_CARRIABLE",
        group = 0,
        size = 4,
        data = {
            { type = "int",  name = "initiator_entity" },
            { type = "int",  name = "target_entity" },
            { type = "bool", name = "is_pickup_done_from_parent" },
            { type = "int",  name = "carrier_mount_entity" }
        }
    },
    {
        name = "EVENT_PLACE_CARRIABLE_ONTO_PARENT",
        group = 0,
        size = 6,
        data = {
            { type = "int",  name = "initiator_entity" },
            { type = "int",  name = "carriable_entity" },
            { type = "int",  name = "carrier_entity" },
            { type = "int",  name = "value_3" },
            { type = "bool", name = "is_a_pelt" },
            { type = "int",  name = "inventory_item" }
        }
    },
    {
        name = "EVENT_PLAYER_COLLECTED_AMBIENT_PICKUP",
        group = 0,
        size = 8,
        data = {
            { type = "int", name = "pickup_name" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "pickup_model" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" },
            { type = "int", name = "inventory_item_quantity" },
            { type = "int", name = "inventory_item" }
        }
    },
    {
        name = "EVENT_PLAYER_ESCALATED_PED",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_PLAYER_HAT_EQUIPPED",
        group = 0,
        size = 10,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "hat_entity" },
            { type = "int", name = "hat_drawble" },
            { type = "int", name = "hat_albedo" },
            { type = "int", name = "hat_normal" },
            { type = "int", name = "hat_material" },
            { type = "int", name = "hat_palette" },
            { type = "int", name = "hat_tint1" },
            { type = "int", name = "hat_tint2" },
            { type = "int", name = "hat_tint3" }
        }
    },
    {
        name = "EVENT_PLAYER_HAT_KNOCKED_OFF",
        group = 0,
        size = 5,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "hat_entity" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" }
        }
    },
    {
        name = "EVENT_PLAYER_HORSE_AGITATED_BY_ANIMAL",
        group = 0,
        size = 4,
        data = {
            { type = "int", name = "horse_entity" },
            { type = "int", name = "agitated_animal_entity" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" }
        }
    },
    {
        name = "EVENT_PLAYER_MOUNT_WILD_HORSE",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_PLAYER_PROMPT_TRIGGERED",
        group = 0,
        size = 10,
        data = {
            { type = "int",   name = "prompt_type" },
            { type = "int",   name = "value_1" },
            { type = "int",   name = "target_entity" },
            { type = "int",   name = "value_3" },
            { type = "float", name = "coord_x" },
            { type = "float", name = "coord_y" },
            { type = "float", name = "coord_z" },
            { type = "int",   name = "discoverable_entity_type" },
            { type = "int",   name = "value_8" },
            { type = "int",   name = "kit_emote_action" }
        }
    },
    {
        name = "EVENT_RAN_OVER_PED",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_REVIVE_ENTITY",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "used_inventory_item" }
        }
    },
    {
        name = "EVENT_SCENARIO_ADD_PED",
        group = 2,
        size = 2,
        data = {
            { type = "int", name = "script_uid" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_SCENARIO_DESTROY_PROP",
        group = 2,
        size = 2,
        data = {
            { type = "int", name = "script_uid" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_SCENARIO_REMOVE_PED",
        group = 2,
        size = 2,
        data = {
            { type = "int", name = "script_uid" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_SHOCKING_ITEM_STOLEN",
        group = 0,
        size = 3,
        data = {
            { type = "int", name = "initiator_entity" },
            { type = "int", name = "target_entity" },
            { type = "int", name = "carriable_entity" }
        }
    },
    {
        name = "EVENT_SHOT_FIRED_BULLET_IMPACT",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_SHOT_FIRED_WHIZZED_BY",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_STAT_VALUE_CHANGED",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "stat_value_type" },
            { type = "int", name = "value_1" }
        }
    },
    {
        name = "EVENT_TRIGGERED_ANIMAL_WRITHE",
        group = 0,
        size = 2,
        data = {
            { type = "int", name = "target_entity" },
            { type = "int", name = "initiator_entity" }
        }
    },
    {
        name = "EVENT_UI_ITEM_INSPECT_ACTIONED",
        group = 3,
        size = 6,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" }
        }
    },
    {
        name = "EVENT_UI_QUICK_ITEM_USED",
        group = 3,
        size = 6,
        data = {
            { type = "int", name = "value_0" },
            { type = "int", name = "value_1" },
            { type = "int", name = "value_2" },
            { type = "int", name = "value_3" },
            { type = "int", name = "value_4" },
            { type = "int", name = "value_5" }
        }
    },
    {
        name = "EVENT_VEHICLE_CREATED",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "target_entity" }
        }
    },
    {
        name = "EVENT_VEHICLE_DESTROYED",
        group = 0,
        size = 1,
        data = {
            { type = "int", name = "target_entity" }
        }
    },
}
