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
	new Edge(00, nodes[0], nodes[1], 0, '', 10, 20, 'gray'),
	new Edge(01, nodes[0], nodes[2], 0, '', 10, 20, 'gray'),
	new Edge(02, nodes[0], nodes[4], 0, '', 10, 20, 'gray'),
	new Edge(03, nodes[1], nodes[2], 0, '', 10, 20, 'gray'),
	new Edge(04, nodes[1], nodes[3], 0, '', 10, 20, 'gray'),
	new Edge(05, nodes[2], nodes[3], 0, '', 10, 20, 'gray'),
	new Edge(06, nodes[4], nodes[2], 0, '', 10, 20, 'gray'),
	new Edge(07, nodes[2], nodes[7], 0, '', 10, 20, 'gray'),
	new Edge(08, nodes[3], nodes[5], 0, '', 10, 20, 'gray'),
	new Edge(09, nodes[3], nodes[6], 0, '', 10, 20, 'gray'),
	new Edge(10, nodes[4], nodes[6], 0, '', 10, 20, 'gray'),
	new Edge(11, nodes[8], nodes[1], 0, '', 10, 20, 'gray'),
	new Edge(12, nodes[4], nodes[9], 0, '', 10, 20, 'gray'),
	new Edge(13, nodes[6], nodes[9], 0, '', 10, 20, 'gray')
];

var g = new Graph(nodes, edges);

// Adjacency list setup
var adj = new Array(nodes.length);
for(var i = 0; i < nodes.length; i++)
	adj[i] = {};
for(var i = 0; i < edges.length; i++){
	var edge = edges[i];
	adj[edge.start.id][edge.end.id] = i;
	adj[edge.end.id][edge.start.id] = i;
}

var vist = new Array(nodes.length).fill(false);
var dir2 = new Array(edges.length).fill(0);

function dfs(cur, prev){
	vist[cur] = true;
	push(nodes[cur], 'cdata', 'V');
	push(nodes[cur], 'color', 'green');
	delay(500);
	
	for(var to in adj[cur]){
		var i = adj[cur][to];
		if(to == prev) continue;

		push(edges[i], 'color', 'orange');
		delay(500);

		if(!vist[to]){
			push(edges[i], 'color', 'green');
			if(edges[i].start.id == cur){
				push(edges[i], 'dir', 1);
				dir2[i] = 1;
			}
			else{
				push(edges[i], 'dir', -1);
				dir2[i] = -1;
			}

			delay(500);
			dfs(to, cur);

			push(edges[i], 'color', 'gray');
			delay(500);
		}
		else{
			push(edges[i], 'color', 'red');
			delay(500);
			push(edges[i], 'color', 'gray');
			delay(500);
		}
	}
	push(nodes[cur], 'color', 'yellow');
	delay(500);
}

// Main/onload
$(document).ready(function(){
	speed = 1;
	auto = true;
	g.render();
	dfs(0);
	for(var i = 0; i < edges.length; i++){
		if(dir2[i] == 0){
			push(edges[i], 'thick', 3);
		}
	}
	init();
});
