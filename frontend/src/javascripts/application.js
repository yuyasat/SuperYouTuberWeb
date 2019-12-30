import $ from 'jquery';
import Swiper from 'swiper';

require('../../node_modules/font-awesome/css/font-awesome.css');

$(function () {
  $('[data-js="confirm"]').click(function () {
    if (confirm($(this).data('confirm'))) {
      return true;
    } else {
      return false;
    }
  });
});

$(function () {
  $('.j-open-search-panel-toggle').click(function (e) {
    $('.j-open-search-panel').toggleClass('is-hide');
    e.preventDefault();
  });

  if ($('.j-open-search-panel').data('default-show')) {
    var prevScrollTop = 0;
    $(window).scroll(function () {
      var scrollTop = $(document).scrollTop();
      if (prevScrollTop > scrollTop && scrollTop <= 100) {
        $('.j-open-search-panel').removeClass('is-hide');
      }
      prevScrollTop = scrollTop;
    });
  }
});

$(function () {
  new Swiper('.slider', {
    slideClass: 'slider__slide',
    wrapperClass: 'slider__wrapper',
    autoHeight: true,
    pagination: {
      el: '.slider__pagination',
      clickable: true,
    },
  });
});
