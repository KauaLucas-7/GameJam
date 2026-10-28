// ===== EFEITOS VISUAIS =====

// 1) Detecta mudança de HP -> número flutuante + tremor
for (var i = 0; i < array_length(turn_order); i++) {
    var _u = turn_order[i];

    if (_u.hp != _u.hp_prev) {
        var _diff = _u.hp - _u.hp_prev;
        var _pos = get_unit_pos(_u);

        if (_diff < 0) {
            add_popup(_pos.x, _pos.y - 30, string(-_diff), _u.is_player ? c_red : c_yellow);
            if (_u.is_player) start_shake(clamp(-_diff / _u.hp_max * 25, 3, 10), 18);
            else              start_shake(2, 8);
        } else {
            add_popup(_pos.x, _pos.y - 30, "+" + string(_diff), c_lime);
        }
        _u.hp_prev = _u.hp;
    }

    // 2) Barra suave: o valor desenhado persegue o HP real
    _u.hp_shown = lerp(_u.hp_shown, _u.hp, 0.08);
    if (abs(_u.hp_shown - _u.hp) < 0.1) _u.hp_shown = _u.hp;
}

// 3) Tremor de tela (diminui até parar)
if (shake_time > 0) {
    shake_time--;
    var _k = shake_time / shake_max;
    shake_x = random_range(-shake_power, shake_power) * _k;
    shake_y = random_range(-shake_power, shake_power) * _k;
} else {
    shake_x = 0;
    shake_y = 0;
}

// 4) Move e remove os números flutuantes
for (var i = array_length(popups) - 1; i >= 0; i--) {
    var _p = popups[i];
    _p.y += _p.vy;
    _p.vy *= 0.95;
    _p.life--;
    if (_p.life <= 0) array_delete(popups, i, 1);
}

// ===== FIM DOS EFEITOS =====

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

                case 0: // Atacar
                    chosen_action = "attack";
                    target_index = 0;
                    state = BATTLE_STATE.PLAYER_TARGET
                    break;

                case 1: // Defender
                    current.defending = true;
                    log_text = current.name + " se defende.";
                    state = BATTLE_STATE.CHECK_END;
                    break;

                case 2: // Habilidade
                    skill_index = 0;
                    state = BATTLE_STATE.PLAYER_SKILL;
                    break;

                case 3: // Item
                    var _potion = global.items.potion;
                    if (use_item(current, _potion)) {
                        log_text = current.name + " usou " + _potion.name + " (+" + string(_potion.heal) + " HP).";
                        timer = 45;
                        state = BATTLE_STATE.EXECUTE_ACTION;
                    } else {
                        log_text = "Sem pocoes!";
                    }
                    break;

                case 4: // Especial (só com a energia cheia)
                    if (energy >= energy_max) {
                        var _targets = alive_list(enemies);
                        for (var i = 0; i < array_length(_targets); i++) {
                            deal_damage(current, _targets[i], 2.5, "");
                        }
                        log_text = current.name + " usou o GOLPE ESPECIAL!";
                        energy = 0;
                        timer = 45;
                        state = BATTLE_STATE.EXECUTE_ACTION;
                    } else {
                        log_text = "Energia insuficiente!";
                    }
                    break;
            }
        }
        break;

    case BATTLE_STATE.PLAYER_SKILL:
        var _skills = current.skills;
        var _count = array_length(_skills);

        if (keyboard_check_pressed(vk_up))   skill_index = (skill_index - 1 + _count) mod _count;
        if (keyboard_check_pressed(vk_down)) skill_index = (skill_index + 1) mod _count;
        if (keyboard_check_pressed(vk_escape)) state = BATTLE_STATE.PLAYER_MENU;

        if (keyboard_check_pressed(vk_enter)) {
            var _s = _skills[skill_index];

            if (current.mp < _s.cost) {
                log_text = "Sem MP para " + _s.name + "!";
            } else {
                chosen_action = "skill";
                chosen_skill = _s;

                if (_s.heal) {
                    use_skill(current, _s, current);
                    log_text = current.name + " usou " + _s.name + " (+" + string(_s.power) + " HP).";
                    timer = 30;
                    state = BATTLE_STATE.EXECUTE_ACTION;
                } else {
                    target_index = 0;
                    state = BATTLE_STATE.PLAYER_TARGET;
                }
            }
        }
        break;

    case BATTLE_STATE.PLAYER_TARGET:
        var _alive = alive_list(enemies);
        var _n = array_length(_alive);
        if (keyboard_check_pressed(vk_left))  target_index = (target_index - 1 + _n) mod _n;
        if (keyboard_check_pressed(vk_right)) target_index = (target_index + 1) mod _n;

        if (keyboard_check_pressed(vk_escape)) {
            state = (chosen_action == "skill") ? BATTLE_STATE.PLAYER_SKILL : BATTLE_STATE.PLAYER_MENU;
			
        }

        if (keyboard_check_pressed(vk_enter)) {
            var _target = _alive[target_index];

            if (chosen_action == "attack") {
                chosen_target = _target;
                timing_pos = 0;
                timing_dir = 1;
                state = BATTLE_STATE.PLAYER_TIMING
            }
            else if (chosen_action == "skill") {
                if (use_skill(current, chosen_skill, _target)) {
                    log_text = current.name + " usou " + chosen_skill.name + " em " + _target.name + "!";
					timer = 30;
                    state = BATTLE_STATE.EXECUTE_ACTION;
                } else {
                    log_text = "Sem MP!";
                    state = BATTLE_STATE.PLAYER_SKILL;
                }
            }
        }
        break;

    case BATTLE_STATE.PLAYER_TIMING:
        timing_pos += timing_speed * timing_dir;
        if (timing_pos >= 1 || timing_pos <= 0) {
            timing_pos = clamp(timing_pos, 0, 1);
            timing_dir *= -1;
        }

        if (keyboard_check_pressed(vk_space)) {
            var _dist = abs(timing_pos - 0.5);
            var _mult = 0.8;
            var _rating = "Fraco...";
            last_result = "miss";
            if (_dist < 0.15) { _mult = 1.2; _rating = "Bom!";      last_result = "good"; }
            if (_dist < 0.05) { _mult = 1.5; _rating = "PERFEITO!"; last_result = "perfect"; }

            var _bonus = 1 + 0.1 * min(combo, 5);   // bônus de combo (até +50%)
            deal_damage(current, chosen_target, _mult * _bonus, "");
            log_text = _rating + " " + log_text;

            timer = 30;
            state = BATTLE_STATE.EXECUTE_ACTION;
        }

        if (keyboard_check_pressed(vk_escape)) state = BATTLE_STATE.PLAYER_TARGET;
        break;

    case BATTLE_STATE.ENEMY_TURN:
        // Escolhe a vítima e abre a janela de defesa (o dano só sai no DEFENSE)
        var _allies = alive_list(party);
        def_victim = _allies[irandom(array_length(_allies) - 1)];
        def_timer = 0;
        def_press = -1;
        for (var i = 0; i < array_length(party); i++) {
            if (party[i] == def_victim) { def_x = 80; def_y = 100 + i * 60; }
        }
        log_text = current.name + " vai atacar " + def_victim.name + "!";
        state = BATTLE_STATE.DEFENSE;
        break;

    case BATTLE_STATE.DEFENSE:
    def_timer++;

    if (def_press == -1 && keyboard_check_pressed(vk_space)) def_press = def_timer;

    if (def_timer >= def_hit + 8) {
        var _diff = (def_press == -1) ? 999 : abs(def_press - def_hit);
        var _is_boss = variable_struct_exists(current, "typed");
        var _bmult = _is_boss ? boss_dmg_mult(current) : 1;

        if (_diff <= 3) {
            // Perfeita: bloqueia tudo
            log_text = "DEFESA PERFEITA! " + def_victim.name + " bloqueou o golpe.";
            add_popup(def_x, def_y - 30, "BLOQUEOU!", c_aqua);
            last_result = "perfect";
            if (_is_boss) log_text += boss_on_block(current);
        }
        else if (_diff <= 8) {
            // Boa: dano pela metade (ainda envenena)
            var _was = def_victim.defending;
            def_victim.defending = true;
            deal_damage(current, def_victim, _bmult, "");
            def_victim.defending = _was;
            log_text = "Defesa boa! " + log_text;
            last_result = "good";
            if (_is_boss) log_text += boss_on_hit(current, def_victim);
        }
        else {
            // Errou ou não apertou: dano completo
            deal_damage(current, def_victim, _bmult, "");
            last_result = "miss";
            if (_is_boss) log_text += boss_on_hit(current, def_victim);
        }

        timer = _is_boss ? 70 : 30;   // texto maior, mais tempo para ler
        state = BATTLE_STATE.EXECUTE_ACTION;
    }
    break;

    case BATTLE_STATE.EXECUTE_ACTION:
        timer--;
        if (timer <= 0) state = BATTLE_STATE.CHECK_END;
        break;

    case BATTLE_STATE.CHECK_END:
        // Combo e energia são somados aqui, com base no resultado da ação
        switch (last_result) {
            case "perfect": combo++; energy += 25; break;
            case "good":    combo++; energy += 15; break;
            case "miss":    combo = 0;             break;
        }
        energy = clamp(energy, 0, energy_max);
        last_result = "none";
		var _pdmg = tick_status(current);
		if (_pdmg > 0) log_text += "  Veneno: -" + string(_pdmg);

		// boss: contagem para trocar de tipo
		if (variable_struct_exists(current, "typed")) log_text += boss_end_turn(current);
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
