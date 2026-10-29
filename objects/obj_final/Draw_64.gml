// ===== Fundo: a sala do Chefe, clareando conforme elas se libertam =====
var _spr = spr_sala_urso;
var _sc = 480 / sprite_get_width(_spr);
var _oy = (270 - sprite_get_height(_spr) * _sc) / 2;
gpu_set_texfilter(true);
draw_sprite_ext(_spr, 0, 0, _oy, _sc, _sc, 0, c_white, 1);
gpu_set_texfilter(false);
draw_set_alpha(0.7 - 0.4 * luz);
draw_set_color(c_black);
draw_rectangle(0, 0, 480, 270, false);
// luz quente da manhã entrando
draw_set_alpha(0.25 * luz);
draw_set_color(make_colour_rgb(255, 200, 120));
draw_rectangle(0, 0, 480, 270, false);
draw_set_alpha(1);

// ===== Personagens =====
var _base = 150;
for (var k = 0; k < array_length(elenco); k++) {
	var _p = elenco[k];
	var _pr = ease_out(_p.prog);
	if (_pr < 1) desenhar_robo(_p.x, _base, 1.4, _p.d, anim + k * 20, false, 1 - _pr);
	if (_pr > 0) desenhar_humana(_p.x, _base, 1.4, _p.d, anim + k * 20, _pr);
	// brilho da transformação
	if (_p.prog > 0 && _p.prog < 1) {
		draw_set_alpha(0.6 * sin(pi * _p.prog));
		draw_set_color(c_white);
		draw_circle(_p.x, _base - 10, 34 * sin(pi * _p.prog), false);
		draw_set_alpha(1);
	}
}

// Nexa: corpo + todas as placas de metal sumindo
var _np = ease_out(nexa.prog);
var _fr = floor(anim / 10) mod sprite_get_number(spr_Nexa);
draw_sprite_ext(spr_Nexa, _fr, nexa.x, _base + 2, 1.5, 1.5, 0, c_white, 1);
if (_np < 1) {
	var _ordem = ["legs", "torso", "arms"];
	for (var s = 0; s < 3; s++) {
		var _ov = global.mod_overlay[$ _ordem[s]];
		draw_sprite_ext(_ov, _fr mod sprite_get_number(_ov), nexa.x, _base + 2, 1.5, 1.5, 0, c_white, 1 - _np);
	}
}
if (nexa.prog > 0 && nexa.prog < 1) {
	draw_set_alpha(0.7 * sin(pi * nexa.prog));
	draw_set_color(c_aqua);
	draw_circle(nexa.x, _base - 6, 40 * sin(pi * nexa.prog), false);
	draw_set_alpha(1);
}

// Placas caindo
for (var k = 0; k < array_length(pecas); k++) {
	var _pc = pecas[k];
	draw_set_alpha(_pc.a);
	draw_set_color(c_silver);
	var _w = 3, _h = 2;
	var _c = dcos(_pc.r), _s = dsin(_pc.r);
	draw_triangle(_pc.x - _w * _c + _h * _s, _pc.y + _w * _s + _h * _c, _pc.x + _w * _c + _h * _s, _pc.y - _w * _s + _h * _c,
	              _pc.x + _w * _c - _h * _s, _pc.y - _w * _s - _h * _c, false);
	draw_set_color(c_red);
	draw_point(_pc.x, _pc.y);
}
draw_set_alpha(1);

// Clarão do final
if (brilho > 0) {
	draw_set_alpha(brilho * 0.8);
	draw_set_color(c_white);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(1);
}

// ===== Legendas =====
if (fase == "cena") {
	var _f = falas[fala_i];
	var _narr = (_f.q == "");
	// barras de cinema
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 22, false);
	draw_set_alpha(0.85);
	draw_set_color(make_colour_rgb(8, 8, 16));
	draw_roundrect(8, 196, 472, 264, false);
	draw_set_alpha(1);
	draw_set_color(_narr ? c_gray : c_white);
	draw_roundrect(8, 196, 472, 264, true);
	var _txt = texto_seguro(string_copy(_f.t, 1, floor(letras)));
	if (_narr) {
		draw_set_halign(fa_center);
		draw_set_color(make_colour_rgb(210, 214, 228));
		draw_text_ext(240, 210, _txt, 14, 440);
		draw_set_halign(fa_left);
	} else {
		draw_set_color((_f.q == "N") ? c_aqua : c_yellow);
		draw_text(18, 201, texto_seguro(nome_falante(_f.q)));
		draw_set_color(c_white);
		draw_text_ext(18, 218, _txt, 14, 444);
	}
	if (letras >= string_length(_f.t)) {
		draw_set_alpha(0.5 + 0.5 * sin(current_time / 150));
		draw_set_color(c_ltgray);
		draw_set_halign(fa_right);
		draw_text(464, 248, texto_seguro("[ESPAÇO]"));
		draw_set_halign(fa_left);
		draw_set_alpha(1);
	}
}

// ===== Créditos =====
if (fase == "creditos") {
	draw_set_alpha(fade_cred * 0.9);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(fade_cred);
	draw_set_halign(fa_center);
	var _y = cred_y;
	for (var k = 0; k < array_length(creditos); k++) {
		var _c = creditos[k];
		if (variable_struct_exists(_c, "tt")) {
			draw_set_color(c_aqua);
			draw_text_transformed(240, _y, texto_seguro(_c.s), 2.4, 2.4, 0);
			_y += 40;
		} else if (variable_struct_exists(_c, "h")) {
			draw_set_color(c_yellow);
			draw_text(240, _y, texto_seguro(_c.s));
			_y += 18;
		} else {
			draw_set_color(c_white);
			draw_text(240, _y, texto_seguro(_c.s));
			_y += 16;
		}
	}
	// todas juntas, humanas, embaixo da tela
	draw_set_alpha(fade_cred);
	for (var k = 0; k < array_length(elenco); k++) desenhar_humana(60 + k * 72 + ((k >= 2) ? 72 : 0), 236, 0.8, elenco[k].d, anim + k * 15, fade_cred);
	draw_sprite_ext(spr_Nexa, floor(anim / 10) mod sprite_get_number(spr_Nexa), 240, 234, 0.9, 0.9, 0, c_white, fade_cred);

	if (cred_fim) {
		draw_set_alpha(0.5 + 0.5 * sin(current_time / 200));
		draw_set_color(c_yellow);
		draw_text_transformed(240, 110, "Obrigado por jogar!", 1.6, 1.6, 0);
		draw_set_color(c_ltgray);
		draw_text(240, 140, "[ENTER] voltar ao menu");
	}
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}
draw_set_color(c_white);
