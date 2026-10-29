// Base de tudo que a Nexa pode usar com [E]: NPCs, chefes e terminais.
// Os filhos chamam event_inherited() e trocam interagir / texto_prompt.
raio = 30 + 25 * escala_sala();   // distância máxima para interagir (personagens maiores)
texto_prompt = "[E] Falar";
prompt_y = 28 - 72 * escala_sala();   // aviso acima da cabeça (pés em y + 28)
depth = -y;                 // quem está mais embaixo na tela fica na frente

interagir = function() {};

nexa_perto = function() {
	return instance_exists(obj_Nexa) && point_distance(x, y, obj_Nexa.x, obj_Nexa.y) <= raio;
};
