



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