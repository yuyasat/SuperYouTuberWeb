import Vue from 'vue'
import _ from 'lodash'
import 'babel-polyfill';

const Promise = require('es6-promise').polyfill();

window.adminCategoryVm = new Vue({
  el: '#admin-category',
  data: {
    parentCategory: gon.parent_category_id || 0,
  },
  computed: {
    isSpecialCategory() {
      return _.includes(gon.music_category_ids, parseInt(this.parentCategory))
    },
  },
})
