import React from 'react';
import '@testing-library/jest-dom'
import { waitFor } from '@testing-library/react';

import { render, screen } from '@testing-library/react';
import Main from './views/Main';
import { BrowserRouter } from 'react-router-dom'

test('renders learn react link', async () => {
  
  render(
    <BrowserRouter> 
  <Main />
  </BrowserRouter>);

  const linkElement = screen.getByText(/Maintain bills/i);
  expect(linkElement).toBeInTheDocument();
  await waitFor(() => {
    const paymentAlert = screen.getByText(/unpaid/i);
    expect(paymentAlert).toBeInTheDocument();
  })

});

// TODO: add a text that uses fetch
// more hints in https://kentcdodds.com/blog/stop-mocking-fetch