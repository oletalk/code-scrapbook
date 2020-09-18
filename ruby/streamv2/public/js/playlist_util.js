// ------------- non-react stuff -----------------
const MAX_ITEM_LENGTH = 50;


function fixTitle (title) {
  let ret = title;
   if (ret == null) {
    ret = '???';
   }
   if (ret.length > MAX_ITEM_LENGTH) {
      ret = ret.substr(0,MAX_ITEM_LENGTH - 3) + "...";
    }
    return ret;
}

function nonnull(str) {
    return (str !== undefined && str !== null) ? str : undefined;
}

function songFromJson (si, json) {
  let songitem = json;
  let item = {
     counter: si,
     hash: songitem['hash'],
     title: fixTitle(songitem['title']),
     date_added: nonnull(songitem['date_added']),
     plays: nonnull(songitem['plays']),
     last_played: nonnull(songitem['last_played']),
     derived: nonnull(songitem['title_derived'])
   };
   return item;
}

function positionTooltip(e) {
  let y = e.clientY;
  let tooltipDiv = document.getElementById('song_tooltip_container');
  tooltipDiv.style.position = 'absolute';
  tooltipDiv.style.top = (y + 20) + 'px';

}

function hideTooltip () {
  let sel = document.getElementById('song_tooltip');
  sel.classList.remove('tooltipshow');
  sel.classList.add('tooltip');

  let selcont = document.getElementById('song_tooltip_container');
  selcont.classList.remove('tooltipshow');
  selcont.classList.add('tooltip');

  sel.innerText = "";
}

function displayTooltip (text) {
  let sel = document.getElementById('song_tooltip');

  sel.innerHTML = text;

  sel.classList.remove('tooltip');
  sel.classList.add('tooltipshow');

  let selcont = document.getElementById('song_tooltip_container');
  selcont.classList.remove('tooltip');
  selcont.classList.add('tooltipshow');

}

function markChanges () {
  let dt = document.title;
  if (dt.indexOf('[') == -1) {
    document.title = "[changes made] " + document.title;
  }
}


// from the original HTML doc
function checkBeforeLeaving() {
  if (document.title.indexOf('[') != -1) {
    return confirm("You made changes to the playlist. Are you sure you want to leave?");
  }
}



function preDelete() {
  return confirm("Are you sure you want to delete this playlist??");
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
