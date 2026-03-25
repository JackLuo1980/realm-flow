---
name: resume-reorg-skill
description: Use when organizing many resumes by graduation-year-based seniority tiers, deduplicating client/project/work-content/timeline records, and rewriting resumes with controlled completion and differentiation.
---

# Resume Reorganization

This skill helps turn a batch of resumes into:

- a graduation-year-based level table
- a deduplicated client/project/work-content/timeline inventory
- a customer/project/content clean list with resume and contract sources merged
- rewritten resumes that satisfy client rules while staying differentiated

## Use this skill when

- the user has many resumes to standardize or restructure
- seniority must be derived from graduation year
- project experience needs to be deduplicated across people
- missing resume content should be filled from a shared project inventory
- repeated phrasing must be reduced across the final resumes

## Core inputs

Expect some or all of the following:

- a spreadsheet with person names and graduation year
- existing resumes
- project records with client, project name, project content, and time range
- client-specific grading rules
- a list of approved project facts or a second-pass review list from the user

## Workflow

1. Read the client rules first.
2. Convert graduation year into experience years using the client's rule.
3. Map each person to a tier or level.
4. Extract every project record into a normalized table with:
   - person
   - customer name
   - client
   - project name
   - project content
   - time range
   - source file or row
5. Deduplicate records by normalized client + project + content + time range.
6. Merge near-duplicates only when the facts are the same.
7. Build a shared project inventory that can be reused during resume rewriting.
8. Build a customer/project/content clean list that also includes contract summaries, with contract project families merged to a single standard row.
9. Extract each resume into a person-level summary table.
10. Rewrite each resume to meet the client's minimum requirements.
11. Fill gaps only from:
   - the deduplicated inventory
   - clearly supported similar experiences
   - the user's follow-up review list
   - reasonable experience augmentation that stays consistent with the existing facts
12. Reduce repetition across resumes by varying:
   - project order
   - wording
   - emphasis
   - sentence structure
13. When the user provides a team-resume template, populate the template directly and save a new file using the pattern `客户名称人员团队简历-姓名.docx` or the user's requested naming convention.
14. Before finalizing any team resume, verify that the `姓名` field is populated and matches the source person exactly; never leave the name blank.
14. For template-based rewriting, preserve the source facts, align the wording to the target role, and prefer bank/risk-management phrasing when the role belongs to that family.
15. For team-resume templates, use the following field rules:
   - `出生年月` should use the `xxxx.xx.xx` format when supported by source data; otherwise leave it blank.
   - If the template field label is `年龄`, the value cell should contain only the integer age as of the current date. Compute it from the person's birth date and do not leave a dotted date in the `年龄` value cell.
   - If the template field label is `出生年月`, keep the value as a dotted birth date in `xxxx.xx.xx` format and do not replace it with an integer age.
   - When a team resume is regenerated, keep the birth-date format consistent with `参加工作时间` style conventions in this project, and normalize all birth dates to dotted format.
   - `参加工作时间` should be filled from the graduation time in the source data, because the project rule treats graduation as the work-start date.
   - `参加工作时间` should use the `xxxx.xx` format.
   - `相关领域工作年限` should contain only the numeric year count, not Chinese text like `年`, and should be calculated from the graduation/work-start date to the current date, rounded down to whole years.
   - `学历及学位` should be expanded to the combined form that matches the degree level, for example:
     - `本科学历` -> `本科学历、学士学位`
     - `硕士学历` -> `硕士学历、硕士学位`
     - `博士学历` -> `博士学历、博士学位`
   - For the `从业资质证书` section, when the certificate is `PMP`, write the certificate name as `PMP` and the level as `中级`; do not combine them into a single cell or string like `中级PMP`.
   - In `从业资质证书`, keep certificate name and level in the same row and place the level in the `级别` cell; do not split one certificate across two visible rows.
   - Apply the same rule to other level-bearing certificates such as `信息系统项目管理师` + `高级`.
   - Treat Chinese words like `初级`, `中级`, and `高级` as levels, not certificate names. Treat entries like `Oracle` as certificate names. Rebuild the certificate table accordingly when the source resume uses that Chinese layout convention.
   - `职称证书` should be filled with `无` when the source resume does not list one.
   - `毕业学校` should keep only the graduation year plus school and major, and append `专业` after the major text only when the major does not already end with `专业`; omit month/day details unless the user explicitly asks for them.
16. After generating a batch, run a hard check for blank critical fields, especially `姓名`, before telling the user the files are ready.
17. When inferring `拟在本项目任职`, prioritize explicit job titles and project-role fields from the source resume; do not let responsibility descriptions alone dominate the role classification.
18. For Word resumes in this project, keep the font fixed to `仿宋` with size `小四` throughout the document. Do not change the font family or size unless the user explicitly requests a different style.
19. When rewriting project experience for a risk-related target role, prefer case titles from the approved case list and allow multiple risk cases to be combined or sequenced to better match the target person's required risk-domain experience.
   - Project timelines should read as a coherent timeline rather than a collection of repeated `xxxx-至今` entries; where possible, select finite date ranges from the approved case list and chain them into a continuous work history.
   - For newly generated resumes, prefer continuous project date ranges and avoid stacking multiple `至今` ranges unless the source explicitly requires it.
   - Ensure every project date range is later than the person's employment start date; do not place project experience before the recorded start-of-employment date.
   - `学历及学位` may be expanded to a combined form like `本科学历、学士学位` when the source resume clearly supports it, and should follow the same pattern for master and doctoral degrees.
   - `毕业学校` should keep only school + major; omit the graduation year in that cell unless the template explicitly asks for it.
   - If the work-experience section has 4 columns, merge start and end time into the first column as a date range and place the detailed duties in the `备注` column.
   - Do not truncate project history when the source resume has more entries than the template's visible rows; extend the table with cloned rows and keep all supported project experiences.
   - If `相关领域工作年限` is not explicitly stated, calculate it as `current date - first employment start date` and round down to whole years, unless the client provides a different rule.
20. For large batches, process resumes in one pass per layout family: cluster sources by table structure first, then reuse the same extraction mapping for every file in that cluster instead of re-parsing each resume from scratch.
21. Prefer batch validation over repeated full-document inspection: verify critical fields first (`姓名`, dates, roles, certificate layout, project continuity), then only reopen files that fail the check or look ambiguous.
22. When many resumes share the same source pattern, reuse the same transformation rule set for that pattern and only vary the person-specific facts; avoid rebuilding the mapping file-by-file.
23. In the project-experience section, write entries in reverse chronological order (newest first, oldest last) and keep one project per row.
24. When a person still has an active current project, write that latest row as `xxxx.xx-至今`; keep older rows finite and do not stack multiple `至今` entries unless the source resume already does so.
25. When populating a team-resume template, compress project names and remarks enough to fit the row layout cleanly; prefer concise, fact-preserving wording over long narrative sentences so the project section remains visually aligned with the template.

## Guardrails

- Treat graduation year as the starting point for experience counting unless the client rule says otherwise.
- Prefer a single normalized customer name per customer family, such as `平安银行` or `国开行`, and keep aliases only in a mapping table if needed.
- Do not invent employers, clients, projects, dates, or responsibilities.
- If a detail is not supported by source data or a clearly approved inference, mark it as `待确认`.
- Preserve factual conflicts instead of silently resolving them.
- Keep the same source fact from appearing in identical wording across many resumes.
- Do not over-rewrite a resume if the client would lose required evidence.
- For overly simple experience entries, enrich them only by expanding the description of:
  - scope
  - responsibilities
  - collaboration points
  - delivery process
  - tools or methods plausibly implied by the original record
- Any enrichment must remain consistent with the source facts and the user's approved project inventory.
- If a useful enhancement is only an inference, label it as `建议补充` or `待确认` rather than presenting it as confirmed fact.

## Suggested outputs

- `客户名称归一表`
- `等级规则表`
- `项目去重清单`
- `客户名称-项目名称-项目内容清单`
- `合同信息汇总表`
- `客户-项目-内容-时间阶段汇总表`
- `简历信息提取汇总表`
- `个人简历重组稿`
- `差异化检查表`
- `待确认事项表`
- `团队简历模板填充稿`

## Practical writing rules

- Prefer short, concrete bullets over long paragraphs.
- Reuse verified facts, not generic filler.
- If several resumes share the same base project, vary the framing while keeping the facts stable.
- If a client asks for a specific hierarchy, apply that hierarchy consistently across all resumes.
- When a project line is too thin, improve it by making the work output, process, and business value more explicit, but never add unsupported employers, dates, or project names.

## Default response style

When using this skill, answer with:

- the normalized customer name being applied
- the seniority rule being applied
- the deduplication rule being applied
- the extraction summary fields being used
- the resume rewrite rule being applied
- any data gaps that need user confirmation
