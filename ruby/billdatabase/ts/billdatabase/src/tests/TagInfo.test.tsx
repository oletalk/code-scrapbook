import React from 'react';
import '@testing-library/jest-dom'
import { fireEvent } from '@testing-library/react';

import { render, screen } from '@testing-library/react';
import TagInfo from '../components/TagInfo';
import { TagObject } from '../common/types-class';

// TEST DATA FOR ALL CASES
const test_taglist : TagObject[] = [
  { changed: false, json_class: 'TagObject', id: '1', description: 'first', color: '#ff0000' },
  { changed: false, json_class: 'TagObject', id: '2', description: 'second', color: '#00ff00' }
]

const all_taglist : TagObject[] = [
  { changed: false, json_class: 'TagObject', id: '1', description: 'first', color: '#ff0000' },
  { changed: false, json_class: 'TagObject', id: '2', description: 'second', color: '#00ff00' },
  { changed: false, json_class: 'TagObject', id: '3', description: 'third', color: '#0000ff' }
]

test('deletes an existing tag', async () => {

  render(
  <TagInfo sender_id='22' info={test_taglist} taglist={all_taglist}/>
  );
  // look for the second tag and click it
  const linkElement = screen.getByRole('button', { name: /second/i });
  expect(linkElement).toBeInTheDocument();
  fireEvent.click(linkElement);
  // it should fire a DELETE request at the url setup in setupTests.js

  /* await waitFor(() => {
    const paymentAlert = screen.getByText(/unpaid/i);
    expect(paymentAlert).toBeInTheDocument();
  }) */

});

test('adds a new tag', async () => {

  render(
  <TagInfo sender_id='22' info={test_taglist} taglist={all_taglist}/>
  );
  // open the tag menu
  const addBtn = screen.getByRole('button', { name: /(add)/i });
  expect(addBtn).toBeInTheDocument();
  fireEvent.click(addBtn);
  // look for the third tag and click it
  const linkElement = screen.getByText(/third/);
  expect(linkElement).toBeInTheDocument();
  fireEvent.click(linkElement);

});