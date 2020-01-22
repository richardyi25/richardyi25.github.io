var g, timer, inf = '∞';

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
	new Edge( 0, nodes[0], nodes[1], 0,  1, 10, 25, 'blue'),
	new Edge( 1, nodes[0], nodes[2], 0,  2, 10, 25, 'blue'),
	new Edge( 2, nodes[0], nodes[4], 0,  7, 10, 25, 'blue'),
	new Edge( 3, nodes[1], nodes[2], 0,  5, 10, 25, 'blue'),
	new Edge( 4, nodes[1], nodes[3], 0,  4, 10, 25, 'blue'),
	new Edge( 5, nodes[2], nodes[3], 0,  2, 10, 25, 'blue'),
	new Edge( 6, nodes[4], nodes[2], 0,  3, 10, 25, 'blue'),
	new Edge( 7, nodes[2], nodes[7], 0,  6, 10, 25, 'blue'),
	new Edge( 8, nodes[3], nodes[5], 0,  2, 10, 25, 'blue'),
	new Edge( 9, nodes[3], nodes[6], 0,  4, 10, 25, 'blue'),
	new Edge(10, nodes[4], nodes[6], 0, 10, 10, 25, 'blue'),
	new Edge(11, nodes[8], nodes[1], 0,  3, 10, 25, 'blue'),
	new Edge(12, nodes[4], nodes[9], 0,  5, 10, 25, 'blue'),
	new Edge(13, nodes[6], nodes[9], 0,  3, 10, 25, 'blue')
];

g = new Graph(nodes, edges);
// Begin util
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
function resolve(){
	anim.reverse();
	
	timer = window.setInterval(function(){
		if(anim.length == 0){
			window.clearInterval(timer);
			return;
		}
		var temp = anim.pop();
		temp[0][temp[1]] = temp[2];
		g.render();
	}, 500);
}
var anim = [];
// End util

var par = [];

function comp(a, b){
	return a.data - b.data;
}

function find(x){
	if(par[x] == x)
		return x;
	else return par[x] = find(par[x]);
}

function join(x, y){
	var r = find(x), s = find(y);
	par[r] = s;
}

function kruskals(){
	for(var i = 0; i < edges.length; i++)
		par[i] = i;
	var edges2 = edges.slice();
	edges2.sort(comp);
	var n = 0;
	for(var i = 0; n < nodes.length - 1; i++){
		var edge = edges2[i];
		print(edge);
		var s = edge.start.id, e = edge.end.id;
		anim.push([edges[edge.id], 'color', 'orange']);
		if(find(s) == find(e)){
			anim.push([edges[edge.id], 'color', 'red']);
			anim.push([edges[edge.id], 'color', 'blue']);
		}
		else{
			anim.push([edges[edge.id], 'color', 'green']);
			join(s, e);
			n++;
		}
	}
}

$(document).ready(function(){
	g.render();
	kruskals();
	resolve();
});
