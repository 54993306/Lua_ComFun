print("-----------------------------21")

local t = {}
t.a = 11
t.b = 22
t.c = "222"
local cc = {"111","222","333"}
print(table.concat(cc,";"))

print("------------------------------22")

--字符串的切割函数的使用

local p = "mall_110325"
local d = string.sub(p, 6, string.len(p));

print(d)


print(string.len("mall_"))

print("--------------------------------23")

local cc = {1,2}

local c = function()
    print("---")
    return cc
end

for k,v in pairs(c()) do    --在for循环中，c方法只会调用一次
    print(1)
end

print("------------------------------------24")

local c = "mall_123345678.jpg"

print(string.sub(c,string.len("mall_")+1,string.find(c,".jpg")-1))

print("------------------------------------25")

local c = "111"

print(string.format("%s%d",c,2))

print("----------------------------------26")

-- 表赋值给另外一个表，是引用
local c = {1,2,3}

local b = {}
b.c = c
table.insert(b.c,4)

for k,v in pairs(c) do
    print(v)
end

-- print(debug.traceback("==============222"))
print("----------------------------------27")

-- lua没有方法的重载
local b = {}
b.a = function()
    print("-------------1")
end

b.a = function(i)
    print("--------",i)
end

b.a()
b.a(2)

print("----------------------------------28")
-- 48 到 57 ascll码对应的 数字为 0 - 9

print(string.char(57)) -- 输出9

local cc = "123"

for i = 1 , string.len(cc) do
    print(string.byte(cc,i))
end

print("----------------------------------29")

for i=10,1,-2 do
    print(i)
end

print("----------------------------------30")

-- local c = 2               -- 无法编译通过
-- if 1<c<3 then
--     print("11")
-- end
print(debug.traceback("[ ERROR ]----->LinXiancheng"))
print("-----------------------------------31")
local tab1 =  {index = 1,pIndex = 7 ,cindex = 1,tablename  = "tab1"}
local tab2 =  {index = 0,pIndex = 11,cindex = 2,tablename  = "tab2"}
local tab3 =  {index = 0,pIndex = 9 ,cindex = 2,tablename  = "tab3"}
local tab4 =  {index = 1,pIndex = 7 ,cindex = 2,tablename  = "tab4"}
local tab13 =  {index = 1,pIndex = 7 ,cindex = 2,tablename  = "tab13"}
local tab14 =  {index = 1,pIndex = 8 ,cindex = 2,tablename  = "tab14"}
local tab5 =  {index = 1,pIndex = 7 ,cindex = 3,tablename  = "tab5"}
local tab6 =  {index = 0,pIndex = 6 ,cindex = 2,tablename  = "tab6"}
local tab7 =  {index = 2,pIndex = 16,cindex = 2,tablename  = "tab7"}
local tab8 =  {index = 4,pIndex = 15,cindex = 2,tablename  = "tab8"}
local tab9 =  {index = 3,pIndex = 13,cindex = 2,tablename  = "tab9"}
local tab10 = {index = 2,pIndex = 12,cindex = 2,tablename  = "tab10"}
local tab11 = {index = 4,pIndex = 14,cindex = 2,tablename  = "tab11"}
local tab12 = {index = 3,pIndex = 17,cindex = 2,tablename  = "tab12"}
--tab6,tab3,tab2,tab4,tab5,tab1,tab7,tab10,tab9,tab12,tab11,tab8

local bigtab = {tab1,tab2,tab3,tab4,tab5,tab6,tab7,tab8,tab9,tab10,tab11,tab12,tab13,tab14}

for k,v in pairs(bigtab) do
  print(v.index)
end
print("-------")

local function sortFun(a,b)
  if a.index == b.index then
    if a.pIndex == b.pIndex then
      return a.cindex < b.cindex
    else
      return a.pIndex < b.pIndex
    end
  else
    return a.index < b.index
  end
end

table.sort(bigtab,sortFun)

for k,v in pairs(bigtab) do
  print(v.index,v.pIndex,v.cindex,v.tablename)
end
print("-----------------------------------")
--快速排序实现多重排序

local sorttab
sorttab = function(tab,left,right,func)
 if right > left then
   local tright = right
   local tleft = left
   local save = tab[tleft]
   while tright > tleft do
        while tright > tleft and func(tab[tright],save) do        --    --tab[tright].index >= save.index
           tright = tright - 1
        end
        if tright > tleft then
           tab[tleft] = tab[tright]
           tleft = tleft + 1
        end
        while tright > tleft and not func(tab[tleft],save) do          --() --tab[left].index < save.index
          tleft = tleft + 1
        end
        if tright > tleft then
          tab[tright] = tab[tleft]
          tright = tright - 1
        end
   end
   tab[tleft] = save
   sorttab(tab,left,tleft-1,func)
   sorttab(tab,tleft+1,right,func)
 end
end

sorttab(bigtab,1,#bigtab,sortFun)

for k,v in ipairs(bigtab) do
  print(v.index,v.pIndex,v.cindex,v.tablename)
end

print("---------------32")

local cc = {}

local c = 2
-- local cc.ffc = {}   -- 表里面的不能再声明为local
cc.ffc = {}

table.insert(cc.ffc,c)


print("------------------33")


local tab = {}
local c = 3
tab.tt = c
--tab.tt = local c = 3
-- tab.fun = local function()    -- 不能两次声明tab里面元素的作用域
--   print("1")
-- end
local function _fun3()
  print("3") 
end  
tab.fun3 = _fun3
tab.fun2 = function()  print("2") end

tab.fun2()
tab.fun3()

print("-----------------------------34")


local tab = {}

local function f1()
  tab.f2()
end

tab.f2 = function()
  print("1")
end

f1()