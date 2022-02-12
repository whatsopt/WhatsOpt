module.exports = function (api) {
  const defaultConfigFunc = require('shakapacker/package/babel/preset.js');
  const resultConfig = defaultConfigFunc(api);
  const isProductionEnv = api.env('production');

  const changesOnDefault = {
    presets: [
      [
        '@babel/preset-react',
        {
          development: !isProductionEnv,
          useBuiltIns: true,
        },
      ],
    ].filter(Boolean),
    plugins: [
      isProductionEnv && ['babel-plugin-transform-react-remove-prop-types',
        {
          removeImport: true,
        },
      ],
      process.env.WEBPACK_SERVE && 'react-refresh/babel',
    ].filter(Boolean),
  };

  resultConfig.presets = [...resultConfig.presets, ...changesOnDefault.presets];
  resultConfig.plugins = [...resultConfig.plugins, ...changesOnDefault.plugins];

  return resultConfig;
};
