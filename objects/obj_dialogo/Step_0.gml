if (espera > 0) { espera--; exit; }
if (em_transicao()) exit;   // espera a transição de sala terminar
if (i >= array_length(linhas)) { instance_destroy(); exit; }

var _fala = linhas[i];

// Efeitos da linha (3º item opcional): "tremer" ou "flash"
if (linha_iniciada != i) {
	linha_iniciada = i;
	// Vozes: os chefes de dados e Python falam; narração e Nexa ficam sem voz
	if (_fala[0] == "BD") som(snd_falas_banco);
	if (_fala[0] == "PY") som(snd_falas_python);
	// Robôs do escritório (NPCs): voz feminina ou masculina pelo nome
	if (!array_contains(["", "N", "U", "BD", "PY"], _fala[0])) {
		if (array_contains(["Beatriz", "Clara", "Lia", "Sônia", "Vera"], _fala[0])) som(snd_robo_femea);
		else som(snd_robo_macho);
	}
	letras = 0;
	if (array_length(_fala) > 2) {
		if (_fala[2] == "tremer") tremor = 18;
		if (_fala[2] == "flash")  clarao = 1;
	}
	if (_fala[0] != falante_ant) { ret_anim = 0; falante_ant = _fala[0]; }
}

abrir = min(1, abrir + 0.15);
ret_anim = min(1, ret_anim + 0.12);
if (tremor > 0) tremor--;
clarao = max(0, clarao - 0.05);
letras = min(string_length(_fala[1]), letras + vel_letras);

if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
	if (letras < string_length(_fala[1])) {
		letras = string_length(_fala[1]);   // 1º aperto: mostra a linha inteira
	} else {
		i++;
		if (i >= array_length(linhas)) {
			if (acao == "luta" && sala != -1) trocar_sala(sala, "batalha");
			if (acao == "final") trocar_sala(rm_final, "fade");
			if (acao == "creditos") iniciar_dialogo("creditos", "fim", -1);
			if (acao == "fim") { if (eh_web()) game_restart(); else game_end(); }
			instance_destroy();
		}
	}
}
