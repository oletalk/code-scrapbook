'use strict';

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

function markChanges () {
  let dt = document.title;
  if (dt.indexOf('[') == -1) {
    document.title = "[changes made] " + document.title;
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
function preSubmit() {
  // we want all the items, not just the selected ones.
  var hashes = "";
  var namefield = document.getElementById('playlist_name')
  if (namefield.value == '') {
    alert('Please input a playlist name');
    return false;
  }
  var sel = document.getElementById('playlist');
  if (sel.options.length < 2) {
    alert('Please add at least 2 items to the playlist');
    return false;
  }
  for (var i = 0; i < sel.options.length; i++) {
    if (i != 0) {
      hashes += ",";
    }
    hashes += sel.options[i].id;
  }
  document.forms[0].songids.value = hashes;
  return true;
}
function preDelete() {
  return confirm("Are you sure you want to delete this playlist??");
}
function checkBeforeLeaving() {
  if (document.title.indexOf('[') != -1) {
    return confirm("You made changes to the playlist. Are you sure you want to leave?");
  }
}
