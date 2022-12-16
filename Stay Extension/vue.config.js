const CopyWebpackPlugin = require('copy-webpack-plugin');
const path = require('path');
const { defineConfig } = require('@vue/cli-service');
// const CompressionWebpackPlugin = require('compression-webpack-plugin');

// 复制文件到指定目录
// const copyFiles = [
//   	{
//     	from: path.resolve("src/assets"),
//     	to: path.resolve("dist/assets")
//   	},
//   	{
// 	    from: path.resolve("src/plugins/inject.js"),
// 	    to: path.resolve("dist/js")
//   	}
// ];

// 复制插件
const plugins = [
  	// new CopyWebpackPlugin({
  // 	patterns: copyFiles
  	// }),
	
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
  transpileDependencies: true,
  // 是否为 Babel 或 TypeScript 使用 thread-loader。该选项在系统的 CPU 有多于一个内核时自动启用，仅作用于生产构建，在适当的时候开启几个子进程去并发的执行压缩
  parallel: require('os').cpus().length > 1,
  // 配置 content.js background.js
  configureWebpack: {
    entry: {
      darkmode: './src/darkmode/dark.user.js',
      fallback: './src/darkmode/fallback.js',
	    sniffer: './src/sniffer/sniffer.user.js',
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
    if (process.env.NODE_ENV === 'production') {
      config.output.filename('js/[name].js').end()
      config.output.chunkFilename('js/[name].js').end()
    }
    config.module.rule('images').set('parser', {
      dataUrlCondition: {
			  maxSize: 4 * 1024, // 4KiB
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