import { getAllSendersWithTags, getMainScreenPayments, getTags,
  getSenderDocuments, getADocument,
  simpleOkResponse, OkResponse } from './testdata/payloads'
import { vi } from 'vitest'
import { create } from 'domain'

const BASEURL = 'http://localhost:4567'

function mockFetchBody(url) {
  console.log('[setupTests]: url = ' + url)
	switch (url) {
    case BASEURL + '/sendertag/22/2': { // delete tag test case
      return {}
    }
    case BASEURL + '/sendertag/22/3': { // add tag test case
      return {}
    }
    case BASEURL + '/document/23': { // view a document
      return getADocument()
    }
    case BASEURL + '/senderaccount/111': { // save sender account
      return {}
    }
    case BASEURL + '/payments': { // payment check on main page
      return getMainScreenPayments()
    }

    case BASEURL + '/tags': { // get tags
      return getTags()
    }

    case BASEURL + '/json/sendertags': {
      return getAllSendersWithTags()
    }
    case BASEURL + '/json/sender/10/documents': {
      return getSenderDocuments()
    }
		default: {
			throw new Error(`Unhandled request: ${url}`)
		}
	}
}

// beforeAll(() => jest.spyOn(window, 'fetch'))
// beforeEach(() => window.fetch.mockImplementation(mockFetch))

beforeEach(() => {
  global.fetch = vi.fn((url) =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve(
        mockFetchBody(url)
      ),
    }),
  );
}
)