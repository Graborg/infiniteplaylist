const path = require("path");
const fs = require("fs");
const outputDir = path.join(__dirname, "public/");
const dotenv = require('dotenv');
const webpack = require('webpack');

const isProd = process.env.NODE_ENV === "production";

module.exports = env => {

  const currentPath = path.join(__dirname);
  const fileName = env === "dev" ? ".env-dev" : ".env"
  const fileEnv = dotenv.config({path: currentPath + "/" + fileName}).parsed;


  const envKeys = Object.keys(fileEnv).reduce((prev, next) => {
    prev[`process.env.${next}`] = JSON.stringify(fileEnv[next]);
    return prev;
  }, {});

  return {
    plugins: [
      new webpack.DefinePlugin(envKeys)
    ],
    entry: "./src/Index.bs.js",
    mode: isProd ? "production" : "development",
    output: {
      path: outputDir,
      filename: "index.js",
    },
    devServer: {
      compress: true,
      contentBase: outputDir,
      port: process.env.PORT || 8000,
      historyApiFallback: true,
    },
    module: {
      rules: [
        {
          test: /\.s[ac]ss$/i,
          use: ["style-loader", "css-loader", "sass-loader"],
        },
      ],
    },
  }
};
