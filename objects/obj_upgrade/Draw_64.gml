draw_set_color(c_white);
draw_text(150, 8, "OFICINA - MODIFICACOES");

var _n_slots = array_length(global.mod_slots);

// Prévia da Nexa ampliada, com as camadas dos mods
var _px = 110, _py = 140, _s = 3;
var _frame = floor(current_time / 1000 * 6) mod sprite_get_number(spr_Nexa);
cyber_draw(spr_Nexa, _frame, _px, _py, _s);

// Círculo piscando na parte do corpo selecionada (a ferramenta não tem marcador)
if (row < _n_slots && variable_struct_exists(global.mod_marker, global.mod_slots[row])) {
    var _mk = global.mod_marker[$ global.mod_slots[row]];
    var _mx = _px + (_mk.x - 25) * _s;
    var _my = _py + (_mk.y - 24) * _s;
    draw_set_color((floor(current_time / 250) mod 2 == 0) ? c_aqua : c_white);
    draw_circle(_mx, _my, 14, true);
    draw_circle(_mx, _my, 15, true);
    draw_set_color(c_white);
}

// Slots
for (var i = 0; i < _n_slots; i++) {
    var _sl = global.mod_slots[i];
    var _id = global.mod_equipped[$ _sl];
    var _label = (_id == "") ? "(vazio)" : global.mods[$ _id].name;
    var _ly = 34 + i * 30;
    draw_text(210, _ly, ((i == row) ? "> " : "  ") + global.slot_names[$ _sl] + ": " + _label);
    if (_id != "") {
        draw_set_color(c_aqua);
        draw_text(224, _ly + 13, global.mods[$ _id].desc);
        draw_set_color(c_white);
    }
}
draw_text(210, 34 + _n_slots * 30, ((row == _n_slots) ? "> " : "  ") + "Voltar ao mapa (Enter)");

draw_text(210, 196, "ATK +" + string(cyber_total("atk")) + "  DEF +" + string(cyber_total("def"))
                  + "  SPD +" + string(cyber_total("spd")) + "  HP +" + string(cyber_total("hp")));
draw_text(210, 220, "Cima/baixo: parte | Esq/dir: trocar");
draw_text(210, 236, "Backspace: voltar ao mapa");
