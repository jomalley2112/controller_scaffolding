function set_per_page(sel) {
    url = updateQueryStringParameter($(location).attr('href'), "per_page", $(sel).val())
    window.location = updateQueryStringParameter(url, "page", "1")
}

function updateQueryStringParameter(uri, key, value) {
  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + "=" + value + '$2');
  }
  else {
    return uri + separator + key + "=" + value;
  }
}