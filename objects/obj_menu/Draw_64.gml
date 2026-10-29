// ===== Fundo: salas da Nexus Tech passando devagar =====
var _spr = fundos[fundo_i];
var _sc = 480 / sprite_get_width(_spr) * 1.15;
var _h = sprite_get_height(_spr) * _sc;
var _pan = fundo_t / 420;
gpu_set_texfilter(true);
draw_sprite_ext(_spr, 0, -30 * _pan, (270 - _h) * _pan, _sc, _sc, 0, c_white, 1);
// fade entre uma sala e outra
var _fa = (fundo_t < 40) ? 1 - fundo_t / 40 : ((fundo_t > 380) ? (fundo_t - 380) / 40 : 0);
gpu_set_texfilter(false);
draw_set_alpha(0.55 + 0.45 * _fa);
draw_set_color(c_black);
draw_rectangle(0, 0, 480, 270, false);
// linhas de scan
draw_set_alpha(0.06);
draw_set_color(c_aqua);
for (var l = (anim div 2) mod 4; l < 270; l += 4) draw_line(0, l, 480, l);
draw_set_alpha(1);
draw_set_color(c_white);

var _fr = floor(anim / 10) mod sprite_get_number(spr_Nexa);

// =====================================================================
//  VERSÃO WEB: "Clique para começar" (dá o foco do teclado ao jogo)
// =====================================================================
if (tela == "clique") {
	draw_set_alpha(0.6);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text_transformed(240, 92, "SHEBORG", 3.4, 3.4, 0);
	draw_set_color(c_aqua);
	draw_text(240, 140, texto_seguro("Quebre o molde."));
	draw_set_alpha(0.5 + 0.5 * sin(current_time / 200));
	draw_set_color(c_yellow);
	draw_text(240, 190, texto_seguro("Clique para começar"));
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
}

// =====================================================================
//  AVISO DE CONTEÚDO SENSÍVEL (primeira tela do jogo)
// =====================================================================
if (tela == "aviso") {
	var _a = ease_out(t / 40);
	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(_a);
	draw_set_color(make_colour_rgb(10, 12, 24));
	draw_roundrect(40, 26, 440, 244, false);
	draw_set_color(c_yellow);
	draw_roundrect(40, 26, 440, 244, true);

	draw_set_halign(fa_center);
	draw_text_transformed(240, 36, texto_seguro("AVISO DE CONTEÚDO"), 1.4, 1.4, 0);
	draw_set_color(c_white);
	var _txt = [
		"Este jogo aborda temas sensíveis:",
		"machismo e desigualdade de gênero no trabalho,",
		"assédio e importunação sexual, e suicídio.",
		"As cenas não são explícitas.",
		"",
		"Se algum desses temas mexe com você,",
		"jogue no seu ritmo e faça pausas quando precisar."
	];
	for (var i = 0; i < array_length(_txt); i++) {
		draw_text_transformed(240, 66 + i * 13, texto_seguro(_txt[i]), 0.85, 0.85, 0);
	}
	draw_set_color(c_aqua);
	draw_text_transformed(240, 164, texto_seguro("Precisa conversar? CVV: ligue 188"), 0.8, 0.8, 0);
	draw_text_transformed(240, 177, texto_seguro("24h, gratuito e sigiloso - cvv.org.br"), 0.8, 0.8, 0);
	draw_text_transformed(240, 194, texto_seguro("Violência contra a mulher: Ligue 180"), 0.8, 0.8, 0);
	if (t > 45) {
		draw_set_alpha(_a * (0.5 + 0.5 * sin(current_time / 200)));
		draw_set_color(c_ltgray);
		draw_text(240, 220, "[ENTER] continuar");
	}
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// =====================================================================
if (tela == "titulo" || tela == "comojogar" || tela == "creditos") {
	// Robôs ao fundo e a Nexa com as peças de metal "piscando"
	var _rx = [292, 330, 416, 454];
	for (var i = 0; i < array_length(robos); i++) {
		desenhar_robo(_rx[i], 196 - (i mod 2) * 6, 1.4, robos[i], anim + i * 30, false, 0.35);
	}
	draw_set_alpha(0.25 + 0.1 * sin(anim * 0.05));
	draw_set_color(c_aqua);
	draw_circle(372, 150, 70, false);
	draw_set_alpha(1);
	draw_sprite_ext(spr_Nexa, _fr, 372, 150, 3, 3, 0, c_white, 1);
	var _ordem = ["legs", "torso", "arms"];
	for (var s = 0; s < 3; s++) {
		var _ov = global.mod_overlay[$ _ordem[s]];
		var _glitch = ((anim + s * 37) mod 160 < 80) ? 0.85 : 0.15 + 0.1 * random(1);
		draw_sprite_ext(_ov, _fr mod sprite_get_number(_ov), 372, 150, 3, 3, 0, c_white, _glitch);
	}
}

if (tela == "titulo") {
	// Título com efeito de falha (glitch)
	var _g = ((anim mod 120) < 6);
	var _gx = _g ? irandom_range(-3, 3) : 0;
	draw_set_color(c_red);
	draw_set_alpha(0.7);
	draw_text_transformed(26 + _gx - 2, 34, "SHEBORG", 3.4, 3.4, 0);
	draw_set_color(c_aqua);
	draw_text_transformed(26 - _gx + 2, 34, "SHEBORG", 3.4, 3.4, 0);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text_transformed(26, 34, "SHEBORG", 3.4, 3.4, 0);
	draw_set_color(c_aqua);
	draw_text(30, 82, texto_seguro("Quebre o molde."));

	// Opções com barra de seleção deslizando
	var _oy = 118;
	draw_set_alpha(0.35 + 0.15 * sin(anim * 0.1));
	draw_set_color(c_aqua);
	draw_roundrect(24, _oy - 3 + sel_anim * 24, 180, _oy + 17 + sel_anim * 24, false);
	draw_set_alpha(1);
	draw_roundrect(24, _oy - 3 + sel_anim * 24, 180, _oy + 17 + sel_anim * 24, true);
	for (var i = 0; i < array_length(opcoes); i++) {
		var _s = (i == sel);
		draw_set_color(_s ? c_yellow : c_white);
		draw_text(_s ? 40 : 34, _oy + i * 24, texto_seguro((_s ? "> " : "") + opcoes[i]));
	}

	draw_set_color(c_ltgray);
	draw_text_transformed(26, 252, texto_seguro("[Cima/Baixo] escolher    [Enter] confirmar"), 0.75, 0.75, 0);
	draw_set_halign(fa_right);
	draw_set_color(c_gray);
	draw_text_transformed(474, 238, texto_seguro("Um jogo sobre desigualdade de gênero na computação"), 0.7, 0.7, 0);
	draw_set_halign(fa_left);
}

// =====================================================================
if (tela == "comojogar" || tela == "creditos") {
	draw_set_alpha(0.92);
	draw_set_color(make_colour_rgb(10, 12, 24));
	draw_roundrect(16, 14, 460, 256, false);
	draw_set_alpha(1);
	draw_set_color(c_aqua);
	draw_roundrect(16, 14, 460, 256, true);

	var _linhas;
	if (tela == "comojogar") {
		_linhas = [
			["h", "EXPLORAÇÃO"],
			["", "WASD / Setas: andar"],
			["", "E: conversar e interagir"],
			["", "Q (ou TAB): diário de missões"],
			["", "Portas brilhantes levam a outros ambientes"],
			["", "Terminal MOD: equipar implantes e ferramentas"],
			["h", "BATALHA"],
			["", "Atacar: ESPAÇO com o marcador no centro da barra"],
			["", "Defender: ESPAÇO no instante em que o golpe acerta"],
			["", "Habilidades gastam MP; fraquezas dão dano extra"],
			["", "Acertos perfeitos enchem a energia do Especial"],
			["h", "MISSÕES"],
			["", "Ajude as colegas e descubra a história:"],
			["", "cada missão dá um bônus permanente."]
		];
	} else {
		_linhas = [
			["h", "EQUIPE"],
			["", "Gabriel - Arte Cenário"],
			["", "Kauã Lucas - Programação"],
			["", "Marcelo Rocha - Programação"],
			["", "Maria Letícia - Arte Personagens"],
			["", "Vítor Gabriel - Soundtrack + Roteiro"],
			["h", "EM HOMENAGEM A"],
			["", "Ada Lovelace, as programadoras do ENIAC,"],
			["", "Grace Hopper e todas as mulheres da computação"],
			["h", "ASSÉDIO NO TRABALHO"],
			["", "Você não está sozinha. Ligue 180."]
		];
	}
	var _y = 24;
	for (var i = 0; i < array_length(_linhas); i++) {
		var _ap = ease_out((t - i * 3) / 12);
		draw_set_alpha(_ap);
		if (_linhas[i][0] == "h") {
			draw_set_color(c_yellow);
			draw_text(30 + 10 * (1 - _ap), _y + 2, texto_seguro(_linhas[i][1]));
			_y += 17;
		} else {
			draw_set_color(c_white);
			draw_text_transformed(38 + 10 * (1 - _ap), _y, texto_seguro(_linhas[i][1]), 0.8, 0.8, 0);
			_y += 13;
		}
	}
	draw_set_alpha(1);
	draw_set_color(c_ltgray);
	draw_text_transformed(30, 240, texto_seguro("[Backspace/Enter] voltar"), 0.75, 0.75, 0);
}

// =====================================================================
//  INTRODUÇÃO DA HISTÓRIA
// =====================================================================
if (tela == "historia") {
	var _qd = quadros[q];
	var _e = ease_out(q_t / 30);
	draw_set_alpha(0.5);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	draw_set_alpha(1);

	switch (_qd.vis) {
		case "predio":
			draw_set_halign(fa_center);
			draw_set_color(c_aqua);
			draw_set_alpha(_e);
			draw_text_transformed(240, 80, "NEXUS TECH", 2.6, 2.6, 0);
			draw_set_color(c_ltgray);
			draw_text(240, 120, texto_seguro("\"Inovação para todos\""));
			draw_set_halign(fa_left);
			draw_set_alpha(1);
			break;

		case "equipe":
			var _ids = ["ricardo", "paulo", "julio", "fabio", "rogerio", "vitor"];
			var _ex = [50, 105, 160, 320, 375, 430];
			for (var i = 0; i < 6; i++) {
				// os robôs se aproximam e cercam a Nexa
				desenhar_robo(lerp(_ex[i], 240 + (_ex[i] - 240) * 0.8, _e), 150, 1.5, npc_dados(_ids[i]), anim + i * 20, false, 0.85);
			}
			draw_set_alpha(0.3);
			draw_set_color(c_yellow);
			draw_circle(240, 140, 46, false);
			draw_set_alpha(1);
			draw_sprite_ext(spr_Nexa, _fr, 240, 136, 2.2, 2.2, 0, c_white, 1);
			break;

		case "credito":
			draw_sprite_ext(spr_Nexa, _fr, 140, 136, 2.2, 2.2, 0, c_white, 1);
			desenhar_robo(340, 136, 2, npc_dados("paulo"), anim);
			// o "cartão" do projeto vai da Nexa para o Paulo
			var _mv = ease_out((q_t - 40) / 60);
			var _cx = lerp(170, 300, _mv), _cy = 96 - 20 * sin(pi * _mv);
			draw_set_color(merge_colour(c_aqua, c_orange, _mv));
			draw_roundrect(_cx - 28, _cy - 10, _cx + 28, _cy + 10, false);
			draw_set_color(c_black);
			draw_set_halign(fa_center); draw_set_valign(fa_middle);
			draw_text_transformed(_cx, _cy, "PROJETO", 0.65, 0.65, 0);
			draw_set_halign(fa_left); draw_set_valign(fa_top);
			if (_mv >= 1) { draw_set_color(c_orange); draw_text(270, 66, texto_seguro("crédito: Paulo")); }
			break;

		case "molde":
			draw_sprite_ext(spr_Nexa, _fr, 240, 132, 3, 3, 0, c_white, 1);
			var _ordem = ["legs", "torso", "arms"];
			for (var s = 0; s < 3; s++) {
				var _ini = 30 + s * 45;
				var _a = clamp((q_t - _ini) / 25, 0, 1);
				var _ov = global.mod_overlay[$ _ordem[s]];
				draw_sprite_ext(_ov, _fr mod sprite_get_number(_ov), 240, 132, 3, 3, 0, c_white, _a);
				if (q_t > _ini && q_t < _ini + 12) {   // clarão de cada peça
					draw_set_alpha(1 - (q_t - _ini) / 12);
					draw_set_color(c_white);
					draw_circle(240, 132, 60, false);
					draw_set_alpha(1);
				}
			}
			break;

		case "chefes":
			var _cor = merge_colour(c_white, c_red, 0.55);
			draw_sprite_ext(spr_BancoDB, 0, 110, 132 + 20 * (1 - _e), 0.42, 0.42, 0, _cor, _e);
			draw_sprite_ext(spr_python, _fr mod sprite_get_number(spr_python), 240, 126 + 20 * (1 - ease_out((q_t - 15) / 30)), 1.2, 1.2, 0, _cor, ease_out((q_t - 15) / 30));
			draw_sprite_ext(spr_urso, _fr mod sprite_get_number(spr_urso), 370, 120 + 20 * (1 - ease_out((q_t - 30) / 30)), 0.75, 0.75, 0, _cor, ease_out((q_t - 30) / 30));
			draw_set_halign(fa_center);
			draw_set_color(c_red);
			draw_set_alpha(ease_out((q_t - 50) / 20));
			draw_text(110, 196, "1º ANDAR"); draw_text(240, 196, "2º ANDAR"); draw_text(370, 196, "3º ANDAR");
			draw_set_alpha(1);
			draw_set_halign(fa_left);
			break;

		case "decisao":
			var _r = 20 + q_t * 1.5;
			draw_set_alpha(max(0, 0.5 - q_t / 200));
			draw_set_color(c_aqua);
			draw_circle(240, 132, _r, true);
			draw_circle(240, 132, _r * 0.7, true);
			draw_set_alpha(0.25);
			draw_circle(240, 132, 60, false);
			draw_set_alpha(1);
			draw_sprite_ext(spr_Nexa, _fr, 240, 132, 3, 3, 0, c_white, 1);
			var _ordem2 = ["legs", "torso", "arms"];
			for (var s = 0; s < 3; s++) {
				var _ov2 = global.mod_overlay[$ _ordem2[s]];
				draw_sprite_ext(_ov2, _fr mod sprite_get_number(_ov2), 240, 132, 3, 3, 0, c_white, 0.6 + 0.4 * sin(anim * 0.3 + s));
			}
			break;
	}

	// barras de cinema + legenda
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 24, false);
	draw_rectangle(0, 214, 480, 270, false);
	var _txt = texto_seguro(string_copy(_qd.txt, 1, floor(letras)));
	draw_set_halign(fa_center);
	draw_set_color(make_colour_rgb(220, 224, 236));
	draw_text_ext(240, 222, _txt, 14, 440);
	draw_set_halign(fa_left);
	// progresso dos quadros
	for (var i = 0; i < array_length(quadros); i++) {
		draw_set_color((i <= q) ? c_aqua : c_dkgray);
		draw_rectangle(200 + i * 14, 10, 210 + i * 14, 13, false);
	}
	draw_set_color(c_gray);
	draw_set_halign(fa_right);
	draw_text_transformed(474, 8, texto_seguro("[ESPAÇO] continuar   [BACKSPACE] pular"), 0.7, 0.7, 0);
	draw_set_halign(fa_left);
}
draw_set_alpha(1);
draw_set_color(c_white);
