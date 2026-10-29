// ===== Interface da exploração (480x270) =====
diario_anim = lerp(diario_anim, diario_aberto ? 1 : 0, 0.2);
if (instance_exists(obj_dialogo) || em_transicao()) exit;

// Dica de controles
if (diario_anim < 0.05) {
	var _vis = missoes_visiveis();
	var _ativas = 0;
	for (var i = 0; i < array_length(_vis); i++) if (missao(_vis[i]).estado == 1) _ativas++;
	draw_set_alpha(0.55);
	draw_set_color(c_black);
	draw_roundrect(4, 250, 190, 266, false);
	draw_set_alpha(0.9);
	draw_set_color(c_white);
	draw_text(10, 252, texto_seguro("[E] Interagir   [TAB] Missões"));
	if (_ativas > 0) {   // bolinha com o número de missões ativas
		draw_set_color(c_yellow);
		draw_circle(184, 258, 6, false);
		draw_set_color(c_black);
		draw_set_halign(fa_center); draw_set_valign(fa_middle);
		draw_text_transformed(184, 258, string(_ativas), 0.7, 0.7, 0);
		draw_set_halign(fa_left); draw_set_valign(fa_top);
	}
	draw_set_alpha(1);

	// ----- Painel do tutorial -----
	var _tut = "";
	var _tag = "TUTORIAL";
	if (room == rm_corredor1 && !flag("tut_mod")) {
		// dica extra na primeira escada: o terminal MOD
		if (!variable_instance_exists(id, "tut_mod_t")) tut_mod_t = 0;
		tut_mod_t++;
		_tut = "Terminal MOD: equipe aqui os implantes e as ferramentas que você ganhar.";
		_tag = "DICA";
		if (tut_mod_t > 480) marcar("tut_mod");
	}
	else if (global.tut_etapa < 5 || global.tut_t < 240) {
		_tut = tut_texto(global.tut_etapa);
	}
	if (_tut != "") {
		global.tut_anim = min(1, global.tut_anim + 0.06);
		var _ta = ease_back(global.tut_anim);
		var _tx = -230 + 238 * _ta;
		var _tt = texto_seguro(_tut);
		var _th = 20 + string_height_ext(_tt, 12, 196);
		var _ty = 244 - _th;   // canto de baixo, acima da dica de controles
		var _pul = 0.5 + 0.5 * sin(current_time / 200);
		draw_set_alpha(0.88);
		draw_set_color(make_colour_rgb(10, 14, 28));
		draw_roundrect(_tx, _ty, _tx + 214, _ty + _th, false);
		draw_set_alpha(1);
		draw_set_color(merge_colour(c_aqua, c_white, _pul * 0.4));
		draw_roundrect(_tx, _ty, _tx + 214, _ty + _th, true);
		draw_rectangle(_tx + 2, _ty + 3, _tx + 4, _ty + _th - 3, false);
		draw_text_transformed(_tx + 10, _ty + 3, _tag, 0.7, 0.7, 0);
		if (global.tut_etapa < 5 && _tag == "TUTORIAL") {
			draw_set_color(c_gray);
			draw_set_halign(fa_right);
			draw_text_transformed(_tx + 208, _ty + 3, string(global.tut_etapa + 1) + "/5", 0.7, 0.7, 0);
			draw_set_halign(fa_left);
		}
		draw_set_color(c_white);
		draw_text_ext(_tx + 10, _ty + 15, _tt, 12, 196);
	}
	exit;
}

// ===== Diário de missões =====
var _a = diario_anim;
var _e = ease_out(_a);
var _oy = 24 * (1 - _e);
var _t = current_time / 1000;

draw_set_alpha(0.55 * _a);
draw_set_color(c_black);
draw_rectangle(0, 0, 480, 270, false);

var _x1 = 24, _y1 = 22 + _oy, _x2 = 456, _y2 = 248 + _oy;
draw_set_alpha(0.95 * _a);
draw_set_color(make_colour_rgb(10, 12, 24));
draw_roundrect(_x1, _y1, _x2, _y2, false);
draw_set_alpha(_a);
draw_set_color(merge_colour(c_aqua, c_white, 0.3 + 0.2 * sin(_t * 3)));
draw_roundrect(_x1, _y1, _x2, _y2, true);

// Cabeçalho
draw_set_color(make_colour_rgb(20, 40, 60));
draw_rectangle(_x1 + 2, _y1 + 2, _x2 - 2, _y1 + 30, false);
nexa_busto(_x1 + 18, _y1 + 16, 0.6, floor(current_time / 160) mod sprite_get_number(spr_Nexa));
draw_set_color(c_white);
draw_text(_x1 + 34, _y1 + 4, texto_seguro("DIÁRIO DA NEXA"));
draw_set_color(c_aqua);
draw_text_transformed(_x1 + 34, _y1 + 17, texto_seguro("Autoconhecimento e apoio no trabalho"), 0.7, 0.7, 0);
var _feitas = 0;
for (var i = 0; i < array_length(global.missoes_ordem); i++) if (missao(global.missoes_ordem[i]).estado == 2) _feitas++;
draw_set_halign(fa_right);
draw_set_color(c_yellow);
draw_text(_x2 - 8, _y1 + 9, string(_feitas) + "/" + string(array_length(global.missoes_ordem)));
draw_set_halign(fa_left);

// Lista (esquerda)
var _lx = _x1 + 8, _ly = _y1 + 38;
for (var i = 0; i < array_length(global.missoes_ordem); i++) {
	var _m = missao(global.missoes_ordem[i]);
	var _iy = _ly + i * 30;
	var _sel = (i == diario_sel);
	if (_sel) {
		draw_set_alpha(_a * (0.35 + 0.15 * sin(_t * 5)));
		draw_set_color(c_aqua);
		draw_roundrect(_lx, _iy, _lx + 156, _iy + 26, false);
		draw_set_alpha(_a);
		draw_set_color(c_aqua);
		draw_roundrect(_lx, _iy, _lx + 156, _iy + 26, true);
	}
	// ícone
	var _icx = _lx + 13, _icy = _iy + 13;
	if (_m.estado == 2) {
		draw_set_color(c_lime);
		draw_circle(_icx, _icy, 7, false);
		draw_set_color(c_black);
		draw_line_width(_icx - 4, _icy, _icx - 1, _icy + 3, 2);
		draw_line_width(_icx - 1, _icy + 3, _icx + 4, _icy - 3, 2);
	} else if (_m.estado == 1) {
		var _r = 7 + sin(_t * 4);
		draw_set_color(c_yellow);
		draw_triangle(_icx, _icy - _r, _icx + _r, _icy, _icx, _icy + _r, false);
		draw_triangle(_icx, _icy - _r, _icx - _r, _icy, _icx, _icy + _r, false);
		draw_set_color(c_black);
		draw_set_halign(fa_center); draw_set_valign(fa_middle);
		draw_text_transformed(_icx, _icy, "!", 0.8, 0.8, 0);
		draw_set_halign(fa_left); draw_set_valign(fa_top);
	} else {
		draw_set_color(c_dkgray);
		draw_circle(_icx, _icy, 7, true);
	}
	draw_set_color((_m.estado == 0) ? c_gray : ((_m.estado == 2) ? c_lime : c_white));
	var _nome = (_m.estado == 0) ? "???" : _m.titulo;
	draw_text_transformed(_lx + 26, _iy + 7, texto_seguro(_nome), 0.85, 0.85, 0);
}

// Divisória
draw_set_color(make_colour_rgb(40, 70, 90));
draw_line(_x1 + 172, _y1 + 36, _x1 + 172, _y2 - 22);

// Detalhes (direita)
var _dx = _x1 + 182, _dw = _x2 - _dx - 10, _dy = _y1 + 38;
var _ms = missao(global.missoes_ordem[clamp(diario_sel, 0, array_length(global.missoes_ordem) - 1)]);
if (_ms.estado == 0) {
	draw_set_color(c_gray);
	draw_text_ext(_dx, _dy + 20, texto_seguro("Missão ainda não descoberta.\n\nConverse com as pessoas, leia os arquivos e explore o prédio."), 13, _dw);
} else {
	draw_set_color(c_white);
	draw_text_transformed(_dx, _dy, texto_seguro(_ms.titulo), 1.15, 1.15, 0);
	// etiqueta de estado
	var _tag = (_ms.estado == 2) ? "CONCLUÍDA" : "EM ANDAMENTO";
	draw_set_color((_ms.estado == 2) ? c_lime : c_yellow);
	draw_text_transformed(_dx, _dy + 18, texto_seguro(_tag), 0.7, 0.7, 0);

	draw_set_color(c_ltgray);
	var _sobre = texto_seguro(_ms.sobre);
	draw_text_ext(_dx, _dy + 32, _sobre, 12, _dw);
	var _yy = _dy + 38 + string_height_ext(_sobre, 12, _dw);

	if (_ms.estado == 1) {
		draw_set_color(c_aqua);
		draw_text(_dx, _yy, "Objetivo:");
		draw_set_color(c_white);
		var _obj = texto_seguro(_ms.objetivo);
		draw_text_ext(_dx, _yy + 13, _obj, 12, _dw);
		_yy += 20 + string_height_ext(_obj, 12, _dw);
	}

	// barra de progresso em segmentos
	var _seg = max(1, _ms.total), _sw = (_dw - (_seg - 1) * 3) / _seg;
	for (var s = 0; s < _seg; s++) {
		var _sx = _dx + s * (_sw + 3);
		draw_set_color(make_colour_rgb(30, 40, 55));
		draw_rectangle(_sx, _yy, _sx + _sw, _yy + 6, false);
		if (s < _ms.prog) {
			draw_set_color((_ms.estado == 2) ? c_lime : c_yellow);
			draw_rectangle(_sx, _yy, _sx + _sw, _yy + 6, false);
		}
	}
	draw_set_color(c_ltgray);
	draw_text_transformed(_dx, _yy + 10, "Progresso: " + string(min(_ms.prog, _ms.total)) + "/" + string(_ms.total), 0.75, 0.75, 0);

	draw_set_color(c_yellow);
	draw_text_ext(_dx, _yy + 24, texto_seguro("Recompensa: " + _ms.recompensa), 12, _dw);
}

// Rodapé
draw_set_color(c_gray);
draw_text_transformed(_x1 + 8, _y2 - 16, texto_seguro("[Cima/Baixo] escolher    [TAB] fechar"), 0.75, 0.75, 0);
draw_set_alpha(1);
draw_set_color(c_white);
