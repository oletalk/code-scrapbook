'use strict';
const e = React.createElement;
const MAX_ITEM_LENGTH = 30;
const MAX_LIST_LENGTH = 30;

class Search extends React.Component {
 state = {
   query: '',
   songs: []
 }

 // NOTE: do not pass raw id here. uses s_<id> for checks.
 itemAlreadyInPlaylist = (hash) => {
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

 hideTooltip = () => {
   let sel = document.getElementById('song_tooltip');
   sel.classList.remove('tooltipshow');
   sel.classList.add('tooltip');

   let selcont = document.getElementById('song_tooltip_container');
   selcont.classList.remove('tooltipshow');
   selcont.classList.add('tooltip');

   sel.innerText = "";
 }

 displayTooltip = (text) => {
   let sel = document.getElementById('song_tooltip');

   sel.innerText = text;

   sel.classList.remove('tooltip');
   sel.classList.add('tooltipshow');

   let selcont = document.getElementById('song_tooltip_container');
   selcont.classList.remove('tooltip');
   selcont.classList.add('tooltipshow');

 }

 markChanges = () => {
   let dt = document.title;
   if (dt.indexOf('[') == -1) {
     document.title = "[changes made] " + document.title;
   }
 }

 addToList = (hash) => {
   var sel = document.getElementById(hash); // should have s_ in front
   if (sel != null) {
     if (this.itemAlreadyInPlaylist(hash)) {
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
       this.markChanges();
     }
   } else {
     alert("Sorry, I was unable to find that song.");
   }
 }

 handleInputChange = (ev) => {
   var a = this;
   var str = ev.target.value;
   var selectedSongs = [];
   if (str.length > 3) {
     axios.get('/search/' + str)
     .then(function (response) { // process search results
       if (Array.isArray(response.data)) {
         for (let si = 0; si < response.data.length; si++) {
           let songitem = response.data[si];
           let si_hash = songitem['hash'];
           let si_title = songitem['title'];
           let si_plays = songitem['plays'];
           let si_last_played = songitem['last_played'];
           if (si_title == null) {
             si_title = '???';
           }
           if (si_title.length > MAX_ITEM_LENGTH) {
             si_title = si_title.substr(0,MAX_ITEM_LENGTH - 3) + "...";
           }
           if (selectedSongs.length <= MAX_LIST_LENGTH) {

             if (a.itemAlreadyInPlaylist('s_' + si_hash)) {
               selectedSongs.push(
                 e('li', {
                   id: "s_" + si_hash,
                   key: si
                 }, si_title )
               )
             } else {
               selectedSongs.push(
                 e('li', {
                   id: "s_" + si_hash,
                   key: si
                      }, e('a', {
                        onMouseOver: function() {
                          if (si_plays !== null) {
                            a.displayTooltip("Plays: " + si_plays + "\nLast Played:" + si_last_played);
                          } else {
                            a.displayTooltip("Song was not recently played.");
                          }
                        },
                        onMouseOut: function() {
                          a.hideTooltip();
                        },
                        onClick: function() {
                          a.hideTooltip();
                          a.addToList("s_" + si_hash);
                        } //end onclick
                      }, si_title ) //end element <a>

               ) //end element <li>
             ) //end push... JS parens are exhausting
           } //end of else block (69)


         } // end if (selectedSongs) (60)
       } // end for loop
     } // end if (Array...)
       console.log("Songs collected: " + selectedSongs.length);
       a.setState({
         query: str,
         songs: selectedSongs
       });
     }) // ...then function response ...
     .catch(function(error) {
       console.log('ERROR! ' + error)
     })
   }
 }

 render() {
   return e(
     'div', {},
     e( // 1st child: input
       'input',
    { type: 'text',
      placeholder: 'Search for song to add...',
      value: this.state.query.value,
      onChange: (ev) => this.handleInputChange(ev)
    })
     , e( // 2nd child: select
      'ul', {
        className: 'click'
      }, this.state.songs
    )
    ,e( // 3rd child: tooltip
      'div', {
        id: 'song_tooltip_container',
        className: 'tooltip'
      }, e(
        'span', {
          id: 'song_tooltip',
          className: 'tooltiptext'
        }
      )
    ) // ...end of tooltip
  );
 }
}

// TODO: write something to fetch and parse playlist search (/search/blah)
const domContainer = document.querySelector('#search_section');
ReactDOM.render(e(Search), domContainer);
