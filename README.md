[![Build FG-Usable File](https://github.com/bmos/FG-CoreRPG-Extraplanar-Containers/actions/workflows/create-ext.yml/badge.svg)](https://github.com/bmos/FG-CoreRPG-Extraplanar-Containers/actions/workflows/create-ext.yml) [![Luacheck](https://github.com/bmos/FG-CoreRPG-Extraplanar-Containers/actions/workflows/luacheck.yml/badge.svg)](https://github.com/bmos/FG-CoreRPG-Extraplanar-Containers/actions/workflows/luacheck.yml)

# Extraplanar Containers
This extension provides support for extraplanar containers by ignoring the weight of carried (but not equipped) items in supported containers.
It also makes working with large inventories easier by allowing supported containers to be collapsed/expanded via double-click.

# Compatibility and Instructions
This extension has been tested with [FantasyGrounds Unity](https://www.fantasygrounds.com/home/FantasyGroundsUnity.php) v4.4.9 (2023-12-18).

This works with CoreRPG, 2E, 3.5E, 5E, PFRPG, and possibly more, although the item names it looks for are based on Pathfinder 1e.

If you have two containers with the same name (such as two backpacks) you may encounter unintended behavior. To work around this, I would suggest giving each a unique descriptive or functional name like "green backpack" or "backpack of food".

# Features
This extension provides support for extraplanar containers by ignoring the weight of carried (but not equipped) items in supported containers ('weightless', 'extraplanar', 'of holding', 'portable hole', 'handy haversack', 'efficient quiver', 'quiver of ehlonna', 'horse', 'donkey', and 'mule').
It also provides subtotals in the item sheets of those containers, warns when the container is overfull, and checks that contents are small enough to fit inside the container.

Supported mundane containers ('container', 'backpack', 'satchel', 'quiver', 'chest', 'purse', 'pouch', 'sack', 'bag', and 'box') will benefit from the subtotal and maximum size and capacity features, but not the weightless contents. To define additional item names that should be detected as mundane or extraplanar containers, edit the ext file attached to [this post](https://www.fantasygrounds.com/forums/showthread.php?67126-PFRPG-Extraplanar-Containers&p=587557&viewfull=1#post587557). Ask for help if you need it.

There is also an option "Encumbrance: Container/Item Volume" that allows you to assign exterior dimensions to items and interior dimensions to containers. This can be used to detect edge cases like putting an enormous, but very light, object into a small container.

Supported containers can have their contents hidden by double-clicking on the name of the container. They will remain collapsed until they are expanded again, either by double-clicking or by editing their name to remove the "[+] ".

# Video Demonstration (click for video)
[<img src="https://i.ytimg.com/vi_webp/6TBMCcs8QuY/hqdefault.webp">](https://www.youtube.com/watch?v=6TBMCcs8QuY)
