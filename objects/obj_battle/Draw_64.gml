// Cenário da luta
desenhar_fundo();

// ===== Cutscene de abertura: Nexa VS chefe =====
if (state == BATTLE_STATE.INTRO) {
	var _t = intro_t;
	var _fim = (_t > 140) ? ease_in((_t - 140) / 30) : 0;   // sai de cena no final

	// barras de cinema
	var _bar = 34 * ease_out(_t / 18) * (1 - _fim);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, _bar, false);
	draw_rectangle(0, 270 - _bar, 480, 270, false);

	// faixa diagonal com a cor do chefe
	draw_set_alpha(0.3 * (1 - _fim));
	draw_set_color(intro_info.cor);
	var _dw = 300 * ease_out((_t - 20) / 20);
	draw_triangle(480 - _dw, 270, 480, 270, 480, 270 - _dw * 0.6, false);
	draw_set_alpha(1);

	// Nexa entra pela esquerda, o chefe pela direita
	var _nx = lerp(-80, 120, ease_out(_t / 26)) - 200 * _fim;
	var _bx = lerp(560, 360, ease_out(_t / 26)) + 200 * _fim;
	cyber_draw(spr_Nexa, floor(_t / 10) mod sprite_get_number(spr_Nexa), _nx, 140, 2, c_white, 1);
	if (intro_info.spr != -1) {
		draw_sprite_ext(intro_info.spr, floor(_t / 10) mod sprite_get_number(intro_info.spr), _bx, 132,
		                intro_info.esc, intro_info.esc, 0, c_white, 1);
	}

	// "VS" estourando no centro
	if (_t > 30) {
		var _vs = ease_back((_t - 30) / 14) * (1 - _fim);
		draw_set_halign(fa_center); draw_set_valign(fa_middle);
		draw_set_color(c_black);
		draw_text_transformed(242, 122, "VS", 3 * _vs, 3 * _vs, -8);
		draw_set_color(c_yellow);
		draw_text_transformed(240, 120, "VS", 3 * _vs, 3 * _vs, -8);
		draw_set_halign(fa_left); draw_set_valign(fa_top);
	}

	// clarão quando o VS bate
	if (_t >= 30 && _t < 42) {
		draw_set_alpha(1 - (_t - 30) / 12);
		draw_set_color(c_white);
		draw_rectangle(0, 0, 480, 270, false);
		draw_set_alpha(1);
	}

	// nome e título do chefe
	if (_t > 50) {
		var _na = ease_out((_t - 50) / 20) * (1 - _fim);
		draw_set_alpha(_na);
		draw_set_halign(fa_right);
		draw_set_color(intro_info.cor);
		draw_text_transformed(466 + 20 * (1 - _na), 196, texto_seguro(intro_info.nome), 1.6, 1.6, 0);
		draw_set_color(c_white);
		draw_text(466 + 20 * (1 - _na), 222, texto_seguro(intro_info.titulo));
		draw_set_halign(fa_left);
		draw_set_color(c_aqua);
		draw_text_transformed(14 - 20 * (1 - _na), 196, "NEXA", 1.6, 1.6, 0);
		draw_set_alpha(1);
	}
	if (_t > 60) {
		draw_set_alpha(0.5 + 0.5 * sin(current_time / 150));
		draw_set_color(c_ltgray);
		draw_text(14, 256, "[ENTER] lutar");
		draw_set_alpha(1);
	}
	draw_set_color(c_white);
	exit;
}

// Tremor
matrix_set(matrix_world, matrix_build(shake_x, shake_y, 0, 0, 0, 0, 1, 1, 1));

draw_set_color(c_white);
if (global.ver_paredes) draw_text(4, 4, "Estado: " + string(state));   // depuração (F1)

// Aliados (esquerda): a Nexa com pose animada (scr_batalha_fx)
var _u0 = party[0];
if (_u0.hp > 0) {
    var _tint = molde_on ? merge_colour(c_white, c_gray, 0.8 * (molde / molde_max)) : c_white;
    nexa_desenhar_batalha(_tint);
    // indicador de turno: losango girando acima da cabeça
    if (_u0 == current && (state == BATTLE_STATE.PLAYER_MENU || state == BATTLE_STATE.PLAYER_SKILL)) {
        var _ay = NEXA_BY - 58 + sin(current_time / 200) * 3;
        draw_set_color(c_aqua);
        draw_triangle(NEXA_BX - 5, _ay, NEXA_BX + 5, _ay, NEXA_BX, _ay + 7, false);
        draw_set_color(c_white);
    }
}
var _ps = status_stacks(_u0, "poison");
if (_ps > 0 && _u0.hp > 0) {
    draw_set_color(make_colour_rgb(30, 60, 30));
    draw_roundrect(NEXA_BX - 26, NEXA_BY + 48, NEXA_BX + 26, NEXA_BY + 60, false);
    draw_set_color(c_lime);
    draw_text_transformed(NEXA_BX - 22, NEXA_BY + 49, "VENENO x" + string(_ps), 0.7, 0.7, 0);
    draw_set_color(c_white);
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
    var _po = inimigo_pose(_e, i);   // respiração, avanço no ataque, recuo e clarão ao levar dano

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
            draw_sprite_ext(_e.sprite, 0, _dx + _po.x, _dy + _oy + _po.y, _sc * _po.sx, _sc * _po.sy, _ang + _po.ang, _col, 1);
            sprite_clarao(_e.sprite, 0, _dx + _po.x, _dy + _oy + _po.y, _sc * _po.sx, _sc * _po.sy, _ang + _po.ang, _po.flash);

            if (boss_exposed)    { draw_set_color(c_yellow); draw_text(_dx - 28, _dy - 60, "EXPOSTO!"); }
            if (boss_recharging) { draw_set_color(c_gray);   draw_text(_dx - 40, _dy - 60, "RECARREGANDO"); }
            draw_set_color(c_white);

            if (_e == current) marca_turno(_dx - 50, _dy - 6);
            if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
                seta_alvo(_dx - 4, _dy - 56);
        }

        if (_e.hp_shown > 0.5) draw_hp_bar(_dx - 40, _dy + 42, 80, 6, _e);
        draw_text(_dx - 40, _dy + 50, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
        continue;
    }

    // ----- BOSS PYTHON (com sprite) -----
    if (variable_struct_exists(_e, "typed") && _e.sprite != -1) {
        var _px = 370, _py = 108;
        var _pscale = 0.95;   // tamanho do sprite (proporcional à Nexa)
        var _tcol = global.boss_types[_e.type_index].color;

        if (_e.hp > 0) {
            var _pfr  = floor(current_time / 1000 * 6) mod sprite_get_number(_e.sprite);
            var _bob  = sin(current_time / 400) * 3;               // flutua parado
            var _tint = merge_colour(c_white, _tcol, 0.45);        // tinge de leve com a cor do tipo
            draw_sprite_ext(_e.sprite, _pfr, _px + _po.x, _py + _po.y, _pscale * _po.sx, _pscale * _po.sy, _po.ang * 2, _tint, 1);
            sprite_clarao(_e.sprite, _pfr, _px + _po.x, _py + _po.y, _pscale * _po.sx, _pscale * _po.sy, _po.ang * 2, _po.flash);

            // cauda: um quadradinho por segmento
            draw_set_color(_tcol);
            for (var s = 0; s < _e.tail; s++) {
                draw_rectangle(_px - 36 + s * 10, _py - 62, _px - 30 + s * 10, _py - 57, false);   // acima da cabeça
            }
            draw_set_color(c_white);

            if (_e == current) marca_turno(_px - 70, _py - 6);
            if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
                seta_alvo(_px - 4, _py - 84);
        }

        if (_e.hp_shown > 0.5) draw_hp_bar(_px - 40, _py + 60, 80, 6, _e);
        draw_text(_px - 40, _py + 68, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
        if (_e.hp > 0) {
            draw_set_color(_tcol);
            draw_text(_px - 40, _py - 76, "TIPO: " + global.boss_types[_e.type_index].name);   // acima da cabeça
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

        // Urso com sprite: 160x200 a 55% do tamanho
        var _sc = 1;
        if (_b && _e.sprite != -1) { _sc = 0.65; _uw = 104; _uh = 130; }

        if (_e.hp > 0) {
            if (_e.sprite != -1) {
                // Idle (4 frames por segundo) ou, durante o ataque do Urso, a animação de golpe
                var _spr = _e.sprite;
                var _fr  = floor(current_time / 1000 * 4) mod sprite_get_number(_spr);

                if (_b && variable_struct_exists(_e, "sprite_attack") && _e == current &&
                    (state == BATTLE_STATE.DEFENSE || state == BATTLE_STATE.EXECUTE_ACTION)) {
                    _spr = _e.sprite_attack;
                    _fr = (state == BATTLE_STATE.DEFENSE) ? clamp(floor(def_timer / (def_hit / 3)), 0, 2) : 3;
                }
                draw_sprite_ext(_spr, _fr, _ux + _po.x, _uy + _po.y, _sc * _po.sx, _sc * _po.sy, _po.ang, c_white, 1);
                sprite_clarao(_spr, _fr, _ux + _po.x, _uy + _po.y, _sc * _po.sx, _sc * _po.sy, _po.ang, _po.flash);
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
            if (_e == current) marca_turno(_ux - _uw / 2 - 14, _uy - 6);
            if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
                seta_alvo(_ux - 4, _uy - _uh / 2 - 28);
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
        if (_e == current) marca_turno(_x - 14, _y + 8);
        if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
            seta_alvo(_x + 4, _y - 14);
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

// ===== Efeitos das ações (projéteis, cortes, escudos, faíscas) =====
fx_desenhar();

// ===================================================================
//  PAINEL DE BATALHA (comandos, habilidades, status e mensagens)
// ===================================================================
var _pnl_y1 = 194, _pnl_y2 = 266;
var _t_ms = current_time;
var _menu = (state == BATTLE_STATE.PLAYER_MENU);
var _skl  = (state == BATTLE_STATE.PLAYER_SKILL);
var _alv  = (state == BATTLE_STATE.PLAYER_TARGET);
menu_anim  = lerp(menu_anim, menu_index, 0.3);
skill_anim = lerp(skill_anim, skill_index, 0.3);

// fundo do painel
draw_set_alpha(0.92);
draw_set_color(make_colour_rgb(9, 11, 22));
draw_roundrect(6, _pnl_y1, 474, _pnl_y2, false);
draw_set_alpha(1);
draw_set_color(make_colour_rgb(40, 90, 120));
draw_roundrect(6, _pnl_y1, 474, _pnl_y2, true);
draw_set_color(merge_colour(c_aqua, c_white, 0.5 + 0.5 * sin(_t_ms / 400)));
draw_line(16, _pnl_y1, 120, _pnl_y1);

// ----- Coluna de comandos -----
var _cx1 = 12, _cy1 = _pnl_y1 + 6, _row = 12;
var _cmd_desc = [
	"Golpe com ritmo: aperte ESPAÇO no centro da barra.",
	"Reduz o dano pela metade até o seu próximo turno.",
	"Gasta MP. O elemento certo causa dano extra.",
	"Poção: recupera " + string(global.items.potion.heal) + " HP.",
	(energy >= energy_max) ? "Energia cheia! Atinge todos os inimigos com força máxima." : "Encha a energia com acertos perfeitos para liberar."
];
var _ativo = (_menu || _skl || _alv);
for (var i = 0; i < array_length(menu_options); i++) {
	var _ry = _cy1 + i * _row;
	var _ok = !(i == 4 && energy < energy_max) && (i != menu_locked) && !(i == 3 && global.items.potion.qty <= 0);
	var _sel = (_menu && i == menu_index);
	// barra de seleção deslizando
	if (_menu && i == 0) {
		var _sy = _cy1 + menu_anim * _row;
		draw_set_alpha(0.85);
		draw_rectangle_colour(_cx1, _sy - 1, _cx1 + 118, _sy + _row - 1, make_colour_rgb(20, 120, 150), make_colour_rgb(10, 30, 50), make_colour_rgb(10, 30, 50), make_colour_rgb(20, 120, 150), false);
		draw_set_alpha(1);
		draw_set_color(c_aqua);
		draw_rectangle(_cx1, _sy - 1, _cx1 + 1, _sy + _row - 1, false);
	}
	var _cor = _ok ? (_sel ? c_white : make_colour_rgb(170, 185, 205)) : make_colour_rgb(70, 75, 90);
	if (!_ativo) _cor = make_colour_rgb(70, 75, 90);
	icone_comando(i, _cx1 + 9 + (_sel ? 2 : 0), _ry + 5, (i == 4 && energy >= energy_max) ? merge_colour(c_orange, c_yellow, 0.5 + 0.5 * sin(_t_ms / 100)) : _cor);
	draw_set_color(_cor);
	var _txt = menu_options[i];
	if (i == 3) _txt += " x" + string(global.items.potion.qty);
	if (i == menu_locked) _txt = "APAGADA";
	draw_text_transformed(_cx1 + 20 + (_sel ? 3 : 0), _ry, texto_seguro(_txt), 0.8, 0.8, 0);
}

// divisória
draw_set_color(make_colour_rgb(40, 70, 90));
draw_line(136, _pnl_y1 + 6, 136, _pnl_y2 - 6);

// ----- Área da direita -----
var _ix = 144, _iy = _pnl_y1 + 5;
var _eu = party[0];

// status da Nexa (sempre visível)
draw_set_color(c_aqua);
draw_text_transformed(_ix, _iy, "NEXA", 0.8, 0.8, 0);
draw_set_color(c_white);
draw_text_transformed(_ix + 38, _iy + 1, "HP", 0.6, 0.6, 0);
draw_hp_bar(_ix + 52, _iy + 3, 90, 5, _eu);
draw_text_transformed(_ix + 146, _iy + 1, string(_eu.hp) + "/" + string(_eu.hp_max), 0.6, 0.6, 0);
draw_text_transformed(_ix + 192, _iy + 1, "MP", 0.6, 0.6, 0);
draw_set_color(make_colour_rgb(30, 30, 60));
draw_rectangle(_ix + 206, _iy + 3, _ix + 266, _iy + 8, false);
draw_set_color(make_colour_rgb(110, 140, 255));
draw_rectangle(_ix + 206, _iy + 3, _ix + 206 + 60 * (_eu.mp / max(1, _eu.mp_max)), _iy + 8, false);
draw_set_color(c_white);
draw_text_transformed(_ix + 270, _iy + 1, string(_eu.mp) + "/" + string(_eu.mp_max), 0.6, 0.6, 0);
if (atk_debuff > 0) {
	draw_set_color(c_red);
	draw_text_transformed(_ix + 300, _iy + 1, "ATK-30%", 0.6, 0.6, 0);
}
draw_set_color(make_colour_rgb(40, 70, 90));
draw_line(_ix, _iy + 13, 466, _iy + 13);

var _dy = _iy + 18;
if (_menu) {
	// descrição do comando escolhido
	draw_set_color(c_yellow);
	draw_text_transformed(_ix, _dy, texto_seguro(menu_options[menu_index]), 0.9, 0.9, 0);
	draw_set_color(make_colour_rgb(200, 205, 220));
	draw_text_ext_transformed(_ix, _dy + 13, texto_seguro((menu_index == menu_locked) ? "Apagada pelo DROP COLUMN neste turno." : _cmd_desc[menu_index]), 14, 380, 0.75, 0.75, 0);
	draw_set_color(c_gray);
	draw_text_transformed(_ix, _pnl_y2 - 12, texto_seguro("[Cima/Baixo] escolher   [Enter] confirmar"), 0.6, 0.6, 0);
}
else if (_skl) {
	// lista de habilidades (esquerda) + detalhes (direita)
	var _skills = current.skills;
	var _n = array_length(_skills);
	var _srow = (_n > 4) ? 9 : 10;
	var _sy2 = _dy - 1 + skill_anim * _srow;
	draw_set_alpha(0.8);
	draw_rectangle_colour(_ix, _sy2, _ix + 150, _sy2 + _srow, make_colour_rgb(20, 120, 150), make_colour_rgb(10, 30, 50), make_colour_rgb(10, 30, 50), make_colour_rgb(20, 120, 150), false);
	draw_set_alpha(1);
	for (var i = 0; i < _n; i++) {
		var _s = _skills[i];
		var _can = (current.mp >= _s.cost);
		draw_set_color(_s.heal ? c_lime : cor_elemento(_s.element));
		draw_circle(_ix + 5, _dy + i * _srow + 4, 3, false);
		draw_set_color(_can ? ((i == skill_index) ? c_white : make_colour_rgb(170, 185, 205)) : make_colour_rgb(80, 80, 95));
		draw_text_transformed(_ix + 12, _dy + i * _srow, texto_seguro(_s.name), 0.7, 0.7, 0);
		draw_set_halign(fa_right);
		draw_text_transformed(_ix + 148, _dy + i * _srow, string(_s.cost) + " MP", 0.65, 0.65, 0);
		draw_set_halign(fa_left);
	}
	var _ss = _skills[skill_index];
	var _dx2 = _ix + 160;
	var _ecor = _ss.heal ? c_lime : cor_elemento(_ss.element);
	draw_set_color(_ecor);
	draw_roundrect(_dx2, _dy, _dx2 + 160, _dy + 12, false);
	draw_set_color(c_black);
	var _enome = _ss.heal ? "CURA" : ((_ss.element == "lightning") ? "RAIO" : ((_ss.element == "fire") ? "FOGO" : "GELO"));
	draw_text_transformed(_dx2 + 4, _dy + 1, _enome, 0.7, 0.7, 0);
	draw_set_color(c_white);
	draw_text_transformed(_dx2, _dy + 16, (_ss.heal ? "Cura " : "Poder ") + string(_ss.power) + "   Custo " + string(_ss.cost) + " MP", 0.7, 0.7, 0);
	// quem é fraco a este elemento?
	var _fraco = "";
	if (!_ss.heal) for (var k = 0; k < array_length(enemies); k++) if (enemies[k].hp > 0 && enemies[k].weak_to == _ss.element) _fraco = enemies[k].name;
	draw_set_color((_fraco != "") ? c_yellow : c_gray);
	draw_text_transformed(_dx2, _dy + 28, texto_seguro((_fraco != "") ? ("Eficaz contra " + _fraco + "!") : (_ss.heal ? "Recupera HP da Nexa." : "Ninguém aqui é fraco a isso.")), 0.65, 0.65, 0);
	draw_set_color(c_gray);
	draw_text_transformed(_ix, _pnl_y2 - 12, texto_seguro("[Enter] usar   [Esc] voltar"), 0.6, 0.6, 0);
}
else if (_alv) {
	var _al = alive_list(enemies);
	alvo_anim = lerp(alvo_anim, target_index, 0.3);
	draw_set_color(c_yellow);
	draw_text_transformed(_ix, _dy, "ESCOLHA O ALVO", 0.9, 0.9, 0);
	if (array_length(_al) > 0) {
		var _tg = _al[clamp(target_index, 0, array_length(_al) - 1)];
		draw_set_color(c_white);
		draw_text_transformed(_ix, _dy + 14, texto_seguro(_tg.name + "  HP " + string(_tg.hp) + "/" + string(_tg.hp_max)), 0.8, 0.8, 0);
	}
	draw_set_color(c_gray);
	draw_text_transformed(_ix, _pnl_y2 - 12, texto_seguro("[Esq/Dir] trocar   [Enter] confirmar   [Esc] voltar"), 0.6, 0.6, 0);
}
else {
	// mensagens da luta
	draw_set_color(c_white);
	draw_text_ext_transformed(_ix, _dy + 2, texto_seguro(log_text), 14, 380, 0.85, 0.85, 0);
	if (state == BATTLE_STATE.WIN || state == BATTLE_STATE.LOSE) {
		draw_set_alpha(0.5 + 0.5 * sin(_t_ms / 150));
		draw_set_color((state == BATTLE_STATE.WIN) ? c_lime : c_red);
		draw_text_transformed(_ix, _pnl_y2 - 13, (state == BATTLE_STATE.WIN) ? "VITORIA!  [Enter]" : "DERROTA...  [Enter]", 0.8, 0.8, 0);
		draw_set_alpha(1);
	}
}
// mensagem curta acima do painel durante os menus
if ((_menu || _skl || _alv) && log_text != "") {
	var _lt = texto_seguro(log_text);
	var _lw = min(440, string_width(_lt) * 0.75 + 16);
	draw_set_alpha(0.7);
	draw_set_color(c_black);
	draw_roundrect(240 - _lw / 2, 178, 240 + _lw / 2, 191, false);
	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(210, 215, 228));
	draw_set_halign(fa_center);
	draw_text_transformed(240, 179, _lt, 0.75, 0.75, 0);
	draw_set_halign(fa_left);
}

// ----- Energia e combo (topo direito) -----
var _ex = 300, _ey = 6, _seg = 10, _sw = 15;
var _cheia = energy >= energy_max;
draw_set_alpha(0.8);
draw_set_color(make_colour_rgb(9, 11, 22));
draw_roundrect(_ex - 4, _ey - 2, 476, _ey + 26, false);
draw_set_alpha(1);
draw_set_color(_cheia ? c_orange : c_aqua);
draw_text_transformed(_ex, _ey, "ENERGIA", 0.6, 0.6, 0);
for (var s = 0; s < _seg; s++) {
	var _sx = _ex + 44 + s * (_sw + 2);
	var _fill = clamp(energy / energy_max * _seg - s, 0, 1);
	draw_set_color(make_colour_rgb(25, 35, 50));
	draw_rectangle(_sx, _ey + 1, _sx + _sw, _ey + 7, false);
	if (_fill > 0) {
		draw_set_color(_cheia ? merge_colour(c_orange, c_yellow, 0.5 + 0.5 * sin(_t_ms / 90 + s)) : c_aqua);
		draw_rectangle(_sx, _ey + 1, _sx + _sw * _fill, _ey + 7, false);
	}
}
draw_set_color(merge_colour(c_white, c_orange, min(1, combo / 5)));
draw_text_transformed(_ex, _ey + 12, "COMBO x" + string(combo), 0.7, 0.7, 0);
if (_cheia) {
	draw_set_alpha(0.5 + 0.5 * sin(_t_ms / 120));
	draw_set_color(c_yellow);
	draw_set_halign(fa_right);
	draw_text_transformed(472, _ey + 12, "ESPECIAL PRONTO!", 0.7, 0.7, 0);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}

// ----- Barra de ritmo (ataque) -----
if (state == BATTLE_STATE.PLAYER_TIMING && acao.tipo == "") {
	var _bx = 110, _by = 140, _bw = 260, _bh = 12;
	draw_set_alpha(0.85);
	draw_set_color(make_colour_rgb(9, 11, 22));
	draw_roundrect(_bx - 10, _by - 22, _bx + _bw + 10, _by + _bh + 10, false);
	draw_set_alpha(1);
	draw_rectangle_colour(_bx, _by, _bx + _bw * 0.5, _by + _bh, make_colour_rgb(110, 20, 30), make_colour_rgb(230, 200, 40), make_colour_rgb(230, 200, 40), make_colour_rgb(110, 20, 30), false);
	draw_rectangle_colour(_bx + _bw * 0.5, _by, _bx + _bw, _by + _bh, make_colour_rgb(230, 200, 40), make_colour_rgb(110, 20, 30), make_colour_rgb(110, 20, 30), make_colour_rgb(230, 200, 40), false);
	draw_set_color(c_lime);
	draw_rectangle(_bx + _bw * 0.45, _by, _bx + _bw * 0.55, _by + _bh, false);
	draw_set_color(c_white);
	draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
	// cursor brilhante com rastro
	var _cx = _bx + _bw * timing_pos;
	for (var k = 1; k <= 4; k++) {
		draw_set_alpha(0.25 / k);
		draw_rectangle(_cx - timing_dir * k * 4 - 1, _by - 2, _cx - timing_dir * k * 4 + 1, _by + _bh + 2, false);
	}
	draw_set_alpha(1);
	draw_triangle(_cx - 5, _by - 7, _cx + 5, _by - 7, _cx, _by - 1, false);
	draw_triangle(_cx - 5, _by + _bh + 7, _cx + 5, _by + _bh + 7, _cx, _by + _bh + 1, false);
	draw_rectangle(_cx - 1, _by - 2, _cx + 1, _by + _bh + 2, false);
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(240, _by - 19, texto_seguro("ESPAÇO no centro!"), 0.75, 0.75, 0);
	draw_set_halign(fa_left);
}

// ----- Defesa ativa: anel que fecha sobre a Nexa -----
if (state == BATTLE_STATE.DEFENSE) {
	var _t = clamp(def_timer / def_hit, 0, 1);
	var _r = lerp(56, 18, _t);
	var _jan = abs(def_timer - def_hit) <= def_good + cyber_total("def_window");
	draw_set_color(c_white);
	draw_circle(def_x, def_y, 18, true);
	draw_set_color(_jan ? c_lime : c_yellow);
	draw_circle(def_x, def_y, _r, true);
	draw_circle(def_x, def_y, _r + 1, true);
	draw_set_alpha(0.15);
	draw_circle(def_x, def_y, _r, false);
	draw_set_alpha(0.5 + 0.5 * sin(current_time / 80));
	draw_set_halign(fa_center);
	draw_set_color(_jan ? c_lime : c_yellow);
	draw_text_transformed(def_x, def_y - 66, texto_seguro("DEFENDA! [ESPAÇO]"), 0.8, 0.8, 0);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// ----- Golpe especial: escurece a tela e dá um clarão no impacto -----
if (especial_escuro > 0) {
	draw_set_alpha(0.45 * especial_escuro);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(1);
	nexa_desenhar_batalha(c_white);   // a Nexa fica por cima do escuro
	fx_desenhar();
}
if (especial_clarao > 0) {
	draw_set_alpha(especial_clarao * 0.8);
	draw_set_color(c_white);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(1);
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
                   "O Urso sorri. A empresa ganha mais uma peca." ];   // continua em rm_final_ruim
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
            cyber_draw(party[0].sprite, 0, 240, 60, 1.5, c_gray);   // era (…, 240, 70, 2, c_gray)
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
// ===== Dica de tutorial (pausa) =====
if (dica != "") {
	var _d = dica_texto(dica);
	var _a = ease_out(dica_t / 14);
	draw_set_alpha(0.55 * _a);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	var _py = 40 + 16 * (1 - _a);
	draw_set_alpha(0.95 * _a);
	draw_set_color(make_colour_rgb(10, 14, 28));
	draw_roundrect(70, _py, 410, _py + 150, false);
	draw_set_alpha(_a);
	draw_set_color(c_aqua);
	draw_roundrect(70, _py, 410, _py + 150, true);
	draw_text_transformed(82, _py + 6, "DICA DE BATALHA", 0.7, 0.7, 0);
	draw_set_color(c_yellow);
	draw_text(82, _py + 18, texto_seguro(_d[0]));
	draw_set_color(c_white);
	var _yy = _py + 38;
	for (var k = 1; k < array_length(_d); k++) {
		draw_text_ext(82, _yy, texto_seguro(_d[k]), 12, 316);
		_yy += 4 + string_height_ext(texto_seguro(_d[k]), 12, 316);
	}
	if (dica_t > 20) {
		draw_set_alpha(_a * (0.5 + 0.5 * sin(current_time / 150)));
		draw_set_color(c_ltgray);
		draw_set_halign(fa_right);
		draw_text(402, _py + 134, "[ENTER] entendi");
		draw_set_halign(fa_left);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}
