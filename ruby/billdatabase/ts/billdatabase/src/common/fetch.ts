export const doPost = (
  url: string, 
  postbody: object,
  doCallback: boolean, callback: Function, callbackdescr: string) => {
  fetch(url,
    {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      method: "POST",
      body: JSON.stringify(postbody)
    })
    .then((response) => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
    })
    .then((json) => {
      console.log(json)
      if (doCallback) {
        console.log('calling callback for ' + callbackdescr)
        callback()
      }
    })
}