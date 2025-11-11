local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- 808 bass-drum Pdef scaffold + LCXL bind
  s(
    "bd808",
    fmt(
      [[
~loadSamplesRecursive.("{root}{subpath}");
(
~{var} = ~samplesTree.at(\bass_drums).asArray[0];
Pdef(\{name}).quant = {quant};
Pdef(\{name},
    ~pBuf.(
        Pbind(
            \buf,    ~{var},          // Buffer object
            \bufnum, Pkey(\buf),      // use Buffer’s bufnum
            \dur,    Pbjorklund2({k}, {n})/{div},
            \amp,    {amp},
            \rate,   {rate},
            \out,    ~p{name}.inbus.index
        )
    )
);
~lcxlBindPdef.(\{bindkey}, \{name});
)
~lcxlUnbindPdef.(\{bindkey}, \{name});
Pdef(\{name}).play;
Pdef(\{name}).stop({stopfade});
Pdef(\{name}).clear;
]],
      {
        root = i(1, "~/Music/supercollider/_samples/"),
        subpath = i(2, "808s_by_SHD/808_kit/"),
        var = i(3, "bd1"),
        name = i(4, "bd1"),
        quant = i(5, "1"),
        k = i(6, "3"),
        n = i(7, "8"),
        div = i(8, "4"),
        amp = i(9, "1.0"),
        rate = i(10, "1"),
        bindkey = i(11, "b0_s1_p"),
        stopfade = i(12, "3"),
      }
    )
  ),
}
-- return {
--   -- basic test snippet
--   s("sctest", fmt([[
--   (
--   // hello snippet
--   "Loaded snippet OK!".postln;
--   ~{} = SynthDef("{}", {{ |out=0| Out.ar(out, SinOsc.ar(440, 0, 0.1)) }}).add;
--   )
--   ]], {
--     i(1, "testSynth"),
--     i(2, "testSynth"),
--   })),
-- }
