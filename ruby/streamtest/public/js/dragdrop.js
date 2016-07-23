
// drag and drop to stash away elsewhere
function handleDragStart(ev) {
   var foo = { hash: ev.target.id, title: ev.target.innerHTML };
   ev.dataTransfer.setData("text", JSON.stringify(foo));
}

function allowDrop(e) {
    e.preventDefault();
}

function clickImg(gid) {
    var l = document.getElementById(gid);
    var ul = l.parentNode;
    ul.removeChild(l);
    if (ul.getElementsByTagName('li').length === 0) {
        ul.appendChild(newLIwith('no songs', false));
    }
    collectSongs();
}

function collectSongs() {
    var allsongs = document.getElementById('target').getElementsByClassName('playlistsong');
    var ret = [];
    for (i = 0; i < allsongs.length; i++) {
        ret.push({ 'hash': allsongs[i].parentElement.getAttribute('data-id') });
    }
    document.getElementById('listcontent').value = JSON.stringify(ret);
}

function saveSongs() { // TODO: probably do this with angular
    alert(document.getElementById('listcontent').value );
}

function drop(e) {
    e.preventDefault();
    var data = e.dataTransfer.getData("text");
    var datajson = JSON.parse(data);
    var targetUL = document.getElementById('target').getElementsByTagName('ul');
    //var newLI = document.createElement('li');
    var newLI = newLIwithXandGUID(datajson.title, datajson.hash);
    var l = targetUL[0];
    if (l.getElementsByClassName('playlistsong').length === 0) {
        l.replaceChild(newLI, l.childNodes[1]);
    } else {
        l.appendChild(newLI);
    }
    collectSongs();
}

function newLIwith(text, issong) {
    var newLI = document.createElement('li');
    var LItext = document.createTextNode(text);
    if (issong) {
        var newSPAN = document.createElement('span');
        newSPAN.appendChild(LItext);
        newSPAN.setAttribute('class', 'playlistsong');
        newLI.appendChild(newSPAN);
    } else {
        newLI.appendChild(LItext);
    }
    return newLI;
}

function newLIwithXandGUID(text, songhash) {
    var newLI = newLIwith(text, true);
    var newid = smallguid();
    var newIMG = document.createElement('img');
    newIMG.setAttribute('src', '/img/x-small.png');
    newIMG.setAttribute('alt', 'x');
    newIMG.setAttribute('onclick', 'clickImg(\'' + newid + '\')');
    newLI.setAttribute('id', newid);
    newLI.setAttribute('data-id', songhash);
    // we want to insert this before the span, though
    newLI.insertBefore(newIMG, newLI.childNodes[0]);
    return newLI;
}

function smallguid() {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4();
}

