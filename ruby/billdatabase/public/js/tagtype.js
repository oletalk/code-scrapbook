function updateColor(tag_id, color) {
  const color_val = document.getElementById(color).value
  console.log('updating color for tag ' + tag_id + ' to ' + color_val)
  const data = {
    color: color_val
  }
  axios.post('/tagtype/' + tag_id, data)
    .then((response) => reloadOrPrintError(response, 'updating tag type'))
    .catch((error) => {
      console.error(error)
    })

}