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
  titleSearch: '',
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
  setTitleSearch(state, val) {
    state.titleSearch = val
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
  getMovies({ commit, state }, payload) {
    const url = '/admin/api/movies'

    const params = Object.assign({}, {
      sort_by: state.sortBy,
      sort_sc: state.sortSc,
      page: state.page,
      title_search: state.titleSearch,
    }, payload)

    const config = {
      method: 'get',
      params: params,
    }
    config.withCredentials = true;

    const successFn = (res) => {
      commit('setMovies', { movies: res.data.movies })
      commit('setSortBy', params.sort_by),
      commit('setSortSc', params.sort_sc),
      commit('setTotalPages', res.data.total_pages)
    }
    const errorFn = (error) => {
      console.log(error);
    }
    axios.get(url, config).then(successFn).catch(errorFn)
  },
}

export default {
  state,
  mutations,
  getters,
  actions,
}
