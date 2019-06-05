# Base mods
Many mods are just feature extensions on top of `base` that have nothing to do with `elona`. These "base mods" should be very focused in functionality. In particular:

- Base mods should not have dependency trees more than 3 layers deep, and preferably only one layer deep.
- Base mods should not provide localization.
  + If it is absolutely necessary the localization should reside in `elona` instead as an outer-mod localization.
