--luacheck: ignore
project='OpenNefia'
title='OpenNefia Lua API'
description='Public API for modding OpenNefia'
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
alias("overrides", "see")
alias("inherits", "see")

new_type("event", "Events", false, "Event Parameters")
new_type("interface", "Interfaces", true, "Parameters")
custom_tags = {
   {"ownership", "Ownership"},
   {"overrides", "Overrides"},
}
