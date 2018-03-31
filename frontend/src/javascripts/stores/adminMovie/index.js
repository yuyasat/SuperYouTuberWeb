import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios';

const initialLatLongArray = function() {
  if (gon.movie_locations.length !== 0) { return gon.movie_locations }

  if (_.includes(gon.map_category_ids, parseInt(gon.default_category))) {
    return [{ latitude: '', longitude: '', index: 0 }]
  } else {
    return []
  }
}

const state = {
  url: gon.movie.url || '',
  key: gon.movie.key || '',
  title: gon.movie.title || '',
  publishedAt: '',
  channel: '',
  category0: gon.movie_categories[0] ? gon.movie_categories[0].id : gon.default_category || '',
  description: gon.movie.description || '',
  latLongArray: initialLatLongArray(),
}

const mutations = {
  setMovieKey(store, payload) {
    store.key = payload.url.split(/v=|&/)[1]
  },
  setMovieUrl(store, payload) {
    store.url = `https://www.youtube.com/watch?v=${payload.key}`
  },
  setMovieInfo(state, data) {
    state.title = data.items[0].snippet.title
    state.publishedAt = data.items[0].snippet.publishedAt
    state.channel = data.items[0].snippet.channelId
  },
  initializeLatLong(store) {
    store.latLongArray = [{ latitude: '', longitude: '', index: 0 }]
  },
  deleteLatLong(store) {
    store.latLongArray = []
  },
  addLocation(state, index) {
    let latLongArray = state.latLongArray
    latLongArray.splice(index + 1, 0, { latitude: '', longitude: '', index: index + 1 })
    latLongArray.slice(index + 2, latLongArray.length).forEach((latLong) => {
      latLong.index++
    })
    state.latLongArray = _.orderBy(latLongArray, 'index')
  },
  removeLocation(state, index) {
    const latLongArray = state.latLongArray
    state.latLongArray = latLongArray.filter(function(latLong) {
      return latLong.index !== index
    })
    state.latLongArray.forEach((latLong, i) => {
      latLong.index = i
    })
  },
}

const getters = {
  thumbnailUrl(state) {
    if (state.key)  return `http://i.ytimg.com/vi/${state.key}/mqdefault.jpg`
  },
}

const actions = {
  getMovieInfo({ commit }, payload) {
    const url = '/admin/api/movie_info'
    const config = {
      method: 'get',
      params: {
        movie_key: payload.key,
      },
    };
    config.withCredentials = true;

    const successFn = (res) => {
      commit('setMovieInfo', res.data)
    }
    const errorFn = (error) => {
      console.log(error);
    }
    axios.get(url, config).then(successFn).catch(errorFn);
  }
}

export default {
  state,
  mutations,
  getters,
  actions,
}
