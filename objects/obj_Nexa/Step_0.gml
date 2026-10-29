// Sem movimento durante o diálogo
if (instance_exists(obj_dialogo)) {
	image_speed = 0;
	exit;
}

// Setas ou WASD
var _h = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var _v = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

// Diagonal não fica mais rápida
if (_h != 0 && _v != 0) {
	_h *= 0.7071;
	_v *= 0.7071;
}

// Colide com obj_parede (paredes e móveis)
move_and_collide(_h * velocidade, _v * velocidade, obj_parede);

// Não sai da sala
x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);

image_speed = (_h != 0 || _v != 0) ? 0.2 : 0;
