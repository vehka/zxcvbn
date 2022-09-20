local VTerm={}

function VTerm:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function VTerm:init()
  self.view={row=1,col=1}
  self.cursor={row=1,col=3}
  self:load_text[[abcdef
 
jumped over the fence
]]
  self:move_cursor(0,0)
end

function VTerm:insert(row,col,s)
  return self.lines[row]:sub(1,col)..s..self.lines[row]:sub(col+1)
end

function VTerm:cursor_insert(s)
  local row=self.cursor.row
  local col=self.cursor.col
  if col==0 then
    self.lines[row]=s..self.lines[row]
  else
    self.lines[row]=self:insert(row,col,s)
  end
  self:move_cursor(0,1)
end

function VTerm:cursor_delete()
  local row=self.cursor.row
  local col=self.cursor.col
  if col==0 then
    do return end
  end
  self.lines[row]=self.lines[row]:sub(1,col-1)..self.lines[row]:sub(col+1)
  print(col)
  self:move_cursor(0,-1)
end

function VTerm:load_text(text)
  self.text=text
  self.lines={}
  for line in text:gmatch("([^\n]*)\n?") do
    table.insert(self.lines,line)
  end
end

function VTerm:move_cursor(row,col)
  self.cursor={row=self.cursor.row+row,col=self.cursor.col+col}
  if self.cursor.row>#self.lines then
    self.cursor.row=#self.lines
  end
  if self.cursor.row<1 then
    self.cursor.row=1
  end
  if self.cursor.col>#self.lines[self.cursor.row] then
    self.cursor.col=#self.lines[self.cursor.row]
  end
  if self.cursor.col<0 then
    self.cursor.col=0
  end
  local line=self.lines[self.cursor.row]
  line=line:gsub(" ","-")
  self.cursor.x=screen.text_extents(line:sub(1,self.cursor.col))+2
  if self.cursor.col==0 then
    self.cursor.x=1
  end
  print("self.cursor.col",self.cursor.col)
end

function VTerm:enc(k,d)
  if k==2 then
    self:move_cursor(0,d)
  elseif k==3 then
    self:move_cursor(d,0)
  end
end

function VTerm:key(k,z)
  if k==3 and z==1 then
    self:cursor_insert("z")
  elseif k==2 and z==1 then
    self:cursor_delete()
  end
end

function VTerm:redraw()
  screen.level(15)
  for i,line in ipairs(self.lines) do
    if i>=self.view.row then
      screen.level(15)
      screen.move(1,8*(i-self.view.row+1))
      screen.text(line:sub(self.view.col))
    end
    if self.cursor.row==i then
      screen.level(5)
      screen.move(self.cursor.x,8*(i-self.view.row+1)-6)
      screen.line(self.cursor.x,8*(i-self.view.row+1)+2)
      screen.stroke()
    end
  end
end

return VTerm