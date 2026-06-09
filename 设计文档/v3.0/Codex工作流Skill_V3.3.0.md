---
name: superright-engineering-workflow
description: Use this skill whenever working on the SuperRight/右键增强 Swift project or when the user asks to continue development with strict engineering workflow. It enforces module comments, documentation after each task, regression testing, Git commits, GitHub packaging/release upload when applicable, and clear reporting of unfinished work and next task direction.
---

# SuperRight Engineering Workflow

## Trigger

Use this skill when:
- Working in `/Users/maple/Documents/Project/Swift/右键增强` or `/Users/maple/Documents/Project/Swift/SuperRight`.
- The user asks to continue implementing, fixing, packaging, testing, documenting, or versioning the project.
- The user asks to follow the “finish one task → test → document → git commit → continue” workflow.

## Required Workflow

For every non-trivial task, follow this sequence:

1. Confirm current repository state.
2. Implement the smallest complete change that solves the current task.
3. Add or update comments for touched modules.
4. Update Markdown documentation for the completed task.
5. Run regression tests before committing.
6. Commit Git changes with a clear Chinese commit message.
7. For release/packaging/update tasks, build the distributable package and upload the required GitHub Release assets.
8. Report what was completed, what was tested, commit hashes, release assets, remaining unfinished tasks, and the recommended next task.

Do not skip steps unless the user explicitly asks to stop early. If a step cannot be completed, state the blocker clearly and do not pretend it passed.

## Module Comments

When changing source code:
- Add concise module-level comments for new or modified modules.
- Explain responsibility, boundary, and why the module exists.
- Add comments to critical entry points, IPC boundaries, permission-sensitive code, persistence logic, and cross-process behavior.
- Avoid noisy line-by-line comments for obvious Swift syntax.
- Keep comments accurate with the implemented behavior.

Minimum comment targets when touched:
- `Shared`: configuration models, IPC models, storage, permissions.
- `ExtensionCore`: menu building, action dispatching, Finder context conversion.
- `AppCore`: SwiftUI entry views, ViewModels, settings modules.
- `RightClickFinderExtension`: Finder menu entry, click handling, forwarding, monitored directories.
- Main App: app lifecycle, permission prompts, request queue handling, external app execution.

## Documentation After Each Task

After completing a task, update or create Markdown documentation under the existing design docs structure.

Preferred locations:
- Swift package docs: `/Users/maple/Documents/Project/Swift/SuperRight/设计文档/v3.0/`
- Changelog: `/Users/maple/Documents/Project/Swift/SuperRight/CHANGELOG.md`

Each completed task should document:
- Date and version/build if relevant.
- What changed.
- Files/modules affected.
- Regression commands and results.
- Manual verification steps if UI/Finder behavior changed.
- Known limitations and remaining tasks.

Do not create unnecessary auxiliary docs. Prefer updating the current version’s validation record, module description, and changelog.

## Regression Testing

Run regression tests before every commit.

Default commands:

```bash
cd /Users/maple/Documents/Project/Swift/SuperRight
swift test
```

```bash
cd /Users/maple/Documents/Project/Swift/右键增强
xcodebuild -project '右键增强.xcodeproj' -scheme '右键增强' -configuration Debug -destination 'platform=macOS' build
```

Validation rules:
- Start with the most relevant tests, then run broader tests before commit.
- If tests fail because of the current change, fix and rerun.
- If tests fail for unrelated reasons, do not fix unrelated issues; document the failure and exact evidence.
- For UI/package changes, verify generated app metadata when relevant using `Info.plist`.

## Git Commit Rules

After documentation and tests pass:
- Commit each repository separately when both `SuperRight` and `右键增强` are modified.
- Keep commits focused on the completed task.
- Do not commit build products, `DerivedData`, archives, zips, `.idea`, `.build`, or other generated files.
- Use clear Chinese commit messages, for example:
  - `实现常用目录真实配置与右键打开`
  - `补充 V3.3 模块注释与验证文档`
  - `统一应用名称和版本号`

Before committing:
- Run `git status --short` in each affected repo.
- Review `git diff --stat` and suspicious diffs.

After committing:
- Run `git status --short` again.
- Report commit hashes.

## Packaging and GitHub Release Rules

When the task involves packaging, releasing, Sparkle updates, version bumps, or the user asks to put the app on GitHub:

1. Build the Release app and package the DMG using the project’s existing scripts or documented release commands.
2. Generate or update Sparkle metadata when applicable, including `appcast.xml` and signatures.
3. Upload the DMG, `appcast.xml`, release notes, and any required verification files to the correct GitHub Release or release-assets repository.
4. Verify uploaded assets from GitHub, not only from local disk. Prefer `gh release view`, `gh release download`, or HTTP status checks for public assets.
5. Reinstall or launch the packaged app from the generated artifact when the task is installation/update related, then re-register Finder Extension from `/Applications/右键增强.app`.
6. Document release asset names, GitHub URLs, version/build, Sparkle appcast status, and manual verification results.

Do not claim a release is complete until the GitHub assets are uploaded and verified. Do not claim Developer ID notarization unless a Developer ID certificate and `notarytool` submission actually succeeded.

## Final Report Format

At the end of each completed task, report concisely:

- Completed changes.
- Regression test results.
- Documentation updated.
- Git commits created.
- GitHub Release assets uploaded and verified, when applicable.
- Worktree cleanliness.
- Remaining unfinished tasks.
- Recommended next task direction.

Always include concrete file references with line numbers when useful.

## Remaining Task Tracking

At the end of each task, explicitly list unfinished or partially implemented areas. For this project, common remaining areas include:
- 文件/文件夹图标功能。
- 工具箱功能。
- 新建文件模板导入真实模板文件。
- 右键菜单分组/子菜单语义。
- 打包、安装、Finder Extension 重启验证。

If the current work changes this list, update it in the relevant Markdown documentation and final report.

## Quality Bar

- Prefer root-cause fixes over temporary patches.
- Keep changes small, coherent, and testable.
- Preserve existing project style.
- Do not silently change unrelated behavior.
- Do not claim completion without tests or a documented blocker.
