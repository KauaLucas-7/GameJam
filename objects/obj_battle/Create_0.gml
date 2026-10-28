display_set_gui_size(480, 270);

enum BATTLE_STATE { START, PLAYER_MENU, PLAYER_SKILL, PLAYER_TARGET, PLAYER_TIMING,
	 EXECUTE_ACTION, ENEMY_TURN, ROLL, DEFENSE, CHECK_END, WIN, LOSE }

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

var _dado = make_unit("Dado BD", 50, 0, 9, 2, 4, false);
_dado.is_dice = true;
_dado.sprite = spr_BancoDb;
enemies = [ _dado ];

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
    var _atk_val = _atk.atk;
    if (_atk.is_player && atk_debuff > 0) _atk_val *= 0.7;   // UPDATE: ATK -30%
    var _d = floor(_atk_val * _mult) - _tgt.def + irandom(2);
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

get_unit_pos = function(_u) {
    for (var i = 0; i < array_length(party); i++) {
        if (party[i] == _u) return { x: 80, y: 100 + i * 60 };
    }
    for (var i = 0; i < array_length(enemies); i++) {
        if (enemies[i] == _u) {
            if (_u.is_dice) return { x: 370, y: 125 };
            return { x: 392, y: 76 + i * 60 };
        }
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

// ===== BOSS 1: BANCO DE DADOS =====
roll_active = false;       // true enquanto o selo da face deve aparecer
roll_timer = 0;
roll_result = 1;           // face sorteada de verdade
roll_face_shown = 1;       // face mostrada durante a animação
boss_phase2 = false;       // dado viciado (abaixo de 50% de HP)
boss_exposed = false;      // face 1 (NULL): seu próximo ataque vale 2x
boss_recharging = false;   // face 6 (DROP TABLE): ele perde o turno seguinte
atk_debuff = 0;            // face 3 (UPDATE): turnos restantes com ATK -30%
menu_locked = -1;          // face 4 (DROP COLUMN): índice da opção apagada

dice_faces = [
    { name: "NULL" },
    { name: "SELECT *" },
    { name: "UPDATE" },
    { name: "DROP COLUMN" },
    { name: "DELETE" },
    { name: "DROP TABLE" }
];

// Parâmetros do ataque inimigo (usados pelo estado DEFENSE)
enemy_mult = 1;
def_perfect = 3;
def_good = 8;
def_heavy = false;
def_hits_left = 1;
def_first = true;

// Sorteia a face (na fase 2 o dado é viciado: sem face 1 e com mais 5 e 6)
roll_dice = function(_boss) {
    if (_boss.hp <= _boss.hp_max * 0.5) {
        var _table = [2, 3, 4, 5, 5, 6, 6];
        return _table[irandom(array_length(_table) - 1)];
    }
    return irandom_range(1, 6);
}

// Prepara um ataque inimigo e abre a janela de defesa ativa
// _mult = multiplicador do dano | _hits = nº de golpes | _hit_frame = frames até acertar
// _perfect/_good = tamanho das janelas | _heavy = golpe pesado (defesa "boa" alivia pouco)
start_boss_attack = function(_mult, _hits, _hit_frame, _perfect, _good, _heavy) {
    var _allies = alive_list(party);
    def_victim = _allies[irandom(array_length(_allies) - 1)];
    for (var i = 0; i < array_length(party); i++) {
        if (party[i] == def_victim) { def_x = 80; def_y = 100 + i * 60; }
    }
    def_timer = 0;
    def_press = -1;
    def_hit = _hit_frame;
    def_perfect = _perfect;
    def_good = _good;
    def_heavy = _heavy;
    enemy_mult = _mult;
    def_hits_left = _hits;
    def_first = true;
    state = BATTLE_STATE.DEFENSE;
}

// Com vários golpes seguidos, vale o pior resultado para o combo
register_defense = function(_res) {
    if (def_first) last_result = _res;
    else if (_res == "miss" || last_result == "miss") last_result = "miss";
    else if (_res == "good" || last_result == "good") last_result = "good";
    else last_result = "perfect";
    def_first = false;
}

// Desenha o selo do dado com os pontos de 1 a 6
draw_dice_face = function(_x, _y, _s, _n) {
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _s, _y + _s, false);
    draw_set_color(c_black);
    draw_rectangle(_x, _y, _x + _s, _y + _s, true);

    var _a = _s * 0.25, _b = _s * 0.5, _c = _s * 0.75, _r = _s * 0.09;
    if (_n == 1 || _n == 3 || _n == 5) draw_circle(_x + _b, _y + _b, _r, false);
    if (_n >= 2) { draw_circle(_x + _a, _y + _a, _r, false); draw_circle(_x + _c, _y + _c, _r, false); }
    if (_n >= 4) { draw_circle(_x + _c, _y + _a, _r, false); draw_circle(_x + _a, _y + _c, _r, false); }
    if (_n == 6) { draw_circle(_x + _a, _y + _b, _r, false); draw_circle(_x + _c, _y + _b, _r, false); }
    draw_set_color(c_white);
}