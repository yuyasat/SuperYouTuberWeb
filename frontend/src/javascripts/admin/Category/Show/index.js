import Vue from 'vue'

import CategorySortComponent from '../../../components/CategorySort'

window.preapplyVm = new Vue({
  el: '#category-sort',
  components: {
    'category-sort-component': CategorySortComponent,
  },
})

