import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import _ from 'lodash'
import 'babel-polyfill';

import adminMovieStore from '../../stores/adminMovie'
import MovieLocation from '../../components/Admin/MovieLocation'

const Promise = require('es6-promise').polyfill();

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieStore)

window.adminMovieVm = new Vue({
  el: '#admin-movie',
  data: {
    url: gon.movie.url || '',
    key: gon.movie.key || '',
    description: gon.movie.description || '',
    existsChecked: false,
    exists: gon.movie.id !== null ? true : false,
    showError: false,
    errorText: '',
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
    latLongArray() {
      return store.state.latLongArray
    },
  },
  watch: {
    url() {
      store.commit('setMovieKey', { url: this.url })
      this.key = store.state.key
    },
    key() {
      if (this.key.length > 11) {
        this.errorText = 'キーが間違っています'
        this.showError = true
        return
      } else if (this.key.length < 11) {
        this.showError = false
        return
      }
      store.commit('setMovieUrl', { key: this.key })
      this.url = store.state.url

      const url = '/admin/api/movie_exists'
      const config = {
        method: 'get',
        params: {
          movie_key: this.key,
        },
      };
      config.withCredentials = true;

      const successFn = (res) => {
        this.exists = res.data.exists
        if (!res.data.exists) {
          store.dispatch('getMovieInfo', { key: this.key })
          this.showError = false
        } else {
          this.errorText = 'すでに登録されています'
          this.showError = true
        }
      }
      const errorFn = (error) => {
        console.log(error)
      }
      axios.get(url, config).then(successFn).catch(errorFn);
    },
  },
  methods: {
    handleLatLong(e) {
      const value = e.target.value
      if (_.includes(gon.map_category_ids, parseInt(value))) {
        if (store.state.latLongArray.length === 0) {
          store.commit('initializeLatLong')
        }
      } else {
        store.commit('deleteLatLong')
      }
    },
  },
  components: {
    'movie-location': MovieLocation,
  },
})
