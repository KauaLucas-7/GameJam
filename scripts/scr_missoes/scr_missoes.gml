// =====================================================================
//  MISSÕES SECUNDÁRIAS — autoconhecimento e empoderamento no trabalho
// =====================================================================
// estado: 0 = ainda não descoberta | 1 = ativa | 2 = concluída
// As recompensas viram bônus permanentes da Nexa nas batalhas (global.bonus).

// Estado das missões: roda ao abrir o jogo e em "Novo jogo" (jogo_novo)
function missoes_estado_inicial() {
	// total = passos para concluir (barra de progresso) | sobre = texto do diário
	global.missoes = {
		memoria:  { titulo: "Memória Apagada",   estado: 0, prog: 0, total: 3, objetivo: "", recompensa: "+3 ATK",
		            sobre: "O Banco de Dados 'perdeu' os registros das mulheres que criaram a computação. Recupere a memória delas." },
		voz:      { titulo: "Voz Própria",       estado: 0, prog: 0, total: 2, objetivo: "", recompensa: "+10 HP máximo",
		            sobre: "Paulo quer apresentar a sua ideia como se fosse dele. Reivindique o que é seu." },
		rede:     { titulo: "Rede de Apoio",     estado: 0, prog: 0, total: 4, objetivo: "", recompensa: "+3 DEF",
		            sobre: "Mulheres também aprendem a repetir o machismo. Converse, escute e construa uma rede de apoio." },
		denuncia: { titulo: "Não é Brincadeira", estado: 0, prog: 0, total: 1, objetivo: "", recompensa: "+25 de energia no início das lutas",
		            sobre: "Importunação sexual não é brincadeira, é crime. Você tem o direito de denunciar, com ou sem testemunhas." },
		espelho:  { titulo: "Reflexos",          estado: 0, prog: 0, total: 3, objetivo: "", recompensa: "Habilidade Autoconfiança, +5 MP",
		            sobre: "Entre tantas vozes dizendo quem você deve ser, encontre a sua." }
	};
	global.fila_missoes = [];   // animações esperando para aparecer (obj_controle)
	global.missoes_ordem = ["memoria", "voz", "rede", "denuncia", "espelho"];
	
	global.bonus = { atk: 0, def: 0, hp: 0, mp: 0, energia: 0 };
	global.skill_autoconfianca = false;   // habilidade liberada pela missão "Reflexos"
	global.flags = {};                    // marcas soltas (arquivos lidos, conversas feitas...)
}
missoes_estado_inicial();

// Missões já descobertas, na ordem do diário
function missoes_visiveis() {
	var _r = [];
	for (var i = 0; i < array_length(global.missoes_ordem); i++) {
		if (missao(global.missoes_ordem[i]).estado > 0) array_push(_r, global.missoes_ordem[i]);
	}
	return _r;
}

function missao(_id) { return global.missoes[$ _id]; }
function flag(_k)    { return variable_struct_exists(global.flags, _k); }
function marcar(_k)  { global.flags[$ _k] = true; }

// Coloca uma animação na fila: "nova", "atualizada" ou "concluida"
function avisar(_tipo, _titulo, _texto) {
	// Som de missao: recebida (nova) ou cumprida (concluida)
	if (_tipo == "nova") som(snd_missao_recebida);
	if (_tipo == "concluida") som(snd_missao_cumprida);
	// a atualização logo depois da "nova" missão é redundante: só troca o texto
	var _n = array_length(global.fila_missoes);
	if (_tipo == "atualizada" && _n > 0 && global.fila_missoes[_n - 1].titulo == _titulo
	    && global.fila_missoes[_n - 1].tipo != "concluida") {
		global.fila_missoes[_n - 1].texto = _texto;
		return;
	}
	array_push(global.fila_missoes, { tipo: _tipo, titulo: _titulo, texto: _texto });
}

function aviso_duracao(_tipo) {
	switch (_tipo) {
		case "nova":      return 210;
		case "concluida": return 290;
	}
	return 160;
}

function missao_iniciar(_id, _objetivo) {
	var _m = missao(_id);
	if (_m.estado != 0) return;
	_m.estado = 1;
	_m.objetivo = _objetivo;
	avisar("nova", _m.titulo, _objetivo);
}

function missao_objetivo(_id, _objetivo) {
	var _m = missao(_id);
	_m.objetivo = _objetivo;
	avisar("atualizada", _m.titulo, _objetivo);
}

function missao_concluir(_id, _recompensa) {
	var _m = missao(_id);
	if (_m.estado == 2) return;
	_m.estado = 2;
	_m.prog = _m.total;
	_m.objetivo = "Concluída!";
	avisar("concluida", _m.titulo, "Recompensa: " + _recompensa);
}

// ---------------------------------------------------------------------
//  Conversas dos NPCs que mudam conforme as missões.
//  Recebe as falas normais e devolve as falas que vão aparecer.
// ---------------------------------------------------------------------
function npc_evento(_id, _linhas) {
	var _r = _linhas;
	var _rede = missao("rede");
	var _den = missao("denuncia");
	var _voz = missao("voz");

	switch (_id) {

		// ----- Rede de Apoio: começa e termina com a Lia -----
		case "lia":
			if (_rede.estado == 0) {
				_r = array_concat(_r, [
					["Lia", "Sabe o que mais dói? Ver mulheres repetindo contra a gente o que ouviram a vida toda."],
					["Lia", "A Clara, a Beatriz, a Sônia... Conversa com elas. A gente precisa uma da outra."]
				]);
				missao_iniciar("rede", "Converse com Clara (1º andar), Beatriz (Escada 1) e Sônia (2º andar): 0/3");
			}
			else if (_rede.estado == 1 && _rede.prog >= 3) {
				_r = [
					["Lia", "Elas vieram falar comigo. Pela primeira vez a gente almoçou juntas."],
					["N", "Ninguém sobe sozinha. A gente sobe junto."]
				];
				global.bonus.def += 3;
				missao_concluir("rede", "+3 DEF");
			}
			else if (_rede.estado == 1) {
				_r = [["Lia", "Ainda faltam algumas. Conversa com a Clara, a Beatriz e a Sônia."]];
			}
			break;

		case "clara":
		case "beatriz":
		case "sonia":
			if (flag("rede_" + _id)) {
				_r = rede_depois(_id);   // já foi "convertida": fala de outro jeito
			}
			else if (_rede.estado == 1) {
				marcar("rede_" + _id);
				_rede.prog++;
				_r = rede_conversa(_id);
				missao_objetivo("rede", (_rede.prog >= 3)
					? "Volte e fale com a Lia (Escada 1)"
					: "Converse com Clara, Beatriz e Sônia: " + string(_rede.prog) + "/3");
			}
			// A Sônia viu a importunação: oferece apoio (não é obrigatório para denunciar)
			if (_id == "sonia" && _den.estado == 1 && !flag("sonia_apoio")) {
				marcar("sonia_apoio");
				_r = array_concat(_r, [
					["Sônia", "Eu vi o que o Otávio fez com você. Já aconteceu comigo também, anos atrás."],
					["Sônia", "Se você denunciar, eu confirmo o que vi. Você não está sozinha."]
				]);
			}
			break;

		// ----- Voz Própria: o Paulo quer roubar a ideia da Nexa -----
		case "paulo":
			if (_voz.estado == 0) {
				_r = array_concat(_r, [["N", "(Eu preciso provar que essa ideia é minha. O repositório guarda tudo.)"]]);
				missao_iniciar("voz", "Ache a prova da sua autoria no Repositório (1º andar)");
			}
			else if (_voz.estado == 1 && _voz.prog >= 1) {
				_r = [
					["N", "Paulo. Histórico do repositório: a ideia, o código e os testes. Tudo com o meu nome."],
					["Paulo", "Ah... isso aí é detalhe técnico, né? Ninguém olha isso."],
					["N", "Eu olho. E vou apresentar na reunião. Com a minha voz."],
					["Paulo", "...Tá bom. A ideia é sua."]
				];
				global.bonus.hp += 10;
				missao_concluir("voz", "+10 HP máximo");
			}
			else if (_voz.estado == 2) {
				_r = [["Paulo", "Ainda tô pensando em como dizer pra diretoria que a ideia não era minha."]];
			}
			break;

		// ----- Não é Brincadeira: importunação sexual e denúncia -----
		case "otavio":
			if (_den.estado == 0) {
				_r = [
					["Otávio", "Ô, Nexa! Esse corpo de metal novo ficou uma delícia, hein?"],
					["", "Ele chega perto demais e tenta pegar na cintura dela, sem permissão.", "tremer"],
					["N", "Tira a mão. Agora.", "flash"],
					["Otávio", "Calma! É só brincadeira. Agora não pode nem elogiar?"],
					["N", "Isso não é elogio. É importunação. E eu não vou ficar calada."],
					["", "Nexa se afasta. O coração dispara, mas ela sabe o que fazer."]
				];
				missao_iniciar("denuncia", "Registre a denúncia no Canal de Ouvidoria (Escada 2). Se quiser apoio, fale com a Sônia (2º andar).");
			} else {
				_r = [["Otávio", "Que estresse. Foi só um comentário..."], ["N", "Não foi. E você sabe disso."]];
			}
			break;

		case "fabio":
			if (_den.estado == 1) {
				_r = [
					["Fábio (RH)", "O Otávio? Ah, ele é brincalhão. Você não está exagerando?"],
					["N", "Não estou. E vou registrar mesmo assim."],
					["", "Quando o RH não escuta, existem outros canais. Nexa lembra da Ouvidoria na escada."]
				];
			}
			break;
	}
	return _r;
}

// Conversa que muda o jeito de pensar das colegas (missão "Rede de Apoio")
function rede_conversa(_id) {
	switch (_id) {
		case "clara": return [
			["N", "Clara, você não precisa ser 'um dos caras' pra ser respeitada aqui."],
			["Clara", "...É que sempre que eu sou eu mesma, ninguém me leva a sério."],
			["N", "O problema não é você. É o lugar que só aceita um tipo de pessoa."],
			["Clara", "Nunca tinha pensado assim. Talvez eu possa parar de fingir."]
		];
		case "beatriz": return [
			["N", "Beatriz, nenhuma roupa é convite. A culpa nunca é de quem sofre."],
			["Beatriz", "Eu falo isso porque... se a culpa for delas, fica mais fácil achar que comigo nunca vai acontecer."],
			["N", "Pode acontecer com qualquer uma. Por isso a gente precisa acreditar umas nas outras."],
			["Beatriz", "Desculpa. Vou procurar a estagiária e pedir desculpas pra ela."]
		];
		case "sonia": return [
			["N", "Sônia, você abriu caminho pra todas nós. Não precisa fechar a porta atrás de você."],
			["Sônia", "Ninguém me ajudou. Eu achei que vocês também tinham que sofrer pra merecer."],
			["N", "Merecer não é sofrer. A gente pode mudar isso agora."],
			["Sônia", "...Tem uma vaga de liderança aberta. Vou indicar você. E a Lia."]
		];
	}
	return [];
}

function rede_depois(_id) {
	switch (_id) {
		case "clara":   return [["Clara", "Hoje eu falei na reunião do meu jeito. E me ouviram."]];
		case "beatriz": return [["Beatriz", "Conversei com a estagiária. Ela vai denunciar, e eu vou junto."]];
		case "sonia":   return [["Sônia", "Liderar não é virar o que te machucou. Ainda estou aprendendo isso."]];
	}
	return [];
}

// ---------------------------------------------------------------------
//  Pontos do mapa (obj_ponto): arquivos, espelhos, repositório, ouvidoria
// ---------------------------------------------------------------------
function ponto_dados(_id) {
	switch (_id) {
		case "arquivo_ada":    return { tipo: "arquivo", prompt: "[E] Ler arquivo" };
		case "arquivo_eniac":  return { tipo: "arquivo", prompt: "[E] Ler arquivo" };
		case "arquivo_hopper": return { tipo: "arquivo", prompt: "[E] Ler arquivo" };
		case "repositorio":    return { tipo: "terminal", prompt: "[E] Repositório" };
		case "ouvidoria":      return { tipo: "ouvidoria", prompt: "[E] Ouvidoria" };
		case "espelho_1":
		case "espelho_2":
		case "espelho_3":      return { tipo: "espelho", prompt: "[E] Olhar" };
	}
	return { tipo: "arquivo", prompt: "[E] ???" };
}

// Ponto já usado? (o arquivo some, o espelho fica mais apagado)
function ponto_usado(_id) { return flag("ponto_" + _id); }

function ponto_interagir(_id) {
	var _r = [];
	switch (_id) {

		// ----- Memória Apagada: pioneiras da computação -----
		case "arquivo_ada":
			_r = [
				["", "ARQUIVO RECUPERADO: Ada Lovelace (1815-1852)."],
				["", "Em 1843 ela publicou o que é considerado o primeiro algoritmo feito para uma máquina: a Máquina Analítica de Charles Babbage."],
				["N", "A primeira programadora da história foi uma mulher. E o Banco de Dados 'perdeu' esse registro."]
			];
			break;
		case "arquivo_eniac":
			_r = [
				["", "ARQUIVO RECUPERADO: as programadoras do ENIAC (1946)."],
				["", "Kathleen McNulty, Jean Jennings, Betty Snyder, Marlyn Wescoff, Frances Bilas e Ruth Lichterman programaram um dos primeiros computadores eletrônicos."],
				["", "Na apresentação ao público, elas nem foram citadas."],
				["N", "Apagar mulheres da história não é acidente. É escolha."]
			];
			break;
		case "arquivo_hopper":
			_r = [
				["", "ARQUIVO RECUPERADO: Grace Hopper (1906-1992)."],
				["", "Criou um dos primeiros compiladores e ajudou a desenvolver a linguagem COBOL."],
				["N", "Cada linha que eu escrevo tem um pouco delas."]
			];
			break;

		// ----- Voz Própria -----
		case "repositorio":
			var _voz = missao("voz");
			if (_voz.estado == 1 && _voz.prog == 0) {
				_voz.prog = 1;
				_r = [
					["", "git log --author=\"Nexa\""],
					["", "Ideia, protótipo, testes, documentação. Todos os commits têm o nome dela."],
					["N", "Está tudo aqui. Agora o Paulo vai ter que me ouvir."]
				];
				missao_objetivo("voz", "Mostre a prova ao Paulo (1º andar)");
			} else {
				_r = [["", "Repositório da Nexus Tech. Milhares de commits. Os nomes das mulheres quase nunca aparecem nos créditos."]];
			}
			return _r;   // não é coletável

		// ----- Não é Brincadeira: canal de denúncia -----
		case "ouvidoria":
			var _den = missao("denuncia");
			if (_den.estado == 1) {
				_r = [
					["", "CANAL DE OUVIDORIA - Denúncia registrada com sigilo."],
					["N", "Nome: Otávio. O que aconteceu: comentário sobre o meu corpo e tentativa de toque sem permissão."]
				];
				if (flag("sonia_apoio")) _r = array_concat(_r, [["", "Testemunha: Sônia confirmou o relato."]]);
				_r = array_concat(_r, [
					["", "Importunação sexual é crime no Brasil (art. 215-A do Código Penal): praticar ato libidinoso contra alguém sem consentimento."],
					["", "Assédio sexual também é crime (art. 216-A): constranger alguém para obter vantagem sexual, usando um cargo superior."],
					["", "Você não precisa de testemunhas para denunciar. Também dá para procurar o Ministério Público do Trabalho ou a polícia. Violência contra a mulher: Ligue 180."],
					["", "O Otávio foi afastado enquanto a denúncia é apurada."],
					["N", "Não era brincadeira. Nunca foi."]
				]);
				global.bonus.energia += 25;
				missao_concluir("denuncia", "começa as lutas com +25 de energia");
			} else if (_den.estado == 2) {
				_r = [["", "Denúncia em apuração. Protocolo guardado com sigilo."]];
			} else {
				_r = [
					["", "CANAL DE OUVIDORIA - Denúncias de assédio e discriminação, com sigilo."],
					["", "Assédio sexual (art. 216-A) e importunação sexual (art. 215-A) são crimes. Violência contra a mulher: Ligue 180."]
				];
			}
			return _r;   // não é coletável

		// ----- Reflexos: autoconhecimento -----
		case "espelho_1":
			_r = [
				["", "Um espelho velho no corredor. Nexa encara o próprio reflexo."],
				["N", "Eles dizem quem eu devo ser o dia inteiro. Quem eu sou quando ninguém está me avaliando?"],
				["N", "...Eu gosto de resolver problemas. Gosto de criar. Isso é meu."]
			];
			break;
		case "espelho_2":
			_r = [
				["", "O reflexo mostra mais metal do que pele."],
				["N", "Foi a empresa que me transformou... ou fui eu que deixei, pra caber?"],
				["N", "Eu não preciso provar meu valor pra quem decidiu não enxergar."]
			];
			break;
		case "espelho_3":
			_r = [
				["", "No último espelho, o reflexo parece mais firme."],
				["N", "Meu corpo pode mudar. A minha voz, não."],
				["N", "Eu não sou o molde. Eu sou a falha que vai quebrar ele."]
			];
			break;
	}

	// Coletáveis: conta progresso uma vez só
	if (!ponto_usado(_id)) {
		marcar("ponto_" + _id);

		if (string_pos("arquivo_", _id) == 1) {
			var _m = missao("memoria");
			_m.prog++;
			if (_m.estado == 0) missao_iniciar("memoria", "");
			if (_m.prog >= 3) {
				_r = array_concat(_r, [["N", "Elas sempre estiveram aqui. E eu também vou ficar."]]);
				global.bonus.atk += 3;
				missao_concluir("memoria", "+3 ATK");
			} else {
				missao_objetivo("memoria", "Recupere arquivos das pioneiras da computação: " + string(_m.prog) + "/3");
			}
		}
		else if (string_pos("espelho_", _id) == 1) {
			var _e = missao("espelho");
			_e.prog++;
			if (_e.estado == 0) missao_iniciar("espelho", "");
			if (_e.prog >= 3) {
				global.skill_autoconfianca = true;
				global.bonus.mp += 5;
				missao_concluir("espelho", "nova habilidade: Autoconfiança, +5 MP");
			} else {
				missao_objetivo("espelho", "Encontre os espelhos pelo prédio: " + string(_e.prog) + "/3");
			}
		}
	}
	return _r;
}
