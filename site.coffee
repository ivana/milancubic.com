timerFunction = 'cubic-bezier(.6, .1, .2, .7)'

###
Description popup show / hide with animation
###
$(document).on 'click', '.desc h2 a', (e) ->
  el = $(e.target).closest('.desc')

  if el.hasClass 'popup'
    # hide description
    el.animate {opacity: 0, translate3d: '0,5px,0'}, 300, 'cubic-bezier(.6, .1, .2, .7)', ->
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
        animate({opacity: 1, translate3d: '0,0,0'}, 300, 'cubic-bezier(.6, .1, .2, .7)')

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
    @currentFigure = @figures().first().addClass 'current'
    @currentPosition = 0

    @strip.on 'click', 'figure img, figure video', (e) =>
      targetFigure = $(e.target).closest('figure')
      if targetFigure.size()
        @moveToFigure targetFigure

  figures: ->
    @strip.find('figure')

  index: ->
    @figures().index(@currentFigure)

  next: ->
    @moveToFigure @nextFigure()
  prev: ->
    @moveToFigure @prevFigure()

  moveToFigure: (figure) ->
    return unless figure.size()
    previousOffset = @currentFigure.offset().left

    @currentFigure.removeClass 'current'
    @currentFigure = figure
    @currentFigure.addClass 'current'

    deltaOffset = @currentFigure.offset().left - previousOffset
    @slideBy deltaOffset

  slideBy: (delta) ->
    @strip.trigger('filmstrip:slide')
    @currentPosition -= delta
    @strip.animate { translate3d: "#{@currentPosition}px,0,0" }, 300, 'cubic-bezier(.6, .1, .2, .7)'

  hasPrev: ->
    @index() > 0

  hasNext: ->
    @index() < @figures().size() - 1

  prevFigure: ->
    @figures().eq(@index() - 1)

  nextFigure: ->
    @figures().eq(@index() + 1)

$ ->
  window.filmStrip = filmStrip = new FilmStrip('.filmstrip')

$(document).on 'click', '.scene-nav a', (e) ->
  e.preventDefault()
  link = $(e.target)
  unless link.hasClass 'disabled'
    method = link.attr('href').replace '#', ''
    filmStrip[method]()

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
  duration = 300
  scale = .9

  cards = $(container).find('.card')
  backOpacity = cards.not('.focus .card').css('opacity')

  cards.each (i) ->
    card = $(this)
    first = i is 0
    losingFocus = card.parent().hasClass 'focus'

    card.animate
      rotateY: "#{ if first then '' else '-' }#{deg}deg"
      translate3d: "#{ if first then '-' else '' }#{offset}px,0,0"
      scale: scale
      opacity: .5
    , duration, timerFunction, ->
      card.parent().toggleClass 'focus'
      setTimeout ->
        card.animate
          rotateY: '0'
          translate3d: '0,0,0'
          scale: 1
          opacity: if losingFocus then backOpacity else 1
        , duration, timerFunction
      , 0

$(document).on 'filmstrip:slide', ->
  $('.desc.popup h2 a').trigger('click')

  $('.scene-nav').find('a[href="#next"]').toggleClass 'disabled', !filmStrip.hasNext()
  $('.scene-nav').find('a[href="#prev"]').toggleClass 'disabled', !filmStrip.hasPrev()

# keyboard shortcuts
$(document).on 'keyup', (e) ->
  if e.keyCode is 37 # left arrow
    filmStrip.prev()
  else if e.keyCode is 39 # right arrow
    filmStrip.next()
  else if e.keyCode >= 49 and e.keyCode <= 57 # numbers from 1-9
    index = e.keyCode - 49
    # move to figure with that position in the filmstrip
    filmStrip.moveToFigure $('.filmstrip figure').eq(index)
