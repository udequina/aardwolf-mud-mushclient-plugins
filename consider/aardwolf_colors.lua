local BLACK = 1
local RED = 2
local GREEN = 3
local YELLOW = 4
local BLUE = 5
local MAGENTA = 6
local CYAN = 7
local WHITE = 8

CODE_PREFIX = "@"
PREFIX_ESCAPE = "@@"

XTERM_CHAR = "x"

BLACK_CHAR = "k"
RED_CHAR = "r"
GREEN_CHAR = "g"
YELLOW_CHAR = "y"
BLUE_CHAR = "b"
MAGENTA_CHAR = "m"
CYAN_CHAR = "c"
WHITE_CHAR = "w"

BOLD_BLACK_CHAR = "D"
BOLD_RED_CHAR = "R"
BOLD_GREEN_CHAR = "G"
BOLD_YELLOW_CHAR = "Y"
BOLD_BLUE_CHAR = "B"
BOLD_MAGENTA_CHAR = "M"
BOLD_CYAN_CHAR = "C"
BOLD_WHITE_CHAR = "W"

NORMAL_CHARS = RED_CHAR..GREEN_CHAR..YELLOW_CHAR..BLUE_CHAR..MAGENTA_CHAR..CYAN_CHAR..WHITE_CHAR
BOLD_CHARS = BOLD_BLACK_CHAR..BOLD_RED_CHAR..BOLD_GREEN_CHAR..BOLD_YELLOW_CHAR..BOLD_BLUE_CHAR..BOLD_MAGENTA_CHAR..BOLD_CYAN_CHAR..BOLD_WHITE_CHAR
ALL_CHARS = XTERM_CHAR..NORMAL_CHARS..BOLD_CHARS

XTERM_CODE = CODE_PREFIX..XTERM_CHAR

BLACK_CODE = CODE_PREFIX..BLACK_CHAR
RED_CODE = CODE_PREFIX..RED_CHAR
GREEN_CODE = CODE_PREFIX..GREEN_CHAR
YELLOW_CODE = CODE_PREFIX..YELLOW_CHAR
BLUE_CODE = CODE_PREFIX..BLUE_CHAR
MAGENTA_CODE = CODE_PREFIX..MAGENTA_CHAR
CYAN_CODE = CODE_PREFIX..CYAN_CHAR
WHITE_CODE = CODE_PREFIX..WHITE_CHAR

BOLD_BLACK_CODE = CODE_PREFIX..BOLD_BLACK_CHAR
BOLD_RED_CODE = CODE_PREFIX..BOLD_RED_CHAR
BOLD_GREEN_CODE = CODE_PREFIX..BOLD_GREEN_CHAR
BOLD_YELLOW_CODE = CODE_PREFIX..BOLD_YELLOW_CHAR
BOLD_BLUE_CODE = CODE_PREFIX..BOLD_BLUE_CHAR
BOLD_MAGENTA_CODE = CODE_PREFIX..BOLD_MAGENTA_CHAR
BOLD_CYAN_CODE = CODE_PREFIX..BOLD_CYAN_CHAR
BOLD_WHITE_CODE = CODE_PREFIX..BOLD_WHITE_CHAR

TILDE_PATTERN = CODE_PREFIX.."%-"
X_NONNUMERIC_PATTERN = XTERM_CODE.."([^%d])"
X_THREEHUNDRED_PATTERN = XTERM_CODE.."[3-9]%d%d"
X_TWOSIXTY_PATTERN = XTERM_CODE.."2[6-9]%d"
X_TWOFIFTYSIX_PATTERN = XTERM_CODE.."25[6-9]"
X_DIGITS_CAPTURE_PATTERN = XTERM_CODE.."(%d%d?%d?)"
X_ANY_DIGITS_PATTERN = XTERM_CODE.."%d?%d?%d?"

ALL_CODES_PATTERN = CODE_PREFIX.."."
HIDDEN_GARBAGE_PATTERN = CODE_PREFIX.."[^"..ALL_CHARS.."]"
BOLD_CODES_CAPTURE_PATTERN = "("..CODE_PREFIX.."["..BOLD_CHARS.."])"
NORMAL_CODES_CAPTURE_PATTERN = "("..CODE_PREFIX.."["..NORMAL_CHARS.."])"
NONX_CODES_CAPTURE_PATTERN = "("..CODE_PREFIX.."[^"..XTERM_CHAR.."])"
CODE_REST_CAPTURE_PATTERN = "("..CODE_PREFIX.."%a)([^"..CODE_PREFIX.."]*)"

X3DIGIT_FORMAT = XTERM_CODE.."%03d"
X2DIGIT_FORMAT = XTERM_CODE.."%02d"
X1DIGIT_FORMAT = XTERM_CODE.."%d"


local code_to_ansi_digit = {
   [RED_CODE] = 31,
   [GREEN_CODE] = 32,
   [YELLOW_CODE] = 33,
   [BLUE_CODE] = 34,
   [MAGENTA_CODE] = 35,
   [CYAN_CODE] = 36,
   [WHITE_CODE] = 37,
   [BOLD_BLACK_CODE] = 30,
   [BOLD_RED_CODE] = 31,
   [BOLD_GREEN_CODE] = 32,
   [BOLD_YELLOW_CODE] = 33,
   [BOLD_BLUE_CODE] = 34,
   [BOLD_MAGENTA_CODE] = 35,
   [BOLD_CYAN_CODE] = 36,
   [BOLD_WHITE_CODE] = 37
}

local ansi_digit_to_dim_code = {
   [31] = RED_CODE,
   [32] = GREEN_CODE,
   [33] = YELLOW_CODE,
   [34] = BLUE_CODE,
   [35] = MAGENTA_CODE,
   [36] = CYAN_CODE,
   [37] = WHITE_CODE
}

local ansi_digit_to_bold_code = {
   [30] = BOLD_BLACK_CODE,
   [31] = BOLD_RED_CODE,
   [32] = BOLD_GREEN_CODE,
   [33] = BOLD_YELLOW_CODE,
   [34] = BOLD_BLUE_CODE,
   [35] = BOLD_MAGENTA_CODE,
   [36] = BOLD_CYAN_CODE,
   [37] = BOLD_WHITE_CODE
}

local first_15_to_code = {}
local code_to_xterm = {}
for k,v in pairs(ansi_digit_to_dim_code) do
   first_15_to_code[k-30] = v  -- 1...7
end
for k,v in pairs(ansi_digit_to_bold_code) do
   first_15_to_code[k-22] = v  -- 8...15
end
for k,v in pairs(first_15_to_code) do
   code_to_xterm[v] = string.format(X3DIGIT_FORMAT, k)
end

local bold_codes = {
   [BOLD_BLACK_CODE]=true, [BOLD_RED_CODE]=true, [BOLD_GREEN_CODE]=true, [BOLD_YELLOW_CODE]=true, [BOLD_BLUE_CODE]=true,
   [BOLD_MAGENTA_CODE]=true, [BOLD_CYAN_CODE]=true, [BOLD_WHITE_CODE]=true
}
for i = 9,15 do
   bold_codes[string.format(X3DIGIT_FORMAT,i)] = true
   bold_codes[string.format(X2DIGIT_FORMAT,i)] = true
   bold_codes[string.format(X1DIGIT_FORMAT,i)] = true
end


local code_to_client_color = {}
local client_color_to_dim_code = {}
local client_color_to_bold_code = {}

function Init_basic_to_color ()
   Default_black = GetNormalColour(BLACK)

   code_to_client_color = {
      [RED_CODE] = GetNormalColour(RED),
      [GREEN_CODE] = GetNormalColour(GREEN),
      [YELLOW_CODE] = GetNormalColour(YELLOW),
      [BLUE_CODE] = GetNormalColour(BLUE),
      [MAGENTA_CODE] = GetNormalColour(MAGENTA),
      [CYAN_CODE] = GetNormalColour(CYAN),
      [WHITE_CODE] = GetNormalColour(WHITE),
      [BOLD_BLACK_CODE] = GetBoldColour(BLACK),
      [BOLD_RED_CODE] = GetBoldColour(RED),
      [BOLD_GREEN_CODE] = GetBoldColour(GREEN),
      [BOLD_YELLOW_CODE] = GetBoldColour(YELLOW),
      [BOLD_BLUE_CODE] = GetBoldColour(BLUE),
      [BOLD_MAGENTA_CODE] = GetBoldColour(MAGENTA),
      [BOLD_CYAN_CODE] = GetBoldColour(CYAN),
      [BOLD_WHITE_CODE] = GetBoldColour(WHITE)
   }
end

function Init_color_to_basic ()
   client_color_to_dim_code = {
      [code_to_client_color[RED_CODE]] = RED_CODE,
      [code_to_client_color[GREEN_CODE]] = GREEN_CODE,
      [code_to_client_color[YELLOW_CODE]] = YELLOW_CODE,
      [code_to_client_color[BLUE_CODE]] = BLUE_CODE,
      [code_to_client_color[MAGENTA_CODE]] = MAGENTA_CODE,
      [code_to_client_color[CYAN_CODE]] = CYAN_CODE,
      [code_to_client_color[WHITE_CODE]] = WHITE_CODE
   }

   client_color_to_bold_code = {
      [code_to_client_color[BOLD_BLACK_CODE]] = BOLD_BLACK_CODE,
      [code_to_client_color[BOLD_RED_CODE]] = BOLD_RED_CODE,
      [code_to_client_color[BOLD_GREEN_CODE]] = BOLD_GREEN_CODE,
      [code_to_client_color[BOLD_YELLOW_CODE]] = BOLD_YELLOW_CODE,
      [code_to_client_color[BOLD_BLUE_CODE]] = BOLD_BLUE_CODE,
      [code_to_client_color[BOLD_MAGENTA_CODE]] = BOLD_MAGENTA_CODE,
      [code_to_client_color[BOLD_CYAN_CODE]] = BOLD_CYAN_CODE,
      [code_to_client_color[BOLD_WHITE_CODE]] = BOLD_WHITE_CODE
   }
end

function Init_basic_colors ()
   Init_basic_to_color()
   Init_color_to_basic()
end


local xterm_number_to_client_color = extended_colours
local client_color_to_xterm_number = {}
local client_color_to_xterm_code = {}
local x_to_client_color = {}
local x_not_too_dark = {}
function Init_xterm_colors ()
   for i = 0,255 do
      local color = xterm_number_to_client_color[i]
      x_not_too_dark[i] = i
      x_to_client_color[string.format(X3DIGIT_FORMAT,i)] = color
      x_to_client_color[string.format(X2DIGIT_FORMAT,i)] = color
      x_to_client_color[string.format(X1DIGIT_FORMAT,i)] = color

      client_color_to_xterm_number[color] = i
      client_color_to_xterm_code[color] = string.format(X3DIGIT_FORMAT,i)
   end

   -- Aardwolf bumps a few very dark xterm colors to brighter values to improve
   -- visibility. This seems like a good idea.
   local function override_dark_color (replace_what, with_what)
      local new_color = xterm_number_to_client_color[with_what]
      x_not_too_dark[replace_what] = with_what
      x_to_client_color[string.format(X3DIGIT_FORMAT,replace_what)] = new_color
      x_to_client_color[string.format(X2DIGIT_FORMAT,replace_what)] = new_color
      x_to_client_color[string.format(X1DIGIT_FORMAT,replace_what)] = new_color
   end

   override_dark_color(0, 7)
   override_dark_color(16, 7)
   override_dark_color(17, 19)
   override_dark_color(18, 19)
   for i = 232,237 do
      override_dark_color(i, 238)
   end
end

Init_xterm_colors()
Init_basic_colors()

function StylesToColours (styles, dollarC_resets)
   Init_basic_colors()
   local line = {}
   local lastcode = ""
   for i,style in ipairs(styles) do
      local bold = style.bold or (style.style and ((style.style % 2) == 1))
      local text = string.gsub(style.text, CODE_PREFIX, PREFIX_ESCAPE)
      local textcolor = style.textcolour
      local code = style.fromx
                   or bold and client_color_to_bold_code[textcolor]
                   or client_color_to_dim_code[textcolor]
                   or client_color_to_xterm_code[textcolor]

      if code and (lastcode ~= code) then
         table.insert(line, code)
         lastcode = code
      end
      if dollarC_resets then
         text = text:gsub("%$C", lastcode)
      end
      table.insert(line, text)
   end
   return table.concat(line)
end


require "copytable"
function TruncateStyles (styles, startcol, endcol)
   if not styles or #styles == 0 then
      return ""
   end

   local startcol = startcol or 1
   local endcol = endcol or 99999 -- 99999 is assumed to be long enough to cover ANY style run

   -- negative column indices are used to measure back from the end
   if startcol < 0 or endcol < 0 then
      local total_chars = 0
      for k,v in ipairs(styles) do
         total_chars = total_chars + v.length
      end
      if startcol < 0 then
         startcol = total_chars + startcol + 1
      end
      if endcol < 0 then
         endcol = total_chars + endcol + 1
      end
   end

   -- start/end order does not matter
   if startcol > endcol then
      startcol, endcol = endcol, startcol
   end

   -- Trim to start and end positions in styles
   local first_style = 0 -- not 1 because we check for foundness
   local col_counter = 0
   local new_styles = {}
   local break_after = false
   for k,v in ipairs(styles) do
      local new_style = copytable.shallow(v)
      col_counter = col_counter + new_style.length
      if endcol <= col_counter then
         new_style.text = new_style.text:sub(1, endcol - (col_counter - v.length))
         new_style.length = #(new_style.text)
         break_after = true
      end
      if startcol <= col_counter then
         if first_style == 0 then
            first_style = k
            new_style.text = new_style.text:sub(startcol - (col_counter - v.length))
            new_style.length = #(new_style.text)
         end
         table.insert(new_styles, new_style)
      end
      if break_after then break end
   end

   return new_styles
end


-- Converts text with colour codes in it into style runs
function ColoursToStyles (input, default_foreground_code, default_background_code)
   local textcolor = ""
   local num = 0
   Init_basic_to_color()
   if default_foreground_code and default_foreground_code:sub(1,1) ~= CODE_PREFIX then
      default_foreground_code = CODE_PREFIX..default_foreground_code
   end
   if default_background_code and default_background_code:sub(1,1) ~= CODE_PREFIX then
      default_background_code = CODE_PREFIX..default_background_code
   end
   local default_bold = false
   local default_foreground = code_to_client_color[default_foreground_code] or x_to_client_color[default_foreground_code]
   if not default_foreground then
      default_foreground = code_to_client_color[WHITE_CODE]
      default_foreground_code = WHITE_CODE
   else
      default_bold = bold_codes[default_foreground_code] or false
      default_foreground_code = default_foreground_code
   end
   local default_background = code_to_client_color[default_background_code] or x_to_client_color[default_background_code]
   if not default_background then
      default_background = Default_black
   end

   if input:find(CODE_PREFIX, nil, true) then
      local astyles = {}

      -- make sure we start with a color
      if input:sub(1, 1) ~= CODE_PREFIX then
         input = default_foreground_code .. input
      end -- if

      input = input:gsub(PREFIX_ESCAPE, "\0") -- change @@ to 0x00
      input = input:gsub(TILDE_PATTERN, "~") -- fix tildes (historical)
      input = input:gsub(X_NONNUMERIC_PATTERN,"%1") -- strip invalid xterm codes (non-number)
      input = input:gsub(X_THREEHUNDRED_PATTERN,"") -- strip invalid xterm codes (300+)
      input = input:gsub(X_TWOSIXTY_PATTERN,"") -- strip invalid xterm codes (260+)
      input = input:gsub(X_TWOFIFTYSIX_PATTERN,"") -- strip invalid xterm codes (256+)
      input = input:gsub(HIDDEN_GARBAGE_PATTERN, "")  -- strip hidden garbage

      for code, text in input:gmatch(CODE_REST_CAPTURE_PATTERN) do
         local from_x = nil
         text = text:gsub("%z", CODE_PREFIX) -- put any @ characters back

         if code == XTERM_CODE then -- xterm 256 colors
            num,text = text:match("(%d%d?%d?)(.*)")
            code = code..num
            -- Aardwolf treats x1...x15 as normal ANSI colors.
            -- That behavior does not match MUSHclient's.
            num = tonumber(num)
            from_x = code
            if num <= 15 then
               textcolor = code_to_client_color[first_15_to_code[num]]
            else
               textcolor = x_to_client_color[code]
            end
         else
            textcolor = code_to_client_color[code]
         end

         table.insert(astyles,
         {
            fromx = from_x,
            text = text,
            bold = bold_codes[code] or false,
            length = #text,
            textcolour = textcolor or default_foreground,
            backcolour = default_background
         })
      end -- for each colour run.

      return astyles
   end -- if any colour codes at all

   -- No colour codes, create a single style.
   return {{
      text = input,
      bold = default_bold,
      length = #input,
      textcolour = default_foreground,
      backcolour = default_background
   }}
end  -- function ColoursToStyles


-- Strip all color codes from a string
function Strip_colours (s)
   s = s:gsub(PREFIX_ESCAPE, "\0")  -- change @@ to 0x00
   s = s:gsub(TILDE_PATTERN, "~")    -- fix tildes (historical)
   s = s:gsub(X_ANY_DIGITS_PATTERN, "") -- strip valid and invalid xterm color codes
   s = s:gsub(ALL_CODES_PATTERN, "") -- strip normal color codes and hidden garbage
   return (s:gsub("%z", CODE_PREFIX)) -- put @ back (has parentheses on purpose)
end -- strip_colours


-- Convert Aardwolf and short x codes to 3 digit x codes
function Canonicalize_colours (s, keep_original)
   if s:find(CODE_PREFIX, nil, true) then
      s = s:gsub(X_DIGITS_CAPTURE_PATTERN, function(a)
         local b = tonumber(a)
         if b and b <= 255 and b >= 0 then
            if keep_original and b <= 15 then
               return first_15_to_code[b]
            end
            return string.format(X3DIGIT_FORMAT, b)
         else
            return ""
         end
      end)
      if not keep_original then
         s = s:gsub(NONX_CODES_CAPTURE_PATTERN, function(a)
            return code_to_xterm[a]
         end)
      end
   end
   return s
end


-- Strip all color codes from a table of styles
function Strip_colours_from_styles (styles)
   local ret = {}
   for i,v in ipairs(styles) do
      table.insert(ret, v.text)
   end
   return table.concat(ret)
end


-- Returns a string with embedded ansi codes.
-- This can get confused if the player has redefined their color chart.
function StylesToANSI (styles, dollarC_resets)
   local line = {}
   local lastcode = ""
   Init_basic_colors()
   for _,v in ipairs(styles) do
      local code = ""
      local textcolor = v.textcolour
      if textcolor then
         local isbold = (v.bold or (v.style and ((v.style % 2) == 1)))
         if v.fromx then
            code = ANSI(isbold and 1 or 0, 38, 5, v.fromx:sub(3))
         elseif isbold and client_color_to_bold_code[textcolor] then
            local a = client_color_to_bold_code[textcolor]
            code = ANSI(1, code_to_ansi_digit[a])
         elseif client_color_to_dim_code[textcolor] then
            local a = client_color_to_dim_code[textcolor]
            code = ANSI(0, code_to_ansi_digit[a])
         elseif client_color_to_xterm_number[textcolor] then
            code = ANSI(isbold and 1 or 0, 38, 5, client_color_to_xterm_number[textcolor])
         end
      end
      if code ~= "" then
         lastcode = code
      end
      if dollarC_resets then
         v.text = v.text:gsub("%$C", lastcode)
      end
      table.insert(line, code..v.text)
   end
   return table.concat(line)
end


-- Tries to convert ANSI sequences to Aardwolf color codes
function AnsiToColours (ansi, default_foreground_code)
   if not default_foreground_code then
      default_foreground_code = WHITE_CODE
   elseif default_foreground_code:sub(1,1) ~= CODE_PREFIX then
      default_foreground_code = CODE_PREFIX..default_foreground_code
   end

   local ansi_capture = "\027%[([%d;]+)m"

   -- this stuff goes outside because ANSI is a state machine (lolsigh)
   local bold = false
   local color = ""
   local xstage = 0

   ansi = ansi:gsub(CODE_PREFIX, PREFIX_ESCAPE):gsub(ansi_capture, function(a)
      for c in a:gmatch("%d+") do
         local nc = tonumber(c)
         if nc == 38 then
            xstage = 1
         elseif nc == 5 and xstage == 1 then
            xstage = 2
         elseif xstage == 2 then -- xterm 256 color
            if bold and ansi_digit_to_bold_code[nc+30] then
               color = ansi_digit_to_bold_code[nc+30]
            else
               color = string.format(X3DIGIT_FORMAT, nc)
            end
            xstage = 0
         elseif nc == 1 then
            bold = true
            xstage = 0
         elseif nc == 0 then
            bold = bold_codes[default_foreground_code] or false
            -- not actually sure if we should set color here or not
            color = default_foreground_code
         elseif nc <= 37 and nc >= 30 then -- regular color
            if bold then
               color = ansi_digit_to_bold_code[nc]
            else
               color = ansi_digit_to_dim_code[nc]
            end
            xstage = 0
         end
      end
      return color
   end)

   return ansi
end


function ColoursToANSI (text)
   -- return stylesToANSI(ColoursToStyles(text))
   if text:find(CODE_PREFIX, nil, true) then
      text = text:gsub(PREFIX_ESCAPE, "\0") -- change @@ to 0x00
      text = text:gsub(TILDE_PATTERN, "~") -- fix tildes (historical)
      text = text:gsub(X_NONNUMERIC_PATTERN,"%1") -- strip invalid xterm codes (non-number)
      text = text:gsub(X_THREEHUNDRED_PATTERN,"") -- strip invalid xterm codes (300+)
      text = text:gsub(X_TWOSIXTY_PATTERN,"") -- strip invalid xterm codes (260+)
      text = text:gsub(X_TWOFIFTYSIX_PATTERN,"") -- strip invalid xterm codes (256+)
      text = text:gsub(HIDDEN_GARBAGE_PATTERN, "")  -- strip hidden garbage

      text = text:gsub(X_DIGITS_CAPTURE_PATTERN, function(a)
         local num_a = tonumber(a)
         -- Aardwolf treats x1...x15 as normal ANSI codes
         if num_a >=1 and num_a <= 15 then
            if num_a >= 9 then
               return ANSI(1, num_a+22)
            else
               return ANSI(0, num_a+30)
            end
         else
            return ANSI(0, 38, 5, x_not_too_dark[num_a])
         end
      end)
      text = text:gsub(BOLD_CODES_CAPTURE_PATTERN, function(a)
         return ANSI(1,code_to_ansi_digit[a])
      end)
      text = text:gsub(NORMAL_CODES_CAPTURE_PATTERN, function(a)
         return ANSI(0,code_to_ansi_digit[a])
      end)

      text = text:gsub("%z", CODE_PREFIX)
   end
   return text
end


-- EVERYTHING BELOW HERE IS DEPRECATED. DO NOT USE. --

-- Historical function without purpose. Use StylesToColours.
-- Use TruncateStyles if you must, but that seems to be rather uncommon.
--
-- Convert a partial line of style runs into color codes.
-- Yes the "OneLine" part of the function name is meaningless. It stays that way for historical compatibility.
-- Think of it instead as TruncatedStylesToColours
-- The caller may optionally choose to start and stop at arbitrary character indices.
-- Negative indices are measured backward from the end.
-- The order of start and end columns does not matter, since the start will always be lower than the end.
function StylesToColoursOneLine (styles, startcol, endcol)
   if startcol or endcol then
      return StylesToColours( TruncateStyles(styles, startcol, endcol) )
   else
      return StylesToColours( styles )
   end
end -- StylesToColoursOneLine


-- should have been marked local to prevent external use
local colour_conversion = {
   [BLACK_CHAR] = GetNormalColour(BLACK)   ,   -- 0x000000
   [RED_CHAR] = GetNormalColour(RED)     ,   -- 0x000080
   [GREEN_CHAR] = GetNormalColour(GREEN)   ,   -- 0x008000
   [YELLOW_CHAR] = GetNormalColour(YELLOW)  ,   -- 0x008080
   [BLUE_CHAR] = GetNormalColour(BLUE)    ,   -- 0x800000
   [MAGENTA_CHAR] = GetNormalColour(MAGENTA) ,   -- 0x800080
   [CYAN_CHAR] = GetNormalColour(CYAN)    ,   -- 0x808000
   [WHITE_CHAR] = GetNormalColour(WHITE)   ,   -- 0xC0C0C0
   [BOLD_BLACK_CHAR] = GetBoldColour(BLACK)   ,   -- 0x808080
   [BOLD_RED_CHAR] = GetBoldColour(RED)     ,   -- 0x0000FF
   [BOLD_GREEN_CHAR] = GetBoldColour(GREEN)   ,   -- 0x00FF00
   [BOLD_YELLOW_CHAR] = GetBoldColour(YELLOW)  ,   -- 0x00FFFF
   [BOLD_BLUE_CHAR] = GetBoldColour(BLUE)    ,   -- 0xFF0000
   [BOLD_MAGENTA_CHAR] = GetBoldColour(MAGENTA) ,   -- 0xFF00FF
   [BOLD_CYAN_CHAR] = GetBoldColour(CYAN)    ,   -- 0xFFFF00
   [BOLD_WHITE_CHAR] = GetBoldColour(WHITE)   ,   -- 0xFFFFFF
}  -- end conversion table

local atletter_to_color_value = colour_conversion -- lol. https://github.com/endavis/bastmush/commit/6f8aec07449a55a65ccece05c1ab3a0139d70e54
