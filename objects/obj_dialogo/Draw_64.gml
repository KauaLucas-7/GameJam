if (i >= array_length(linhas)) exit;

var _fala = linhas[i];
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _x1 = 40, _y1 = _gh - 180, _x2 = _gw - 40, _y2 = _gh - 30;

draw_set_alpha(0.85);
draw_set_color(c_black);
draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_alpha(1);

draw_set_color(c_white);
draw_rectangle(_x1, _y1, _x2, _y2, true);

if (_fala[0] != "") {
	draw_set_color(c_yellow);
	draw_text(_x1 + 20, _y1 + 14, nome_falante(_fala[0]));
}
draw_set_color(c_white);
draw_text_ext(_x1 + 20, _y1 + 48, _fala[1], 26, _x2 - _x1 - 40);
draw_text(_x2 - 260, _y2 - 28, "[ESPAÇO] continuar");
