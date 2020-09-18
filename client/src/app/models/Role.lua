
local Wizard = import(".Wizard")
local Role = class("Role")

local RoleMap  = {
	handler(Wizard, Wizard.create),
}

function Role:ctor()
end

function Role:build(role)
	return RoleMap[role]()
end

return Role