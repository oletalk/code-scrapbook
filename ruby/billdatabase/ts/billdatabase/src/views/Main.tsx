import React from "react";
import { Link } from 'react-router-dom';

export default class Main extends React.Component {

  render() {
    return (
      <div className="App">
      <div className="std-list">
      <h1>Maintain bills/payments</h1>
      <div>
        View/search for ...
        <ul>
          <li>Payments</li>
          <li><Link to="/documents">All documents</Link></li>
          <li>Contact a Sender...</li>
          <li>List of document types</li>
        </ul>
      </div>

      <div>
        Maintain list of ...
        <ul>
          <li><Link to="/senders">Senders</Link></li>
          <li><Link to="/taglist">Tags</Link></li>
        </ul>
      </div>

      <div>
        Add new ...
        <ul>
          <li><Link to="/document_new">Document</Link></li>
          <li>Sender</li>
        </ul>
      </div>

    </div>
    </div>
    )
  }
}