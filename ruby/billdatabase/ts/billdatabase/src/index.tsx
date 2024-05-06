import React from 'react'
import ReactDOM from 'react-dom/client';

import { BrowserRouter as Router, Route, Routes } from 'react-router-dom'

import './index.css'

import Main from './views/Main'
import MaintainTags from './views/MaintainTags'
// import NotFound from './views/NotFound'

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
    <Router>
        <Routes>
        <Route path="/" element={<Main/>}/>
        <Route path="/taglist" element={<MaintainTags/>}/>
        <Route path="*" element={<Main/>}/>
        </Routes>
    </Router>
);
