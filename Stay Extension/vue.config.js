const CopyWebpackPlugin = require('copy-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const path = require('path');
const { defineConfig } = require('@vue/cli-service');
// const CompressionWebpackPlugin = require('compression-webpack-plugin');

// 复制文件到指定目录
const copyFiles = [
  {
    from: path.resolve('src/assets/images/popup-download-dark.png'),
    to: path.resolve('Resources/popup/img')
  },
  {
    from: path.resolve('src/assets/images/popup-download-light.png'),
    to: path.resolve('Resources/popup/img')
  }
];

// 复制插件
const plugins = [
  new CopyWebpackPlugin({
    patterns: copyFiles
  }),
  new UglifyJsPlugin({
    uglifyOptions: {
      // 删除注释
      output: {
        comments: false
      },
      warnings: false,
      compress: {
        drop_console: true,
        drop_debugger: true,
        pure_funcs: process.env.NODE_ENV === 'production'?['console.log']:[] //移除console
      }
    },
    sourceMap: false,
    parallel: true
  })
];

// 页面文件
const pages = {};
// 配置 popup.html 页面
const chromeName = ['popup'];

chromeName.forEach(name => {
  	pages[name] = {
    	entry: `src/${name}/main.js`,
    	template: `src/${name}/index.html`,
    	filename: `${name}.html`
  	};
});

module.exports = defineConfig({
  pages,
  publicPath: './',
  outputDir:'Resources/popup',
  productionSourceMap: false,
  runtimeCompiler: false,
  filenameHashing: false,
  transpileDependencies: true,
  // 是否为 Babel 或 TypeScript 使用 thread-loader。该选项在系统的 CPU 有多于一个内核时自动启用，仅作用于生产构建，在适当的时候开启几个子进程去并发的执行压缩
  parallel: require('os').cpus().length > 1,
  // 配置 content.js background.js
  configureWebpack: {
    entry: {
      darkmode: './src/darkmode/dark.user.js',
      fallback: './src/darkmode/fallback.js',
	    sniffer: './src/sniffer/sniffer.user.js',
      transfer: './src/sniffer/transfer.user.js',
    },
    output: {
      filename: 'js/[name].js',
      libraryExport: 'default'
    },
    plugins
  },
  // 配置 content.css
  css: {
    extract: {
      filename: 'css/[name].css'
    }
  },
  chainWebpack: config => {
    // 开启压缩js代码
    config.optimization.minimize(true)
    config.optimization.delete('splitChunks')
    if (process.env.NODE_ENV === 'production') {
      config.output.filename('js/[name].js').end()
      config.output.chunkFilename('js/[name].js').end()
      config.optimization
        .minimize(true)
        .minimizer('terser')
        .tap(args => {
          let { terserOptions } = args[0];
          terserOptions.compress.drop_console = true;
          terserOptions.compress.drop_debugger = true;
          return args
        });
    }
    config.module.rule('images').set('parser', {
      dataUrlCondition: {
			  maxSize: 1 * 1024, // 4KiB
      },
    });
    
    // 开启gzip压缩
    // config.plugins.push(
    // 	new CompressionWebpackPlugin({
    // 	  algorithm: 'gzip',
    // 	  test: /\.js$|\.html$|\.json$|\.css/,
    // 	  threshold: 10240,
    // 	  minRatio: 0.8,
    // 	})
    // );
  }
});