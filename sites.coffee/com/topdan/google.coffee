###
//
// @import lib/std
// @domain www.google.com
//
###

route '/', 'index', ->
  action 'doSearch'

route '/search', 'search'

@index = ->
  br()
  br()
  
  form 'doSearch', (f) ->
    f.fieldset ->
      f.search 'q', {placeholder: 'Google Search'}
    
    f.br()
    f.br()
    
    f.submit('Google Search')

@doSearch = (request) ->
  document.location.href = 'http://www.google.com/search?q=' + encodeURIComponent(request.params.q) + '&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a'
  wait()

@search = ->
  title($('title').text())
  
  $('#rso li.g').list (r) ->
    e = $(this)
    
    r.titleURL = e.find('h3 a')
    r.image = e.find('img').attr('src')
    # throw r.img if r.img
    
    cite = $(this).find('cite').text()
    cite = cite.match(/http:\/\/([^\/]*)/) || cite.match(/([^\/]*)/) if cite
    r.subtitle = cite[1] if cite
  , imageInternalURL: true
  
  paginate([
    {name: 'prev', url: externalURL($('#pnprev').attr('href'))},
    {name: 'next', url: externalURL($('#pnnext').attr('href'))}
  ])
