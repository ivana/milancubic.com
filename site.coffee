# description popup show / hide with animation
$(document).on 'click', '.desc h2 a', (e) ->
  el = $(e.target).closest('.desc')

  if el.hasClass 'popup'
    # hide description
    el.animate {opacity: 0, translate3d: '0,5px,0'}, 300, 'cubic-bezier(.6, .1, .2, .7)', ->
      el.remove()
  else
    # show description
    oldEl = el
    el = el.clone().insertBefore oldEl

    properties =
      'z-index': oldEl.css('z-index') + 1
      'position': 'absolute'
      'margin-top': '0px'
      'opacity': 0.2
    properties["#{$.fx.cssPrefix}transform"] = 'translate3d(0,-5px,0)'
    el.css properties

    el.toggleClass('popup').animate({opacity: 1, translate3d: '0,0,0'}, 300, 'cubic-bezier(.6, .1, .2, .7)')

  false
