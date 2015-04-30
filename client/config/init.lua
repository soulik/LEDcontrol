local sql = require 'lsqlite3'

local db
local values = {
	--version = '1.0',
}

local M 

local function sql_assert(expr, msg)
	assert(expr == sql.OK, msg or db:errmsg())
end

M = {
	open = function()
		db = sql.open('data/config.sqlite3')
		M.prepare()
	end,
	prepare = function()
		sql_assert(db:exec([[
CREATE TABLE IF NOT EXISTS config (name TEXT(32) PRIMARY KEY, value TEXT);
]]))
	end,
	close = function()
		db:close()
	end,
	load = function()
		for row in db:nrows("SELECT name,value FROM config;") do
			values[row.name] = row.value
		end
	end,
	sync = function()
		local statements = {}
		for k,v in pairs(values) do
			table.insert(statements, ("INSERT OR REPLACE INTO config (name, value) VALUES ('%s', '%s');"):format(k, v))
		end
		print(table.concat(statements, "\n"))
		sql_assert(db:exec(table.concat(statements, "\n")))
	end,
}

setmetatable(M, {
	__index = values,
	__newindex = values,
})

M.open()
M.sync()
M.load()

return M