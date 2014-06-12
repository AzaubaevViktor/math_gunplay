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
	"combo_factor"		: 		1.1,
}

function Player(name, elem) {
	// Elements
	this.elem = elem;
	this.elName = elem.find(".name");

	this.elBull = elem.find(".bullets");
	this.elSolv = elem.find(".btn-solve");
	this.elNSlv = elem.find(".btn-not-solve");
	this.elPict = elem.find(".image-avatar");
	this.elHlth = elem.find(".health");
	this.elProb = elem.find(".probablity");

	this.elTrth = elem.find(".treatment>a");
	this.elAttk = elem.find(".btn-attack");
	this.elComb = elem.find(".combo");

	this.elBtAttack = elem.find(".attack");
	this.elBtAttacked = elem.find(".attacked"); 

	this.elButtonAttacked = elem.find(".btn-kill");
	this.elDamg = elem.find(".damage");

	// Game parameters
	this.health = 1;
	this.accurancy = 0;
	this.combo = 0;
	this.tasks = [];
	this.bullets = 0;
	this.name = name;

	this.players = [];

	// Flags
	this.isAttackedMode = 0;
	this.isDead = 0;

	this.elSolv.removeClass("disabled");
	var parent = this
	this.elSolv.click(function () {
		parent.solve(1);
	});

	this.elNSlv.removeClass("disabled");
	this.elNSlv.click(function () {
		parent.solve(0);
	});

	this.elTrth.click(function () {
		parent.treatment();
	});

	this.elAttk.click(function () {
		parent.attackMode();
	});

	this.elButtonAttacked.click(function () {
		parent.attacked();
	});

	this.update();
};

Player.prototype.addPlayers = function (players) {
	for (var i = 0; i < players.length; i++) {
		pl = players[i];
		if (this != pl) {
			this.players.push(pl);
		}
	}
};

Player.prototype.updateUI = function() {
	if (!this.isDead) {
		this.elName.text(this.name);
		this.elBull.html("&nbsp;" + str_repeat("|", this.bullets));
		this.elProb.text((calcHit(this.accurancy)*100).toFixed(1) + "%");
		this.elHlth.text((this.health*100).toFixed(1) + "%");
		this.elTrth.html(str_repeat("<span class='glyphicon glyphicon-plus-sign'></span> ",
			Math.floor(this.bullets / 3)));

		if (this.bullets) {
			this.elAttk.removeClass("disabled");
		} else {
			this.elAttk.addClass("disabled");
		}
		this.elComb.text("x" + (calcCombo(this.combo)).toFixed(1));

		if (2 == this.isAttackedMode) {
			this.elBtAttack.addClass("none");
			this.elBtAttacked.removeClass("none");
		} else {
			this.elBtAttack.removeClass("none");
			this.elBtAttacked.addClass("none");
		}
	} else {
		this.elBtAttack.removeClass("none");
		this.elBtAttacked.addClass("none");
		this.elSolv.addClass("disabled");
		this.elNSlv.addClass("disabled");
		this.elBtAttack.addClass("disabled");
		this.elBtAttacked.addClass("disabled");
		this.elAttk.addClass("disabled");
		this.elProb.text("--");
		this.elHlth.text("0%");
	};
};

Player.prototype.updateState = function() {
	this.isDead = (0 >= this.health);
	if (this.isDead) {
		this.health = 0;
	}
};

Player.prototype.update = function() {
	this.updateState();
	this.updateUI();
};

Player.prototype.solve = function(isSolve) {
	if (isSolve) {
		console.log("Task decided!");
		this.tasks.push(1);
		this.combo += 1;
		this.accurancy += 1;
		this.bullets += 1;
	} else {
		console.log("Task doesn't decided!");
		this.tasks.push(0);
		this.combo = 0;
		this.accurancy -= 1;
	}
	this.update();
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
	 return (Math.atan(acc/7)/Math.PI*2*(1-0.2) + 0.2);
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
		this.bullets -= 1;

		if (isHit(this.accurancy)) {
			console.log("HIT!");
			Enemy.health -= dmg;
		}
	} else {
		console.warn("Has no bullets to shot!");
	}
};

Player.prototype.treatment = function() {
	console.log("Treatment of %s",this.name)
	if (3 <= this.bullets) {
		this.health += 0.3;
		this.health = (this.health > 1) ? 1 : this.health;
		this.bullets -= 3;
	} else {
		console.warn("Not enought bullets for treatment");
	}
	this.update();
};

Player.prototype.buttons = function (enable) {
	if (enable) {
		this.elAttk.removeClass("disabled");
		this.elSolv.removeClass("disabled");
		this.elNSlv.removeClass("disabled");
	} else {
		this.elAttk.addClass("disabled");
		this.elSolv.addClass("disabled");
		this.elNSlv.addClass("disabled");
	}
};

Player.prototype.attackMode = function (type)  {
	if (0 == this.isAttackedMode) {
		// Standart state
		this.isAttackedMode = 1;
		for (var i=0;i<this.players.length;i++) {
			this.players[i].isAttackedMode = 2;
			this.players[i].update();
			this.players[i].elDamg.text((_damage(this, this.players[i])*100).toFixed(1));
			}
	} else if (1 == this.isAttackedMode) {
		// Click this.elAttk button
		this.isAttackedMode = 0;
		for (var i=0;i<this.players.length;i++) {
			this.players[i].isAttackedMode = 0;
			this.players[i].update();
		}
	};
};

Player.prototype.attacked = function () {
	for (var i=0;i<this.players.length;i++) {
		if (1 == this.players[i].isAttackedMode) {
			var pl = this.players[i];
		}
	}
	pl.shot(this);
	this.isAttackedMode = 0;
	this.update();
	for (var i=0;i<this.players.length;i++) {
		this.players[i].isAttackedMode = 0;
		this.players[i].update();
	}
};

Player.prototype.info = function () {
	console.groupCollapsed();
	console.info("Info about `%s`", this.name);
	console.log("Health:    %.3f", this.health);
	console.log("Accurancy: %.3f%", this.accurancy*100);
	console.log("Combo:     [%d] %.3f", this.combo, calcCombo(this.combo));
	console.log("Bullets:   %d", this.bullets);
	console.groupEnd();
};

$(document).ready(function () {
	$("#two").html($("#one").html());
	$("#three").html($("#one").html());
	$("#four").html($("#one").html());

pl1 = new Player("Player 1", $("#one"));
pl2 = new Player("Player 2", $("#two"));
pl3 = new Player("Player 3", $("#three"));
pl4 = new Player("Player 4", $("#four"));

players = [pl1, pl2, pl3, pl4];

for (var i=0; i< players.length; i++) {
	var pl = players[i];
	console.log(pl);
	pl.addPlayers(players);
}

});