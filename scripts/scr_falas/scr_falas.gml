// Falas do roteiro. Cada linha e [quem, texto].
// quem: "U" = chefe (urso), "N" = Nexa, "BD" = banco de dados, "PY" = python, "" = narração

function nome_falante(_quem) {
	switch (_quem) {
		case "U":  return "Chefe";
		case "N":  return "Nexa";
		case "BD": return "Banco de Dados";
		case "PY": return "Python";
	}
	return _quem;   // NPCs usam o próprio nome (ex.: "Lia"); "" = narração
}

function falas_get(_cena) {
	switch (_cena) {
		case "intro": return [
			["U", "Dormiu de novo, hein?"],
			["N", "Desculpe, chefe. Faz um tempo não me sinto tão bem."],
			["U", "Não tem problema, você é uma trabalhadora e tanto. Haha!"],
			["N", "..."],
			["N", "É, talvez eu seja."],
			["U", "Olha, que tal mudar um pouco o expediente hoje?"],
			["U", "Eu poderia te levar em casa."],
			["", "Ele apoia a mão no ombro dela, sem pedir. Nexa se afasta devagar.", "tremer"],
			["N", "..."],
			["N", "Foi mal, tenho que lidar com um banco de dados hoje à tarde."],
			["U", "Certo, certo... Talvez na próxima."],
			["", "O chefe sai de cena, e a Nexa se levanta da cadeira."],
			["N", "(De novo esse 'te levar em casa'... Eu não pedi isso. Nunca pedi.)"]
		];

		// ----- Chegada em cada sala (1ª visita) -----
		case "entrada_rm_corredor1": return [
			["", "Escada de serviço. Na parede, o quadro 'Funcionário do Mês': doze fotos, doze homens."],
			["N", "Doze meses. Nenhuma de nós."]
		];
		case "entrada_rm_andar2": return [
			["", "2º andar - Desenvolvimento. Aqui, piada sobre mulher é chamada de 'cultura da empresa'."],
			["N", "Já ouvi tudo isso antes. Desta vez eu vou responder."]
		];
		case "entrada_rm_corredor2": return [
			["", "Mural de avisos: 'Política contra assédio - em revisão desde 2079'."],
			["N", "Oito anos 'em revisão'. Quantas de nós saíram daqui nesse tempo?"]
		];
		case "entrada_rm_andar3": return [
			["", "Último andar. A sala do Chefe. Cada robô deste prédio já foi alguém que tentou se encaixar."],
			["N", "Foi ele quem desenhou o molde. Chegou a hora de quebrá-lo."]
		];

		// ----- Chefe ainda não liberado (a história segue em ordem) -----
		case "bloqueado_2": return [
			["PY", "Ssshh... Ainda não é a sua vez, minha querida."],
			["PY", "Volte quando o Banco de Dados do 1º andar tiver caído."]
		];
		case "bloqueado_3": return [
			["U", "Calma, Nexa. Você ainda nem passou pelo Python."],
			["U", "Quem pula etapas aqui... não sobe na carreira."]
		];

		case "andar1_pre": return [
			["BD", "P-Puxa vida, n3XA! Os dados estão ficando corr0mp1dos!", "tremer"],
			["N", "Talvez seja melhor S.Q.L (_Se queixar longe_)"],
			["BD", "Você vai estar na primeira coluna de DESEMPREGADA no próximo mês"],
			["BD", "Alguém está querendo ter o salário reduzido, quando vai ser um de nós"],
			["N", "Você tá com muito papo pra pouco dado."]
		];

		case "andar1_pos": return [
			["BD", "N-N4O vAi t3r c0mo fug1r do seu destino!.."],
			["N", "Eu farei meu destino."],
			["N", "Argh. Que dor."],
			["", "A Nexa ganha braços de robô. 2º andar liberado."]
		];

		case "andar1_fim": return array_concat(falas_get("andar1_pos"), falas_get("andar1_chefe"));
		case "andar1_chefe": return [
			["U", "Meus parabéns! Continue assim."],
			["N", "...Irei, chefe."],
			["U", "Desse jeito poderá até ser uma de nós."],
			["N", "..."],
			["", "O chefe sai de cena."]
		];

		case "andar2_pre": return [
			["PY", "Ssseu ressultado... Definitivamente vitoriossa..."],
			["N", "Não vai conseguir colocar seu veneno em mim."],
			["PY", "Issso é o que vosscê acha, minha querida."],
			["PY", "O _Chefe_ vai consseguir moldar a todosss."],
			["PY", "E pelo vissto... Seu braço prova isso..."],
			["N", "Pra uma cobra fortemente tipada você tá sendo bem baixa"],
			["N", "Ah, mas você já está no chão, rastejando."]
		];

		case "andar2_pos": return [
			["N", "Game-over. cobrinha."],
			["N", "Argh!"],
			["", "A Nexa agora possui todo corpo de metal, exceto a cabeça."],
			["N", "Mas?..."],
			["PY", "Isso é só o começo... O Chefe te espera no último andar."]
		];

		case "andar3_pre": return [
			["U", "Olha só, quem chegou."],
			["U", "Minha proposta vai ser aceita? Tanto a ganhar!"],
			["U", "Uma promoção pra você... Só depende de quanto você quer ser 'gentil' comigo depois do expediente."],
			["N", "Isso tem nome: assédio sexual. Usar o cargo pra me pressionar é crime.", "flash"],
			["N", "..."],
			["N", "Mas também tanto a perder..."],
			["U", "Hã?"],
			["N", "Eu tô a tanto tempo aqui, e cada dia que passa fico igual..."],
			["U", "Igual a?"],
			["N", "Igual a vocês. Só pra me validar."],
			["N", "Mas eu recuso esse molde! Eu mesma estou acima disso."],
			["U", "E então, o que vai fazer?"],
			["N", "Eu vou vencer.", "flash"]
		];

		case "creditos": return [
			["", "CRÉDITOS"],
			["", "Gabriel - Arte Cenário"],
			["", "Kauã Lucas - Programação"],
			["", "Marcelo Rocha - Programação"],
			["", "Maria Letícia - Arte Personagens"],
			["", "Vítor Gabriel - Soundtrack + Roteiro"],
			["", "Obrigado por jogar!"]
		];

		case "final": return [
			["", "A Nexa volta ao seu corpo normal, e os robôs que estavam no escritório também. Algumas são mulheres, outros homens."],
			["N", "Ninguém mais irá se moldar."],
			["U", "Meus... Funcionários. Já faz tanto tempo."],
			["N", "Tanto tempo que você mal via no que muitas se tornaram."],
			["N", "Só mais uma engrenagem."],
			["N", "Mas, eu, vim para mudar isso. Todos somos iguais."],
			["U", "Você tem razão. Admito que... Essa empresa se tornou algo que eu não imaginava."],
			["N", "Tudo bem. Você tem muito a melhorar."],
			["N", "Mas, sou a prova de que melhoraremos."],
			["U", "Obrigado... Nexus. Por me fazer entender."],
			["N", "Agora, um dia de folga extra."]
		];
	}
	return [["", "[cena não encontrada: " + string(_cena) + "]"]];
}

// A cena existe no roteiro?
function falas_existe(_cena) {
	var _l = falas_get(_cena);
	return !(array_length(_l) == 1 && string_pos("[cena não encontrada", _l[0][1]) == 1);
}

// Abre a caixa de diálogo.
// _acao: "nada" ou "luta" (ao acabar, vai para a sala _sala)
function iniciar_dialogo(_cena, _acao, _sala) {
	return iniciar_dialogo_linhas(falas_get(_cena), _acao, _sala);
}

// Igual, mas recebe as linhas prontas (usado pelos NPCs)
function iniciar_dialogo_linhas(_linhas, _acao = "nada", _sala = -1) {
	var _d = instance_create_depth(0, 0, -10000, obj_dialogo);
	_d.linhas = _linhas;
	_d.acao = _acao;
	_d.sala = _sala;
	return _d;
}
