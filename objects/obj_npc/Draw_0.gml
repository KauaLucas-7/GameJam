if (dados == undefined) exit;

// Funcionário(a)-robô em escala proporcional à sala, pés fixos em y + 28
var _s = escala_sala();
desenhar_robo(x, y + 28 - 28 * _s, _s, dados, anim);

// "!" amarelo: tem um item para entregar
if (dados.item != "" && !variable_struct_exists(global.npc_entregou, npc_id) && !nexa_perto()) {
	texto_mundo(x, y + 28 - 70 * _s + sin(anim * 0.1) * 2, "!", c_yellow);
}

draw_set_color(c_white);
event_inherited();   // aviso [E]
