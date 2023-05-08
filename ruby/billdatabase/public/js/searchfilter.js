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
      trs[i].classList.remove('hidden')
    } else {
      trs[i].classList.add('hidden')
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

function updateDocumentsDates(dateFromEl, dateToEl) {
  const dfe = document.getElementById(dateFromEl).value
  const dte = document.getElementById(dateToEl).value

  console.log('from: ' + dfe + ', to: ' + dte)
  if (dfe == '' || dte == '') {
    alert('Please select both dates first')
  } else if (dfe > dte) {
    alert('End date should be after start date')
  } else {
    location.href = '/documents/' + dfe + '/' + dte
  }
}

function setQuarter(fromField, toField) {
  // today - 3 months, today
  let d = new Date()
  setField(toField, ymdStr(d))
  const mon = d.getMonth()
  const newMonth = (mon < 3 ? mon + 9 : mon - 3)
  d.setMonth(newMonth)
  setField(fromField, ymdStr(d))
  updateDocumentsDates(fromField, toField)
}

function setYear(fromField, toField) {
  // january 1, today
  let d = new Date()
  setField(toField, ymdStr(d))
  d.setDate(1)
  d.setMonth(1)
  setField(fromField, ymdStr(d))
  updateDocumentsDates(fromField, toField)
}

function setField(fldName, newval) {
  let field = document.getElementById(fldName)
  if (field != null) {
    field.value = newval
  } else {
    console.error('Could not find field ' + fldName)
  }
}
function ymdStr(d) {
  return d.toISOString().split('T')[0]
}