# Phase / Round / Issue Design Rules

## 逶ｮ逧・
縺薙・譁・嶌縺ｯ縲￣andocker-X 縺ｮ Phase / Round / Issue 縺ｮ蛻・ｊ蛻・￠譁ｹ繧貞ｮ夂ｾｩ縺励∪縺吶・issue 縺斐→縺ｮ PR縲〉eplacement PR縲《tale PR 縺ｮ謇ｱ縺・√◎縺励※迴ｾ蝨ｨ縺ｮ issue 鬆・ｒ縺薙％縺ｧ蝗ｺ螳壹＠縺ｾ縺吶・
## Definitions

- Phase: 隍・焚 issue 繧偵∪縺溘＄螟ｧ縺阪↑蜿悶ｊ邨・∩縺ｧ縺吶・- Round: Codex 縺ｮ 1 蝗槭・螳溯｡後〒縺吶・- Issue: 1 PR 縺ｫ蜿弱ａ繧九Ξ繝薙Η繝ｼ蜿ｯ閭ｽ縺ｪ蜊倅ｽ阪〒縺吶・
## Design rules

- Phase 繧・1 round 縺ｫ謚ｼ縺苓ｾｼ縺ｾ縺ｪ縺・〒縺上□縺輔＞縲・- 1 issue 繧定､・焚縺ｮ辟｡髢｢菫・PR 縺ｫ蛻・牡縺励↑縺・〒縺上□縺輔＞縲・- 1 branch, 1 issue, 1 PR 繧貞次蜑・↓縺励※縺上□縺輔＞縲・- 螳溯｣・」alidation縲‥ocumentation 縺ｯ蜷後§ issue scope 縺ｫ蜷医ｏ縺帙※縺上□縺輔＞縲・
## Branch / PR rules

- Base branch: `master`
- Branch name: `codex/<issue-number>-<short-description>`
- PR title 縺ｯ issue 縺ｮ蜀・ｮｹ縺悟・縺九ｋ遏ｭ縺・ｂ縺ｮ縺ｫ縺励※縺上□縺輔＞縲・- PR body 縺ｫ縺ｯ蠢・磯・岼繧呈純縺医※縺上□縺輔＞縲・
PR body 蠢・磯・岼:

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

## Validation rules

docs-only 縺ｮ縺ｨ縺阪・蟆代↑縺上→繧よｬ｡繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・
```bash
git diff --check
git status --short --branch
git diff --name-only origin/master...HEAD
```

behavior 螟画峩縺ｧ縺ｯ縲∝ｯｾ雎｡縺ｫ蠢懊§縺ｦ霑ｽ蜉 validation 繧定｡後▲縺ｦ縺上□縺輔＞縲・
```bash
bash -n pdx
cargo check --locked --manifest-path tools/pdx-win/Cargo.toml
cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml
./pdx setup
./pdx new smoke-report
./pdx build smoke-report -Log
test -f projects/smoke-report/output/report.pdf
```

## Runtime / Docker / TeX rules

- Pandocker-X 縺ｮ讓呎ｺ・build 縺ｯ Docker runtime 繧剃ｽｿ縺｣縺ｦ縺上□縺輔＞縲・- host TeX Live 繧呈ｭ｣縺ｨ縺励↑縺・〒縺上□縺輔＞縲・- template target 縺ｯ Docker image / runtime 縺ｮ雋ｬ蜍吶→縺励※謇ｱ縺｣縺ｦ縺上□縺輔＞縲・- `lualatex`, `platex`, `uplatex`, `pbibtex`, `dvipdfmx`, `latexmk` 縺ｮ蜿ｯ逕ｨ諤ｧ縺ｯ Docker 蛛ｴ縺ｧ菫晁ｨｼ縺励※縺上□縺輔＞縲・
## Release publishing boundary

谺｡縺ｯ譏守､ｺ逧・↑ release 菴懈･ｭ縺ｧ縺ｪ縺・剞繧顔ｦ∵ｭ｢縺ｧ縺吶・
- GitHub Release 縺ｮ菴懈・
- release asset upload
- checksum 縺ｮ蜈ｬ髢・- secrets / credentials 縺ｮ謫堺ｽ・- deployment key 縺ｮ螟画峩

## Unified template target rule

- user-facing route 縺ｯ蜊倡ｴ斐↓菫昴▲縺ｦ縺上□縺輔＞縲・- `pdx new <name>`
- `pdx new <name> --target <target-id>`
- `pdx build <name>`
- 縺薙ｌ莉･螟悶・ top-level command 繧貞｢励ｄ縺励※ workflow 繧貞・蟯舌＆縺帙↑縺・〒縺上□縺輔＞縲・
## Replacement PR / stale PR rules

- replacement PR 繧剃ｽ懊ｋ縺ｨ縺阪・縲∵立 PR 縺・stale 縺ｫ縺ｪ縺｣縺溘％縺ｨ繧呈・險倥＠縺ｦ縺上□縺輔＞縲・- stale PR 縺ｯ merge 蟇ｾ雎｡縺ｫ縺励↑縺・〒縺上□縺輔＞縲・- 蜷後§ issue 縺ｮ荳ｦ襍ｰ PR 繧呈叛鄂ｮ縺励↑縺・〒縺上□縺輔＞縲・
## Round completion audit

round 螳御ｺ・燕縺ｫ谺｡繧堤｢ｺ隱阪＠縺ｦ縺上□縺輔＞縲・
- diff 縺・issue scope 縺九ｉ縺ｯ縺ｿ蜃ｺ縺励※縺・↑縺・- forbidden files 縺悟・縺｣縺ｦ縺・↑縺・- validation 縺碁壹▲縺ｦ縺・ｋ
- PR 譛ｬ譁・′螳溷ｷｮ蛻・→荳閾ｴ縺励※縺・ｋ
- gpt-5.5 review 縺悟ｿ・ｦ√↑蝣ｴ蜷医・譛ｪ螳御ｺ・・縺ｾ縺ｾ縺ｫ縺吶ｋ

## gpt-5.5 review

safe for merge縲《afe for light human review縲ヽound complete縲“oal complete縲｜locked 縺ｮ譛邨ょ愛譁ｭ縺ｯ縲∝ｿ・ｦ√↓蠢懊§縺ｦ gpt-5.5 review 繧貞燕謠舌↓縺励※縺上□縺輔＞縲・
## Stop conditions

谺｡縺後≠繧後・豁｢繧√※蝣ｱ蜻翫＠縺ｦ縺上□縺輔＞縲・
- repository mismatch
- wrong base branch
- issue scope exceeded
- unrelated working tree changes
- validation failure outside the scope
- Docker or TeX runtime gap
- release publishing is implied but not authorized
- required review is unavailable

## Final report format

譛邨ょｱ蜻翫・谺｡縺ｮ鬆・ｺ上〒譖ｸ縺・※縺上□縺輔＞縲・
1. 螟画峩縺ｮ隕∫せ
2. validation 邨先棡
3. changed files
4. forbidden files 縺悟性縺ｾ繧後※縺・↑縺・｢ｺ隱・5. 蠢・ｦ√↑繧画ｬ｡縺ｮ荳謇・
## Current issue order

迴ｾ陦後・謗ｨ螂ｨ蟇ｾ蠢憺・・谺｡縺ｧ縺吶・
1. `#10` Align Unix and Windows build failure semantics
2. `#11` Validate project names and prevent path traversal
3. `#12` Add PDF smoke tests for CI and release artifacts
4. `#9` Separate runtime root and workspace root for installed Windows usage
5. `#14` Introduce unified template target architecture
6. `#13` Consolidate LaTeX defaults/template/preamble ownership

## Related reference

- `docs/agent/codex-round-batch-execution-guardrails.md`
