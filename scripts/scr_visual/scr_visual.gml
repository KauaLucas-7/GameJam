// =====================================================================
//  VISUAL: personagens desenhados com sprites/formas, retratos e easing
// =====================================================================

// ---------------------------------------------------------------------
//  Tamanho dos personagens no mapa, proporcional à arte de cada sala.
//  Os andares mostram a sala inteira (zoom menor), então os personagens
//  são desenhados maiores; nas escadas a tela já está mais "perto".
//  A posição (x, y) continua a mesma: só o desenho cresce para cima,
//  com os pés fixos em y + 28. A colisão usa só os pés (spr_mask_pes).
// ---------------------------------------------------------------------
function escala_sala() {
	switch (room) {
		case rm_corredor1:
		case rm_corredor2: return 1.15;
	}
	return 2.2;
}

// Desenha formas em escala em volta de um ponto (âncora nos pés)
function escala_inicio(_x, _ay, _s) {
	matrix_set(matrix_world, matrix_multiply(matrix_build(-_x, -_ay, 0, 0, 0, 0, 1, 1, 1),
	                                         matrix_build(_x, _ay, 0, 0, 0, 0, _s, _s, 1)));
}
function escala_fim() {
	matrix_set(matrix_world, matrix_build_identity());
}

// Suavizações para animações (t de 0 a 1)
function ease_out(_t)    { _t = clamp(_t, 0, 1); return 1 - power(1 - _t, 3); }
function ease_in(_t)     { _t = clamp(_t, 0, 1); return _t * _t * _t; }
function ease_back(_t)   { _t = clamp(_t, 0, 1); var _c = 1.70158; return 1 + (_c + 1) * power(_t - 1, 3) + _c * power(_t - 1, 2); }

// ---------------------------------------------------------------------
//  Robô do escritório (mesmo visual do obj_npc), em qualquer escala.
//  _busto = true desenha só cabeça e tronco (retratos).
// ---------------------------------------------------------------------
function desenhar_robo(_x, _y, _s, _d, _anim = 0, _busto = false, _a = 1) {
	var _b = round(sin(_anim * 0.05));
	var _f = variable_struct_exists(_d, "genero") && _d.genero == "f";
	draw_set_alpha(_a);

	if (!_busto) {
		draw_set_alpha(0.3 * _a);
		draw_set_color(c_black);
		draw_ellipse(_x - 12 * _s, _y + 24 * _s, _x + 12 * _s, _y + 31 * _s, false);
		draw_set_alpha(_a);
	}

	if (_f) {
		if (!_busto) {
			draw_set_color(c_gray);
			draw_rectangle(_x - 6 * _s, _y + 12 * _s, _x - 3 * _s, _y + 28 * _s, false);
			draw_rectangle(_x + 3 * _s, _y + 12 * _s, _x + 6 * _s, _y + 28 * _s, false);
			draw_set_color(_d.cor);
			draw_triangle(_x - 12 * _s, _y + 16 * _s, _x + 12 * _s, _y + 16 * _s, _x, _y + (-2 + _b) * _s, false);
			draw_rectangle(_x - 9 * _s, _y + (4 + _b) * _s, _x + 9 * _s, _y + 16 * _s, false);
		}
		draw_set_color(_d.cor);
		draw_roundrect(_x - 9 * _s, _y + (-12 + _b) * _s, _x + 9 * _s, _y + (6 + _b) * _s, false);
		draw_set_color(c_silver);
		draw_rectangle(_x - 3 * _s, _y + (-12 + _b) * _s, _x + 3 * _s, _y + (-8 + _b) * _s, false);
		var _cab = variable_struct_exists(_d, "cabelo") ? _d.cabelo : c_dkgray;
		draw_set_color(_cab);
		draw_roundrect(_x - 11 * _s, _y + (-32 + _b) * _s, _x + 11 * _s, _y + (-16 + _b) * _s, false);
		draw_rectangle(_x + 6 * _s, _y + (-22 + _b) * _s, _x + 11 * _s, _y + (-6 + _b) * _s, false);
		draw_set_color(c_silver);
		draw_roundrect(_x - 8 * _s, _y + (-29 + _b) * _s, _x + 7 * _s, _y + (-13 + _b) * _s, false);
		draw_set_color(_d.visor);
		draw_rectangle(_x - 6 * _s, _y + (-24 + _b) * _s, _x + 5 * _s, _y + (-20 + _b) * _s, false);
		draw_circle(_x - 9 * _s, _y + (-17 + _b) * _s, max(1, _s), false);
	} else {
		if (!_busto) {
			draw_set_color(c_dkgray);
			draw_rectangle(_x - 8 * _s, _y + 9 * _s, _x - 2 * _s, _y + 28 * _s, false);
			draw_rectangle(_x + 2 * _s, _y + 9 * _s, _x + 8 * _s, _y + 28 * _s, false);
		}
		draw_set_color(_d.cor);
		draw_roundrect(_x - 12 * _s, _y + (-12 + _b) * _s, _x + 12 * _s, _y + 12 * _s, false);
		draw_set_color(c_white);
		draw_triangle(_x - 4 * _s, _y + (-12 + _b) * _s, _x + 4 * _s, _y + (-12 + _b) * _s, _x, _y + (-6 + _b) * _s, false);
		draw_set_color(c_red);
		draw_triangle(_x - 2 * _s, _y + (-8 + _b) * _s, _x + 2 * _s, _y + (-8 + _b) * _s, _x, _y + (4 + _b) * _s, false);
		draw_set_color(c_silver);
		draw_roundrect(_x - 9 * _s, _y + (-30 + _b) * _s, _x + 9 * _s, _y + (-13 + _b) * _s, false);
		draw_set_color(_d.visor);
		draw_rectangle(_x - 6 * _s, _y + (-25 + _b) * _s, _x + 6 * _s, _y + (-20 + _b) * _s, false);
		draw_set_color(c_gray);
		draw_line_width(_x, _y + (-30 + _b) * _s, _x, _y + (-35 + _b) * _s, max(1, _s * 0.8));
		draw_circle(_x, _y + (-36 + _b) * _s, 2 * _s, false);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// ---------------------------------------------------------------------
//  A mesma pessoa, já 100% humana (cutscene final)
// ---------------------------------------------------------------------
function cor_cabelo_humano(_c) {
	switch (_c) {
		case c_olive:  return make_colour_rgb(150, 105, 55);   // castanho claro
		case c_gray:   return make_colour_rgb(175, 175, 182);  // grisalho
		case c_maroon: return make_colour_rgb(125, 45, 30);    // ruivo escuro
		case c_black:  return make_colour_rgb(22, 20, 26);     // preto
	}
	return make_colour_rgb(55, 38, 28);                          // castanho escuro
}

function cor_pele(_nome) {
	var _tons = [make_colour_rgb(241, 194, 160), make_colour_rgb(198, 134, 66), make_colour_rgb(141, 85, 36),
	             make_colour_rgb(224, 172, 105), make_colour_rgb(255, 219, 172)];
	var _h = 0;
	for (var i = 1; i <= string_length(_nome); i++) _h += ord(string_char_at(_nome, i));
	return _tons[_h mod array_length(_tons)];
}

function desenhar_humana(_x, _y, _s, _d, _anim = 0, _a = 1) {
	var _b = round(sin(_anim * 0.05));
	var _pele = cor_pele(_d.nome);
	var _cab = cor_cabelo_humano(variable_struct_exists(_d, "cabelo") ? _d.cabelo : c_dkgray);
	var _roupa = merge_colour(_d.cor, c_white, 0.25);

	draw_set_alpha(0.3 * _a);
	draw_set_color(c_black);
	draw_ellipse(_x - 12 * _s, _y + 24 * _s, _x + 12 * _s, _y + 31 * _s, false);
	draw_set_alpha(_a);

	// cabelo comprido (atrás)
	draw_set_color(_cab);
	draw_roundrect(_x - 10 * _s, _y + (-31 + _b) * _s, _x + 10 * _s, _y + (-4 + _b) * _s, false);
	// pernas e sapatos
	draw_set_color(_pele);
	draw_rectangle(_x - 6 * _s, _y + 12 * _s, _x - 3 * _s, _y + 26 * _s, false);
	draw_rectangle(_x + 3 * _s, _y + 12 * _s, _x + 6 * _s, _y + 26 * _s, false);
	draw_set_color(c_black);
	draw_rectangle(_x - 7 * _s, _y + 26 * _s, _x - 2 * _s, _y + 28 * _s, false);
	draw_rectangle(_x + 2 * _s, _y + 26 * _s, _x + 7 * _s, _y + 28 * _s, false);
	// saia/vestido com a cor da pessoa
	draw_set_color(_d.cor);
	draw_triangle(_x - 12 * _s, _y + 16 * _s, _x + 12 * _s, _y + 16 * _s, _x, _y + (-2 + _b) * _s, false);
	draw_rectangle(_x - 9 * _s, _y + (4 + _b) * _s, _x + 9 * _s, _y + 16 * _s, false);
	// blusa e braços
	draw_set_color(_roupa);
	draw_roundrect(_x - 9 * _s, _y + (-12 + _b) * _s, _x + 9 * _s, _y + (6 + _b) * _s, false);
	draw_set_color(_pele);
	draw_rectangle(_x - 12 * _s, _y + (-9 + _b) * _s, _x - 9 * _s, _y + (6 + _b) * _s, false);
	draw_rectangle(_x + 9 * _s, _y + (-9 + _b) * _s, _x + 12 * _s, _y + (6 + _b) * _s, false);
	// pescoço e rosto
	draw_rectangle(_x - 2 * _s, _y + (-15 + _b) * _s, _x + 2 * _s, _y + (-11 + _b) * _s, false);
	draw_ellipse(_x - 7 * _s, _y + (-29 + _b) * _s, _x + 7 * _s, _y + (-14 + _b) * _s, false);
	// franja
	draw_set_color(_cab);
	draw_roundrect(_x - 8 * _s, _y + (-31 + _b) * _s, _x + 8 * _s, _y + (-25 + _b) * _s, false);
	// olhos, bochechas e sorriso
	draw_set_color(c_black);
	draw_circle(_x - 3 * _s, _y + (-21 + _b) * _s, max(1, 0.9 * _s), false);
	draw_circle(_x + 3 * _s, _y + (-21 + _b) * _s, max(1, 0.9 * _s), false);
	draw_set_color(merge_colour(_pele, c_red, 0.35));
	draw_circle(_x - 5 * _s, _y + (-18 + _b) * _s, max(1, 0.9 * _s), false);
	draw_circle(_x + 5 * _s, _y + (-18 + _b) * _s, max(1, 0.9 * _s), false);
	draw_set_color(make_colour_rgb(150, 50, 50));
	draw_line_width(_x - 2 * _s, _y + (-17 + _b) * _s, _x + 2 * _s, _y + (-17 + _b) * _s, max(1, 0.6 * _s));

	draw_set_alpha(1);
	draw_set_color(c_white);
}

// ---------------------------------------------------------------------
//  NPC pelo nome que aparece no diálogo (para o retrato)
// ---------------------------------------------------------------------
global.npc_ids = ["ricardo", "marcos", "paulo", "julio", "lia", "fabio", "rogerio", "gustavo",
                  "henrique", "vitor", "sergio", "clara", "beatriz", "sonia", "vera", "otavio"];
global.npc_por_nome_cache = {};

function npc_por_nome(_nome) {
	if (variable_struct_exists(global.npc_por_nome_cache, _nome)) return global.npc_por_nome_cache[$ _nome];
	var _achou = undefined;
	for (var i = 0; i < array_length(global.npc_ids); i++) {
		var _d = npc_dados(global.npc_ids[i]);
		if (_d.nome == _nome) { _achou = _d; break; }
	}
	global.npc_por_nome_cache[$ _nome] = _achou;
	return _achou;
}

// Camadas de mod equipadas na Nexa, recortadas (retrato)
function nexa_busto(_cx, _cy, _s, _frame) {
	var _l = 8, _t = 0, _w = 48, _h = 42;
	var _x0 = _cx - _w * _s / 2, _y0 = _cy - _h * _s / 2;
	draw_sprite_part_ext(spr_Nexa, _frame, _l, _t, _w, _h, _x0, _y0, _s, _s, c_white, 1);
	var _ordem = ["legs", "torso", "arms"];
	for (var i = 0; i < 3; i++) {
		var _slot = _ordem[i];
		if (global.mod_equipped[$ _slot] != "") {
			var _ov = global.mod_overlay[$ _slot];
			draw_sprite_part_ext(_ov, _frame mod sprite_get_number(_ov), _l, _t, _w, _h, _x0, _y0, _s, _s, c_white, 1);
		}
	}
}

// Desenha o retrato de quem fala, centrado em (_cx, _cy), cabendo em ~84x74
function retrato(_quem, _cx, _cy) {
	var _f = floor(current_time / 160);
	switch (_quem) {
		case "N":
			cyber_init();
			nexa_busto(_cx, _cy, 1.75, _f mod sprite_get_number(spr_Nexa));
			return true;
		case "U":
			draw_sprite_part_ext(spr_urso, _f mod sprite_get_number(spr_urso), 20, 0, 120, 105,
			                     _cx - 42, _cy - 37, 0.7, 0.7, c_white, 1);
			return true;
		case "PY":
			draw_sprite_part_ext(spr_python, _f mod sprite_get_number(spr_python), 0, 0, 120, 105,
			                     _cx - 42, _cy - 37, 0.7, 0.7, c_white, 1);
			return true;
		case "BD":
			draw_sprite_part_ext(spr_BancoDB, 0, 0, 0, 300, 260, _cx - 43, _cy - 37, 0.29, 0.29, c_white, 1);
			return true;
	}
	var _d = npc_por_nome(_quem);
	if (_d != undefined) {
		desenhar_robo(_cx, _cy + 18, 1.5, _d, current_time / 16, true);
		return true;
	}
	return false;
}
