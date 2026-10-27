draw_set_color(c_white);
draw_text(4, 4, "Estado: " + string(state));   // dica do guia: debug do estado

// Aliados (esquerda)
for (var i = 0; i < array_length(party); i+=1) {
    var _u = party[i];
    var _x = 80, _y = 100 + i * 60;
    if (_u.hp > 0) {
       if(_u.sprite !=1){
		   draw_sprite(_u.sprite, 0, _x, _y);
	   }else {
		draw_set_color(c_aqua);
	    draw_rectangle(_x, _y, _x + 24, _y + 32, false);
	    draw_set_color(c_white);
	   }
        if (_u == current) draw_text(_x - 14, _y + 8, ">");
    }
    draw_text(_x - 30, _y + 34, _u.name + " " + string(_u.hp) + "/" + string(_u.hp_max));
}

// Inimigos (direita)
var _alive = alive_list(enemies);
for (var i = 0; i < array_length(enemies); i++) {
    var _e = enemies[i];
    var _x = 380, _y = 60 + i * 60;
    if (_e.hp > 0) {
        draw_set_color(c_red);
        draw_rectangle(_x, _y, _x + 24, _y + 32, false);
        draw_set_color(c_white);
        if (_e == current) draw_text(_x - 14, _y + 8, "<");
        if (state == BATTLE_STATE.PLAYER_TARGET && _e == _alive[target_index])
            draw_text(_x + 4, _y - 14, "v");   // cursor de alvo
    }
    draw_text(_x - 20, _y + 34, _e.name + " " + string(_e.hp) + "/" + string(_e.hp_max));
}

// Menu
if (state == BATTLE_STATE.PLAYER_MENU) {
    for (var i = 0; i < array_length(menu_options); i++) {
        var _txt = menu_options[i];
        if (i == 3) _txt += " (" + string(potions) + ")";
        draw_text(20, 190 + i * 16, ((i == menu_index) ? "> " : "  ") + _txt);
    }
}

// Log e fim de batalha
draw_text(160, 240, log_text);
if (state == BATTLE_STATE.WIN)  draw_text(190, 20, "VITORIA! (Enter)");
if (state == BATTLE_STATE.LOSE) draw_text(190, 20, "DERROTA... (Enter)");
