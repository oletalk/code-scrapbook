// d'n'd list manipulation
function addsong(songitem) {
  var toAdd = document.getElementById(songitem.value);
  var songid = songitem.value;
  var songDisp = toAdd.innerHTML;
  var delItem = !songitem.checked;
  
  var selectBox = document.getElementById('selectedsongs').firstChild;
  var chkId = 'list_' + songid;
  var lit = document.getElementById(chkId);

  if (delItem) {
    if (lit === null) {
      alert("Error: This item isn't actually in the list.");
    } else {
      selectBox.removeChild(lit);
    }
  } else {
    if (lit === null) {
      var newli = document.createElement("li");
      newli.setAttribute("id", chkId);
      newli.setAttribute("draggable", "true");
      newli.setAttribute("ondragstart", "dragStarted(event)");
      newli.setAttribute("ondragover", "draggingOver(event)");
      newli.setAttribute("ondrop", "dropped(event)");

      newli.appendChild(document.createTextNode(songDisp));
      selectBox.appendChild(newli);
    } else {
      alert("Error: This item seems to be in the list already.");
    }
  }

}

function updatebox() {
  var songlist = document.getElementById("selectedsongs").firstChild;
  var songs = songlist.childNodes;
  var ids = "";
  for (i = 0; i < songs.length; i++) {
    ids += (i == 0 ? "" : ",") + songs[i].id;
  }
  document.getElementById("songids").value = ids;
  return true;
}

// drag 'n' drop code

var source;

function dragStarted(evt) {
  source = evt.target;
  // we need to drag the text and the id behind it
  evt.dataTransfer.setData("text/plain", evt.target.innerHTML + "||" + evt.target.id);
  evt.dataTransfer.effectAllowed = "move";
}

function draggingOver(evt) {
  evt.preventDefault();
  evt.dataTransfer.dropEffect = "move";
}

function dropped(evt) {
  evt.preventDefault();
  evt.stopPropagation();
  // update text and id in dragged item
  source.innerHTML = evt.target.innerHTML;
  source.id = evt.target.id;
  // update text and id in dropped target
  var drpp = evt.dataTransfer.getData("text/plain").split("||");
  evt.target.innerHTML = drpp[0];
  evt.target.id = drpp[1];
}

