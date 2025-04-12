import React from 'react';
import '@testing-library/jest-dom'
import userEvent from '@testing-library/user-event';

import { fireEvent, waitFor } from '@testing-library/react';

import { render, screen } from '@testing-library/react';
import EditAccountInfo from '../components/AccountInfo';
import { AccountInfo } from '../common/types-class';

test('renders account info component', async () => {
  
  let newAccount : AccountInfo | undefined;

  const captureChange = (ac : AccountInfo) => {
    newAccount = ac
  }
  const noop = () => {}
  const account : AccountInfo = {
    closed: false,
    sender_id: "22",
    account_number: "123",
    account_details: "some details",
    comments: "",
    json_class: "AccountInfo",
    id: "111"
  }
  render(
  <EditAccountInfo sender_id='22' info={account} onChange={captureChange} refreshCallback={noop}/>
);
// label htmlFor is for the form component with that id, not name #SIGH
expect(screen.getByLabelText(/Account number/i)).toBeInTheDocument()
const commentBox = screen.getByLabelText(/Comments/)
expect(commentBox).toBeInTheDocument()
// type some comments
userEvent.type(commentBox, "a comment from me")

// check the form knows about it
expect(newAccount?.comments).toContain("comment from me")

const linkElement = screen.getByRole('button', { name: /Update Account/i })
  expect(linkElement).toBeInTheDocument();
  fireEvent.click(linkElement);

  
});