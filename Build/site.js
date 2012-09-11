
/*
Description popup show / hide with animation
*/


(function() {
  var FilmStrip, filmStrip;

  $(document).on('click', '.desc h2 a', function(e) {
    var el, oldEl;
    el = $(e.target).closest('.desc');
    if (el.hasClass('popup')) {
      el.animate({
        opacity: 0,
        translate3d: '0,5px,0'
      }, 300, 'cubic-bezier(.6, .1, .2, .7)', function() {
        return el.remove();
      });
    } else {
      oldEl = el;
      el = el.clone();
      el.animate({
        'z-index': Number(oldEl.css('z-index')) + 1,
        'position': 'absolute',
        'margin-top': '0px',
        'opacity': 0.2,
        translate3d: '0,-5px,0'
      }, 0, null, function() {
        return el.insertBefore(oldEl).toggleClass('popup').animate({
          opacity: 1,
          translate3d: '0,0,0'
        }, 300, 'cubic-bezier(.6, .1, .2, .7)');
      });
    }
    return false;
  });

  /*
  FilmStrip - helper class for prev / next transitioning
  */


  filmStrip = null;

  FilmStrip = (function() {

    function FilmStrip(strip) {
      this.strip = $(strip);
      this.currentFigure = this.figures().first();
      this.currentPosition = 0;
    }

    FilmStrip.prototype.figures = function() {
      return this.strip.find('figure');
    };

    FilmStrip.prototype.next = function() {
      return this.moveToFigure(this.currentFigure.next());
    };

    FilmStrip.prototype.prev = function() {
      return this.moveToFigure(this.currentFigure.prev());
    };

    FilmStrip.prototype.moveToFigure = function(figure) {
      var deltaOffset, previousOffset;
      previousOffset = this.currentFigure.offset().left;
      this.currentFigure = figure;
      deltaOffset = this.currentFigure.offset().left - previousOffset;
      return this.slideBy(deltaOffset);
    };

    FilmStrip.prototype.slideBy = function(delta) {
      this.currentPosition -= delta;
      return this.strip.animate({
        translate3d: "" + this.currentPosition + "px,0,0"
      }, 300, 'cubic-bezier(.6, .1, .2, .7)');
    };

    FilmStrip.prototype.hasPrev = function() {
      return this.figures().index(this.currentFigure) > 0;
    };

    FilmStrip.prototype.hasNext = function() {
      return this.figures().index(this.currentFigure) < this.figures().size() - 1;
    };

    FilmStrip.prototype.transition = function(link, e) {
      var currentFigure, method;
      e.preventDefault();
      if (!link.hasClass('disabled')) {
        method = link.attr('href').replace('#', '');
        filmStrip[method]();
        $('.scene-nav').find('a[href="#next"]').toggleClass('disabled', !filmStrip.hasNext());
        $('.scene-nav').find('a[href="#prev"]').toggleClass('disabled', !filmStrip.hasPrev());
        currentFigure = filmStrip.currentFigure;
        currentFigure.next().children('a[href^="#"]').attr('href', '#next');
        currentFigure.prev().children('a[href^="#"]').attr('href', '#prev');
        if (filmStrip.hasNext()) {
          return currentFigure.children('a[href^="#"]').attr('href', '#next');
        } else {
          return currentFigure.children('a[href^="#"]').attr('href', '#');
        }
      }
    };

    return FilmStrip;

  })();

  $(function() {
    return window.filmStrip = filmStrip = new FilmStrip('.filmstrip');
  });

  $(document).on('click', '[href="#next"], [href="#prev"]', function(e) {
    var el;
    filmStrip.transition($(this), e);
    el = $(e.target).closest('.desc');
    if (el.length) {
      return el.animate({
        opacity: 0,
        translate3d: '0,5px,0'
      }, 300, 'cubic-bezier(.6, .1, .2, .7)', function() {
        return el.remove();
      });
    }
  });

}).call(this);
