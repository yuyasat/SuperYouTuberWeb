require('../../node_modules/font-awesome/css/font-awesome.css')

import $ from 'jquery'

$(function() {
  $('[data-js="confirm"]').click(function() {
    if (confirm($(this).data('confirm'))) {
      return true;
    } else {
      return false;
    }
  });
});
