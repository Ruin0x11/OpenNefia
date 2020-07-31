local t_insert      =  table.insert;
local t_concat      =  table.concat;
local t_remove      =  table.remove;
local s_match       =  string.match;
local tostring      =      tostring;
local pairs         =         pairs;
local ipairs        =        ipairs;
local type          =          type;
local next          =          next;
local s_find        =   string.find;

local XmlDoc = class.class("XmlDoc")

local function is_text(s) return type(s) == 'string' end

--- create a new document node.
-- @param tag the tag name
-- @param attr optional attributes (table of name-value pairs)
function XmlDoc:init(tag, attr)
   self.tag = tag
   self.attr = attr or {}
   self.last_add = {}
   self.empty = nil
end

---- convenient function to add a document node, This updates the last inserted position.
-- @param tag a tag name
-- @param attrs optional set of attributes (name-string pairs)
function XmlDoc:addtag(tag, attrs)
   local s = XmlDoc:new(tag, attrs);
   (self.last_add[#self.last_add] or self):add_direct_child(s);
   t_insert(self.last_add, s);
   return self;
end

--- convenient function to add a text node.  This updates the last inserted position.
-- @param text a string
function XmlDoc:text(text)
   (self.last_add[#self.last_add] or self):add_direct_child(text);
   return self;
end

---- go up one level in a document
function XmlDoc:up()
   t_remove(self.last_add);
   return self;
end

function XmlDoc:reset()
   local last_add = self.last_add;
   for i = 1,#last_add do
      last_add[i] = nil;
   end
   return self;
end

--- append a child to a document directly.
-- @param child a child node (either text or a document)
function XmlDoc:add_direct_child(child)
   t_insert(self, child);
end

--- append a child to a document at the last element added
-- @param child a child node (either text or a document)
function XmlDoc:add_child(child)
   (self.last_add[#self.last_add] or self):add_direct_child(child);
   return self;
end

--accessing attributes: useful not to have to expose implementation (attr)
--but also can allow attr to be nil in any future optimizations

--- set attributes of a document node.
-- @param t a table containing attribute/value pairs
function XmlDoc:set_attribs (t)
   for k,v in pairs(t) do
      self.attr[k] = v
   end
end

--- set a single attribute of a document node.
-- @param a attribute
-- @param v its value
function XmlDoc:set_attrib(a,v)
   self.attr[a] = v
end

--- access the attributes of a document node.
function XmlDoc:get_attribs()
   return self.attr
end

local function is_data(data)
   return #data == 0 or type(data[1]) ~= 'table'
end

local function prepare_data(data)
   -- a hack for ensuring that $1 maps to first element of data, etc.
   -- Either this or could change the gsub call just below.
   for i,v in ipairs(data) do
      data[tostring(i)] = v
   end
end

local templ_cache = {}

local function template_cache (templ)
   local Xml = require("mod.extlibs.api.Xml")
   if is_text(templ) then
      if templ_cache[templ] then
         templ = templ_cache[templ]
      else
         local str,err = templ
         templ,err = Xml.parse(str,false,true)
         if not templ then return nil,err end
         templ_cache[str] = templ
      end
   elseif not Xml.is_tag(templ) then
      return nil, "template is not a document"
   end
   return templ
end

--- create a substituted copy of a document,
-- @param templ  may be a document or a string representation which will be parsed and cached
-- @param data  a table of name-value pairs or a list of such tables
-- @return an XML document
function XmlDoc.subst(templ, data)
   local Xml = require("mod.extlibs.api.Xml")
   local err
   if type(data) ~= 'table' or not next(data) then return nil, "data must be a non-empty table" end
   if is_data(data) then
      prepare_data(data)
   end
   templ,err = template_cache(templ)
   if err then return nil, err end
   local function _subst(item)
      return Xml.clone(templ,function(s)
                          return s:gsub('%$(%w+)',item)
      end)
   end
   if is_data(data) then return _subst(data) end
   local list = {}
   for _,item in ipairs(data) do
      prepare_data(item)
      t_insert(list,_subst(item))
   end
   if data.tag then
      list = Xml.elem(data.tag,list)
   end
   return list
end

--- get the first child with a given tag name.
-- @param tag the tag name
function XmlDoc:child_with_name(tag)
   for _, child in ipairs(self) do
      if child.tag == tag then return child; end
   end
end

local _children_with_name
function _children_with_name(self,tag,list,recurse)
   for _, child in ipairs(self) do if type(child) == 'table' then
         if child.tag == tag then t_insert(list,child) end
         if recurse then _children_with_name(child,tag,list,recurse) end
   end end
end

--- get all elements in a document that have a given tag.
-- @param tag a tag name
-- @param dont_recurse optionally only return the immediate children with this tag name
-- @return a list of elements
function XmlDoc:get_elements_with_name(tag,dont_recurse)
   local res = {}
   _children_with_name(self,tag,res,not dont_recurse)
   return res
end

XmlDoc.find = XmlDoc.get_elements_with_name

function XmlDoc:find_first(tag)
   return self:get_elements_with_name(tag)[1]
end

-- iterate over all children of a document node, including text nodes.
function XmlDoc:children()
   local i = 0;
   return function (a)
      i = i + 1
      return a[i];
   end, self, i;
end

-- return the first child element of a node, if it exists.
function XmlDoc:first_childtag()
   if #self == 0 then return end
   for _,t in ipairs(self) do
      if type(t) == 'table' then return t end
   end
end

function XmlDoc:matching_tags(tag, xmlns)
   xmlns = xmlns or self.attr.xmlns;
   local tags = self;
   local start_i, max_i, v = 1, #tags;
   return function ()
      for i=start_i,max_i do
         v = tags[i];
         if (not tag or v.tag == tag)
         and (not xmlns or xmlns == v.attr.xmlns) then
            start_i = i+1;
            return v;
         end
      end
   end, tags, start_i;
end

--- iterate over all child elements of a document node.
function XmlDoc:childtags()
   local i = 0;
   return function (a)
      local v
      repeat
         i = i + 1
         v = self[i]
         if v and type(v) == 'table' then return v; end
      until not v
   end, self[1], i;
end

--- visit child element  of a node and call a function, possibility modifying the document.
-- @param callback  a function passed the node (text or element). If it returns nil, that node will be removed.
-- If it returns a value, that will replace the current node.
function XmlDoc:maptags(callback)
   local Xml = require("mod.extlibs.api.Xml")
   local is_tag = Xml.is_tag
   local i = 1;
   while i <= #self do
      if is_tag(self[i]) then
         local ret = callback(self[i]);
         if ret == nil then
            t_remove(self, i);
         else
            self[i] = ret;
            i = i + 1;
         end
      end
   end
   return self;
end

-- pretty printing
-- if indent, then put each new tag on its own line
-- if attr_indent, put each new attribute on its own line
local function _dostring(t, buf, self, xml_escape, parentns, idn, indent, attr_indent)
   local nsid = 0;
   local tag = t.tag
   local lf,alf = ""," "
   if indent then lf = '\n'..idn end
   if attr_indent then alf = '\n'..idn..attr_indent end
   t_insert(buf, lf.."<"..tag);
   local function write_attr(k,v)
      if s_find(k, "\1", 1, true) then
         local ns, attrk = s_match(k, "^([^\1]*)\1?(.*)$");
         nsid = nsid + 1;
         t_insert(buf, " xmlns:ns"..nsid.."='"..xml_escape(ns).."' ".."ns"..nsid..":"..attrk.."='"..xml_escape(v).."'");
      elseif not(k == "xmlns" and v == parentns) then
         t_insert(buf, alf..k.."='"..xml_escape(v).."'");
      end
   end
   -- it's useful for testing to have predictable attribute ordering, if available
   if #t.attr > 0 then
      for _,k in ipairs(t.attr) do
         write_attr(k,t.attr[k])
      end
   else
      for k, v in pairs(t.attr) do
         write_attr(k,v)
      end
   end
   local len,has_children = #t;
   if len == 0 then
      local out = "/>"
      if attr_indent then out = '\n'..idn..out end
      t_insert(buf, out);
   else
      t_insert(buf, ">");
      for n=1,len do
         local child = t[n];
         if child.tag then
            self(child, buf, self, xml_escape, t.attr.xmlns,idn and idn..indent, indent, attr_indent );
            has_children = true
         else -- text element
            t_insert(buf, xml_escape(child));
         end
      end
      t_insert(buf, (has_children and lf or '').."</"..tag..">");
   end
end

---- pretty-print an XML document
--- @param self an XML document
--- @param idn an initial indent (indents are all strings)
--- @param indent an indent for each level
--- @param attr_indent if given, indent each attribute pair and put on a separate line
--- @param xml force prefacing with default or custom <?xml...>
--- @return a string representation
function XmlDoc:__tostring(idn,indent, attr_indent, xml)
   local buf = {};
   if xml then
      if type(xml) == "string" then
         buf[1] = xml
      else
         buf[1] = "<?xml version='1.0'?>"
      end
   end
   local Xml = require("mod.extlibs.api.Xml")
   _dostring(self, buf, _dostring, Xml.xml_escape, nil,idn,indent, attr_indent);
   return t_concat(buf);
end

--- get the full text value of an element
function XmlDoc:get_text()
   local res = {}
   for _,el in ipairs(self) do
      if is_text(el) then t_insert(res,el) end
   end
   return t_concat(res);
end

--- make a copy of a document
-- @param self the original document
-- @param strsubst an optional function for handling string copying which could do substitution, etc.
function XmlDoc:filter(strsubst)
   local lookup_table = {};
   local function _copy(object,kind,parent)
      if type(object) ~= "table" then
         if strsubst and is_text(object) then return strsubst(object,kind,parent)
         else return object
         end
      elseif lookup_table[object] then
         return lookup_table[object]
      end
      local new_table = XmlDoc:new()
      lookup_table[object] = new_table
      local tag = object.tag
      new_table.tag = _copy(tag,'*TAG',parent)
      if object.attr then
         local res = {}
         for attr,value in pairs(object.attr) do
            res[attr] = _copy(value,attr,object)
         end
         new_table.attr = res
      end
      for index = 1,#object do
         local v = _copy(object[index],'*TEXT',object)
         t_insert(new_table,v)
      end
      return new_table
   end

   return _copy(self)
end

local function empty(attr) return not attr or not next(attr) end
local function is_element(d) return type(d) == 'table' and d.tag ~= nil end

-- returns the key,value pair from a table if it has exactly one entry
local function has_one_element(t)
   local key,value = next(t)
   if next(t,key) ~= nil then return false end
   return key,value
end

local function append_capture(res,tbl)
   if not empty(tbl) then -- no point in capturing empty tables...
      local key
      if tbl._ then  -- if $_ was set then it is meant as the top-level key for the captured table
         key = tbl._
         tbl._ = nil
         if empty(tbl) then return end
      end
      -- a table with only one pair {[0]=value} shall be reduced to that value
      local numkey,val = has_one_element(tbl)
      if numkey == 0 then tbl = val end
      if key then
         res[key] = tbl
      else -- otherwise, we append the captured table
         t_insert(res,tbl)
      end
   end
end

local function make_number(pat)
   if pat:find '^%d+$' then -- $1 etc means use this as an array location
      pat = tonumber(pat)
   end
   return pat
end

local function capture_attrib(res,pat,value)
   pat = make_number(pat:sub(2))
   res[pat] = value
   return true
end

local match
function match(d,pat,res,keep_going)
   local Xml = require("mod.extlibs.api.Xml")
   local ret = true
   if d == nil then d = '' end --return false end
   -- attribute string matching is straight equality, except if the pattern is a $ capture,
   -- which always succeeds.
   if is_text(d) then
      if not is_text(pat) then return false end
      if Xml.debug then print(d,pat) end
      if pat:find '^%$' then
         return capture_attrib(res,pat,d)
      else
         return d == pat
      end
   else
      if Xml.debug then print(d.tag,pat.tag) end
      -- this is an element node. For a match to succeed, the attributes must
      -- match as well.
      -- a tagname in the pattern ending with '-' is a wildcard and matches like an attribute
      local tagpat = pat.tag:match '^(.-)%-$'
      if tagpat then
         tagpat = make_number(tagpat)
         res[tagpat] = d.tag
      end
      if d.tag == pat.tag or tagpat then

         if not empty(pat.attr) then
            if empty(d.attr) then ret =  false
            else
               for prop,pval in pairs(pat.attr) do
                  local dval = d.attr[prop]
                  if not match(dval,pval,res) then ret = false;  break end
               end
            end
         end
         -- the pattern may have child nodes. We match partially, so that {P1,P2} shall match {X,P1,X,X,P2,..}
         if ret and #pat > 0 then
            local i,j = 1,1
            local function next_elem()
               j = j + 1  -- next child element of data
               if is_text(d[j]) then j = j + 1 end
               return j <= #d
            end
            repeat
               local p = pat[i]
               -- repeated {{<...>}} patterns  shall match one or more elements
               -- so e.g. {P+} will match {X,X,P,P,X,P,X,X,X}
               if is_element(p) and p.repeated then
                  local found
                  repeat
                     local tbl = {}
                     ret = match(d[j],p,tbl,false)
                     if ret then
                        found = false --true
                        append_capture(res,tbl)
                     end
                  until not next_elem() or (found and not ret)
                  i = i + 1
               else
                  ret = match(d[j],p,res,false)
                  if ret then i = i + 1 end
               end
            until not next_elem() or i > #pat -- run out of elements or patterns to match
            -- if every element in our pattern matched ok, then it's been a successful match
            if i > #pat then return true end
         end
         if ret then return true end
      else
         ret = false
      end
      -- keep going anyway - look at the children!
      if keep_going then
         for child in d:childtags() do
            ret = match(child,pat,res,keep_going)
            if ret then break end
         end
      end
   end
   return ret
end

function XmlDoc:match(pat)
   local Xml = require("mod.extlibs.api.Xml")
   local err
   pat,err = template_cache(pat)
   if not pat then return nil, err end
   Xml.walk(pat,false,function(_,d)
               if is_text(d[1]) and is_element(d[2]) and is_text(d[3]) and
               d[1]:find '%s*{{' and d[3]:find '}}%s*' then
                  t_remove(d,1)
                  t_remove(d,2)
                  d[1].repeated = true
               end
   end)

   local res = {}
   local ret = match(self,pat,res,true)
   return res,ret
end

return XmlDoc
