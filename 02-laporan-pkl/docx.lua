-- docx.lua: penomoran heading dan cover page untuk output DOCX.
--  - Heading 1: "BAB I PENDAHULUAN" (huruf kapital, angka romawi)
--  - Heading 2: "1.1. Sub Bab" (titik di akhir nomor)
--  - Heading 3: "1.1.1 Sub Sub Bab"
--  - Heading dengan atribut {-} (unnumbered) dilewati tanpa penomoran.
--  - Cover page dibangun dari metadata (logo, judul, penulis, institusi)
--    meniru cover PDF, menggantikan title block bawaan pandoc.
--
-- Dipakai lewat `pandoc ... --lua-filter=docx.lua --reference-doc=reference.docx`.

local bab = 0
local sub = 0
local subsub = 0
local toc_entries = {}
local chapter_prefix = "BAB "
local chapter_num_fmt = "roman"
local sub_dot = true
local subsub_dot = false
local doc_margins = { top = 1134, right = 1417, bottom = 1701, left = 1417 }

local function dim_to_twips(val, fallback)
  if not val or val == "" then return fallback end
  local num, unit = val:match("^%s*([0-9]+%.?[0-9]*)%s*([a-zA-Z]+)%s*$")
  if not num then return fallback end
  local n = tonumber(num)
  if not n then return fallback end
  unit = unit:lower()
  if unit == "cm" then
    return math.floor(n * 566.929133858 + 0.5)
  elseif unit == "mm" then
    return math.floor(n * 56.6929133858 + 0.5)
  elseif unit == "in" then
    return math.floor(n * 1440 + 0.5)
  elseif unit == "pt" then
    return math.floor(n * 20 + 0.5)
  end
  return fallback
end

local function is_unnumbered(el)
  for _, cls in ipairs(el.attr.classes or {}) do
    if cls == "unnumbered" then
      return true
    end
  end
  return false
end

local function roman(n)
  local map = {
    {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
    {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
    {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"},
  }
  local out = ""
  for _, pair in ipairs(map) do
    while n >= pair[1] do
      out = out .. pair[2]
      n = n - pair[1]
    end
  end
  return out
end

local function balance_title(text)
  local words = {}
  for w in text:gmatch("%S+") do
    words[#words + 1] = w
  end
  local n = #words
  if n <= 1 or #text <= 55 then
    return { text }
  end
  local function count_words(s)
    local c = 0
    for _ in s:gmatch("%S+") do
      c = c + 1
    end
    return c
  end
  local function best_for(k)
    local best, best_cost = nil, math.huge
    local function rec(i, kk, cur, mx, single)
      if kk == 1 then
        local line = table.concat(words, " ", i, n)
        local lines = {}
        for _, l in ipairs(cur) do
          lines[#lines + 1] = l
        end
        lines[#lines + 1] = line
        local m = math.max(mx, #line)
        local s = single + (count_words(line) <= 1 and 1 or 0)
        local cost = m + 100 * s
        if cost < best_cost then
          best, best_cost = lines, cost
        end
        return
      end
      for j = i, n - kk + 1 do
        local line = table.concat(words, " ", i, j)
        local nxt = {}
        for _, l in ipairs(cur) do
          nxt[#nxt + 1] = l
        end
        nxt[#nxt + 1] = line
        rec(
          j + 1,
          kk - 1,
          nxt,
          math.max(mx, #line),
          single + (count_words(line) <= 1 and 1 or 0)
        )
      end
    end
    rec(1, k, {}, 0, 0)
    return best
  end
  local function mx_of(lines)
    local m = 0
    for _, l in ipairs(lines) do
      m = math.max(m, #l)
    end
    return m
  end
  local function orphan(lines)
    for _, l in ipairs(lines) do
      if count_words(l) <= 1 then
        return true
      end
    end
    return false
  end
  local two = best_for(2)
  if not orphan(two) and mx_of(two) <= 50 then
    return two
  end
  return best_for(3)
end

local function para(content, style)
  return pandoc.Div(
    { pandoc.Para(content) },
    pandoc.Attr("", {}, { ["custom-style"] = style })
  )
end

local function pagebreak()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function spacer(before)
  return pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:spacing w:before="' .. before .. '" w:after="0" w:line="20" w:lineRule="exact"/><w:rPr><w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr></w:pPr></w:p>'
  )
end

local function meta_str(meta, key)
  local v = meta[key]
  if v == nil then
    return ""
  end
  if type(v) == "boolean" then
    return tostring(v)
  end
  return pandoc.utils.stringify(v)
end

local function meta_bool(meta, key)
  local v = meta[key]
  if v == nil then
    return false
  end
  if type(v) == "boolean" then
    return v
  end
  local s = meta_str(meta, key):lower():gsub("%s+", "")
  return s == "true" or s == "1" or s == "yes"
end

local function format_chapter_number(n)
  if chapter_num_fmt == "arabic" then
    return tostring(n)
  else
    return roman(n)
  end
end

local function Meta(meta)
  if meta["heading_chapter_prefix"] ~= nil then
    local pfx = meta_str(meta, "heading_chapter_prefix")
    if pfx == "" then
      chapter_prefix = ""
    else
      if not pfx:match("%s$") then
        pfx = pfx .. " "
      end
      chapter_prefix = pfx
    end
  end
  local fmt = meta_str(meta, "heading_chapter_num_format")
  if fmt ~= "" then
    chapter_num_fmt = fmt
  end
  if meta["heading_sub_dot"] ~= nil then
    sub_dot = meta_bool(meta, "heading_sub_dot")
  end
  if meta["heading_subsub_dot"] ~= nil then
    subsub_dot = meta_bool(meta, "heading_subsub_dot")
  end
  local m_preset = meta_str(meta, "margin_preset")
  if m_preset == "skripsi-4433" or m_preset == "4-4-3-3" then
    doc_margins = { top = 2268, right = 1701, bottom = 1701, left = 2268 }
  end
  doc_margins.top = dim_to_twips(meta_str(meta, "margin_top"), doc_margins.top)
  doc_margins.bottom = dim_to_twips(meta_str(meta, "margin_bottom"), doc_margins.bottom)
  doc_margins.left = dim_to_twips(meta_str(meta, "margin_left"), doc_margins.left)
  doc_margins.right = dim_to_twips(meta_str(meta, "margin_right"), doc_margins.right)
end

function Header(el)
  if FORMAT ~= "docx" then
    return nil
  end
  local title = pandoc.utils.stringify(el.content)
  if is_unnumbered(el) then
    if el.level == 1 then
      toc_entries[#toc_entries + 1] = {
        level = 1,
        id = el.identifier,
        text = string.upper(title),
      }
    end
    return nil
  end
  if el.level == 1 then
    bab = bab + 1
    sub = 0
    subsub = 0
    local bnum = format_chapter_number(bab)
    local full_bab = chapter_prefix .. bnum
    local clean_title = title:gsub("^%d+%.%s*", "")
    if clean_title ~= title and chapter_prefix == "" then
      el.content = pandoc.List{ pandoc.Str(title) }
      return el
    end
    if chapter_prefix == "" then
      full_bab = bnum .. "."
      toc_entries[#toc_entries + 1] = {
        level = 1,
        id = el.identifier,
        text = full_bab .. " " .. string.upper(title),
      }
      el.content = pandoc.List{
        pandoc.Str(full_bab .. " " .. string.upper(title)),
      }
    else
      toc_entries[#toc_entries + 1] = {
        level = 1,
        id = el.identifier,
        text = full_bab .. " " .. string.upper(title),
      }
      el.content = pandoc.List{
        pandoc.Str(full_bab),
        pandoc.LineBreak(),
        pandoc.Str(string.upper(title)),
      }
    end
  elseif el.level == 2 then
    sub = sub + 1
    subsub = 0
    local bnum = format_chapter_number(bab)
    local sep2 = sub_dot and ". " or " "
    local num_str = bnum .. "." .. sub .. sep2
    toc_entries[#toc_entries + 1] = {
      level = 2,
      id = el.identifier,
      text = num_str .. title,
    }
    el.content = pandoc.Str(num_str .. title)
  elseif el.level == 3 then
    subsub = subsub + 1
    local bnum = format_chapter_number(bab)
    local sep3 = subsub_dot and ". " or " "
    local num_str = bnum .. "." .. sub .. "." .. subsub .. sep3
    toc_entries[#toc_entries + 1] = {
      level = 3,
      id = el.identifier,
      text = num_str .. title,
    }
    el.content = pandoc.Str(num_str .. title)
  end
  return el
end

local ZWS = "\226\128\139"

local function inject_zws(s)
  s = s:gsub("::", "::" .. ZWS)
  s = s:gsub("/", "/" .. ZWS)
  s = s:gsub("_", "_" .. ZWS)
  s = s:gsub("%.", "." .. ZWS)
  s = s:gsub("([a-z])([A-Z])", "%1" .. ZWS .. "%2")
  return s
end

local function process_table_cell(cell, style_name)
  local walked = pandoc.walk_block(pandoc.Div(cell.contents), {
    Str = function(s)
      return pandoc.Str(inject_zws(s.text))
    end,
    Plain = function(p)
      return pandoc.Para(p.content)
    end,
  })
  cell.contents = {
    pandoc.Div(walked.content, pandoc.Attr("", {}, { ["custom-style"] = style_name })),
  }
  return cell
end

local function Table(el)
  if FORMAT ~= "docx" then
    return nil
  end

  -- Pastikan seluruh kolom memiliki lebar proporsional terdefinisi
  local ncols = #el.colspecs
  if ncols > 0 then
    local sum_w = 0
    local missing = false
    for i = 1, ncols do
      local w = el.colspecs[i][2]
      if not w or w <= 0 then
        missing = true
      else
        sum_w = sum_w + w
      end
    end
    if missing or sum_w <= 0 then
      local eq = 1.0 / ncols
      for i = 1, ncols do
        el.colspecs[i][2] = eq
      end
    elseif math.abs(sum_w - 1.0) > 0.01 then
      for i = 1, ncols do
        el.colspecs[i][2] = el.colspecs[i][2] / sum_w
      end
    end
  end

  -- Proses header rows dengan style TableHeader (10pt bold, rata kiri, spasi rapat)
  if el.head and el.head.rows then
    for _, row in ipairs(el.head.rows) do
      for i, cell in ipairs(row.cells) do
        row.cells[i] = process_table_cell(cell, "TableHeader")
      end
    end
  end

  -- Proses body rows dengan style TableCell (10pt normal, rata kiri, spasi rapat)
  if el.bodies then
    for _, body in ipairs(el.bodies) do
      if body.head then
        for _, row in ipairs(body.head) do
          for i, cell in ipairs(row.cells) do
            row.cells[i] = process_table_cell(cell, "TableHeader")
          end
        end
      end
      if body.body then
        for _, row in ipairs(body.body) do
          for i, cell in ipairs(row.cells) do
            row.cells[i] = process_table_cell(cell, "TableCell")
          end
        end
      end
    end
  end

  if el.foot and el.foot.rows then
    for _, row in ipairs(el.foot.rows) do
      for i, cell in ipairs(row.cells) do
        row.cells[i] = process_table_cell(cell, "TableCell")
      end
    end
  end

  return el
end

local function toc_entry(e)
  local style, ind, bold, spacing = "TOC1", 0, "<w:rPr><w:b/></w:rPr>", '<w:spacing w:before="120" w:after="40" w:line="260" w:lineRule="auto"/>'
  if e.level == 2 then
    style, ind, bold, spacing = "TOC2", 360, "", '<w:spacing w:before="20" w:after="20" w:line="240" w:lineRule="auto"/>'
  elseif e.level == 3 then
    style, ind, bold, spacing = "TOC3", 720, "", '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' ..
    spacing ..
    '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9072"/></w:tabs>' ..
    '<w:ind w:left="' .. ind .. '" w:right="0"/></w:pPr>' ..
    '<w:hyperlink w:anchor="' .. e.id .. '" w:history="1">' ..
    '<w:r>' .. bold .. '<w:t xml:space="preserve">' .. e.text .. '</w:t></w:r>' ..
    '</w:hyperlink>' ..
    '<w:r><w:tab/></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> PAGEREF ' .. e.id .. ' \\h </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>0</w:t></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="end"/></w:r>' ..
    '</w:p>'
end

local function daftar_isi()
  local out = pandoc.List{}
  out[#out + 1] = pagebreak()
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:jc w:val="center"/><w:outlineLvl w:val="9"/></w:pPr>' ..
      '<w:r><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>DAFTAR ISI</w:t></w:r></w:p>'
  )
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>'
  )
  for _, e in ipairs(toc_entries) do
    out[#out + 1] = pandoc.RawBlock("openxml", toc_entry(e))
  end
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  )
  return out
end

local function daftar_gambar()
  local out = pandoc.List{}
  out[#out + 1] = pagebreak()
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:jc w:val="center"/><w:outlineLvl w:val="9"/></w:pPr>' ..
      '<w:r><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>DAFTAR GAMBAR</w:t></w:r></w:p>'
  )
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> TOC \\c "Gambar" \\h \\z </w:instrText></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  )
  return out
end

local function daftar_tabel()
  local out = pandoc.List{}
  out[#out + 1] = pagebreak()
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:jc w:val="center"/><w:outlineLvl w:val="9"/></w:pPr>' ..
      '<w:r><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>DAFTAR TABEL</w:t></w:r></w:p>'
  )
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> TOC \\c "Tabel" \\h \\z </w:instrText></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
      '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  )
  return out
end

function Pandoc(doc)
  if FORMAT ~= "docx" then
    return doc
  end
  local meta = doc.meta
  local title = meta_str(meta, "title")
  local subtitle = meta_str(meta, "subtitle")
  local course = meta_str(meta, "course")
  local lecturer = meta_str(meta, "lecturer")
  local faculty = meta_str(meta, "faculty")
  local institution = meta_str(meta, "institution")
  local year = meta_str(meta, "year")
  local show_dg = (meta_bool(meta, "daftar_gambar") or meta_bool(meta, "list_of_figures"))
  local show_dt = (meta_bool(meta, "daftar_tabel") or meta_bool(meta, "list_of_tables"))

  local is_journal = (meta_str(meta, "doc_type") == "journal" or meta_str(meta, "cover_show") == "false")
  local blocks = pandoc.List{}

  if is_journal then
    if title ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(string.upper(title))) }, "CoverTitle")
    end
    local authors = {}
    if meta.author and type(meta.author) == "table" then
      for _, a in ipairs(meta.author) do
        local name = type(a) == "table" and a.name and pandoc.utils.stringify(a.name) or pandoc.utils.stringify(a)
        if name ~= "" then
          authors[#authors + 1] = name
        end
      end
    end
    if #authors > 0 then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(table.concat(authors, ", "))) }, "CoverCourse")
    end
    if institution ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Str(institution) }, "CoverInstitution")
    end
    local abs_id = meta_str(meta, "abstract_id")
    if abs_id ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("Abstrak - ")), pandoc.Emph(pandoc.Str(abs_id)) }, "Normal")
    end
    local abs_en = meta_str(meta, "abstract_en")
    if abs_en ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("Abstract - ")), pandoc.Emph(pandoc.Str(abs_en)) }, "Normal")
    end
    doc.blocks = blocks .. doc.blocks
    return doc
  end

  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("LAPORAN AKHIR")) }, "CoverTitle")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("MAGANG MANDIRI")) }, "CoverSubtitle")
  if title ~= "" then
    local tlines = balance_title(string.upper(title))
    local content = {}
    for i, l in ipairs(tlines) do
      if i > 1 then
        content[#content + 1] = pandoc.LineBreak()
      end
      content[#content + 1] = pandoc.Str(l)
    end
    blocks[#blocks + 1] = para(content, "CoverTitle")
  end
  local pks = meta_str(meta, "pks_number")
  if pks == "" then pks = "No. PKS: 015/UN63.7/PKS/2024" end
  blocks[#blocks + 1] = para({ pandoc.Str(pks) }, "CoverLine")

  local logo_file = meta_str(meta, "logo")
  if logo_file == "" then logo_file = "gambar/logo.png" end
  local logo_width = meta_str(meta, "cover_logo_width")
  if logo_width == "" then logo_width = "4.5cm" end
  blocks[#blocks + 1] = spacer(240)
  blocks[#blocks + 1] = pandoc.Div(
    { pandoc.Para({ pandoc.Image({}, logo_file, "", pandoc.Attr("", {}, { width = logo_width })) }) },
    pandoc.Attr("", {}, { ["custom-style"] = "CoverImage" })
  )
  blocks[#blocks + 1] = spacer(240)

  blocks[#blocks + 1] = para({
    pandoc.Str("Diajukan untuk memenuhi persyaratan kelulusan"),
    pandoc.LineBreak(),
    pandoc.Str("Program Magang Mandiri")
  }, "CoverLine")
  blocks[#blocks + 1] = spacer(160)
  blocks[#blocks + 1] = para({ pandoc.Str("oleh :") }, "CoverLine")
  local authors = meta["author"]
  if authors ~= nil then
    local author_list = {}
    if authors[1] ~= nil then
      for _, a in ipairs(authors) do author_list[#author_list + 1] = a end
    else
      author_list[#author_list + 1] = authors
    end
    for _, a in ipairs(author_list) do
      local name = pandoc.utils.stringify(a["name"] or a)
      local nim = pandoc.utils.stringify(a["nim"] or "")
      local line_text = name .. (nim ~= "" and (" / " .. nim) or "")
      blocks[#blocks + 1] = para({ pandoc.Str(line_text) }, "CoverLine")
    end
  end

  blocks[#blocks + 1] = spacer(280)
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("PROGRAM STUDI INFORMATIKA")) }, "CoverInstitution")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("FAKULTAS ILMU KOMPUTER")) }, "CoverInstitution")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str('UNIVERSITAS PEMBANGUNAN NASIONAL "VETERAN" JAWA TIMUR')) }, "CoverInstitution")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("2026")) }, "CoverInstitution")

  -- Section break (Next Page) penutup cover: tanpa footer/nomor halaman
  blocks[#blocks + 1] = pandoc.RawBlock(
    "openxml",
    string.format(
      '<w:p><w:pPr><w:sectPr><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="%d" w:right="%d" w:bottom="%d" w:left="%d" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>',
      doc_margins.top, doc_margins.right, doc_margins.bottom, doc_margins.left
    )
  )

  -- Optional Lembar Pengesahan (approval)
  if meta["approval"] ~= nil and type(meta["approval"]) == "table" then
    local app = meta["approval"]
    local app_city = meta_str(app, "city")
    local app_date = meta_str(app, "date")
    if app_date == "" then app_date = meta_str(meta, "date") end
    blocks[#blocks + 1] = pandoc.Header(1, { pandoc.Str("LEMBAR PENGESAHAN") }, pandoc.Attr("lembar-pengesahan", { "unnumbered" }, {}))
    if title ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(string.upper(title))) }, "CoverLine")
      blocks[#blocks + 1] = para({ pandoc.Str("Di PT Jawa Pos Media Televisi (JTV)") }, "CoverLine")
    end
    blocks[#blocks + 1] = spacer(200)
    blocks[#blocks + 1] = para({ pandoc.Str("oleh :") }, "CoverLine")
    if authors ~= nil then
      local author_list = {}
      if authors[1] ~= nil then
        for _, a in ipairs(authors) do author_list[#author_list + 1] = a end
      else
        author_list[#author_list + 1] = authors
      end
      for _, a in ipairs(author_list) do
        local name = pandoc.utils.stringify(a["name"] or a)
        local nim = pandoc.utils.stringify(a["nim"] or "")
        blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(name)), pandoc.Str(" / " .. nim) }, "CoverName")
      end
    end
    blocks[#blocks + 1] = spacer(200)
    blocks[#blocks + 1] = para({ pandoc.Str("disetujui sebagai") }, "CoverLine")
    blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("Laporan Magang Mandiri")) }, "CoverLine")
    local date_line = (app_city ~= "" and (app_city .. ", ") or "") .. app_date
    if date_line ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Str(date_line) }, "CoverLine")
    end
    blocks[#blocks + 1] = spacer(400)
    if app["supervisors"] ~= nil and type(app["supervisors"]) == "table" then
      for _, sup in ipairs(app["supervisors"]) do
        local s_role = pandoc.utils.stringify(sup["role"] or "Pembimbing")
        local s_name = pandoc.utils.stringify(sup["name"] or "")
        local s_nip = pandoc.utils.stringify(sup["nip"] or "")
        blocks[#blocks + 1] = spacer(200)
        blocks[#blocks + 1] = para({ pandoc.Str(s_role) }, "CoverLine")
        blocks[#blocks + 1] = spacer(480)
        blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(s_name)) }, "CoverName")
        if s_nip ~= "" and s_nip ~= "-" and s_nip ~= "....." then
          blocks[#blocks + 1] = para({ pandoc.Str("NIP. " .. s_nip) }, "CoverLine")
        end
      end
    end
    blocks[#blocks + 1] = pagebreak()
  end

  -- Optional Abstrak Bahasa Indonesia (abstract_id)
  local abs_id = meta_str(meta, "abstract_id")
  if abs_id ~= "" then
    blocks[#blocks + 1] = pandoc.Header(1, { pandoc.Str("ABSTRAK") }, pandoc.Attr("abstrak", { "unnumbered" }, {}))
    if title ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(string.upper(title))) }, "CoverLine")
    end
    blocks[#blocks + 1] = pandoc.Para({ pandoc.Str(abs_id) })
    if meta["keywords_id"] ~= nil then
      local kw_list = {}
      if type(meta["keywords_id"]) == "table" and meta["keywords_id"][1] ~= nil then
        for _, k in ipairs(meta["keywords_id"]) do
          kw_list[#kw_list + 1] = pandoc.utils.stringify(k)
        end
      else
        kw_list[#kw_list + 1] = meta_str(meta, "keywords_id")
      end
      if #kw_list > 0 then
        blocks[#blocks + 1] = pandoc.Para({
          pandoc.Strong(pandoc.Str("Kata Kunci: ")),
          pandoc.Emph(pandoc.Str(table.concat(kw_list, ", ")))
        })
      end
    end
    blocks[#blocks + 1] = pagebreak()
  end

  -- Optional Abstract English (abstract_en)
  local abs_en = meta_str(meta, "abstract_en")
  if abs_en ~= "" then
    blocks[#blocks + 1] = pandoc.Header(1, { pandoc.Str("ABSTRACT") }, pandoc.Attr("abstract", { "unnumbered" }, {}))
    if title ~= "" then
      blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Emph(pandoc.Str(string.upper(title)))) }, "CoverLine")
    end
    blocks[#blocks + 1] = pandoc.Para({ pandoc.Emph(pandoc.Str(abs_en)) })
    if meta["keywords_en"] ~= nil then
      local kw_en = {}
      if type(meta["keywords_en"]) == "table" and meta["keywords_en"][1] ~= nil then
        for _, k in ipairs(meta["keywords_en"]) do
          kw_en[#kw_en + 1] = pandoc.utils.stringify(k)
        end
      else
        kw_en[#kw_en + 1] = meta_str(meta, "keywords_en")
      end
      if #kw_en > 0 then
        blocks[#blocks + 1] = pandoc.Para({
          pandoc.Strong(pandoc.Str("Keywords: ")),
          pandoc.Emph(pandoc.Str(table.concat(kw_en, ", ")))
        })
      end
    end
    blocks[#blocks + 1] = pagebreak()
  end

  meta.title = nil
  meta.subtitle = nil
  meta.date = nil
  meta.author = nil
  meta.abstract = nil
  meta["abstract-title"] = nil

  local body = pandoc.List{}
  local inserted = false
  for _, blk in ipairs(doc.blocks) do
    if
      not inserted
      and not is_journal
      and blk.tag == "Header"
      and blk.level == 1
      and not is_unnumbered(blk)
    then
      for _, b in ipairs(daftar_isi()) do
        body[#body + 1] = b
      end
      if show_dg then
        for _, b in ipairs(daftar_gambar()) do
          body[#body + 1] = b
        end
      end
      if show_dt then
        for _, b in ipairs(daftar_tabel()) do
          body[#body + 1] = b
        end
      end
      inserted = true
    end
    body[#body + 1] = blk
  end

  doc.blocks = blocks .. body
  return doc
end

return {
  { Meta = Meta },
  { Header = Header, Table = Table, Pandoc = Pandoc }
}