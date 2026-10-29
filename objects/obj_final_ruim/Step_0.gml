if (em_transicao()) exit;
anim++;
t++;
var _ok = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);

// ----- Tela final: tentar de novo ou voltar ao menu -----
if (fim) {
	fim_t++;
	if (fim_t > 40) {
		if (keyboard_check_pressed(vk_enter)) {
			// volta para a luta contra o Chefe, para recusar o molde
			global.andar = 3;
			global.retorno_luta = rm_andar3;
			trocar_sala(rom_urso_fight, "batalha");
		}
		if (keyboard_check_pressed(vk_escape)) game_restart();
	}
	exit;
}

// ----- Legendas -----
q_t++;
var _l = legendas[q];
letras = min(string_length(_l.txt), letras + 0.8);

// notificações da sobrecarga
if (_l.vis == "sobrecarga" && q_t mod 10 == 0) {
	array_push(avisos, { x: random_range(20, 400), y: -16, vy: random_range(1.2, 2.4),
	                     s: avisos_txt[irandom(array_length(avisos_txt) - 1)], pousou: false });
}
for (var i = 0; i < array_length(avisos); i++) {
	var _a = avisos[i];
	if (!_a.pousou) { _a.y += _a.vy; if (_a.y > 190 - (i div 6) * 12) _a.pousou = true; }
}

if (_ok && q_t > 25) {
	if (letras < string_length(_l.txt)) letras = string_length(_l.txt);
	else {
		q++;
		q_t = 0;
		letras = 0;
		if (q >= array_length(legendas)) { q = array_length(legendas) - 1; fim = true; fim_t = 0; }
	}
}
