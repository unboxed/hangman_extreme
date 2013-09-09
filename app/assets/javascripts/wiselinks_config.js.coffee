$(document).ready ->
  window.wiselinks = new Wiselinks($('div#wrap'))

  $(document).off('page:done').on(
    'page:done'
    (event, $target, status, url, data) ->
      _gaq.push(['_trackPageview', url])
  )
