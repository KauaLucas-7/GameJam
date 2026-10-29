// Paredes invisíveis de cada sala, medidas sobre a arte de fundo.
// Cada item é [x1, y1, x2, y2] em pixels da room.
// Para conferir no jogo: aperte F1 para ver as paredes em vermelho.
// (O 2º andar e as escadas já têm paredes colocadas no editor de rooms.)

function paredes_da_sala(_sala) {
	switch (_sala) {

		case rm_andar1: return [
			// bordas da sala
			[0, 0, 1254, 240],        // parede de cima (janelas, servidores, painel)
			[0, 0, 100, 1254],        // parede da esquerda
			[1165, 0, 1254, 1254],    // parede da direita
			[0, 1095, 570, 1254],     // parede de baixo (esquerda da porta)
			[690, 1095, 1254, 1254],  // parede de baixo (direita da porta)
			// móveis
			[268, 240, 478, 335],     // mesa com monitores (alto, esquerda)
			[875, 240, 1075, 325],    // copa
			[1080, 240, 1165, 300],   // geladeira
			[100, 375, 150, 745],     // racks da esquerda
			[100, 835, 150, 960],     // rack baixo da esquerda
			[235, 450, 465, 695],     // baias de trabalho
			[795, 390, 1065, 575],    // sofás e mesa de centro
			[1100, 570, 1165, 990],   // armário da direita
			[1020, 715, 1080, 890],   // impressora
			[605, 705, 760, 945],     // mesa de reunião
			[160, 905, 345, 1010],    // mesa de baixo (esquerda)
			[505, 1035, 545, 1090],   // vaso ao lado da porta
			[705, 1035, 745, 1090]    // vaso ao lado da porta
		];

		case rm_andar3: return [
			// bordas da sala
			[0, 0, 1448, 175],        // parede de cima
			[0, 0, 105, 1086],        // parede da esquerda
			[1385, 0, 1448, 1086],    // parede da direita
			[0, 990, 645, 1086],      // parede de baixo (esquerda da porta)
			[800, 990, 1448, 1086],   // parede de baixo (direita da porta)
			// móveis
			[255, 175, 490, 295],     // mesa do Chefe
			[560, 175, 630, 215],     // estante
			[945, 175, 1250, 265],    // copa
			[1255, 175, 1320, 265],   // geladeira
			[205, 385, 475, 690],     // baias de trabalho
			[920, 305, 1225, 525],    // sofás
			[670, 595, 835, 860],     // mesa de reunião
			[150, 775, 350, 890],     // mesa de baixo (esquerda)
			[1170, 635, 1230, 765],   // impressora
			[1255, 560, 1385, 900],   // armários da direita
			[585, 920, 630, 985],     // vaso ao lado da porta
			[810, 920, 855, 985]      // vaso ao lado da porta
		];
	}
	return [];
}

// Cria as paredes da sala atual (chamado pela Nexa ao entrar)
function paredes_criar() {
	var _lista = paredes_da_sala(room);
	for (var i = 0; i < array_length(_lista); i++) {
		var _r = _lista[i];
		var _p = instance_create_depth(_r[0], _r[1], 0, obj_parede);
		_p.image_xscale = (_r[2] - _r[0]) / 32;   // spr_parede tem 32x32
		_p.image_yscale = (_r[3] - _r[1]) / 32;
	}
}
