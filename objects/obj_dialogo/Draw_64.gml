if (i >= array_length(linhas)) exit;

var _fala = linhas[i];
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _narr = (_fala[0] == "");

// Barras de cinema na narração
barras = lerp(barras, _narr ? 26 : 0, 0.12);
if (barras > 0.5) {
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gw, barras, false);
	draw_rectangle(0, _gh - barras, _gw, _gh, false);
}

// Tremor
var _sx = (tremor > 0) ? irandom_range(-2, 2) : 0;
var _sy = (tremor > 0) ? irandom_range(-2, 2) : 0;

// Caixa de texto (abre esticando)
var _e = ease_out(abrir);
var _x1 = 8 + _sx, _y2 = _gh - 6 + _sy;
var _y1 = _y2 - 80 * _e, _x2 = _gw - 8 + _sx;
draw_set_alpha(0.88);
draw_set_color(make_colour_rgb(8, 8, 16));
draw_roundrect(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);
draw_set_color(_narr ? c_gray : c_white);
draw_roundrect(_x1, _y1, _x2, _y2, true);
if (abrir < 0.95) exit;

var _tx = _x1 + 10;
var _nome = texto_seguro(nome_falante(_fala[0]));

// Retrato de quem fala (entra deslizando pela esquerda)
if (!_narr) {
	var _re = ease_back(ret_anim);
	var _px = _x1 + 6 - 60 * (1 - _re), _py = _y1 - 82;
	draw_set_alpha(0.9 * _re);
	draw_set_color(make_colour_rgb(14, 18, 32));
	draw_roundrect(_px, _py, _px + 92, _py + 78, false);
	draw_set_alpha(_re);
	draw_set_color((_fala[0] == "N") ? c_aqua : c_yellow);
	draw_roundrect(_px, _py, _px + 92, _py + 78, true);
	draw_set_alpha(1);
	retrato(_fala[0], _px + 46, _py + 40);
	// etiqueta com o nome
	draw_set_color((_fala[0] == "N") ? c_aqua : c_yellow);
	draw_roundrect(_px + 4, _py + 66, _px + 8 + string_width(_nome) * 0.75 + 6, _py + 80, false);
	draw_set_color(c_black);
	draw_text_transformed(_px + 8, _py + 67, _nome, 0.75, 0.75, 0);
}

// Texto aparecendo letra por letra
var _texto = texto_seguro(string_copy(_fala[1], 1, floor(letras)));
draw_set_color(_narr ? make_colour_rgb(200, 205, 220) : c_white);
if (_narr) {
	draw_set_halign(fa_center);
	draw_text_ext(_gw / 2 + _sx, _y1 + 14, _texto, 14, _x2 - _x1 - 30);
	draw_set_halign(fa_left);
} else {
	draw_set_color(c_yellow);
	draw_text(_tx, _y1 + 5, _nome);
	draw_set_color(c_white);
	draw_text_ext(_tx, _y1 + 22, _texto, 14, _x2 - _x1 - 20);
}

// Indicador para continuar (pisca quando a linha terminou)
if (letras >= string_length(_fala[1])) {
	draw_set_alpha(0.5 + 0.5 * sin(current_time / 150));
	draw_set_color(c_ltgray);
	draw_set_halign(fa_right);
	draw_text(_x2 - 8, _y2 - 16, texto_seguro("[ESPAÇO] ") + string(i + 1) + "/" + string(array_length(linhas)));
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}

// Clarão
if (clarao > 0) {
	draw_set_alpha(clarao);
	draw_set_color(c_white);
	draw_rectangle(0, 0, _gw, _gh, false);
	draw_set_alpha(1);
}
draw_set_color(c_white);
