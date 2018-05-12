import Vue from 'vue'
import _ from 'lodash'

import VideoArtistsUpdateItem from '../VideoArtistsUpdateItem'

export default Vue.extend({
  template: `
    <div class="small">
      <div class="row header-border" style="margin-bottom: 10px">
        <div>
          <div class="col-xs-1">id</div>
          <div class="col-xs-2">チャンネルID</div>
          <div class="col-xs-2">タイトル</div>
          <div class="col-xs-2">Twitter</div>
          <div class="col-xs-2">Instagram</div>
          <div class="col-xs-1">かな</div>
          <div class="col-xs-1">en</div>
          <div class="col-xs-1">保存</div>
        </div>
      </div>
      <div class="row" v-for="video_artist in this.video_artists">
        <video-artists-update-item :video_artist="video_artist"></video-artists-update-item>
      </div>
    </div>
  `,
  data: function () {
    return {
      video_artists: _.orderBy(gon.video_artists, 'id')
    }
  },
  components: {
    'video-artists-update-item': VideoArtistsUpdateItem,
  },
})
