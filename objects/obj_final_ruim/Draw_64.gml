var _l = legendas[q];
var _fr = floor(anim / 12) mod sprite_get_number(spr_Nexa);
var _e = ease_out(q_t / 40);

draw_set_color(c_black);
draw_rectangle(0, 0, 480, 270, false);


if (!fim) switch (_l.vis) {

	case "promocao":
		var _sc = 480 / sprite_get_width(spr_sala_urso);
		gpu_set_texfilter(true);
		draw_sprite_ext(spr_sala_urso, 0, 0, (270 - sprite_get_height(spr_sala_urso) * _sc) / 2, _sc, _sc, 0, c_white, 1);
		gpu_set_texfilter(false);
		draw_set_alpha(0.6); draw_set_color(c_black); draw_rectangle(0, 0, 480, 270, false); draw_set_alpha(1);
		desenhar_nexa_moldada(190, 130, 2.2, c_white, 1);
		draw_sprite_ext(spr_urso, _fr mod sprite_get_number(spr_urso), 320, 122, 0.8, 0.8, 0, c_white, 1);
		// o "contrato" da promoção
		draw_set_color(c_white);
		draw_roundrect(234, 96, 276, 120, false);
		draw_set_color(c_black);
		draw_set_halign(fa_center); draw_set_valign(fa_middle);
		draw_text_transformed(255, 108, texto_seguro("PROMOÇÃO"), 0.5, 0.5, 0);
		draw_set_halign(fa_left); draw_set_valign(fa_top);
		break;

	case "sobrecarga":
		// a Nexa vai ficando cinza enquanto as cobranças se acumulam
		var _cinza = merge_colour(c_white, c_gray, clamp(q_t / 300, 0, 0.9));
		desenhar_nexa_moldada(240, 132, 2.2, _cinza, 1);
		for (var i = 0; i < array_length(avisos); i++) {
			var _a = avisos[i];
			var _w = string_width(_a.s) * 0.7 + 12;
			draw_set_alpha(0.92);
			draw_set_color(make_colour_rgb(60, 14, 20));
			draw_roundrect(_a.x, _a.y, _a.x + _w, _a.y + 14, false);
			draw_set_alpha(1);
			draw_set_color(c_red);
			draw_roundrect(_a.x, _a.y, _a.x + _w, _a.y + 14, true);
			draw_set_color(c_white);
			draw_text_transformed(_a.x + 6, _a.y + 2, texto_seguro(_a.s), 0.7, 0.7, 0);
		}
		break;

	case "isolamento":
		// as colegas chamam de longe, cada vez mais apagadas
		for (var i = 0; i < array_length(colegas); i++) {
			var _cx = (i < 2) ? 60 + i * 60 : 360 + (i - 2) * 60;
			desenhar_robo(_cx, 150, 1.5, colegas[i], anim + i * 20, false, max(0.15, 0.8 - q_t / 300));
		}
		draw_set_alpha(0.25);
		draw_set_color(c_white);
		draw_circle(240, 140, 50, false);
		draw_set_alpha(1);
		desenhar_nexa_moldada(240, 136, 2.2, c_gray, 1);
		break;

	case "mesa":
		// Escritório vazio à noite: só a mesa, a cadeira e o monitor ligado.
		// (Nada é mostrado além da ausência.)
		draw_set_color(make_colour_rgb(10, 12, 20));
		draw_rectangle(0, 0, 480, 270, false);
		// janela com chuva
		draw_set_color(make_colour_rgb(18, 24, 40));
		draw_rectangle(150, 30, 330, 90, false);
		draw_set_alpha(0.4);
		draw_set_color(make_colour_rgb(120, 140, 180));
		for (var r = 0; r < 18; r++) {
			var _rx = 150 + ((r * 37 + anim * 2) mod 180), _ry = 30 + ((r * 23 + anim * 3) mod 60);
			draw_line(_rx, _ry, _rx - 2, _ry + 6);
		}
		draw_set_alpha(1);
		// mesa
		draw_set_color(make_colour_rgb(40, 32, 30));
		draw_rectangle(130, 150, 350, 166, false);
		draw_rectangle(140, 166, 148, 210, false);
		draw_rectangle(332, 166, 340, 210, false);
		// monitor piscando
		var _pisca = 0.35 + 0.15 * sin(anim * 0.07) + ((anim mod 97 < 3) ? 0.3 : 0);
		draw_set_alpha(_pisca * 0.5);
		draw_set_color(c_aqua);
		draw_ellipse(190, 100, 290, 170, false);
		draw_set_alpha(1);
		draw_set_color(make_colour_rgb(20, 24, 30));
		draw_rectangle(210, 112, 270, 146, false);
		draw_set_color(merge_colour(c_black, c_aqua, _pisca));
		draw_rectangle(213, 115, 267, 143, false);
		draw_set_color(make_colour_rgb(20, 24, 30));
		draw_rectangle(236, 146, 244, 150, false);
		// crachá e caneca sobre a mesa
		draw_set_color(c_white);
		draw_rectangle(290, 144, 306, 150, false);
		draw_set_color(c_black);
		draw_text_transformed(291, 144, "NEXA", 0.35, 0.35, 0);
		draw_set_color(make_colour_rgb(150, 60, 60));
		draw_rectangle(166, 140, 174, 150, false);
		// cadeira vazia
		draw_set_color(make_colour_rgb(30, 30, 40));
		draw_roundrect(220, 172, 260, 200, false);
		draw_rectangle(238, 200, 242, 214, false);
		draw_rectangle(226, 214, 254, 217, false);
		// vinheta
		draw_set_alpha(0.5);
		draw_set_color(c_black);
		draw_rectangle(0, 0, 480, 24, false);
		draw_set_alpha(1);
		break;

	case "dado":
		draw_set_halign(fa_center);
		draw_set_alpha(_e);
		draw_set_color(c_white);
		draw_text_transformed(240, 70, "QUASE 70%", 2.6 * ease_back(q_t / 30), 2.6 * ease_back(q_t / 30), 0);
		draw_set_alpha(min(1, q_t / 60));
		draw_set_color(c_gray);
		draw_text_transformed(240, 130, texto_seguro("Fonte: Ministério da Saúde, Boletim Epidemiológico"), 0.7, 0.7, 0);
		draw_set_halign(fa_left);
		draw_set_alpha(1);
		break;

	case "apoio":
		var _g = 0.5 + 0.5 * sin(anim * 0.03);
		draw_set_alpha(0.15 + 0.1 * _g);
		draw_set_color(c_aqua);
		draw_circle(240, 100, 70 + 6 * _g, false);
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_set_color(c_aqua);
		draw_text_transformed(240, 70, "CVV  188", 2.2, 2.2, 0);
		draw_set_color(c_ltgray);
		draw_text(240, 110, texto_seguro("24 horas, gratuito e sigiloso  -  cvv.org.br"));
		draw_set_halign(fa_left);
		break;
}

// ----- Legenda -----
if (!fim) {
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 22, false);
	draw_set_alpha(0.85);
	draw_set_color(make_colour_rgb(8, 8, 14));
	draw_roundrect(8, 192, 472, 264, false);
	draw_set_alpha(1);
	draw_set_color(c_dkgray);
	draw_roundrect(8, 192, 472, 264, true);
	draw_set_halign(fa_center);
	draw_set_color(make_colour_rgb(215, 218, 228));
	draw_text_ext(240, 204, texto_seguro(string_copy(_l.txt, 1, floor(letras))), 14, 440);
	draw_set_halign(fa_left);
	if (letras >= string_length(_l.txt)) {
		draw_set_alpha(0.5 + 0.5 * sin(current_time / 200));
		draw_set_color(c_gray);
		draw_set_halign(fa_right);
		draw_text(464, 248, texto_seguro("[ESPAÇO]"));
		draw_set_halign(fa_left);
		draw_set_alpha(1);
	}
}

// ----- Tela final -----
if (fim) {
	var _a = ease_out(fim_t / 40);
	draw_set_alpha(_a);
	draw_set_halign(fa_center);
	draw_set_color(c_red);
	draw_text_transformed(240, 70, "FINAL RUIM", 2.2, 2.2, 0);
	draw_set_color(c_white);
	draw_text(240, 112, texto_seguro("Ninguém precisa caber num molde para ter valor."));
	draw_set_color(c_aqua);
	draw_text(240, 130, texto_seguro("Se precisar conversar: CVV 188 ou cvv.org.br"));
	if (fim_t > 40) {
		draw_set_alpha(0.5 + 0.5 * sin(current_time / 200));
		draw_set_color(c_ltgray);
		draw_text(240, 180, texto_seguro("[ENTER] tentar de novo e recusar o molde"));
		draw_text(240, 198, "[ESC] voltar ao menu");
	}
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}
draw_set_color(c_white);
