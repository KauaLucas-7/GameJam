draw_set_color(c_white);
draw_text(150, 10, "OFICINA - MODIFICACOES");

// Prévia da Nexa ampliada, com as camadas dos mods
var _px = 130, _py = 140, _s = 3;
var _frame = floor(current_time / 1000 * 6) mod sprite_get_number(spr_Nexa);
cyber_draw(spr_Nexa, _frame, _px, _py, _s);

// Círculo piscando na parte do corpo selecionada
if (row < 3) {
    var _mk = global.mod_marker[$ global.mod_slots[row]];
    var _mx = _px + (_mk.x - 25) * _s;
    var _my = _py + (_mk.y - 24) * _s;
    draw_set_color((floor(current_time / 250) mod 2 == 0) ? c_aqua : c_white);
    draw_circle(_mx, _my, 14, true);
    draw_circle(_mx, _my, 15, true);
    draw_set_color(c_white);
}

// Slots
for (var i = 0; i < 3; i++) {
    var _sl = global.mod_slots[i];
    var _id = global.mod_equipped[$ _sl];
    var _label = (_id == "") ? "(vazio)" : global.mods[$ _id].name;
    draw_text(230, 50 + i * 36, ((i == row) ? "> " : "  ") + global.slot_names[$ _sl] + ": " + _label);
    if (_id != "") {
        draw_set_color(c_aqua);
        draw_text(244, 50 + i * 36 + 14, global.mods[$ _id].desc);
        draw_set_color(c_white);
    }
}
draw_text(230, 50 + 3 * 36, ((row == 3) ? "> " : "  ") + "Continuar (Enter)");

draw_text(230, 190, "ATK +" + string(cyber_total("atk")) + "  DEF +" + string(cyber_total("def"))
                  + "  SPD +" + string(cyber_total("spd")) + "  HP +" + string(cyber_total("hp")));
draw_text(230, 215, "Cima/baixo: parte do corpo | Esq/dir: trocar mod");