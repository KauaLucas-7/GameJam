event_inherited();

// Ponto de interesse no mapa: arquivo, espelho, repositório ou ouvidoria.
// ponto_id vem da Creation Code da instância (ex.: ponto_id = "espelho_1";)
// e os textos ficam em scr_missoes (ponto_dados / ponto_interagir).
ponto_id = "";
dados = undefined;
anim = random(100);
raio = 25 + 20 * escala_sala();

interagir = function() {
	if (dados == undefined) return;
	iniciar_dialogo_linhas(ponto_interagir(ponto_id), "nada", -1);
};
