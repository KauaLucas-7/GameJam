// Sem movimento durante diálogo, transição de sala ou cena de missão (pose parada)
if (instance_exists(obj_dialogo) || em_transicao()) {
	sprite_index = spr_Nexa;
	image_index = 0;
	exit;
}

if (!eh_web() && keyboard_check_pressed(vk_f1)) global.ver_paredes = !global.ver_paredes;   // teste das paredes (no navegador o F1 abre a ajuda)
if (tecla_missoes()) { diario_aberto = !diario_aberto; diario_sel = 0; marcar("tut_diario"); }   // Q, M ou TAB

// Diário aberto: cima/baixo escolhe a missão; a Nexa fica parada
if (diario_aberto) {
	var _n = array_length(global.missoes_ordem);
	if (_n > 0) {
		if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) diario_sel = (diario_sel - 1 + _n) mod _n;
		if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) diario_sel = (diario_sel + 1) mod _n;
	}
	if ((keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace))) diario_aberto = false;
	sprite_index = spr_Nexa;
	anim += 0.05;
	image_index = anim;
	exit;
}

// Cena de chegada na sala (só na 1ª visita)
var _cena_sala = "entrada_" + room_get_name(room);
if (!flag(_cena_sala) && falas_existe(_cena_sala)) {
	marcar(_cena_sala);
	iniciar_dialogo(_cena_sala, "nada", -1);
	exit;
}

// [E] interage com o NPC, chefe ou terminal mais próximo
if (keyboard_check_pressed(ord("E"))) {
	var _alvo = instance_nearest(x, y, obj_interagivel);
	if (_alvo != noone && point_distance(x, y, _alvo.x, _alvo.y) <= _alvo.raio) {
		sprite_index = spr_Nexa;
		image_index = 0;
		if (_alvo.object_index == obj_ponto) marcar("tut_objeto");   // tutorial: usou um objeto
		_alvo.interagir();
		exit;
	}
}

// Setas ou WASD
var _h = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var _v = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

// Diagonal não fica mais rápida
if (_h != 0 && _v != 0) {
	_h *= 0.7071;
	_v *= 0.7071;
}

// Colide com paredes/móveis, NPCs e terminais
move_and_collide(_h * velocidade, _v * velocidade, [obj_parede, obj_npc, obj_terminal_oficina]);

// Não sai da sala
x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);
depth = -y;

// --- Animação ---
if (_h != 0) olhar = sign(_h);   // subindo/descendo mantém o último lado
var _andando = (_h != 0 || _v != 0);

if (_andando) {
	if (sprite_index != spr_Nexa_andar) { sprite_index = spr_Nexa_andar; anim = 0; }
	anim += 0.18;   // ~11 quadros por segundo
} else {
	if (sprite_index != spr_Nexa) { sprite_index = spr_Nexa; anim = 0; }
	anim += 0.05;   // respiração lenta
}
image_index = anim;

// --- Tutorial: avança quando o jogador faz o que foi pedido ---
global.tut_t++;
if (_andando) global.tut_dist += velocidade;
if (global.tut_dist > 220) tut_avancar(0);                                   // andou
if (variable_struct_names_count(global.npc_falou) > 0) tut_avancar(1);       // conversou
if (global.tut_etapa == 3 && global.tut_t > 480) tut_avancar(3);            // já viu a dica dos objetos
if (flag("tut_diario")) tut_avancar(2);                                     // abriu o diário
if (flag("tut_objeto")) tut_avancar(3);                                     // usou um objeto
