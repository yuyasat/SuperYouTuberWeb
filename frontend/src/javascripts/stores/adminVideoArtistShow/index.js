import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const initialDefinitionArray = function() {
  if (gon.movie_registration_definitions.length !== 0) { return gon.movie_registration_definitions }

  return [{ regex: '', categoryId: '', index: 0 }]
}

const state = {
  definitionArray: initialDefinitionArray(),
}

const mutations = {
  addDifinition(state, index) {
    let defArray = state.definitionArray
    defArray.splice(index + 1, 0, { regex: '', categoryId: '', index: index + 1 })
    defArray.slice(index + 2, defArray.length).forEach((definition) => {
      definition.index++
    })
    state.definitionArray = _.orderBy(definitionArray, 'index')
  },
  removeDifinition(state, index) {
    const definitionArray = state.definitionArray
    state.definitionArray = definitionArray.filter(function(definition) {
      return definition.index !== index
    })
    state.definitionArray.forEach((definition, i) => {
      definition.index = i
    })
  },
}

const getters = {
}

const actions = {
}

export default new Vuex.Store({
  state,
  mutations,
  getters,
  actions,
})
