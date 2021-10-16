var webpack = require("webpack");

module.exports = {
  entry: {
    list: './src/index.ts',
  },
  mode: 'none', // don't think we've anything different between environments...
  module: {
    // Use `ts-loader` on any file that ends in '.ts'
    rules: [
      {
        test: /\.(ts|tsx)$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
  // Bundle '.ts' files as well as '.js' files.
  resolve: {
    extensions: ['.ts', '.tsx', '.js'],
  },
  plugins: [
    // fix "process is not defined" error
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('development')
    })
  ],
  output: {
    filename: "[name].bundle.js",
    path: `${process.cwd()}/../../public/js/spa`,
  }
};
