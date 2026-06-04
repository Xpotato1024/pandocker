# Codex Round Batch Execution Guardrails

## 逶ｮ逧・
縺薙・譁・嶌縺ｯ縲￣andocker-X 縺ｧ Codex 縺・1 round 繧貞ｮ溯｡後☆繧九→縺阪・驕狗畑繝ｫ繝ｼ繝ｫ繧貞ｮ夂ｾｩ縺励∪縺吶・repository identity縲｜ase branch縲（ssue scope縲」alidation縲〉eview縲￣R 菴懈・繧偵％縺ｮ譁・嶌縺ｮ蝓ｺ貅悶〒謇ｱ縺・∪縺吶・
## Goal usage

- 1 round 縺斐→縺ｫ 1 goal 繧剃ｽｿ縺｣縺ｦ縺上□縺輔＞縲・- goal 縺ｯ 1 issue 縺ｮ螳御ｺ・愛螳壹ｒ霑ｽ霍｡縺吶ｋ縺溘ａ縺ｫ菴ｿ縺｣縺ｦ縺上□縺輔＞縲・- goal 繧・complete 縺ｫ縺吶ｋ縺ｮ縺ｯ縲∝ｿ・・validation 縺檎ｵゅｏ繧翫∝ｷｮ蛻・′ scope 蜀・↓蜿弱∪繧翫￣R 譛ｬ譁・ｂ謨ｴ縺｣縺溘→縺阪□縺代↓縺励※縺上□縺輔＞縲・- 蜷後§髦ｻ螳ｳ隕∝屏縺檎ｹｰ繧願ｿ斐＠蜃ｺ縺溘→縺阪□縺・blocked 繧剃ｽｿ縺｣縺ｦ縺上□縺輔＞縲・- 騾比ｸｭ縺ｧ蛻･ issue 縺ｫ蠎・￡縺ｪ縺・〒縺上□縺輔＞縲・
## Repository identity

- Project: `Pandocker-X`
- Repository: `Xpotato1024/Pandocker-X`
- default branch 縺ｮ source of truth: `gh repo view --json nameWithOwner,defaultBranchRef`
- 迴ｾ譎らせ縺ｮ default branch: `master`
- PR base: `master`

repository identity 縺御ｸ閾ｴ縺励↑縺・ｴ蜷医・菴懈･ｭ繧呈ｭ｢繧√※蝣ｱ蜻翫＠縺ｦ縺上□縺輔＞縲・
## Mandatory preflight

round 髢句ｧ句燕縺ｫ蠢・★谺｡繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・
```powershell
git remote -v
git branch --show-current
git status --short --branch
gh repo view --json nameWithOwner,defaultBranchRef
```

谺｡縺ｮ縺・★繧後°縺後≠繧後・ stop condition 縺ｧ縺吶・
- repository mismatch
- wrong base branch
- unexpected working tree changes
- required validation 縺ｮ螟ｱ謨・
## Work hierarchy

- Phase: 螟ｧ縺阪↑謌ｦ逡･逧・叙繧顔ｵ・∩縺ｧ縺吶・- Round: Codex 縺ｮ 1 蝗槭・螳溯｡後〒縺吶・- Issue: 1 PR 縺ｫ蜿弱ａ繧九Ξ繝薙Η繝ｼ蜿ｯ閭ｽ縺ｪ蜊倅ｽ阪〒縺吶・- 1 issue = 1 PR 繧貞ｮ医▲縺ｦ縺上□縺輔＞縲・
Phase 繧・1 round 縺ｧ邨ゅｏ繧峨○繧医≧縺ｨ縺励↑縺・〒縺上□縺輔＞縲・Issue 縺ｮ遽・峇繧定ｶ・∴繧句､画峩縺ｯ谺｡ round 縺ｫ蛻・屬縺励※縺上□縺輔＞縲・
## Output formatting guard

- prompt 繧・final report 縺ｧ縺ｯ Markdown 繧定ｪｭ縺ｿ繧・☆縺丈ｿ昴▲縺ｦ縺上□縺輔＞縲・- nested triple-backtick 縺ｯ菴懊ｉ縺ｪ縺・〒縺上□縺輔＞縲・- command 縺ｮ萓九・ plain text 縺句挨縺ｮ fenced block 縺ｫ蛻・￠縺ｦ縺上□縺輔＞縲・
## Validation rules

docs-only 螟画峩縺ｧ縺ｯ縲∝ｰ代↑縺上→繧よｬ｡繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・
```bash
git diff --check
git status --short --branch
git diff --name-only origin/master...HEAD
```

behavior 螟画峩縺ｧ縺ｯ縲∬ｩｲ蠖薙☆繧玖ｿｽ蜉 validation 繧貞ｮ滓命縺励※縺上□縺輔＞縲・
- `bash -n pdx`
- `cargo check --locked --manifest-path tools/pdx-win/Cargo.toml`
- `cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml`
- `./pdx setup`
- `./pdx new smoke-report`
- `./pdx build smoke-report -Log`
- `test -f projects/smoke-report/output/report.pdf`

## Runtime / Docker / TeX rules

- Pandocker-X 縺ｯ Docker runtime 繧呈ｭ｣縺ｨ縺励※縺上□縺輔＞縲・- host TeX Live 繧貞燕謠舌↓縺励↑縺・〒縺上□縺輔＞縲・- template target 繧・TeX engine 縺ｮ雋ｬ蜍吶・ Docker image / runtime 蛛ｴ縺ｫ鄂ｮ縺・※縺上□縺輔＞縲・- `lualatex`, `platex`, `uplatex`, `pbibtex`, `dvipdfmx`, `latexmk` 繧剃ｽｿ縺・path 縺ｯ Docker runtime 縺ｮ荳ｭ縺ｫ髢峨§縺ｦ縺上□縺輔＞縲・
## Release publishing boundary

谺｡縺ｯ譏守､ｺ逧・↑險ｱ蜿ｯ縺後↑縺・剞繧顔ｦ∵ｭ｢縺ｧ縺吶・
- GitHub Release 縺ｮ菴懈・
- release asset upload
- checksum 縺ｮ蜀咲匱陦後ｄ蜈ｬ髢・- secrets / credentials 縺ｮ謫堺ｽ・- deployment key 縺ｮ螟画峩

## PR body required items

PR 譛ｬ譁・↓縺ｯ蠢・★谺｡繧貞・繧後※縺上□縺輔＞縲・
- Summary
- Changed Files
- What Changed
- Validation Run
- Scope Check
- Scope Exclusions
- Runtime / Docker / TeX Status
- Branch / Diff Gate
- Remaining Risks
- Handoff
- Related issue

## Replacement PR / stale PR rules

- 譌｢蟄・PR 繧堤ｽｮ縺肴鋤縺医ｋ蝣ｴ蜷医・縲〉eplacement PR 繧呈・遉ｺ縺励※縺上□縺輔＞縲・- stale 縺ｫ縺ｪ縺｣縺・PR 縺ｯ縺昴・縺ｾ縺ｾ謾ｾ鄂ｮ縺帙★縲∝ｿ・ｦ√↑繧・close 縺句ｷｮ縺玲崛縺医ｒ陦後▲縺ｦ縺上□縺輔＞縲・- 蜷後§ issue 繧定､・焚 PR 縺ｧ荳ｦ襍ｰ縺輔○縺ｪ縺・〒縺上□縺輔＞縲・
## Round completion audit

round 繧貞ｮ御ｺ・→縺ｿ縺ｪ縺吝燕縺ｫ谺｡繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・
- diff 縺・issue scope 縺ｫ蜿弱∪縺｣縺ｦ縺・ｋ
- forbidden files 縺悟・縺｣縺ｦ縺・↑縺・- validation 縺碁壹▲縺ｦ縺・ｋ
- PR 譛ｬ譁・′螳溷ｷｮ蛻・→荳閾ｴ縺励※縺・ｋ
- gpt-5.5 review 縺悟ｿ・ｦ√↑蝣ｴ蜷医・螳御ｺ・桶縺・↓縺励↑縺・
## gpt-5.5 review

safe for merge縲《afe for light human review縲ヽound complete縲“oal complete縲｜locked 縺ｮ譛邨ょ愛譁ｭ縺ｯ縲∝ｿ・ｦ√↑蝣ｴ蜷医・ gpt-5.5 review 繧堤ｵ後※縺九ｉ縺ｫ縺励※縺上□縺輔＞縲・
## Final report format

譛邨ょｱ蜻翫・谺｡縺ｮ鬆・ｺ上〒邁｡貎斐↓縺ｾ縺ｨ繧√※縺上□縺輔＞縲・
1. 菴輔ｒ螟画峩縺励◆縺・2. 縺ｩ縺ｮ validation 繧帝壹＠縺溘°
3. 譛溷ｾ・＆繧後◆ changed files 縺ｫ蜿弱∪縺｣縺ｦ縺・ｋ縺・4. 蜷ｫ縺ｾ繧後※縺・↑縺・ｦ∵ｭ｢繝輔ぃ繧､繝ｫ縺後≠繧九°
5. 蠢・ｦ√↑繧・next step

## Pandocker-X current issue order

迴ｾ陦後・謗ｨ螂ｨ蟇ｾ蠢憺・・谺｡縺ｧ縺吶・
1. `#10` Align Unix and Windows build failure semantics
2. `#11` Validate project names and prevent path traversal
3. `#12` Add PDF smoke tests for CI and release artifacts
4. `#9` Separate runtime root and workspace root for installed Windows usage
5. `#14` Introduce unified template target architecture
6. `#13` Consolidate LaTeX defaults/template/preamble ownership

## Documentation references

- `docs/agent/phase-round-issue-design-rules.md`
- `README.md`
