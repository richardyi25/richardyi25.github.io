//var state = makeAll(["K", "x", "y"]);
//var state = makeAll(["S", ["K", ["S", "I"]], "K", "x", "y"]);
//var state = makeAll(["S", ["B", "B", "S"], ["K", "K"], "x", "y", "z"]);
//var state = makeAll(["S", "S", ["S", "K"], "x", "y"]);
var state = makeAll(["S", "L", "L", "f"]);
// ["C", "B", ["W", "I"], "x", "y"]
var offset, height = 15;

const combWidth = 150, brWidth = 50, adjWidth = 50, curWidth = 50, barWidth = 50;
const backHeight = 25, combHeight = 150, barHeight = 15;

function back(depth, width){
	var c = $("canvas");
	for(var i = 0; i <= depth; i++){
		c.drawRect({
			x: offset,
			y: i * backHeight,
			width: width,
			height: 2 * (height - i) * backHeight + combHeight,
			fillStyle: "hsl(" + (-45 * i + 180) + ", 80%, 80%)",
			fromCenter: false
		});
	}
}

function draw(state, depth, curried, inline){
	var c = $("canvas");
	if(!inline){
		back(depth, brWidth);
		offset += brWidth;
	}
	for(var i = 0; i < state.length; i++){
		if(Array.isArray(state[i]))
			draw(state[i], depth + 1, curried, false);
		else{
			var comb = state[i], color = comb.id in lookup ? lookup[comb.id].color : "gray";
			back(depth, combWidth);
			c.drawEllipse({
				fillStyle: color,
				x: offset + combWidth / 2,
				y: height * backHeight + combHeight / 2,
				width: combWidth * 0.6,
				height: combHeight * 0.6,
				fromCenter: true
			});
			c.drawText({
				fillStyle: "black",
				x: offset + combWidth / 2,
				y: height * backHeight + combHeight / 2,
				fontSize: Math.floor(Math.min(combWidth, combHeight) * 0.4),
				text: comb.id,
				fromCenter: true
			});
			if(!curried && comb.num > -1){
				c.drawText({
					fillStyle: "black",
					x: offset + combWidth * 0.9,
					y: height * backHeight + combHeight * 0.2,
					fontSize: Math.floor(Math.min(combWidth, combHeight) / 4),
					text: comb.num,
					fromCenter: true
				});
			}
			offset += combWidth;
			if(comb.args.length > 0){
				back(depth, barWidth);
				c.drawRect({
					fillStyle: "black",
					x: offset,
					y: height * backHeight + combHeight / 2 - barHeight / 2,
					width: barWidth,
					height: barHeight,
					fromCenter: false
				});
				offset += barWidth;
				for(var j = 0; j < comb.args.length; j++){
					if(Array.isArray(comb.args[j]))
						draw([comb.args[j]], depth, true, true);
					else{
						back(depth, combWidth);
						c.drawEllipse({
							fillStyle: comb.args[j].id in lookup ? lookup[comb.args[j].id].color : "gray",
							x: offset + combWidth / 2,
							y: height * backHeight + combHeight / 2,
							width: combWidth * 0.6,
							height: combHeight * 0.6,
							fromCenter: true
						});
						c.drawText({
							fillStyle: "black",
							x: offset + combWidth / 2,
							y: height * backHeight + combHeight / 2,
							fontSize: Math.floor(Math.min(combWidth, combHeight) * 0.4),
							text: comb.args[j].id,
							fromCenter: true
						});
						offset += combWidth;
					}
					if(j < comb.args.length - 1){
						back(depth, barWidth);
						c.drawRect({
							fillStyle: "black",
							x: offset,
							y: height * backHeight + combHeight / 2 - barHeight / 2,
							width: barWidth,
							height: barHeight,
							fromCenter: false
						});
						offset += barWidth;
					}
				}
			}
		}

		if(i != state.length - 1){
			back(depth, adjWidth);
			offset += adjWidth;
		}
	}
	if(!inline){
		back(depth, brWidth);
		offset += brWidth;
	}
}

function render(){
	var canvas = document.getElementById("canvas");
	c = $("canvas");
	
	canvas.width = window.innerWidth * 3;
	canvas.height = window.innerHeight * 3;
	canvas.style.height = window.innerHeight + "px";
	canvas.style.width = window.innerWidth + "px";
	
	c.drawRect({
		fillStyle: "hsl(180, 80%, 80%)",
		x: 0, y: 0,
		width: canvas.width, height: canvas.height,
		fromCenter: false
	});

	offset = 0;
	draw(state, 0, false, false);

	c.drawText({
		fillStyle: "black",
		x: 100, y: 900,
		fontSize: 50,
		fontFamily: "Verdana, Sans",
		text: "Press Enter to step",
		fromCenter: false
	});
}

function go(e){
	if(e.which != 13) return;
	var tmp = step(state), stepped = tmp[0], changed = tmp[1];
	if(!changed) return;
	state = stepped;
	render();
}

$(document).ready(function(){
	render();
	$(document).keydown(go);
});
