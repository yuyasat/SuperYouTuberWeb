import Vue from 'vue'

import VideoArtistsUpdate from '../../components/Admin/VideoArtistsUpdate'

window.adminVideoArtist = new Vue({
  el: '#admin-video-artists',
  components: {
    'video-artists-update': VideoArtistsUpdate,
  },
})

