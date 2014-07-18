function str_repeat ( input, multiplier ) {	// Repeat a string
	// +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	var buf = '';
	for (i=0; i < multiplier; i++){
		buf += input;
	}
	return buf;
}

/* class Model:
 *  addSnapshot
 *  backToSnapshot
 *  joinView
 *  addPlayer
 *  calcProblity
 *  calcDamage
 *  isAlive
 *  this.isAttackMode
 *  attack
 *  unsolve
 *
 * generated events:
 *  addSnapshot
 *  addPlayer
 *  hit
 *  miss
 *  updatePlayers
 */

function Model() {
	this.players = [];
	this.kPlayers = 0;
	this.snapshots = [];
	this.view = undefined;
	this.isAttackMode = -1;
}

Model.prototype.addSnapshot = function () {
	this.snapshots.push(this.players.slice(-1)[0]);
	this.view.addSnapshot();
};

Model.prototype.backToSnapshot = function () {
	this.players = this.snapshots.pop(); // Возможно нужно будет добавить slice
};

Model.prototype.joinView = function (view) {
	this.view = view;
};

Model.prototype.addPlayer = function (name) {
	player = {
		'name': name,
		'health': 1,
		'solved': 0,
		'unsolved': 0
	}
	this.players.push(player);
	this.kPlayers += 1;

	this.view.addPlayer();
}

Model.prototype.calcProbablity = function (plInd) {
	player = this.players[plInd];
	return Math.max((player['solved'] + 2) / (player['solved'] + player['unsolved'] + 4), 0.5)
}

Model.prototype.calcDamage = function (plInd) {
	if (plInd == -1) {
		return 0;
	}
	player = this.players[plInd];
	return player['health'] / 5;
};

Model.prototype.isAlive = function (plInd) {
	player = this.players[plInd];
	return player['health'] > 0;
};

Model.prototype.attackModeChange = function (plInd) {
	this.isAttackMode = (this.isAttackMode != -1) ? -1 : plInd;

	this.view.updatePlayers();
};

Model.prototype.attack = function (toInd) {
	fromInd = this.isAttackMode;
	this.isAttackMode = -1;
	pl1 = this.players[fromInd];
	pl2 = this.players[toInd];

	prob = this.isAlive(toInd) && this.calcProbablity(fromInd);
	if (Math.random() < prob) {
		this.view.hit(fromInd, toInd);
		pl2['health'] -= this.calcDamage(fromInd);
	} else {
		this.view.miss(fromInd, toInd);
	}

	pl1['solved'] += 1;

	this.addSnapshot();

	this.view.updatePlayers();
}

Model.prototype.unsolve = function (plInd) {
	player = this.players[plInd];
	player['unsolved'] += 1;

	this.addSnapshot();

	this.view.updatePlayers();
};


/* class View:
 *
 * generated events:
 *
 * listened events:
 *
 */
function View() {
	this.players = [];
	this.model = undefined;
	this.controller = undefined;
	this.elBody = $("body");
	this.elPlayers = $(".players");
	this.newPlayerTemplate = this.elPlayers.find("#template").html();
	this.animateDur = 500;
}

View.prototype.joinModel = function (model) {
	this.model = model;
};

View.prototype.joinController = function (controller) {
	this.controller = controller;
};

View.prototype.addSnapshot = function () {
	;
};

View.prototype.addPlayer = function () {
	var player = this.model.players.slice(-1)[0];
	var plId = this.model.kPlayers - 1;
	var playerHTML = "<div id=\"player" + plId + "\" class=\"block\" style=\"display:none\">" +
               		 this.newPlayerTemplate +
							     "</div>";
	this.elPlayers.append(playerHTML);

	obj = this.elPlayers.find("#player" + plId);

	var els = {};

	els['root'] = obj;

	els['state'] = {
		'name': obj.find(".username"),
		'health': obj.find(".health"),
		'probablity': obj.find(".probablity"),
		'tasks': obj.find(".tasks"),
	};

	els['bars'] = {
		'actBar': obj.find(".actionbar"),
		'attackBar': obj.find(".attackbar"),
	};

	els['buttons'] = {
		'solved': obj.find(".solved"),
		'unsolved': obj.find(".unsolved"),
		'attack': obj.find(".attack"),
	};

	els['damage'] = obj.find(".damage");

	this.players.push(els);

	els['state']['name'].text(player['name']);

	this.updatePlayers();
	els['root'].slideDown(this.animateDur);

	this.controller.bindNewPlayer(els, plId);
};

View.prototype.updatePlayers = function () {
	var players = this.model.players;

	var am = this.model.isAttackMode;
	var damage = this.model.calcDamage(am);
	var view = this;
	var model = this.model;
	var anim = this.animateDur;

	players.forEach(function(player, index) {
		var plHtml = view.players[index];
		var isAlive = model.isAlive(index);

		plHtml['state']['health'].text(
			((isAlive && player['health'])*100).toFixed(1) + "%");
		plHtml['state']['probablity'].text(
			((isAlive && view.model.calcProbablity(index))*100).toFixed(1));
		plHtml['state']['tasks'].text("Задач Р/Н: " + player['solved'] + "/" + player['unsolved']);

		if (!isAlive) {
			plHtml['buttons']['solved'].addClass("disabled");
			plHtml['buttons']['unsolved'].addClass("disabled");
		}

		if ((am != -1) && (am != index)) {
			plHtml['bars']['actBar'].slideUp(anim);
			plHtml['bars']['attackBar'].slideDown(anim);
			plHtml['damage'].text("Урон: " + (damage*100).toFixed(1) + "%");
		} else {
			plHtml['bars']['actBar'].slideDown(anim);
			plHtml['bars']['attackBar'].slideUp(anim);
		}
	});
};

View.prototype.hit = function (fromInd, toInd) {
	console.log(fromInd + "->" + toInd + " Попал!");
};

View.prototype.miss = function (fromInd, toInd) {
	console.log(fromInd + "->" + toInd + " не Попал!");
};


// Class Controller
function Controller() {
	this.model = undefined;
}

Controller.prototype.joinModel = function (model) {
	this.model = model;
};

Controller.prototype.bindNewPlayer = function (playerHtml, index) {
	playerHtml['buttons']['solved'].click(
		function() {
			model.attackModeChange(index)
			}
		);

	playerHtml['buttons']['unsolved'].click(
		function() {
			model.unsolve(index);
		}
	);

	playerHtml['buttons']['attack'].click(
		function() {
			model.attack(index);
		}
	)
};

Controller.prototype.bindAddNewUserInput = function (input) {
	input.keyup(function(e) {
  	if(e.keyCode == 13){
			name = input.val();
			input.val("");
			model.addPlayer(name);
    }
  });
};

$(document).ready(function () {
	console.log("I'm alive!");

	$("#version").text(__version__);
	view = new View();
	model = new Model();
	controller = new Controller();

	model.joinView(view);
	view.joinModel(model);
	view.joinController(controller);
	controller.joinModel(view);
	controller.bindAddNewUserInput($("#newusername"))

	// For test
});
