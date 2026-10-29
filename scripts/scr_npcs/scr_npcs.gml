// Dados dos NPCs do escritório (funcionários "moldados" pela empresa).
// Cada NPC na room define npc_id na Creation Code da instância.
//   nome:   aparece na caixa de diálogo
//   cor:    cor do terno | visor: cor do visor do robô
//   item:   id do mod (scr_cyber) que ele entrega na 1ª conversa ("" = nenhum)
//   falas:  1ª conversa | depois: conversas seguintes
// As falas mostram o machismo do escritório que a Nexa enfrenta.
//   genero: "f" desenha a robô feminina (saia e "cabelo" de placas) | cabelo: cor das placas
//   auto:   true = a conversa começa sozinha quando a Nexa chega perto (evento)
//   sumir_se: id de missão; quando ela for concluída, o NPC some do mapa
// Algumas conversas mudam com as missões (ver npc_evento em scr_missoes).

function npc_dados(_id) {
	switch (_id) {

		// ----- Robôs femininas: repetem o machismo que aprenderam -----
		case "clara": return {
			nome: "Clara", genero: "f", cor: c_purple, visor: c_fuchsia, cabelo: c_dkgray, item: "",
			falas: [
				["Clara", "Ah, você é a outra menina da TI? Eu não sou como as outras, viu. Sou praticamente um dos caras."],
				["Clara", "Mulher junta só dá fofoca. Prefiro trabalhar com homem, é mais objetivo."],
				["N", "Ser mulher não é defeito, Clara."]
			],
			depois: [["Clara", "Se quiser ser levada a sério, fala menos de sentimento e mais de número."]]
		};

		case "beatriz": return {
			nome: "Beatriz", genero: "f", cor: c_maroon, visor: c_orange, cabelo: c_olive, item: "",
			falas: [
				["Beatriz", "Viu a estagiária reclamando do Otávio? Também, com aquela roupa... tava pedindo."],
				["N", "Nenhuma roupa é convite."],
				["Beatriz", "Ai, Nexa, não é assim. A gente tem que se dar ao respeito."]
			],
			depois: [["Beatriz", "Eu me visto discreta e nunca me aconteceu nada. É só saber se comportar."]]
		};

		case "sonia": return {
			nome: "Sônia", genero: "f", cor: c_black, visor: c_red, cabelo: c_gray, item: "",
			falas: [
				["Sônia", "Eu sofri vinte anos pra chegar na gerência. Ninguém me ajudou. Se você quer subir, que sofra também."],
				["Sônia", "E mulher na liderança tem que ser mais dura que os homens. Sorriso é fraqueza."],
				["N", "Ou a gente pode ser a liderança que não tivemos."]
			],
			depois: [["Sônia", "Não vem pedir favor. Comigo é igual pra todo mundo: difícil."]]
		};

		case "vera": return {
			nome: "Vera", genero: "f", cor: c_teal, visor: c_yellow, cabelo: c_maroon, item: "",
			falas: [
				["Vera", "Você foi promovida porque é bonitinha, né? Mérito é que não foi."],
				["N", "Meu código fala por mim. Lê ele um dia."],
				["Vera", "Mulher bonita na TI sempre tem 'ajuda'. Todo mundo sabe."]
			],
			depois: [["Vera", "Se fosse tão boa, já tinha um homem assinando embaixo do seu trabalho."]]
		};

		// ----- Evento: importunação sexual (missão "Não é Brincadeira") -----
		case "otavio": return {
			nome: "Otávio", cor: c_navy, visor: c_red, item: "", auto: true, sumir_se: "denuncia",
			falas: [["Otávio", "..."]],   // as falas reais vêm de npc_evento
			depois: []
		};

		// ----- 1º andar -----
		case "ricardo": return {
			nome: "Ricardo", cor: c_navy, visor: c_red, item: "",
			falas: [
				["Ricardo", "Nossa, você é a programadora? Achei que fosse a moça do café."],
				["N", "Faz três anos que eu trabalho aqui, Ricardo."],
				["Ricardo", "É mesmo? Nem reparei. Sorria mais, você fica mais bonita assim."],
				["N", "..."]
			],
			depois: [["Ricardo", "Já falei: sorria! Ninguém gosta de mulher emburrada no escritório."]]
		};

		case "marcos": return {
			nome: "Marcos", cor: c_maroon, visor: c_orange, item: "powerbank",
			falas: [
				["Marcos", "Ei, Nexa! Toma esse power bank."],
				["Marcos", "Sei que mulher sempre esquece de carregar as coisas. Faz parte, né?"],
				["N", "Eu aceito o power bank. O comentário, não."]
			],
			depois: [["Marcos", "Tá carregado? Não vai me fazer explicar onde liga, hein."]]
		};

		case "paulo": return {
			nome: "Paulo", cor: c_black, visor: c_yellow, item: "",
			falas: [
				["Paulo", "Aquela sua ideia na reunião foi ótima."],
				["Paulo", "Tão ótima que eu vou apresentar como minha. Ninguém levaria a sério vindo de você."],
				["N", "Eu tenho os commits pra provar que é minha."],
				["Paulo", "Commits? Que fofo."]
			],
			depois: [["Paulo", "Relaxa, no slide eu coloco seu nome. Bem pequenininho."]]
		};

		// ----- Corredor 1 -----
		case "julio": return {
			nome: "Júlio", cor: c_dkgray, visor: c_red, item: "",
			falas: [
				["Júlio", "Deixa eu te explicar esse código, é meio técnico."],
				["N", "Fui eu que escrevi esse código."],
				["Júlio", "Então deixa eu te explicar por que ele tá errado."]
			],
			depois: [["Júlio", "Se tiver dúvida, pergunta pra um dos meninos do time, tá?"]]
		};

		case "lia": return {
			nome: "Lia", genero: "f", cor: c_teal, visor: c_lime, cabelo: c_black, item: "antirruido",
			falas: [
				["Lia", "Nexa... você também escuta esses comentários o dia inteiro, né?"],
				["Lia", "Toma meu fone antirruído. Ajuda a focar no que importa."],
				["N", "Obrigada, Lia. De verdade."],
				["Lia", "Eu já tô quase virando metal. Não deixa eles te moldarem."]
			],
			depois: [["Lia", "Foco no ritmo. Bloqueia na hora certa."]]
		};

		case "fabio": return {
			nome: "Fábio (RH)", cor: c_olive, visor: c_orange, item: "",
			falas: [
				["Fábio (RH)", "Você pensa em ter filhos? Pergunto só pelo planejamento da equipe."],
				["N", "Você faz essa pergunta pros homens do time também?"],
				["Fábio (RH)", "Ah, com eles é diferente, né."]
			],
			depois: [["Fábio (RH)", "Já pensou num cargo mais leve? O RH tá precisando de uma moça simpática."]]
		};

		// ----- 2º andar -----
		case "rogerio": return {
			nome: "Rogério", cor: c_navy, visor: c_aqua, item: "firewall",
			falas: [
				["Rogério", "Vai encarar o Python? Leva esse firewall portátil."],
				["Rogério", "Mulher precisa de proteção extra, né? É frágil."],
				["N", "Eu sei me proteger. Mas o firewall eu levo."]
			],
			depois: [["Rogério", "Qualquer coisa grita que um homem vai te ajudar."]]
		};

		case "gustavo": return {
			nome: "Gustavo", cor: c_purple, visor: c_red, item: "",
			falas: [
				["Gustavo", "Tá nervosinha hoje? Deve ser aquela época do mês."],
				["N", "Não. Deve ser você."]
			],
			depois: [["Gustavo", "Calma, calma! Não precisa ficar histérica."]]
		};

		case "henrique": return {
			nome: "Henrique", cor: c_dkgray, visor: c_yellow, item: "backup",
			falas: [
				["Henrique", "Esse pendrive tem um backup completo. Se der pane, ele te reinicia."],
				["Henrique", "Achei que ia precisar. Vocês costumam travar sob pressão."],
				["N", "Quem trava sob pressão é o seu servidor, Henrique."]
			],
			depois: [["Henrique", "Se travar, não chora. Só reinicia."]]
		};

		// ----- Corredor 2 -----
		case "vitor": return {
			nome: "Vitor", cor: c_maroon, visor: c_aqua, item: "overclock",
			falas: [
				["Vitor", "Pega esse overclock USB. Deixa tudo mais rápido."],
				["Vitor", "Até você vai conseguir acompanhar o ritmo do time."],
				["N", "Eu sou o ritmo do time."]
			],
			depois: [["Vitor", "Não vai queimar tudo, hein. Isso aí é coisa de engenheiro."]]
		};

		case "sergio": return {
			nome: "Sérgio", cor: c_black, visor: c_red, item: "",
			falas: [
				["Sérgio", "Lá em cima o Chefe vai te fazer uma proposta."],
				["Sérgio", "Aceita. Mulher que fala demais não sobe na carreira."],
				["N", "Eu não vim pra subir. Eu vim pra quebrar o molde."]
			],
			depois: [["Sérgio", "Depois não diz que eu não avisei, mocinha."]]
		};
	}
	return { nome: "???", cor: c_gray, visor: c_white, item: "",
	         falas: [["", "[NPC sem dados: " + string(_id) + "]"]], depois: [] };
}
