# Visual AI

Visual AI is an enhancement to Elona's default AI which allows you to configure your allies' AI in a visual manner, on a 2D grid.

Its design draws heavily on Disgaea 6's "Mashin Edit" system and visual programming languages like Scratch and Pure Data.

## Usage

Install the mod, then use the interact command (<kbd>i</kbd>) to select an ally. Choose "Edit Visual AI" to open the editor.

To enable the AI for this ally, open the config menu (<kbd>x</kbd>) and toggle the "Enable" option.

## Tutorial

To keep things simple, all the things you can do with Visual AI are made up of 4 fundamental building blocks:

- Conditionals.
- Target selection.
- Acting on the target.
- Compound statements of the above 3.

Let's start off by writing a simple AI to follow the player. This AI won't attempt to do anything else but target the player and follow them.

Select the upper left tile in the editor. This will open a new window where you can choose an AI block to add. Use left and right to navigate the category to "Target" and select "The player".

![]()

This block sets a filter on the character or other thing being targeted. You can chain more than one of them together, like "Enemy" and "Nearest" to mean "the closest enemy to myself." This filter will remain in place until you use the "Target reset" block (see below).

You can see that the tile to the right of the block we just inserted is now highlighted, indicating you can insert another block there. Select it and choose the "move closer to" action, under the "Actions" category.

![]()

You can't add any more blocks after actions like these, since moving ends this character's turn.

This is a pretty basic setup. Now what we need to do is *save* our AI (<kbd>F2</kbd>) and exit the menu. Make sure that "Visual AI: Enabled" is shown to the left of the menu, or it won't get run.

![]()

Now let's add some logic to attack enemies. What we're about to add will make our AI feature-compatible with vanilla Elona's.

When the AI runs, it will automatically save its last target. You can access this target with the "Previous target" block in the Target category.

What we will first do is check to see if our ally is already targeting an enemy. If not, we will try to target the nearest enemy in range. If we can't find one, we'll go back to following the player. Visual AI comes with predicates for all of these cases built-in.

First, press <kbd>Backspace</kbd> to clear the current config. Open the blocks list, change to the "Target" category and add "Previous target." Then add the block "Target is in sight" in the "Condition" category.

![]()

Conditional primitives in Visual AI have a "true" and "false" case. If the condition is true, the path to the right is taken. If not, the path below is taken. First let's handle the failing case. If we do not have a valid target in sight, we want to set our target filter to whatever enemy is nearest to us. Select the tile below our conditional and add the "Enemy" and "Nearest" blocks from the Target category.

At this point we want to continue with our logic as before, since a target has been searched for. To assist with this, Visual AI comes with a "Jump" special operator. What it means is you can jump to a valid tile after you've finished running one branch of your AI's logic. Add this block after the two target filters (it's under the "Special" category). It will prompt you for the position to jump to. Select the open tile to the right of the conditional we added earlier.

![]()

As you can see, there is a line extending from the Jump block pointing to where the AI will run next.

Now we want to check again if there's a target in sight. It could be the case that there aren't any enemies we can see, so there would be nobody to attack. Add another "Target is in sight" conditional afterwards.

![]()

To the right of this condition, let's add an action to move closer to the enemy or attack. Normally we'd want to do something like first check if the enemy is in range for a melee or ranged attack, move closer if not, and attack if so. This can be a bit annoying to write out completely, though, since this is bound to be a common final action. Instead what we can do is use a feature of Visual AI called "compound blocks." These are blocks that themselves contain blocks, and can potentially perform actions, set targets, or have conditional branches all in one. Visual AI comes with a few of them premade by default. Add a new block to the right of the conditional, choose the "Compound" category, and select "Move or attack somehow."

![]()

Notice that this block has a blue indicator. That means this is a metablock that "acts like" an action block. You can have metablocks that "act like" target or conditional blocks too, which would be reflected in the color of the indicator, like so:

![]()

This block will try to move the character closer if it's not in range, which would end its turn. However, if it's already close enough to its target, it will instead branch out to the right and you can keep adding your own logic to it.

The block we just added emulates the full behavior of Elona's default AI. It will try to see if it has any default AI actions it can take (leveraging the original `ai_actions` prototype) and attack if so, otherwise move towards the target. You can take a peek at what goes on inside this block by selecting it and pressing <kbd>Enter</kbd>. To exit out of this subview, hit the cancel key.

![]()

With that done, we can select the other conditional branch and add the logic we had before: Set the target to the player and follow them. *However*, one thing we will need to do is add a "Reset target filter" block first, so that we can change the target character to filter by. Otherwise the AI will try to look for a character like "is this both an enemy and the player," which doesn't make sense.

![]()

Save this AI and try it out, and hopefully nothing weird should happen. That means you've successfully recreated Elona's default AI in Visual AI.

## API

Import `mod.api.VisualAI`.

### VisualAI.run(IChara, VisualAIPlan)

This function lets you run Visual AI standalone. It won't account for things like status effects (those are handled by OpenNefia's default AI). Provide the acting character and the finished plan to run.

```lua

```

## Bugs

Keep looking, you'll find them eventually.

## Credits

Icon art from [https://opengameart.org/content/game-icons-expansion](https://opengameart.org/content/game-icons-expansion).

## License

MIT.
