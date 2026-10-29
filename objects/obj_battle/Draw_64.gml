// Tremor
matrix_set(matrix_world, matrix_build(shake_x, shake_y, 0, 0, 0, 0, 1, 1, 1));

draw_set_color(c_white);
draw_text(4, 4, "Estado: " + string(state));

// Aliados (esquerda)
for (var i = 0; i < array_length(party); i++) {
    var _u = party[i];
    var _x = 80, _y = 100 + i * 60;

    if (_u.hp > 0) {
        if (_u.sprite != -1) {
            var _frames = sprite_get_number(_u.sprite);
            var _frame  = floor(current_time / 1000 * 6) mod _frames;
            var _tint = molde_on ? merge_colour(c_white, c_gray, 0.8 * (molde / molde_max)) : c_white;
            draw_sprite_ext(_u.sprite, _frame, _x, _y, 1, 1, 0, _tint, 1);
        } else {
            draw_set_color(c_aqua);
            draw_rectangle(_x - 12, _y - 16, _x + 12, _y + 16, false);
            draw_set_color(c_white);
        }
        if (_u == current) draw_text(_x - 45, _y - 8, ">");
    }

    if (_u.hp_shown > 0.5) draw_hp_bar(_x - 30, _y + 28, 70, 5, _u);
    draw_text(_x - 30, _y + 35, _u.name + " HP " + string(_u.hp) + "/" + string(_u.hp_max)
                              + "  MP " + string(_u.mp) + "/" + string(_u.mp_max));

    // Indicador de veneno (boss Python)
    var _ps = status_stacks(_u, "poison");
    if (_ps > 0 && _u.hp > 0) {
        draw_set_color(c_green);
        draw_text(_x - 30, _y + 47, "VENENO x" + string(_ps));
        draw_set_color(c_white);
    }
}

// Debuff do UPDATE
if (atk_debuff > 0) {
    draw_set_color(c_red);
    draw_text(20, 165, "ATK -30% (" + string(atk_debuff) + ")");
    draw_set_color(c_white);
}

// Inimigos (direita)
var _alive = alive_list(enemies);
for (var i = 0; i < array_length(enemies); i++) {
    var _e = enemies[i];

    // ----- BOSS DADO -----
    if (_e.is_dice) {
        var _dx = 370, _dy = 125;
        var _ang = 0, _oy = 0, _sc = 0.6;   // _sc = tamanho do dado (ajuste se ficar grande/pequeno)

        if (_e.hp > 0) {
            if (state == BATTLE_STATE.ROLL && roll_timer < 60) {
                var _pr = roll_timer / 60;
                _ang = 720 * (1 - sqr(1 - _pr));                        // gira e desacelera
                _oy  = -abs(sin(roll_timer * 0.35)) * 30 * (1 - _pr);   // quica cada vez menos
            } else {
                _oy = sin(current_time / 400) * 3;                      // flutua parado
            }
            if (state == BATTLE_STATE.ROLL && roll_timer >= 60 && roll_timer < 70) {
                _sc = 0.6 + (70 - roll_timer) * 0.01;                   // "pop" ao pousar
            }

            var _col = c_white;
            if (boss_exposed)    _col = c_yellow;   // NULL: exposto
            if (boss_recharging) _col = c_gray;     // DROP TABLE: recarregando
            draw_sprite_ext(_e.sprite, 0, _dx, _dy + _oy, _sc, _sc, _ang, _col, 1);

            if (boss_exposed)    { draw_set_color(c_yellow); draw_text(_dx - 28, _dy - 60, "EXPOSTO!"); }
            if (boss_recharging) { draw_set_color(c_gray);   draw_text(_dx - 40, _dy - 60, "RECARREGANDO"); }
            draw_set_color(c_white);

            if (_e == current) draw_text(_dx - 50, _dy - 6, "<");
            if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
                draw_text(_dx - 4, _dy - 56, "v");
        }

        if (_e.hp_shown > 0.5) draw_hp_bar(_dx - 40, _dy + 42, 80, 6, _e);
        draw_text(_dx - 40, _dy + 50, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
        continue;
    }

    // ----- BOSS PYTHON (com sprite) -----
    if (variable_struct_exists(_e, "typed") && _e.sprite != -1) {
        var _px = 370, _py = 120;
        var _pscale = 0.6;   // tamanho do sprite (ajuste se ficar grande/pequeno)
        var _tcol = global.boss_types[_e.type_index].color;

        if (_e.hp > 0) {
            var _pfr  = floor(current_time / 1000 * 6) mod sprite_get_number(_e.sprite);
            var _bob  = sin(current_time / 400) * 3;               // flutua parado
            var _tint = merge_colour(c_white, _tcol, 0.45);        // tinge de leve com a cor do tipo
            draw_sprite_ext(_e.sprite, _pfr, _px, _py + _bob, _pscale, _pscale, 0, _tint, 1);

            // cauda: um quadradinho por segmento
            draw_set_color(_tcol);
            for (var s = 0; s < _e.tail; s++) {
                draw_rectangle(_px - 36 + s * 10, _py + 80, _px - 30 + s * 10, _py + 86, false);
            }
            draw_set_color(c_white);

            if (_e == current) draw_text(_px - 70, _py - 6, "<");
            if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
                draw_text(_px - 4, _py - 60, "v");
        }

        if (_e.hp_shown > 0.5) draw_hp_bar(_px - 40, _py + 42, 80, 6, _e);
        draw_text(_px - 40, _py + 50, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
        if (_e.hp > 0) {
            draw_set_color(_tcol);
            draw_text(_px - 40, _py + 64, "TIPO: " + global.boss_types[_e.type_index].name);
            draw_set_color(c_white);
        }
        continue;
    }
	    // ----- BOSS URSO e FUNCIONARIOS MOLDADOS -----
    if (is_urso(_e) || is_worker(_e)) {
        var _b = is_urso(_e);
        var _ux = _e.pos.x, _uy = _e.pos.y;
        var _uw = _b ? 56 : 22, _uh = _b ? 72 : 30;
        var _ubob = sin(current_time / 400 + i) * (_b ? 2 : 1);

        if (_e.hp > 0) {
            if (_e.sprite != -1) {
                draw_sprite_ext(_e.sprite, 0, _ux, _uy + _ubob, 1, 1, 0, c_white, 1);
            } else {
                // sem sprite ainda: retângulos de teste
                draw_set_color(_b ? make_colour_rgb(120, 70, 30) : c_gray);
                draw_rectangle(_ux - _uw / 2, _uy - _uh / 2 + _ubob, _ux + _uw / 2, _uy + _uh / 2 + _ubob, false);
                draw_set_color(_b ? c_red : c_aqua);   // "olhos"
                draw_rectangle(_ux - _uw / 4 - 2, _uy - _uh / 4 + _ubob, _ux - _uw / 4 + 2, _uy - _uh / 4 + 4 + _ubob, false);
                draw_rectangle(_ux + _uw / 4 - 2, _uy - _uh / 4 + _ubob, _ux + _uw / 4 + 2, _uy - _uh / 4 + 4 + _ubob, false);
                draw_set_color(c_white);
            }
            if (!_b) {
                draw_set_color(c_gray);
                draw_text(_ux - 22, _uy - _uh / 2 - 14, "MOLDADO");
                draw_set_color(c_white);
            }
            if (_e == current) draw_text(_ux - _uw / 2 - 14, _uy - 6, "<");
            if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
                draw_text(_ux - 4, _uy - _uh / 2 - 28, "v");
        }

        if (_e.hp_shown > 0.5) draw_hp_bar(_ux - 28, _uy + _uh / 2 + 6, 56, 5, _e);
        if (_e.hp > 0) draw_text(_ux - 28, _uy + _uh / 2 + 14, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
        continue;
    }

    // ----- Inimigos normais (e o Python sem sprite) -----
    var _x = 380, _y = 60 + i * 60;
    var _boss = variable_struct_exists(_e, "typed");

    if (_e.hp > 0) {
        // O Python usa a cor do tipo atual; os outros continuam vermelhos
        draw_set_color(_boss ? global.boss_types[_e.type_index].color : c_red);
        draw_rectangle(_x, _y, _x + 24, _y + 32, false);

        // Cauda do Python (um quadradinho por segmento)
        if (_boss) {
            for (var s = 0; s < _e.tail; s++) {
                draw_rectangle(_x + 28 + s * 7, _y + 24, _x + 33 + s * 7, _y + 29, false);
            }
        }

        draw_set_color(c_white);
        if (_e == current) draw_text(_x - 14, _y + 8, "<");
        if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
            draw_text(_x + 4, _y - 14, "v");
    }

    if (_e.hp_shown > 0.5) draw_hp_bar(_x - 20, _y + 36, 70, 5, _e);
    draw_text(_x - 20, _y + 43, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));

    // Tipo atual do Python
    if (_boss && _e.hp > 0) {
        draw_set_color(global.boss_types[_e.type_index].color);
        draw_text(_x - 20, _y + 55, "TIPO: " + global.boss_types[_e.type_index].name);
        draw_set_color(c_white);
    }
}

// Selo da face do dado (o número sorteado e o nome do ataque)
if (roll_active && current.is_dice &&
    (state == BATTLE_STATE.ROLL || state == BATTLE_STATE.DEFENSE || state == BATTLE_STATE.EXECUTE_ACTION)) {
    var _landed = (state != BATTLE_STATE.ROLL) || (roll_timer >= 60);
    var _fn = _landed ? roll_result : roll_face_shown;
    draw_dice_face(268, 100, 40, _fn);
    if (_landed) draw_text(258, 144, dice_faces[roll_result - 1].name);
}

// Menu principal
if (state == BATTLE_STATE.PLAYER_MENU || state == BATTLE_STATE.PLAYER_SKILL) {
    for (var i = 0; i < array_length(menu_options); i++) {
        var _txt = menu_options[i];
        if (i == 3) _txt += " (" + string(global.items.potion.qty) + ")";
        if (i == menu_locked) _txt += " (APAGADA)";

        var _ready = !(i == 4 && energy < energy_max) && (i != menu_locked);
        draw_set_color(_ready ? c_white : c_gray);
        var _cursor = (i == menu_index) ? "> " : "  ";
        draw_text(20, 190 + i * 16, _cursor + _txt);
    }
    draw_set_color(c_white);
}

// Submenu de habilidades
if (state == BATTLE_STATE.PLAYER_SKILL) {
    var _skills = current.skills;
    for (var i = 0; i < array_length(_skills); i++) {
        var _s = _skills[i];
        var _can = (current.mp >= _s.cost);

        draw_set_color(_can ? c_white : c_gray);
        var _cursor = (i == skill_index) ? "> " : "  ";
        draw_text(140, 190 + i * 16, _cursor + _s.name + " (" + string(_s.cost) + " MP)");
    }
    draw_set_color(c_white);
}

// Log e fim de batalha
draw_text(160, 256, log_text);   // y=256 para não encostar no submenu de 4 skills
if (state == BATTLE_STATE.WIN)  draw_text(190, 20, "VITORIA! (Enter)");
if (state == BATTLE_STATE.LOSE) draw_text(190, 20, "DERROTA... (Enter)");

// Barra de energia e combo
var _ex = 300, _ey = 8, _ew = 170, _eh = 8;
draw_set_color(c_dkgray);
draw_rectangle(_ex, _ey, _ex + _ew, _ey + _eh, false);
draw_set_color(energy >= energy_max ? c_orange : c_aqua);
draw_rectangle(_ex, _ey, _ex + _ew * (energy / energy_max), _ey + _eh, false);
draw_set_color(c_white);
draw_rectangle(_ex, _ey, _ex + _ew, _ey + _eh, true);
draw_text(_ex, _ey + 12, "Combo x" + string(combo));
if (energy >= energy_max) draw_text(_ex, _ey + 28, "ESPECIAL PRONTO!");

// Barra de timing (ataque)
if (state == BATTLE_STATE.PLAYER_TIMING) {
    var _bx = 120, _by = 130, _bw = 240, _bh = 12;

    draw_set_color(c_maroon);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
    draw_set_color(c_yellow);
    draw_rectangle(_bx + _bw * 0.35, _by, _bx + _bw * 0.65, _by + _bh, false);
    draw_set_color(c_lime);
    draw_rectangle(_bx + _bw * 0.45, _by, _bx + _bw * 0.55, _by + _bh, false);

    draw_set_color(c_white);
    var _cx = _bx + _bw * timing_pos;
    draw_rectangle(_cx - 1, _by - 4, _cx + 1, _by + _bh + 4, false);
    draw_text(_bx, _by - 24, "ESPACO para atacar na zona verde!");
}

// Defesa ativa (anel que fecha)
if (state == BATTLE_STATE.DEFENSE) {
    var _t = clamp(def_timer / def_hit, 0, 1);
    var _r = lerp(48, 14, _t);
    var _in_window = abs(def_timer - def_hit) <= def_good;

    draw_set_color(c_white);
    draw_circle(def_x, def_y, 14, true);
    draw_set_color(_in_window ? c_lime : c_yellow);
    draw_circle(def_x, def_y, _r, true);

    draw_set_color(c_white);
    draw_text(150, 130, "DEFENDA! (ESPACO)");
}

// Números flutuantes
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var i = 0; i < array_length(popups); i++) {
    var _p = popups[i];
    var _tt = 1 - _p.life / _p.life_max;
    var _scp = 1 + max(0, 0.5 - _tt * 4);
    draw_set_alpha(min(1, _p.life / 15));

    draw_set_color(c_black);
    draw_text_transformed(_p.x + 1, _p.y + 1, _p.text, _scp, _scp, 0);
    draw_set_color(_p.color);
    draw_text_transformed(_p.x, _p.y, _p.text, _scp, _scp, 0);
}
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
// ===== 3o ANDAR: MOLDE, PROPOSTA E CENAS =====
if (molde_on) {
    // Barra de Molde (o oposto da energia)
    var _mx = 110, _my = 8, _mw = 170, _mh = 8;
    var _mf = molde / molde_max;
    draw_set_color(c_dkgray);
    draw_rectangle(_mx, _my, _mx + _mw, _my + _mh, false);
    draw_set_color(_mf > 0.7 ? c_red : (_mf > 0.4 ? c_fuchsia : c_purple));
    draw_rectangle(_mx, _my, _mx + _mw * _mf, _my + _mh, false);
    draw_set_color(c_white);
    draw_rectangle(_mx, _my, _mx + _mw, _my + _mh, true);
    draw_text(_mx, _my + 12, "MOLDE " + string(floor(molde)) + "/" + string(molde_max));
    if (_mf > 0.7 && ((current_time div 300) mod 2) == 0) {
        draw_set_color(c_red);
        draw_text(_mx, _my + 28, "VOCE ESTA SENDO MOLDADA!");
        draw_set_color(c_white);
    }
    if (fase_final) {
        draw_set_color(c_red);
        draw_text(_mx + 120, _my + 12, "FASE FINAL");
        draw_set_color(c_white);
    }

    // A Proposta (menu Aceitar / Recusar)
    if (state == BATTLE_STATE.PROPOSAL) {
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_rectangle(80, 70, 400, 190, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_rectangle(80, 70, 400, 190, true);
        draw_set_halign(fa_center);
        draw_text(240, 84, "URSO: Minha proposta vai ser aceita?");
        draw_text(240, 106, "Venha para a equipe. Pare de lutar.");
        draw_set_color(proposal_index == 0 ? c_yellow : c_white);
        draw_text(240, 142, (proposal_index == 0 ? "> " : "  ") + "Aceitar");
        draw_set_color(proposal_index == 1 ? c_yellow : c_white);
        draw_text(240, 162, (proposal_index == 1 ? "> " : "  ") + "Recusar");
        draw_set_halign(fa_left);
        draw_set_color(c_white);
    }

    // Cenas: derrota por Molde, final ruim e final bom
    var _scene = undefined;
    if (state == BATTLE_STATE.MOLD_END) {
        _scene = [ "O molde se fecha ao redor de Nexa.",
                   "Os circuitos se alinham. As cores se apagam.",
                   "Nexa se molda. Mais uma robo na linha de producao.",
                   "FIM DE JOGO (Enter para tentar de novo)" ];
    } else if (state == BATTLE_STATE.ENDING_BAD) {
        _scene = [ "Nexa aceita a proposta.",
                   "O Urso sorri. A empresa ganha mais uma peca.",
                   "Ninguem foi libertado. Todos continuam moldados.",
                   "FINAL RUIM (Enter para tentar de novo)" ];
    } else if (state == BATTLE_STATE.WIN) {
        var _names = "";
        for (var f = 0; f < array_length(freed_names); f++) _names += ((f > 0) ? ", " : "") + freed_names[f];
        _scene = [ "O Urso cai. O molde se quebra.",
                   "Os robos voltam ao normal.",
                   (freed_count > 0) ? ("Libertados por voce: " + _names) : "Ninguem pode agradecer a tempo...",
                   "VITORIA! (Enter)" ];
    }

    if (!is_undefined(_scene)) {
        draw_set_alpha(min(0.88, scene_timer / 60));
        draw_set_color(c_black);
        draw_rectangle(0, 0, 480, 270, false);
        draw_set_alpha(1);
        if (state != BATTLE_STATE.WIN && party[0].sprite != -1)
            draw_sprite_ext(party[0].sprite, 0, 240, 70, 2, 2, 0, c_gray, 1);   // Nexa apagada
        draw_set_halign(fa_center);
        for (var k = 0; k < array_length(_scene); k++) {
            if (scene_timer > 60 + k * 90) {
                draw_set_color((k == array_length(_scene) - 1) ? c_yellow : c_white);
                draw_text(240, 130 + k * 20, _scene[k]);
            }
        }
        draw_set_halign(fa_left);
        draw_set_color(c_white);
    }
}
matrix_set(matrix_world, matrix_build_identity());