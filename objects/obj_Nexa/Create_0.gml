velocidade = 3;
image_speed = 0;

// Se veio por uma porta, nasce perto dela
if (variable_global_exists("usar_spawn") && global.usar_spawn) {
	x = global.spawn_x;
	y = global.spawn_y;
	global.usar_spawn = false;
}

// Cena pós-luta que ficou pendente (vinda do obj_battle)
if (variable_global_exists("cena_pendente") && global.cena_pendente != "") {
	var _cena = global.cena_pendente;
	global.cena_pendente = "";
	iniciar_dialogo(_cena, "nada", -1);
}
