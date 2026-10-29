function cyber_init() {
    if (variable_global_exists("cyber_ready")) return;   // roda uma vez; os mods sobrevivem entre batalhas
    global.cyber_ready = true;

    global.mod_slots = ["arms", "torso", "legs"];
    global.slot_names = { arms: "Bracos", torso: "Torso", legs: "Pernas" };

    // Cada mod: slot + bônus. Campo que não existe conta como 0.
    global.mods = {
        gorilla:    { name: "Bracos de Gorila",        slot: "arms",  desc: "+4 ATK",                        atk: 4 },
        mantis:     { name: "Laminas Mantis",          slot: "arms",  desc: "+2 ATK, +25% energia",          atk: 2, energy_mult: 0.25 },
        subdermal:  { name: "Armadura Subdermica",     slot: "torso", desc: "+3 DEF, +10 HP",                def: 3, hp: 10 },
        kerenzikov: { name: "Kerenzikov",              slot: "torso", desc: "Barra de timing 30% mais lenta", timing_slow: 0.3 },
        tendons:    { name: "Tendoes Reforcados",      slot: "legs",  desc: "+3 SPD",                        spd: 3 },
        ankles:     { name: "Tornozelos Fortificados", slot: "legs",  desc: "+2 DEF, +1 SPD",                def: 2, spd: 1 }
    };

    global.mod_inventory = [];                                  // ids dos mods que o jogador possui
    global.mod_equipped = { arms: "", torso: "", legs: "" };    // "" = nada equipado
    global.mod_overlay = { arms: spr_Nexa_arms, torso: spr_Nexa_torso, legs: spr_Nexa_legs };

    // Ponto (no sprite) que a oficina destaca em cada parte do corpo
    global.mod_marker = { arms: {x: 26, y: 27}, torso: {x: 33, y: 21}, legs: {x: 32, y: 45} };
}

function cyber_give(_id) {
    if (array_get_index(global.mod_inventory, _id) == -1) array_push(global.mod_inventory, _id);
}

function cyber_equip(_slot, _id) {
    if (_id != "" && global.mods[$ _id].slot != _slot) return;   // mod no slot errado
    global.mod_equipped[$ _slot] = _id;
}

// O que dá para equipar num slot ("" = tirar o mod)
function cyber_options(_slot) {
    var _res = [""];
    for (var i = 0; i < array_length(global.mod_inventory); i++) {
        var _id = global.mod_inventory[i];
        if (global.mods[$ _id].slot == _slot) array_push(_res, _id);
    }
    return _res;
}

// Soma um atributo de todos os mods equipados (ex.: cyber_total("atk"))
function cyber_total(_key) {
    var _sum = 0;
    for (var i = 0; i < array_length(global.mod_slots); i++) {
        var _id = global.mod_equipped[$ global.mod_slots[i]];
        if (_id != "") {
            var _m = global.mods[$ _id];
            if (variable_struct_exists(_m, _key)) _sum += _m[$ _key];
        }
    }
    return _sum;
}

// Aplica os bônus ao herói recém-criado
function cyber_apply(_u) {
    _u.atk += cyber_total("atk");
    _u.def += cyber_total("def");
    _u.spd += cyber_total("spd");
    _u.hp_max += cyber_total("hp");
    _u.hp = _u.hp_max;
}

// Desenha o corpo e, por cima, a camada de cada parte que tem mod
function cyber_draw(_spr, _frame, _x, _y, _scale = 1, _tint = c_white) {
    draw_sprite_ext(_spr, _frame, _x, _y, _scale, _scale, 0, _tint, 1);
    if (_spr != spr_Nexa) return;

    var _order = ["legs", "torso", "arms"];   // braços por cima
    for (var i = 0; i < 3; i++) {
        var _slot = _order[i];
        if (global.mod_equipped[$ _slot] != "") {
            var _ov = global.mod_overlay[$ _slot];
            draw_sprite_ext(_ov, _frame mod sprite_get_number(_ov), _x, _y, _scale, _scale, 0, _tint, 1);
        }
    }
}

// Só para testes
function cyber_give_all() {
    var _names = variable_struct_get_names(global.mods);
    for (var i = 0; i < array_length(_names); i++) cyber_give(_names[i]);
}
