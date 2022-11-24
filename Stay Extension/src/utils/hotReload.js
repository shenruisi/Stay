// 加载文件

const filesInDirectory = dir =>
  new Promise(resolve =>
    dir.createReader().readEntries(entries => {
      Promise.all(
          entries
          .filter(e => e.name[0] !== '.')
          .map(e =>
            e.isDirectory ? filesInDirectory(e) : new Promise(resolve => e.file(resolve))
          )
        )
        .then(files => [].concat(...files))
        .then(resolve);
    })
  );

// 遍历插件目录，读取文件信息，组合文件名称和修改时间成数据
const timestampForFilesInDirectory = dir =>
  filesInDirectory(dir).then(files =>
    files.map(f => f.name + f.lastModifiedDate).join()
  );

// 刷新当前活动页
const reload = () => {
  window.chrome.tabs.query({
      active: true,
      currentWindow: true
    },
    tabs => {
      // NB: see https://github.com/xpl/crx-hotreload/issues/5
      if (tabs[0]) {
        window.chrome.tabs.reload(tabs[0].id);
      }
      // 强制刷新页面
      window.chrome.runtime.reload();
    }
  );
};

// 观察文件改动
const watchChanges = (dir, lastTimestamp) => {
  timestampForFilesInDirectory(dir).then(timestamp => {
    // 文件没有改动则循环监听watchChanges方法
    if (!lastTimestamp || lastTimestamp === timestamp) {
      setTimeout(() => watchChanges(dir, timestamp), 1000); // retry after 1s
    } else {
      // 强制刷新页面
      reload();
    }
  });
};

const hotReload = () => {
  window.chrome.management.getSelf(self => {
    if (self.installType === 'development') {
      // 获取插件目录，监听文件变化
      window.chrome.runtime.getPackageDirectoryEntry(dir => watchChanges(dir));
    }
  });
};

export default hotReload;
