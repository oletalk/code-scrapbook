'use strict';

const e = React.createElement;
const MAX_ITEM_LENGTH = 50;
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


 addRandomSongs = (num) => {
   var a = this;
   var selectedSongs = [];

   axios.get('/random/' + num)
   .then(function(response) {
     if (Array.isArray(response.data)) {
       for (let si = 0; si < response.data.length; si++) {
         let item = songFromJson(si, response.data[si]);
         //console.log(item);

         if (selectedSongs.length <= MAX_LIST_LENGTH) {

           let lineItemProps = {key: item.counter, containingSearch: a, dataSource: item};
           selectedSongs.push(
             e(LineItem, lineItemProps, null)
           )

         }

       }
     }
     a.setState({
       query: '',
       songs: selectedSongs
     });

   })
   .catch(function(error) {
     console.log('ERROR! ' + error)
   })
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
           let item = songFromJson(si, response.data[si]);

           if (selectedSongs.length <= MAX_LIST_LENGTH) {

             let lineItemProps = {key: item.counter, containingSearch: a, dataSource: item};
             selectedSongs.push(
               e(LineItem, lineItemProps, null)
             )

         }
       }
     }

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
 } // handleInputChange (function)

 render() {
   return e(
     'div', {},
     e( // 1st child: span (of inputs)
     'span', {},

       e( // 1st child: input
         'input',
          { type: 'text',
            placeholder: 'Search for song to add...',
            value: this.state.query.value,
            onChange: (ev) => this.handleInputChange(ev)
          }
        ),
        e(
          'input', {
            type: 'button',
            id: "randomBtn",
            onClick: (ev) => this.addRandomSongs(10),
            value: 'Random'
          }
        ), null

  )
     , e( // 2nd child: select
      'ul', {
        className: 'click'
      }, this.state.songs
    )
    ,e(TooltipBox, null, null)
  );
 }
}

class TooltipBox extends React.Component {
  render() {
    return e( // 3rd child: tooltip
      'div', {
        id: 'song_tooltip_container',
        className: 'tooltip'
      }, e(
        'span', {
          id: 'song_tooltip',
          className: 'tooltiptext'
        }
      )
    )
  }
}

class LineItem extends React.Component {
  render() {
    let item = this.props.dataSource;

    if (this.props.containingSearch.itemAlreadyInPlaylist('s_' + item.hash)) {
      // inactive one

      return e('li', {
        id: "s_" + item.hash,
      }, item.title )

    } else {
      // active one
      let linkProps = {song: item, containingSearch: this.props.containingSearch};

      return e('li', {
        id: "s_" + item.hash,
        className: "title_" + item.derived,
           },
           e(SongLink, linkProps, null)

      )

    }

  }
}

class SongLink extends React.Component {
  render() {
    let item = this.props.song;
    let search = this.props.containingSearch;
    return e('a', {
      onMouseOver: function() {
        if (item.plays !== undefined) {
          search.displayTooltip("Plays: " + item.plays + "\nLast Played:" + item.last_played);
        } else {
          search.displayTooltip("Song was not recently played.");
        }
      },
      onMouseOut: function() {
        search.hideTooltip();
      },
      onClick: function() {
        search.hideTooltip();
        search.addToList("s_" + item.hash);
      } //end onclick
    }, item.title )
  }
}

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
     plays: nonnull(songitem['plays']),
     last_played: nonnull(songitem['last_played']),
     derived: nonnull(songitem['title_derived'])
   };
   return item;
}

// TODO: write something to fetch and parse playlist search (/search/blah)
const domContainer = document.querySelector('#search_section');
ReactDOM.render(e(Search), domContainer);
