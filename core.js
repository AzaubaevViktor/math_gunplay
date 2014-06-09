function Player(consts, name) {
	this.health = 1;
	this.accurancy = 0;
	this.combo = 0;
	this.tasks = [];
	this.bullets = 0;
	this.name = name;
};


Player.prototype.solve = function(isSolve) {
	if (isSolve) {
		console.log("Task decided!");
		this.tasks.push(1);
		this.combo += 1;
		this.accurancy += 0.12;
		this.bullets += 1;
	} else {
		console.log("Task doesn't decided!");
		this.tasks.push(0);
		this.combo = 1;
		this.accurancy -= 0.12;
	}
};


function calcDmg(health) {
	return 	(0.619048) * health * health
			- (0.519048) * health
			+ 0.2;
};
function calcCombo(combo) {
	return Math.pow(1.1, combo);
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

pl1 = new Player({}, "lalka1");
pl2 = new Player({}, "azaza2");
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