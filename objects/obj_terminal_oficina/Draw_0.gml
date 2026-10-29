anim++;
var _esc = escala_sala();
escala_inicio(x, y + 28, _esc);   // desenha em escala, ancorado na base

// Sombra
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 20, y + 24, x + 20, y + 32, false);
draw_set_alpha(1);

// Bancada
draw_set_color(make_colour_rgb(40, 44, 60));
draw_rectangle(x - 18, y - 6, x + 18, y + 28, false);
draw_set_color(make_colour_rgb(90, 96, 120));
draw_rectangle(x - 18, y - 6, x + 18, y + 28, true);

// Tela piscando
var _g = 0.5 + 0.5 * sin(anim * 0.08);
draw_set_color(merge_colour(c_teal, c_aqua, _g));
draw_rectangle(x - 15, y - 30, x + 15, y - 9, false);
draw_set_color(c_black);
draw_rectangle(x - 15, y - 30, x + 15, y - 9, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(x, y - 19, "MOD", 0.6, 0.6, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Braço robótico da bancada
draw_set_color(c_silver);
draw_line_width(x + 18, y + 2, x + 26, y - 14, 3);
draw_circle(x + 26, y - 16, 3, false);

draw_set_color(c_white);
escala_fim();
event_inherited();   // aviso [E]
