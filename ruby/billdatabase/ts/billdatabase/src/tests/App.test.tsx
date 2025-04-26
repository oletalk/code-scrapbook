import { expect } from 'vitest'
import { waitFor } from '@testing-library/react';

import { render, screen } from '@testing-library/react';
import Main from '../views/Main';
import { act } from 'react'
import { BrowserRouter } from 'react-router-dom'
import ReactDOM from 'react-dom/client';

test('renders learn react link', async () => {
  
// i get warned 'await has no effect' but it actually waits for the 
// render and the test passes, so meh
await act(() => {
        render(
      <BrowserRouter> 
    <Main />
    </BrowserRouter>)

  }
)

  
await new Promise(process.nextTick);

await waitFor(() => {
  const linkElement = screen.getByText(/Maintain bills/i);
  expect(linkElement).toBeInTheDocument();

})

  const paymentAlert = screen.getByText(/unpaid/i);
    expect(paymentAlert).toBeInTheDocument();


});
