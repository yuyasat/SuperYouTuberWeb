import Vue from 'vue'
import Vuex from 'vuex'

import adminMovieStore from '../../../stores/adminMovie'

Vue.use(Vuex)

const store = new Vuex.Store(adminMovieStore)

export default Vue.extend({
  template: `
    <div class="form-group">
      <label for="movie_longlat" class="col-xs-4 control-label small">緯度・経度</label>
      <input size="22" placeholder="35.684952, 135.122211" type="text"
             :name="'movie[locations_attributes][' + latlong.index + '][latlong]'"
             id="movie_locations_attributes_1_latitude" class="small form-controll" v-model="latlong.latlong">
      <i class="fa fa-plus-square" v-on:click="addLocation"></i>
      <i class="fa fa-minus-square" v-show="latlong.index !== 0" v-on:click="removeLocation"></i>
    </div>
  `,
  props: ['latlong'],
  methods: {
    addLocation() {
      store.commit('addLocation', this.latlong.index)
    },
    removeLocation() {
      store.commit('removeLocation', this.latlong.index)
    },
  },
})
