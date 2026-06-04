# Pandocker-X

Pandocker-X 縺ｯ縲｀arkdown 繧・Pandoc 縺ｨ LaTeX 縺ｧ PDF 縺ｫ螟画鋤縺吶ｋ縺溘ａ縺ｮ Docker 繝吶・繧ｹ縺ｮ繝ｯ繝ｼ繧ｯ繝輔Ο繝ｼ縺ｧ縺吶・
縺薙・繝ｪ繝昴ず繝医Μ縺ｯ縲∵ｬ｡縺ｮ蜀・ｮｹ縺ｫ蟇ｾ縺吶ｋ source of truth 縺ｧ縺吶・
- 繝励Ο繧ｸ繧ｧ繧ｯ繝磯屁蠖｢
- Docker 繧､繝｡繝ｼ繧ｸ縺ｨ繝薙Ν繝芽ｨｭ螳・- Windows 蜷代￠驟榊ｸ・ヰ繧､繝翫Μ
- Linux / macOS 蜷代￠ source release 縺ｮ襍ｷ轤ｹ

## 蛻ｩ逕ｨ譁ｹ豕・
### Windows

Windows 縺ｧ縺ｯ縲ヽust 陬ｽ縺ｮ驟榊ｸ・ヰ繧､繝翫Μ繧偵う繝ｳ繧ｹ繝医・繝ｫ縺励※ WSL 邨檎罰縺ｧ菴ｿ縺・∪縺吶・
- release asset: `pandocker-x-windows-<version>.zip`
- checksum asset: `pandocker-x-checksums-<version>.sha256`
- 繝ｭ繝ｼ繧ｫ繝ｫ checkout 逕ｨ縺ｮ蟆主・繧ｹ繧ｯ繝ｪ繝励ヨ: `install.ps1`
- 螳溯｡檎腸蠅・ WSL 2縲．ocker Desktop 縺ｾ縺溘・ WSL Docker

繧､繝ｳ繧ｹ繝医・繝ｫ蠕後・蜈ｸ蝙狗噪縺ｪ螳溯｡御ｾ・

```powershell
.\pdx-bootstrap.exe install
```

### Linux / macOS

Linux 縺ｨ macOS 縺ｧ縺ｯ縲《ource release 縺九Ο繝ｼ繧ｫ繝ｫ checkout 繧剃ｽｿ縺・√Ν繝ｼ繝育峩荳九・ Unix `pdx` 繧貞ｮ溯｡後＠縺ｾ縺吶・
- release asset: `pandocker-x-source-<version>.zip`
- checksum asset: `pandocker-x-checksums-<version>.sha256`
- 繧ｨ繝ｳ繝医Μ繝昴う繝ｳ繝・ `./pdx`
- 螳溯｡檎腸蠅・ Docker縲．ocker Compose縲～jq`

蛻晏屓螳溯｡後・萓・

```bash
./pdx setup
./pdx new sample-report
./pdx build sample-report
```

## 繧ｯ繧､繝・け繧ｹ繧ｿ繝ｼ繝・
### Windows 縺ｮ source checkout

```powershell
.\install.ps1
pdx setup
pdx new sample-report
pdx build sample-report
```

### Linux / macOS 縺ｮ source checkout 縺ｾ縺溘・ source release

```bash
./pdx setup
./pdx new sample-report
./pdx build sample-report
```

## 繝・ぅ繝ｬ繧ｯ繝医Μ讒区・

- `config/` - 螳溯｡瑚ｨｭ螳壹→ WSL 繝倥Ν繝代・
- `templates/` - `pdx new` 縺御ｽｿ縺・ユ繝ｳ繝励Ξ繝ｼ繝・- `preamble/` - LaTeX 縺ｮ preamble 譁ｭ迚・- `csl/` - 蠑慕畑繧ｹ繧ｿ繧､繝ｫ
- `tools/` - Windows 蟆主・縺ｨ setup 逕ｨ縺ｮ Rust 繝舌う繝翫Μ
- `projects/<name>/content/` - Markdown 譛ｬ譁・- `projects/<name>/output/` - 逕滓・貂医∩ PDF
- `docs/` - release縲《upport縲〉oadmap 縺ｮ譁・嶌

## Release 縺ｮ豬√ｌ

蜈ｬ髢・release 縺ｯ谺｡縺ｮ豬√ｌ縺ｧ騾ｲ繧√∪縺吶・
1. Issue 繧剃ｽ懈・縺ｾ縺溘・譖ｴ譁ｰ縺吶ｋ縲・2. `codex/` 繝励Ξ繝輔ぅ繝・け繧ｹ縺ｮ branch 繧貞・繧九・3. 螟画峩繧・commit 縺吶ｋ縲・4. branch 繧・push 縺吶ｋ縲・5. PR 繧剃ｽ懊ｋ縲・6. 繝ｬ繝薙Η繝ｼ蠕後↓ merge 縺吶ｋ縲・7. `v1.2.3` 縺ｮ繧医≧縺ｪ release tag 繧・push 縺吶ｋ縲・
隧ｳ縺励＞驕狗畑縺ｯ [CONTRIBUTING.md](CONTRIBUTING.md) 繧貞盾辣ｧ縺励※縺上□縺輔＞縲・
## OSS 蜷代￠縺ｮ譯亥・

- License 縺ｯ [MIT License](LICENSE) 縺ｧ縺吶・- 螟画峩謠先｡医・ [CONTRIBUTING.md](CONTRIBUTING.md) 縺ｫ蠕薙▲縺ｦ縺上□縺輔＞縲・- Security report 縺ｯ [SECURITY.md](SECURITY.md) 繧貞盾辣ｧ縺励※縺上□縺輔＞縲・- Release asset 縺ｫ縺ｯ Windows zip縲《ource archive縲…hecksum file 縺悟性縺ｾ繧後∪縺吶よ､懆ｨｼ謇矩・・ [docs/release.md](docs/release.md) 繧貞盾辣ｧ縺励※縺上□縺輔＞縲・
## 譁・嶌

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [SECURITY.md](SECURITY.md)
- [docs/release.md](docs/release.md)
- [docs/windows-binary.md](docs/windows-binary.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/build-metrics.md](docs/build-metrics.md)
- [docs/agent/codex-round-batch-execution-guardrails.md](docs/agent/codex-round-batch-execution-guardrails.md)
- [docs/agent/phase-round-issue-design-rules.md](docs/agent/phase-round-issue-design-rules.md)

## 陬懆ｶｳ

- `legacy/` 縺ｫ縺ｯ譌ｧ譚･縺ｮ shell / PowerShell 繧ｹ繧ｯ繝ｪ繝励ヨ縺後≠繧翫∪縺吶ょ盾辣ｧ繝ｻ莠呈鋤逕ｨ縺ｧ縺ゅｊ縲∽ｸｻ隕√↑蟆守ｷ壹〒縺ｯ縺ゅｊ縺ｾ縺帙ｓ縲・- GitHub release asset 縺ｫ縺ｯ Windows binaries縲ゞnix 蜷代￠ source archive縲…hecksum file 縺悟性縺ｾ繧後∪縺吶・
