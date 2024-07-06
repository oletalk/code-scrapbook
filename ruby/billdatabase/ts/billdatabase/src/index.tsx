// import React from 'react'
import ReactDOM from 'react-dom/client';

import { HashRouter as Router, Route, Routes } from 'react-router-dom'

import './index.css'
import './css/taglist.css'
import './css/tooltip.css'
import './css/default.css'
import './css/payments.css'

import Main from './views/Main'
import MaintainTags from './views/MaintainTags'
import ViewSenders from './views/ViewSenders'
import EditSender from './views/EditSender'
import EditDocument from './views/EditDocument'
import ViewDocuments from './views/ViewDocuments'

// import NotFound from './views/NotFound'

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
    <Router>
        <Routes>
        <Route path="/" element={<Main/>}/>
        <Route path="/taglist" element={<MaintainTags/>}/>
        <Route path="/senders" element={<ViewSenders/>}/>
        <Route path="/sender/:id" element={<EditSender /> } />
        <Route path="/documents" element={<ViewDocuments /> } />
        <Route path="/document/:id" element={<EditDocument /> } />
        <Route path="*" element={<Main/>}/>
        </Routes>
    </Router>
);
