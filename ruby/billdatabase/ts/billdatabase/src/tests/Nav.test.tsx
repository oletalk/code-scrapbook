import React from 'react';
import '@testing-library/jest-dom'

import { render, screen } from '@testing-library/react';
import Nav from '../components/Nav'
import { NavType } from '../common/types-class';
import { BrowserRouter } from 'react-router-dom'

test('renders link on edit document page', async () => {
  
  render(
    <BrowserRouter> 
  <Nav page={NavType.EditDocument} />
  </BrowserRouter>);

  // expect(screen.getByText(/Documents/i)).toBeInTheDocument();
  expect(screen.getByRole('link', {name:"Documents"})).toBeInTheDocument();
  expect(screen.getByText(/Edit Document/i)).toBeInTheDocument();

});

test('renders path to senders page', async () => {
  
  render(
    <BrowserRouter> 
  <Nav page={NavType.Senders} />
  </BrowserRouter>);

  expect(screen.getByText(/Senders/i)).toBeInTheDocument();

});