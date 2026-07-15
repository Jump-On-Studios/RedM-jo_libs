jo.createModule("bucket")

local playersBuckets = {
    -- [bucketId] = {
    --     players = { source1, source2, source3 },
    --     index = {
    --         [source1] = 1,
    --         [source2] = 2,
    --         [source3] = 3,
    --     },
    -- }
}

--- Creates an empty bucket entry
---@param bucketId number (The bucket id to create)
---@return table (Return the newly created bucket)
local function createBucket(bucketId)
    local bucket = {
        players = {},
        index = {},
    }

    playersBuckets[bucketId] = bucket

    return bucket
end


--- Returns the list of players in a bucket
---@param bucketId number (The bucket id)
---@return table (Return the list of player sources in the bucket, or an empty table if the bucket doesn't exist)
function jo.bucket.getPlayersInBucket(bucketId)
    return playersBuckets[bucketId]?.players or {}
end

--- Adds a player to a bucket
---@param source number (The player source)
---@param bucketId number (The bucket id)
---@return boolean (Return `true` if the player was added, `false` if he was already in the bucket)
local function addPlayerToBucket(source, bucketId)
    local bucket = playersBuckets[bucketId]

    if not bucket then
        bucket = createBucket(bucketId)
    end

    -- Le joueur est déjà présent dans le bucket
    if bucket.index[source] then
        return false
    end

    table.insert(bucket.players, source)
    bucket.index[source] = #bucket.players

    return true
end

--- Removes a player from a bucket
---@param source number (The player source)
---@param bucketId number (The bucket id)
---@return boolean (Return `true` if the player was removed, `false` if the bucket or the player didn't exist)
local function removePlayerFromBucket(source, bucketId)
    local bucket = playersBuckets[bucketId]

    if not bucket then
        return false
    end

    local index = bucket.index[source]

    if not index then
        return false
    end

    local lastIndex = #bucket.players
    local lastPlayer = bucket.players[lastIndex]

    -- Remplace le joueur supprimé par le dernier joueur
    if index ~= lastIndex then
        bucket.players[index] = lastPlayer
        bucket.index[lastPlayer] = index
    end

    -- On supprime toujours le dernier élément, donc aucun décalage
    bucket.players[lastIndex] = nil

    bucket.index[source] = nil

    -- Supprime complètement le bucket lorsqu'il est vide
    if #bucket.players == 0 then
        playersBuckets[bucketId] = nil
    end

    return true
end

--- Moves a player from one bucket to another
---@param source number (The player source)
---@param oldBucket number (The bucket id the player is currently in)
---@param newBucket number (The bucket id to move the player to)
---@return boolean (Return `true` if the player was moved, `false` if `oldBucket` and `newBucket` are the same)
local function movePlayerToBucket(source, oldBucket, newBucket)
    if oldBucket == newBucket then
        return false
    end

    removePlayerFromBucket(source, oldBucket)
    addPlayerToBucket(source, newBucket)

    return true
end

AddEventHandler("onPlayerBucketChange", function(source, bucket, oldBucket)
    movePlayerToBucket(source, oldBucket, bucket)
end)


AddEventHandler("playerDropped", function()
    local source = source
    local bucket = GetPlayerRoutingBucket(source)
    removePlayerFromBucket(source, bucket)
end)
