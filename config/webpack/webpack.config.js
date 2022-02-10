const { webpackConfig: baseWebpackConfig, merge } = require('shakapacker');

const options = {
  resolve: {
    extensions: ['.css'],
    fallback: { stream: false, buffer: false },
  },
};

const config = merge({}, baseWebpackConfig, options);
console.log(config);
module.exports = config;
