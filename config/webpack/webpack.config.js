const { webpackConfig: baseWebpackConfig, merge } = require('shakapacker');
const webpack = require('webpack');

const options = {

  // Manage css of swagger ui in node_modules, ignore stream
  resolve: {
    extensions: ['.css'],
    fallback: { stream: false },
    alias: {
      jquery: 'jquery/src/jquery',
    },
  },

  // Add dependency needed by swagger ui
  plugins: [new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Buffer: ['buffer', 'Buffer'],
  })],

  // Add loader for plotly parallel coordinates
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: 'ify-loader',
      },
      {
        test: require.resolve('jquery'),
        loader: 'expose-loader',
        options: {
          exposes: ['$', 'jQuery'],
        },
      },
    ],
  },

  // 04/11/2022: Workaround webpack error: Uncaught TypeError:
  // __webpack_modules__[moduleId] is undefined
  // https://github.com/webpack/webpack/issues/5429
  // https://github.com/webpack/webpack/issues/11277
  // From time to time: should check if this can be removed
  optimization: { concatenateModules: false, providedExports: false, usedExports: false },

};

const config = merge({}, baseWebpackConfig, options);
console.log(config);
module.exports = config;
