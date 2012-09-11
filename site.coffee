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

  index: ->
    @figures().index(@currentFigure)

  next: ->
    @moveToFigure @nextFigure()
  prev: ->
    @moveToFigure @prevFigure()

  moveToFigure: (figure) ->
    previousOffset = @currentFigure.offset().left
    @currentFigure = figure
    deltaOffset = @currentFigure.offset().left - previousOffset
    @slideBy deltaOffset

  slideBy: (delta) ->
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

  transition: (link, e) ->
    e.preventDefault()
    unless link.hasClass 'disabled'
      method = link.attr('href').replace '#', ''
      filmStrip[method]()

      $('.scene-nav').find('a[href="#next"]').toggleClass 'disabled', !filmStrip.hasNext()
      $('.scene-nav').find('a[href="#prev"]').toggleClass 'disabled', !filmStrip.hasPrev()

      filmStrip.nextFigure().children('a[href^="#"]').attr 'href', '#next'
      filmStrip.prevFigure().children('a[href^="#"]').attr 'href', '#prev'
      if filmStrip.hasNext()
        filmStrip.currentFigure.children('a[href^="#"]').attr 'href', '#next'
      else
        filmStrip.currentFigure.children('a[href^="#"]').attr 'href', '#prev' # what when on last?

$ ->
  window.filmStrip = filmStrip = new FilmStrip('.filmstrip')

$(document).on 'click', '[href="#next"], [href="#prev"]', (e) ->
  filmStrip.transition $(this), e

  # hide popup if go to case study is target
  el = $(e.target).closest('.desc')
  if el.size()
    el.animate {opacity: 0, translate3d: '0,5px,0'}, 300, 'cubic-bezier(.6, .1, .2, .7)', ->
      el.remove()

