# RelaxinTestTweak

给 **Relaxin 隐根（RootHide）** 用的最小测试插件，目标环境：

- iPhone 15 Pro Max
- iOS 17.1.1
- Relaxin + Sileo + ElleKit

装上之后主屏幕会出现 **「Relaxin测试」** 图标。能打开 App 说明越狱 App 能跑；重春板后弹出「SpringBoard 注入成功」说明 tweak 注入能跑。

这不是越狱工具，只是在已经越狱的机器上验证插件/App 是否工作。

## 仓库里有什么

| 部分 | 作用 |
| --- | --- |
| `app/` | 主屏幕 App（环境检测、开关、测试弹窗） |
| `tweak/Tweak.x` | 注入 SpringBoard，延迟约 2.5 秒弹窗 |
| `Makefile` | Theos，`THEOS_PACKAGE_SCHEME=roothide` |
| `entitlements.plist` | RootHide 应用所需 entitlement |

## 编译（Mac）

1. 安装 [roothide/theos](https://github.com/roothide/theos)：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/roothide/theos/master/bin/install-theos)"
```

2. 需要 Xcode 和 iOS SDK。在项目目录：

```bash
export THEOS=~/theos   # 按你的实际路径
make package FINALPACKAGE=1
```

产物在 `packages/`，deb 架构为 `iphoneos-arm64e`（RootHide）。

3. 传到手机后用 Sileo / Filza 安装。依赖：

- ElleKit（或 MobileSubstrate）
- iOS 16.5.1–17.3.1（Relaxin 公开范围）

如果 Sileo 提示不是 RootHide 包，用 **RootHide Patcher** 的 Convert 再装（这个仓库已经按 roothide scheme 打包，一般不需要）。

## 怎么判断成功

1. 安装完成后重春板。
2. 主屏幕出现「Relaxin测试」。
3. 打开 App，点 **弹出 App 内测试窗口** → 能弹 = App UI 正常。
4. 保持「允许 SpringBoard 弹窗」打开，重春板后 2–3 秒应弹出 **SpringBoard 注入成功**。
5. 再打开 App，看「注入状态」。

## GitHub

本机已登录 `gh` 时：

```bash
cd ~/Projects/RelaxinTestTweak
gh repo create RelaxinTestTweak --private --source=. --remote=origin --push
```

或在 GitHub 新建空仓库后：

```bash
git remote add origin git@github.com:csm7zn7frs-creator/RelaxinTestTweak.git
git push -u origin master
```

Release 可以挂 `make package` 打出的 `.deb`。CI 只检查源文件是否齐全，不会在 GitHub 上交叉编译 iOS deb（需要本机 Theos + SDK）。
