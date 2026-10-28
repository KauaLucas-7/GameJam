function use_skill(_user, _skill, _target) {
	if (_user.mp < _skill.cost) return false; // sem MP: não faz nada
	_user.mp -= _skill.cost;
	if (_skill.heal) {
	_target.hp = min(_target.hp_max, _target.hp + _skill.power);
	} else {
		var _dmg = max(1, _skill.power - _target.def);
		if (_target.weak_to == _skill.element) _dmg = round(_dmg * 1.5);
		_target.hp = max(0, _target.hp - _dmg);
	}
	return true;
}
function use_item(_user, _item) {
	if (_item.qty <= 0) return false; // acabou o estoque
	_item.qty--;
	_user.hp = min(_user.hp_max, _user.hp + _item.heal);
	return true;
}
