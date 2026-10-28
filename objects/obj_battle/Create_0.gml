display_set_gui_size(480, 270);

enum BATTLE_STATE { START, PLAYER_MENU, PLAYER_SKILL, PLAYER_TARGET, PLAYER_TIMING,
	 EXECUTE_ACTION, ENEMY_TURN, DEFENSE, CHECK_END, WIN, LOSE }

state = BATTLE_STATE.START;

// --- Skills e itens (recriados a cada batalha) ---
global.skills = {
    shock:    { name: "Curto circuito", cost: 5, power: 19, element: "lightning", heal: false },
    fireball: { name: "Bola de fogo",   cost: 8, power: 16, element: "fire",      heal: false },
    cure:     { name: "Cura",           cost: 6, power: 15, element: "none",      heal: true  }
};

global.items = {
    potion: { name: "Pocao", heal: 20, qty: 3 }
};

// --- Unidades ---
party = [ make_unit("Heroi", 40, 20, 10, 3, 8, true) ];
party[0].sprite = spr_Nexa;
party[0].skills = [ global.skills.shock, global.skills.fireball, global.skills.cure ];

var _slime = make_unit("Slime", 20, 10, 6, 1, 5, false);
_slime.weak_to = "fire";
enemies = [ _slime, make_unit("Goblin", 25, 15, 8, 2, 6, false) ];

// --- Ordem dos turnos ---
turn_order = array_concat(party, enemies);
array_sort(turn_order, function(a, b) { return b.spd - a.spd; });
turn_index = 0;
current = turn_order[turn_index];

// --- Menu ---
log_text = "A batalha comecou!";
menu_options = ["Atacar", "Defender", "Habilidade", "Item", "Especial"];
menu_index = 0;
skill_index = 0;
target_index = 0;
chosen_action = "";
chosen_skill = undefined;
timer = 0;

// --- Funções auxiliares ---
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
    if (_weak) _d *= 2;
    if (_tgt.defending) _d = floor(_d / 2);
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

timing_pos = 0;
timing_dir = 1; 
timing_speed = 0.025;
chosen_target = undefined;

// --- Combo / energia ---
combo = 0;
energy = 0;
energy_max = 100;
last_result = "none";   // "perfect", "good", "miss" ou "none" (lido no CHECK_END)

// --- Defesa ativa ---
def_timer = 0;
def_hit = 50;           // frame em que o golpe do inimigo acerta
def_press = -1;         // frame em que o jogador apertou (-1 = não apertou)
def_victim = undefined;
def_x = 0;
def_y = 0;

// --- Efeitos visuais ---
popups = [];
shake_time = 0;
shake_max = 1;
shake_power = 0;
shake_x = 0;
shake_y = 0;

// Campos extras em cada unidade (barra suave + detecção de dano)
for (var i = 0; i < array_length(turn_order); i++) {
    turn_order[i].hp_shown = turn_order[i].hp;   // valor "desenhado" da barra
    turn_order[i].hp_prev  = turn_order[i].hp;   // HP do frame anterior
}

// Centro de cada unidade na tela (onde o número aparece)
get_unit_pos = function(_u) {
    for (var i = 0; i < array_length(party); i++) {
        if (party[i] == _u) return { x: 80, y: 100 + i * 60 };
    }
    for (var i = 0; i < array_length(enemies); i++) {
        if (enemies[i] == _u) return { x: 392, y: 76 + i * 60 };
    }
    return { x: 240, y: 135 };
}

add_popup = function(_x, _y, _text, _color) {
    array_push(popups, { x: _x, y: _y, text: _text, color: _color,
                         life: 50, life_max: 50, vy: -0.8 });
}

start_shake = function(_power, _frames) {
    shake_power = _power;
    shake_time = _frames;
    shake_max = _frames;
}

draw_hp_bar = function(_x, _y, _w, _h, _u) {
    var _now   = clamp(_u.hp / _u.hp_max, 0, 1);
    var _shown = clamp(_u.hp_shown / _u.hp_max, 0, 1);
    var _front = min(_now, _shown);   // parte colorida
    var _back  = max(_now, _shown);   // rastro do dano (ou brilho da cura)

    draw_set_color(c_black);          // moldura
    draw_rectangle(_x - 1, _y - 1, _x + _w + 1, _y + _h + 1, false);
    draw_set_color(c_dkgray);         // fundo
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);

    draw_set_color((_shown > _now) ? c_yellow : c_white);   // amarelo = dano, branco = cura
    draw_rectangle(_x, _y, _x + _w * _back, _y + _h, false);

    draw_set_color((_front > 0.5) ? c_lime : ((_front > 0.25) ? c_orange : c_red));
    draw_rectangle(_x, _y, _x + _w * _front, _y + _h, false);

    draw_set_color(c_white);
}