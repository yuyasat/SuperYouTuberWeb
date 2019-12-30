const INLINE_ELEMENTS = require('./node_modules/eslint-plugin-vue/lib/utils/inline-non-void-elements.json')

module.exports = {
  "extends": [
    // eslint-plugin-vue(.vueファイルのtemplateとscriptのlint)をextend
    "plugin:vue/recommended",
    // eslint-config-standardをextend
    "standard",
  ],
  "parserOptions": {
    // ecmaVersionを指定
    "ecmaVersion": 6,
    // type="module"をサポート
    "sourceType": "module",
    // parserを指定
    "parser": "babel-eslint",
  },
  "env": {
    // browserが持っているオブジェクトをサポート
    "browser": true,
    // ES2015以降に追加された組み込みオブジェクトをサポート
    "es6": true
  },
  "globals": {
    "$": true,
    "gon": true,
  },
  "rules": {
    "semi": ["error", "always"],
    "comma-dangle": ["error", "always-multiline"],
    "no-unused-expressions": "warn", // TODO: Promiseのところ少し検討して別PRで対応
    "no-new": "off", // new Vue(); してインスタンスを変数に入れなくても良い
    "no-extra-boolean-cast": "off", //!!でBooleanにキャストしても良い
    "vue/singleline-html-element-content-newline": ["error", {
      "ignoreWhenNoAttributes": true,
      "ignoreWhenEmpty": true,
      "ignores": ["option", "pre", "textarea", ...INLINE_ELEMENTS], // enechange-spec対応
    }],
    "vue/multiline-html-element-content-newline": ["error", {
      "ignoreWhenEmpty": true,
      "ignores": ["option", "pre", "textarea", ...INLINE_ELEMENTS], // enechange-spec対応
      "allowEmptyLines": false,
    }],
    "quote-props": ["error", "consistent"],
    "quotes": ["error", "single", { "avoidEscape": false }],
    "prefer-const": ["error",{
      "destructuring": "any",
      "ignoreReadBeforeAssign": false}],
    "dot-notation": "off",
    "array-bracket-spacing": [2, "never"],
    "computed-property-spacing": ["error", "never"]
  }
}
