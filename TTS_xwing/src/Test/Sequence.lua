Sequence = {}
Sequence.__index = Sequence

function Sequence:new()
    local seq = {}
    setmetatable(seq, Sequence)
    seq.tasks = {}
    seq.current = 1
    return seq
end

function Sequence:add(task, ...)
    table.insert(self.tasks, { func = task, args = { ... } })
end

function Sequence:next()
    if self.current <= #self.tasks then
        local task = self.tasks[self.current]
        self.current = self.current + 1
        task.func(self, table.unpack(task.args))
    end
end

function Sequence:start()
    self.current = 1
    self:next()
end

Sequence.NoSeq = {
    next = function() end
}

return Sequence
