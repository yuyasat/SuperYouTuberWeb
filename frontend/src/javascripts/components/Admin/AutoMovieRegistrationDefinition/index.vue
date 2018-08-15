<template>
  <div class="form-group">
    <label for="movie_longlat" class="col-xs-4 control-label small">自動動画登録</label>
    <div class="row">
      <div class="col-xs-2">正規表現</div>
      <input
        :name="'video_artist[movie_registration_definitions_attributes]['+index+'][definition]'"
        :id="'video_artist_movie_registration_definitions_attributes_'+index+'_definition'"
        :value="definition.definition"
        size="22" type="text"
        class="col-xs-2 small form-controll admin-text">
      <select
        :name="'video_artist[movie_registration_definitions_attributes]['+index+'][category_id]'"
        :id="'video_artist_movie_registration_definitions_attributes_'+index+'_category_id'"
        :value="definition.category_id"
        class="form-controll small col-xs-2">
        <option v-for="category in categoryList" :value="category[1]">{{ category[0] }}</option>
      </select>
      <i class="fa fa-plus-square" @click="addDefinition"></i>
      <i class="fa fa-minus-square" @click="removeDefinition"></i>
    </div>
  </div>
</template>

<script>
  import store from '../../../stores/adminVideoArtistShow'
  import { mapState } from 'vuex'

  export default {
    props: [
      'definition',
      'index',
      'categoryList',
    ],
    computed: {
    },
    mounted() {
    },
    methods: {
      addDefinition() {
        store.commit('addDefinition', this.index)
      },
      removeDefinition() {
        store.commit('removeDefinition', this.index)
      },
    },
  }
</script>
