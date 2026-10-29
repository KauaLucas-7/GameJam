anim++;
depth = -y;

if (iniciando || instance_exists(obj_dialogo) || !instance_exists(obj_Nexa)) exit;
texto_prompt = liberado() ? "[E] Enfrentar" : "[E] Falar";
if (modo != "perseguir") exit;
if (!liberado()) exit;   // chefe bloqueado não persegue a Nexa

var _d = point_distance(x, y, obj_Nexa.x, obj_Nexa.y);
if (!avistou && _d <= raio_visao) avistou = true;

if (avistou) {
	if (_d > 46 * escala_sala()) {
		// Vai direto até a Nexa (passa por cima dos móveis)
		var _dir = point_direction(x, y, obj_Nexa.x, obj_Nexa.y);
		x += lengthdir_x(velocidade, _dir);
		y += lengthdir_y(velocidade, _dir);
	} else {
		iniciar();
	}
}
