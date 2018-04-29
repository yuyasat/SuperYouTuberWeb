import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

import { queryToObject } from '../../utilities'


const state = {
  movies: null,
  sortBy: 'id',
  sortSc: 'desc',
  page: 1,
  totalPages: 0,
}

const mutations = {
  setSortBy(state, val) {
    state.sortBy = val
  },
  setSortSc(sate, val) {
    state.sortSc = val
  },
  setMovies(state, payload) {
    state.movies = payload.movies
  },
  setPage(state, val) {
    state.page = val
  },
  setTotalPages(state, val) {
    state.totalPages = val
  },
}

const getters = {
  movies: state => {
    return state.movies
  },
  sortBy: state => {
    return state.sortBy
  },
  sortSc: state => {
    return state.sortSc
  },
}

const actions = {
  setSortBy({ commit, state }, payload) {
    const url = '/admin/api/movies'
    const config = {
      method: 'get',
      params: {
        sort_by: payload.sortBy,
        sort_sc: payload.sortSc,
        page: payload.page,
      },
    }
    config.withCredentials = true;

    const successFn = (res) => {
      commit('setMovies', { movies: res.data.movies })
      commit('setSortBy', payload.sortBy),
      commit('setSortSc', payload.sortSc),
      commit('setTotalPages', res.data.total_pages)
    }
    const errorFn = (error) => {
      console.log(error);
    }
    axios.get(url, config).then(successFn).catch(errorFn)
  },

  getMovies({ commit, state }, payload) {
    const url = '/admin/api/movies'
    const config = {
      method: 'get',
      params: queryToObject(window.location.search),
    };
    config.withCredentials = true;

    const successFn = (res) => {
      commit('setMovies', { movies: res.data.movies })
      commit('setTotalPages', res.data.total_pages)
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
