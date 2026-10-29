if (instance_exists(obj_dialogo)) exit;
if (!place_meeting(x, y, obj_Nexa)) exit;

// Destino e ponto de nascimento na sala de destino, pela sala atual e pela posição da porta
var _d = -1, _sx = 0, _sy = 0;
switch (room) {
	case rm_andar1:
		// porta de baixo do 1º andar -> 2º andar, perto da porta de cima
		_d = rm_andar2; _sx = 121; _sy = 264;
		break;
	case rm_andar2:
		if (y < room_height / 2) {
			// porta de cima -> 1º andar, perto da porta de baixo
			_d = rm_andar1; _sx = 632; _sy = 1000;
		} else {
			// porta de baixo -> 3º andar (ajuste o spawn quando montar o 3º)
			_d = rm_andar3; _sx = 724; _sy = 700;
		}
		break;
}
if (_d == -1) exit;

global.spawn_x = _sx;
global.spawn_y = _sy;
global.usar_spawn = true;
room_goto(_d);
