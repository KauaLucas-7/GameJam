// =====================================================================
//  FINAL RUIM: Nexa aceita o "molde" da empresa
//  Mostra a sobrecarga e o isolamento que se seguem, e trata o suicídio
//  com cuidado (recomendações de comunicação responsável da OMS e do CVV):
//  sem cena explícita nem método, sem romantizar, com dado real e
//  informação de apoio ao final.
// =====================================================================
display_set_gui_size(480, 270);
usar_fonte();
garantir_controle();
tocar_musica(snd_musica_final_ruim);
cyber_init();

t = 0;
anim = 0;
q = 0;          // legenda atual
q_t = 0;        // tempo na legenda
letras = 0;
fim = false;    // tela final (tentar de novo / menu)
fim_t = 0;

// vis = cena desenhada por trás da legenda
legendas = [
	{ vis: "promocao",   txt: "Nexa aceitou a proposta. A promoção veio... e o molde veio junto." },
	{ vis: "promocao",   txt: "Para manter o cargo, ela precisava ser 'gentil', disponível, perfeita. Sempre." },
	{ vis: "sobrecarga", txt: "Mais horas. Mais metas. Mais comentários. Ela não podia reclamar: tinha 'aceitado'." },
	{ vis: "isolamento", txt: "Lia e as outras tentaram se aproximar. Mas Nexa já não respondia as mensagens." },
	{ vis: "isolamento", txt: "Ninguém percebeu o quanto todo aquele metal pesava." },
	{ vis: "mesa",       txt: "Uma noite, a pressão se tornou insuportável. Nexa tirou a própria vida." },
	{ vis: "mesa",       txt: "Na manhã seguinte, a cadeira dela continuava vazia. E a empresa seguiu como se nada tivesse acontecido." },
	{ vis: "dado",       txt: "No Brasil, as mulheres representam quase 70% das notificações de tentativas de suicídio e lesões autoprovocadas." },
	{ vis: "apoio",      txt: "Nenhum molde vale a sua vida. Se você está sofrendo, você não está sozinha: pedir ajuda é um ato de coragem." },
	{ vis: "apoio",      txt: "CVV - Centro de Valorização da Vida: ligue 188 (24 horas, gratuito) ou acesse cvv.org.br. Em emergência: SAMU 192." }
];

// Notificações caindo sobre a Nexa (cena "sobrecarga")
avisos = [];
avisos_txt = ["URGENTE", "Reunião 22h", "Entrega pra ontem", "Sorria mais", "Você está atrasada",
              "Sem hora extra", "Fim de semana também", "Seja mais gentil", "Meta: 200%", "Cadê o relatório?"];

// Colegas que tentam se aproximar (cena "isolamento")
colegas = [npc_dados("lia"), npc_dados("clara"), npc_dados("sonia"), npc_dados("beatriz")];

// Nexa com todas as peças de metal (o "molde" completo)
desenhar_nexa_moldada = function(_x, _y, _s, _tint, _a) {
	var _fr2 = floor(anim / 12) mod sprite_get_number(spr_Nexa);
	draw_sprite_ext(spr_Nexa, _fr2, _x, _y, _s, _s, 0, _tint, _a);
	var _ordem = ["legs", "torso", "arms"];
	for (var s = 0; s < 3; s++) {
		var _ov = global.mod_overlay[$ _ordem[s]];
		draw_sprite_ext(_ov, _fr2 mod sprite_get_number(_ov), _x, _y, _s, _s, 0, _tint, _a);
	}
};
