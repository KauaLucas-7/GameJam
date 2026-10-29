// Controlador persistente (criado pela Nexa / batalha / final se ainda não existir).
// Cuida de:
//   - transições entre salas: fade com "card" do ambiente, ou entrada de batalha
//   - animações de missão: nova, atualizada e a cutscene de missão concluída
display_set_gui_size(480, 270);
cyber_init();

trans_fase = 0;          // 0 = nada | 1 = fechando a tela | 2 = abrindo na sala nova
trans_t = 0;
trans_destino = -1;
trans_estilo = "fade";   // "fade" ou "batalha"
trans_titulo = undefined;
trans_dur = 0;

aviso = undefined;       // aviso de missão em exibição
aviso_t = 0;
cena_ativa = false;      // missão concluída: trava a Nexa enquanto a cena toca
particulas = [];

// Card com o nome do ambiente ao abrir a sala
iniciar_card = function(_sala) {
	trans_fase = 2;
	trans_t = 0;
	trans_titulo = titulo_sala(_sala);
	if (trans_titulo == undefined) { trans_dur = 24; return; }
	var _k = "visitou_" + room_get_name(_sala);
	var _primeira = !flag(_k);
	marcar(_k);
	trans_dur = _primeira ? 160 : 80;   // 1ª visita: card completo
};

// Abertura do jogo: card da primeira sala
abertura = true;
iniciar_card(room);