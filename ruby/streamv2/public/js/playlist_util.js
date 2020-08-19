// ------------- non-react stuff -----------------
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

  sel.innerText = text;

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
      sel.innerHTML = sel.innerText;
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
