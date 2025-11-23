-- ~/.config/nvim/lua/snippets/supercollider.lua
-- 2025-11-22: Pdefn snippets (newline-safe for LuaSnip)

local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
  -- Pdefn + Pseq pattern block with editable name, list, repeat count
  s("pdefn", {
    t({ "Pdefn(\\", "" }),
    i(1, "name"),
    t({ ", Pseq([", "  " }),
    i(2, "0, 1, 0.25, 0"),
    t({ "", "], " }),
    i(3, "inf"),
    t("));"),
  }),

  -- Multi-line aligned-grid version (name stays on first line; padded grid)
  s("pdefndm", {
    t("Pdefn(\\"),
    i(1, "name"),
    t({ ", Pseq([", "  " }),

    -- row 1 (pre-padded columns)
    i(2, "0,   0,   0,   0,   0,   0,   0,   0"),
    t({ ",", "  " }),

    -- row 2 (pre-padded columns)
    i(3, "0,   0,   0,   0,   0,   0,   0,   0"),
    t({ "", "], " }),

    i(4, "inf"),
    t("));"),
  }),

  s("pdefnds", {
    t("Pdefn(\\"),
    i(1, "name"),
    t(" , Pseq([ 0,   0,    0,    0,      0,    0,    0,    0,    ],"),
    i(2, "inf"),
    t("));"),
  }),

  s("pbindef-midi", {
    t({"(", "Pbindef(\\"}),
    i(1, "name"),
    t({
        ", ",
        "  \\type,      \\midi,",
        "  \\midiout,   ~mOut,",
        "  \\chan,      0,",
        "  \\amp,       1,",
        "  \\octave,    3,",
        "  \\degree,    0,",
        "  \\dur,       0.25,",
        "));",
        ")"
    }),
  }),
}

