// Generated by CoffeeScript 1.8.0
(function() {
  var deepCopy, getValScope, strCopy, _Carousel;

  getValScope = function(val, scope) {
    if (scope[0] > val) {
      return scope[0];
    } else if (scope[1] < val) {
      return scope[1];
    }
    return val;
  };

  strCopy = function(s, n) {
    var i, res;
    res = "";
    i = 0;
    while (i < n) {
      i += 1;
      res += s;
    }
    return res;
  };

  deepCopy = function(v) {
    return $.extend(true, [], v);
  };

  _Carousel = (function() {
    function _Carousel(_at_elem) {
      this.elem = _at_elem;
    }

    _Carousel.prototype.start = function() {
      return this.elem.carousel("cycle");
    };

    _Carousel.prototype.pause = function() {
      return this.elem.carousel("pause");
    };

    _Carousel.prototype.go = function(num) {
      return this.elem.carousel(num);
    };

    _Carousel.prototype.next = function() {
      return this.elem.carousel("next");
    };

    _Carousel.prototype.prev = function() {
      return this.elem.carousel("prev");
    };

    _Carousel.prototype.hideControls = function() {
      this.elem.find(".carousel-control").fadeOut(500);
      this.elem.find(".carousel-indicators").fadeOut(500);
      return void 0;
    };

    _Carousel.prototype.showControls = function() {
      this.elem.find(".carousel-control").fadeIn(500);
      this.elem.find(".carousel-indicators").fadeIn(500);
      return void 0;
    };

    _Carousel.prototype.overflow = function(st) {
      return this.elem.css({
        "overflow": st
      });
    };

    return _Carousel;

  })();

  window.getValScope = getValScope;

  window.strCopy = strCopy;

  window.deepCopy = deepCopy;

  window._Carousel = _Carousel;

}).call(this);

//# sourceMappingURL=other.js.map
