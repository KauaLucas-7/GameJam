var _w = sprite_get_width(sprite_mapa) * escala;
var _h = sprite_get_height(sprite_mapa) * escala;
var _f = floor(anim / 10) mod sprite_get_number(sprite_mapa);

// Sombra
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - _w * 0.4, y + _h * 0.5 - 6, x + _w * 0.4, y + _h * 0.5 + 4, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Chefe (sprites com origem no centro)
draw_sprite_ext(sprite_mapa, _f, x, y + sin(anim * 0.06) * 2, escala, escala, 0, c_white, 1);

// "!" vermelho quando avista a Nexa
if (avistou && !iniciando) {
	texto_mundo(x, y - _h * 0.5 - 4, "!", c_red);
	exit;
}

event_inherited();   // aviso [E]
