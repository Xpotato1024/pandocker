# Pandocker-X: Markdown 竊・PDF 譌･譛ｬ隱櫁・蜍輔ン繝ｫ繝臥腸蠅・

[![GitHub release](https://img.shields.io/badge/release-v2.2.0--alpha-blue)](https://github.com/Xpotato1024/Pandocker-X/releases/tag/v2.2.0-alpha)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 讎りｦ・

Pandocker-X 縺ｯ **Docker (Windows/Linux/Mac)** 荳翫〒蜍穂ｽ懊☆繧九￣andoc + LuaLaTeX + pandoc-crossref 迺ｰ蠅・〒縺吶・arkdown 縺九ｉ鬮伜刀雉ｪ縺ｪ譌･譛ｬ隱・PDF 繧定・蜍慕函謌舌〒縺阪∪縺吶・

`install.ps1` (Windows) 縺ｾ縺溘・ `install.sh` (Linux/Mac) 縺ｫ繧医ｋ蛻晏屓繧ｻ繝・ヨ繧｢繝・・蠕後・縲～pdx` 繧ｳ繝槭Φ繝峨ｒ螳溯｡後☆繧九□縺代〒縲√Ξ繝昴・繝医・髮帛ｽ｢菴懈・縺九ｉ PDF 縺ｮ繝薙Ν繝峨∪縺ｧ繧偵Ρ繝ｳ繧ｳ繝槭Φ繝峨〒螳檎ｵ舌＆縺帙∪縺吶・

## 荳ｻ縺ｪ迚ｹ蠕ｴ

* **繧ｯ繝ｭ繧ｹ繝励Λ繝・ヨ繝輔か繝ｼ繝蟇ｾ蠢・** Windows (WSL2)縲´inux縲［acOS 縺ｮ縺吶∋縺ｦ縺ｧ `pdx` 繧ｳ繝槭Φ繝峨′蜍穂ｽ懊・

* **繝ｯ繝ｳ繧ｳ繝槭Φ繝牙ｮ溯｡・** `pdx build "project"` 縺縺代〒 Docker 迺ｰ蠅・・縺ｧ Markdown 竊・PDF 螟画鋤縺悟ｮ檎ｵ舌・

* **萓晏ｭ倬未菫ゆｸ崎ｦ・** 繝帙せ繝・S蛛ｴ縺ｫ LaTeX 繧・Pandoc 繧偵う繝ｳ繧ｹ繝医・繝ｫ縺吶ｋ蠢・ｦ√↑縺励・窶ｻLinux/Mac縺ｧ縺ｯ `jq` 縺悟ｿ・ｦ・

* **髮帛ｽ｢逕滓・:** `pdx new "project"` 縺ｧ繝ｬ繝昴・繝医・繝ｭ繧ｸ繧ｧ繧ｯ繝医ｒ閾ｪ蜍穂ｽ懈・縲・

* **繝薙Ν繝芽ｨｭ螳壹・螟夜Κ蛹・** `config/pandoc-args.json` 縺ｧPandoc縺ｮ蜈ｱ騾壼ｼ墓焚繧堤ｮ｡逅・・

* **蠑慕畑繧ｹ繧ｿ繧､繝ｫ (CSL) 縺ｮ譟碑ｻ滓ｧ:**
    * 繝・ヵ繧ｩ繝ｫ繝医・IEEE繧ｹ繧ｿ繧､繝ｫ縺ｫ蜉縺医∽ｸ闊ｬ逧・↑繧ｹ繧ｿ繧､繝ｫ (APA, MLA, Chicago縺ｪ縺ｩ) 繧貞酔譴ｱ莠亥ｮ壹・
    * `report.md` 縺ｮYAML繝倥ャ繝繝ｼ繧堤ｷｨ髮・☆繧九□縺代〒繧ｹ繧ｿ繧､繝ｫ繧貞・繧頑崛縺亥庄閭ｽ縲・
    * 繝励Ο繧ｸ繧ｧ繧ｯ繝亥・縺ｫ迢ｬ閾ｪ縺ｮCSL繝輔ぃ繧､繝ｫ繧定ｿｽ蜉縺励※菴ｿ逕ｨ縺吶ｋ縺薙→繧ょ庄閭ｽ縲・

* **鬮伜刀雉ｪ縺ｪ邨・沿:** LuaLaTeX 縺ｫ繧医ｋ鄒弱＠縺・律譛ｬ隱樊枚譖ｸ蜃ｺ蜉帙・

* **蝗ｳ陦ｨ繝ｻ謨ｰ蠑上・逶ｸ莠貞盾辣ｧ:** `pandoc-crossref` 縺ｫ繧医▲縺ｦ閾ｪ蜍輔〒逡ｪ蜿ｷ繝ｻ蜿ら・莉倥￠縲・

## 蠢・ｦ∫腸蠅・

### 蠢・ｦ∫腸蠅・(Windows)

* **Windows 10/11**
* [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) (WSL2 Backend)
* **Ubuntu (縺ｾ縺溘・莉悶ョ繧｣繧ｹ繝医Μ繝薙Η繝ｼ繧ｷ繝ｧ繝ｳ) :** Microsoft Store縺九ｉ繧､繝ｳ繧ｹ繝医・繝ｫ
* **PowerShell 7 莉･髯・:** Microsoft Store縺九ｉ繧､繝ｳ繧ｹ繝医・繝ｫ (謗ｨ螂ｨ)
    * 窶ｻ Windows讓呎ｺ悶・PowerShell 5.1縺ｧ繧ょ虚菴懊＠縺ｾ縺吶′縲～install.ps1` 縺ｮ譁・ｭ励さ繝ｼ繝我ｺ呈鋤諤ｧ縺ｮ縺溘ａPS 7繧呈耳螂ｨ縺励∪縺吶・

### 蠢・ｦ∫腸蠅・(Linux / macOS)

* **Linux 縺ｾ縺溘・ macOS**
* [Docker Desktop](https://docs.docker.com/desktop/setup/install/linux-install/) 縺ｾ縺溘・ Docker Engine
* **Bash** 縺ｾ縺溘・ **Zsh**
* **jq** (繧ｳ繝槭Φ繝峨Λ繧､繝ｳJSON繝代・繧ｵ繝ｼ)
    * `sudo apt install jq` (Debian/Ubuntu) 繧・`brew install jq` (macOS) 縺ｧ繧､繝ｳ繧ｹ繝医・繝ｫ縺励※縺上□縺輔＞縲・

## 繝・ぅ繝ｬ繧ｯ繝医Μ讒区・

~~~
.
笏・ﾂDockerfile ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# Pandoc縺ｨTeX迺ｰ蠅・ｒ讒狗ｯ峨☆繧汽ocker險ｭ螳・
笏・ﾂdocker-compose.yml ﾂ ﾂ ﾂ# 繧ｳ繝ｳ繝・リ螳溯｡後ｒ閾ｪ蜍募喧縺吶ｋCompose螳夂ｾｩ
笏・ﾂinstall.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ # [Windows逕ｨ] pdx髢｢謨ｰ繧単owerShell縺ｫ逋ｻ骭ｲ縺吶ｋ繧､繝ｳ繧ｹ繝医・繝ｩ
笏・ﾂinstall.sh ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# [Linux/Mac逕ｨ] pdx髢｢謨ｰ繧達ash/Zsh縺ｫ逋ｻ骭ｲ縺吶ｋ繧､繝ｳ繧ｹ繝医・繝ｩ
笏・ﾂREADME.md ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ # 縺薙・繝峨く繝･繝｡繝ｳ繝・
笏・ﾂdefault.yml ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ # 蜷・・繝ｭ繧ｸ繧ｧ繧ｯ繝医・defaults.yml縺ｮ繧ｳ繝斐・蜈・
笏・
笏懌楳config/
笏・ﾂ ﾂconfig.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# [Windows逕ｨ] 迺ｰ蠅・ｨｭ螳・(WSL繝・ぅ繧ｹ繝医Μ蜷阪↑縺ｩ)
笏・ﾂ ﾂwsl-helpers.ps1 ﾂ ﾂ ﾂ ﾂ# [Windows逕ｨ] WSL髢｢騾｣縺ｮ陬懷勧髢｢謨ｰ
笏・ﾂ ﾂpandoc-args.json ﾂ ﾂ ﾂ # [蜈ｱ騾咯 Pandoc繝薙Ν繝牙ｼ墓焚縺ｮ險ｭ螳壹ヵ繧｡繧､繝ｫ
笏・
笏懌楳scripts/
笏・ﾂ ﾂbuild.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# [Windows逕ｨ] pdx build 縺ｮ譛ｬ菴・
笏・ﾂ ﾂnew.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# [Windows逕ｨ] pdx new 縺ｮ譛ｬ菴・
笏・ﾂ ﾂsetup.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# [Windows逕ｨ] pdx setup 縺ｮ譛ｬ菴・
笏・ﾂ ﾂwsl-init.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ # [Windows逕ｨ] WSL蛻晄悄蛹悶・蜈ｱ騾壹Ο繧ｸ繝・け
笏・ﾂ ﾂuninstall.ps1 ﾂ ﾂ ﾂ ﾂ ﾂ# [Windows逕ｨ] 繧｢繝ｳ繧､繝ｳ繧ｹ繝医・繝ｩ
笏・
笏・ﾂ ﾂbuild.sh ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ # [Linux/Mac逕ｨ] pdx build 縺ｮ譛ｬ菴・
笏・ﾂ ﾂnew.sh ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ # [Linux/Mac逕ｨ] pdx new 縺ｮ譛ｬ菴・
笏・ﾂ ﾂsetup.sh ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ # [Linux/Mac逕ｨ] pdx setup 縺ｮ譛ｬ菴・
笏・ﾂ ﾂuninstall.sh ﾂ ﾂ ﾂ ﾂ ﾂ# [Linux/Mac逕ｨ] 繧｢繝ｳ繧､繝ｳ繧ｹ繝医・繝ｩ
笏・
笏懌楳csl/
笏・ﾂ ﾂieee-with-url.csl ﾂ ﾂ # 繝・ヵ繧ｩ繝ｫ繝医・蠑慕畑繧ｹ繧ｿ繧､繝ｫ
笏・ﾂ ﾂapa.csl ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# (萓・ 霑ｽ蜉縺吶ｋ荳闊ｬ逧・↑CSL繝輔ぃ繧､繝ｫ
笏・ﾂ ﾂmla.csl ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ ﾂ# (萓・
笏・ﾂ ﾂ...
笏・
笏懌楳log/
笏・ﾂ ﾂ(pandoc_*.log) ﾂ ﾂ ﾂ ﾂ# -Log 繧ｪ繝励す繝ｧ繝ｳ謖・ｮ壽凾縺ｫ逕滓・
笏・
笏懌楳preamble/
笏・ﾂ ﾂpreamble-main.tex ﾂ ﾂ # LaTeX縺ｮ繝励Μ繧｢繝ｳ繝悶Ν險ｭ螳・
笏・ﾂ ﾂ...
笏・
笏懌楳projects/
笏・ﾂ 笏披楳 report-name/
笏・ﾂ ﾂ ﾂ ﾂ(逵∫払)
笏・
笏披楳templates/
ﾂ ﾂ ﾂpandoc.latex ﾂ ﾂ ﾂ ﾂ ﾂ# Pandoc縺ｮLaTeX繝・Φ繝励Ξ繝ｼ繝・
~~~

## 菴ｿ縺・婿

### 0. Windows 繝ｦ繝ｼ繧ｶ繝ｼ蜷代￠: Docker 縺ｨ WSL 縺ｮ邨ｱ蜷郁ｨｭ螳・

(Linux/macOS 繝ｦ繝ｼ繧ｶ繝ｼ縺ｯ縺薙・繧ｹ繝・ャ繝励ｒ繧ｹ繧ｭ繝・・縺励※縺上□縺輔＞)

Docker Desktop 縺ｧ PDF 繝薙Ν繝臥腸蠅・ｒ豁｣縺励￥蜍穂ｽ懊＆縺帙ｋ縺ｫ縺ｯ縲仝SL 邨ｱ蜷医ｒ譛牙柑縺ｫ縺吶ｋ蠢・ｦ√′縺ゅｊ縺ｾ縺吶・

1. Docker Desktop 繧帝幕縺・
2. Settings 竊・Resources 竊・WSL Integration 縺ｫ遘ｻ蜍・
3. 莉･荳九ｒ譛牙柑蛹・
   ﾂ ﾂ ﾂ- Enable integration with my default WSL distro
   ﾂ ﾂ ﾂ- Enable integration with additional distros: 縺ｧ菴ｿ逕ｨ縺吶ｋ Ubuntu 縺ｮ繝医げ繝ｫ繧偵が繝ｳ

### 1. 蛻晏屓繧､繝ｳ繧ｹ繝医・繝ｫ (pdx 繧ｳ繝槭Φ繝峨・逋ｻ骭ｲ)

縺贋ｽｿ縺・・OS縺ｫ蜷医ｏ縺帙※縲√う繝ｳ繧ｹ繝医・繝ｩ繝ｼ繧・*荳蠎ｦ縺縺・*螳溯｡後＠縺ｾ縺吶・

#### Windows (PowerShell) 縺ｮ蝣ｴ蜷・

PowerShell 繧帝幕縺阪√・繝ｭ繧ｸ繧ｧ繧ｯ繝医・繝ｫ繝ｼ繝医ョ繧｣繝ｬ繧ｯ繝医Μ縺ｧ `install.ps1` 繧・*繝峨ャ繝医た繝ｼ繧ｹ**縺ｧ螳溯｡後＠縺ｾ縺吶・

~~~
# 螳溯｡後・繝ｪ繧ｷ繝ｼ縺軍estricted縺ｮ蝣ｴ蜷医・蜈医↓螟画峩縺悟ｿ・ｦ√〒縺・
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# install.ps1 繧貞ｮ溯｡後＠縺ｦ pdx 髢｢謨ｰ繧堤匳骭ｲ (蜈磯ｭ縺ｮ繝峨ャ繝・.)縺碁㍾隕√〒縺・
. .\install.ps1
~~~

`install.ps1` 縺ｯ `pdx` 髢｢謨ｰ繧単owerShell繝励Ο繝輔ぃ繧､繝ｫ縺ｫ逋ｻ骭ｲ縺励∫樟蝨ｨ縺ｮ繧ｻ繝・す繝ｧ繝ｳ縺ｫ閾ｪ蜍戊ｪｭ縺ｿ霎ｼ縺ｿ縺励∪縺吶Ａpdx` 繧ｳ繝槭Φ繝峨′**縺昴・縺ｾ縺ｾ菴ｿ逕ｨ蜿ｯ閭ｽ**縺ｫ縺ｪ繧翫∪縺吶・

#### Linux / macOS (Bash/Zsh) 縺ｮ蝣ｴ蜷・

繧ｿ繝ｼ繝溘リ繝ｫ繧帝幕縺阪√・繝ｭ繧ｸ繧ｧ繧ｯ繝医・繝ｫ繝ｼ繝医ョ繧｣繝ｬ繧ｯ繝医Μ縺ｧ `install.sh` 繧・**source** 繧ｳ繝槭Φ繝峨〒螳溯｡後＠縺ｾ縺吶・

~~~bash
# 螳溯｡梧ｨｩ髯舌ｒ莉倅ｸ・
chmod +x install.sh
chmod +x scripts/*.sh

# install.sh 繧貞ｮ溯｡・(source 縺ｾ縺溘・ . 縺碁㍾隕√〒縺・
source ./install.sh
~~~

`install.sh` 縺ｯ `pdx` 髢｢謨ｰ繧・`.bashrc` 縺ｾ縺溘・ `.zshrc` 縺ｫ逋ｻ骭ｲ縺励∫樟蝨ｨ縺ｮ繧ｻ繝・す繝ｧ繝ｳ縺ｫ閾ｪ蜍戊ｪｭ縺ｿ霎ｼ縺ｿ縺励∪縺吶Ａpdx` 繧ｳ繝槭Φ繝峨′**縺昴・縺ｾ縺ｾ菴ｿ逕ｨ蜿ｯ閭ｽ**縺ｫ縺ｪ繧翫∪縺吶・

### 2. 迺ｰ蠅・そ繝・ヨ繧｢繝・・

`pdx` 繧ｳ繝槭Φ繝峨′菴ｿ縺医ｋ繧医≧縺ｫ縺ｪ縺｣縺溘ｉ縲．ocker 繧､繝｡繝ｼ繧ｸ縺ｨ TeX Live 迺ｰ蠅・ｒ讒狗ｯ峨＠縺ｾ縺吶・

~~~
pdx setup
~~~

> 窶ｻ Windows 繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ蝣ｴ蜷・ WSL 縺ｮ繝・ぅ繧ｹ繝医Μ繝薙Η繝ｼ繧ｷ繝ｧ繝ｳ險ｭ螳壹・ `config/config.ps1` 蜀・〒陦後＞縺ｾ縺吶・

### 3. 譁ｰ縺励＞繝ｬ繝昴・繝育腸蠅・ｒ菴懈・

`pdx new` 繧ｳ繝槭Φ繝峨〒 `projects/` 驟堺ｸ九↓髮帛ｽ｢繧剃ｽ懈・縺励∪縺吶・

~~~
pdx new "report-name"
~~~

* 蠑墓焚1:菴懈・縺吶ｋ繝輔か繝ｫ繝蜷阪ｒ謖・ｮ・

螳溯｡後☆繧九→縲～projects/report-name/` 縺ｫ Markdown 繧・bib 繝輔ぃ繧､繝ｫ縺ｪ縺ｩ縺瑚・蜍慕函謌舌＆繧後∪縺吶・

### 4. 蝓ｷ遲・

* 譛ｬ譁・ `projects/report-name/src/report.md`
* 逕ｻ蜒・ `projects/report-name/images/`
* 蜿り・枚迪ｮ: `projects/report-name/bib/references.bib`

### 5. PDF 逕滓・

`pdx build` 繧ｳ繝槭Φ繝峨〒 PDF 繧堤函謌舌＠縺ｾ縺吶・

~~~
pdx build "report-name"
~~~

* 蠑墓焚1:菴懈・縺励◆繝輔か繝ｫ繝蜷阪ｒ謖・ｮ・

* 蠑墓焚2 (莉ｻ諢・: PDF縺ｫ繝薙Ν繝峨☆繧九ヵ繧｡繧､繝ｫ蜷阪ｒ謖・ｮ・
  ﾂ ﾂ ﾂ- 辟｡謖・ｮ壹↑繧・`report.md` 繧偵ン繝ｫ繝・
  ﾂ ﾂ ﾂ- 1縺､謖・ｮ壹☆繧後・縺昴・ Markdown 繧偵ン繝ｫ繝・
  ﾂ ﾂ ﾂ- 隍・焚謖・ｮ壹〒謖・ｮ壹＠縺・Markdown 繧帝・分縺ｫ繝薙Ν繝・
  ﾂ

* `-All` 繧ｹ繧､繝・メ縺ｧ `src/` 蜀・・縺吶∋縺ｦ縺ｮ `.md` 繝輔ぃ繧､繝ｫ繧偵ン繝ｫ繝・

* `-Log` 繧ｹ繧､繝・メ縺ｧ繝ｭ繧ｰ蜃ｺ蜉・

#### 蠑墓焚謖・ｮ壹・謖吝虚

| 遞ｮ鬘・| 萓・| 蜍穂ｽ・|
|------|----|------|
| **辟｡謖・ｮ・* | `pdx build "report-name"` | `projects/report-name/src` 蜀・・ `report.md` 縺ｫ縺､縺・※繝薙Ν繝峨ｒ螳溯｡後＠縺ｾ縺吶・|
| **蜊俶焚謖・ｮ・* | `pdx build "report-name" "report1.md"` | 謖・ｮ壹＠縺・Markdown 縺ｮ縺ｿ繧偵ン繝ｫ繝峨＠縺ｾ縺吶・|
| **隍・焚謖・ｮ・* | `pdx build "report-name" "report1.md" "report2.md"` | 謖・ｮ壹＠縺溯､・焚縺ｮ Markdown 繧帝・↓繝薙Ν繝峨＠縺ｾ縺吶・|
| **蜈ｨ謖・ｮ夲ｼ・All・・* | `pdx build "report-name" -All` | `projects/report-name/src` 莉･荳九☆縺ｹ縺ｦ縺ｮ Markdown 繧定・蜍慕噪縺ｫ繝薙Ν繝峨＠縺ｾ縺吶・|

逕滓・邨先棡縺ｯ `projects/report-name/output/` 縺ｫ菫晏ｭ倥＆繧後∪縺吶・

繝ｭ繧ｰ蜃ｺ蜉帑ｻ倥″繝薙Ν繝峨ｂ蜿ｯ閭ｽ縺ｧ縺吶・

~~~
pdx build "report-name" -All -Log
~~~

#### 繝輔ぃ繧､繝ｫ荳頑嶌縺埼亟豁｢

PDF 蜃ｺ蜉帶凾縺ｯ縲∝・蜉帙ヵ繧｡繧､繝ｫ蜷阪ｒ繧ゅ→縺ｫ縺励◆繝輔ぃ繧､繝ｫ蜷阪〒菫晏ｭ倥＆繧後ｋ縺溘ａ縲∝酔荳繝・ぅ繝ｬ繧ｯ繝医Μ縺ｧ隍・焚繝薙Ν繝峨＠縺ｦ繧ゆｸ頑嶌縺阪＆繧後∪縺帙ｓ縲・

## 繧ｫ繧ｹ繧ｿ繝槭う繧ｺ

### defaults.yml 縺ｮ邱ｨ髮・

* 繝輔か繝ｳ繝医・菴咏區繝ｻ譁・嶌繧ｯ繝ｩ繧ｹ縺ｪ縺ｩ縺ｮ蝓ｺ譛ｬ險ｭ螳壹ｒ螟画峩縺ｧ縺阪∪縺吶・

> 蝓ｺ譛ｬ逧・↓縺ｯ菴懈・縺励◆繝輔か繝ｫ繝蜀・↓縺ゅｋdefaults.yml繧堤ｷｨ髮・☆繧九％縺ｨ縲・

* **LaTeX繝代ャ繧ｱ繝ｼ繧ｸ縺ｮ險ｭ螳・** ﾂ
  `include-in-header` 縺ｧ隱ｭ縺ｿ霎ｼ繧 `/app/preamble/` 蜀・・ `.tex` 繝輔ぃ繧､繝ｫ繧堤ｷｨ髮・＠縺ｾ縺吶ゆｸ崎ｦ√↑繝代ャ繧ｱ繝ｼ繧ｸ繧偵さ繝｡繝ｳ繝医い繧ｦ繝医☆繧九％縺ｨ縺ｧ繝薙Ν繝画凾髢薙ｒ遏ｭ邵ｮ縺ｧ縺阪∪縺吶・

~~~yaml
include-in-header:
  - "/app/preamble/preamble-main.tex" #蝓ｺ譛ｬ繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-chem.tex"  #蛹門ｭｦ繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-mathphys.tex"  #謨ｰ蟄ｦ迚ｩ逅・ヱ繝・こ繝ｼ繧ｸ
  - "/app/preamble/preamble-tikz.tex"  #tikz繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-table.tex"  #繝・・繝悶Ν繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-code.tex"  #繧ｳ繝ｼ繝峨ヱ繝・こ繝ｼ繧ｸ
  - "/app/preamble/preamble-links.tex"  #繝ｪ繝ｳ繧ｯ繝代ャ繧ｱ繝ｼ繧ｸ
~~~

萓・TikZ繧・喧蟄ｦ蠑上ｒ菴ｿ繧上↑縺・ｴ蜷・

~~~yaml
include-in-header:
  - "/app/preamble/preamble-main.tex" #蝓ｺ譛ｬ繝代ャ繧ｱ繝ｼ繧ｸ
  #- "/app/preamble/preamble-chem.tex"  #蛹門ｭｦ繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-mathphys.tex"  #謨ｰ蟄ｦ迚ｩ逅・ヱ繝・こ繝ｼ繧ｸ
  #- "/app/preamble/preamble-tikz.tex"  #tikz繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-table.tex"  #繝・・繝悶Ν繝代ャ繧ｱ繝ｼ繧ｸ
  - "/app/preamble/preamble-code.tex"  #繧ｳ繝ｼ繝峨ヱ繝・こ繝ｼ繧ｸ
  - "/app/preamble/preamble-links.tex"  #繝ｪ繝ｳ繧ｯ繝代ャ繧ｱ繝ｼ繧ｸ
~~~

### 蠑慕畑繧ｹ繧ｿ繧､繝ｫ (CSL) 縺ｮ螟画峩

* **蜷梧｢ｱ繧ｹ繧ｿ繧､繝ｫ縺ｸ縺ｮ蛻・ｊ譖ｿ縺・**
    `report.md` 縺ｮYAML繝倥ャ繝繝ｼ縺ｫ縺ゅｋ `csl:` 縺ｮ蛟､繧偵∽ｽｿ逕ｨ縺励◆縺・せ繧ｿ繧､繝ｫ縺ｮ **繧ｳ繝ｳ繝・リ蜀・ｵｶ蟇ｾ繝代せ** 縺ｫ螟画峩縺励∪縺吶ょ酔譴ｱ縺輔ｌ縺ｦ縺・ｋ繧ｹ繧ｿ繧､繝ｫ縺ｯ `/app/csl/` 繝・ぅ繝ｬ繧ｯ繝医Μ蜀・↓縺ゅｊ縺ｾ縺・(繝輔ぃ繧､繝ｫ蜷阪・逡ｰ縺ｪ繧句ｴ蜷医′縺ゅｊ縺ｾ縺・縲・

    ~~~yaml
    ---
    title: "Title"
    author: "Your Name"
    date: "..."
    bibliography: ../bib/references.bib
    csl: /app/csl/apa.csl # 縺薙％繧・/app/csl/mla.csl 縺ｪ縺ｩ縺ｫ螟画峩
    ---
    ~~~

    **蜷梧｢ｱ縺輔ｌ繧句ｼ慕畑繧ｹ繧ｿ繧､繝ｫ:**
    * IEEE (繝・ヵ繧ｩ繝ｫ繝・: `ieee-with-url.csl`
    * APA: `apa.csl`
    * MLA: `mla.csl`
    * Chicago (Author-Date): `chicago-author-date.csl`
    * Vancouver: `vancouver.csl`
    * (莉悶・繧ｹ繧ｿ繧､繝ｫ繧・`pdx setup`螳溯｡悟燕縺ｫ`csl/` 繝輔か繝ｫ繝縺ｫ霑ｽ蜉縺励※縺上□縺輔＞)

* **繧ｫ繧ｹ繧ｿ繝CSL繝輔ぃ繧､繝ｫ縺ｮ菴ｿ逕ｨ:**
    1.  菴ｿ逕ｨ縺励◆縺・`.csl` 繝輔ぃ繧､繝ｫ繧偵√＃閾ｪ霄ｫ縺ｮ繝励Ο繧ｸ繧ｧ繧ｯ繝医ヵ繧ｩ繝ｫ繝蜀・・蛻・°繧翫ｄ縺吶＞蝣ｴ謇 (萓・ `projects/report-name/custom-csl/my-style.csl`) 縺ｫ鄂ｮ縺阪∪縺吶・
    2.  `report.md` 縺ｮYAML繝倥ャ繝繝ｼ縺ｮ `csl:` 縺ｮ蛟､繧偵・*`src` 繝・ぅ繝ｬ繧ｯ繝医Μ縺九ｉ隕九◆逶ｸ蟇ｾ繝代せ**縺ｫ螟画峩縺励∪縺吶・

    ~~~yaml
    ---
    csl: ../custom-csl/my-style.csl # 繝励Ο繧ｸ繧ｧ繧ｯ繝亥・縺ｮ繝輔ぃ繧､繝ｫ縺ｸ縺ｮ逶ｸ蟇ｾ繝代せ
    ---
    ~~~

## 繝ｭ繧ｰ縺ｨ繧ｭ繝｣繝・す繝･

* 繝薙Ν繝峨Ο繧ｰ: `log/pandoc_*.log` ( `-Log` 謖・ｮ壽凾縺ｫ逕滓・)

* Docker 繧ｭ繝｣繝・す繝･: LaTeX 繝輔か繝ｳ繝医ｄ繝代ャ繧ｱ繝ｼ繧ｸ繧剃ｿ晄戟縺励√ン繝ｫ繝峨ｒ鬮倬溷喧縲・

## 繝医Λ繝悶Ν繧ｷ繝･繝ｼ繝・ぅ繝ｳ繧ｰ

* **`pdx` 繧ｳ繝槭Φ繝画悴讀懷・:** 繧､繝ｳ繧ｹ繝医・繝ｩ (`. .\install.ps1` 縺ｾ縺溘・ `source ./install.sh`) 繧貞ｮ溯｡後＠縺ｾ縺励◆縺具ｼ・繧ｿ繝ｼ繝溘リ繝ｫ繧貞・襍ｷ蜍輔☆繧九→隱崎ｭ倥＆繧後ｋ蝣ｴ蜷医ｂ縺ゅｊ縺ｾ縺吶・
* **WSL 譛ｪ讀懷・ (Windows):** `wsl --install -d Ubuntu` 繧貞ｮ溯｡後・
* **Docker 縺瑚ｵｷ蜍輔＠縺ｦ縺・↑縺・** Docker Desktop 繧定ｵｷ蜍輔＠縺ｦ蜀崎ｩｦ陦後・
* **繝輔か繝ｳ繝医お繝ｩ繝ｼ:** `pdx setup` 繧貞・螳溯｡後＠縺ｦ TeX Live 繧貞・讒狗ｯ峨・
* **`jq` 縺瑚ｦ九▽縺九ｉ縺ｪ縺・(Linux/Mac):** `sudo apt install jq` 縺ｾ縺溘・ `brew install jq` 縺ｧ `jq` 繧偵う繝ｳ繧ｹ繝医・繝ｫ縺励※縺上□縺輔＞縲・

## 菴懈・閠・

**Xpotato1024** ([321miyuto@xpotato.net](mailto:321miyuto@xpotato.net))

## Backend 縺ｨ sample

### Docker backend

- `config/config.ps1` 縺ｧ `DockerBackend = "desktop" | "wsl-dockerd"` 繧帝∈縺ｹ縺ｾ縺吶・- `desktop` 縺ｯ Docker Desktop 縺ｮ WSL Integration 繧剃ｽｿ縺・∪縺吶・- `wsl-dockerd` 縺ｯ WSL 蜀・・ `dockerd` 縺ｨ `docker compose` 繧剃ｽｿ縺・∪縺吶・- 螟ｱ謨玲凾縺ｯ `wsl-helpers.ps1` 縺・`docker version` / `docker compose version` / `systemctl is-active docker` / `pgrep dockerd` 繧堤｢ｺ隱阪＠縺ｾ縺吶・
### Sync mode

- `SyncMode = "mirror-repo"`: 繝ｪ繝昴ず繝医Μ蜈ｨ菴薙ｒ WSL 縺ｫ蜷梧悄縺励∪縺吶・- `SyncMode = "project-only"`: 繝薙Ν繝峨↓蠢・ｦ√↑繝輔ぃ繧､繝ｫ縺縺代ｒ蜷梧悄縺励∪縺吶・- `SyncMode = "none"`: WSL 蛛ｴ縺ｫ譌｢縺ｫ縺ゅｋ菴懈･ｭ繝・Μ繝ｼ繧偵◎縺ｮ縺ｾ縺ｾ菴ｿ縺・∪縺吶・
### `pdx new`

- `templates/report.md` 繧呈眠隕上・繝ｭ繧ｸ繧ｧ繧ｯ繝医・蛻晄悄 `src/report.md` 縺ｨ縺励※菴ｿ縺・∪縺吶・- `date` 縺ｨ `csl` 縺ｮ繝励Ξ繝ｼ繧ｹ繝帙Ν繝縺ｯ `scripts/new.ps1` / `scripts/new.sh` 縺悟ｱ暮幕縺励∪縺吶・
### `pdx build`

- `defaults.yml` 縺ｯ `/app/templates/pandoc.latex` 繧剃ｽｿ縺・ｈ縺・↓縺励※縺・∪縺吶・- `defaults-paper.yml` 縺ｯ 2 谿ｵ邨・・隲匁枚蜷代￠險ｭ螳壹〒縺吶・- `projects/sample-paper/` 縺ｯ縲∝ｼ慕畑繝ｻ謨ｰ蠑上・蝗ｳ繝ｻ陦ｨ繧貞性繧蜍穂ｽ懃｢ｺ隱咲畑縺ｮ譛蟆上し繝ｳ繝励Ν縺ｧ縺吶・
### Build metrics

- ビルド時間や PDF サイズの記録用に `docs/build-metrics.md` を追加しました。
- `pdx setup` / `pdx build` の検証結果はここに追記してください。

## 追加の挙動

- `pdx build "<project>" -All` は `src/` 配下を再帰的に探索し、サブディレクトリ構成を保って `output/` に PDF を出力します。
- `pdx new -Paper "<project>"` は `defaults-paper.yml` を `defaults.yml` としてコピーし、2 段組み論文向けの初期設定を使います。
- `projects/sample-paper/` はこの挙動を確認するためのサンプルです。

## Windows binary

Windows の新しい配布手順と `pdx.exe` のビルド手順は [docs/windows-binary.md](docs/windows-binary.md) を参照してください。
