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
    @currentFigure = @strip.find('figure').first()
    @currentPosition = 0

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

$ ->
  filmStrip = new FilmStrip('.filmstrip')

# next / previous slide
$(document).on 'click', 'a[href="#next"]:not(.disabled)', (e) ->
  filmStrip.next()
  # if filmStrip.isLast()
  #   disable next button
  false

$(document).on 'click', 'a[href="#prev"]', (e) ->
  filmStrip.prev()
  false
