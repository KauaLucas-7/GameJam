// Estado global do jogo.
// jogo_estado_inicial() roda ao abrir o jogo e de novo em "Novo jogo"
// (game_restart não reinicia as variáveis globais, então zeramos aqui).

function jogo_estado_inicial() {
	global.andar = 1;              // andar do próximo chefe (1 = Banco, 2 = Python, 3 = Urso)
	global.vencidos = {};          // chefes já vencidos: { a1: true, a2: true ... }
	global.cena_pendente = "";     // cena que toca quando a Nexa volta ao mapa

	// Ponto de nascimento da Nexa na próxima room (portas, lutas e oficina usam)
	global.usar_spawn = false;
	global.spawn_x = 0;
	global.spawn_y = 0;

	global.intro_feita = false;
	global.retorno_luta = -1;      // room de exploração para onde a luta volta
	global.oficina_retorno = -1;   // room de onde a Nexa entrou na oficina
	global.npc_entregou = {};      // NPCs que já deram o item: { id_do_npc: true }
	global.npc_falou = {};         // NPCs com quem a Nexa já conversou
	global.ver_paredes = false;    // F1 mostra as paredes invisíveis

	// Tutorial da exploração (cada etapa termina quando o jogador faz a ação)
	global.tut_etapa = 0;          // 0 andar | 1 conversar | 2 diário | 3 objetos | 4 chefe | 5 fim
	global.tut_dist = 0;           // quanto a Nexa já andou
	global.tut_t = 0;              // tempo na etapa atual
	global.tut_anim = 0;           // animação do painel
}
jogo_estado_inicial();

// Começa uma partida do zero (menu > Novo jogo)
function jogo_novo() {
	jogo_estado_inicial();
	missoes_estado_inicial();
	global.cyber_ready = false;    // refaz inventário e mods equipados
	cyber_init();
}

// --- Fonte com acentos ---
// fnt_jogo tem os caracteres do português, mas a imagem dela só é gerada
// pela IDE do GameMaker. Se ainda não foi gerada, usa a fonte padrão e
// troca as letras acentuadas por letras simples (para o texto não sumir).
global.fonte_ok = undefined;

function fonte_pronta() {
	if (global.fonte_ok == undefined) {
		var _info = font_get_info(fnt_jogo);
		global.fonte_ok = is_struct(_info) && variable_struct_exists(_info, "glyphs")
		               && is_struct(_info.glyphs) && variable_struct_names_count(_info.glyphs) > 0;
	}
	return global.fonte_ok;
}

function usar_fonte() {
	draw_set_font(fonte_pronta() ? fnt_jogo : -1);
}

function texto_seguro(_s) {
	if (fonte_pronta()) return _s;
	static _de   = "áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ";
	static _para = "aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN";
	var _r = "";
	for (var i = 1; i <= string_length(_s); i++) {
		var _c = string_char_at(_s, i);
		var _p = string_pos(_c, _de);
		_r += (_p > 0) ? string_char_at(_para, _p) : _c;
	}
	return _r;
}

// Escala para textos desenhados no mapa: mantém o mesmo tamanho na tela
// em qualquer sala (a câmera mostra a sala inteira, então o zoom muda por sala).
function escala_mundo() {
	return camera_get_view_width(view_camera[0]) / 640;
}

// Texto no mapa com contorno, centralizado em (_x, _y) pela base
function texto_mundo(_x, _y, _txt, _cor = c_white) {
	var _k = escala_mundo();
	_txt = texto_seguro(_txt);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_color(c_black);
	draw_text_transformed(_x + _k, _y + _k, _txt, _k, _k, 0);
	draw_set_color(_cor);
	draw_text_transformed(_x, _y, _txt, _k, _k, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

// --- Transições entre salas (obj_controle) ---
// _estilo: "fade" (card com o nome do ambiente) ou "batalha" (clarão e listras)
function trocar_sala(_sala, _estilo = "fade") {
	if (!instance_exists(obj_controle)) instance_create_depth(0, 0, -15000, obj_controle);
	with (obj_controle) {
		if (trans_fase != 0) return;
		trans_destino = _sala;
		trans_estilo = _estilo;
		trans_fase = 1;
		trans_t = 0;
	}
}

// Algo está tocando por cima do jogo? (transição ou cena de missão concluída)
function em_transicao() {
	return instance_exists(obj_controle) && (obj_controle.trans_fase != 0 || obj_controle.cena_ativa);
}

// Nome do ambiente mostrado no card de transição
function titulo_sala(_sala) {
	switch (_sala) {
		case rm_andar1:    return ["1º ANDAR", "Dados e Registros"];
		case rm_corredor1: return ["ESCADA DE SERVIÇO", "Entre o 1º e o 2º andar"];
		case rm_andar2:    return ["2º ANDAR", "Desenvolvimento"];
		case rm_corredor2: return ["ESCADA DE SERVIÇO", "Entre o 2º e o 3º andar"];
		case rm_andar3:    return ["3º ANDAR", "A sala do Chefe"];
		case rm_final:     return ["NEXUS TECH", "Depois do molde"];
	}
	return undefined;
}

function garantir_controle() {
	if (!instance_exists(obj_controle)) instance_create_depth(0, 0, -15000, obj_controle);
}

// --- Tutorial da exploração (estado em jogo_estado_inicial) ---
function tut_texto(_e) {
	switch (_e) {
		case 0: return "Use WASD ou as setas para andar.";
		case 1: return "Chegue perto de alguém e aperte [E] para conversar.";
		case 2: return "Aperte [TAB] para abrir o diário de missões.";
		case 3: return "Arquivos brilhantes, espelhos e terminais também respondem ao [E].";
		case 4: return "Enfrente o Banco de Dados, perto da mesa de reunião: chegue perto e aperte [E].";
		case 5: return "Tutorial concluído! Bom jogo.";
	}
	return "";
}

function tut_avancar(_de) {
	if (global.tut_etapa != _de) return;
	global.tut_etapa++;
	global.tut_t = 0;
	global.tut_anim = 0;
}

// Começa a luta do chefe deste andar, guardando onde a Nexa estava
function iniciar_luta_andar(_andar) {
	tut_avancar(4);   // tutorial: enfrentou o chefe
	global.andar = _andar;
	global.retorno_luta = room;
	if (instance_exists(obj_Nexa)) {
		global.spawn_x = obj_Nexa.x;
		global.spawn_y = obj_Nexa.y;
	}
	var _sala = rm_python_fight;
	if (_andar == 1) _sala = rom_banco_fight;
	if (_andar == 3) _sala = rom_urso_fight;
	iniciar_dialogo("andar" + string(_andar) + "_pre", "luta", _sala);
}
