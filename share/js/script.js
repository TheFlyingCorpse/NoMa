// global setting for mouse position
var mouseX = 0;
var mouseY = 0;
document.onmousemove = getMousePos;

// retrieve mouse position
function getMousePos (e) {
	if (document.all) {
		mouseX = event.clientX;
		mouseY = event.clientY;
	} else {
		mouseX = e.pageX;
		mouseY = e.pageY;
	}
	if (mouseX < 0) mouseX = 0;
	if (mouseY < 0) mouseY = 0;  
}

// show popup for contact and group names
function showLong (txt) {
	document.getElementById('longText').style.left = mouseX + 'px';
	document.getElementById('longText').style.top = mouseY + 'px';
	document.getElementById('longText').style.visibility = 'visible';
	document.getElementById('longText').innerHTML = txt;
}

// hide popup for contact and group names
function hideLong () {
	document.getElementById('longText').style.visibility = 'hidden';
	document.getElementById('longText').innerHTML = '';
}

// enable/disable notifications
function toggleActive (id) {
	window.location.href='index.php?action=toggle_active&id=' + id;
}

// edit notification
function editEntry (id) {
	window.location.href='index.php?action=edit&id=' + id;
}

// delete notification
function deleteEntry (id) {
	if(!confirm('Do you really want to delete this notification?')) return false;
	window.location.href='index.php?action=del&id=' + id;
}

// set value of page element
function setValue (elementID, value) {
	document.getElementById(elementID).value = value;
}

// ajax for host and service previews

var request = false;

function update_preview (entity, type) {

	var s = '&';
	request = false;

	// create query string
	var prefix = '';
	var qStrFilter = 'filter=';

	switch (entity) {
		case 'r':
                        prefix = 'recipients_';
                        break;
		case 'hg':
			prefix = 'hostgroups_';
			break;
		case 'h':
			prefix = 'hosts_';
			break;
                case 'sg':
                        prefix = 'servicegroups_';
                        break;
		case 's':
			prefix = 'services_';
			break;
		default:
			return false;
	}

	switch (type) {
		case 'i':
			qStrFilter += document.getElementById(prefix + 'include').value;
			break;
		case 'e':
			qStrFilter += document.getElementById(prefix + 'exclude').value;
			break;
		default:
			return false;
	}

	var url = 'index.php?preview=&entity=' + entity + '&' + qStrFilter

	// create request object
	if (window.XMLHttpRequest) {
		request = new XMLHttpRequest();
		if (request.overrideMimeType) {
			request.overrideMimeType('text/xml');
		}
	}else if (window.ActiveXObject) {
		try{
			request = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try{
				request = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {}
		}
	}

	request.onreadystatechange = show_preview_result;
	request.open('get', url, true);
	request.send(null);

}

function show_preview_result () {

	var content = '';
	var element = document.getElementById('hs_preview');

	if (request.readyState == 4) {
		if (request.status == 200) {
			if (request.responseText != '') {
				content = request.responseText;
			}
		}
	}

	element.style.visibility = (content != "") ? "visible" : "hidden";
	element.innerHTML = content;

}

function toggle() {
	var ele = document.getElementById("toggleAffectedObjects");
	var text = document.getElementById("displayAffectedObjects");
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "show linked objects";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "hide linked objects";
	}
}
