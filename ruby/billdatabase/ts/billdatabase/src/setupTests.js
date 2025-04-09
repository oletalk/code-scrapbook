const BASEURL = 'http://localhost:4567'

async function mockFetch(url, config) {
	switch (url) {
    case BASEURL + '/payments': {
      return {
				ok: true,
				status: 200,
				json: async () => (
          [
            {
              "name":"MacFie & Co",
              "summary":"Quarterly Common Charges from 01/06 to 31/08",
              "due_date":"2024-09-09",
              "paid_date":"",
              "document_id":"35",
              "status":"unpaid"
            }
          ]
         ),
      }
    }
		default: {
			throw new Error(`Unhandled request: ${url}`)
		}
	}
}

beforeAll(() => jest.spyOn(window, 'fetch'))
beforeEach(() => window.fetch.mockImplementation(mockFetch))