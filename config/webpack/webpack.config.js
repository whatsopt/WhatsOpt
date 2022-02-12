const { webpackConfig: baseWebpackConfig, merge } = require('shakapacker');
const webpack = require('webpack');

const options = {

  // Manage css of swagger ui in node_modules, ignore stream
  resolve: {
    extensions: ['.css'],
    fallback: { stream: false },
  },

  // Add dependency needed by swagger ui
  plugins: [new webpack.ProvidePlugin({
    Buffer: ['buffer', 'Buffer'],
  })],

  // Add loader for plotly parallel coordinates
  module: {
    rules: [{
      test: /\.js$/,
      loader: 'ify-loader',
    }],
  },

};

const config = merge({}, baseWebpackConfig, options);
console.log(config);
module.exports = config;
