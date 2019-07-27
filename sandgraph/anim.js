// Animation Queue
var anim = [];
// Make the queue "persistent" (can revert states)
var rev = [];
// Which animation needs to be resolved next
var counter = 0;
// Whether animation is running automatically
var auto = false;
var speed = 1;

// Wrap into array
function push(a, b, c){
	anim.push([a, b, c]);
}

function delay(n){
	anim.push([n]);
}

pause = delay;

// Step forward (auto or manual)
function next(){
	var delay;
	while(true){
		// Exit if past last animation
		if(counter >= anim.length) return;

		// Resolve all animation object
		while(true){
			var temp = anim[counter++];
			if(temp.length == 1) break;
			var obj = temp[0], index = temp[1], val = temp[2];
			obj[index] = val;
		}

		// Delay object
		delay = temp[0];
		// Pop all subsequent delays if on manual
		if(!auto)
			while(counter < anim.length && anim[counter].length == 1)
				++counter;
		break;
	}

	g.render();
	if(auto) window.setTimeout(next, delay / speed);
}

// Step back (manual only)
function prev(){
	while(true){
		if(counter <= 0) break;
		var temp = rev[counter--];
		if(temp.length == 1) break;
		var obj = temp[0], index = temp[1], val = temp[2];
		obj[index] = val;
	}

	while(anim[counter].length == 1)
		--counter;

	g.render();
}

// Generate rev array and autostart
function init(){
	delay(1000);

	for(var i = 0; i < anim.length; i++){
		var temp = anim[i];
		if(temp.length == 1){
			rev.push(temp);
		}
		else{
			var obj = temp[0], index = temp[1], val = temp[2];
			rev.push([obj, index, obj[index]]);
			obj[index] = val;
		}
	}

	for(var i = rev.length - 1; i >= 0; i--){
		var temp = rev[i];
		if(temp.length == 1) continue;
		var obj = temp[0], index = temp[1], val = temp[2];
		obj[index] = val;
	}

	if(auto) next();
}

$(document).keydown(function(e){
	// "T" key toggles auto/manual
	if(e.which == 84){
		if(auto) auto = false;
		else{
			auto = true;
			next();
		}
	}
	// Left arrow steps back in manual mode
	else if(e.which == 37){
		if(!auto)
			prev();
	}
	// Right arrow steps forward in manual mode
	else if(e.which == 39){
		if(!auto)
			next();
	}
	// Up arrow increases speed in auto mode
	else if(e.which == 38){
		e.preventDefault();
		speed *= 1.1;
	}
	// Down arrow decreases speed in auto mode
	else if(e.which == 40){
		e.preventDefault();
		speed /= 1.1;
	}
	// Restart (refresh) on R
	else if(e.which == 82)
		window.location.reload();
});

//$(document).click(next);
