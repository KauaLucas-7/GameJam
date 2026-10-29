if (ativado || instance_exists(obj_dialogo)) exit;

if (tipo == "intro") {
	if (!variable_global_exists("intro_feita")) global.intro_feita = false;
	if (!global.intro_feita) {
		global.intro_feita = true;
		ativado = true;
		iniciar_dialogo("intro", "nada", -1);
	}
	instance_destroy();
	exit;
}

// tipo "luta": ao encostar na Nexa
if (place_meeting(x, y, obj_Nexa)) {
	ativado = true;
	global.andar = andar_alvo;
	var _sala = rm_python_fight;
	if (andar_alvo == 1) _sala = rom_banco_fight;
	if (andar_alvo == 3) _sala = rom_urso_fight;
	iniciar_dialogo("andar" + string(andar_alvo) + "_pre", "luta", _sala);
}
