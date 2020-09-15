// FIXME: these menu items can't be selected again!
function removeSelected() {
  var sel = document.getElementById('playlist');
  var toremove = []
  for (var i = 0; i < sel.options.length; i++) {
    if (sel.options[i].selected) {
      toremove.push(sel.options[i].id);
    }
  }

  for (var r = 0; r < toremove.length; r++) {
    var sel = document.getElementById(toremove[r]);
    sel.remove();
    // check if the menu item should be reactivated in the dropdown
    // (it may not be there)
    var dd_sel = document.getElementById('s_' + toremove[r])
    if (dd_sel != null) { // TODO: do not touch the React list! find another way to do this
      var oldText = dd_sel.innerText;
      // FIXME: I can't just re-add 'addToList' function as
      // it doesn't seem to recognise it if I refer to it outside the js :-/
      var str = "<a onClick=\"alert('Unable to re-add this song. Please save and come back to this playlist.')\">" + oldText + "</a>";
      dd_sel.innerHTML = str; // FIXME

    }
  }

}

function toggleMoveButtons() {
  let s = document.getElementById('playlist');
  let i = s.selectedIndex;
  let n = s.options.length;

  let upBtn = document.getElementById('move-up');
  let downBtn = document.getElementById('move-down');
  if (i == -1) {
    upBtn.classList.add('disabled');
    downBtn.classList.add('disabled');
  } else {
    if (i == 0) {
      upBtn.classList.add('disabled');
      downBtn.classList.remove('disabled');
    } else if (i == n - 1) {
      upBtn.classList.remove('disabled');
      downBtn.classList.add('disabled');
    } else {
      upBtn.classList.remove('disabled');
      downBtn.classList.remove('disabled');
    }
  }

}
function moveUp() {
  let s = document.getElementById('playlist');
  let i = s.selectedIndex;
  if (i != -1) {
    if (i > 0) {
      let a = s.options[i];
      s.remove(i);
      s.add(a, i-1);
      markChanges();

      // use select.add and select.remove
      s.selectedIndex = i - 1;
    } else {
      alert("Already at top of list!");
      toggleMoveButtons();
    }
  }
}

function moveDown() {
  let s = document.getElementById('playlist');
  let i = s.selectedIndex;
  if (i < s.options.length - 1) {
    if (i < s.options.length - 1) {
      let a = s.options[i];
      s.remove(i);
      s.add(a, i+1);
      markChanges();

      // use select.add and select.remove
      s.selectedIndex = i + 1;
    }
  } else {
    alert("Already at bottom of list!");
    toggleMoveButtons();
  }
}

// NOTE: do not pass raw id here. uses s_<id> for checks.
function itemAlreadyInPlaylist (hash) {
  var ret = false;

  let sel = document.getElementById('playlist');
  for (var i = 0; i < sel.options.length; i++) {
    let opt = sel.options[i];
    let dd_identifier = hash.split('_')
    if (opt.id == dd_identifier[1]) { // without the s_...
      ret = true;
    }
  }
  return ret;
}



function addToList (hash) {
  var sel = document.getElementById(hash); // should have s_ in front
  if (sel != null) {
    if (itemAlreadyInPlaylist(hash)) {
      alert('Sorry, the playlist already has this item.');
    } else {
      var playlist = document.getElementById('playlist');
      var newOption = document.createElement('option');
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
