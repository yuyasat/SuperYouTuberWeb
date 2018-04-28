import Vue from 'vue'
import Vuex from 'vuex'
import moment from 'moment'

import adminMovieListStore from '../../../stores/adminMovieList'

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieListStore)

export default Vue.extend({
  template: `
    <table class="table table-striped table-hover admin small">
      <thead>
        <tr>
          <th>id</th>
          <th>サムネイル</th>
          <th>動画キー</th>
          <th>カテゴリ</th>
          <th>チャンネル/タイトル</th>
          <th>公開時刻</th>
          <th>作成時刻</th>
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
          <td>{{ moment(movie.published_at).format('YYYY-MM-DD hh:mm:ss') }}</td>
          <td>{{ moment(movie.created_at).format('YYYY-MM-DD hh:mm:ss') }}</td>
        </tr>
      </tbody>
    </table>
  `,
  props: ['movies'],
  methods: {
    moment() {
      return moment();
    }
  },
})
