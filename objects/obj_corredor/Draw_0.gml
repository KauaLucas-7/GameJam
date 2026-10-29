// Piso
draw_set_color(make_colour_rgb(46, 50, 66));
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_color(make_colour_rgb(56, 61, 80));
for (var _x = 0; _x <= room_width; _x += 32) draw_line(_x, 0, _x, room_height);
for (var _y = 0; _y <= room_height; _y += 32) draw_line(0, _y, room_width, _y);

// Carpete ligando a porta de cima à de baixo
draw_set_color(make_colour_rgb(86, 38, 48));
with (obj_porta) {
	// guarda o centro de cada porta para traçar o caminho
	if (y < room_height / 2) { other.px1 = (bbox_left + bbox_right) / 2; }
	else                     { other.px2 = (bbox_left + bbox_right) / 2; }
}
var _meio = room_height / 2;
draw_rectangle(px1 - 40, 0, px1 + 40, _meio + 40, false);
draw_rectangle(min(px1, px2) - 40, _meio - 40, max(px1, px2) + 40, _meio + 40, false);
draw_rectangle(px2 - 40, _meio - 40, px2 + 40, room_height, false);

// Paredes (obj_parede é invisível; aqui elas ganham cor)
with (obj_parede) {
	draw_set_color(make_colour_rgb(24, 26, 36));
	draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
	draw_set_color(make_colour_rgb(80, 86, 110));
	draw_line(bbox_left, bbox_bottom, bbox_right, bbox_bottom);
}

// Placa no chão
texto_mundo(room_width / 2, room_height - 80, placa, make_colour_rgb(150, 156, 180));
