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
  filmStrip.next()

###
FilmStrip - helper class for prev / next transitioning
###

filmStrip = null

class FilmStrip
  constructor: (strip) ->
    @strip = $(strip)
    @currentFigure = @figures().first()
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
    previousOffset = @currentFigure.offset().left
    @currentFigure = figure
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
  link = $(e.target)
  unless link.hasClass 'disabled'
    method = link.attr('href').replace '#', ''
    filmStrip[method]()

$(document).on 'filmstrip:slide', ->
  $('.desc.popup h2 a').trigger('click')

  $('.scene-nav').find('a[href="#next"]').toggleClass 'disabled', !filmStrip.hasNext()
  $('.scene-nav').find('a[href="#prev"]').toggleClass 'disabled', !filmStrip.hasPrev()
