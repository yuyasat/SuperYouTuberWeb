import Vue from 'vue'
window.preapplyVm = new Vue({
  el: '#admin-movie',
  data: {
    url: gon.movie.url || '',
    key: gon.movie.key || '',
    title: gon.movie.title || '',
    category0: gon.movie_categories[0] ? gon.movie_categories[0].id : '',
    description: gon.movie.description || '',
  },
  computed: {
    thumbnailUrl() {
      if (this.key)  return `http://i.ytimg.com/vi/${this.key}/mqdefault.jpg`
    }
  },
  watch: {
    url() {
      this.key = this.url.split('v=').pop()
    },
    key() {
      this.url = 'https://www.youtube.com/watch?v=' + this.key
    }
  }
})
