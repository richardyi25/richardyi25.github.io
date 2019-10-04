definitions = {};
allowed = ["Theorem", "Lemma", "Axiom"];

function getAlias(name){
	if(name in definitions)
		return definitions[name];
	return name;
}

function removeComments(text){
	var ignore = false;
	var result = '';
	for(var i = 0; i < text.length - 1; i++){
		if(text[i] == '(' && text[i + 1] == '*') ignore = true;
		if(!ignore){
			if(text[i] == ' ' && text[i + 1] == ' ') continue;
			result += text[i];
		}
		if(text[i] == '*' && text[i + 1] == ')'){
			ignore = false;
			++i;
		}
	}
	if(!ignore) result += text[text.length - 1];
	return result;
}

function convert(){
	var outLines = [];
	var output = "";

	var text = document.getElementById("code").value;
	text = removeComments(text);
	text = text.replace(/\n/g, '');
	text = text.replace(/\r/g, '');
	var lines = text.split('.');

	var ignore = false;
	for(var i = 0; i < lines.length; i++){
		var line = lines[i];
		line = line.trim();

		if(line == "Proof.")
			ignore = true;
		if(ignore) continue;

		var keyword = line.split(' ', 1)[0];
		if(keyword == "Definition"){
			var parts = line.split(':=');
			var left = parts[0].split(' ')[1].trim();
			var right = parts[1].trim();
			definitions[right] = left;
		}
		if(allowed.indexOf(keyword) >= 0){
			outLines.push(line.split(' ').slice(1).join(' '));
		}

		if(line == "Qed." || line == "Admitted.")
			ignore = false;
	}

	var maxLength = 0;
	for(var i = 0; i < outLines.length; i++){
		var line = outLines[i];
		name = line.split(':', 1)[0].trim();
		name = getAlias(name);
		console.log(name, name.length);
		maxLength = Math.max(maxLength, name.length);
	}

	for(var i = 0; i < outLines.length; i++){
		var line = outLines[i];
		var parts = line.split(':');
		var name = getAlias(parts[0].trim()), statement = parts.slice(1).join(':');
		output += name + ' '.repeat(maxLength + 2 - name.length) + statement + '\n';
	}

	document.getElementById("result").value = output;
}

function clearTextArea(){
	var ele = document.getElementById("code");
	if (ele.value == "Enter your Coq code here...")
		ele.value = "";
}

document.addEventListener("DOMContentLoaded", function(){
	document.getElementById("go").addEventListener("click", convert);
	document.getElementById("code").addEventListener("click", clearTextArea);
	document.getElementById("code").addEventListener("focus", clearTextArea);
});
