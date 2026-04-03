VERSION = "1.3"

local micro = import("micro")
local config = import("micro/config")
local util = import("micro/util")
local utf8 = import("unicode/utf8")

function init()
    micro.SetStatusInfoFn("wc.cc")
    micro.SetStatusInfoFn("wc.wc")
    micro.SetStatusInfoFn("wc.lc")
    micro.SetStatusInfoFn("wc.status")
    config.MakeCommand("wc", formatCount, config.NoComplete)
    config.AddRuntimeFile("wc", config.RTHelp, "help/wc.md")
    config.TryBindKey("F5", "lua:wc.formatCount", false)
end

function getBuffer(b)
    -- If b.Buf exists, unwrap.
    if b.Buf then
        return b.Buf
    end
    -- Otherwise b is buffer, return.
    return b
end

function hasSelection(buf)
    --Get active cursor (to get selection).
    local cursor = buf:GetActiveCursor()

    -- If cursor and selection Buf exist, return selected Buf byte[] to string.
    if (cursor and cursor:HasSelection()) then
        return util.String(cursor:GetSelection())
    end

    -- Else, return the whole document Buf byte[] to string.
    return util.String(buf:Bytes())
end

function calc(b)
    -- Raw Buf object
    local buf = getBuffer(b)

    -- Buf of selection || Buf of document
    local buffer = hasSelection(buf)

    -- length of the buffer/selection (string), utf8 friendly
    local charCount = utf8.RuneCountInString(buffer)

    -- number of substitutions, pattern: %w+ (more than one non-whitespace characters)
    local _ , wordCount = buffer:gsub("%w+","")

    -- number of substitutions, pattern: \n (number of newline characters)
    local _, lineCount = buffer:gsub("\n", "")

    -- add one to line count (since we're counting separators not lines above)
    lineCount = lineCount + 1

    return charCount, wordCount, lineCount
end

function cc(b)
    local charCount, _, _ = calc(b)
    return tostring(charCount)
end

function wc(b)
    local _, wordCount, _ = calc(b)
    return tostring(wordCount)
end

function lc(b)
    local _, _, lineCount = calc(b)
    return tostring(lineCount)
end

function status(b)
    local charCount, wordCount, lineCount = calc(b)

    return "Lines:" .. lineCount .. "  Words:" .. wordCount .. "  Characters:" .. charCount
end

function formatCount(b)
    local charCount, wordCount, lineCount = calc(b)
    micro.InfoBar():Message("Lines:" .. lineCount .. "  Words:" .. wordCount .. "  Characters:" .. charCount)
end
