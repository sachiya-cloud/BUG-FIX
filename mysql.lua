--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

-- dbList[defaultDB] settings
local hostname = get("hostname") or "51.83.49.125"
local port = tonumber(get("port")) or 3306
local username = get("username") or "u298386_tcAmS07Sl2"
local password = get("password") or "!gL1VjcuG9qqnzzS77C=F^U1"
local database = get("database") or "s298386_owl"
local options = ""
local defaultDB = "mta"
local dbList = {
  [defaultDB] = dbConnect("mysql", "dbname="..database..";host="..hostname..";port="..port..";charset=latin1;", username, password, options),
  -- you can add multiple DBs if you wish to do so.
}
local cache = {}
local lastHandler = nil

function getMySQLHost() return hostname end
function getMySQLPort() return port end
function getMySQLUsername() return username end
function getMySQLPassword() return password end
function getMySQLDBName() return database end
function getConn(connType)
  if not connType or not dbList[connType] then return dbList[defaultDB] end
  return dbList[connType]
end
function mysql_connect() return getConn() end

function num_rows(queryHandle)
    if not queryHandle or not cache[queryHandle] then return false end
    return cache[queryHandle].count
end

function escape_string(queryString) return queryString end
function insert_id() return (lastHandler and cache[lastHandler] and cache[lastHandler].id) or false end

function free_result(queryHandle)
    if not queryHandle or not cache[queryHandle] then return false end
    cache[queryHandle] = nil
    return dbFree(queryHandle)
end

function fetch_assoc(queryHandle)
    if not queryHandle or not cache[queryHandle] or not cache[queryHandle].result then return false end
    local row = cache[queryHandle].result[1] or false
    if row then table.remove(cache[queryHandle].result, 1) end
    return row
end

function query(...)
    local queryHandle = dbQuery(dbList[defaultDB], ...)
    local result, _, id = dbPoll(queryHandle, -1)
    cache[queryHandle] = {result = result, id = id, count = (result and #result) or 0}
    lastHandler = queryHandle
    return queryHandle
end

function query_fetch_assoc(...)
    local resultQuery = dbQuery(dbList[defaultDB], ...)
    local result = dbPoll(resultQuery, -1)
    dbFree(resultQuery)
    return (result and result[1]) or false
end

function query_insert_free(...)
    local resultQuery = dbQuery(dbList[defaultDB], ...)
    local _, _, id = dbPoll(resultQuery, -1)
    dbFree(resultQuery)
    return id or false
end

function query_free(...) return dbExec(dbList[defaultDB], ...) end

-- FIX: Added missing mysql_null function to prevent nil value errors
function mysql_null(val)
    if val == nil or val == "" or val == "N/A" then
        return "NULL"
    else
        return "'" .. tostring(val) .. "'"
    end
end

-- FIX: Added missing createMigrations / createMigrationsTable functions
function createMigrationsTable()
    -- Safe execution for table migrations if required by gamemode
    dbExec(dbList[defaultDB], "CREATE TABLE IF NOT EXISTS `migrations` (`id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(255) NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;")
end

function createMigrations()
    createMigrationsTable()
end


--Custom functions
local function createWhereClause( array, required )
	if not array then
		-- will cause an error if it's required and we wanna concat it.
		return not required and '' or nil
	end
	local strings = { }
	for i, k in pairs( array ) do
		table.insert( strings, "`" .. i .. "` = '" .. ( tonumber( k ) or escape_string( k ) ) .. "'" )
	end
	return ' WHERE ' .. table.concat(strings, ' AND ')
end

function select_one( tableName, clause )
	local result = query( "SELECT * FROM " .. tableName .. createWhereClause( clause ) .. ' LIMIT 1' )
	if result then
		local __result = fetch_assoc( result )
		free_result( result )
		return __result
	end
	return false
end

function insert( tableName, array )
	local keyNames = { }
	local values = { }
	for i, k in pairs( array ) do
		table.insert( keyNames, i )
		table.insert( values, tonumber( k ) or escape_string( k ) )
	end
	return query_insert_free("INSERT INTO `"..tableName.."` (`" .. table.concat( keyNames, "`, `" ) .. "`) VALUES ('" .. table.concat( values, "', '" ) .. "')")
end

function update( tableName, array, clause )
	local strings = { }
	for i, k in pairs( array ) do
		table.insert( strings, "`" .. i .. "` = " .. ( k == nil and "NULL" or ( "'" .. ( tonumber( k ) or escape_string( k ) ) .. "'" ) ) )
	end
	return query_free("UPDATE `" .. tableName .. "` SET " .. table.concat( strings, ", " ) .. createWhereClause( clause, true ))
end

function getSmallestID( table, index )
	index = index or 'id'
	return "(SELECT MIN(e1."..index.."+1) FROM "..table.." AS e1 LEFT JOIN "..table.." AS e2 ON e1."..index.." +1 = e2."..index.." WHERE e2."..index.." IS NULL)"
end
