ProficientUtils = {}

function ProficientUtils:SetDefault(table, key, defaultValue)
    -- set default value for a nested table key
    local keys = {strsplit(".", key)}
    local t = table
    for i = 1, #keys - 1 do
        if t[keys[i]] == nil then
            t[keys[i]] = {}
        end
        t = t[keys[i]]
    end
    if t[keys[#keys]] == nil then
        t[keys[#keys]] = defaultValue
    end
end

function ProficientUtils:ChatMessage(msg)
    -- print a message to chat
    if not ProficientStorage or ProficientStorage.showChatMessages then
        print(msg)
    end
end
