event_inherited();

// npc_id vem da Creation Code da instância (ex.: npc_id = "lia";).
// A Creation Code roda depois deste evento, por isso os dados são lidos no 1º Step.
npc_id = "";
dados = undefined;
anim = random(100);

interagir = function() {
	if (dados == undefined) return;
	cyber_init();

	var _linhas = dados.falas;
	var _ja_falou = variable_struct_exists(global.npc_falou, npc_id);
	var _tem_item = (dados.item != "" && !variable_struct_exists(global.npc_entregou, npc_id));

	if (_tem_item) {
		// 1ª conversa com item: entrega e avisa
		cyber_give(dados.item);
		global.npc_entregou[$ npc_id] = true;
		var _m = global.mods[$ dados.item];
		_linhas = array_concat(_linhas, [["", "Nexa recebeu: " + _m.name + " (" + _m.desc + "). Equipe num terminal de oficina."]]);
	}
	else if (_ja_falou && array_length(dados.depois) > 0) {
		_linhas = dados.depois;
	}

	// Missões podem trocar ou completar as falas (scr_missoes)
	_linhas = npc_evento(npc_id, _linhas);

	global.npc_falou[$ npc_id] = true;
	iniciar_dialogo_linhas(_linhas, "nada", -1);
};

auto_feito = false;   // evento automático (NPC que aborda a Nexa) já aconteceu?
