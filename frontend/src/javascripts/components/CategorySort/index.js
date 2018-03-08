import Vue from 'vue'
import _ from 'lodash'

export default Vue.extend({
  template: `
    <div class="list-group">
      <div class="list-group-item draggable-cursor" v-for="category in this.orderedCategories"
           draggable="true"
           @dragstart="dragstart(category, $event)"
           @dragend="dragend"
           @dragenter="dragenter(category)">
        <input type="hidden" name="category[][id]" v-bind:value="category.id">
        <div class="row">
          <div class="col-xs-8">{{category.name}}</div>
          <div class="text-right col-xs-4">
            <input class="small" name="category[][display_order]" v-bind:value="category.displayOrder" size="2">
          </div>
        </div>
      </div>
    </div>
  `,
  data: function () {
    return {
      draggingCategory: undefined,
      categories: gon.children_categories.map((cat, i) => {
        return Object.assign(cat, {
          displayOrder: cat.display_order === 0 ? i + 1 : cat.display_order
        })
      }),
    }
  },
  computed: {
    orderedCategories() {
      return _.orderBy(this.categories, 'displayOrder')
    }
  },
  methods: {
    dragstart(category, e) {
      this.draggingCategory = category
      e.target.style.opacity = 0.5;
    },
    dragend(e) {
      e.target.style.opacity = 1;
      e.preventDefault();
    },
    dragenter(category) {
      const tempDisplayOrder = category.displayOrder;
      category.displayOrder = this.draggingCategory.displayOrder
      this.draggingCategory.displayOrder = tempDisplayOrder
    },
  },
})
