-- docx.lua: Generator struktur DOCX resmi PKL Konversi (UPN "Veteran" Jawa Timur)
--  - Sampul (mendukung 1 penulis / Individu maupun multi-penulis / Kelompok)
--  - Lembar Pengesahan PKL Konversi (4 tanda tangan: Menyetujui 2 + Mengetahui 2)
--  - Surat Pernyataan bermaterai Rp10.000 (adaptif Saya/Kami)
--  - Abstrak ID (dengan tabel header mini: Judul, Studi Kasus, Penulis, Pembimbing) & Abstract EN
--  - Heading 1: "BAB I\nPENDAHULUAN", Heading 2: "1.1 Sub Bab", Heading 3: "1.1.1 Sub Sub Bab"
--  - Tabel dengan gaya TableHeader/TableCell & penyisipan ZWS agar bebas overflow
--  - Daftar Isi, Daftar Tabel, dan Daftar Gambar otomatis sebelum BAB I

local bab = 0
local sub = 0
local subsub = 0
local toc_entries = {}
local chapter_prefix = "BAB "
local chapter_num_fmt = "roman"
local sub_dot = false
local subsub_dot = false
local doc_margins = { top = 2268, right = 1701, bottom = 1701, left = 2268 }

local function utf8_upper(s)
  if pandoc.text and pandoc.text.upper then
    return pandoc.text.upper(tostring(s or ""))
  end
  return tostring(s or "")
end

local function xml_esc(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  s = s:gsub('"', "&quot;")
  return s
end

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
  if v == nil then return "" end
  if type(v) == "boolean" then return tostring(v) end
  return pandoc.utils.stringify(v)
end

local function meta_bool(meta, key)
  local v = meta[key]
  if v == nil then return false end
  if type(v) == "boolean" then return v end
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

local function get_authors(meta)
  local list = {}
  local authors = meta["author"]
  if authors == nil then return list end
  if authors[1] ~= nil then
    for _, a in ipairs(authors) do
      list[#list + 1] = {
        name = pandoc.utils.stringify(a["name"] or a),
        nim = pandoc.utils.stringify(a["nim"] or ""),
      }
    end
  else
    list[#list + 1] = {
      name = pandoc.utils.stringify(authors["name"] or authors),
      nim = pandoc.utils.stringify(authors["nim"] or ""),
    }
  end
  return list
end

local function borderless_table_xml(rows_xml, bottom_rule)
  local bottom_bdr = bottom_rule and '<w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/>' or '<w:bottom w:val="none"/>'
  return '<w:tbl><w:tblPr>' ..
    '<w:tblW w:w="5000" w:type="pct"/>' ..
    '<w:tblBorders><w:top w:val="none"/><w:left w:val="none"/>' .. bottom_bdr ..
    '<w:right w:val="none"/><w:insideH w:val="none"/><w:insideV w:val="none"/></w:tblBorders>' ..
    '</w:tblPr>' .. table.concat(rows_xml, "") .. '</w:tbl>'
end

local function cell_xml(w_pct, paragraphs_xml)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w_pct .. '" w:type="pct"/>' ..
    '<w:tcMar><w:top w:w="30" w:type="dxa"/><w:bottom w:w="30" w:type="dxa"/><w:left w:w="40" w:type="dxa"/><w:right w:w="40" w:type="dxa"/></w:tcMar>' ..
    '</w:tcPr>' .. table.concat(paragraphs_xml, "") .. '</w:tc>'
end

local function run_p(txt, opts)
  opts = opts or {}
  local jc = opts.align or "left"
  local sz = (opts.size or 11) * 2
  local b = opts.bold and "<w:b/>" or ""
  local i = opts.italic and "<w:i/>" or ""
  local u = opts.underline and '<w:u w:val="single"/>' or ""
  local sb = opts.before or 0
  local sa = opts.after or 40
  return '<w:p><w:pPr><w:jc w:val="' .. jc .. '"/><w:spacing w:before="' .. sb .. '" w:after="' .. sa .. '" w:line="260" w:lineRule="auto"/></w:pPr>' ..
    '<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>' ..
    b .. i .. u .. '<w:sz w:val="' .. sz .. '"/><w:szCs w:val="' .. sz .. '"/></w:rPr>' ..
    '<w:t xml:space="preserve">' .. xml_esc(txt) .. '</w:t></w:r></w:p>'
end

local function Meta(meta)
  if meta["heading_chapter_prefix"] ~= nil then
    local pfx = meta_str(meta, "heading_chapter_prefix")
    if pfx == "" then
      chapter_prefix = ""
    else
      if not pfx:match("%s$") then pfx = pfx .. " " end
      chapter_prefix = pfx
    end
  end
  local fmt = meta_str(meta, "heading_chapter_num_format")
  if fmt ~= "" then chapter_num_fmt = fmt end
  if meta["heading_sub_dot"] ~= nil then sub_dot = meta_bool(meta, "heading_sub_dot") end
  if meta["heading_subsub_dot"] ~= nil then subsub_dot = meta_bool(meta, "heading_subsub_dot") end
  doc_margins.top = dim_to_twips(meta_str(meta, "margin_top"), doc_margins.top)
  doc_margins.bottom = dim_to_twips(meta_str(meta, "margin_bottom"), doc_margins.bottom)
  doc_margins.left = dim_to_twips(meta_str(meta, "margin_left"), doc_margins.left)
  doc_margins.right = dim_to_twips(meta_str(meta, "margin_right"), doc_margins.right)
end

function Header(el)
  if FORMAT ~= "docx" then return nil end
  local title = pandoc.utils.stringify(el.content)
  if is_unnumbered(el) then
    if el.level == 1 then
      toc_entries[#toc_entries + 1] = { level = 1, id = el.identifier, text = utf8_upper(title) }
    end
    return nil
  end
  if el.level == 1 then
    bab = bab + 1
    sub = 0
    subsub = 0
    local bnum = format_chapter_number(bab)
    local full_bab = chapter_prefix .. bnum
    toc_entries[#toc_entries + 1] = {
      level = 1,
      id = el.identifier,
      text = full_bab .. " " .. utf8_upper(title),
    }
    el.content = pandoc.List{
      pandoc.Str(full_bab),
      pandoc.LineBreak(),
      pandoc.Str(utf8_upper(title)),
    }
  elseif el.level == 2 then
    sub = sub + 1
    subsub = 0
    local sep2 = sub_dot and ". " or " "
    local num_str = tostring(bab) .. "." .. tostring(sub) .. sep2
    toc_entries[#toc_entries + 1] = { level = 2, id = el.identifier, text = num_str .. title }
    el.content = pandoc.Str(num_str .. title)
  elseif el.level == 3 then
    subsub = subsub + 1
    local sep3 = subsub_dot and ". " or " "
    local num_str = tostring(bab) .. "." .. tostring(sub) .. "." .. tostring(subsub) .. sep3
    toc_entries[#toc_entries + 1] = { level = 3, id = el.identifier, text = num_str .. title }
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
    Str = function(s) return pandoc.Str(inject_zws(s.text)) end,
    Plain = function(p) return pandoc.Para(p.content) end,
  })
  cell.contents = {
    pandoc.Div(walked.content, pandoc.Attr("", {}, { ["custom-style"] = style_name })),
  }
  return cell
end

local function Table(el)
  if FORMAT ~= "docx" then return nil end
  local ncols = #el.colspecs
  if ncols > 0 then
    local sum_w, missing = 0, false
    for i = 1, ncols do
      local w = el.colspecs[i][2]
      if not w or w <= 0 then missing = true else sum_w = sum_w + w end
    end
    if missing or sum_w <= 0 then
      for i = 1, ncols do el.colspecs[i][2] = 1.0 / ncols end
    elseif math.abs(sum_w - 1.0) > 0.01 then
      for i = 1, ncols do el.colspecs[i][2] = el.colspecs[i][2] / sum_w end
    end
  end
  if el.head and el.head.rows then
    for _, row in ipairs(el.head.rows) do
      for i, cell in ipairs(row.cells) do row.cells[i] = process_table_cell(cell, "TableHeader") end
    end
  end
  if el.bodies then
    for _, body in ipairs(el.bodies) do
      if body.head then
        for _, row in ipairs(body.head) do
          for i, cell in ipairs(row.cells) do row.cells[i] = process_table_cell(cell, "TableHeader") end
        end
      end
      if body.body then
        for _, row in ipairs(body.body) do
          for i, cell in ipairs(row.cells) do row.cells[i] = process_table_cell(cell, "TableCell") end
        end
      end
    end
  end
  if el.foot and el.foot.rows then
    for _, row in ipairs(el.foot.rows) do
      for i, cell in ipairs(row.cells) do row.cells[i] = process_table_cell(cell, "TableCell") end
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
    '<w:r>' .. bold .. '<w:t xml:space="preserve">' .. xml_esc(e.text) .. '</w:t></w:r>' ..
    '</w:hyperlink>' ..
    '<w:r><w:tab/></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> PAGEREF ' .. e.id .. ' \\h </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:t>0</w:t></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
end

local function daftar_isi()
  local out = pandoc.List{}
  out[#out + 1] = pagebreak()
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:jc w:val="center"/><w:outlineLvl w:val="9"/></w:pPr>' ..
    '<w:r><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>DAFTAR ISI</w:t></w:r></w:p>')
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
    '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r></w:p>')
  for _, e in ipairs(toc_entries) do
    out[#out + 1] = pandoc.RawBlock("openxml", toc_entry(e))
  end
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  return out
end

local function daftar_auto(heading_txt, seq_name)
  local out = pandoc.List{}
  out[#out + 1] = pagebreak()
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:jc w:val="center"/><w:outlineLvl w:val="9"/></w:pPr>' ..
    '<w:r><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>' .. heading_txt .. '</w:t></w:r></w:p>')
  out[#out + 1] = pandoc.RawBlock("openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
    '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
    '<w:r><w:instrText xml:space="preserve"> TOC \\c "' .. seq_name .. '" \\h \\z </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>')
  return out
end

function Pandoc(doc)
  if FORMAT ~= "docx" then return doc end
  local meta = doc.meta
  local title = meta_str(meta, "title")
  local doc_kind = meta_str(meta, "doc_kind")
  if doc_kind == "" then doc_kind = "PRAKTIK KERJA LAPANGAN" end
  local case_study = meta_str(meta, "case_study")
  if case_study == "" then case_study = "PT. Jawa Pos Media Televisi (JTV)" end
  local partner_name = meta_str(meta, "partner_name")
  if partner_name == "" then partner_name = "PT. JAWA POS MEDIA TELEVISI (JTV)" end
  local partner_address = meta_str(meta, "partner_address")
  if partner_address == "" then partner_address = "Graha Pena, Jl. Ahmad Yani No. 88, Ketintang, Gayungan, Surabaya, Jawa Timur" end
  local lecturer = meta_str(meta, "lecturer")
  local department = meta_str(meta, "department")
  if department == "" then department = "PROGRAM STUDI INFORMATIKA" end
  local faculty = meta_str(meta, "faculty")
  if faculty == "" then faculty = "FAKULTAS ILMU KOMPUTER" end
  local institution = meta_str(meta, "institution")
  if institution == "" then institution = 'UNIVERSITAS PEMBANGUNAN NASIONAL "VETERAN" JAWA TIMUR' end
  local city = meta_str(meta, "city")
  if city == "" then city = "Surabaya" end
  local year = meta_str(meta, "year")
  if year == "" then year = "2026" end
  local date_str = meta_str(meta, "date")
  if date_str == "" then date_str = "Desember 2026" end
  local show_dt = (meta_bool(meta, "daftar_tabel") or meta_bool(meta, "list_of_tables"))
  local show_dg = (meta_bool(meta, "daftar_gambar") or meta_bool(meta, "list_of_figures"))
  local authors = get_authors(meta)
  local is_group = #authors > 1

  local blocks = pandoc.List{}

  -- 1. HALAMAN SAMPUL
  if title ~= "" then
    blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(utf8_upper(title))) }, "CoverTitle")
  end
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(utf8_upper(doc_kind))) }, "CoverSubtitle")

  local logo_file = meta_str(meta, "logo")
  if logo_file == "" then logo_file = "gambar/01-profil/logo-upn.png" end
  local logo_width = meta_str(meta, "cover_logo_width")
  if logo_width == "" then logo_width = "4.5cm" end
  blocks[#blocks + 1] = spacer(400)
  blocks[#blocks + 1] = pandoc.Div(
    { pandoc.Para({ pandoc.Image({}, logo_file, "", pandoc.Attr("", {}, { width = logo_width })) }) },
    pandoc.Attr("", {}, { ["custom-style"] = "CoverImage" })
  )
  blocks[#blocks + 1] = spacer(400)

  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str("Oleh:")) }, "CoverLine")
  for _, a in ipairs(authors) do
    local line = a.name .. (a.nim ~= "" and (" (" .. a.nim .. ")") or "")
    blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(line)) }, "CoverLine")
  end

  blocks[#blocks + 1] = spacer(480)
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(utf8_upper(department))) }, "CoverInstitution")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(utf8_upper(faculty))) }, "CoverInstitution")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(utf8_upper(institution))) }, "CoverInstitution")
  blocks[#blocks + 1] = para({ pandoc.Strong(pandoc.Str(year)) }, "CoverInstitution")

  -- Section break (Next Page) penutup cover tanpa nomor halaman
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", string.format(
    '<w:p><w:pPr><w:sectPr><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="%d" w:right="%d" w:bottom="%d" w:left="%d" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>',
    doc_margins.top, doc_margins.right, doc_margins.bottom, doc_margins.left
  ))

  -- 2. LEMBAR PENGESAHAN PKL KONVERSI (4 Tanda Tangan)
  if meta["approval"] ~= nil and type(meta["approval"]) == "table" then
    local app = meta["approval"]
    local app_heading = meta_str(app, "heading")
    if app_heading == "" then app_heading = "LEMBAR PENGESAHAN PRAKTEK KERJA LAPANGAN KONVERSI" end
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p(app_heading, { align = "center", size = 13, bold = true, after = 240 }))

    local author_ps = {}
    for _, a in ipairs(authors) do
      author_ps[#author_ps + 1] = run_p(a.name .. "   (" .. a.nim .. ")", { size = 11, bold = true, after = 20 })
    end
    local hdr_rows = {
      "<w:tr>" .. cell_xml(800, { run_p("Judul", { size = 11, bold = true }) }) ..
        cell_xml(250, { run_p(":", { size = 11, bold = true, align = "center" }) }) ..
        cell_xml(3950, { run_p(utf8_upper(title), { size = 11, bold = true }) }) .. "</w:tr>",
      "<w:tr>" .. cell_xml(800, { run_p("Oleh", { size = 11, bold = true }) }) ..
        cell_xml(250, { run_p(":", { size = 11, bold = true, align = "center" }) }) ..
        cell_xml(3950, author_ps) .. "</w:tr>",
    }
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml(hdr_rows, false))

    local ex_day = meta_str(app, "exam_day")
    if ex_day == "" then ex_day = "........" end
    local ex_date = meta_str(app, "exam_date")
    if ex_date == "" then ex_date = "........" end
    local ex_month = meta_str(app, "exam_month")
    if ex_month == "" then ex_month = "Desember" end
    local ex_year = meta_str(app, "exam_year")
    if ex_year == "" then ex_year = year end

    blocks[#blocks + 1] = pandoc.RawBlock("openxml",
      run_p("Telah Diseminarkan Dalam Ujian PKL, pada :", { align = "center", size = 11, bold = true, before = 240, after = 20 }) ..
      run_p("Hari " .. ex_day .. ", Tanggal " .. ex_date .. " Bulan " .. ex_month .. " " .. ex_year, { align = "center", size = 11, bold = true, after = 240 }) ..
      run_p("Menyetujui", { align = "center", size = 11, bold = true, after = 120 })
    )

    if app["supervisors"] ~= nil and type(app["supervisors"]) == "table" then
      local cells = {}
      for _, sup in ipairs(app["supervisors"]) do
        local s_role = pandoc.utils.stringify(sup["role"] or "")
        local s_name = pandoc.utils.stringify(sup["name"] or "")
        local s_nip = pandoc.utils.stringify(sup["nip"] or "")
        local ps = {
          run_p(s_role, { align = "center", size = 11, bold = true, after = 900 }),
          run_p(s_name, { align = "center", size = 10.5, bold = true, underline = true, after = 20 }),
        }
        if s_nip ~= "" then
          ps[#ps + 1] = run_p("NIP. " .. s_nip, { align = "center", size = 10, bold = true, after = 40 })
        end
        cells[#cells + 1] = cell_xml(2500, ps)
      end
      blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml({ "<w:tr>" .. table.concat(cells, "") .. "</w:tr>" }, false))
    end

    if app["officials"] ~= nil and type(app["officials"]) == "table" then
      blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p("Mengetahui", { align = "center", size = 11, bold = true, before = 280, after = 120 }))
      local cells = {}
      for _, off in ipairs(app["officials"]) do
        local o_role = pandoc.utils.stringify(off["role"] or "")
        local o_unit = pandoc.utils.stringify(off["unit"] or "")
        local o_name = pandoc.utils.stringify(off["name"] or "")
        local o_nip = pandoc.utils.stringify(off["nip"] or "")
        local ps = { run_p(o_role, { align = "center", size = 11, bold = true, after = 0 }) }
        if o_unit ~= "" then
          ps[#ps + 1] = run_p(o_unit, { align = "center", size = 11, bold = true, after = 900 })
        else
          ps[1] = run_p(o_role, { align = "center", size = 11, bold = true, after = 900 })
        end
        ps[#ps + 1] = run_p(o_name, { align = "center", size = 10.5, bold = true, underline = true, after = 20 })
        if o_nip ~= "" then
          ps[#ps + 1] = run_p("NIP. " .. o_nip, { align = "center", size = 10, bold = true, after = 40 })
        end
        cells[#cells + 1] = cell_xml(2500, ps)
      end
      blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml({ "<w:tr>" .. table.concat(cells, "") .. "</w:tr>" }, false))
    end
    blocks[#blocks + 1] = pagebreak()
  end

  -- 3. SURAT PERNYATAAN KEASLIAN KEGIATAN PKL (Bermaterai Rp10.000)
  if meta["statement"] ~= nil and type(meta["statement"]) == "table" and meta_bool(meta["statement"], "enabled") then
    local stamp_lbl = meta_str(meta["statement"], "stamp_label")
    if stamp_lbl == "" then stamp_lbl = "Materai Rp10.000" end
    local pron_cap = is_group and "Kami" or "Saya"
    local pron_low = is_group and "kami" or "saya"

    blocks[#blocks + 1] = pandoc.Header(1, { pandoc.Str("SURAT PERNYATAAN") }, pandoc.Attr("surat-pernyataan", { "unnumbered" }, {}))
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p(pron_cap .. " yang bertanda tangan di bawah ini:", { size = 12, after = 120 }))
    local a_rows = {}
    for _, a in ipairs(authors) do
      a_rows[#a_rows + 1] = "<w:tr>" .. cell_xml(1200, { run_p("Nama", { size = 12 }) }) .. cell_xml(200, { run_p(":", { size = 12 }) }) .. cell_xml(3600, { run_p(a.name, { size = 12 }) }) .. "</w:tr>"
      a_rows[#a_rows + 1] = "<w:tr>" .. cell_xml(1200, { run_p("NPM", { size = 12, after = 120 }) }) .. cell_xml(200, { run_p(":", { size = 12, after = 120 }) }) .. cell_xml(3600, { run_p(a.nim, { size = 12, after = 120 }) }) .. "</w:tr>"
    end
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml(a_rows, false))
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p("Menyatakan bahwa kegiatan PKL yang " .. pron_low .. " lakukan memang benar-benar telah " .. pron_low .. " laksanakan di perusahaan/instansi:", { size = 12, before = 100, after = 100 }))
    local p_rows = {
      "<w:tr>" .. cell_xml(1800, { run_p("Nama Perusahaan/Instansi", { size = 12 }) }) .. cell_xml(200, { run_p(":", { size = 12 }) }) .. cell_xml(3000, { run_p(partner_name, { size = 12 }) }) .. "</w:tr>",
      "<w:tr>" .. cell_xml(1800, { run_p("Alamat", { size = 12 }) }) .. cell_xml(200, { run_p(":", { size = 12 }) }) .. cell_xml(3000, { run_p(partner_address, { size = 12 }) }) .. "</w:tr>",
    }
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml(p_rows, false))
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p(
      "Valid, dan perusahaan/instansi tempat " .. pron_low .. " melaksanakan PKL benar adanya serta dapat dibuktikan kebenarannya. Jika " .. pron_low .. " menyalahi surat pernyataan yang " .. pron_low .. " buat maka " .. pron_low .. ' siap menerima konsekuensi akademik maupun non-akademik. Demikian surat pernyataan ini ' .. pron_low .. ' buat sebagai syarat laporan PKL di Program Studi Informatika, Fakultas Ilmu Komputer, Universitas Pembangunan Nasional "Veteran" Jawa Timur.',
      { align = "both", size = 12, before = 140, after = 360 }
    ))

    if is_group then
      local sig_rows = {}
      for idx = 1, #authors, 2 do
        local a1 = authors[idx]
        local a2 = authors[idx + 1]
        local c1 = cell_xml(2500, {
          run_p(stamp_lbl, { align = "center", size = 10, underline = true, after = 560 }),
          run_p(a1.name, { align = "center", size = 11.5, bold = true, after = 20 }),
          run_p(a1.nim, { align = "center", size = 11, after = 200 }),
        })
        local c2 = a2 and cell_xml(2500, {
          run_p(stamp_lbl, { align = "center", size = 10, underline = true, after = 560 }),
          run_p(a2.name, { align = "center", size = 11.5, bold = true, after = 20 }),
          run_p(a2.nim, { align = "center", size = 11, after = 200 }),
        }) or cell_xml(2500, { run_p("", { size = 11 }) })
        sig_rows[#sig_rows + 1] = "<w:tr>" .. c1 .. c2 .. "</w:tr>"
      end
      blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml(sig_rows, false))
    else
      local a1 = authors[1] or { name = "", nim = "" }
      local sig_row = "<w:tr>" .. cell_xml(2600, { run_p("", { size = 11 }) }) ..
        cell_xml(2400, {
          run_p(city .. ", " .. date_str, { align = "center", size = 11.5, after = 180 }),
          run_p(stamp_lbl, { align = "center", size = 10, underline = true, after = 560 }),
          run_p(a1.name, { align = "center", size = 11.5, bold = true, after = 20 }),
          run_p(a1.nim, { align = "center", size = 11, after = 40 }),
        }) .. "</w:tr>"
      blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml({ sig_row }, false))
    end
    blocks[#blocks + 1] = pagebreak()
  end

  -- 4. ABSTRAK BAHASA INDONESIA (dengan Tabel Header Mini)
  local abs_id = meta_str(meta, "abstract_id")
  if abs_id ~= "" then
    toc_entries[#toc_entries + 1] = { level = 1, id = "abstrak", text = "ABSTRAK" }
    local author_ps = {}
    for _, a in ipairs(authors) do
      author_ps[#author_ps + 1] = run_p(a.name, { size = 11, after = 10 })
    end
    local abs_hdr = {
      "<w:tr>" .. cell_xml(1050, { run_p("Judul", { size = 11 }) }) .. cell_xml(200, { run_p(":", { size = 11, align = "center" }) }) .. cell_xml(3750, { run_p(utf8_upper(title), { size = 11, bold = true }) }) .. "</w:tr>",
      "<w:tr>" .. cell_xml(1050, { run_p("Studi Kasus", { size = 11 }) }) .. cell_xml(200, { run_p(":", { size = 11, align = "center" }) }) .. cell_xml(3750, { run_p(case_study, { size = 11 }) }) .. "</w:tr>",
      "<w:tr>" .. cell_xml(1050, { run_p("Penulis", { size = 11 }) }) .. cell_xml(200, { run_p(":", { size = 11, align = "center" }) }) .. cell_xml(3750, author_ps) .. "</w:tr>",
      "<w:tr>" .. cell_xml(1050, { run_p("Pembimbing", { size = 11, after = 80 }) }) .. cell_xml(200, { run_p(":", { size = 11, align = "center", after = 80 }) }) .. cell_xml(3750, { run_p(lecturer, { size = 11, after = 80 }) }) .. "</w:tr>",
    }
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", borderless_table_xml(abs_hdr, true))
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p("ABSTRAK", { size = 12, bold = true, before = 200, after = 120 }))
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p(abs_id, { align = "both", size = 12, after = 160 }))
    if meta["keywords_id"] ~= nil then
      local kw_list = {}
      if type(meta["keywords_id"]) == "table" and meta["keywords_id"][1] ~= nil then
        for _, k in ipairs(meta["keywords_id"]) do kw_list[#kw_list + 1] = pandoc.utils.stringify(k) end
      else
        kw_list[#kw_list + 1] = meta_str(meta, "keywords_id")
      end
      if #kw_list > 0 then
        blocks[#blocks + 1] = pandoc.Para({ pandoc.Strong(pandoc.Str("Kata kunci: ")), pandoc.Emph(pandoc.Str(table.concat(kw_list, ", ") .. ".")) })
      end
    end
    blocks[#blocks + 1] = pagebreak()
  end

  -- 5. ABSTRACT BAHASA INGGRIS
  local abs_en = meta_str(meta, "abstract_en")
  if abs_en ~= "" then
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p("ABSTRACT", { size = 12, bold = true, after = 120 }))
    blocks[#blocks + 1] = pandoc.RawBlock("openxml", run_p(abs_en, { align = "both", size = 12, italic = true, after = 160 }))
    if meta["keywords_en"] ~= nil then
      local kw_en = {}
      if type(meta["keywords_en"]) == "table" and meta["keywords_en"][1] ~= nil then
        for _, k in ipairs(meta["keywords_en"]) do kw_en[#kw_en + 1] = pandoc.utils.stringify(k) end
      else
        kw_en[#kw_en + 1] = meta_str(meta, "keywords_en")
      end
      if #kw_en > 0 then
        blocks[#blocks + 1] = pandoc.Para({ pandoc.Strong(pandoc.Str("Keywords: ")), pandoc.Emph(pandoc.Str(table.concat(kw_en, ", ") .. ".")) })
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
    if not inserted and blk.tag == "Header" and blk.level == 1 and not is_unnumbered(blk) then
      for _, b in ipairs(daftar_isi()) do body[#body + 1] = b end
      if show_dt then
        for _, b in ipairs(daftar_auto("DAFTAR TABEL", "Tabel")) do body[#body + 1] = b end
      end
      if show_dg then
        for _, b in ipairs(daftar_auto("DAFTAR GAMBAR", "Gambar")) do body[#body + 1] = b end
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
