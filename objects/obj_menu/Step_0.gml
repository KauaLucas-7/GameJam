if (em_transicao()) exit;
anim++;
t++;
fundo_t++;
if (fundo_t > 420) { fundo_t = 0; fundo_i = (fundo_i + 1) mod array_length(fundos); }

var _cima  = keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"));
var _baixo = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _ok    = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var _volta = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);

switch (tela) {

	case "aviso":
		if (_ok && t > 45) { tela = "titulo"; t = 0; }
		break;

	case "titulo":
		if (_cima)  sel = (sel - 1 + array_length(opcoes)) mod array_length(opcoes);
		if (_baixo) sel = (sel + 1) mod array_length(opcoes);
		sel_anim = lerp(sel_anim, sel, 0.25);
		if (_ok && t > 20) {
			switch (sel) {
				case 0: jogo_novo(); tela = "historia"; q = 0; q_t = 0; letras = 0; break;   // partida zerada
				case 1: tela = "comojogar"; t = 0; break;
				case 2: tela = "creditos"; t = 0; break;
				case 3: game_end(); break;
			}
		}
		break;

	case "comojogar":
	case "creditos":
		if ((_ok || _volta) && t > 10) { tela = "titulo"; t = 0; }
		break;

	case "historia":
		q_t++;
		var _txt = quadros[q].txt;
		letras = min(string_length(_txt), letras + 0.9);
		if (_volta) { trocar_sala(rm_andar1); break; }   // Esc pula a introdução
		if (_ok && q_t > 15) {
			if (letras < string_length(_txt)) letras = string_length(_txt);
			else {
				q++;
				q_t = 0;
				letras = 0;
				if (q >= array_length(quadros)) { q = array_length(quadros) - 1; trocar_sala(rm_andar1); }
			}
		}
		break;
}
