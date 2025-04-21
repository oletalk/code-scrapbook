import React from 'react';
import '@testing-library/jest-dom'
import { waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import { render, screen } from '@testing-library/react';
import EditField from '../components/EditField';
import { CaptureUtils } from '../testdata/captureutils'
import { DocumentInfo, emptyDocument } from '../common/types-class';

const utils = new CaptureUtils<Object>()

test('renders edit field for a property', async () => {
  
  let docInfo : DocumentInfo = emptyDocument()
  docInfo.summary = 'hello there'
  
  render(
  <EditField 
  initialValue={docInfo.summary}
  fieldType='text'
  fieldName='summary'
  changeCallback={(kv) => utils.capture('summaryfield', kv)}/>
  )
await new Promise(process.nextTick);

  const linkElement = screen.getByRole('textbox');
  expect(linkElement).toBeInTheDocument();
  userEvent.type(linkElement, ', more text')
  await waitFor(() => {
    // expect(captured).toStrictEqual({'summary': 'hello there, more text'});
    expect(utils.getCaptured('summaryfield')).toStrictEqual({'summary': 'hello there, more text'});
  })

});
