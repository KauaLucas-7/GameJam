display_set_gui_size(480, 270);
usar_fonte();   // fonte com acentos (ou a padrão, se ainda não foi gerada)

enum BATTLE_STATE { START, PLAYER_MENU, PLAYER_SKILL, PLAYER_TARGET, PLAYER_TIMING,
	 EXECUTE_ACTION, ENEMY_TURN, ROLL, DEFENSE, CHECK_END, PROPOSAL, MOLD_END, ENDING_BAD, WIN, LOSE, INTRO }

state = BATTLE_STATE.INTRO;   // começa com a cutscene de apresentação do chefe
intro_t = 0;
garantir_controle();

cyber_init();
// cyber_give_all();   // TESTE: tire as barras para lutar com todos os mods

// JUNTADO: andar atual (1 = boss Dado, 2 = boss Python, 3 = Urso, outro = inimigos normais)
urso = undefined;
if (!variable_global_exists("andar")) global.andar =  3;
// A sala de luta define o chefe (assim cada sala pode ser testada sozinha)
if (room == rom_banco_fight)      global.andar = 1;
else if (room == rm_python_fight) global.andar = 2;
else if (room == rom_urso_fight)  global.andar = 3;

// --- Skills e itens (recriados a cada batalha) ---
global.skills = {
    shock:    { name: "Curto circuito", cost: 5, power: 19, element: "lightning", heal: false },
    fireball: { name: "Bola de fogo",   cost: 8, power: 16, element: "fire",      heal: false },
    ice:      { name: "Raio de gelo",   cost: 6, power: 17, element: "ice",       heal: false },   // JUNTADO: 3o tipo do Python
    cure:     { name: "Cura",           cost: 6, power: 15, element: "none",      heal: true  },
    // Liberada pela missão "Reflexos" (espelhos)
    autoconfianca: { name: "Autoconfianca", cost: 6, power: 28, element: "none", heal: true }
};

global.items = {
    potion: { name: "Pocao", heal: 20, qty: 3 }
};

// JUNTADO: boss Python (tipos e elementos)
global.last_skill_note = "";
global.boss_types = [
    { name: "INT",   element: "lightning", color: c_aqua   },
    { name: "STR",   element: "fire",      color: c_orange },
    { name: "FLOAT", element: "ice",       color: c_lime   }
];

// --- Unidades ---
party = [ make_unit("Nexa", 40, 20, 10, 3, 8, true) ];
party[0].sprite = spr_Nexa;
party[0].skills = [ global.skills.shock, global.skills.fireball, global.skills.ice, global.skills.cure ];
if (variable_global_exists("skill_autoconfianca") && global.skill_autoconfianca) array_push(party[0].skills, global.skills.autoconfianca);
cyber_apply(party[0]);   // bônus dos mods equipados e das missões

// JUNTADO: o inimigo depende do andar
if (global.andar == 1) {
    // ----- Andar 1: boss Dado (Banco de Dados) -----
    var _dado = make_unit("Dado BD", 50, 0, 9, 2, 4, false);
    _dado.is_dice = true;
    _dado.sprite = spr_BancoDB;
    _dado.rewards = ["gorilla", "mantis"];
    enemies = [ _dado ];
}
else if (global.andar == 2) {
    // ----- Andar 2: boss Python -----
    var _python = make_unit("Python", 80, 0, 9, 2, 7, false);
    _python.sprite = spr_python;
    _python.rewards = ["subdermal", "kerenzikov", "tendons", "ankles"];
    boss_init(_python);
    enemies = [ _python ];
}
else if (global.andar == 3) {
    // ----- Andar 3: o Chefe (urso) -----
    var _urso = make_urso();
    _urso.sprite = spr_urso;
    _urso.sprite_attack = spr_urso_attack;
    urso = _urso;
    enemies = [ _urso ];
}
else {
    // ----- Qualquer outro valor: inimigos normais -----
    var _slime = make_unit("Slime", 20, 10, 6, 1, 5, false);
    _slime.weak_to = "fire";
    enemies = [ _slime, make_unit("Goblin", 25, 15, 8, 2, 6, false) ];
}

// Música da luta: cada chefe tem a sua; as outras lutas usam o tema ambiente
if (global.andar == 1)      tocar_musica(snd_musica_boss_banco);
else if (global.andar == 2) tocar_musica(snd_musica_boss_python);
else                        tocar_musica(snd_musica_ambiente);

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
    som(snd_ataque);
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

// --- Ferramentas equipadas (scr_cyber, slot "tool") ---
energy = cyber_total("start_energy");                   // Overclock USB
if (variable_global_exists("bonus")) energy += global.bonus.energia;   // missão "Não é Brincadeira"
energy = min(energy_max, energy);
firewall_cargas = cyber_total("first_block");           // Firewall Portátil
backup_cargas = cyber_total("revive");                  // Pendrive de Backup

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

    // JUNTADO: o Draw lê is_dice de toda unidade; garante o campo mesmo que o make_unit não crie
    if (!variable_struct_exists(turn_order[i], "is_dice")) turn_order[i].is_dice = false;
}

get_unit_pos = function(_u) {
    if (variable_struct_exists(_u, "pos")) return _u.pos;   // Urso e funcionários
    for (var i = 0; i < array_length(party); i++) {
        if (party[i] == _u) return { x: 80, y: 100 + i * 60 };
    }
    for (var i = 0; i < array_length(enemies); i++) {
        if (enemies[i] == _u) {
            if (_u.is_dice) return { x: 370, y: 125 };
            if (variable_struct_exists(_u, "typed") && _u.sprite != -1) return { x: 370, y: 108 };   // Python (mesmo ponto do Draw)
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
// ===== BOSS 3: O CHEFE (URSO) =====
molde_on = (global.andar == 3);
molde = 0;
molde_max = 100;
last_action_id = "";       // última ação do jogador (para detectar repetição)
proposta_done = false;
proposal_index = 0;        // 0 = Aceitar, 1 = Recusar
fase_final = false;
urso_turns = 0;
scene_timer = 0;
worker_names = ["Rafa", "Bia", "Caio", "Duda", "Leo", "Nina"];
worker_next = 0;
freed_count = 0;
freed_names = [];

workers_alive = function() {
    var _n = 0;
    for (var i = 0; i < array_length(enemies); i++) {
        if (is_worker(enemies[i]) && enemies[i].hp > 0) _n++;
    }
    return _n;
}

// Cria um funcionário moldado num espaço livre
spawn_worker = function() {
    var _slots = [ { x: 290, y: 70 }, { x: 290, y: 165 }, { x: 440, y: 215 } ];
    for (var s = 0; s < array_length(_slots); s++) {
        var _used = false;
        for (var i = 0; i < array_length(enemies); i++) {
            if (is_worker(enemies[i]) && enemies[i].hp > 0 && enemies[i].slot == s) _used = true;
        }
        if (!_used) {
            var _name = worker_names[worker_next mod array_length(worker_names)];
            worker_next++;
            var _w = make_worker(_name, s, _slots[s]);
            // _w.sprite = spr_Funcionario;   // quando tiver o sprite
            if (!variable_struct_exists(_w, "is_dice")) _w.is_dice = false;
            _w.hp_shown = _w.hp;
            _w.hp_prev  = _w.hp;
            _w.hurt = 0;
            array_push(enemies, _w);
            array_push(turn_order, _w);   // entra no fim da ordem: age depois do Urso
            add_popup(_slots[s].x, _slots[s].y - 30, "MOLDADO!", c_gray);
            return true;
        }
    }
    return false;
}

// Tira o funcionário da luta sem número de dano
remove_worker = function(_w) {
    _w.hp = 0;
    _w.hp_prev = 0;
    _w.hp_shown = 0;
}

// Timing perfeito: liberta e ajuda (alterna cura e energia)
free_worker = function(_w) {
    array_push(freed_names, _w.name);
    var _msg;
    if (freed_count mod 2 == 0) {
        current.hp = min(current.hp_max, current.hp + 15);
        _msg = "+15 HP";
    } else {
        energy = min(energy_max, energy + 30);
        _msg = "+30 energia";
    }
    freed_count++;
    add_popup(_w.pos.x, _w.pos.y - 30, "LIBERTADO!", c_lime);
    log_text = _w.name + " foi libertado! (" + _msg + ")";
    remove_worker(_w);
}
reward_given = false;

// ===== ANIMAÇÕES (scr_batalha_fx) =====
acao = { tipo: "", t: 0, dur: 0, alvo: undefined, el: "none", imp: undefined, dx: 0 };
fx = [];
especial_escuro = 0;   // tela escurece no golpe especial
especial_clarao = 0;   // clarão quando o especial acerta
menu_anim = 0;         // posição animada da seleção do menu
skill_anim = 0;        // posição animada da seleção de habilidade
alvo_anim = 0;         // posição animada da seta de alvo
for (var i = 0; i < array_length(turn_order); i++) turn_order[i].hurt = 0;

// ===== TUTORIAL DE BATALHA =====
// Na 1ª vez que cada mecânica aparece, a luta pausa e mostra uma dica.
dica = "";
dica_t = 0;
dica_texto = function(_id) {
	switch (_id) {
		case "menu":     return ["SUA VEZ", "Use Cima/Baixo para escolher e Enter para confirmar.", "Atacar usa uma barra de ritmo. Defender reduz o dano.", "Habilidade gasta MP. Item cura a Nexa."];
		case "ataque":   return ["ATAQUE COM RITMO", "Aperte ESPAÇO quando o marcador passar pelo CENTRO da barra.", "No centro: PERFEITO (mais dano e combo).", "Errar zera o combo."];
		case "defesa":   return ["DEFESA ATIVA", "O inimigo vai atacar! Aperte ESPAÇO no instante em que o golpe acertar.", "Na hora exata: bloqueia tudo.", "Quase na hora: leva só metade do dano."];
		case "especial": return ["ESPECIAL PRONTO", "A energia está cheia!", "Escolha Especial para atingir todos os inimigos.", "Acertos perfeitos enchem a energia mais rápido."];
		case "dado":     return ["O DADO DO BANCO", "O Banco de Dados rola um dado: cada face é um ataque diferente.", "NULL o deixa exposto (seu próximo golpe vale 2x).", "DROP TABLE é devastador: defenda bem!"];
		case "python":   return ["TIPOS DO PYTHON", "O Python troca de tipo a cada 2 turnos.", "Use a habilidade do elemento fraco: INT = raio, STR = fogo, FLOAT = gelo.", "Cada golpe que ele acerta aumenta a cauda e envenena."];
		case "molde":    return ["A BARRA DO MOLDE", "Errar o ritmo e repetir a mesma ação enchem o Molde.", "Se encher, a Nexa é moldada!", "Varie as ações e acerte o tempo para esvaziar a barra."];
	}
	return ["", ""];
};
// Mostra a dica uma vez só (devolve true se mostrou)
mostrar_dica = function(_id) {
	if (flag("tut_b_" + _id)) return false;
	marcar("tut_b_" + _id);
	dica = _id;
	dica_t = 0;
	return true;
};

// ===== CENÁRIO DA LUTA =====
// Fundo por chefe: sala do Banco (spr_Luta01), do Python e do Chefe, escurecidos
fundo_spr = spr_Luta01;
if (global.andar == 2) fundo_spr = spr_sala_python;
if (global.andar == 3) fundo_spr = spr_sala_urso;

// Partículas do cenário: dados caindo (BD), código subindo (Python), brasas (Chefe)
fundo_part = [];
repeat (34) array_push(fundo_part, { x: random(480), y: random(270), v: random_range(0.3, 1.2), k: irandom(1) });

// Textos da apresentação do chefe
intro_info = { nome: "INIMIGOS", titulo: "Treino", cor: c_white, spr: -1, esc: 1 };
switch (global.andar) {
	case 1: intro_info = { nome: "BANCO DE DADOS", titulo: "Quem apaga a história das mulheres", cor: c_aqua, spr: spr_BancoDB, esc: 0.42 }; break;
	case 2: intro_info = { nome: "PYTHON", titulo: "O veneno das 'brincadeiras'", cor: c_lime, spr: spr_python, esc: 1.25 }; break;
	case 3: intro_info = { nome: "O CHEFE", titulo: "O dono do molde", cor: c_red, spr: spr_urso, esc: 0.8 }; break;
}

desenhar_fundo = function() {
	var _sc = 480 / sprite_get_width(fundo_spr);
	var _h = sprite_get_height(fundo_spr) * _sc;
	var _oy = (270 - _h) / 2;
	gpu_set_texfilter(true);
	draw_sprite_ext(fundo_spr, 0, sprite_get_xoffset(fundo_spr) * _sc, _oy + sprite_get_yoffset(fundo_spr) * _sc,
	                _sc, _sc, 0, c_white, 1);
	gpu_set_texfilter(false);
	// escurece para os personagens e textos aparecerem
	draw_set_alpha(0.45);
	draw_set_color(c_black);
	draw_rectangle(0, 0, 480, 270, false);
	// faixa escura embaixo para o menu (cobre também a marca d'água da arte)
	draw_set_alpha(0.75);
	draw_rectangle(0, 182, 480, 270, false);
	// Chefe: a sala fica mais vermelha conforme o Molde sobe
	if (molde_on) {
		draw_set_alpha(0.25 * (molde / molde_max) + 0.05 * sin(current_time / 300));
		draw_set_color(c_red);
		draw_rectangle(0, 0, 480, 270, false);
	}
	// partículas
	for (var i = 0; i < array_length(fundo_part); i++) {
		var _p = fundo_part[i];
		draw_set_alpha(0.35);
		switch (global.andar) {
			case 1:  draw_set_color(c_aqua);   draw_text_transformed(_p.x, _p.y, string(_p.k), 0.55, 0.55, 0); break;
			case 2:  draw_set_color(c_lime);   draw_rectangle(_p.x, _p.y, _p.x + 2, _p.y + 1, false); break;
			default: draw_set_color(c_orange); draw_circle(_p.x, _p.y, 1, false); break;
		}
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
};