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
    alert(xmlDoc);
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

