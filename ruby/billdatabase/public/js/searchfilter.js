function quickFilter(searchStr) {
  // main table id is 'alldocuments'
  if (searchStr.length > 1) {
    filterSearchTrs(searchStr, 'alldocuments')
  } else {
    // make sure all are shown
    filterSearchTrs('', 'alldocuments')
  }
}

function filterSearchTrs(searchStr, tblid) {
  // check type[1], sender[2], summary[6]
  let tbl = document.getElementById(tblid)
  let trs = tbl.getElementsByTagName('tr')
  for (let i = 1; i < trs.length; i++) {
    // let td = trs[i].getElementsByTagName('td')[0]
    const docTypeMatch = columnContains(trs[i], 1, searchStr)
    const senderMatch = columnContains(trs[i], 2, searchStr)
    const summaryMatch = columnContains(trs[i], 6, searchStr)
    if (docTypeMatch || senderMatch || summaryMatch) {
      trs[i].style.display = ''
    } else {
      trs[i].style.display = 'none'
    }
  }
}

function columnContains(row, colno, searchStr) {
  let ret = false
  let td = row.getElementsByTagName('td')[colno]
  if (td) {
    // given the column number, find the text content and search for searchStr
    const txtValue = td.textContent || td.innerText
    if (txtValue.toUpperCase().indexOf(searchStr.toUpperCase()) > -1) {
      ret = true
    }
  }
  return ret
}