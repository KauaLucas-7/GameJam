// =====================================================================
//  CUTSCENE FINAL + CRÉDITOS
//  A Nexa e as colegas perdem as placas de metal e voltam a ser 100% humanas:
//  o corpo de robô era só o esforço de "se adaptar" a um lugar feito por e
//  para homens. Elas amadurecem ao perceber que só precisam ser elas mesmas.
// =====================================================================
display_set_gui_size(480, 270);
usar_fonte();
garantir_controle();
tocar_musica(snd_musica_final_bom);
cyber_init();

fase = "cena";   // "cena" -> "creditos"
t = 0;
anim = 0;

// Elenco: a Nexa no centro (x 240) e as colegas ao redor
elenco = [];
var _ids = ["clara", "beatriz", "lia", "sonia", "vera"];
var _xs  = [62, 118, 174, 306, 362];
for (var i = 0; i < array_length(_ids); i++) {
	array_push(elenco, { d: npc_dados(_ids[i]), x: _xs[i], prog: 0, ativo: false, atraso: 0 });
}
nexa = { x: 240, prog: 0, ativo: false, atraso: 0 };
pecas = [];     // placas de metal que caem
luz = 0;        // quanto a sala já "clareou"
brilho = 0;     // clarão do final

// Legendas da cena (q = quem fala; ev = evento disparado ao aparecer)
falas = [
	{ q: "",        t: "O molde se quebrou. No silêncio do último andar, as colegas da Nexa se reúnem." },
	{ q: "N",       t: "Olhem pra nós... Ainda tem tanto metal no nosso corpo." },
	{ q: "Lia",     t: "A gente foi trocando as peças, uma por uma. Só pra caber." },
	{ q: "",        t: "Então, devagar, as placas começam a cair.", ev: "despertar" },
	{ q: "Clara",   t: "Eu achava que precisava ser 'um dos caras' pra ser respeitada." },
	{ q: "Beatriz", t: "Eu culpava as outras pra me sentir segura." },
	{ q: "Sônia",   t: "Eu endureci pra sobreviver... e esqueci quem eu era." },
	{ q: "Vera",    t: "Eu duvidava das outras porque duvidavam de mim." },
	{ q: "N",       t: "O metal nunca fomos nós. Era o esforço de caber num lugar feito só pra eles." },
	{ q: "N",       t: "A gente não precisa se adaptar ao molde. Quem precisa mudar é o molde." },
	{ q: "Lia",     t: "Programadoras, engenheiras, cientistas. Inteiras. Do nosso jeito." },
	{ q: "",        t: "100% humanas. 100% elas mesmas.", ev: "brilho" }
];
fala_i = 0;
letras = 0;

// Créditos (h = título de seção, tt = título do jogo)
creditos = [
	{ s: "SHEBORG", tt: true },
	{ s: "Uma história sobre desigualdade de gênero na computação" },
	{ s: "" },
	{ s: "EQUIPE", h: true },
	{ s: "Gabriel - Arte Cenário" },
	{ s: "Kauã Lucas - Programação" },
	{ s: "Marcelo Rocha - Programação" },
	{ s: "Maria Letícia - Arte Personagens" },
	{ s: "Vítor Gabriel - Soundtrack + Roteiro" },
	{ s: "" },
	{ s: "EM HOMENAGEM A", h: true },
	{ s: "Ada Lovelace" },
	{ s: "Às programadoras do ENIAC" },
	{ s: "Grace Hopper" },
	{ s: "E a todas as mulheres que constroem a computação" },
	{ s: "" },
	{ s: "SE VOCÊ SOFRE ASSÉDIO NO TRABALHO", h: true },
	{ s: "Você não está sozinha. Denuncie." },
	{ s: "Ligue 180 - Central de Atendimento à Mulher" },
	{ s: "Ministério Público do Trabalho" },
	{ s: "" },
	{ s: "Feito com GameMaker" }
];
cred_y = 290;
cred_fim = false;
fade_cred = 0;

// Começa a soltar as placas de um personagem
soltar_pecas = function(_x) {
	repeat (7) array_push(pecas, {
		x: _x + random_range(-10, 10), y: 150 + random_range(-30, 20),
		vx: random_range(-1.2, 1.2), vy: random_range(-2.5, -0.5), r: random(360), vr: random_range(-8, 8), a: 1
	});
};

disparar = function(_ev) {
	if (_ev == "despertar") {
		nexa.ativo = true; nexa.atraso = 0;
		for (var k = 0; k < array_length(elenco); k++) { elenco[k].ativo = true; elenco[k].atraso = 40 + k * 28; }
	}
	if (_ev == "brilho") brilho = 1;
};
