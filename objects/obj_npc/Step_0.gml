if (dados == undefined) {
	dados = npc_dados(npc_id);
	// Some do mapa depois que a missão ligada a ele termina (ex.: Otávio após a denúncia)
	if (variable_struct_exists(dados, "sumir_se") && missao(dados.sumir_se).estado == 2) {
		instance_destroy();
		exit;
	}
}
anim++;

// NPC que aborda a Nexa sozinho quando ela passa perto (só uma vez)
if (variable_struct_exists(dados, "auto") && dados.auto && !auto_feito
    && !variable_struct_exists(global.npc_falou, npc_id)
    && instance_exists(obj_Nexa) && !instance_exists(obj_dialogo)
    && point_distance(x, y, obj_Nexa.x, obj_Nexa.y) < 70) {
	auto_feito = true;
	interagir();
}
