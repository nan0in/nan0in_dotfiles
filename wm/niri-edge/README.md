# 私有 niri-edge

来源和固定提交见 [UPSTREAM](UPSTREAM)。只将真正的 compositor 放到
`~/.local/opt/niri-edge/bin/niri`，不替换 `/usr/bin/niri`，不创建自定义登录 session 或启动包装器。
本机正常 Niri 登录已经使用这一版，IPC 报告原生最小化、scale / genie 动画能力。
Clavis 到 compositor 的最小化／恢复已在独立真实窗口上验证。

从 dotfiles 仓库根目录执行：

```sh
python3 scripts/setup-niri-edge.py build
python3 scripts/setup-niri-edge.py enable
python3 scripts/setup-niri-edge.py check
# 恢复发行版 compositor（下次登录，不重启当前桌面）：
python3 scripts/setup-niri-edge.py disable
```

构建使用干净的固定提交缓存和校验清单；必要的 libclang / resource headers 位于用户缓存，
不安装系统编译器。启用前验证实际 profile，不覆盖个人 systemd drop-in。
回退保留 Clavis 的独立 profile 与全部个人设置。

## 本地原生桌面补丁

`patches/0001-native-desktop.patch` 应用到固定干净提交的独立归档，不改原始源码缓存。
构建版本为 `26.04 (clavis-native-1 b2aaeb3)`；安装清单记录原提交、补丁和二进制 SHA-256。
修改过的缓存／二进制／个人 drop-in 会被保留并报错，不自动覆盖。

- 单独 Super 轻按松开（≤600 ms）触发；组合键、其他修饰键、指针、锁屏等取消。
  Super 按下／松开仍完整转发客户端；左右 Super 均支持，不依赖虚拟键盘全局监听。
- `window-rule { dim 0.08; }` 仅降低窗口 RGB，保留 alpha 与背景 blur。
- 原生最小化及动画能力继续保留。

新二进制已私有安装，**下次正常 Niri 登录生效**，当前 compositor 未重启。
原生输入契约 6 项、配置 24 项通过；独立真实窗口像素验证了 dim 保留 alpha。
关闭私有版前安装器会移除自己生成的 dim 规则，再选择发行版；手改规则保持保护。
旧二进制与清单在 `~/.local/state/clavis/remaining-20261022-185240/deployment-before/niri/`。
