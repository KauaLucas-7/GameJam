// ===== Animações de missão =====
if (aviso != undefined) {
	var _t = aviso_t;
	var _dur = aviso_duracao(aviso.tipo);
	var _tit = texto_seguro(aviso.titulo);
	var _txt = texto_seguro(aviso.texto);

	switch (aviso.tipo) {

		// ----- NOVA MISSÃO: cartão entra pela direita -----
		case "nova":
			var _in = ease_back(_t / 24);
			var _out = (_t > _dur - 22) ? ease_in((_t - (_dur - 22)) / 22) : 0;
			var _cx = lerp(492, 252, _in) + 250 * _out;
			var _cy = 34, _cw = 222, _ch = 50;
			var _pulse = 0.5 + 0.5 * sin(_t * 0.15);

			draw_set_alpha(0.92);
			draw_set_color(make_colour_rgb(12, 14, 26));
			draw_roundrect(_cx, _cy, _cx + _cw, _cy + _ch, false);
			draw_set_alpha(1);
			draw_set_color(merge_colour(c_aqua, c_white, _pulse * 0.5));
			draw_roundrect(_cx, _cy, _cx + _cw, _cy + _ch, true);
			draw_set_color(c_yellow);
			draw_rectangle(_cx + 2, _cy + 4, _cx + 4, _cy + _ch - 4, false);

			// ícone: losango girando com "!"
			var _ix = _cx + 24, _iy = _cy + _ch / 2, _ir = 13 + 2 * _pulse, _ang = _t * 3;
			draw_set_color(c_yellow);
			draw_triangle(_ix + lengthdir_x(_ir, _ang), _iy + lengthdir_y(_ir, _ang),
			              _ix + lengthdir_x(_ir, _ang + 90), _iy + lengthdir_y(_ir, _ang + 90),
			              _ix + lengthdir_x(_ir, _ang + 180), _iy + lengthdir_y(_ir, _ang + 180), false);
			draw_triangle(_ix + lengthdir_x(_ir, _ang), _iy + lengthdir_y(_ir, _ang),
			              _ix + lengthdir_x(_ir, _ang + 270), _iy + lengthdir_y(_ir, _ang + 270),
			              _ix + lengthdir_x(_ir, _ang + 180), _iy + lengthdir_y(_ir, _ang + 180), false);
			draw_set_color(c_black);
			draw_set_halign(fa_center); draw_set_valign(fa_middle);
			draw_text(_ix, _iy, "!");
			draw_set_halign(fa_left); draw_set_valign(fa_top);
			// anel de "ping" no começo
			if (_t < 40) {
				draw_set_alpha(1 - _t / 40);
				draw_set_color(c_yellow);
				draw_circle(_ix, _iy, 10 + _t, true);
				draw_set_alpha(1);
			}
			draw_set_color(c_aqua);
			draw_text_transformed(_cx + 46, _cy + 7, texto_seguro("NOVA MISSÃO"), 0.75, 0.75, 0);
			draw_set_color(c_white);
			draw_text(_cx + 46, _cy + 22, _tit);
			break;

		// ----- MISSÃO ATUALIZADA: faixa desce no topo -----
		case "atualizada":
			var _in2 = ease_out(_t / 16);
			var _out2 = (_t > _dur - 16) ? ease_in((_t - (_dur - 16)) / 16) : 0;
			var _py = lerp(-40, 6, _in2) - 46 * _out2;
			var _pw = 330, _px = 240 - _pw / 2;
			var _alt = 18 + string_height_ext(_txt, 12, _pw - 16);
			draw_set_alpha(0.9);
			draw_set_color(make_colour_rgb(12, 14, 26));
			draw_roundrect(_px, _py, _px + _pw, _py + _alt, false);
			draw_set_alpha(1);
			draw_set_color(c_aqua);
			draw_roundrect(_px, _py, _px + _pw, _py + _alt, true);
			draw_text_transformed(_px + 8, _py + 3, texto_seguro("MISSÃO ATUALIZADA  ·  ") + _tit, 0.75, 0.75, 0);
			draw_set_color(c_white);
			draw_text_ext(_px + 8, _py + 15, _txt, 12, _pw - 16);
			break;

		// ----- MISSÃO CONCLUÍDA: cutscene curta -----
		case "concluida":
			var _fade = (_t > _dur - 30) ? 1 - (_t - (_dur - 30)) / 30 : 1;
			draw_set_alpha(min(0.7, _t / 20) * _fade);
			draw_set_color(c_black);
			draw_rectangle(0, 0, 480, 270, false);

			// estrelas subindo
			for (var i = 0; i < array_length(particulas); i++) {
				var _p = particulas[i];
				draw_set_alpha(0.8 * _fade);
				draw_set_color(_p.c);
				var _r = _p.s * 2;
				draw_triangle(_p.x + lengthdir_x(_r, _p.r), _p.y + lengthdir_y(_r, _p.r),
				              _p.x + lengthdir_x(_r, _p.r + 120), _p.y + lengthdir_y(_r, _p.r + 120),
				              _p.x + lengthdir_x(_r, _p.r + 240), _p.y + lengthdir_y(_r, _p.r + 240), false);
			}

			// faixa dourada abrindo do centro
			var _bh = 80 * ease_out(_t / 26);
			var _by1 = 135 - _bh / 2, _by2 = 135 + _bh / 2;
			draw_set_alpha(0.92 * _fade);
			draw_set_color(make_colour_rgb(18, 14, 34));
			draw_rectangle(0, _by1, 480, _by2, false);
			var _lw = 480 * ease_out((_t - 6) / 30);
			draw_set_alpha(_fade);
			draw_set_color(c_yellow);
			draw_rectangle(240 - _lw / 2, _by1, 240 + _lw / 2, _by1 + 1, false);
			draw_rectangle(240 - _lw / 2, _by2 - 1, 240 + _lw / 2, _by2, false);

			// Nexa com brilho
			if (_t > 10) {
				var _g = 0.5 + 0.5 * sin(_t * 0.1);
				draw_set_alpha((0.25 + 0.2 * _g) * _fade);
				draw_set_color(c_yellow);
				draw_circle(70, 135, 30 + 4 * _g, false);
				draw_set_alpha(_fade);
				nexa_busto(70, 132, 1.5, floor(_t / 10) mod sprite_get_number(spr_Nexa));
			}

			// textos: título letra por letra, depois a recompensa
			draw_set_alpha(_fade);
			var _cab = texto_seguro("MISSÃO CONCLUÍDA");
			var _n = clamp(floor((_t - 14) / 2), 0, string_length(_cab));
			draw_set_color(c_yellow);
			draw_text_transformed(130, _by1 + 8, string_copy(_cab, 1, _n), 1.1, 1.1, 0);
			if (_t > 34) {
				var _sc = 1.35 * ease_back((_t - 34) / 18);
				draw_set_color(c_white);
				draw_text_transformed(130, _by1 + 30, _tit, _sc, _sc, 0);
			}
			if (_t > 55) {
				draw_set_alpha(min(1, (_t - 55) / 20) * _fade);
				draw_set_color(c_aqua);
				draw_text_ext(130, _by1 + 56, _txt, 12, 330);
			}
			if (_t > 90) {
				draw_set_alpha(_fade * (0.5 + 0.5 * sin(_t * 0.12)));
				draw_set_color(c_ltgray);
				draw_set_halign(fa_right);
				draw_text(474, 254, texto_seguro("[ESPAÇO]"));
				draw_set_halign(fa_left);
			}
			draw_set_alpha(1);
			break;
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// ===== Transição por cima de tudo =====
if (trans_fase != 0) {
	if (trans_estilo == "batalha") {
		// Entrada de batalha: clarão + listras que fecham e depois abrem
		var _bars = 10, _bhh = 27;
		if (trans_fase == 1) {
			if (trans_t < 10) {
				draw_set_alpha(1 - trans_t / 10);
				draw_set_color(c_white);
				draw_rectangle(0, 0, 480, 270, false);
			}
			draw_set_alpha(1);
			draw_set_color(c_black);
			for (var b = 0; b < _bars; b++) {
				var _w = 480 * ease_in((trans_t - 6 - b * 1.5) / 18);
				if (b mod 2 == 0) draw_rectangle(0, b * _bhh, _w, (b + 1) * _bhh, false);
				else draw_rectangle(480 - _w, b * _bhh, 480, (b + 1) * _bhh, false);
			}
		} else {
			draw_set_color(c_black);
			for (var b = 0; b < _bars; b++) {
				var _w2 = 480 * (1 - ease_out((trans_t - b) / 16));
				if (b mod 2 == 0) draw_rectangle(480 - _w2, b * _bhh, 480, (b + 1) * _bhh, false);
				else draw_rectangle(0, b * _bhh, _w2, (b + 1) * _bhh, false);
			}
		}
	}
	else if (trans_fase == 1) {
		draw_set_alpha(trans_t / 20);
		draw_set_color(c_black);
		draw_rectangle(0, 0, 480, 270, false);
	}
	else if (trans_titulo == undefined) {
		draw_set_alpha(1 - trans_t / trans_dur);
		draw_set_color(c_black);
		draw_rectangle(0, 0, 480, 270, false);
	}
	else {
		// Card do ambiente: nome da sala e a Nexa caminhando
		var _fd = (trans_t > trans_dur - 25) ? (trans_dur - trans_t) / 25 : 1;
		draw_set_alpha(_fd);
		draw_set_color(c_black);
		draw_rectangle(0, 0, 480, 270, false);

		// linhas de "scan"
		draw_set_alpha(0.08 * _fd);
		draw_set_color(c_aqua);
		for (var l = (trans_t * 2) mod 6; l < 270; l += 6) draw_line(0, l, 480, l);

		var _a1 = ease_out(trans_t / 25) * _fd;
		draw_set_alpha(_a1);
		draw_set_halign(fa_center);
		draw_set_color(c_white);
		draw_text_transformed(240, 92 + 10 * (1 - ease_out(trans_t / 25)), texto_seguro(trans_titulo[0]), 2, 2, 0);
		var _lw2 = 260 * ease_out((trans_t - 10) / 30);
		draw_set_color(c_aqua);
		draw_rectangle(240 - _lw2 / 2, 132, 240 + _lw2 / 2, 133, false);
		draw_set_alpha(ease_out((trans_t - 18) / 25) * _fd);
		draw_set_color(c_aqua);
		draw_text(240, 140, texto_seguro(trans_titulo[1]));
		draw_set_halign(fa_left);

		// Nexa atravessando a tela
		draw_set_alpha(1);
		var _nx = lerp(-30, 510, trans_t / trans_dur);
		if (_fd > 0.4) cyber_draw(spr_Nexa_andar, floor(trans_t / 5) mod 8, _nx, 210, 1, c_white, 1);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}
