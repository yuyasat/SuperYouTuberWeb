require('../../node_modules/font-awesome/css/font-awesome.css')

import $ from 'jquery'
import Swiper from 'swiper'

$(function() {
  $('[data-js="confirm"]').click(function() {
    if (confirm($(this).data('confirm'))) {
      return true;
    } else {
      return false;
    }
  });
});

$(function() {
  $('.j-open-search-panel-toggle').click(function(e){
    $('.j-open-search-panel').toggleClass('is-hide');
    e.preventDefault();
  });
});

$(function(){
  new Swiper('.slider',{
    slideClass: 'slider__slide',
    wrapperClass: 'slider__wrapper',
    autoHeight: true,
      pagination: {
        el: '.slider__pagination',
        clickable: true,
      },
  })
})
