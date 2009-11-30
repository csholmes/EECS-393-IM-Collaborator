// JS File
// @author: Curtis Holmes
// @date: 28 November 2009

function message (from, body) { // Received Message
	
	openChatWindow(from, from);
	addMessageText(from, body);
	
}

function addMessageText(user, msg) {
	
	// Append text to area
	var tf = document.getElementById("chat_text_" + user);
	tf.innerHTML = tf.innerHTML + "\n" + user + ": " + msg;
	
	//scroll to bottom of text
	ct = document.getElementById("chat_text_" + user);
	ct.scrollTop = ct.scrollHeight;
}

function openChatWindow(user, name) {
	
	if (!document.getElementById('chat_' + user)) {
		
		/* Create a window like this under bottom_windows
		
		<div class="window" id="chat_user@host.com">
			
			<div class="windowtop" >
				<div class="windowtoptext">chat_user@host.com</div>
				<a class="closebutton" href="" onclick="closeChatWindow('chat_user@host.com'); return false;"></a>
				<a id="minmax_chat_user@host.com" class="minbutton" href="" onclick="minChatWindow('chat_user@host.com'); return false;" ></a>			
			</div>
			
			<textarea class="windowtextarea" id="chat_text_csh22@case.edu" readonly="readonly" ></textarea>
			<textarea class="windowtextenter" onkeyup="checkEnter('csh22@case.edu', this, event)"></textarea>

		</div>
		
		*/

		// Create div elements
		var div = document.createElement('div');
		var topdiv = document.createElement('div');
		var toptextdiv = document.createElement('div');
		
		// windowdiv elements
		div.className = "window";
		div.id = "chat_" + user;
		
		// windowtopdiv element
		topdiv.className = "windowtop";
		
		// toptextdiv elements
		toptextdiv.className = "windowtoptext";
		var chatname = document.createTextNode(name);
		toptextdiv.appendChild(chatname);
		
		var close = document.createElement('a');
		close.className = "closebutton";
		close.setAttribute("href", "");
		close.setAttribute("onclick", "closeChatWindow('" + user + "'); return false;");
		
		var min = document.createElement('a');
		min.className = "minbutton";
		min.id = "minmax_" + user;
		min.setAttribute("href", "");
		min.setAttribute("onclick", "minChatWindow('" + user + "'); return false;");
		
		// Append topdivs
		topdiv.appendChild(toptextdiv);
		topdiv.appendChild(close);
		topdiv.appendChild(min);
		
		// Windows
		var textarea = document.createElement('textarea');
		textarea.className = "windowtextarea";
		textarea.id = "chat_text_" + user;
		textarea.setAttribute('readonly', 'readonly');
		
		var textenter = document.createElement('textarea');
		textenter.className = "windowtextenter";
		textenter.setAttribute("onkeyup", "checkEnter('" + user + "', this, event)");
		
		//Append children
		div.appendChild(topdiv);
		div.appendChild(textarea);
		div.appendChild(textenter);
		document.getElementById('bottom_windows').appendChild(div);
		
	}
}

function closeChatWindow(user) {
	
	var window = document.getElementById('chat_' + user);
	window.parentNode.removeChild(window);
}

function minChatWindow(user) {
	
	var window = document.getElementById('chat_' + user);
	window.className = "minwindow";
	
	var minmax = document.getElementById('minmax_' + user);
	minmax.className = "maxbutton"; 
	minmax.setAttribute('onclick', "maxChatWindow('" + user + "'); return false;")
}

function maxChatWindow(user) {
	
	var window = document.getElementById('chat_' + user);
	window.className = "window";
	
	var minmax = document.getElementById('minmax_' + user);
	minmax.className = "minbutton"; 
	minmax.setAttribute('onclick', "minChatWindow('" + user + "'); return false;")
}

function checkEnter(user, element, number) {
	
	if (number.keyCode == 13) {
		sendMessage (user, rtrim(element.value));
		element.value = "";
		

	}
}

function sendMessage (user, msg) {
	
	// Send message to Rails
	new Ajax.Updater('nothing', '/im/sendmessage', {asynchronus:true, evalScripts:true, parameters:{to:user, msg:msg}});
	
	//Add to text field
	//alert(user + " " + msg);
	var tf = document.getElementById("chat_text_" + user);
	tf.innerHTML = tf.innerHTML + "\nMe: " + msg;
	
	//scroll to bottom of text
	ct = document.getElementById("chat_text_" + user);
	ct.scrollTop = ct.scrollHeight;
}

function rtrim(stringToTrim) {
	return stringToTrim.replace(/\s+$/,"");
}

// for changing presence

function updatePresence(user, presence) {
	
	//alert('sdfsdfsd');
	//alert(user + " " + presence);
	// remove old buddy 
	

	if (document.getElementById('buddy_' + user)) {
		
		var buddy = document.getElementById('buddy_' + user);

		if (buddy.className == "buddy_offline") {

			buddy.className = "buddy";
			buddy.setAttribute("onclick", "openChatWindow('"+ user +"', '"+ user +"');");
			buddytext = document.getElementById('buddytext_' + user);
			buddytext.className = "buddytext";

			// Move buddy to online
			buddy.parentNode.removeChild(buddy);
			
		}

		// Update presence color
		
		
		
		switch (presence) {
		
		case '':
			document.getElementById("green").appendChild(buddy);
			buddycolor = document.getElementById("buddyimage_"+user);			
			buddycolor.setAttribute('src', '/images/greencircle.png');
			break;
		case 'chat':
			document.getElementById("green").appendChild(buddy);
			buddycolor = document.getElementById("buddyimage_"+user);	
			buddycolor.setAttribute('src', '/images/greencircle.png');
			break;
		case 'away':
			document.getElementById("yellow").appendChild(buddy);
			buddycolor = document.getElementById("buddyimage_"+user);	
			buddycolor.setAttribute('src', '/images/yellowcircle.png');
			break;
		case 'dnd':
			document.getElementById("red").appendChild(buddy);
			buddycolor = document.getElementById("buddyimage_"+user);	
			buddycolor.setAttribute('src', '/images/redcircle.png');
			break;
		default:
			document.getElementById("offline").appendChild(buddy);
			break;
		}
		
	} 
}

function logout() {
	
	new Ajax.Updater('nothing', '/im/logout', {asynchronus:true, evalScripts:true});
	//alert('closing');
} 

