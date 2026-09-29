// cv.typ — single-column CV rendered from cv.yaml.
//
// Build with `make` from the repo root (pinned Typst container, see Makefile).
// cv.yaml, private.yaml and photo.jpg are read relative to this file, and the
// fonts live in ./fonts, hence --font-path. Manual equivalent:
//   typst compile --font-path src/fonts --input photo=false src/cv.typ cv.pdf
//
// Inputs (sys.inputs values are always strings):
//   lang     "fr" (default) | "en"        — language of {fr, en} text.
//   photo    "true" (default) | "false"   — show/hide the header photo.
//   private  "false" (default) | "true"   — load the git-ignored private.yaml (phone).
//   variant  "full" (default) | <tag>     — see keep() below for the tag rules.
//   version  "" (default) | "v3.0.0"…    — shown in the footer (`git describe`).

// ----------------------------------------------------------------------------
// Inputs & data
// ----------------------------------------------------------------------------
#let data = yaml("cv.yaml")
#let lang = sys.inputs.at("lang", default: "fr")
#let show-photo = sys.inputs.at("photo", default: "true") != "false"
#let variant = sys.inputs.at("variant", default: "full")
#let version = sys.inputs.at("version", default: "")
#let priv = if sys.inputs.at("private", default: "false") == "true" {
  yaml("private.yaml")
} else { (:) }

// ----------------------------------------------------------------------------
// Localisation helpers
// ----------------------------------------------------------------------------
// Pick the current language out of a {fr, en} mapping; pass plain values through.
#let t(x) = if type(x) == dictionary and lang in x { x.at(lang) } else { x }

// Flag unfilled placeholders so a provisional value never ships unnoticed.
#let T(x) = {
  let s = t(x)
  if type(s) == str and s.starts-with("TODO") {
    text(fill: red, style: "italic")[#s]
  } else { s }
}

// Section labels and fixed words.
#let L = (
  fr: (
    summary: "Profil", experience: "Expérience", projects: "Projets",
    education: "Formation", skills: "Compétences", languages: "Langues",
    certifications: "Certifications", volunteering: "Bénévolat",
    present: "présent", remote: "à distance", colon: " : ",
    source: "Ce CV est généré depuis son code source : ",
  ),
  en: (
    summary: "Profile", experience: "Experience", projects: "Projects",
    education: "Education", skills: "Skills", languages: "Languages",
    certifications: "Certifications", volunteering: "Volunteering",
    present: "present", remote: "remote", colon: ": ",
    source: "This CV is generated from its source code: ",
  ),
).at(lang, default: (:))

// Short month names, indexed 1..12.
#let months = (
  fr: ("janv.", "févr.", "mars", "avr.", "mai", "juin",
       "juil.", "août", "sept.", "oct.", "nov.", "déc."),
  en: ("Jan", "Feb", "Mar", "Apr", "May", "Jun",
       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
).at(lang, default: ("", "", "", "", "", "", "", "", "", "", "", ""))

// "YYYY-MM" -> "juil. 2024" ; none (YAML null) -> "présent"/"present".
#let fmt-date(d) = {
  if d == none { return L.present }
  let parts = str(d).split("-")
  let year = parts.at(0)
  let m = int(parts.at(1, default: "1"))
  months.at(m - 1) + " " + year
}
// A one-month entry (start == end) shows a single date instead of a range.
#let date-range(start, end) = if start == end { fmt-date(start) } else {
  fmt-date(start) + " – " + fmt-date(end)
}

// Keep an entry for the current variant:
//   variant == "full"  -> keep everything EXCEPT entries tagged "extra"
//                         (redundant school projects hidden from the default CV).
//   variant == <tag>   -> keep "core" entries plus those carrying <tag>. An
//                         "extra" entry carrying <tag> then reappears — that is
//                         the point of per-offer selection.
#let keep(e) = {
  let tags = e.at("tags", default: ())
  if variant == "full" {
    "extra" not in tags
  } else {
    ("core" in tags) or (variant in tags)
  }
}

// A variant may override the headline title and/or summary under
// headline.variants.<tag> in cv.yaml; whatever it leaves out keeps the default.
#let headline = (
  data.headline + data.headline.at("variants", default: (:)).at(variant, default: (:))
)

// ----------------------------------------------------------------------------
// Document & page setup (ATS-friendly, PDF/UA compatible)
// ----------------------------------------------------------------------------
#set document(
  title: data.header.name + " — CV",
  author: data.header.name,
  keywords: ("CV", "résumé", "Enoal Fauchille-Bolle"),
)
#set text(
  lang: lang,
  font: ("Hanken Grotesk", "Libertinus Serif"),
  size: 10pt,
  hyphenate: false,          // never split keywords like "TypeScript"
)
#set par(justify: false, leading: 0.6em)
#let accent = rgb("#1f6f8b")

#set page(paper: "a4", margin: (x: 1.5cm, y: 1.4cm))

#show link: set text(fill: accent)

// Section heading: uppercase title in Dosis with an accent rule underneath.
#let section(title) = {
  v(6pt)
  block(width: 100%, breakable: false)[
    #text(font: "Dosis", weight: "bold", size: 12pt, fill: accent, tracking: 0.5pt)[
      #upper(title)
    ]
    #v(-4pt)
    #line(length: 100%, stroke: 0.6pt + accent)
  ]
  v(3pt)
}

// One dated entry: bold title, subtitle and place on the same line, right-aligned
// dates, bullets, and an optional tech stack line (plain selectable words, no
// icons — ATS-safe).
#let entry(title, subtitle, dates, place: none, tech: (), bullets: ()) = {
  block(width: 100%, breakable: false, above: 6pt)[
    // Typst spaces blocks by 1.2em by default; keep an entry's lines tight.
    #set par(spacing: 0.6em)
    #set block(spacing: 0.6em)
    #grid(columns: (1fr, auto), column-gutter: 8pt,
      [#text(weight: "bold")[#title]#if subtitle != none {
        text(fill: rgb("#333333"))[ · #subtitle#if place != none [ · #place]]
      }],
      text(fill: rgb("#555555"))[#dates],
    )
    #if bullets.len() > 0 {
      set text(size: 9.5pt)
      list(..bullets.map(b => T(b)))
    }
    #if tech.len() > 0 {
      set text(size: 8.5pt, fill: accent)
      tech.join(" · ")
    }
  ]
}

// ----------------------------------------------------------------------------
// Header
// ----------------------------------------------------------------------------
#let hd = data.header
#let contact = {
  set text(size: 9pt)
  let items = (
    link("mailto:" + hd.email)[#hd.email],
  )
  if "phone" in priv { items.push(priv.phone) }
  items.push(link(hd.website)[#hd.website.replace("https://", "")])
  // Full https:// URLs in the text: ATS parsers skip profiles without them (#29).
  items.push(link("https://github.com/" + hd.github)[#("https://github.com/" + hd.github)])
  items.push(link("https://linkedin.com/in/" + hd.linkedin)[#("https://linkedin.com/in/" + hd.linkedin)])
  // Boxed items wrap between entries, never inside a URL.
  items.map(box).join(text(fill: rgb("#999999"))[  ·  ])
}

#let identity = [
  #text(font: "Dosis", weight: "bold", size: 26pt)[#hd.name]
  #v(-6pt)
  // The location sits on the title line: at the end of the contacts it wrapped
  // onto a line of its own once the photo narrowed the column.
  #text(size: 12pt, fill: accent, weight: "medium")[#T(headline.title)]#text(size: 12pt, fill: rgb("#555555"))[ · #t(hd.location)]
  #v(2pt)
  #contact
]

#if show-photo {
  grid(columns: (1fr, auto), column-gutter: 14pt, align: horizon,
    identity,
    box(clip: true, radius: 4pt, width: 2.6cm, height: 2.6cm,
      image(hd.photo, width: 100%, height: 100%, fit: "cover",
        alt: "Portrait photo of " + hd.name)),
  )
} else {
  identity
}

// ----------------------------------------------------------------------------
// Profile / summary
// ----------------------------------------------------------------------------
#let summary = T(headline.summary)
#if summary != none {
  section(L.summary)
  summary
}

// ----------------------------------------------------------------------------
// Experience
// ----------------------------------------------------------------------------
#let exp = data.at("experience", default: ()).filter(keep)
#if exp.len() > 0 {
  section(L.experience)
  for e in exp {
    let place = if e.at("remote", default: false) { L.remote } else { t(e.location) }
    let org = if e.at("url", default: none) != none { link(e.url)[#e.org] } else { e.org }
    entry(
      T(e.role), org, date-range(e.start, e.end),
      place: place, tech: e.at("tech", default: ()), bullets: e.at("bullets", default: ()),
    )
  }
}

// ----------------------------------------------------------------------------
// Projects
// ----------------------------------------------------------------------------
#let projs = data.at("projects", default: ()).filter(keep)
#if projs.len() > 0 {
  section(L.projects)
  for p in projs {
    let name = if p.at("url", default: none) != none { link(p.url)[#p.name] } else { p.name }
    entry(
      name, T(p.role), date-range(p.start, p.end),
      tech: p.at("tech", default: ()), bullets: p.at("bullets", default: ()),
    )
  }
}

// ----------------------------------------------------------------------------
// Education
// ----------------------------------------------------------------------------
#let edu = data.at("education", default: ()).filter(keep)
#if edu.len() > 0 {
  section(L.education)
  for e in edu {
    entry(
      e.school, T(e.degree), date-range(e.start, e.end),
      place: t(e.location), bullets: e.at("bullets", default: ()),
    )
  }
}

// ----------------------------------------------------------------------------
// Skills
// ----------------------------------------------------------------------------
// Spoken languages are one more line of this section, not a section of their own.
#let sk = data.at("skills", default: ()).filter(keep)
#let langs = data.at("languages", default: ()).filter(keep)
#if sk.len() > 0 or langs.len() > 0 {
  section(L.skills)
  for s in sk {
    block(above: 4pt)[
      #text(weight: "bold")[#T(s.group)#L.colon]#s.at("items", default: ()).join(", ")
    ]
  }
  if langs.len() > 0 {
    block(above: 4pt)[
      #text(weight: "bold")[#L.languages#L.colon]#langs.map(l => [#T(l.name) (#T(l.level))]).join(", ")
    ]
  }
}

// ----------------------------------------------------------------------------
// Certifications
// ----------------------------------------------------------------------------
#let certs = data.at("certifications", default: ()).filter(keep)
#if certs.len() > 0 {
  section(L.certifications)
  for c in certs {
    let name = if c.at("url", default: none) != none {
      link(c.url)[#c.name]
    } else { c.name }
    block(above: 4pt)[#name — #c.issuer #h(1fr) #text(fill: rgb("#555555"))[#fmt-date(c.at("date", default: none))]]
  }
}

// ----------------------------------------------------------------------------
// Volunteering
// ----------------------------------------------------------------------------
#let vol = data.at("volunteering", default: ()).filter(keep)
#if vol.len() > 0 {
  section(L.volunteering)
  for v in vol {
    entry(
      T(v.role), v.org, date-range(v.start, v.end),
      place: t(v.location), bullets: v.at("bullets", default: ()),
    )
  }
}

// ----------------------------------------------------------------------------
// Source line
// ----------------------------------------------------------------------------
// Pinned into the bottom margin, so it costs no line of content. Not a page
// footer: PDF/UA marks footers as artifacts, which may not contain links.
#place(bottom + center, dy: 0.8cm, text(size: 7.5pt, fill: rgb("#999999"))[
  #L.source#link(data.header.source)[#data.header.source]#if version != "" [ · #version]
])
