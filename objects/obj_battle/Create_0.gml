display_set_gui_size(480, 270); 

enum BATTLE_STATE { START,PLAYER_MENU, PLAYER_TARGET, EXECUTE_ACTION, ENEMY_TURN, CHECK_END, WIN, LOSE }

state = BATTLE_STATE.START;

party = [ make_unit("Heroi", 40, 20, 10, 3, 8, true) ]; 
party[0].sprite = spr_Nexa;
//alternar o nome dos inimigos
var _slime = make_unit("Slime", 20, 10, 6, 1, 5, false);
_slime.weak_to = "fire";
enemies = [ _slime, make_unit("Goblin", 25, 15, 8, 2, 6, false) ];

turn_order = array_concat(party, enemies);
array_sort(turn_order, function(a, b) { return b.spd - a.spd; });
turn_index = 0;
current = turn_order[turn_index]

menu_options = ["Atacar", "Defender", "Habilidade", "Item"];
menu_index = 0;
target_index = 0;
chosen_action = "";
timer = 0;

potions = 3;
log_text = "";

//oponente vivo
alive_list = function(_arr) {
    var _res = [];
    for (var i = 0; i < array_length(_arr); i++) {
        if (_arr[i].hp > 0) array_push(_res, _arr[i]);
    }
    return _res;
}

deal_damage = function(_atk, _tgt, _mult, _element) {
    var _d = floor(_atk.atk * _mult) - _tgt.def + irandom(2);
    var _weak = (_element != "" && _tgt.weak_to == _element);
    if (_weak) _d *= 2;                       // fraqueza dobra o dano
    if (_tgt.defending) _d = floor(_d / 2);   // defesa corta pela metade
    _d = max(1, _d);
    _tgt.hp = max(0, _tgt.hp - _d);
    log_text = _atk.name + " causou " + string(_d) + " em " + _tgt.name
             + (_weak ? " (fraqueza!)" : "");
}

next_turn = function() {
    do {
        turn_index = (turn_index + 1) mod array_length(turn_order);
    } until (turn_order[turn_index].hp > 0);   
    current = turn_order[turn_index];
    current.defending = false;                 
}
