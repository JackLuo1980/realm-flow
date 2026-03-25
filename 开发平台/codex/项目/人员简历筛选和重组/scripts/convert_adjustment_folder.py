from __future__ import annotations

import argparse
import re
from pathlib import Path

from docx import Document

from convert_resumes_to_new_template import (
    CertRow,
    ProjectRow,
    ResumeData,
    compute_age_from_birth,
    compute_work_years,
    extract_resume_data,
    fill_new_template,
    keyword_summary,
    month_diff,
    normalize_degree_text,
    normalize_school_text,
    normalize_text,
    parse_date_range,
)


def person_from_raw_filename(path: Path) -> str:
    m = re.search(r"\+([^+]+?)\+工作简历", path.name)
    if m:
        person = m.group(1)
    else:
        person = path.stem.replace("工作简历", "").replace("+", "").strip()
    return re.sub(r"\d+$", "", person)


def select_latest_team_resume(roots: list[Path]) -> dict[str, Path]:
    latest: dict[str, tuple[float, Path]] = {}
    pattern = re.compile(r"国开行人员团队简历-(.+?)(?:_v(\d+(?:\.\d+)?))?\.docx$")
    for root in roots:
        for path in root.rglob("国开行人员团队简历-*.docx"):
            m = pattern.match(path.name)
            if not m:
                continue
            person = re.sub(r"\d+$", "", m.group(1))
            ver = float(m.group(2)) if m.group(2) else -1.0
            cur = latest.get(person)
            if cur is None or ver > cur[0]:
                latest[person] = (ver, path)
    return {k: v[1] for k, v in latest.items()}


def parse_raw_resume(path: Path) -> ResumeData:
    doc = Document(str(path))
    table = doc.tables[0]

    name = normalize_text(table.rows[1].cells[1].text)
    school = normalize_school_text(
        f"{normalize_text(table.rows[2].cells[4].text)} {normalize_text(table.rows[3].cells[1].text)}"
    )
    degree = normalize_degree_text(normalize_text(table.rows[3].cells[4].text))
    title = normalize_text(table.rows[4].cells[4].text)
    dept = normalize_text(table.rows[4].cells[1].text)
    summary = normalize_text(table.rows[5].cells[1].text)
    work_years = normalize_text(table.rows[1].cells[4].text).replace("年", "").replace(".5", "")
    if "." in work_years:
        work_years = work_years.split(".")[0]
    work_start = ""
    if normalize_text(table.rows[9].cells[0].text):
        start = normalize_text(table.rows[9].cells[0].text).replace("/", ".")
        m = re.match(r"(\d{4})\.(\d{1,2})", start)
        if m:
            work_start = f"{int(m.group(1))}.{int(m.group(2)):02d}"
    if not work_start:
        grad = normalize_text(table.rows[2].cells[1].text)
        m = re.match(r"(\d{4})年(\d{1,2})月", grad)
        if m:
            work_start = f"{int(m.group(1))}.{int(m.group(2)):02d}"
    related_years = work_years or compute_work_years(work_start)
    role_years = related_years

    certs = [CertRow(name="无", level="", major="", note="")]
    if len(table.rows) > 23:
        cert_text = normalize_text(table.rows[23].cells[1].text)
        if cert_text and cert_text != "无":
            certs = [CertRow(name=cert_text, level="", major="", note="")]

    projects: list[ProjectRow] = []
    for row in table.rows[13:]:
        first = normalize_text(row.cells[0].text)
        if not first or first in {"能力与资质", "业务与技术能力详述", "资质认证", "参与培训", "技能标签"}:
            break
        start = normalize_text(row.cells[0].text).replace("/", ".")
        end = normalize_text(row.cells[1].text).replace("/", ".")
        date_text = f"{start}-{'至今' if end == '至今' else end}"
        project_name = normalize_text(row.cells[2].text)
        role = normalize_text(row.cells[3].text)
        duty = normalize_text(row.cells[5].text)
        months = ""
        try:
            sy, sm, ey, em = parse_date_range(date_text)
            months = str(month_diff(sy, sm, ey, em))
        except Exception:
            pass
        projects.append(
            ProjectRow(
                date_text=date_text,
                name=project_name,
                institution="",
                role=role,
                duty=duty,
                months=months,
                content="",
            )
        )

    age = ""
    grad = normalize_text(table.rows[2].cells[1].text)
    m = re.match(r"(\d{4})年(\d{1,2})月", grad)
    if m:
        approx_birth_year = int(m.group(1)) - 22
        age = compute_age_from_birth(approx_birth_year, 1, 1)

    summary_text = summary or keyword_summary(projects)
    return ResumeData(
        name=name,
        age=age,
        id_number="",
        school=school,
        degree=degree,
        work_start=work_start,
        work_years=work_years or compute_work_years(work_start),
        related_years=related_years or compute_work_years(work_start),
        target_role=title or "开发",
        role_years=role_years or compute_work_years(work_start),
        summary=summary_text,
        cert_summary="；".join(c.name for c in certs if c.name) if certs else "无",
        certs=certs,
        projects=projects,
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-root", required=True)
    parser.add_argument("--template", required=True)
    parser.add_argument("--team-roots", nargs="+", required=True)
    args = parser.parse_args()

    raw_root = Path(args.raw_root)
    template = Path(args.template)
    latest = select_latest_team_resume([Path(x) for x in args.team_roots])

    processed = 0
    fallback = 0
    for raw in sorted(raw_root.rglob("*.docx")):
        person = person_from_raw_filename(raw)
        source = latest.get(person)
        if source:
            data = extract_resume_data(source)
        else:
            data = parse_raw_resume(raw)
            fallback += 1
        output = raw.with_name(raw.stem + "+new.docx")
        fill_new_template(template, data, output)
        processed += 1
        print(f"OK {raw} -> {output} (source={source or 'RAW'})")

    print(f"processed={processed}")
    print(f"fallback_raw={fallback}")


if __name__ == "__main__":
    main()
