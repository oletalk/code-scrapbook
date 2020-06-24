'use strict';
const e = React.createElement;

class Search extends React.Component {
 state = {
   query: '',
   songs: []
 }

 handleInputChange = (ev) => {
   var a = this;
   var str = ev.target.value;
   var selectedSongs = [];
   if (str.length > 3) {
     console.log(str);
     axios.get('/search/' + str)
     .then(function (response) {
       if (Array.isArray(response.data)) {
         for (let si = 0; si < response.data.length; si++) {
           let songitem = response.data[si];
           selectedSongs.push(
             e('option', { 
               value: songitem['hash'],
               key: si
             }, songitem['title'])
           );
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
 }

 render() {
   return e(
     'div', {},
     e( // 1st child: input
       'input',
    { type: 'text',
      placeholder: 'Type partial search',
      value: this.state.query.value,
      onChange: (ev) => this.handleInputChange(ev)
    })
     , e( // 2nd child: select
      'select', {}, this.state.songs // TODO: add children!
    )
  );
 }
}

// TODO: write something to fetch and parse playlist search (/search/blah)
const domContainer = document.querySelector('#search_section');
ReactDOM.render(e(Search), domContainer);
