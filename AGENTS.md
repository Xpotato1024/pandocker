# AGENTS.md

## Codex / Agent 繧ｬ繝ｼ繝峨Ξ繝ｼ繝ｫ

- 縺薙・繝ｪ繝昴ず繝医Μ縺ｯ `Pandocker-X` 縺ｧ縺吶・- repository identity 縺ｯ `Xpotato1024/Pandocker-X` 縺ｧ縺吶・- default branch 縺ｮ source of truth 縺ｯ `gh repo view --json nameWithOwner,defaultBranchRef` 縺ｧ縺吶・- 迴ｾ譎らせ縺ｮ `defaultBranchRef.name` 縺ｯ `master` 縺ｧ縺吶１R 縺ｮ base 繧・`master` 縺ｫ縺励※縺上□縺輔＞縲・- 菴懈･ｭ蜑阪↓蠢・★谺｡繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・  - `git remote -v`
  - `git branch --show-current`
  - `git status --short --branch`
  - `gh repo view --json nameWithOwner,defaultBranchRef`
- 迚ｹ縺ｫ `Xpotato1024/Selfrionette` 縺ｧ縺ｯ邨ｶ蟇ｾ縺ｫ菴懈･ｭ縺励↑縺・〒縺上□縺輔＞縲・- 隧ｳ邏ｰ縺ｪ驕狗畑繝ｫ繝ｼ繝ｫ縺ｯ `docs/agent/codex-round-batch-execution-guardrails.md` 縺ｨ `docs/agent/phase-round-issue-design-rules.md` 繧貞盾辣ｧ縺励※縺上□縺輔＞縲・- `master` 莉･螟悶ｒ base branch 縺ｫ縺励↑縺・〒縺上□縺輔＞縲・- repository mismatch縲『rong base branch縲「nrelated working tree changes縲」alidation failure縲．ocker / TeX runtime gap 縺後≠繧後・蛛懈ｭ｢縺励※蝣ｱ蜻翫＠縺ｦ縺上□縺輔＞縲・- Markdown 縺ｮ prompt 繧・ｪｬ譏弱〒 fenced code block 繧剃ｽｿ縺・→縺阪・縲］ested triple-backtick 繧剃ｽ懊ｉ縺ｪ縺・〒縺上□縺輔＞縲・- 1 issue = 1 PR 繧貞ｮ医▲縺ｦ縺上□縺輔＞縲・
## 縺薙・繝ｪ繝昴ず繝医Μ縺ｮ菴懈･ｭ遏･隴・
- build 謖吝虚縺ｮ螟画峩縺ｯ縺ｾ縺・`tools/`縲～config/`縲～defaults.yml` 繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・- Windows 縺ｮ蟆主・蟆守ｷ壹・ `install.ps1` 縺ｨ `tools/pdx-installer/` 繧貞━蜈医＠縺ｦ縺上□縺輔＞縲・- 譌ｧ譚･縺ｮ shell / PowerShell 繧ｹ繧ｯ繝ｪ繝励ヨ縺ｯ `legacy/` 縺ｫ縺ゅｋ蜑肴署縺ｧ縲∝次蜑・→縺励※譁ｰ隕丈ｿｮ豁｣縺励↑縺・〒縺上□縺輔＞縲・- 譁ｰ縺励＞髮帛ｽ｢繧・ユ繝ｳ繝励Ξ繝ｼ繝医・螟画峩縺ｯ `templates/` 縺ｨ `projects/<project>/content/` 縺ｮ髢｢菫ゅｒ蟠ｩ縺輔↑縺・〒縺上□縺輔＞縲・- LaTeX 蜻ｨ繧翫・隱ｿ謨ｴ縺ｯ `preamble/` 繧貞━蜈医＠縲√ユ繝ｳ繝励Ξ繝ｼ繝亥・菴薙ｒ螟ｧ縺阪￥譖ｸ縺肴鋤縺医↑縺・〒縺上□縺輔＞縲・- 蠑慕畑繧ｹ繧ｿ繧､繝ｫ縺ｮ霑ｽ蜉繧・・繧頑崛縺医・ `csl/` 縺ｨ report 邉ｻ YAML 繝倥ャ繝繝ｼ縺ｮ謨ｴ蜷医ｒ菫昴▲縺ｦ縺上□縺輔＞縲・- 迴ｾ陦後・ issue 鬆・・ `#10`, `#11`, `#12`, `#9`, `#14`, `#13` 縺ｧ縺吶・
## Reference Order

1. `README.md`
2. `defaults.yml` and `config/`
3. `tools/`
4. `templates/`
5. `projects/<name>/`
