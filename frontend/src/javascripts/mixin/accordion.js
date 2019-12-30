export default {
  data () {
    return {
      showList: [false],
    };
  },
  computed: {
  },
  methods: {
    toggle (index) {
      this.showList.splice(index, 1, !this.showList[index]);
    },
    show (index) {
      return this.showList[index];
    },
    onBeforeEnter (el) {
      el.style.height = 0;
    },
    onEnter (el) {
      el.style.height = el.scrollHeight + 'px';
    },
    onBeforeLeave (el) {
      el.style.height = el.scrollHeight + 'px';
    },
    onLeave (el) {
      el.style.height = 0;
    },
  },
};
