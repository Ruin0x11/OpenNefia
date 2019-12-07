--luacheck: ignore
project='elona-next'
title='elona-next Lua API'
description='Public API for modding elona-next'
format='discount'
backtick_references=false
merge=false
not_luadoc=true
file={
   "../src/api"
}
dir='out'
readme='main.md'
style='!pale'
kind_names={topic='Manual',module="APIs"}
alias("interface", "module")
alias("overrides", "see")
alias("inherits", "see")

new_type("event", "Events", false, "Event Parameters")
custom_tags = {
   {"ownership", "Ownership"},
   {"interface", "Interface"},
   {"overrides", "Overrides"},
}
