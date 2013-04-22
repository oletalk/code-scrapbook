/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
editing = '';

function updateDoc(row) {
    var rowid = row.id;
    var tdlist = row.getElementsByTagName('input');

    var postUrl = '/TagEditor/tags/update.htm?hash=' + rowid;
    
    for (var i = 0; i < tdlist.length; i++) {
        if (tdlist[i].type == 'text' && tdlist[i].value != '') {
            var n = tdlist[i].name;
            var v = tdlist[i].value;
            postUrl += '&' + n + '=' + escape(v);
            tdlist[i].value = '';
        }
        
    }
    
    if (!confirm('To send: ' + postUrl)) {
        return;
    }
    if (window.XMLHttpRequest()) {
        xmlhttp=new XMLHttpRequest();
    } else {
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    
    xmlhttp.open("POST", postUrl, false);
    xmlhttp.send();
    xmlDoc = xmlhttp.responseXML;
    //alert(xmlDoc);
}

function filter(fld) {
    
    var searchstr = fld.value.toUpperCase();
    // filter on this value if it is not empty
    var tdlist = document.getElementsByTagName('td');
    for (var i = 0; i < tdlist.length; i++) {
        if (tdlist[i].className == 'filepath') {
            var j = tdlist[i].firstChild.textContent.toUpperCase();
            var row = tdlist[i].parentNode;

            if (searchstr != '') {
                if (j.indexOf(searchstr) == -1) {
                    row.className = 'trhidden';
                } else {
                    row.className = 'trvisible';
                }
            } else {
                row.className = 'trvisible'; // all visible if no search string
            }
        }
    }
}

function setedit(btn, val) {
    var hash_row = btn.parentNode.parentNode;

    if (editing != '') {
        if (val == true) {
            return;
        } else {
            editing = '';
            updateDoc(hash_row);
        }
    }
    //alert('Song with hash: ' + hash_row.id);
    var tdlist = hash_row.getElementsByTagName('input');
    for (var i = 0; i < tdlist.length; i++) {
        if (tdlist[i].type == 'text') {
            //alert(tdlist[i].name + ' is ' + tdlist[i].value);
            tdlist[i].readOnly = !val;
            if (val == true)
                editing = hash_row.id;
        }
    }
}

