var dummy = { prop : 1};
// Graph setup

var names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'α', 'π', 'Δ', 'θ'];

var nodes = [
	new Node( 0,   76,  133, '', '', 65, 'black'),
	new Node( 1,  259,  155, '', '', 65, 'black'),
	new Node( 2,  180,  437, '', '', 65, 'black'),
	new Node( 3,  186,  283, '', '', 65, 'black'),
	new Node( 4,  659,  195, '', '', 65, 'black'),
	new Node( 5, 1002,  518, '', '', 65, 'black'),
	new Node( 6, 1089,  117, '', '', 65, 'black'),
	new Node( 7,   80,  330, '', '', 65, 'black'),
	new Node( 8,  554,  246, '', '', 65, 'black'),
	new Node( 9,  583,  357, '', '', 65, 'black'),
	new Node(10,  986,  371, '', '', 65, 'black'),
	new Node(11, 1128,  304, '', '', 65, 'black'),
	new Node(12,   70,  572, '', '', 65, 'black'),
	new Node(13,  776,  426, '', '', 65, 'black'),
	new Node(14,  751,  300, '', '', 65, 'black'),
	new Node(15,  178,  573, '', '', 65, 'black'),
	new Node(16,  311,  322, '', '', 65, 'black'),
	new Node(17, 1085,  451, '', '', 65, 'black'),
	new Node(18,  319,  498, '', '', 65, 'black'),
	new Node(19,  910,  453, '', '', 65, 'black'),
	new Node(20,  681,  567, '', '', 65, 'black'),
	new Node(21,  386,  409, '', '', 65, 'black'),
	new Node(22,  555,  463, '', '', 65, 'black'),
	new Node(23,  426,  245, '', '', 65, 'black'),
	new Node(24,  435,  517, '', '', 65, 'black'),
	new Node(25,  361,  101, '', '', 65, 'black'),
	new Node(26, 1024,  272, '', '', 65, 'black'),
	new Node(27,  899,  218, '', '', 65, 'black'),
	new Node(28,  653,   83, '', '', 65, 'black'),
	new Node(29,  798,  553, '', '', 65, 'black'),
];

var edges = [
	new Edge( 0, nodes[10], nodes[26], 0, '', 10, 0, 'black'),
	new Edge( 1,  nodes[5], nodes[17], 0, '', 10, 0, 'black'),
	new Edge( 2, nodes[12], nodes[15], 0, '', 10, 0, 'black'),
	new Edge( 3, nodes[11], nodes[26], 0, '', 10, 0, 'black'),
	new Edge( 4,  nodes[9], nodes[22], 0, '', 10, 0, 'black'),
	new Edge( 5, nodes[18], nodes[21], 0, '', 10, 0, 'black'),
	new Edge( 6, nodes[10], nodes[19], 0, '', 10, 0, 'black'),
	new Edge( 7,  nodes[4], nodes[28], 0, '', 10, 0, 'black'),
	new Edge( 8,  nodes[5], nodes[19], 0, '', 10, 0, 'black'),
	new Edge( 9,  nodes[8],  nodes[9], 0, '', 10, 0, 'black'),
	new Edge(10, nodes[16], nodes[21], 0, '', 10, 0, 'black'),
	new Edge(11,  nodes[1], nodes[25], 0, '', 10, 0, 'black'),
	new Edge(12,  nodes[3],  nodes[7], 0, '', 10, 0, 'black'),
	new Edge(13,  nodes[4],  nodes[8], 0, '', 10, 0, 'black'),
	new Edge(14, nodes[18], nodes[24], 0, '', 10, 0, 'black'),
	new Edge(15, nodes[20], nodes[29], 0, '', 10, 0, 'black'),
	new Edge(16,  nodes[8], nodes[23], 0, '', 10, 0, 'black'),
	new Edge(17, nodes[13], nodes[14], 0, '', 10, 0, 'black'),
	new Edge(18, nodes[13], nodes[29], 0, '', 10, 0, 'black'),
	new Edge(19,  nodes[3], nodes[16], 0, '', 10, 0, 'black'),
	new Edge(20, nodes[22], nodes[24], 0, '', 10, 0, 'black'),
	new Edge(21,  nodes[2], nodes[15], 0, '', 10, 0, 'black'),
	new Edge(22, nodes[26], nodes[27], 0, '', 10, 0, 'black'),
	new Edge(23, nodes[13], nodes[19], 0, '', 10, 0, 'black'),
	new Edge(24,  nodes[4], nodes[14], 0, '', 10, 0, 'black'),
	new Edge(25,  nodes[2],  nodes[7], 0, '', 10, 0, 'black'),
	new Edge(26,  nodes[1],  nodes[3], 0, '', 10, 0, 'black'),
	new Edge(27,  nodes[6], nodes[26], 0, '', 10, 0, 'black'),
	new Edge(28,  nodes[0],  nodes[1], 0, '', 10, 0, 'black'),
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

// Graph algorithm
var size = new Array(nodes.length);
var big = new Array(nodes.length);
var del = new Array(nodes.length).fill(false);
var depth = new Array(nodes.length).fill(0);
var colors = ['#C9F', '#9F9', '#6CF', '#F99', 'orange'];

function dfs(cur, prev){
	size[cur] = 1;
	big[cur] = -1;

	for(var to in adj[cur]){
		if(to == prev || del[to]) continue;
		dfs(to, cur);
		if(big[cur] == -1 || size[to] > size[big[cur]])
			big[cur] = to;
		size[cur] += size[to];
	}
}

function find(cur, total){
	if(size[big[cur]] <= total / 2)
		return cur;
	return find(big[cur], total);
}

function coloring(cur, prev, color){
	push(nodes[cur], 'color', colors[color], 0);
	for(var to in adj[cur]){
		if(del[to] || to == prev) continue;
		push(edges[adj[cur][to]], 'color', colors[color], 0);
		coloring(to, cur, color);
	}
}

function decomp(start){
	var queue = [[0, -1]];
	while(queue.length > 0){
		var cur = queue[0][0];
		var prev = queue[0][1];
		queue.shift();

		dfs(cur, -1);
		var cen = size[cur] == 1 ? cur : find(cur, size[cur]);
		if(prev != -1){
			depth[cen] = depth[prev] + 1;
		}
		
		coloring(cur, prev, 4);

		delay(400);
		if(prev != -1){
			push(edges[adj[cur][prev]], 'color', 'red', 0);
			delay(400);
			push(edges[adj[cur][prev]], 'thick', '3', 0);
			push(edges[adj[cur][prev]], 'color', '#DDD', 0);
		}
		delay(400);

		push(nodes[cen], 'color', '#AAA', 0);
		push(nodes[cen], 'data', depth[cen], 0);
		delay(500);
		push(nodes[cen], 'cdata', '', 0);
		del[cen] = true;

		var i = 0;
		for(var to in adj[cen]){
			if(!del[to]){
				push(edges[adj[cen][to]], 'color', colors[i], 0);
				coloring(to, cen, i);
				delay(200);
				i++;
			}
		}

		delay(100);

		for(var i = 0; i < nodes.length; i++)
			for(var j in adj[i])
				if(!del[i] && !del[j])
					push(edges[adj[i][j]], 'color', 'black', 0);

		for(var i = 0; i < nodes.length; i++)
			if(!del[i])
				push(nodes[i], 'color', 'black', 0);

		for(var to in adj[cen])
			if(!del[to])
				queue.push([to, cen]);

		delay(300);
	}
}

// Main/onload
$(document).ready(function(){
	speed = 1;
	auto = true;
	g.render();
	decomp(0, -1);
//	for(var i = 0; i < nodes.length; i++)
//		push(nodes[i], 'cdata', names[i], 0);
	init();
});
