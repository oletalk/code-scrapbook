import { PostMessage } from "./types-class"

export async function doFetch<T> (
  url: string
) {
  let response = await fetch(url)
  handleFetchError(response)
  let ret : T = await response.json()

  return new Promise<T>((resolve) => {
    resolve(ret)
  })

}

// note - does not return any response body/json from the endpoint!
/** send an HTTP delete (no body) then perform a specified callback function */
export const doDelete = (url: string, callback: Function | undefined) => {
  fetch(url, {
    method: "DELETE"
  })
  .then((response) => {
    handleFetchError(response)
  })
  .then(() => {
    if (typeof callback !== 'undefined') {
      console.log('calling callback after delete')
      callback()
    }
  })
  .catch((err) => {
    console.error("Error occurred with delete: " + err)
  })

}

// note - does not return any response body/json from the endpoint!
/** POST a request then perform a specified callback function */
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
      handleFetchError(response)
    })
    .then(() => {
      if (doCallback) {
        console.log('calling callback for ' + callbackdescr)
        callback()
      }
    })
    .catch((err) => {
      console.error("Error occurred with post: " + err)
    })
}

/** POST a request then return a promise with either (a) a json with a message in a 'result' member, or (b) an error message.  */
export async function doPostAndReturnMessage (
  url: string, 
  postbody: object) {
  let response = await fetch(url,
    {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      method: "POST",
      body: JSON.stringify(postbody)
    })

    handleFetchError(response)
    let ret : PostMessage = await response.json()
      return new Promise<PostMessage>((resolve, reject) => {
        if (ret.result === 'success') {
          resolve(ret)
        }
        reject(ret.result)
      })  
  }

/** POST a request then return a promise with a JSON that serializes to a given object type.  */
export async function doPostAndReturn<T> (
  url: string, 
  postbody: object) {
  let response = await fetch(url,
    {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      method: "POST",
      body: JSON.stringify(postbody)
    })

    handleFetchError(response)
    let ret : T = await response.json()

    return new Promise<T>((resolve) => {
      resolve(ret)
    })
  }

export const doUpload = (url : string, fileinput : HTMLInputElement, callback: Function | undefined) => {
  // const file = document.getElementById(elementId).files[0]
  const file = fileinput?.files?.[0]
  if (typeof file === 'undefined') {
    alert('Please select a file to upload first!')
  } else {
    let formData = new FormData()

    formData.append('file', file)

    // POST - for this app url should be /document/<docId>/file
    //      - or /document/<docId>/remote
    fetch(url, {
      method: "POST",
      body: formData
    })
      .then((response) => {
        handleFetchError(response)
      })
      .then(() => {
        if (typeof callback !== 'undefined') {
          console.log('calling callback after upload')
          callback()
        }

      })
      .catch((error) => {
        console.error(error)
      })

  }
}


// const handleRtnOrError = (res: Response) => {
//   if (res.ok) {
//     return res.body
//   } else {
//     throw new Error('HTTP ' + res.status + ' response returned: ' + res.statusText)
//   }
// }
const handleFetchError = (res: Response) => {
  if (!res.ok) {
    throw new Error('HTTP ' + res.status + ' response returned: ' + res.statusText)
  }
}