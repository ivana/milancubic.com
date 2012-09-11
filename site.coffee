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

###
FilmStrip - helper class for prev / next transitioning
###

filmStrip = null

class FilmStrip
  constructor: (strip) ->
    @strip = $(strip)
    @currentFigure = @figures().first()
    @currentPosition = 0

  figures: ->
    @strip.find('figure')

  next: ->
    @moveToFigure @currentFigure.next()
  prev: ->
    @moveToFigure @currentFigure.prev()

  moveToFigure: (figure) ->
    previousOffset = @currentFigure.offset().left
    @currentFigure = figure
    deltaOffset = @currentFigure.offset().left - previousOffset
    @slideBy deltaOffset

  slideBy: (delta) ->
    @currentPosition -= delta
    @strip.animate { translate3d: "#{@currentPosition}px,0,0" }, 300, 'cubic-bezier(.6, .1, .2, .7)'

  hasPrev: ->
    @figures().index(@currentFigure) > 0

  hasNext: ->
    @figures().index(@currentFigure) < @figures().size() - 1

  transition: (link, e) ->
    e.preventDefault()
    method = link.attr('href').replace '#', ''
    if not link.hasClass 'disabled' or method in ['next', 'prev'] # buttons
      filmStrip[method]()

      $('.scene-nav').find('a[href="#next"]').toggleClass 'disabled', !filmStrip.hasNext()
      $('.scene-nav').find('a[href="#prev"]').toggleClass 'disabled', !filmStrip.hasPrev()

      currentFigure = filmStrip.currentFigure
      currentFigure.children('a[href^="#"]').attr 'href', '#next'
      currentFigure.next().children('a[href^="#"]').attr 'href', '#next'
      currentFigure.prev().children('a[href^="#"]').attr 'href', '#prev'

$ ->
  window.filmStrip = filmStrip = new FilmStrip('.filmstrip')

$(document).on 'click', '.scene-nav a, figure a[href^="#"]', (e) ->
  filmStrip.transition $(this), e

