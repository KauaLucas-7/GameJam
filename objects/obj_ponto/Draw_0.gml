if (dados == undefined) exit;
var _esc = escala_sala();
escala_inicio(x, y + 28, _esc);   // desenha em escala, ancorado na base
var _p = 0.5 + 0.5 * sin(anim * 0.08);   // pulsar

switch (dados.tipo) {

	case "arquivo":
		// Cubo de dados holográfico flutuando
		var _fy = y + sin(anim * 0.06) * 3;
		draw_set_alpha(0.3);
		draw_set_color(c_aqua);
		draw_ellipse(x - 10, y + 10, x + 10, y + 16, false);
		draw_set_alpha(0.6 + 0.4 * _p);
		draw_set_color(merge_colour(c_aqua, c_white, _p * 0.5));
		draw_rectangle(x - 7, _fy - 7, x + 7, _fy + 7, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_rectangle(x - 7, _fy - 7, x + 7, _fy + 7, true);
		draw_line(x - 4, _fy - 2, x + 4, _fy - 2);
		draw_line(x - 4, _fy + 2, x + 2, _fy + 2);
		break;

	case "espelho":
		// Espelho de parede com moldura
		var _usado = ponto_usado(ponto_id);
		draw_set_color(make_colour_rgb(70, 60, 50));
		draw_roundrect(x - 12, y - 30, x + 12, y + 8, false);
		draw_set_color(merge_colour(make_colour_rgb(120, 140, 170), c_white, _usado ? 0.1 : 0.25 * _p));
		draw_roundrect(x - 9, y - 27, x + 9, y + 5, false);
		draw_set_color(c_white);
		draw_line(x - 5, y - 22, x - 1, y - 26);   // brilho
		draw_line(x - 6, y - 16, x + 1, y - 23);
		break;

	case "terminal":
	case "ouvidoria":
		var _tela = (dados.tipo == "ouvidoria") ? c_fuchsia : c_lime;
		var _txt  = (dados.tipo == "ouvidoria") ? "OUV" : "GIT";
		draw_set_alpha(0.3);
		draw_set_color(c_black);
		draw_ellipse(x - 18, y + 22, x + 18, y + 30, false);
		draw_set_alpha(1);
		draw_set_color(make_colour_rgb(40, 44, 60));
		draw_rectangle(x - 14, y - 4, x + 14, y + 24, false);
		draw_set_color(merge_colour(make_colour_rgb(30, 30, 40), _tela, 0.5 + 0.4 * _p));
		draw_rectangle(x - 13, y - 28, x + 13, y - 7, false);
		draw_set_color(c_black);
		draw_rectangle(x - 13, y - 28, x + 13, y - 7, true);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed(x, y - 17, _txt, 0.55, 0.55, 0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		break;
}

draw_set_color(c_white);
escala_fim();
event_inherited();   // aviso [E]
