import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

import { queryToObject } from '../../utilities'


const state = {
  movies: null,
}

const mutations = {
  setMovies(state, payload) {
    state.movies = payload.movies
  },
}

const getters = {
  movies: state => {
    return state.movies
  },
}

const actions = {
  getMovies({ commit, state }, payload) {
    const url = '/admin/api/movies'
    const config = {
      method: 'get',
      params: queryToObject(window.location.search),
    };
    config.withCredentials = true;

    const successFn = (res) => {
      commit('setMovies', { movies: res.data.movies })
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
