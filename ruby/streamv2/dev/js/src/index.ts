//import './style.css';
//import Icon from './icon.png';
import * as ReactDOM from 'react-dom';
import * as React from 'react';
import Search from './app/Search';

const e = React.createElement;


ReactDOM.render(
  e(Search),
  document.getElementById('search_section')
);
