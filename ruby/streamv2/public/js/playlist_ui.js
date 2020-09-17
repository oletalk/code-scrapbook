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
    // TODO: any way to refresh search list at that point?
    // when you type another search term it will do it
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
