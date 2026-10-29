if (em_transicao()) exit;
var _n_slots = array_length(global.mod_slots);
var _rows = _n_slots + 1;   // + "Voltar"

if (keyboard_check_pressed(vk_up))   row = (row - 1 + _rows) mod _rows;
if (keyboard_check_pressed(vk_down)) row = (row + 1) mod _rows;

if (row < _n_slots) {
    var _slot = global.mod_slots[row];
    var _opts = cyber_options(_slot);
    var _i = array_get_index(_opts, global.mod_equipped[$ _slot]);
    var _n = array_length(_opts);

    if (keyboard_check_pressed(vk_right)) { _i = (_i + 1) mod _n;      cyber_equip(_slot, _opts[_i]); }
    if (keyboard_check_pressed(vk_left))  { _i = (_i - 1 + _n) mod _n; cyber_equip(_slot, _opts[_i]); }
} else if (keyboard_check_pressed(vk_enter)) {
    sair();
}

if (keyboard_check_pressed(vk_backspace)) sair();
