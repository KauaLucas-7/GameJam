#macro POISON_DMG_PER_STACK 2

function status_find(_unit, _kind) {
    for (var i = 0; i < array_length(_unit.status); i++) {
        if (_unit.status[i].kind == _kind) return i;
    }
    return -1;
}

function status_stacks(_unit, _kind) {
    var _i = status_find(_unit, _kind);
    return (_i == -1) ? 0 : _unit.status[_i].stacks;
}

function status_add(_unit, _kind, _n, _max) {
    var _i = status_find(_unit, _kind);
    if (_i == -1) array_push(_unit.status, { kind: _kind, stacks: min(_n, _max) });
    else _unit.status[_i].stacks = min(_unit.status[_i].stacks + _n, _max);
}

function status_clear(_unit, _kind) {
    var _i = status_find(_unit, _kind);
    if (_i != -1) array_delete(_unit.status, _i, 1);
}

// dano do veneno no fim do turno da unidade; devolve o dano causado
function tick_status(_unit) {
    var _dmg = status_stacks(_unit, "poison") * POISON_DMG_PER_STACK;
    _unit.hp = max(0, _unit.hp - _dmg);
    return _dmg;
}