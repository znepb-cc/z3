local a = {}

function a.search(query, depth)
    local cdepth = 0
    local reachedDepth = false
    local output = {}

    local function search(path)
        local list = fs.list(path)
        for i, v in pairs(list) do
            local fpath = fs.combine(path, v)
            if not fs.isDir(fpath) and v:find(query) then
                table.insert(output, fpath)
            elseif fs.isDir(fpath) then
                if cdepth < depth then
                    search(fpath)
                else
                    reachedDpeth = true
                end
            end
        end
    end

    search("/")

    return output, reachedDepth
end

return a