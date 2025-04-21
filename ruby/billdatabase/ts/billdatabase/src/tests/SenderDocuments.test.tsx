import React from 'react';
import '@testing-library/jest-dom'
import { fireEvent, waitFor } from '@testing-library/react';

import { render, screen } from '@testing-library/react';
import SenderDocuments from '../components/SenderDocuments';
import { BrowserRouter } from 'react-router-dom'

test('renders learn react link', async () => {
  
  render(
    <BrowserRouter> 
  <SenderDocuments sender_id='10'/>
  </BrowserRouter>);

// the screen loads documents for this sender
// see payloads.js for payload details...
await waitFor(() => {
  expect(screen.getByText(/Invoice 459/i)).toBeInTheDocument();
})
// look for and then click on one of the documents
const linkElement = screen.getByRole('link', {name: '2025-03-05'});

await waitFor(() => {
  expect(linkElement).toBeInTheDocument();
  // expect(screen.getByRole('link', {name: 'Invoice 234'})).toBeInTheDocument();  
})
fireEvent.click(linkElement);


});

// TODO: add a text that uses fetch
// more hints in https://kentcdodds.com/blog/stop-mocking-fetch