event_inherited();

// O andar sai do nome da room: rm_andar2 -> 2
andar = real(string_digits(room_get_name(room)));

// Chefe já vencido não aparece mais
if (variable_struct_exists(global.vencidos, "a" + string(andar))) {
	instance_destroy();
	exit;
}

texto_prompt = "[E] Enfrentar";
raio = 60 * escala_sala();
iniciando = false;
avistou = false;
anim = 0;

// modo "interagir": espera a Nexa falar com ele
// modo "perseguir": vai até a Nexa quando a vê, e a conversa começa sozinha
sprite_mapa = spr_python;
escala = 0.7;
modo = "interagir";
velocidade = 0;
raio_visao = 0;

switch (andar) {
	case 1: // Banco de Dados: fica parado esperando
		sprite_mapa = spr_BancoDB; escala = 0.85; modo = "interagir"; raio = 80 * escala_sala();
		break;
	case 2: // Python: rasteja até a Nexa
		sprite_mapa = spr_python; escala = 1.45; modo = "perseguir"; velocidade = 2.2; raio_visao = 260;
		break;
	case 3: // Chefe: "Olha só, quem chegou." e vem ao encontro dela
		sprite_mapa = spr_urso; escala = 1.0; modo = "perseguir"; velocidade = 1.6; raio_visao = 360;
		break;
}
prompt_y = -sprite_get_height(sprite_mapa) * escala * 0.5 - 4;

// A história é linear: só dá para enfrentar este chefe depois do anterior
liberado = function() {
	return (andar <= 1) || variable_struct_exists(global.vencidos, "a" + string(andar - 1));
};

iniciar = function() {
	if (iniciando) return;
	if (!liberado()) {
		iniciar_dialogo("bloqueado_" + string(andar), "nada", -1);
		return;
	}
	iniciando = true;
	iniciar_luta_andar(andar);
};

interagir = function() { iniciar(); };
