//import './style.css';
//import Icon from './icon.png';
import ReactDOM from 'react-dom';
import React from 'react';
import Search from './app/Search.jsx';
// ---
// ---
const e = React.createElement;


ReactDOM.render(
  e(Search, {}),
  document.getElementById('search_section')
);
