// O GameMaker pode reiniciar o tamanho da interface ao criar/redimensionar a janela:
// reaplica sempre para que cards, diálogos e menus fiquem em 480x270.
if (display_get_gui_width() != 480 || display_get_gui_height() != 270) display_set_gui_size(480, 270);

// Web: encaixa o jogo na aba do navegador, sem cortar e sem distorcer (16:9)
if (eh_web() && (browser_width != web_w || browser_height != web_h)) {
	web_w = browser_width;
	web_h = browser_height;
	var _esc = min(web_w / 1440, web_h / 810);
	window_set_size(max(1, floor(1440 * _esc)), max(1, floor(810 * _esc)));
	window_center();
}

var _ok = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);

// ===== Transição entre salas =====
if (trans_fase == 1) {
	trans_t++;
	var _fim = (trans_estilo == "batalha") ? 36 : 20;
	if (trans_t >= _fim) {
		room_goto(trans_destino);
		if (trans_estilo == "batalha") {
			trans_fase = 2; trans_t = 0; trans_titulo = undefined; trans_dur = 24;
		} else {
			iniciar_card(trans_destino);
		}
	}
}
else if (trans_fase == 2) {
	// Abertura do jogo: o jogo começa a rodar antes de a janela aparecer;
	// o card só anda quando a janela já está na tela (em foco)
	if (!(abertura && !window_has_focus())) trans_t++;
	// Espaço/Enter adianta o card do ambiente
	if (trans_titulo != undefined && trans_t > 30 && trans_t < trans_dur - 25 && _ok) trans_t = trans_dur - 25;
	if (trans_t >= trans_dur) { trans_fase = 0; abertura = false; }
}

// ===== Avisos de missão (fila em scr_missoes) =====
if (aviso == undefined) {
	if (array_length(global.fila_missoes) > 0 && trans_fase == 0
	    && !instance_exists(obj_dialogo) && !instance_exists(obj_battle)) {
		aviso = global.fila_missoes[0];
		array_delete(global.fila_missoes, 0, 1);
		aviso_t = 0;
		cena_ativa = (aviso.tipo == "concluida");
		if (cena_ativa) {
			particulas = [];
			repeat (45) array_push(particulas, {
				x: random(480), y: 270 + random(120), v: random_range(0.5, 1.8),
				s: random_range(1, 2.6), c: choose(c_yellow, c_aqua, c_white, c_fuchsia), r: random(360)
			});
		}
	}
} else {
	aviso_t++;
	var _dur = aviso_duracao(aviso.tipo);
	if (cena_ativa && aviso_t > 90 && aviso_t < _dur - 30 && _ok) aviso_t = _dur - 30;
	if (aviso_t >= _dur) { aviso = undefined; cena_ativa = false; }
	for (var i = 0; i < array_length(particulas); i++) {
		var _p = particulas[i];
		_p.y -= _p.v;
		_p.r += 3;
		if (_p.y < -10) _p.y = 280;
	}
}
