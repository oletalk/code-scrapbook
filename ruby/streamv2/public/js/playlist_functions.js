'use strict';

const e = React.createElement;
const MAX_ITEM_LENGTH = 50;
const MAX_LIST_LENGTH = 30;

class Search extends React.Component {
 state = {
   query: '',
   songs: []
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

           selectedSongs.push(
             e(LineItem, {key: item.counter, dataSource: item}, null)
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

             selectedSongs.push(
               e(LineItem, {key: item.counter, dataSource: item}, null)
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

    if (itemAlreadyInPlaylist('s_' + item.hash)) {
      // inactive one

      return e('li', {
        id: "s_" + item.hash,
      }, item.title )

    } else {
      // active one

      return e('li', {
        id: "s_" + item.hash,
        className: "title_" + item.derived,
           },
           e(SongLink, {song: item}, null)

      )

    }

  }
}

class SongLink extends React.Component {
  render() {
    let item = this.props.song;
    return e('a', {
      onMouseOver: function(e) {
        positionTooltip(e);
        if (item.plays !== undefined) {


          displayTooltip("<b>Plays:</b> " + item.plays
          + "<br/><b>Last Played:</b>" + item.last_played
          + "<br/><b>Date added:</b>" + item.date_added);
        } else {
          displayTooltip("Song was not recently played.");
        }
      },
      onMouseOut: function() {
        hideTooltip();
      },
      onClick: function() {
        hideTooltip();
        addToList("s_" + item.hash);
      } //end onclick
    }, item.title )
  }
}




// TODO: write something to fetch and parse playlist search (/search/blah)
const domContainer = document.querySelector('#search_section');
ReactDOM.render(e(Search), domContainer);
