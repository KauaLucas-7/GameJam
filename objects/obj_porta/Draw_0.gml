// Brilho suave marcando a saída
draw_set_alpha(0.15 + 0.1 * sin(current_time / 300));
draw_set_color(c_aqua);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
draw_set_alpha(1);

// Seta: para cima nas portas de cima, para baixo nas de baixo
var _seta = (y < room_height / 2) ? "^" : "v";
texto_mundo((bbox_left + bbox_right) / 2, (bbox_top + bbox_bottom) / 2 + 8 * escala_mundo(), _seta);
