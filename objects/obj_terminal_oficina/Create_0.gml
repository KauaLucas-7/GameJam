event_inherited();

// Terminal no mapa que leva à oficina de modificações
texto_prompt = "[E] Oficina";
anim = 0;

interagir = function() {
	global.oficina_retorno = room;
	global.spawn_x = x;
	global.spawn_y = y + 64;   // volta na frente do terminal
	trocar_sala(rm_oficina);
};
