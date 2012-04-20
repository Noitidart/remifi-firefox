###
//
// @import lib/std
// @url    http://www.youtube.com
//
###

route "/", "index", ->
  action "doSearch"

route "/results", "results", ->
  action "doSearch"

route "/watch", "watch", ->
  action 'playPause'
  action 'startOver'
  action 'toggleFullscreen'

this.index = (request) ->
  searchForm()
  
  $('.feed-item-main').list (r) ->
    e = $(this)
    link = e.find('h4 a')
    img = e.find('.feed-item-thumb img')
    
    r.title = link.text()
    r.url   = link.attr('href')
    r.image = img.attr('data-thumb') || img.attr('src')

this.results = (request) ->
  pages = [
    {name: 'prev', url: externalURL($('#search-footer-box .yt-uix-pager-prev').attr('href'))},
    {name: 'next', url: externalURL($('#search-footer-box .yt-uix-pager-next').attr('href'))}
  ]
  
  searchForm()
  paginate(pages)
  
  $('#search-results > div.result-item').list (r) ->
    e = $(this)
    link = e.find('h3 a')
    img = e.find('.thumb-container img')
    
    r.title = link.text()
    r.url   = link.attr('href')
    r.image = img.attr('data-thumb') || img.attr('src')

  paginate(pages)

this.searchForm = () ->
  form 'doSearch', (f) ->
    f.br()
    f.fieldset ->
      f.search('q', {placeholder: 'YouTube Search', value: $('#masthead-search-term').val()})

this.doSearch = (request) ->
  document.location.href = 'http://www.youtube.com/results?search_query=' + encodeURIComponent(request.params.q)
  wait()

this.watch = (request) ->
  title($('#eow-title').attr('title'))
  
  unavailable = $('#unavailable-message')
  
  if unavailable.length > 0
    error(unavailable.find('.yt-alert-message').text())
    
  else
    p = player()
    color = player().isFullscreen ? 'primary' : null
    button('Play/Pause', 'playPause')
    button('Toogle Fullscreen', 'toggleFullscreen', {type: color})
    if (player().isFullscreen)
      button('Start Over', 'startOver', {disabled: 'Exit fullscreen first'})
    else
      button('Start Over', 'startOver')
  
  $('#watch-related > .video-list-item').list (r) ->
    e = $(this)
    img = e.find('.clip-inner img')
    
    r.title = e.find('.title').text()
    r.url   = e.find('a').attr('href')
    r.image = img.attr('data-thumb') || img.attr('src')

this.player = () ->
  player = new Player('#movie_player-flash,#movie_player,#movie_player-html5')
  
  if player.isFullscreen
    player.setBox({width: 'full', valign: 'bottom', height: 40})
    player.setSeek({x1: 5, x2: player.box.width, y: 0, delay: 500})
    player.setPlay({x: 35, y: 26, delay: 500})
  else
    player.setBox({width: 'full', valign: 'bottom', height: 35})
    player.setSeek({x1: 3, x2: player.box.width, y: 5, delay: 250})
    player.setPlay({x: 29, y: 25})
  
  player.setFullscreenOff({key: 'escape'})
  player.setFullscreenOn({align: 'right', x: 17, y: 23})
  
  player

this.playPause = (request) ->
  player().play()
  watch(request)

this.startOver = (request) ->
  player().seek(0)
  watch(request)

this.toggleFullscreen = (request) ->
  player().toggleFullscreen()
  watch(request)