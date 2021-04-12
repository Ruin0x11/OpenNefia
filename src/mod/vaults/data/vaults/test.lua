local vault = {}

vault.map = [[
xxxxxxxxx@.xxxxxx
xvvvvvvvx..xbbbbx
xv.....vx..xb..bx
xv..{..+...xb..bx
xv.....vx..xb..bx
xvvvvvvvx...+..bx
xxxxxxxxx..xb..bx
@..........xb..bx
.........T.xb..bx
xxxxxxxx...xbbbbx
xxxxxxxx.@.xxxxxx]]

function vault.main(builder)
   builder:tags("arrival")
   builder:tags("no_monster_gen")
   builder:orient("float")
   builder:shuffle("cvb")
end

return vault
