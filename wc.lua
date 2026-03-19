VERSION = "1.2.2"

local micro = import("micro")
local config = import("micro/config")
local util = import("micro/util")
local utf8 = import("unicode/utf8")

function init()
    micro.SetStatusInfoFn("wc.w")
    config.MakeCommand("wc", formatCount, config.NoComplete)
    config.AddRuntimeFile("wc", config.RTHelp, "help/wc.md")
    config.TryBindKey("F5", "lua:wc.wc", false)
end

function formatCount(b)
    local charCount, wordCount, lineCount = calc(b)
    micro.InfoBar():Message("Lines:" .. lineCount .. "  Words:"..wordCount.."  Characters:"..charCount)
end

function calc(b)
    -- Buffer of selection/whole document
    local buffer
    --Get active cursor (to get selection)
    local cursor = b.Buf:GetActiveCursor()
    --If cursor exists and there is selection, convert selection byte[] to string
    if cursor and cursor:HasSelection() then
        buffer = util.String(cursor:GetSelection())
    else
    --no selection, convert whole buffer byte[] to string
        buffer = util.String(b.Buf:Bytes())
    end
    --length of the buffer/selection (string), utf8 friendly
    charCount = utf8.RuneCountInString(buffer)
    --Get word/line count using gsub's number of substitutions
    -- number of substitutions, pattern: %w+ (more than one non-whitespace characters)
    local _ , wordCount = buffer:gsub("%w+","")
    -- number of substitutions, pattern: \n (number of newline characters)
    local _, lineCount = buffer:gsub("\n", "")
    --add one to line count (since we're counting separators not lines above)
    lineCount = lineCount + 1

    return charCount, wordCount, lineCount
end

function cc(b)
    local charCount, _, _ = calc(b)
    return charCount
end

function wc(b)
    local _, wordCount, _ = calc(b)
    return wordCount
end

function lc(b)
    local _, _, lineCount = calc(b)
    return lineCount
end
