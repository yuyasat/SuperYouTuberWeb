import Vue from 'vue'
import 'babel-polyfill';

import accordion from '../mixin/accordion'

window.spotsCategoriesVm = new Vue({
  mixins: [accordion],
  el: '#spots-categories',
})
