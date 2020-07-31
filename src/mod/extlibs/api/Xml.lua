--- Based on Penlight's `xml` library.
---
--- XML LOM Utilities.
--
-- This implements some useful things on [LOM](http://matthewwild.co.uk/projects/luaexpat/lom.html) documents, such as returned by `lxp.lom.parse`.
-- In particular, it can convert LOM back into XML text, with optional pretty-printing control.
-- It is s based on stanza.lua from [Prosody](http://hg.prosody.im/trunk/file/4621c92d2368/util/stanza.lua)
--
--     > d = xml.parse "<nodes><node id='1'>alice</node></nodes>"
--     > = d
--     <nodes><node id='1'>alice</node></nodes>
--     > = xml.tostring(d,'','  ')
--     <nodes>
--        <node id='1'>alice</node>
--     </nodes>
--
-- Can be used as a lightweight one-stop-shop for simple XML processing; a simple XML parser is included
-- but the default is to use `lxp.lom` if it can be found.
-- <pre>
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain--
-- classic Lua XML parser by Roberto Ierusalimschy.
-- modified to output LOM format.
-- http://lua-users.org/wiki/LuaXml
-- </pre>
-- See @{06-data.md.XML|the Guide}
--
-- Dependencies: `pl.utils`
--
-- Soft Dependencies: `lxp.lom` (fallback is to use basic Lua parser)
-- @module pl.xml

local t_insert      =  table.insert;
local pairs         =         pairs;
local ipairs        =        ipairs;
local type          =          type;
local s_gsub        =   string.gsub;
local pcall,require     =   pcall,require

local Fs = require("api.Fs")
local XmlDoc = require("mod.extlibs.api.XmlDoc")

--- split a string into a list of strings separated by a delimiter.
-- @param s The input string
-- @param re A Lua string pattern; defaults to '%s+'
-- @param plain don't use Lua patterns
-- @param n optional maximum number of splits
-- @return a list-like table
-- @raise error if s is not a string
local function split(s,re,plain,n)
   local find,sub,append = string.find, string.sub, table.insert
   local i1,ls = 1,{}
   if not re then re = '%s+' end
   if re == '' then return {s} end
   while true do
      local i2,i3 = find(s,re,i1,plain)
      if not i2 then
         local last = sub(s,i1)
         if last ~= '' then append(ls,last) end
         if #ls == 1 and ls[1] == '' then
            return {}
         else
            return ls
         end
      end
      append(ls,sub(s,i1,i2-1))
      if n and #ls == n then
         ls[#ls] = sub(s,i1)
         return ls
      end
      i1 = i3+1
   end
end

local Xml = {}

--- parse an XML document.  By default, this uses lxp.lom.parse, but
-- falls back to basic_parse, or if use_basic is true
-- @param text_or_file  file or string representation
-- @param is_file whether text_or_file is a file name or not
-- @param use_basic do a basic parse
-- @return a parsed LOM document with the document metatatables set
-- @return nil, error the error can either be a file error or a parse error
function Xml.parse(text_or_file, is_file, use_basic)
   local parser,status,lom
   if use_basic then parser = Xml.basic_parse
   else
      status,lom = pcall(require,'lxp.lom')
      if not status then parser = Xml.basic_parse else parser = lom.parse end
   end
   if is_file then
      local err
      text_or_file, err = Fs.read_all(text_or_file)
      if not text_or_file then
         return nil, err
      end
   end
   local doc,err = parser(text_or_file)
   if not doc then return nil,err end
   if lom then
      Xml.walk(doc,false,function(_,d)
                  local doc = XmlDoc:new(d.tag, d.attr)
                  for k, v in pairs(d) do
                     doc[k] = v
                  end
      end)
   end
   return doc
end

local function is_text(s) return type(s) == 'string' end

--- function to create an element with a given tag name and a set of children.
-- @param tag a tag name
-- @param items either text or a table where the hash part is the attributes and the list part is the children.
function Xml.elem(tag,items)
   local s = XmlDoc:new(tag)
   if is_text(items) then items = {items} end
   if Xml.is_tag(items) then
      t_insert(s,items)
   elseif type(items) == 'table' then
      for k,v in pairs(items) do
         if is_text(k) then
            s.attr[k] = v
            t_insert(s.attr,k)
         else
            s[k] = v
         end
      end
   end
   return s
end

--- given a list of names, return a number of element constructors.
-- @param list  a list of names, or a comma-separated string.
-- @usage local parent,children = doc.tags 'parent,children' <br>
--  doc = parent {child 'one', child 'two'}
function Xml.tags(list)
   local ctors = {}
   if is_text(list) then list = split(list,'%s*,%s*') end
   for _,tag in ipairs(list) do
      local ctor = function(items) return Xml.elem(tag,items) end
      t_insert(ctors,ctor)
   end
   return unpack(ctors)
end

local xml_escape
do
   local escape_table = { ["'"] = "&apos;", ["\""] = "&quot;", ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" };
   function xml_escape(str) return (s_gsub(str, "['&<>\"]", escape_table)); end
   Xml.xml_escape = xml_escape
end

--- compare two documents.
-- @param t1 any value
-- @param t2 any value
function Xml.compare(t1,t2)
   local ty1 = type(t1)
   local ty2 = type(t2)
   if ty1 ~= ty2 then return false, 'type mismatch' end
   if ty1 == 'string' then
      return t1 == t2 and true or 'text '..t1..' ~= text '..t2
   end
   if ty1 ~= 'table' or ty2 ~= 'table' then return false, 'not a document' end
   if t1.tag ~= t2.tag then return false, 'tag  '..t1.tag..' ~= tag '..t2.tag end
   if #t1 ~= #t2 then return false, 'size '..#t1..' ~= size '..#t2..' for tag '..t1.tag end
   -- compare attributes
   for k,v in pairs(t1.attr) do
      if t2.attr[k] ~= v then return false, 'mismatch attrib' end
   end
   for k,v in pairs(t2.attr) do
      if t1.attr[k] ~= v then return false, 'mismatch attrib' end
   end
   -- compare children
   for i = 1,#t1 do
      local yes,err = Xml.compare(t1[i],t2[i])
      if not yes then return err end
   end
   return true
end

--- is this value a document element?
-- @param d any value
function Xml.is_tag(d)
   return type(d) == 'table' and is_text(d.tag)
end

--- call the desired function recursively over the document.
-- @param doc the document
-- @param depth_first  visit child notes first, then the current node
-- @param operation a function which will receive the current tag name and current node.
function Xml.walk (doc, depth_first, operation)
   if not depth_first then operation(doc.tag,doc) end
   for _,d in ipairs(doc) do
      if Xml.is_tag(d) then
         Xml.walk(d,depth_first,operation)
      end
   end
   if depth_first then operation(doc.tag,doc) end
end

local html_empty_elements = { --lists all HTML empty (void) elements
   br      = true,
   img     = true,
   meta    = true,
   frame   = true,
   area    = true,
   hr      = true,
   base    = true,
   col     = true,
   link    = true,
   input   = true,
   option  = true,
   param   = true,
   isindex = true,
   embed = true,
}

local escapes = { quot = "\"", apos = "'", lt = "<", gt = ">", amp = "&" }
local function unescape(str) return (str:gsub( "&(%a+);", escapes)); end

--- Parse a well-formed HTML file as a string.
-- Tags are case-insenstive, DOCTYPE is ignored, and empty elements can be .. empty.
-- @param s the HTML
function Xml.parsehtml (s)
   return Xml.basic_parse(s,false,true)
end

--- Parse a simple XML document using a pure Lua parser based on Robero Ierusalimschy's original version.
-- @param s the XML document to be parsed.
-- @param all_text  if true, preserves all whitespace. Otherwise only text containing non-whitespace is included.
-- @param html if true, uses relaxed HTML rules for parsing
function Xml.basic_parse(s,all_text,html)
   local t_remove = table.remove
   local s_find,s_sub = string.find,string.sub
   local stack = {}
   local top = {}

   local function parseargs(st)
      local arg = {}
      st:gsub("([%w:%-_]+)%s*=%s*([\"'])(.-)%2", function (w, _, a)
                if html then w = w:lower() end
                arg[w] = unescape(a)
      end)
      if html then
         st:gsub("([%w:%-_]+)%s*=%s*([^\"']+)%s*", function (w, a)
                   w = w:lower()
                   arg[w] = unescape(a)
         end)
      end
      return arg
   end

   t_insert(stack, top)
   local ni,c,label,xarg, empty, _, istart
   local i = 1
   local j
   -- we're not interested in <?xml version="1.0"?>
   _,istart = s_find(s,'^%s*<%?[^%?]+%?>%s*')
   if not istart then -- or <!DOCTYPE ...>
      _,istart = s_find(s,'^%s*<!DOCTYPE.->%s*')
   end
   if istart then i = istart+1 end
   while true do
      local cdata
      ni, j, cdata = s_find(s, "<!%[CDATA%[(.-)%]%]>", i)
      if ni == i and cdata then
         local doc = XmlDoc:new()
         doc.cdata = cdata
         t_insert(top, doc)
      else
         ni,j,c,label,xarg, empty = s_find(s, "<([%/!]?)([%w:%-_]+)(.-)(%/?)>", i)
         if not ni then break end
         if c == "!" then -- comment
            -- case where there's no space inside comment
            if not (label:match '%-%-$' and xarg == '') then
               if xarg:match '%-%-$' then -- we've grabbed it all
                  j = j - 2
               end
               -- match end of comment
               _,j = s_find(s, "-->", j, true)
            end
         else
            local text = s_sub(s, i, ni-1)
            if html then
               label = label:lower()
               if html_empty_elements[label] then empty = "/" end
            end
            if all_text or not s_find(text, "^%s*$") then
               t_insert(top, unescape(text))
            end
            if empty == "/" then  -- empty element tag
               local doc = XmlDoc:new(label, parseargs(xarg))
               doc.empty = 1
               t_insert(top, doc)
            elseif c == "" then   -- start tag
               local doc = XmlDoc:new(label, parseargs(xarg))
               top = doc
               t_insert(stack, top)   -- new level
            else  -- end tag
               local toclose = t_remove(stack)  -- remove top
               top = stack[#stack]
               if #stack < 1 then
                  error("nothing to close with "..label..':'..text)
               end
               if toclose.tag ~= label then
                  error("trying to close "..toclose.tag.." with "..label.." "..text)
               end
               t_insert(top, toclose)
            end
         end
      end
      i = j+1
   end
   local text = s_sub(s, i)
   if all_text or  not s_find(text, "^%s*$") then
      t_insert(stack[#stack], unescape(text))
   end
   if #stack > 1 then
      error("unclosed "..stack[#stack].tag)
   end
   local res = stack[1]
   return is_text(res[1]) and res[2] or res[1]
end

local from_rapidxml
from_rapidxml = function(t)
   assert(t.xml, inspect(t))
   local tag = t.xml
   t.xml = nil
   local attrs = {}
   for k, v in pairs(t) do
      if type(k) == "string" then
         attrs[k] = v
      end
   end
   local doc = XmlDoc:new(tag, attrs)
   for i, v in ipairs(t) do
      if type(v) == "table" then
         doc[i] = from_rapidxml(v)
      else
         doc[i] = tostring(v)
      end
   end
   return doc
end

function Xml.from_rapidxml(t)
   return from_rapidxml(t)
end

return Xml
