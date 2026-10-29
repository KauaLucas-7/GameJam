if (dados == undefined) {
	dados = ponto_dados(ponto_id);
	texto_prompt = dados.prompt;
}
anim++;

// Arquivo já lido some do mapa (depois que o diálogo fecha)
if (dados.tipo == "arquivo" && ponto_usado(ponto_id) && !instance_exists(obj_dialogo)) instance_destroy();
