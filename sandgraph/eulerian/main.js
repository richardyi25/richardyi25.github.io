var nodes = [
	new Node(00, 200, 150, 'A', '', 70, 'gold'),
	new Node(01, 250, 350, 'B', '', 70, 'gold'),
	new Node(02, 500, 300, 'C', '', 70, 'gold'),
	new Node(03, 525, 500, 'D', '', 70, 'gold'),
	new Node(04, 700, 100, 'E', '', 70, 'gold'),
	new Node(05, 800, 450, 'F', '', 70, 'gold'),
	new Node(06, 950, 300, 'G', '', 70, 'gold'),
	new Node(07, 670, 300, 'H', '', 70, 'gold'),
	new Node(08, 230, 520, 'I', '', 70, 'gold'),
	new Node(09, 920, 100, 'J', '', 70, 'gold')
];

var edges = [
	new Edge(00, nodes[0], nodes[1], 1, '', 7, 20, 'gray'),
	new Edge(01, nodes[1], nodes[2], 1, '', 7, 20, 'gray'),
	new Edge(02, nodes[2], nodes[0], 1, '', 7, 20, 'gray'),
	new Edge(03, nodes[2], nodes[4], 1, '', 7, 20, 'gray'),
	new Edge(04, nodes[2], nodes[8], 1, '', 7, 20, 'gray'),
	new Edge(05, nodes[3], nodes[2], 1, '', 7, 20, 'gray'),
	new Edge(06, nodes[3], nodes[5], 1, '', 7, 20, 'gray'),
	new Edge(07, nodes[4], nodes[7], 1, '', 7, 20, 'gray'),
	new Edge(08, nodes[4], nodes[9], 1, '', 7, 20, 'gray'),
	new Edge(09, nodes[5], nodes[6], 1, '', 7, 20, 'gray'),
	new Edge(10, nodes[6], nodes[3], 1, '', 7, 20, 'gray'),
	new Edge(11, nodes[6], nodes[4], 1, '', 7, 20, 'gray'),
	new Edge(12, nodes[7], nodes[2], 1, '', 7, 20, 'gray'),
	new Edge(13, nodes[8], nodes[3], 1, '', 7, 20, 'gray'),
	new Edge(14, nodes[9], nodes[6], 1, '', 7, 20, 'gray'),
];

var g = new Graph(nodes, edges);

// Adjacency list setup
var adj = new Array(nodes.length);
for(var i = 0; i < nodes.length; i++)
	adj[i] = {};
for(var i = 0; i < edges.length; i++){
	var edge = edges[i];
	adj[edge.start.id][edge.end.id] = i;
}

var vist = new Array(nodes.length).fill(false);
for(let i = 0; i < nodes.length; i++)
	vist[i] = new Array(nodes.length).fill(0);

function dfs(cur){
	push(nodes[cur], 'color', 'green');
	delay(500);

	for(var to in adj[cur]){
		cur *= 1; to *= 1;
		var eid = adj[cur][to], edge = edges[eid];
		if(vist[cur][to] == true) continue;
		vist[cur][to] = true;
		push(edge, 'color', 'green');
		push(nodes[to], 'color', 'green');
		delay(500);
		push(edge, 'color', 'gray');
		push(edge, 'thick', 1);
		push(nodes[cur], 'color', 'gold');
		delay(500);
		dfs(to);
		push(nodes[cur], 'color', 'green');
		delay(500);
	}

	push(nodes[cur], 'color', 'gold');
}

// Main/onload
$(document).ready(function(){
	speed = 1;
	auto = true;
	g.render();
	dfs(0);
	init();
});
