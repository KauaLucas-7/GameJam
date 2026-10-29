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
					chosen_action = "defend";   
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
						chosen_action = "item";   
                        log_text = current.name + " usou " + _potion.name + " (+" + string(_potion.heal) + " HP).";
                        timer = 45;
                        state = BATTLE_STATE.EXECUTE_ACTION;
                    } else {
                        log_text = "Sem pocoes!";
                    }
                    break;

                case 4: // Especial (só com a energia cheia)
                    if (energy >= energy_max) {
						 chosen_action = "special";   // NOVO
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
        timing_pos += timing_speed * (1 - cyber_total("timing_slow")) * timing_dir;
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

            var _bonus = 1 + 0.1 * min(combo, 5);
            var _expo = boss_exposed;
            if (_expo) { _bonus *= 2; boss_exposed = false; }   // NULL: dobra uma vez e consome

            if (is_worker(chosen_target) && last_result == "perfect") {
                // Funcionário moldado + timing perfeito: é libertado
                free_worker(chosen_target);
            } else {
                deal_damage(current, chosen_target, _mult * _bonus, "");
                if (_expo) log_text = "EXPOSTO x2! " + log_text;
            }
            log_text = _rating + " " + log_text;

            timer = 30;
            state = BATTLE_STATE.EXECUTE_ACTION;
        }

        if (keyboard_check_pressed(vk_escape)) state = BATTLE_STATE.PLAYER_TARGET;
        break;
       case BATTLE_STATE.ENEMY_TURN:
        if (current.is_dice) {
            if (boss_recharging) {
                // Depois do DROP TABLE ele perde o turno
                boss_recharging = false;
                roll_active = false;
                log_text = "O dado esta recarregando...";
                timer = 60;
                state = BATTLE_STATE.EXECUTE_ACTION;
            } else {
                if (!boss_phase2 && current.hp <= current.hp_max * 0.5) {
                    boss_phase2 = true;
                    var _bp = get_unit_pos(current);
                    add_popup(_bp.x, _bp.y - 55, "DADO VICIADO!", c_red);
                    start_shake(5, 14);
                }
                roll_active = true;
                roll_timer = 0;
                roll_result = roll_dice(current);
                roll_face_shown = irandom_range(1, 6);

                // TESTE: segure 1 a 6 no teclado para forçar a face (apague depois)
                for (var k = 1; k <= 6; k++) if (keyboard_check(ord(string(k)))) roll_result = k;

                log_text = "O dado esta rolando...";
                state = BATTLE_STATE.ROLL;
            }
        }
        // ----- Boss Urso -----
        else if (is_urso(current)) {
            urso_turns++;

            // chama um funcionário moldado (mais rápido na fase final)
            if (urso_turns mod (fase_final ? 2 : 3) == 0 && workers_alive() < 3) spawn_worker();

            var _fm = fase_final ? 1.25 : 1;
            if (urso_turns mod 4 == 0) {
                // Reunião de alinhamento: golpe pesado
                start_boss_attack(1.6 * _fm, 1, 40, 2, 5, true);
                log_text = "REUNIAO DE ALINHAMENTO! Voce precisa se adequar!";
            } else if (fase_final) {
                // Fase final: golpe duplo
                start_boss_attack(0.8 * _fm, 2, 38, 3, 8, false);
                log_text = "Eu moldo todo mundo! Golpe duplo!";
            } else {
                start_boss_attack(_fm, 1, 50, 3, 8, false);
                log_text = "Urso: Todos aqui seguem o molde!";
            }
        }
        // ----- Funcionário moldado -----
        else if (is_worker(current)) {
            start_boss_attack(0.7, 1, 50, 3, 8, false);
            log_text = current.name + " (moldado) ataca!";
        }
        // ----- Python e inimigos normais -----
        else {
            var _py = variable_struct_exists(current, "typed");
            start_boss_attack(_py ? boss_dmg_mult(current) : 1, 1, 50, 3, 8, false);
            log_text = current.name + " vai atacar " + def_victim.name + "!";
        }
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

		//timer = (_py || is_urso(current)) ? 70 : 30;   // texto maior, mais tempo para ler
        state = BATTLE_STATE.EXECUTE_ACTION;
    }
    break;

    case BATTLE_STATE.EXECUTE_ACTION:
        timer--;
        if (timer <= 0) state = BATTLE_STATE.CHECK_END;
        break;

    case BATTLE_STATE.CHECK_END:
        // Combo e energia
		var _em = 1 + cyber_total("energy_mult");
        switch (last_result) {
            case "perfect": combo++; energy += floor(25 * _em); break;
            case "good":    combo++; energy += floor(15 * _em); break;
            case "miss":    combo = 0;                          break
        }
        energy = clamp(energy, 0, energy_max);

        // Molde (só no 3o andar): erro sobe, perfeito desce, repetir ação sobe
        if (molde_on) {
            if (last_result == "perfect") { molde -= 12; add_popup(190, 40, "MOLDE -12", c_aqua); }
            if (last_result == "miss")    { molde += 15; add_popup(190, 40, "MOLDE +15", c_fuchsia); }
            if (current.is_player) {
                var _aid = chosen_action;
                if (_aid == "skill") _aid += chosen_skill.name;
                if (_aid == last_action_id) { molde += 10; add_popup(80, 60, "REPETIU! MOLDE +10", c_orange); }
                last_action_id = _aid;
            }
            molde = clamp(molde, 0, molde_max);
        }
        last_result = "none";

        // Veneno: dano no fim do turno de quem acabou de agir
        var _pdmg = tick_status(current);
        if (_pdmg > 0) log_text += "  Veneno: -" + string(_pdmg);

        // Python: contagem para trocar de tipo
        if (variable_struct_exists(current, "typed")) log_text += boss_end_turn(current);

        // Fim do turno do jogador: efeitos de "1 turno" do dado acabam
        if (current.is_player) {
            if (atk_debuff > 0) atk_debuff--;
            menu_locked = -1;
        }
        roll_active = false;

        // No 3o andar vence quem derrota o Urso (os robôs restantes voltam ao normal)
        var _enemies_dead = molde_on ? (urso.hp <= 0) : (array_length(alive_list(enemies)) == 0);

        if (_enemies_dead) {
            if (molde_on) {
                for (var i = 0; i < array_length(enemies); i++) {
                    if (is_worker(enemies[i])) remove_worker(enemies[i]);
                }
            }
            scene_timer = 0;
            state = BATTLE_STATE.WIN;
        }
        else if (array_length(alive_list(party)) == 0) state = BATTLE_STATE.LOSE;
        else if (molde_on && molde >= molde_max) {
            scene_timer = 0;
            state = BATTLE_STATE.MOLD_END;
        }
        else if (molde_on && !proposta_done && urso.hp <= urso.hp_max * 0.5) {
            proposal_index = 0;
            state = BATTLE_STATE.PROPOSAL;
        }
        else {
            next_turn();
            menu_index = 0;
            state = current.is_player ? BATTLE_STATE.PLAYER_MENU : BATTLE_STATE.ENEMY_TURN;
        }
        break;
    case BATTLE_STATE.PROPOSAL:
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)) proposal_index = 1 - proposal_index;

        if (keyboard_check_pressed(vk_enter)) {
            proposta_done = true;
            if (proposal_index == 0) {
                // ACEITAR: cura o chefe por completo e leva ao final ruim
                urso.hp = urso.hp_max;
                log_text = "Nexa aceita a proposta...";
                scene_timer = 0;
                state = BATTLE_STATE.ENDING_BAD;
            } else {
                // RECUSAR: energia cheia e começa a fase final
                energy = energy_max;
                fase_final = true;
                add_popup(80, 60, "EU RECUSO ESSE MOLDE!", c_aqua);
                start_shake(6, 20);
                log_text = "Eu recuso esse molde! Fase final!";
                next_turn();
                menu_index = 0;
                state = current.is_player ? BATTLE_STATE.PLAYER_MENU : BATTLE_STATE.ENEMY_TURN;
            }
        }
        break;

    case BATTLE_STATE.MOLD_END:
    case BATTLE_STATE.ENDING_BAD:
        scene_timer++;
        if (scene_timer > 330 && keyboard_check_pressed(vk_enter)) room_restart();
        break;

        case BATTLE_STATE.WIN:
        scene_timer++;
        // Andares 1 e 2: o boss solta mods. O andar 3 (Molde) é o fim do jogo.
        if (!molde_on && !reward_given) {
            reward_given = true;
            var _names = "";
            for (var i = 0; i < array_length(enemies); i++) {
                if (variable_struct_exists(enemies[i], "rewards")) {
                    for (var j = 0; j < array_length(enemies[i].rewards); j++) {
                        var _rid = enemies[i].rewards[j];
                        cyber_give(_rid);
                        _names += ((_names == "") ? "" : ", ") + global.mods[$ _rid].name;
                    }
                }
            }
            if (_names != "") log_text = "Mods encontrados: " + _names;
        }
        if (keyboard_check_pressed(vk_enter)) {
            if (molde_on) {
				if (!variable_instance_exists(id, "final_disparado")) {
					final_disparado = true;
					iniciar_dialogo("final", "creditos", -1);
				}
			}
            else {
				var _venceu = global.andar;
				if (!variable_global_exists("vencidos")) global.vencidos = {};
				variable_struct_set(global.vencidos, "a" + string(_venceu), true);
				global.cena_pendente = (_venceu == 1) ? "andar1_fim" : "andar2_pos";
				global.andar++;
				if (_venceu == 1) room_goto(rm_andar1); else room_goto(rm_andar2);
			}
        }
        break;

    case BATTLE_STATE.LOSE:
        scene_timer++;
        if (keyboard_check_pressed(vk_enter)) room_restart();
        break;

}
