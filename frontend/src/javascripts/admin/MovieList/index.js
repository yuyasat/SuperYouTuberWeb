import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import _ from 'lodash'

import adminMovieListStore from '../../stores/adminMovieList'

import MovieList from '../../components/Admin/MovieList'
import CategorySelect from '../../components/Admin/CategorySelect'
import Paginate from 'vuejs-paginate'
import { queryToObject } from '../../utilities'

Vue.component('paginate', Paginate)

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieListStore)

window.adminMovieListVm = new Vue({
  el: '#admin-movie-list',
  data: {
    titleSearch: '',
    categorySearch: '',
  },
  computed: {
    movies() {
      return store.getters.movies
    },
    totalPages() {
      return store.state.totalPages
    },
  },
  watch: {
    titleSearch(val) {
      if (val.length === 11 || val.length === 0) {
        store.commit('setTitleSearch', val)
        store.commit('setPage', 1)
        store.dispatch('getMovies', { title_search: val })
      }
    },
  },
  mounted() {
    store.dispatch('getMovies')
  },
  components: {
    'movie-list': MovieList,
    'category-select': CategorySelect,
  },
  methods: {
    paginationClick(n) {
      store.commit('setPage', n)
      store.dispatch("getMovies", { page: n })
    },
    searchCategoryMovie() {
      if (this.categorySearch.length > 0) {
        store.commit('setCategorySearch', this.categorySearch)
        store.dispatch("getMovies", { category_search: this.categorySearch })
      }
    },
  },
})
