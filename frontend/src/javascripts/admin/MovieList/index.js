import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import _ from 'lodash'

import adminMovieListStore from '../../stores/adminMovieList'

import MovieList from '../../components/Admin/MovieList'

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
  },
  watch: {

  },
  mounted() {
    store.dispatch('getMovies')
  },
  components: {
    'movie-list': MovieList,
  },
})
