# Forest Simulacrum: A(n incomplete) game made in the Godot Engine

A game that you can look at for reference and hopefully learn from!

## NOTICE
This game is CANCELLED!! 

Actually it's just undergoing a hard pivot and will not be completed in its current state.  I think it's a cute little walking sim, but it screams "Babby's first game", with the lack of mechanical depth, the eclectic assets, the ad-hoc (and incomplete) story, among other things.  But this was a valuable stepping-stone for the new design of the game, which sounds like something I'd actually want to play!

## Requirements

You will have to use the Godot 3.1 Alpha because I am using features from it, like the static typing.

## Epic-with-the-B-emoji game features

- OST with Four original songs!

- Controller support: this was harder than it sounds because Godot doesn't out-of-the-box support navigating UIs with the analog sticks (read `scripts/input.gd` if you want to see my implementation of this. You'll probably want to modify it to disable when not in a UI because currently it spams input events when walking around)

- Options Menu: Full button remapping and everything! No volume controls and I will not add them!

## Addons

I made the addons, but I tried to keep them separate so I could use them in other projects.

- Gradient Shader: a shader for making gradients! I don't think it'll be very useful for most games, since it's two shaders and accompanying tools that are very specific to the look and feel of this game.

- Peroxinator: A dialog system that I made for an unreleased game called _Peroxia_. The editor was originally in java and I lost the source code (plus it was bad) so I made a new editor in Godot. So it has literally nothing to do with Peroxia other than a common format.  Also I couldn't figure out custom resources so I hope that doesn't break the game!
