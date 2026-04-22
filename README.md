# 今日印钞

一个原生 macOS 菜单栏小应用，用来实时显示当天已经赚到多少钱。

把今天赚了多少钱挂在菜单栏里，边上班边看数字往上跳。

![今日印钞展示图](./assets/readme-hero.svg)

## 特性

- 菜单栏实时显示 `今日已赚`
- 支持多种状态栏显示样式
- 支持按月薪或按时薪计算
- 支持配置上下班时间、午休开始时间和午休时长
- 支持 `自动 / 开工 / 摸鱼 / 收工` 状态切换
- 支持周末、法定节假日和补班工作日规则
- 支持启动时自动同步当年官方节假日，平时优先使用本地缓存
- 支持配置加班时段和加班倍率
- 本地自动保存配置

## 适合谁

- 想把工资、时薪、接单收入可视化的人
- 想在菜单栏里实时看到 `今日已赚` 的人
- 想按工作日、节假日、补班、加班规则来估算收入的人

## 下载

- 推荐从 GitHub Releases 下载打包好的 `.app` 或压缩包
- 如果你想自己构建，也可以按下面步骤生成 `今日印钞.app`
- Releases: [huang4766/today-money-printer/releases](https://github.com/huang4766/today-money-printer/releases)

## 系统要求

- `macOS 14+`
- 建议使用完整 Xcode 工具链

## 快速开始

```bash
chmod +x ./build_app.sh
./build_app.sh
open ./今日印钞.app
```

构建完成后会在当前目录生成 `今日印钞.app`。

如果你本机执行时报 `swift` / SDK 版本不匹配，先把当前开发者目录切到完整 Xcode，而不是 `CommandLineTools`：

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

然后再重新执行 `./build_app.sh`。

## Roadmap

- 更多状态栏显示样式
- 更完整的节假日自动同步
- 更像 iOS 设置页的交互与外观
- 自动更新与发布签名
