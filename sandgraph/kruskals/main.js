var inf = '∞';
var nodes = [
	new Node(00, 200, 150, 'A', '', 70, 'yellow'),
	new Node(01, 250, 350, 'B', '', 70, 'yellow'),
	new Node(02, 500, 300, 'C', '', 70, 'yellow'),
	new Node(03, 525, 500, 'D', '', 70, 'yellow'),
	new Node(04, 700, 100, 'E', '', 70, 'yellow'),
	new Node(05, 800, 450, 'F', '', 70, 'yellow'),
	new Node(06, 950, 300, 'G', '', 70, 'yellow'),
	new Node(07, 670, 300, 'H', '', 70, 'yellow'),
	new Node(08, 230, 520, 'I', '', 70, 'yellow'),
	new Node(09, 920, 100, 'J', '', 70, 'yellow'),
	new Node(10, 920, 500, 'K', '', 70, 'yellow')
];

var edges = [
	new Edge(00, nodes[0], nodes[01], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(01, nodes[0], nodes[02], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(02, nodes[0], nodes[04], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(03, nodes[1], nodes[02], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(04, nodes[1], nodes[03], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(05, nodes[2], nodes[03], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(06, nodes[4], nodes[02], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(07, nodes[2], nodes[07], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(08, nodes[3], nodes[05], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(10, nodes[4], nodes[06], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(11, nodes[8], nodes[01], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(12, nodes[4], nodes[09], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(13, nodes[6], nodes[09], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(14, nodes[6], nodes[10], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(14, nodes[8], nodes[03], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(14, nodes[4], nodes[07], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(14, nodes[7], nodes[06], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(14, nodes[5], nodes[10], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray'),
	new Edge(14, nodes[5], nodes[06], 0, Math.floor(Math.random() * 9) + 1, 12, 25, 'gray')
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

var par = new Array(nodes.length); for(var i = 0; i < nodes.length; i++) par[i] = i;

function find(n){
	if(par[n] == n) return n;
	par[n] = find(par[n]);
	return par[n];
}

function kruskal(){
	var ch = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
	var ok = new Array(edges.length).fill(false);
	edges.sort(function(a, b){
		return a.data - b.data;
	});
	
	var count = 0;
	for(var i = 0; i < edges.length; i++){
		var edge = edges[i];

		var u = edge.start.id, v = edge.end.id;
		push(edges[i], 'color', 'orange');
		delay(1000);
		console.log('' + ch[u] + '->' + ch[v] + ' (' + u + ', ' + v + ')');
		s = '';
		for(var j = 0; j < nodes.length; j++) s += '' + ch[j] + '->' + ch[par[j]] + '  ';
		console.log(s);

		if(find(u) == find(v)){
			push(edges[i], 'color', 'red');
			delay(1000);
			push(edges[i], 'color', 'gray');
			delay(1000);
		}
		else{
			++count;
			par[find(u)] = find(v);
			push(edges[i], 'color', 'green');
			ok[i] = true;
			delay(1000);
		}
		if(count == nodes.length - 1) break;
	}

	for(var i = 0; i < edges.length; i++){
		if(!ok[i]){
			push(edges[i], 'thick', 3);
			push(edges[i], 'fsize', 18);
		}
	}
}

// Main/onload
$(document).ready(function(){
	speed = 1;
	auto = true;
	g.render();
	kruskal();
	init();
});
