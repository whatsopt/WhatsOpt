const { globalMutableWebpackConfig: webpackConfig, merge } = require('shakapacker');

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
};

const config = merge({}, webpackConfig, options);
console.log(config);
module.exports = config;
