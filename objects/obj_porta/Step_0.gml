if (instance_exists(obj_dialogo) || em_transicao()) exit;
if (!place_meeting(x, y, obj_Nexa)) exit;

// Caminho: andar1 <-> corredor1 <-> andar2 <-> corredor2 <-> andar3
// Porta de cima (metade de cima da room) sobe; porta de baixo desce.
// _sx/_sy = onde a Nexa nasce na room de destino (fora da porta de lá).
var _cima = (y < room_height / 2);
var _d = -1, _sx = 0, _sy = 0;

switch (room) {
	case rm_andar1:
		_d = rm_corredor1; _sx = 176; _sy = 150;
		break;

	case rm_corredor1:
		if (_cima) { _d = rm_andar1; _sx = 632; _sy = 985; }
		else       { _d = rm_andar2; _sx = 121; _sy = 264; }
		break;

	case rm_andar2:
		if (_cima) { _d = rm_corredor1; _sx = 784; _sy = 400; }
		else       { _d = rm_corredor2; _sx = 176; _sy = 150; }
		break;

	case rm_corredor2:
		if (_cima) { _d = rm_andar2; _sx = 740; _sy = 800; }
		else       { _d = rm_andar3; _sx = 724; _sy = 900; }   // porta do 3º andar fica embaixo, como na arte
		break;

	case rm_andar3:
		_d = rm_corredor2; _sx = 784; _sy = 400;
		break;
}
if (_d == -1) exit;

global.spawn_x = _sx;
global.spawn_y = _sy;
global.usar_spawn = true;
trocar_sala(_d);   // fade com o card do ambiente (obj_controle)
