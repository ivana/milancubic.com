timerFunction = 'cubic-bezier(.6, .1, .2, .7)'
$.fx.speeds.medium = 300

$.fn.translateX = ->
  translateMatch = (this.css($.fx.cssPrefix + 'transform') || '').match(/\((-?\d+)/)
  if translateMatch then Number translateMatch[1] else 0

###
Description popup show / hide with animation
###
$(document).on 'click', '.desc h2 a', (e) ->
  el = $(e.target).closest('.desc')

  if el.hasClass 'popup'
    # hide description
    el.animate {opacity: 0, translate3d: '0,5px,0'}, 'medium', timerFunction, ->
      el.remove()
  else
    # show description
    oldEl = el
    el = el.clone()

    el.animate
      'z-index': Number(oldEl.css('z-index')) + 1
      'position': 'absolute'
      'margin-top': '0px'
      'opacity': 0.2
      translate3d: '0,-5px,0'
    , 0, null, ->
      el.insertBefore(oldEl).
        toggleClass('popup').
        animate({opacity: 1, translate3d: '0,0,0'}, 'medium', timerFunction)

  false

$(document).on 'click', '.desc a[href="#next"]', (e) ->
  e.preventDefault()
  filmStrip.next()

###
FilmStrip - helper class for prev / next transitioning
###

filmStrip = null

class FilmStrip
  constructor: (strip) ->
    @strip = $(strip)
    @currentFigure = @figures().first().addClass 'current' # current does not have the pointer cursor
    @currentPosition = 0

    @showLabels()
    @playVideo()

    @strip.on 'click', 'figure img, figure video', (e) =>
      targetFigure = $(e.target).closest('figure')
      if targetFigure.size()
        @moveToFigure targetFigure

  figures: ->
    @strip.find('figure')

  index: ->
    @figures().index(@currentFigure)

  moveToIndex: (index) ->
    @moveToFigure @figures().eq(index)

  next: ->
    @moveToFigure @nextFigure()
  prev: ->
    @moveToFigure @prevFigure()

  moveToFigure: (figure) ->
    return unless figure.size()

    # some figures may have a temporary offset in the "transform" property
    # because of shifts that showing cards cause
    tempOffset = figure.translateX()

    @hideCards() if @cardsVisible()
    @hideLabels()

    @currentFigure.removeClass 'current'
    previousOffset = @currentFigure.offset().left
    @currentFigure = figure
    @currentFigure.addClass 'current'

    deltaOffset = @currentFigure.offset().left - previousOffset - tempOffset
    @slideBy deltaOffset

    @showCards() if @isPhone()
    @showLabels()

    setTimeout =>
      @playVideo()
    , $.fx.speeds.medium

  slideBy: (delta) ->
    @strip.trigger('filmstrip:slide')
    @currentPosition -= delta
    @strip.animate { translate3d: "#{@currentPosition}px,0,0" }, 'medium', timerFunction

  hasPrev: ->
    @index() > 0

  hasNext: ->
    @index() < @figures().size() - 1

  prevFigure: ->
    @figures().eq(@index() - 1)

  nextFigure: ->
    @figures().eq(@index() + 1)

  # a collection of all figures left of the current one + current image/video
  leftElements: ->
    @figures().slice(0, @index()).add @currentFigure.find('img, video')

  # a collection of all figures right of the current one + current cards
  rightElements: ->
    @figures().slice(@index() + 1).add @currentFigure.find('figcaption > div')

  cardsVisible: ->
    @currentFigure.find('figcaption').css('opacity') > 0

  isPhone: ->
    @currentFigure.hasClass 'iPhone'

  currentLabels: ->
    @currentFigure.children('.show, .hide').add @currentFigure.prev('.desc')

  showLabels: ->
    @currentLabels().css(visibility: 'visible', opacity: 0).animate(opacity: 1 , 'medium', timerFunction)

  hideLabels: ->
    @currentLabels().animate opacity: 0, 'medium', timerFunction, ->
      $(this).css('visibility', 'hidden')

  showCards: ->
    # pull the cards up to align the top with figure image/video
    figureHeight = (@currentFigure.find('img, video').filter -> $(this).css('display') != 'none').height()
    @currentFigure.find('figcaption').css('margin-top', -figureHeight)

    # For iPhone, shift the right part of the filmstrip to the right.
    # For others, shift the left part of the filmstrip to the left.
    (if @isPhone() then @rightElements() else @leftElements()).animate
      translate3d: "#{if @isPhone() then '' else '-'}545px,0,0"
    , 'medium', timerFunction

    @currentFigure.find('figcaption').animate
      opacity: 1
    , 'medium', timerFunction

    @currentFigure.find('.cardwrapper').eq(1).animate
      translate3d: "-78px,0,0"
    , (if @isPhone() then 0 else 'medium'), timerFunction

    @currentFigure.find('.show a').animate
      translate3d: "-233px,0,0"
      opacity: 0
    , 'medium', timerFunction, ->
      $(this).hide()

    @currentFigure.find('.hide a').css({opacity: 0, display: 'inline-block'}).animate
      translate3d: "-233px,0,0"
      opacity: 1
    , 'medium', timerFunction

  hideCards: ->
    (if @isPhone() then @rightElements() else @leftElements()).animate
      translate3d: "0,0,0"
    , 'medium', timerFunction

    @currentFigure.find('figcaption').animate
      opacity: 0
    , 'medium', timerFunction

    if not @isPhone()
      @currentFigure.find('.cardwrapper').eq(1).animate
        translate3d: "0,0,0"
      , 'medium', timerFunction

    @currentFigure.find('.show a').css({display: 'inline-block'}).animate
      translate3d: "0,0,0"
      opacity: 1
    , 'medium', timerFunction

    @currentFigure.find('.hide a').animate
      translate3d: "0,0,0"
      opacity: 0
    , 'medium', timerFunction, ->
      $(this).hide()

  playVideo: ->
    video = @currentFigure.children('.desc + figure video')
    video.get(0).play() if video.size()


$ ->
  window.filmStrip = filmStrip = new FilmStrip('.filmstrip')

  if window.location.host is 'hammr.co'
    $('a[href="/"]').attr 'href', 'index.html'

$(document).on 'click', '.scene-nav a', (e) ->
  e.preventDefault()
  link = $(e.target)
  unless link.hasClass 'disabled'
    method = link.attr('href').replace '#', ''
    filmStrip[method]()

$(document).on 'filmstrip:slide', ->
  $('.desc.popup h2 a').trigger('click') # so popup can be hidden if open

  # keep buttons correctly displayed, depending on the slide position
  $('.scene-nav').find('a[href="#next"]').toggleClass 'disabled', !filmStrip.hasNext()
  $('.scene-nav').find('a[href="#prev"]').toggleClass 'disabled', !filmStrip.hasPrev()

$(document).on 'keydown', (e) ->
  # holding Shift pressed makes animations slower for debugging
  if e.keyCode is 16 # Shift
    $.fx.speeds.medium = 3000

# keyboard shortcuts
$(document).on 'keyup', (e) ->
  if e.keyCode is 37 # left arrow
    filmStrip.prev()
  else if e.keyCode is 39 # right arrow
    filmStrip.next()
  else if e.keyCode >= 49 and e.keyCode <= 57 # numbers from 1-9
    index = e.keyCode - 49
    filmStrip.moveToIndex index
  else if e.keyCode is 16 # Shift
    $.fx.speeds.medium = 300

###
Card swapping
###
$(document).on 'click', 'figure .card', (e) ->
  card = $(this)
  link = $(e.target).closest('.switch a', this)

  e.preventDefault() if link.size()

  if !card.parent().hasClass('focus') or link.size()
    swapCards card.closest('figcaption')

swapCards = (container) ->
  offset = 125
  deg = 50
  scale = .9

  cards = $(container).find('.card')
  backOpacity = cards.not('.focus .card').css('opacity')

  cards.each (i) ->
    card = $(this)
    first = i isnt 0
    losingFocus = card.parent().hasClass 'focus'

    card.animate
      rotateY: "#{ if first then '' else '-' }#{deg}deg"
      translate3d: "#{ if first then '-' else '' }#{offset}px,0,0"
      scale: scale
      opacity: .5
    , 'medium', timerFunction, ->
      card.parent().toggleClass 'focus'
      setTimeout ->
        card.animate
          rotateY: '0'
          translate3d: '0,0,0'
          scale: 1
          opacity: if losingFocus then backOpacity else 1
        , 'medium', timerFunction
      , 20

###
Show / hide cards
###
$(document).on 'click', '.show a, .hide a', (e) ->
  e.preventDefault()
  link = $(e.target)
  action = link.closest('p').attr('class')

  if action is 'show'
    filmStrip.showCards()
  else
    filmStrip.hideCards()


###
Video Use Cases
###
$(document).on 'click', '.focus .card li', (e) ->
  li = $(e.target).closest('li')
  li.closest('ol').children('li').removeClass 'active inactive'
  li.addClass 'active'
  li.siblings().addClass 'inactive'

  # play video by the position among its siblings (equals li position among its siblings)
  videos = $(e.target).closest('figure').children('video')
  videos.each (i) ->
    video = $(this)
    unless i is li.index()
      video.css('display', 'none')
    else
      v = video.css('display', 'block').get(0)
      v.play()
      video.on 'ended', (e) ->
        li.closest('ol').children('li').removeClass 'active inactive'

