# ffhp

Implements FFHP's customization features that need dynamic chip replacement.

Basic theming needs can be satisfied by overriding the properties of data types like `base.chip`. However, there are cases like random items where the themed asset needs to be substituted in-game, since the type of those items is only known to the player when the item is fully identified. This mod implements features like those by replacing the chip after events like item identification, and should (hopefully) make it easy to implement this behavior for new objects that can have multiple themable assets.
