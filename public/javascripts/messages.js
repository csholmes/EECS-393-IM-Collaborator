// Created by Curtis Holmes
// 9 November 2009

function message (from, body) {
	
	if (!document.getElementById('message_text_' + from)) {
		
		//Create a new messagebox if one is not already there
		alert("Creating new div");
		createMessageDiv(from);
		
	}
	
	// Append text to area
	var tab = document.getElementById("message_text_" + from); 
	var brk = document.createTextNode(from + ': ' + body);
	tab.appendChild(brk);	
	
}

function createMessageDiv(user) {
	
	var message = document.createElement('div');
	message.className = "message";
	message.id = "message_" + user;
	
	var messageheader = document.createElement('div');
	messageheader.className = "messageheader";
	messageheader.innerHTML = user;
	
	var messagetext = document.createElement('div');
	messagetext.className = "messagetext";
	messagetext.id = "message_text_" + user;
	
	var entry = document.createElement('div');
	var entry_form = document.createElement('form');
	entry_form.setAttribute('action', "im/sendmessage");
	entry_form.setAttribute('method', "post");
	entry_form.setAttribute('onSubmit', "new Ajax.Updater('content', 'im/sendmessage', {asynchronus:true, evalScripts:true parameters:Form.serialize(this)}); return false;");
	
	var msg = document.createElement('input');
	msg.name = "message";
	msg.type = "text";
	
	var to = document.createElement('input');
	to.name = "to";
	to.type = "hidden";
	
	var submit = document.createElement('input');
	submit.name = "commit";
	submit.type = "submit";
	submit.value = "Send";
	
	entry_form.appendChild(msg);
	entry_form.appendChild(to);
	entry_form.appendChild(submit);
	entry.appendChild(entry_form);
	
	message.appendChild(messageheader);
	message.appendChild(messagetext);
	message.appendChild(entry);
	
	var messages = document.getElementById("messages");
	messages.appendChild(message);
}