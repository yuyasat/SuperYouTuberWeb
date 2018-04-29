import Vue from 'vue'
import Vuex from 'vuex'

import adminMovieListStore from '../../../stores/adminMovieList'

import { queryToObject } from '../../../utilities'

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieListStore)
const orderClass = { flat: 'fa-minus', desc: 'fa-caret-down', asc: 'fa-caret-up' }

export default Vue.extend({
  template: `
    <table class="table table-striped table-hover admin small">
      <thead>
        <tr>
          <th>id<i @click="sortBy('id')" class="fa" :class="idOrderClass"></i></th>
          <th>サムネイル</th>
          <th>動画キー</th>
          <th>カテゴリ</th>
          <th>チャンネル/タイトル</th>
          <th>公開時刻<i @click="sortBy('published_at')" class="fa" :class="publishedAtOrderClass"></i></th>
          <th>作成時刻<i @click="sortBy('created_at')" class="fa" :class="createdAtOrderClass"></i></th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="movie in this.movies">
          <td><a :href="'/admin/movies/' + movie.id">{{ movie.id }}</a></td>
          <td>
            <a alt="【密着24時】YouTuberくまみきの1日☆お仕事編" target="_blank" :href="movie.url">
              <img :src="movie.default_url" alt="Default">
            </a>
          </td>
          <td>{{ movie.key }}</td>
          <td>{{ movie.categories.map((cat) => { return cat.name }).join(', ') }}</td>
          <td>
            <div><a target="_blank" :href="movie.channel_url">{{ movie.channel }}</a></div>
            <div>{{ movie.title }}</div>
            <div v-for="loc in movie.locations">
              {{ loc.latitude + ', ' + loc.longitude }}
            </div>
          </td>
          <td>{{ date_text(movie.published_at) }}</td>
          <td>{{ date_text(movie.created_at) }}</td>
        </tr>
      </tbody>
    </table>
  `,
  props: ['movies'],
  computed: {
    idOrderClass: state => {
      if (store.getters.sortBy !== 'id') {
        return orderClass.flat
      }
      return orderClass[store.getters.sortSc]
    },
    publishedAtOrderClass: state => {
      if (store.getters.sortBy !== 'published_at') {
        return orderClass.flat
      }
      return orderClass[store.getters.sortSc]
    },
    createdAtOrderClass: state => {
      if (store.getters.sortBy !== 'created_at') {
        return orderClass.flat
      }
      return orderClass[store.getters.sortSc]
    },
  },
  methods: {
    date_text(date) {
      const d = new Date(date)
      const year = d.getFullYear()
      const month = ('0'+(d.getMonth() + 1)).slice(-2)
      const day = ('0'+d.getDate()).slice(-2)
      const hours = ('0'+d.getHours()).slice(-2)
      const min = ('0'+d.getMinutes()).slice(-2)
      const sec = ('0'+d.getSeconds()).slice(-2)
      return `${year}-${month}-${day} ${hours}:${min}:${sec}`
    },
    sortBy(column) {
      let sort;
      if (store.getters.sortBy === column) {
        sort = store.state.sortSc === 'desc' ? 'asc' : 'desc'
      } else {
        sort = 'desc'
      }
      store.dispatch(
        "setSortBy",
        { sortBy: column, sortSc: sort, page: store.state.page }
      )
    },
    orderClass(order) {
    },
  },
})
