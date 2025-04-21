import { getAllSendersWithTags, getMainScreenPayments, getTags,
  getSenderDocuments, getADocument,
  simpleOkResponse, OkResponse } from './testdata/payloads'

const BASEURL = 'http://localhost:4567'

async function mockFetch(url, config) {
	switch (url) {
    case BASEURL + '/sendertag/22/2': { // delete tag test case
      return simpleOkResponse()
    }
    case BASEURL + '/sendertag/22/3': { // add tag test case
      return simpleOkResponse()
    }
    case BASEURL + '/document/23': { // view a document
      return OkResponse(getADocument())
    }
    case BASEURL + '/senderaccount/111': { // save sender account
      return simpleOkResponse()
    }
    case BASEURL + '/payments': { // payment check on main page
      return OkResponse(getMainScreenPayments())
    }

    case BASEURL + '/tags': { // get tags
      return OkResponse(getTags)
    }

    case BASEURL + '/json/sendertags': {
      return OkResponse(getAllSendersWithTags())
    }
    case BASEURL + '/json/sender/10/documents': {
      return OkResponse(getSenderDocuments())
    }
		default: {
			throw new Error(`Unhandled request: ${url}`)
		}
	}
}

beforeAll(() => jest.spyOn(window, 'fetch'))
beforeEach(() => window.fetch.mockImplementation(mockFetch))