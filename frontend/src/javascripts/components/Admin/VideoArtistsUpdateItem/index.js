import Vue from 'vue'
import $ from 'jquery'
import axios from 'axios'

export default Vue.extend({
  template: `
    <div class="admin">
      <div class="col-xs-1">{{ video_artist.id }}</div>
      <div class="col-xs-3">
        <a :href="video_artist.channel_url" target="_blank">{{ video_artist.channel }}</a>
      </div>
      <div class="col-xs-3">{{ video_artist.title }}</div>
      <div class="col-xs-2">
         <input type="text" v-model="twitter" class="col-xs-8 admin-text">
         <i class="fa col-xs-4"
            :class="{ 'fa-check': isTwitterSaved, 'fa-spinner fa-spin': twitterLoading }"></i>
      </div>
      <div class="col-xs-2">
         <input type="text" v-model="instagram" class="col-xs-8 admin-text">
         <i class="fa col-xs-4"
            :class="{ 'fa-check': isInstagramSaved, 'fa-spinner fa-spin': instagramLoading }"></i>
      </div>
      <div class="col-xs-1">
        <button name="button"
                type="submit"
                @click="update" ><i class="fa fa-save"></i></button>
      </div>
    </div>
  `,
  props: ['video_artist'],
  data: function() {
    return {
      twitter: this.video_artist.twitter || '',
      instagram: this.video_artist.instagram || '',
      twitterPersited: this.video_artist.twitter !== null,
      twitterLoading: false,
      instagramPersited: this.video_artist.instagram !== null,
      instagramLoading: false,
    }
  },
  computed: {
    isTwitterSaved() {
      return this.twitterPersited && !this.twitterLoading
    },
    isInstagramSaved() {
      return this.instagramPersited && !this.instagramLoading
    },
  },
  methods: {
    update() {
      const url = '/admin/api/video_artist'
      const params = {
        video_artist: {
          id: this.video_artist.id,
          sns_accounts_attributes: [
            {
              type: 'TwitterAccount',
              video_artist_id: this.video_artist.id,
              account: this.twitter
            },
            {
              type: 'InstagramAccount',
              video_artist_id: this.video_artist.id,
              account: this.instagram
            },
          ]
        },
      }
      const config = {
        withCredentials: true,
        onUploadProgress: (progressEvent) => {
          this.twitterLoading = true
          this.instagramLoading = true
        },
      }

      const successFn = (res) => {
        this.twitterLoading = false
        this.twitterPersited = res.data.twitter !== null
        this.instagramLoading = false
        this.instagramPersited = res.data.instagram !== null
        this.twitter = res.data.twitter
        this.instagram = res.data.instagram
      }
      const errorFn = (error) => {
        console.log(error)
      }
      axios.defaults.headers['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content')
      axios.post(url, params, config).then(successFn).catch(errorFn);
    },
  },
})
