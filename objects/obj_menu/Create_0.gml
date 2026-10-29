// =====================================================================
//  MENU INICIAL + INTRODUÇÃO DA HISTÓRIA
//  tela: "titulo" (menu) | "comojogar" | "creditos" | "historia" (cutscene)
// =====================================================================
display_set_gui_size(480, 270);
usar_fonte();
garantir_controle();
cyber_init();

tela = "aviso";   // aviso de conteúdo sensível antes do menu
t = 0;
anim = 0;
opcoes = ["Novo jogo", "Como jogar", "Créditos", "Sair"];
sel = 0;
sel_anim = 0;   // barra de seleção deslizando
fundos = [spr_sala_bd, spr_sala_python, spr_sala_urso];
fundo_i = 0;
fundo_t = 0;

// Robôs do escritório que aparecem na tela de título
robos = [npc_dados("ricardo"), npc_dados("paulo"), npc_dados("clara"), npc_dados("sergio")];

// ----- Introdução: quadros com legenda (vis = o que aparece na cena) -----
quadros = [
	{ vis: "predio",  txt: "Nexus Tech, 2087. A maior empresa de computação da cidade." },
	{ vis: "equipe",  txt: "Na engenharia, de cada dez pessoas, só uma é mulher. Nexa é a única desenvolvedora sênior do andar." },
	{ vis: "credito", txt: "Ela escreve o código mais importante da empresa. Quem leva os créditos, quase sempre, são outros." },
	{ vis: "molde",   txt: "Para ser aceita, ela foi se adaptando. Peça por peça, trocou partes de si por metal." },
	{ vis: "chefes",  txt: "Três andares. Três chefes. E um 'molde' que transforma todo mundo em mais uma engrenagem." },
	{ vis: "decisao", txt: "Hoje, Nexa decide parar de se moldar." }
];
q = 0;          // quadro atual
q_t = 0;        // tempo no quadro
letras = 0;
