import Vue from 'vue'
import Vuex from 'vuex'

import { mapState } from 'vuex'

Vue.use(Vuex)

import MovieRegistrationDefinition from '../../../components/Admin/AutoMovieRegistrationDefinition/index.vue'
import store from '../../../stores/adminVideoArtistShow'

window.adminVideoArtistShow = new Vue({
  el: '#admin-video-artists-show',
  store,
  components: {
    'movie-registration-definition': MovieRegistrationDefinition,
  },
  computed: {
    ...mapState([
      'definitionArray'
    ]),
  },
})

