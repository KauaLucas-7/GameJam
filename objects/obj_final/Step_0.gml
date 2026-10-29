if (em_transicao()) exit;
anim++;
t++;
var _ok = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter);

// ----- Transformações (robô -> humana) -----
var _todos = [nexa];
for (var k = 0; k < array_length(elenco); k++) array_push(_todos, elenco[k]);
for (var k = 0; k < array_length(_todos); k++) {
	var _p = _todos[k];
	if (!_p.ativo || _p.prog >= 1) continue;
	if (_p.atraso > 0) { _p.atraso--; continue; }
	if (_p.prog == 0) soltar_pecas(_p.x);
	_p.prog = min(1, _p.prog + 1 / 70);
}
var _soma = 0;
for (var k = 0; k < array_length(_todos); k++) _soma += _todos[k].prog;
luz = lerp(luz, _soma / array_length(_todos), 0.05);
brilho = max(0, brilho - 0.01);

// Placas de metal caindo
for (var k = array_length(pecas) - 1; k >= 0; k--) {
	var _pc = pecas[k];
	_pc.vy += 0.12; _pc.x += _pc.vx; _pc.y += _pc.vy; _pc.r += _pc.vr;
	if (_pc.y > 182) { _pc.y = 182; _pc.vy *= -0.3; _pc.vx *= 0.7; _pc.a -= 0.02; }
	if (_pc.a <= 0) array_delete(pecas, k, 1);
}

// ----- Legendas -----
if (fase == "cena") {
	var _f = falas[fala_i];
	letras = min(string_length(_f.t), letras + 1.1);
	if (_ok && t > 20) {
		if (letras < string_length(_f.t)) letras = string_length(_f.t);
		else {
			fala_i++;
			letras = 0;
			if (fala_i >= array_length(falas)) {
				fase = "creditos";
				t = 0;
				fala_i = array_length(falas) - 1;
			} else if (variable_struct_exists(falas[fala_i], "ev")) {
				disparar(falas[fala_i].ev);
			}
		}
	}
}
// ----- Créditos -----
else if (fase == "creditos") {
	fade_cred = min(1, fade_cred + 1 / 60);
	if (!cred_fim) {
		cred_y -= keyboard_check(vk_space) || keyboard_check(vk_enter) ? 2 : 0.45;
		if (cred_y + array_length(creditos) * 18 < 40) cred_fim = true;
	} else if (_ok) {
		game_restart();   // volta ao menu inicial com tudo zerado
	}
}
