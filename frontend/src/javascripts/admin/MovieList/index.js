import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import _ from 'lodash'

import adminMovieListStore from '../../stores/adminMovieList'

import MovieList from '../../components/Admin/MovieList'
import Paginate from 'vuejs-paginate'
import { queryToObject } from '../../utilities'

Vue.component('paginate', Paginate)

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieListStore)

window.adminMovieListVm = new Vue({
  el: '#admin-movie-list',
  data: {
    titleSearch: '',
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
  },
  methods: {
    paginationClick(n) {
      const param = {
        page: n,
      }
      store.commit('setPage', n)
      store.dispatch("getMovies", param)
    }
  },
})
