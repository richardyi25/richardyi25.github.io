var g, inf = '∞';

var nodes = [
	new Node(0, 150, 150, inf, 'A', 70, 'yellow'),
	new Node(1, 200, 350, inf, 'B', 70, 'yellow'),
	new Node(2, 450, 300, inf, 'C', 70, 'yellow'),
	new Node(3, 475, 500, inf, 'D', 70, 'yellow'),
	new Node(4, 650, 100, inf, 'E', 70, 'yellow'),
	new Node(5, 750, 450, inf, 'F', 70, 'yellow'),
	new Node(6, 900, 300, inf, 'G', 70, 'yellow'),
	new Node(7, 620, 300, inf, 'H', 70, 'yellow'),
	new Node(8, 180, 520, inf, 'I', 70, 'yellow'),
	new Node(9, 870, 100, inf, 'J', 70, 'yellow')
];

var edges = [
	new Edge(nodes[0], nodes[1], 0, 01, 10, 20, 'blue'),
	new Edge(nodes[0], nodes[2], 0, 02, 10, 20, 'blue'),
	new Edge(nodes[0], nodes[4], 0, 07, 10, 20, 'blue'),
	new Edge(nodes[1], nodes[2], 0, 05, 10, 20, 'blue'),
	new Edge(nodes[1], nodes[3], 0, 04, 10, 20, 'blue'),
	new Edge(nodes[2], nodes[3], 0, 02, 10, 20, 'blue'),
	new Edge(nodes[4], nodes[2], 0, 03, 10, 20, 'blue'),
	new Edge(nodes[2], nodes[7], 0, 06, 10, 20, 'blue'),
	new Edge(nodes[3], nodes[5], 0, 02, 10, 20, 'blue'),
	new Edge(nodes[3], nodes[6], 0, 04, 10, 20, 'blue'),
	new Edge(nodes[4], nodes[6], 0, 10, 10, 20, 'blue'),
	new Edge(nodes[8], nodes[1], 0, 03, 10, 20, 'blue'),
	new Edge(nodes[4], nodes[9], 0, 05, 10, 20, 'blue'),
	new Edge(nodes[6], nodes[9], 0, 03, 10, 20, 'blue')
];

g = new Graph(nodes, edges);

var adj = [];
for(var i = 0; i < nodes.length; i++)
	adj[i] = {};
for(var i = 0; i < edges.length; i++){
	var edge = edges[i];
	adj[edge.start.id][edge.end.id] = {
		id: i,
		wt: edge.data
	};
	adj[edge.end.id][edge.start.id] = {
		id: i,
		wt: edge.data
	};
}
var dist = [];
var vist = []
for(var i = 0; i < nodes.length; i++){
	dist[i] = 999999999999;
	vist[i] = false;
}

function dijks(start){
	dist[start] = 0;
	g.push(nodes[start], 'data', 0);

	//Slow Dijks
	for(var i = 0; i < nodes.length; i++){
		var cur = -1;
		for(var j = 0; j < nodes.length; j++)
			if(!vist[j] && (cur == -1 || dist[j] < dist[cur]))
				cur = j;

		vist[cur] = true;
		g.push(nodes[cur], 'color', 'orange');

		for(var to in adj[cur]){
			var edge = adj[cur][to].id, wt = adj[cur][to].wt;
			g.push(g.edges[edge], 'color', 'orange');

			if(!vist[to] && dist[cur] + wt < dist[to]){
				dist[to] = dist[cur] + wt;
				g.push(edges[edge], 'color', 'green');
				g.push(nodes[to], 'data', dist[to]);
			}
			else
				g.push(edges[edge], 'color', 'red');

			g.push(edges[edge], 'color', 'blue');
		}

		g.push(nodes[cur], 'color', 'green');
	}
}

$(document).ready(function(){
	g.render();
	dijks(4);
	init(g, 500);
});
