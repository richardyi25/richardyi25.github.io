var nodes = [
	new Node(00, 200, 150, '', '', 70, 'gold'),
	new Node(01, 250, 350, '', '', 70, 'gold'),
	new Node(02, 500, 300, '', '', 70, 'gold'),
	new Node(03, 525, 500, '', '', 70, 'gold'),
	new Node(04, 700, 100, '', '', 70, 'gold'),
	new Node(05, 800, 450, '', '', 70, 'gold'),
	new Node(06, 950, 300, '', '', 70, 'gold'),
	new Node(07, 670, 300, '', '', 70, 'gold'),
	new Node(08, 230, 520, '', '', 70, 'gold'),
	new Node(09, 920, 100, '', '', 70, 'gold')
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
var stamp = new Array(nodes.length).fill(null);
var low = new Array(nodes.length).fill(null);
var time = 0;

function dfs(cur, par){
	vist[cur] = true;
	low[cur] = stamp[cur] = ++time;
	push(nodes[cur], 'color', 'green');
	push(nodes[cur], 'data', stamp[cur]);
	push(nodes[cur], 'cdata', low[cur]);
	delay(500);

	for(var to in adj[cur]){
		var eid = adj[cur][to], edge = edges[eid];

		if(to == par) continue;

		push(edge, 'color', 'gold');
		delay(500);

		if(vist[to]){
			if(stamp[to] < stamp[cur]){
				push(edge, 'color', 'orange');
				delay(500);

				if(stamp[to] < low[cur]){
					low[cur] = stamp[to];
					push(nodes[cur], 'cdata', low[cur]);
					delay(500);
				}

				if(edge.start.id == cur)
					push(edge, 'dir', 1);
				else
					push(edge, 'dir', -1);

				push(edge, 'color', 'gray');
				push(edge, 'thick', 3);
				delay(500);
			}
			else{
				push(edge, 'color', 'gray');
				delay(500);
			}
		}
		else{
			push(edge, 'color', 'green')
			if(edge.start.id == cur)
				push(edge, 'dir', 1);
			else
				push(edge, 'dir', -1);

			dfs(to, cur);

			if(low[to] < low[cur]){
				low[cur] = low[to];
				push(nodes[cur], 'cdata', low[cur]);
				delay(500);
			}

			push(edge, 'color', 'gray');
			delay(500);
		}
	}

	push(nodes[cur], 'color', 'orange');
	delay(500);
}

// Main/onload
$(document).ready(function(){
	speed = 1;
	auto = true;
	g.render();
	dfs(0, -1);
	init();
});
