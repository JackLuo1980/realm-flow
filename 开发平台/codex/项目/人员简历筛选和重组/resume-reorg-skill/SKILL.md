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
