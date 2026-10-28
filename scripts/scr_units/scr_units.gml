function make_unit(_name, _hp, _mp, _atk, _def, _spd, _is_player){
	return {
		name: _name,
		hp: _hp,     hp_max: _hp,
		mp: _mp,    mp_max: _mp,
		atk: _atk,  def: _def,
		spd: _spd,  //velocidade: define a ordem dos turnos
		is_player: _is_player,    //se True o personagem é controlado pelo jogador, se False é um inimigo
		defending: false,    //Se True o personagem ira defender o ataque.
		weak_to: "none",    //elemento que causa dano extra
		status: [],         //efeitos como veneno
		sprite: -1,
		is_dice: false 
	};
}



