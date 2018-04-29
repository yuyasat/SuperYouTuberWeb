import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

import adminMovieListStore from '../../../stores/adminMovieList'

import { queryToObject } from '../../../utilities'

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieListStore)

export default Vue.extend({
  template: `
    <div class="row">
      <div class="col-xs-12">
        <div class="form-group">
          <label for="category_search" class="col-xs-2 control-label small">カテゴリ検索</label>
          <div class="col-xs-3">
            <select class="form-controll small" v-model="rootCategory">
              <option value="">大カテゴリ</option>
              <option v-for="category in rootCategorySelect" :value="category.id">{{ category.name }}</option>
            </select>
          </div>
          <div class="col-xs-3">
            <select class="form-controll small" v-model="secondaryCategory">
              <option value="">中カテゴリ</option>
              <option v-for="category in secondaryCategorySelect" :value="category.id">{{ category.name }}</option>
            </select>
          </div>
          <div class="col-xs-3">
            <select class="form-controll small" v-model="tertiaryCategory">
              <option value="">小カテゴリ</option>
              <option v-for="category in tertiaryCategorySelect" :value="category.id">{{ category.name }}</option>
            </select>
          </div>
        </div>
      </div>
    </div>
  `,
  props: [],
  data: function() {
    return {
      rootCategorySelect: gon.root_categories,
      secondaryCategorySelect: [],
      tertiaryCategorySelect: [],

      rootCategory: '',
      secondaryCategory: '',
      tertiaryCategory: '',
    }
  },
  watch: {
    rootCategory(val) {
      if (val !== '') {
        this.getCategories(val, 'root')
        this.secondaryCategory = ''
        this.tertiaryCategory = ''
        store.commit('setSecondaryCategory', '')
        store.commit('setTertiaryCategory', '')
      }
      store.commit('setRootCategory', val)
      store.dispatch('getMovies', { category_id: val })
    },
    secondaryCategory(val) {
      if (val !== '') {
        this.getCategories(val, 'secondary')
        this.tertiaryCategory = ''
        store.commit('setTertiaryCategory', '')
      }
      store.commit('setSecondaryCategory', val)
      store.dispatch('getMovies', { category_id: val })
    },
    tertiaryCategory(val) {
      store.commit('setTertiaryCategory', val)
      store.dispatch('getMovies', { category_id: val })
    },
  },
  computed: {
  },
  methods: {
    getCategories(category_id, changedCategory) {
      const url = '/admin/api/children_categories'

      const config = {
        method: 'get',
        params: {
          category_id: category_id
        },
      }
      config.withCredentials = true;

      const next = { root: 'secondary', secondary: 'tertiary' }
      const successFn = (res) => {
        this[`${next[changedCategory]}CategorySelect`] = res.data.categories
        store.commit(`set${_.upperFirst(changedCategory)}Category`, category_id)
      }
      const errorFn = (error) => {
        console.log(error);
      }
      axios.get(url, config).then(successFn).catch(errorFn)
    },
  },
})
