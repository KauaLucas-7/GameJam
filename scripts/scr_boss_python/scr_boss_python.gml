#macro BOSS_TAIL_MAX 8

function boss_set_type(_boss, _index) {
    _boss.type_index = _index;
    _boss.weak_to = global.boss_types[_index].element;
}

function boss_init(_boss) {
    _boss.typed = true;     // marca o boss com tipagem
    _boss.type_turns = 0;
    _boss.tail = 0;
    boss_set_type(_boss, irandom(array_length(global.boss_types) - 1));
    return _boss;
}

function boss_dmg_mult(_boss) {
    return 1 + 0.1 * _boss.tail;   // +10% por segmento da cauda
}

// golpe que acertou (defesa boa ou erro): veneno +1 e cauda cresce
function boss_on_hit(_boss, _victim) {
    _python.tail = min(BOSS_TAIL_MAX, _boss.tail + 1);
    status_add(_victim, "poison", 1, 3);
    return " Veneno x" + string(status_stacks(_victim, "poison")) + "!";
}

// defesa perfeita: cauda encolhe, sem veneno
function boss_on_block(_boss) {
    _python.tail = max(0, _boss.tail - 1);
    return " A cauda encolheu!";
}

// fim do turno dela: a cada 2 turnos, troca de tipo
function boss_end_turn(_boss) {
    _python.type_turns++;
    if (_boss.type_turns < 2) return "";
    _python.type_turns = 0;
    var _new;
    do { _new = irandom(array_length(global.boss_types) - 1); } until (_new != _python.type_index);
    boss_set_type(_python, _new);
    return " Agora e " + global.boss_types[_new].name + "!";
}