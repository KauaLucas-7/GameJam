// Personagem em escala proporcional à sala, com os pés fixos em y + 29
var _s = escala_sala();
var _pe = y + 29;

// Sombra no chão
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 13 * _s, _pe - 4 * _s, x + 13 * _s, _pe + 3 * _s, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Corpo + camadas dos mods equipados, virada para o lado em que anda
gpu_set_texfilter(false);   // pixel art nítida mesmo ampliada
cyber_draw(sprite_index, floor(image_index) mod sprite_get_number(sprite_index), x, _pe - 29 * _s, _s, c_white, olhar);
gpu_set_texfilter(true);

// F1: mostra as paredes invisíveis (para ajustar)
if (global.ver_paredes) {
	draw_set_alpha(0.35);
	draw_set_color(c_red);
	with (obj_parede) draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
	draw_set_color(c_yellow);
	draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);   // colisão da Nexa (pés)
	draw_set_alpha(1);
	draw_set_color(c_white);
}
