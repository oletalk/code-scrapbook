var searchStyle = document.getElementById('search_style');
  //alert(searchStyle.innerHTML);
document.getElementById('srch').addEventListener('input', function() {
  if (!this.value) {
    searchStyle.innerHTML = "";
    return;
  }

  searchStyle.innerHTML = ".searchable:not([data-index*=\"" + this.value.toLowerCase() + "\"]) { display: none; }";
});

