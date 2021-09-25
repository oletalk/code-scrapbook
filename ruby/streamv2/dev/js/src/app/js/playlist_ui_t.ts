function itemAlreadyInPlaylist (hash: string): boolean {
  var ret = false;

  let sel = <HTMLSelectElement>document.getElementById('playlist');
  for (var i = 0; i < sel.options.length; i++) {
    let opt = sel.options[i];
    let dd_identifier = hash.split('_')
    if (opt.id == dd_identifier[1]) { // without the s_...
      ret = true;
    }
  }
  return ret;
}

function addToList (hash: string) {
  var sel = <HTMLSelectElement>document.getElementById(hash); // should have s_ in front
  if (sel != null) {
    if (itemAlreadyInPlaylist(hash)) {
      alert('Sorry, the playlist already has this item.');
    } else {
      var playlist = <HTMLSelectElement>document.getElementById('playlist');
      var newOption = <HTMLOptionElement>document.createElement('option');
      newOption.text = sel.innerText;
      //sel.innerHTML = sel.innerText; // don't touch stuff managed by React!!
      //alert(hash);
      let dd_identifier = hash.split('_')
      newOption.id = dd_identifier[1]; // without the s_!
      playlist.add(newOption);
      markChanges();
    }
  } else {
    alert("Sorry, I was unable to find that song.");
  }
}

function markChanges () {
  let dt = document.title;
  if (dt.indexOf('[') == -1) {
    document.title = "[changes made] " + document.title;
  }
}


export { addToList, itemAlreadyInPlaylist };
