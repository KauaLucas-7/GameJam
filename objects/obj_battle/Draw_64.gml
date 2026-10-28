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
            draw_sprite(_u.sprite, _frame, _x, _y);
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

    // ----- Inimigos normais -----
    var _x = 380, _y = 60 + i * 60;

    if (_e.hp > 0) {
        draw_set_color(c_red);
        draw_rectangle(_x, _y, _x + 24, _y + 32, false);
        draw_set_color(c_white);
        if (_e == current) draw_text(_x - 14, _y + 8, "<");
        if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
            draw_text(_x + 4, _y - 14, "v");
    }

    if (_e.hp_shown > 0.5) draw_hp_bar(_x - 20, _y + 36, 70, 5, _e);
    draw_text(_x - 20, _y + 43, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
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
draw_text(160, 245, log_text);
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

matrix_set(matrix_world, matrix_build_identity());