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

    // 2) Barra suave
    _u.hp_shown = lerp(_u.hp_shown, _u.hp, 0.08);
    if (abs(_u.hp_shown - _u.hp) < 0.1) _u.hp_shown = _u.hp;
}

// 3) Tremor de tela
if (shake_time > 0) {
    shake_time--;
    var _k = shake_time / shake_max;
    shake_x = random_range(-shake_power, shake_power) * _k;
    shake_y = random_range(-shake_power, shake_power) * _k;
} else {
    shake_x = 0;
    shake_y = 0;
}

// 4) Números flutuantes
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
            if (menu_index == menu_locked) {
                log_text = "Apagada pelo DROP COLUMN!";
            } else {
                switch (menu_index) {

                    case 0: // Atacar
                        chosen_action = "attack";
                        target_index = 0;
                        state = BATTLE_STATE.PLAYER_TARGET;
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

                    case 4: // Especial
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
                state = BATTLE_STATE.PLAYER_TIMING;
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

            var _bonus = 1 + 0.1 * min(combo, 5);
            var _expo = boss_exposed;
            if (_expo) { _bonus *= 2; boss_exposed = false; }   // NULL: dobra uma vez e consome

            deal_damage(current, chosen_target, _mult * _bonus, "");
            if (_expo) log_text = "EXPOSTO x2! " + log_text;
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
        } else {
            start_boss_attack(1, 1, 50, 3, 8, false);
            log_text = current.name + " vai atacar " + def_victim.name + "!";
        }
        break;

    case BATTLE_STATE.ROLL:
        roll_timer++;

        if (roll_timer < 60) {
            // Girando: a face troca rápido e vai desacelerando
            var _interval = (roll_timer < 30) ? 3 : 6;
            if ((roll_timer mod _interval) == 0) roll_face_shown = irandom_range(1, 6);
        }
        else if (roll_timer == 60) {
            // Pousou
            roll_face_shown = roll_result;
            start_shake(3, 10);
            log_text = "Dado: " + string(roll_result) + "!";
        }
        else if (roll_timer >= 110) {
            // Executa o ataque da face sorteada
            var _bp2 = get_unit_pos(current);
            add_popup(_bp2.x, _bp2.y - 55, dice_faces[roll_result - 1].name, c_white);

            switch (roll_result) {

                case 1: // NULL: falha e fica exposto
                    boss_exposed = true;
                    log_text = "NULL! Exposto: seu proximo golpe vale 2x";
                    timer = 60;
                    state = BATTLE_STATE.EXECUTE_ACTION;
                    break;

                case 2: // SELECT *: ataque básico
                    start_boss_attack(1, 1, 50, 3, 8, false);
                    log_text = "SELECT * em " + def_victim.name + "!";
                    break;

                case 3: // UPDATE: ATK -30% por 2 turnos
                    atk_debuff = 2;
                    log_text = "UPDATE! Seu ATK caiu 30% por 2 turnos";
                    timer = 60;
                    state = BATTLE_STATE.EXECUTE_ACTION;
                    break;

                case 4: // DROP COLUMN: apaga Habilidade ou Item por 1 turno
                    menu_locked = choose(2, 3);
                    log_text = "DROP COLUMN! " + menu_options[menu_locked] + " apagada";
                    timer = 60;
                    state = BATTLE_STATE.EXECUTE_ACTION;
                    break;

                case 5: // DELETE: golpe duplo (duas janelas de defesa)
                    start_boss_attack(0.8, 2, 38, 3, 8, false);
                    log_text = "DELETE! Golpe duplo!";
                    break;

                case 6: // DROP TABLE: golpe devastador, janela curta, depois recarrega
                    boss_recharging = true;
                    start_boss_attack(3, 1, 34, 2, 5, true);
                    log_text = "DROP TABLE!!! Defenda!";
                    break;
            }
        }
        break;

    case BATTLE_STATE.DEFENSE:
        def_timer++;

        // Só vale o primeiro aperto
        if (def_press == -1 && keyboard_check_pressed(vk_space)) def_press = def_timer;

        // Resolve quando a janela fecha
        if (def_timer >= def_hit + def_good) {
            var _dd = (def_press == -1) ? 999 : abs(def_press - def_hit);
            var _res = "miss";

            if (_dd <= def_perfect) {
                // Perfeita: bloqueia tudo
                log_text = "DEFESA PERFEITA! " + def_victim.name + " bloqueou.";
                add_popup(def_x, def_y - 30, "BLOQUEOU!", c_aqua);
                _res = "perfect";
            }
            else if (_dd <= def_good) {
                if (def_heavy) {
                    // Golpe pesado: a defesa boa alivia só um pouco
                    deal_damage(current, def_victim, enemy_mult * 0.7, "");
                } else {
                    // Normal: dano pela metade
                    var _was = def_victim.defending;
                    def_victim.defending = true;
                    deal_damage(current, def_victim, enemy_mult, "");
                    def_victim.defending = _was;
                }
                log_text = "Defesa boa! " + log_text;
                _res = "good";
            }
            else {
                // Errou ou não apertou: dano completo
                deal_damage(current, def_victim, enemy_mult, "");
                _res = "miss";
            }

            register_defense(_res);

            if (def_hits_left > 1 && def_victim.hp > 0) {
                // Tem mais um golpe vindo: reinicia a janela
                def_hits_left--;
                def_timer = 0;
                def_press = -1;
                log_text = "Segundo golpe!";
            } else {
                timer = 30;
                state = BATTLE_STATE.EXECUTE_ACTION;
            }
        }
        break;

    case BATTLE_STATE.EXECUTE_ACTION:
        timer--;
        if (timer <= 0) state = BATTLE_STATE.CHECK_END;
        break;

    case BATTLE_STATE.CHECK_END:
        // Combo e energia
        switch (last_result) {
            case "perfect": combo++; energy += 25; break;
            case "good":    combo++; energy += 15; break;
            case "miss":    combo = 0;             break;
        }
        energy = clamp(energy, 0, energy_max);
        last_result = "none";

        // Fim do turno do jogador: efeitos de "1 turno" do dado acabam
        if (current.is_player) {
            if (atk_debuff > 0) atk_debuff--;
            menu_locked = -1;
        }
        roll_active = false;

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