module.exports = {
  root: true,
  globals: {
    chrome: true,
    browser: true,
  },
  env: {
    node: true,
    "vue/setup-compiler-macros": true
  },
  extends: [
    'plugin:vue/vue3-essential',
    "eslint:recommended", 
    "@vue/prettier"
  ],
  parserOptions: {
    parser: 'babel-eslint'
  },
  rules: {
    "generator-star-spacing": "off",
    "object-curly-spacing": "off",
    "no-var": "error",
    "semi": 0,
    "eol-last": "off",
    "no-tabs": "off",
    // "indent": "off",
    "quote-props": 0,
    "quotes": [1, "single"], //引号类型 `` "" ''
    "no-mixed-spaces-and-tabs": "off",
    "no-trailing-spaces": "off",
    "arrow-parens": 0,
    "spaced-comment": "off",
    "space-before-function-paren": "off",
    "no-empty": "off",
    "no-else-return": "off",
    //"no-unused-vars": [2, {"vars": "all", "args": "after-used"}],
    "no-unused-vars": "off", //不能有声明后未被使用的变量或参数
    "max-len": [1, 500],
    "no-console": "off",
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    "indent": [2, 2, { SwitchCase: 1 }], //缩进风格
    "vue/singleline-html-element-content-newline": "off",
    "vue/multiline-html-element-content-newline": "off",
  }
}
