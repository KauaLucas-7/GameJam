display_set_gui_size(480, 270);
usar_fonte();   // fonte com acentos (ou a padrão, se ainda não foi gerada)
cyber_init();
// cyber_give_all();   // TESTE: tire as barras para ter todos os mods
row = 0;   // 0 a 3 = Braços, Torso, Pernas, Ferramenta | 4 = Voltar

// Volta para o terminal de onde a Nexa veio
sair = function() {
	var _sala = global.oficina_retorno;
	if (_sala == -1) _sala = rm_andar1;   // abriu a oficina direto (teste)
	else global.usar_spawn = true;
	trocar_sala(_sala);
};
