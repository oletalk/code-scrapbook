var searchStyle = document.getElementById('search_style');
  //alert(searchStyle.innerHTML);
document.getElementById('srch').addEventListener('input', function() {
  if (!this.value) {
    searchStyle.innerHTML = "";
    return;
  }

  searchStyle.innerHTML = ".searchable:not([data-index*=\"" + this.value.toLowerCase() + "\"]) { display: none; }";
});

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

      newli.appendChild(document.createTextNode(songDisp));
      selectBox.appendChild(newli);
    } else {
      alert("Error: This item seems to be in the list already.");
    }
  }

}

function dragStarted(evt) {
}

function draggingOver(evt) {
}
