var print = console.log;
var c;

// Node Class
function Node(id, x, y, data, cdata, size, color){
	this.id = id;
	this.x = x;
	this.y = y;
	this.data = data;
	this.cdata = cdata;
	this.size = size;
	this.color = color;
}

// Edge Class
function Edge(id, start, end, dir, data, thick, fsize, color){
	this.id = id;
	this.start = start;
	this.end = end;
	this.dir = dir;
	this.data = data;
	this.thick = thick;
	this.fsize = fsize;
	this.color = color;

	this.update = function(){
		var start, end;
		// Information based on edge direction
		// TODO: Properly change architecture
		if(this.dir == -1){
			var start = this.end;
			var end = this.start;
		}
		else{
			var start = this.start;
			var end = this.end
		}

		// Angle from start to end is atan2
		this.alpha = Math.atan2(end.y - start.y, end.x - start.x) + (2 * Math.PI);
		// Angle but the other way
		this.beta = this.alpha + Math.PI;
		// Ensure angles between 0 and 2pi
		while(this.alpha < 0) this.alpha += Math.PI * 2;
		while(this.beta < 0) this.beta += Math.PI * 2;
		this.alpha %= Math.PI * 2;
		this.beta %= Math.PI * 2;

		// Calculate the "real" endpoints of the this
		// This is offset by the size of the nodes and the angle of the this
		// Ratio to account for outer circle thickness
		// 1.6 is to account for arrowhead
		var ratio = 1/2;
		this.rx1 = start.x + start.size * ratio * Math.cos(this.alpha);
		this.ry1 = start.y + start.size * ratio * Math.sin(this.alpha);
		this.rx2 = end.x + end.size * ratio * Math.cos(this.beta);
		this.ry2 = end.y + end.size * ratio * Math.sin(this.beta);
		this.rx3 = end.x + (end.size * 8/15 + this.thick * 1.6) * Math.cos(this.beta);
		this.ry3 = end.y + (end.size * 8/15 + this.thick * 1.6) * Math.sin(this.beta);
	}

	this.update();
}

// Graph Class
function Graph(nodes, edges){
	var edge, rev;
	this.nodes = nodes;
	this.edges = edges; 

	// Draw the graph to the canvas
	this.render = function(){
		var node, edge, data, cdata;
		var perp;

		//Clear screen
		c.clearCanvas();

		// Draw edges
		for(var i = 0; i < this.edges.length; i++){
			edge = this.edges[i];

			if(edge.color == 'invis') continue;

			// Update some angle and math values
			edge.update();
			// Convert to string
			data = "" + edge.data;

			// Draw edge itself
			c.drawLine({
				x1: edge.rx1,
				y1: edge.ry1,
				// Draw arrowed edges a bit shorter
				x2: edge.dir ? edge.rx3 : edge.rx2,
				y2: edge.dir ? edge.ry3 : edge.ry2,
				strokeStyle: edge.color,
				strokeWidth: edge.thick,
				endArrow: edge.dir,
				arrowRadius: edge.thick * 3,
			});

			// Some trig to determine where the weight is drawn

			// "Randomly" add or remove pi/2 to make it perpendicular (clockwise)
			// If the edge ID is odd, add pi/2, if it's even, remove pi/2
			perp = edge.alpha + (edge.id & 1 ? 1 : -1) * (Math.PI / 2);

			// Weight is drawn perpendicular to midpoint
			// The distance scales with edge thickness and font size
			// Use cos and sin to find x and y distances
			wx = (edge.rx1 + edge.rx2) / 2 + (edge.thick + edge.fsize + 10) / 2 * Math.cos(perp);
			wy = (edge.ry1 + edge.ry2) / 2 + (edge.thick + edge.fsize + 10) / 2 * Math.sin(perp);

			// Draw edge weight
			c.drawText({
				text: data,
				x: wx,
				y: wy,
				fontSize: edge.fsize,
				fromCenter: true,
				fontFamily: 'Arial',
				fillStyle: edge.color
			});
		}

		// Draw nodes
		for(var i = 0; i < this.nodes.length; i++){
			node = this.nodes[i];
			// Convert to strings
			data = "" + node.data;
			cdata = "" + node.cdata;

			// Draw node body
			c.drawEllipse({
				x: node.x,
				y: node.y,
				width: node.size,
				height: node.size,
				strokeStyle: node.color,
				strokeWidth: node.size/15,
				fillStyle: 'white'
			});

			// Draw in-node text
			c.drawText({
				text: data,
				x: node.x,
				y: node.y,
				fromCenter: true,
				fillStyle: 'black',
				// Scales based on size of node and length of text
				fontSize: node.size * 0.85 / Math.pow(data.length, 0.8),
				fontFamily: 'Arial'
			});

			//Draw out-node background
			c.drawEllipse({
				x: node.x - node.size / 2,
				y: node.y - node.size / 2,
				fillStyle: '#EEE',
				fromCenter: true,
				// A bit larger than the out-node text
				width: node.size * 0.45 / Math.pow(cdata.length, 0.3) + 2,
				height: node.size * 0.45 / Math.pow(cdata.length, 0.3) + 2,
			});

			// Draw out-node text
			c.drawText({
				text: cdata,
				x: node.x - node.size / 2,
				y: node.y - node.size / 2,
				fromCenter: true,
				fillStyle: 'black',
				// Scales based on size of node and length of text
				fontSize: node.size * 0.35 / Math.pow(cdata.length, 0.3),
				fontFamily: 'Arial'
			});
		}

	}
}

// Variable binding
$(document).ready(function(){
	c = $('canvas');
});
