switch (state) {

    case BATTLE_STATE.START:
		current = turn_order[turn_index];			
        state = current.is_player ? BATTLE_STATE.PLAYER_MENU : BATTLE_STATE.ENEMY_TURN;
        break;

    case BATTLE_STATE.PLAYER_MENU:
        if (keyboard_check_pressed(vk_up))   menu_index--;
        if (keyboard_check_pressed(vk_down)) menu_index++;
        menu_index = clamp(menu_index, 0, array_length(menu_options) - 1);

        if (keyboard_check_pressed(vk_enter)) {
            switch (menu_index) {
                case 0: chosen_action = "attack"; target_index = 0; state = BATTLE_STATE.PLAYER_TARGET; break;
                case 2: chosen_action = "skill";  target_index = 0; state = BATTLE_STATE.PLAYER_TARGET; break;
                case 1: // Defender -> vai direto para CHECK_END
                    current.defending = true;
                    log_text = current.name + " se defende.";
                    state = BATTLE_STATE.CHECK_END;
                    break;
                case 3: // Item (poção cura o aliado atual, sem alvo)
                    if (potions > 0) {
                        potions--;
                        current.hp = min(current.hp_max, current.hp + 15);
                        log_text = current.name + " usou Pocao (+15 HP).";
                        timer = 45;
                        state = BATTLE_STATE.EXECUTE_ACTION;
                    } else {
                        log_text = "Sem pocoes!";
                    }
                    break;
            }
        }
        break;

    case BATTLE_STATE.PLAYER_TARGET:
        var _alive = alive_list(enemies);
        var _n = array_length(_alive);
        if (keyboard_check_pressed(vk_left))  target_index = (target_index - 1 + _n) mod _n;
        if (keyboard_check_pressed(vk_right)) target_index = (target_index + 1) mod _n;
        if (keyboard_check_pressed(vk_escape)) state = BATTLE_STATE.PLAYER_MENU;

        if (keyboard_check_pressed(vk_enter)) {
            var _target = _alive[target_index];
            if (chosen_action == "attack") deal_damage(current, _target, 1,   "");
            if (chosen_action == "skill")  deal_damage(current, _target, 1.5, "fire");
            timer = 45;
            state = BATTLE_STATE.EXECUTE_ACTION;
        }
        break;

    case BATTLE_STATE.ENEMY_TURN:
        var _allies = alive_list(party);
        var _victim = _allies[irandom(array_length(_allies) - 1)];
        deal_damage(current, _victim, 1, "");
        timer = 45;
        state = BATTLE_STATE.EXECUTE_ACTION;
        break;

    case BATTLE_STATE.EXECUTE_ACTION:
        timer--;
        if (timer <= 0) state = BATTLE_STATE.CHECK_END;
        break;

    case BATTLE_STATE.CHECK_END:
        if (array_length(alive_list(enemies)) == 0)      state = BATTLE_STATE.WIN;
        else if (array_length(alive_list(party)) == 0)   state = BATTLE_STATE.LOSE;
        else {
            next_turn();
            menu_index = 0;
            state = current.is_player ? BATTLE_STATE.PLAYER_MENU : BATTLE_STATE.ENEMY_TURN;
        }
        break;

    case BATTLE_STATE.WIN:
    case BATTLE_STATE.LOSE:
        if (keyboard_check_pressed(vk_enter)) room_restart();
        break;
}
