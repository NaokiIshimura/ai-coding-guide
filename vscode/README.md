# VSCode設定

## .vscode/settings.json作成コマンド

```bash
mkdir -p .vscode && cat << 'EOF' > .vscode/settings.json
{
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#ff0000", // タイトルバーの背景色
    "titleBar.activeForeground": "#ffffff"  // タイトルバーの文字色
    // "titleBar.activeBackground": "#0000ff", // タイトルバーの背景色
    // "titleBar.activeForeground": "#ffffff"  // タイトルバーの文字色
    // "titleBar.activeBackground": "#008000", // タイトルバーの背景色
    // "titleBar.activeForeground": "#ffffff"  // タイトルバーの文字色
  }
}
EOF
```
