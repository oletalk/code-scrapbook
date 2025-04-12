import React from 'react';
import '@testing-library/jest-dom'
import { fireEvent, waitFor } from '@testing-library/react';

import { TagObject } from '../common/types-class';
import { render, screen } from '@testing-library/react';
import FilterByTag from '../components/TagFilter';

test('renders tag filtering component', async () => {
  
  const taglist : TagObject[] = [
    {
      "changed": false,
      "json_class": "SenderTag",
      "id": "2",
      "description": "second",
      "color": "#00ff00"
    },
    {
      "changed": false,
      "json_class": "SenderTag",
      "id": "1",
      "description": "first",
      "color": "#ff0000"
    }
  ]
  
  let tagsIdToFilter : string[] = []

  const captureArgs = (activeIds : string[]) => {
    tagsIdToFilter = activeIds
  }

  render(
  <FilterByTag tags={taglist} filterCallbackOn={captureArgs}/>
);

// click 'second' tag --> filter on second tag type
  const linkElement = screen.getByRole('button', { name: /second/i });
  expect(linkElement).toBeInTheDocument();
  fireEvent.click(linkElement);
  expect(tagsIdToFilter).toStrictEqual(['2'])

  // click 'first' tag --> filter on first and second tag types

  const linkElement2 = screen.getByRole('button', { name: /first/i });
  expect(linkElement2).toBeInTheDocument();
  fireEvent.click(linkElement2);
  expect(tagsIdToFilter).toStrictEqual(['2', '1'])

  // click 'second' tag --> should now filter on just first tag type
  fireEvent.click(linkElement);
  expect(tagsIdToFilter).toStrictEqual(['1'])

    // click 'first' tag --> should now not filter on anything
    fireEvent.click(linkElement2);
    expect(tagsIdToFilter).toStrictEqual([])
  
});