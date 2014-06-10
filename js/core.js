function str_repeat ( input, multiplier ) {	// Repeat a string
	// 
	// +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)

	var buf = '';

	for (i=0; i < multiplier; i++){
		buf += input;
	}

	return buf;
}


consts = {
	"accurancy_plus" 	:			0.12,
	"accurancy_minus" : 		-0.12,
	"combo_factor"		: 		1.1,
}

function Player(consts, name, elem) {
	this.elem = elem;
	this.elName = elem.find(".name");

	this.elBull = elem.find(".bullets");
	this.elSolv = elem.find(".btn-solve");
	this.elPict = elem.find(".image-avatar");
	this.elHlth = elem.find(".health");

	this.elTrth = elem.find(".treatment>a");
	this.elAttk = elem.find(".btn-attack");
	this.elComb = elem.find(".combo");
	this.health = 1;
	this.accurancy = 0;
	this.combo = 0;
	this.tasks = [];
	this.bullets = 0;
	this.name = name;
};

Player.prototype.updateUI = function() {
	this.elBull.text(str_repeat("|", this.bullets));
	this.elHlth.text((this.health*100).toFixed(1) + "%");
	this.elTrth.html(str_repeat("<span class='glyphicon glyphicon-plus-sign'></span> ",
		Math.floor(this.bullets / 3)));
	if (this.bullets) {
		this.elAttk.removeClass("disabled");
	} else {
		this.elAttk.addClass("disabled");
	}
	this.elComb.text("x" + (calcCombo(this.combo)).toFixed(1));
}

Player.prototype.solve = function(isSolve) {
	if (isSolve) {
		console.log("Task decided!");
		this.tasks.push(1);
		this.combo += 1;
		this.accurancy += consts["accurancy_plus"];
		this.bullets += 1;
	} else {
		console.log("Task doesn't decided!");
		this.tasks.push(0);
		this.combo = 1;
		this.accurancy -= consts["accurancy_minus"];
	}
};


function calcDmg(health) {
	return 	(0.619048) * health * health
			- (0.519048) * health
			+ 0.2;
};
function calcCombo(combo) {
	return Math.pow(consts["combo_factor"], combo);
};

function calcProtect(healthEnemy) {
	return healthEnemy + 1;
};
function calcHit(acc) {
	 return (acc * 0.5 + 0.3);
};
function isHit(acc) {
	return (Math.random() < calcHit(acc));
};
function _damage(pl, en) {
	return calcDmg(pl.health) * calcCombo(pl.combo) / calcProtect(en.health);
};


Player.prototype.shot = function(Enemy) {
	if (this.bullets) {
		dmg = _damage(this, Enemy);
		console.log("Shot %s -> %s, prob:%d% Assume hit:%d%",
			this.name,
			Enemy.name,
			calcHit(this.accurancy)*100,
			dmg*100);

		if (isHit(this.accurancy)) {
			console.log("HIT!");
			Enemy.health -= dmg;
			console.info(Enemy.health*100);
			this.bullets -= 1;
		}
	} else {
		console.warn("Has no bullets to shot!");
	}
};

Player.prototype.treatment = function() {
	console.log("Treatment of %s",this.name)
	this.health += 0.3;
	this.health = (this.health > 1) ? 1 : this.health;
};

Player.prototype.info = function () {
	console.groupCollapsed();
	console.info(this.name);
	console.log("Health: %.3f", this.health);

	console.groupEnd();
};

pl1 = new Player({}, "lalka1", $("#one"));
pl2 = new Player({}, "azaza2", $("#two"));
pl1.solve(1);
pl1.shot(pl2);
pl1.solve(1);
pl1.solve(0);
pl1.solve(1);
pl1.solve(1);
pl1.health = 0.9;
pl1.treatment();
console.log(pl1.health);
pl1;
pl1;