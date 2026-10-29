function make_urso() {
    var _u = make_unit("Urso", 120, 0, 11, 3, 6, false);
    _u.is_urso = true;
    _u.pos = { x: 380, y: 115 };   // posição na tela (Draw e números de dano)
    return _u;
}

function make_worker(_name, _slot, _pos) {
    var _w = make_unit(_name, 18, 0, 6, 1, 5, false);
    _w.is_worker = true;
    _w.slot = _slot;
    _w.pos = _pos;
    return _w;
}

function is_urso(_u)   { return variable_struct_exists(_u, "is_urso"); }
function is_worker(_u) { return variable_struct_exists(_u, "is_worker"); }