import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios';

const state = {
  url: gon.movie.url || '',
  key: gon.movie.key || '',
  title: gon.movie.title || '',
  publishedAt: '',
  channel: '',
  category0: gon.movie_categories[0] ? gon.movie_categories[0].id : '',
  description: gon.movie.description || '',
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
