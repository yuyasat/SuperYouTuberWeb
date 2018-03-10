import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

import adminMovieStore from '../../stores/adminMovie'

const Promise = require('es6-promise').polyfill();

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieStore)

window.adminMovieVm = new Vue({
  el: '#admin-movie',
  data: {
    url: gon.movie.url || '',
    key: gon.movie.key || '',
    description: gon.movie.description || '',
  },
  computed: {
    movieUrl() {
      return store.state.url
    },
    thumbnailUrl() {
      return store.getters.thumbnailUrl
    },
    title() {
      return store.state.title
    },
    publishedAt() {
      return store.state.publishedAt
    },
    channel() {
      return store.state.channel
    },
    category0() {
      return store.state.category0
    },
  },
  watch: {
    url() {
      store.commit('setMovieKey', { url: this.url })
      this.key = store.state.key
    },
    key() {
      if (this.key.length !== 11) return
      store.commit('setMovieUrl', { key: this.key })
      this.url = store.state.url
      store.dispatch('getMovieInfo', { key: this.key })
    }
  },
})
