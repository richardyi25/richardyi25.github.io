var inf = '∞';
var nodes = [
	new Node(00, 200, 150, inf, 'A', 70, 'yellow'),
	new Node(01, 250, 350, inf, 'B', 70, 'yellow'),
	new Node(02, 500, 300, inf, 'C', 70, 'yellow'),
	new Node(03, 525, 500, inf, 'D', 70, 'yellow'),
	new Node(04, 700, 100, inf, 'E', 70, 'yellow'),
	new Node(05, 800, 450, inf, 'F', 70, 'yellow'),
	new Node(06, 950, 300, inf, 'G', 70, 'yellow'),
	new Node(07, 670, 300, inf, 'H', 70, 'yellow'),
	new Node(08, 230, 520, inf, 'I', 70, 'yellow'),
	new Node(09, 920, 100, inf, 'J', 70, 'yellow'),
	new Node(10, 920, 500, inf, 'K', 70, 'yellow')
];

var edges = [
	new Edge(00, nodes[0], nodes[1], 0, 05, 10, 20, 'gray'),
	new Edge(01, nodes[0], nodes[2], 0, 02, 10, 20, 'gray'),
	new Edge(02, nodes[0], nodes[4], 0, 04, 10, 20, 'gray'),
	new Edge(03, nodes[1], nodes[2], 0, 06, 10, 20, 'gray'),
	new Edge(04, nodes[1], nodes[3], 0, 01, 10, 20, 'gray'),
	new Edge(05, nodes[2], nodes[3], 0, 09, 10, 20, 'gray'),
	new Edge(06, nodes[4], nodes[2], 0, 10, 10, 20, 'gray'),
	new Edge(07, nodes[2], nodes[7], 0, 03, 10, 20, 'gray'),
	new Edge(08, nodes[3], nodes[5], 0, 04, 10, 20, 'gray'),
	new Edge(09, nodes[3], nodes[6], 0, 07, 10, 20, 'gray'),
	new Edge(10, nodes[4], nodes[6], 0, 08, 10, 20, 'gray'),
	new Edge(11, nodes[8], nodes[1], 0, 02, 10, 20, 'gray'),
	new Edge(12, nodes[4], nodes[9], 0, 03, 10, 20, 'gray'),
	new Edge(13, nodes[6], nodes[9], 0, 04, 10, 20, 'gray')
];

var g = new Graph(nodes, edges);

// Adjacency list setup
var adj = new Array(nodes.length);
for(var i = 0; i < nodes.length; i++)
	adj[i] = {};
for(var i = 0; i < edges.length; i++){
	var edge = edges[i];
	adj[edge.start.id][edge.end.id] = { id: i, wt: edge.data };
	adj[edge.end.id][edge.start.id] = { id: i, wt: edge.data };
}

var vist = new Array(nodes.length).fill(false);
var dist = new Array(nodes.length).fill(1000000000);

function dijks(start){
	dist[start] = 0;
	push(nodes[start], 'data', 0);
	delay(500);

	for(var _ = 0; _ < nodes.length; _++){
		var u = -1;
		for(var i = 0; i <= nodes.length; i++)
			if(!vist[i] && (u == -1 || dist[i] < dist[u])) u = i;

		console.log(u);
		push(nodes[u], 'color', 'red');
		delay(500);
		vist[u] = true;

		for(var v in adj[u]){
			var id = adj[u][v].id, w = adj[u][v].wt;
			push(edges[id], 'color', 'orange');
			delay(500);

			if(dist[u] + w < dist[v]){
				push(edges[id], 'color', 'green');
				dist[v] = dist[u] + w;
				push(nodes[v], 'data', dist[v]);
			}
			else
				push(edges[id], 'color', 'red');

			delay(500);

			push(edges[id], 'color', 'gray');

			delay(500);
		}

		push(nodes[u], 'color', 'green');

		delay(1000);
	}
}

// Main/onload
$(document).ready(function(){
	speed = 1;
	auto = true;
	g.render();
	dijks(0);
	init();
});
