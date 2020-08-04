--- This is a monotonically increasing integer that will be incremented by 1 on
--- every commit that changes a file under "api/". This should be enforced with
--- a pre-commit hook of some kind.
---
--- For this to work, strict loading order has to be in place (`elona_sys` and
--- `elona` mods merged into base, can only use dependent mods that area already
--- loaded). Some refactoring is necessary to accomplish this (#30). Until then
--- the public API will have to be considered unstable and subject to change at
--- any time.
return 0
