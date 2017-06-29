// Note: You must restart bin/webpack-dev-server for changes to take effect

const merge = require('webpack-merge')
const sharedConfig = require('./shared.js')
const { settings, output } = require('./configuration.js')
const webpack = require('webpack')

module.exports = merge(sharedConfig, {
  devtool: 'cheap-eval-source-map',

  output: {
    pathinfo: true
  },

  devServer: {
    clientLogLevel: 'none',
    https: settings.dev_server.https,
    host: settings.dev_server.host,
    port: settings.dev_server.port,
    contentBase: output.path,
    publicPath: output.publicPath,
    compress: true,
    headers: { 'Access-Control-Allow-Origin': '*' },
    historyApiFallback: true,
    watchOptions: {
      aggregateTimeout: 300,
      poll: 1000,
      ignored: /node_modules/
    },
    stats: {
      errorDetails: true
    }
  }
})
 