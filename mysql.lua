--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]
-- Production Server
production = true
socket = ""

-- connection settings (Updated with your database details)
hostname = "51.83.49.125"
username = "u298386_tcAmS07SI2"
password = "!gL1VjcuG9qqnzS77C=F^U1"
database = "s298386_owl"
port = 3306

core_hostname = "51.83.49.125"
core_username = "u298386_tcAmS07SI2"
core_password = "!gL1VjcuG9qqnzS77C=F^U1"
core_database = "s298386_owl"
core_port = 3306

local dbConns = {}

function createConnection(res, db)
	if ((db and db == "mta") or not db) and not dbConns.mta then
		dbConns.mta = dbConnect("mysql","dbname=".. database ..";host="..hostname..";port="..port..";"..socket, username, password, "autoreconnect=1")
		if dbConns.mta then
			if eventName then
				outputDebugString("[MYSQL] createConnection / "..database.." / OK")
			else
				connectToDatabase(res) -- Restart the connection for the MySQL Module
				outputDebugString("[MYSQL] reconnectConnection / "..database.." / OK")
			end
		else
			if eventName then
				cancelEvent(true, "Cannot connect to the database.")
				outputDebugString("[MYSQL] createConnection / "..database.." / FAILED")
			else
				outputDebugString("[MYSQL] reconnectConnection / "..database.." / FAILED")
			end
		end
		-- create the migrations table if it didn't already exist.
		createMigrationsTable()
	elseif (db and db == "core") and not dbConns.core then
		dbConns.core = dbConnect("mysql","dbname=".. core_database ..";host="..core_hostname..";port="..core_port..";"..socket, core_username, core_password, "autoreconnect=1")
		if dbConns.core then
			if eventName then
				outputDebugString("[MYSQL] createConnection / "..core_database.." / OK")
			else
				outputDebugString("[MYSQL] reconnectConnection / "..core_database.." / OK")
			end
		else
			if eventName then
				cancelEvent(true, "Cannot connect to the database.")
				outputDebugString("[MYSQL] createConnection / "..core_database.." / FAILED")
			else
				outputDebugString("[MYSQL] reconnectConnection / "..core_database.." / FAILED")
			end
		end
	end

	if not eventName then
		return dbConns[db]
	end
end
addEventHandler("onResourceStart", resourceRoot, createConnection)

function getConn(db)
	if isElement(dbConns[db or 'mta']) then
		return dbConns[db or 'mta']
	else
		return createConnection(false, db or 'mta')
	end
end

function getSmallestID( table, index )
	index = index or 'id'
	return "(SELECT MIN(e1."..index.."+1) FROM "..table.." AS e1 LEFT JOIN "..table.." AS e2 ON e1."..index.." +1 = e2."..index.." WHERE e2."..index.." IS NULL)"
end
