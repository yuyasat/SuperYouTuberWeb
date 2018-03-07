import Vue from 'vue'
window.preapplyVm = new Vue({
  el: '#admin-create-movie',
  data: {
    movieUrl: '',
    movieKey: '',
  },
  computed: {
  },
  watch: {
    movieUrl() {
      this.movieKey = this.movieUrl.split('v=').pop()
    },
    movieKey() {
      this.movieUrl = 'https://www.youtube.com/watch?v=' + this.movieKey
    }
  }
})
