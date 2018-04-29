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
        sortBy: store.state.sortBy,
        sortSc: store.state.sortSc,
        page: n,
      }
      store.commit('setPage', n)
      store.dispatch("setSortBy", param)
    }
  },
})
