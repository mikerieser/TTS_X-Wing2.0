-- Check if string begins with the argument (no regex)
if not string.beginswith then
    string.beginswith = function(str, prefix)
        return (str:sub(1, prefix:len()) == prefix)
    end
    if not string.startswith then
        string.startswith = string.beginswith
    end
end

-- Check if the string ends with the argument (no regex)
if not string.endswith then
    string.endswith = function(str, prefix)
        return (str:sub(-1 * prefix:len(), -1) == prefix)
    end
end

-- Check if string contains argument anywhere in it (no regex)
if not string.contains then
    string.contains = function(str, query)
        if query == nil then
            return false
        end
        return (str:find(query, 1, true) ~= nil)
    end
end

-- Split a string by a plain-text separator (no patterns)
if not string.split then
    string.split = function(str, sep, trimParts)
        if type(sep) ~= "string" or sep == "" then
            return { trimParts and str:trim() or str }
        end
        local out = {}
        local start = 1
        local sepLen = #sep
        while true do
            local idx = str:find(sep, start, true)
            if not idx then
                local piece = str:sub(start)
                table.insert(out, trimParts and piece:trim() or piece)
                break
            end
            local piece = str:sub(start, idx - 1)
            table.insert(out, trimParts and piece:trim() or piece)
            start = idx + sepLen
        end
        return out
    end
end

if not string.trim then
    function string:trim()
        local len = #self
        if len <= 256 then
            -- Use pattern-based for shorter strings (faster, avoids bug)
            return (self:gsub("^%s+", ""):gsub("%s+$", ""))
        else
            -- Use loop-based for longer strings (avoids pattern bug)
            if len == 0 then return "" end

            -- Find the start index (first non-whitespace char)
            local start_idx = 1
            while start_idx <= len and self:byte(start_idx) <= 32 do -- ASCII whitespace <= 32
                start_idx = start_idx + 1
            end
            if start_idx > len then return "" end -- All whitespace

            -- Find the end index (last non-whitespace char)
            local end_idx = len
            while end_idx >= start_idx and self:byte(end_idx) <= 32 do
                end_idx = end_idx - 1
            end

            return self:sub(start_idx, end_idx)
        end
    end
end

return string
