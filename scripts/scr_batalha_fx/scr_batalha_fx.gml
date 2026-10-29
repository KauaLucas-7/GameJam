// =====================================================================
//  ANIMAÇÕES DA BATALHA
//  Funções chamadas de dentro do obj_battle (usam as variáveis dele).
//  acao = animação da Nexa em andamento | fx = efeitos (projéteis, faíscas...)
// =====================================================================

#macro NEXA_BX 80     // posição base da Nexa na batalha
#macro NEXA_BY 104
#macro NEXA_ESC 1.4

function cor_elemento(_el) {
	switch (_el) {
		case "lightning": return make_colour_rgb(255, 240, 90);
		case "fire":      return make_colour_rgb(255, 120, 40);
		case "ice":       return make_colour_rgb(150, 220, 255);
	}
	return c_lime;
}

function fx_add(_f) { array_push(fx, _f); return _f; }

function fx_faiscas(_x, _y, _n, _cor, _forca = 2.5) {
	repeat (_n) {
		var _d = random(360), _v = random_range(0.6, _forca);
		fx_add({ tipo: "faisca", x: _x, y: _y, vx: lengthdir_x(_v, _d), vy: lengthdir_y(_v, _d) - 0.5,
		         vida: irandom_range(14, 26), max: 26, cor: _cor });
	}
}

// Começa uma animação da Nexa. _imp = struct com o que acontece no impacto (dano atrasado)
function iniciar_acao(_tipo, _dur, _alvo = undefined, _el = "none", _imp = undefined) {
	acao = { tipo: _tipo, t: 0, dur: _dur, alvo: _alvo, el: _el, imp: _imp, dx: 0 };
	var _ax = NEXA_BX + 20, _ay = NEXA_BY - 14;
	if (_alvo != undefined) {
		var _p = get_unit_pos(_alvo);
		acao.dx = _p.x - NEXA_BX - 58;
		acao.tx = _p.x; acao.ty = _p.y;
	}
	switch (_tipo) {
		case "defesa":
			fx_add({ tipo: "escudo", x: NEXA_BX, y: NEXA_BY - 4, vida: 30, max: 30, cor: c_aqua, r: 34 });
			fx_faiscas(NEXA_BX, NEXA_BY - 4, 10, c_aqua);
			break;
		case "item":
			fx_add({ tipo: "frasco", x: NEXA_BX + 14, y: NEXA_BY - 20, vida: 40, max: 40 });
			break;
		case "cura":
			repeat (3) fx_add({ tipo: "anel", x: NEXA_BX, y: NEXA_BY + 30, r0: 8, r1: 40, vida: 34, max: 34, cor: cor_elemento(_el), sobe: true });
			break;
		case "habilidade":
			if (_el == "lightning") {
				// o raio cai alguns quadros depois (no impacto)
			} else {
				fx_add({ tipo: "proj", x: _ax, y: _ay, x0: _ax, y0: _ay, x2: acao.tx, y2: acao.ty, t: -8, dur: 18,
				         cor: cor_elemento(_el), el: _el });
			}
			break;
		case "especial":
			especial_escuro = 1;
			break;
	}
}

// Avança animação, efeitos e o "impacto" (quando o dano acontece)
function fx_atualizar() {
	if (acao.tipo != "") {
		acao.t++;
		var _imp_t = -1;
		switch (acao.tipo) {
			case "ataque":     _imp_t = 10; break;
			case "habilidade": _imp_t = 26; break;
			case "especial":   _imp_t = 24; break;
		}
		if (acao.t == _imp_t && acao.imp != undefined) aplicar_impacto(acao.imp);
		if (acao.t >= acao.dur) acao.tipo = "";
	}
	especial_escuro = max(0, especial_escuro - ((acao.tipo == "especial") ? 0 : 0.05));

	for (var i = array_length(fx) - 1; i >= 0; i--) {
		var _f = fx[i];
		switch (_f.tipo) {
			case "faisca": _f.x += _f.vx; _f.y += _f.vy; _f.vy += 0.08; _f.vida--; break;
			case "proj":
				_f.t++;
				if (_f.t >= 0) {
					var _k = _f.t / _f.dur;
					_f.x = lerp(_f.x0, _f.x2, _k);
					_f.y = lerp(_f.y0, _f.y2, _k) - sin(pi * _k) * 20;
					if (_f.el == "fire" && _f.t mod 2 == 0) fx_add({ tipo: "faisca", x: _f.x, y: _f.y, vx: random_range(-0.5, 0.5), vy: random_range(-0.6, 0.2), vida: 14, max: 14, cor: c_orange });
				}
				if (_f.t >= _f.dur) {
					fx_add({ tipo: "anel", x: _f.x2, y: _f.y2, r0: 4, r1: 36, vida: 18, max: 18, cor: _f.cor, sobe: false });
					fx_faiscas(_f.x2, _f.y2, 14, _f.cor, 3);
					_f.vida = 0;
				} else _f.vida = 1;
				break;
			default: _f.vida--; break;
		}
		if (_f.vida <= 0) array_delete(fx, i, 1);
	}
}

// O golpe acerta: aplica o dano guardado no começo da animação
function aplicar_impacto(_imp) {
	var _eu = party[0];
	switch (_imp.tipo) {
		case "ataque":
			if (_imp.liberta) free_worker(_imp.alvo);
			else {
				deal_damage(_eu, _imp.alvo, _imp.mult, "");
				if (_imp.expo) log_text = "EXPOSTO x2! " + log_text;
			}
			log_text = _imp.rating + " " + log_text;
			var _p = get_unit_pos(_imp.alvo);
			fx_add({ tipo: "corte", x: _p.x, y: _p.y, vida: 14, max: 14, ang: 30 });
			fx_faiscas(_p.x, _p.y, (_imp.rating == "PERFEITO!") ? 18 : 9, (_imp.rating == "PERFEITO!") ? c_yellow : c_white, 3);
			start_shake((_imp.rating == "PERFEITO!") ? 4 : 2, 10);
			break;

		case "habilidade":
			use_skill(_eu, _imp.skill, _imp.alvo);
			var _p2 = get_unit_pos(_imp.alvo);
			if (_imp.skill.element == "lightning") {
				fx_add({ tipo: "raio", x1: _p2.x + random_range(-6, 6), y1: 20, x2: _p2.x, y2: _p2.y, vida: 14, max: 14, cor: cor_elemento("lightning") });
				fx_faiscas(_p2.x, _p2.y, 16, cor_elemento("lightning"), 3.5);
				start_shake(3, 10);
			}
			if (_imp.skill.element == "ice") {
				repeat (5) fx_add({ tipo: "cristal", x: _p2.x + random_range(-22, 22), y: _p2.y + random_range(-18, 18),
				                    vida: 30, max: 30, ang: random(360) });
			}
			break;

		case "especial":
			var _alvos = alive_list(enemies);
			for (var i = 0; i < array_length(_alvos); i++) {
				deal_damage(_eu, _alvos[i], 2.5, "");
				var _p3 = get_unit_pos(_alvos[i]);
				fx_add({ tipo: "feixe", x1: NEXA_BX + 14, y1: NEXA_BY - 10, x2: _p3.x, y2: _p3.y, vida: 18, max: 18 });
				fx_faiscas(_p3.x, _p3.y, 16, c_aqua, 4);
			}
			log_text = _eu.name + " usou o GOLPE ESPECIAL!";
			fx_add({ tipo: "anel", x: NEXA_BX, y: NEXA_BY, r0: 10, r1: 520, vida: 26, max: 26, cor: c_aqua, sobe: false });
			especial_clarao = 1;
			start_shake(7, 22);
			break;
	}
}

// ---------------------------------------------------------------------
//  Poses (deslocamento, escala, rotação) — deixam o movimento fluido
// ---------------------------------------------------------------------
function nexa_pose() {
	var _b = sin(current_time / 420);
	var _p = { x: 0, y: -1.5 * _b, sx: 1 - 0.012 * _b, sy: 1 + 0.025 * _b, ang: 0, brilho: 0, cor: c_aqua };
	var _t = acao.t;
	switch (acao.tipo) {
		case "ataque":
			if (_t < 10)      { var _e = ease_in(_t / 10); _p.x = acao.dx * _e; _p.ang = -10 * _e; _p.sx *= 1 + 0.15 * _e; _p.sy *= 1 - 0.08 * _e; }
			else if (_t < 18) { _p.x = acao.dx; _p.ang = -10 + (_t - 10) * 2.5; }
			else              { var _e2 = ease_out((_t - 18) / 16); _p.x = acao.dx * (1 - _e2); _p.ang = 10 * (1 - _e2); }
			break;
		case "habilidade":
			_p.y -= 10 * sin(pi * clamp(_t / 30, 0, 1));
			_p.brilho = sin(pi * clamp(_t / 30, 0, 1));
			_p.cor = cor_elemento(acao.el);
			break;
		case "cura":
		case "item":
			_p.y -= 5 * sin(pi * clamp(_t / acao.dur, 0, 1));
			_p.brilho = 0.7 * sin(pi * clamp(_t / acao.dur, 0, 1));
			_p.cor = c_lime;
			break;
		case "defesa":
			_p.x = -5 * ease_out(_t / 8) * (1 - _t / acao.dur);
			_p.sy *= 1 - 0.06 * sin(pi * clamp(_t / 12, 0, 1));
			break;
		case "especial":
			if (_t < 24) { var _e3 = ease_out(_t / 24); _p.y -= 18 * _e3; _p.ang = 360 * ease_in(_t / 24); _p.brilho = _e3; }
			else         { var _e4 = ease_out((_t - 24) / 30); _p.y -= 18 * (1 - _e4); _p.brilho = 1 - _e4; }
			break;
	}
	// preparando o golpe (barra de ritmo): inclina para trás
	if (acao.tipo == "" && state == BATTLE_STATE.PLAYER_TIMING) { _p.x = -6; _p.ang = 8 + sin(current_time / 90) * 1.5; }
	// levou dano: recua e pisca em vermelho
	var _u = party[0];
	if (variable_struct_exists(_u, "hurt") && _u.hurt > 0) _p.x -= 8 * (_u.hurt / 14);
	return _p;
}

function inimigo_pose(_e, _i) {
	var _ph = _i * 1.7;
	var _p = { x: 0, y: sin(current_time / 500 + _ph) * 3, sx: 1 - 0.01 * sin(current_time / 380 + _ph),
	           sy: 1 + 0.025 * sin(current_time / 380 + _ph), ang: sin(current_time / 900 + _ph) * 2, flash: 0 };
	// ataque: avança até a Nexa no momento do golpe e volta
	if (state == BATTLE_STATE.DEFENSE && _e == current) {
		if (def_timer <= def_hit) _p.x = -70 * ease_in(clamp(def_timer / def_hit, 0, 1));
		else _p.x = -70 * (1 - ease_out((def_timer - def_hit) / 10));
	}
	// levou dano: recua e pisca em branco
	if (variable_struct_exists(_e, "hurt") && _e.hurt > 0) { _p.x += 10 * (_e.hurt / 14); _p.flash = _e.hurt / 14; }
	return _p;
}

// Sprite todo branco (clarão de dano)
function sprite_clarao(_spr, _f, _x, _y, _sx, _sy, _ang, _a, _cor = c_white) {
	if (_a <= 0) return;
	gpu_set_fog(true, _cor, 0, 0);
	draw_sprite_ext(_spr, _f, _x, _y, _sx, _sy, _ang, c_white, _a);
	gpu_set_fog(false, c_white, 0, 0);
}

// Nexa na batalha: corpo + mods, com pose, brilho e clarão de dano
function nexa_desenhar_batalha(_tint) {
	var _p = nexa_pose();
	var _x = NEXA_BX + _p.x, _y = NEXA_BY + _p.y;
	var _sx = NEXA_ESC * _p.sx, _sy = NEXA_ESC * _p.sy;
	var _fr = floor(current_time / 160) mod sprite_get_number(spr_Nexa);

	// sombra
	draw_set_alpha(0.35);
	draw_set_color(c_black);
	draw_ellipse(NEXA_BX + _p.x - 18, NEXA_BY + 38, NEXA_BX + _p.x + 18, NEXA_BY + 46, false);
	// aura
	if (_p.brilho > 0) {
		draw_set_alpha(0.35 * _p.brilho);
		draw_set_color(_p.cor);
		draw_circle(_x, _y - 4, 36 + 6 * sin(current_time / 80), false);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);

	draw_sprite_ext(spr_Nexa, _fr, _x, _y, _sx, _sy, _p.ang, _tint, 1);
	var _ordem = ["legs", "torso", "arms"];
	for (var s = 0; s < 3; s++) {
		var _slot = _ordem[s];
		if (global.mod_equipped[$ _slot] != "") {
			var _ov = global.mod_overlay[$ _slot];
			draw_sprite_ext(_ov, _fr mod sprite_get_number(_ov), _x, _y, _sx, _sy, _p.ang, _tint, 1);
		}
	}
	if (_p.brilho > 0) sprite_clarao(spr_Nexa, _fr, _x, _y, _sx, _sy, _p.ang, 0.35 * _p.brilho, _p.cor);
	var _u = party[0];
	if (variable_struct_exists(_u, "hurt") && _u.hurt > 0) sprite_clarao(spr_Nexa, _fr, _x, _y, _sx, _sy, _p.ang, _u.hurt / 14, c_red);

	// escudo enquanto está defendendo
	if (_u.defending) {
		draw_set_alpha(0.25 + 0.1 * sin(current_time / 150));
		desenhar_hexagono(NEXA_BX, NEXA_BY - 4, 32, c_aqua, true);
		draw_set_alpha(1);
	}
}

function desenhar_hexagono(_x, _y, _r, _cor, _contorno) {
	draw_set_color(_cor);
	for (var k = 0; k < 6; k++) {
		var _a1 = k * 60 + 30, _a2 = _a1 + 60;
		if (_contorno) draw_line_width(_x + lengthdir_x(_r, _a1), _y + lengthdir_y(_r, _a1), _x + lengthdir_x(_r, _a2), _y + lengthdir_y(_r, _a2), 2);
		else draw_triangle(_x, _y, _x + lengthdir_x(_r, _a1), _y + lengthdir_y(_r, _a1), _x + lengthdir_x(_r, _a2), _y + lengthdir_y(_r, _a2), false);
	}
}

// ---------------------------------------------------------------------
//  Desenho dos efeitos
// ---------------------------------------------------------------------
function fx_desenhar() {
	for (var i = 0; i < array_length(fx); i++) {
		var _f = fx[i];
		var _a = (_f.tipo == "proj") ? 1 : _f.vida / _f.max;
		draw_set_alpha(_a);
		switch (_f.tipo) {
			case "faisca":
				draw_set_color(_f.cor);
				draw_rectangle(_f.x - 1, _f.y - 1, _f.x + 1, _f.y + 1, false);
				break;
			case "anel":
				var _k = 1 - _f.vida / _f.max;
				var _yy = _f.sobe ? _f.y - 50 * _k : _f.y;
				draw_set_color(_f.cor);
				draw_circle(_f.x, _yy, lerp(_f.r0, _f.r1, ease_out(_k)), true);
				draw_circle(_f.x, _yy, lerp(_f.r0, _f.r1, ease_out(_k)) - 1, true);
				break;
			case "escudo":
				var _k2 = ease_back(1 - (_f.vida - 10) / (_f.max - 10));
				desenhar_hexagono(_f.x, _f.y, _f.r * clamp(_k2, 0, 1.2), _f.cor, true);
				draw_set_alpha(_a * 0.25);
				desenhar_hexagono(_f.x, _f.y, _f.r * clamp(_k2, 0, 1.2), _f.cor, false);
				break;
			case "frasco":
				var _k3 = 1 - _f.vida / _f.max;
				var _fx = _f.x, _fy = _f.y - 24 * ease_out(_k3);
				draw_set_color(make_colour_rgb(80, 220, 120));
				draw_roundrect(_fx - 4, _fy - 4, _fx + 4, _fy + 6, false);
				draw_set_color(c_white);
				draw_rectangle(_fx - 2, _fy - 8, _fx + 2, _fy - 4, false);
				if (_f.vida mod 4 == 0) fx_add({ tipo: "faisca", x: _fx + random_range(-6, 6), y: _fy, vx: random_range(-0.3, 0.3), vy: -0.8, vida: 18, max: 18, cor: c_lime });
				break;
			case "proj":
				if (_f.t < 0) break;
				draw_set_color(_f.cor);
				if (_f.el == "ice") {
					draw_triangle(_f.x + 8, _f.y, _f.x - 6, _f.y - 4, _f.x - 6, _f.y + 4, false);
				} else {
					draw_circle(_f.x, _f.y, 6, false);
					draw_set_color(c_white);
					draw_circle(_f.x, _f.y, 3, false);
				}
				break;
			case "raio":
				draw_set_color(_f.cor);
				var _px = _f.x1, _py = _f.y1, _seg = 7;
				for (var s = 1; s <= _seg; s++) {
					var _nx = lerp(_f.x1, _f.x2, s / _seg) + ((s < _seg) ? random_range(-10, 10) : 0);
					var _ny = lerp(_f.y1, _f.y2, s / _seg);
					draw_line_width(_px, _py, _nx, _ny, 3);
					_px = _nx; _py = _ny;
				}
				break;
			case "cristal":
				draw_set_color(cor_elemento("ice"));
				var _cs = 6 * ease_back(1 - _f.vida / _f.max);
				draw_triangle(_f.x, _f.y - _cs * 1.6, _f.x - _cs, _f.y, _f.x + _cs, _f.y, false);
				draw_triangle(_f.x, _f.y + _cs * 1.6, _f.x - _cs, _f.y, _f.x + _cs, _f.y, false);
				break;
			case "corte":
				var _k4 = 1 - _f.vida / _f.max;
				draw_set_color(c_white);
				for (var s = -2; s <= 2; s++) {
					var _ang = _f.ang + lerp(-70, 70, _k4) + s * 6;
					draw_line_width(_f.x + lengthdir_x(10, _ang), _f.y + lengthdir_y(10, _ang),
					                _f.x + lengthdir_x(30, _ang), _f.y + lengthdir_y(30, _ang), 3 - abs(s));
				}
				break;
			case "feixe":
				var _w = 10 * (_f.vida / _f.max);
				draw_set_color(c_aqua);
				draw_line_width(_f.x1, _f.y1, _f.x2, _f.y2, _w);
				draw_set_color(c_white);
				draw_line_width(_f.x1, _f.y1, _f.x2, _f.y2, _w * 0.4);
				break;
		}
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Ícones dos comandos do menu (desenhados com formas)
function icone_comando(_i, _x, _y, _cor) {
	draw_set_color(_cor);
	switch (_i) {
		case 0: // espada
			draw_line_width(_x - 5, _y + 5, _x + 5, _y - 5, 2);
			draw_line_width(_x - 6, _y + 1, _x - 1, _y + 6, 2);
			break;
		case 1: // escudo
			draw_triangle(_x - 5, _y - 5, _x + 5, _y - 5, _x, _y + 6, false);
			draw_rectangle(_x - 5, _y - 5, _x + 5, _y - 1, false);
			break;
		case 2: // estrela (habilidade)
			for (var k = 0; k < 5; k++) {
				var _a = 90 + k * 72;
				draw_triangle(_x, _y, _x + lengthdir_x(6, _a - 18), _y + lengthdir_y(6, _a - 18), _x + lengthdir_x(6, _a + 18), _y + lengthdir_y(6, _a + 18), false);
			}
			break;
		case 3: // frasco
			draw_roundrect(_x - 4, _y - 2, _x + 4, _y + 6, false);
			draw_rectangle(_x - 2, _y - 6, _x + 2, _y - 2, false);
			break;
		case 4: // explosão (especial)
			for (var k = 0; k < 8; k++) {
				var _a2 = k * 45 + current_time / 20;
				draw_line_width(_x, _y, _x + lengthdir_x((k mod 2 == 0) ? 7 : 4, _a2), _y + lengthdir_y((k mod 2 == 0) ? 7 : 4, _a2), 2);
			}
			break;
	}
}

// Seta saltitante sobre o alvo escolhido (+ anel no chão)
function seta_alvo(_x, _y) {
	var _b = sin(current_time / 110) * 3;
	var _cx = _x + 4, _cy = _y + 4;
	draw_set_color(c_black);
	draw_triangle(_cx - 8, _cy - 12 + _b, _cx + 8, _cy - 12 + _b, _cx, _cy + 1 + _b, false);
	draw_set_color(c_yellow);
	draw_triangle(_cx - 6, _cy - 11 + _b, _cx + 6, _cy - 11 + _b, _cx, _cy - 1 + _b, false);
	draw_set_color(c_white);
}

// Indicador de "é a vez deste inimigo"
function marca_turno(_x, _y) {
	var _p = 0.5 + 0.5 * sin(current_time / 150);
	draw_set_color(merge_colour(c_red, c_white, _p * 0.4));
	draw_triangle(_x + 8, _y + 8, _x, _y + 4, _x, _y + 12, false);
	draw_set_color(c_white);
}
