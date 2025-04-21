import React from 'react';
import '@testing-library/jest-dom'
import { waitFor } from '@testing-library/react';
import { fakeAccount } from '../testdata/fakedata';
import { render, screen } from '@testing-library/react';
import AccountSelectBox from '../components/AccountSelectBox';
import { BrowserRouter } from 'react-router-dom'
import { AccountInfo } from '../common/types-class';
import { CaptureUtils } from '../testdata/captureutils';

const utils = new CaptureUtils<AccountInfo>()

test('dropdown with no accounts available', async () => {
  // TODO fix bug where no items but still showing select box...
  render(
    <BrowserRouter> 
  <AccountSelectBox 
  selectName='test_sa_dropdown'
  selectedItem='10'
  changeCallback={(id) => utils.capture('ac_info', id)}
  itemList={[]}
  noItemMessage='no items available'
  />
  </BrowserRouter>);
await new Promise(process.nextTick);

  const linkElement = screen.getByText(/no items available/i);
  expect(linkElement).toBeInTheDocument();

});

test('dropdown with a few accounts', async () => {
  // TODO fix bug where no items but still showing select box...
  render(
    <BrowserRouter> 
  <AccountSelectBox 
  selectName='test_sa_dropdown'
  selectedItem='10'
  changeCallback={(id) => utils.capture('ac_info', id)}
  itemList={[
    fakeAccount('123456', '10', '3'),
    fakeAccount('342433', '11', '3')
    
  ]}
  noItemMessage='no items available'
  />
  </BrowserRouter>);
await new Promise(process.nextTick);

  const linkElement = screen.getByRole('option', {name:'342433'});
  expect(linkElement).toBeInTheDocument();

});