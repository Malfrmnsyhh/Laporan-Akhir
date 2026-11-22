-- docx.lua: filter Pandoc khusus Buku Panduan (Manual Book) HKI Program Komputer.
--  - Halaman 1: Sampul grafis full-bleed (margin 0) diikuti section break.
--  - Halaman 2 (i): DAFTAR ISI otomatis.
--  - Batang Tubuh: BAB I..V (Romawi), Sub-bab 1.1..5.2 (Arab), Sub-sub-bab 4.1.1 (Arab).

local bab = 0
local sub = 0
local subsub = 0
local toc_entries = {}
local doc_margins = { top = 1417, right = 1417, bottom = 1417, left = 1417 } -- 2.5cm

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

local function pagebreak()
  return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

local function meta_str(meta, key)
  local v = meta[key]
  if v == nil then return "" end
  if type(v) == "boolean" then return tostring(v) end
  return pandoc.utils.stringify(v)
end

local function Meta(meta)
  doc_margins.top = dim_to_twips(meta_str(meta, "margin_top"), doc_margins.top)
  doc_margins.bottom = dim_to_twips(meta_str(meta, "margin_bottom"), doc_margins.bottom)
  doc_margins.left = dim_to_twips(meta_str(meta, "margin_left"), doc_margins.left)
  doc_margins.right = dim_to_twips(meta_str(meta, "margin_right"), doc_margins.right)
end

function Header(el)
  if FORMAT ~= "docx" then return nil end
  local title = pandoc.utils.stringify(el.content)
  if is_unnumbered(el) then
    return nil
  end
  if el.level == 1 then
    bab = bab + 1
    sub = 0
    subsub = 0
    local full_bab = "BAB " .. roman(bab)
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
  elseif el.level == 2 then
    sub = sub + 1
    subsub = 0
    local num_str = tostring(bab) .. "." .. tostring(sub) .. " "
    toc_entries[#toc_entries + 1] = {
      level = 2,
      id = el.identifier,
      text = num_str .. title,
    }
    el.content = pandoc.Str(num_str .. title)
  elseif el.level == 3 then
    subsub = subsub + 1
    local num_str = tostring(bab) .. "." .. tostring(sub) .. "." .. tostring(subsub) .. " "
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
  if FORMAT ~= "docx" then return nil end
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
      for i = 1, ncols do el.colspecs[i][2] = eq end
    elseif math.abs(sum_w - 1.0) > 0.01 then
      for i = 1, ncols do el.colspecs[i][2] = el.colspecs[i][2] / sum_w end
    end
  end
  if el.head and el.head.rows then
    for _, row in ipairs(el.head.rows) do
      for i, cell in ipairs(row.cells) do
        row.cells[i] = process_table_cell(cell, "TableHeader")
      end
    end
  end
  if el.bodies then
    for _, body in ipairs(el.bodies) do
      if body.body then
        for _, row in ipairs(body.body) do
          for i, cell in ipairs(row.cells) do
            row.cells[i] = process_table_cell(cell, "TableCell")
          end
        end
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
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOCHeading"/><w:jc w:val="center"/><w:outlineLvl w:val="9"/></w:pPr>' ..
      '<w:r><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>DAFTAR ISI</w:t></w:r></w:p>'
  )
  out[#out + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:pStyle w:val="TOC1"/></w:pPr>' ..
      '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>' ..
      '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r>' ..
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

function Pandoc(doc)
  if FORMAT ~= "docx" then return doc end
  local meta = doc.meta
  local cover_file = meta_str(meta, "cover_image")
  if cover_file == "" then cover_file = "gambar/cover-buku-panduan.png" end

  local blocks = pandoc.List{}

  -- Halaman 1: Gambar Sampul Full-Bleed A4 (21cm x 29.7cm)
  blocks[#blocks + 1] = pandoc.Div(
    { pandoc.Para({ pandoc.Image({}, cover_file, "", pandoc.Attr("", {}, { width = "21cm", height = "29.7cm" })) }) },
    pandoc.Attr("", {}, { ["custom-style"] = "CoverImage" })
  )
  -- Section break dengan margin 0 untuk Halaman 1 (Cover)
  blocks[#blocks + 1] = pandoc.RawBlock(
    "openxml",
    '<w:p><w:pPr><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="0" w:right="0" w:bottom="0" w:left="0" w:header="0" w:footer="0" w:gutter="0"/></w:sectPr></w:pPr></w:p>'
  )

  -- Halaman 2 (i): Daftar Isi
  for _, b in ipairs(daftar_isi()) do
    blocks[#blocks + 1] = b
  end

  -- Section break untuk beralih ke batang tubuh (margin 2.5cm)
  blocks[#blocks + 1] = pandoc.RawBlock(
    "openxml",
    string.format(
      '<w:p><w:pPr><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="%d" w:right="%d" w:bottom="%d" w:left="%d" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>',
      doc_margins.top, doc_margins.right, doc_margins.bottom, doc_margins.left
    )
  )

  meta.title = nil
  meta.subtitle = nil
  meta.date = nil
  meta.author = nil

  doc.blocks = blocks .. doc.blocks
  return doc
end

return {
  { Meta = Meta },
  { Header = Header, Table = Table, Pandoc = Pandoc }
}
