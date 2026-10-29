velocidade = 2.0 * escala_sala();   // personagem maior anda proporcionalmente mais rápido
image_speed = 0;
usar_fonte();   // fonte com acentos (ou a padrão, se ainda não foi gerada)
cyber_init();   // mods (para desenhar as partes equipadas no mapa)
display_set_gui_size(480, 270);
paredes_criar();        // paredes invisíveis da sala (scr_paredes)
diario_aberto = false;  // Q (ou M/TAB) abre o diário de missões
diario_sel = 0;         // missão selecionada no diário
diario_anim = 0;        // 0 = fechado, 1 = aberto (animação)
garantir_controle();    // transições e animações de missão (obj_controle)
tocar_musica(snd_musica_ambiente);   // tema da empresa nas salas de exploração

// Animação: spr_Nexa = parada | spr_Nexa_andar = caminhando
sprite_index = spr_Nexa;
mask_index = spr_mask_pes;   // colisão só nos pés (top-down), não muda com a passada
olhar = 1;               // 1 = direita, -1 = esquerda (espelha o sprite)
anim = 0;

// Se veio por uma porta, luta ou oficina, nasce no ponto combinado
if (variable_global_exists("usar_spawn") && global.usar_spawn) {
	x = global.spawn_x;
	y = global.spawn_y;
	global.usar_spawn = false;
}
depth = -y;

// --- Câmera fixa mostrando a sala inteira (estilo top-down) ---
// A visão tem 16:9 e cobre a sala toda; salas mais altas ou quadradas
// ganham faixas pretas nas laterais, sem distorcer a arte.
ajustar_camera = function() {
	var _cam = view_camera[0];
	var _vw = max(room_width, room_height * 16 / 9);
	var _vh = _vw * 9 / 16;
	camera_set_view_target(_cam, noone);
	camera_set_view_size(_cam, _vw, _vh);
	camera_set_view_pos(_cam, (room_width - _vw) / 2, (room_height - _vh) / 2);
};
ajustar_camera();

// Cena pós-luta que ficou pendente (vinda do obj_battle)
if (variable_global_exists("cena_pendente") && global.cena_pendente != "") {
	var _cena = global.cena_pendente;
	global.cena_pendente = "";
	iniciar_dialogo(_cena, "nada", -1);
}
