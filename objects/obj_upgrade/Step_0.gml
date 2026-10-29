if (keyboard_check_pressed(vk_up))   row = (row - 1 + 4) mod 4;
if (keyboard_check_pressed(vk_down)) row = (row + 1) mod 4;

if (row < 3) {
    var _slot = global.mod_slots[row];
    var _opts = cyber_options(_slot);
    var _i = array_get_index(_opts, global.mod_equipped[$ _slot]);
    var _n = array_length(_opts);

    if (keyboard_check_pressed(vk_right)) { _i = (_i + 1) mod _n;      cyber_equip(_slot, _opts[_i]); }
    if (keyboard_check_pressed(vk_left))  { _i = (_i - 1 + _n) mod _n; cyber_equip(_slot, _opts[_i]); }
} else {
    if (keyboard_check_pressed(vk_enter)) room_goto(Room1);   // volta para a batalha (próximo andar)
}