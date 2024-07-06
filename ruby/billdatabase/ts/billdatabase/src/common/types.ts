



export const isBlank = (str: Object) => {
  if (typeof str == 'undefined') {
    return true
  } else if (typeof str == 'string') {
    if (str.trim() === '') {
      return true
    } else {
      return false
    }
  }
  return false
}

export const nullSafeContains = (outer: string, inner: string) : boolean => {
  if (outer === null) {
    return inner === null
  }
  if (typeof outer === 'undefined') {
    return typeof inner === 'undefined'
  }
  if (outer.length > 0) {
    let outerCmp = outer.toLocaleUpperCase()
    let innerCmp = inner.toLocaleUpperCase()
    return outerCmp.indexOf(innerCmp) !== -1
  }
  return false
}

export const toDateString = (dte: Date) => {
  console.log(dte)
  console.log(typeof dte)
  return ''
  // let ret: string = dte.toISOString()
  // return ret.split('T')[0]
}