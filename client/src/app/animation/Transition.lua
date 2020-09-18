local Transition = class("Transition")

function Transition:ctor(handler)
    self.handler = handler or {}
end

function Transition:canTransition()
    return  self.handler()
end

return Transition