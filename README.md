# Godot Loot Tables
(WIP) Generic Loot Tables for Godot 4

TODO: good readme

### General Idea
- `PoolEntry` is a base Resource type with a weight and a `roll()` function that provides an array of whatever `Resource` type you want
  - You can implement your own subclasses or use various implementations like `ChanceEntry`, `LootTableEntry`, `SingleEntry`, `SingleSceneEntry`
- `Pool` is a custom Resource type that has a roll count and an array of `PoolEntry`
  - `Pool` has a `roll()` function that randomly picks one of its entries weighted by their weight
- `LootTable` is a custom Resource type that has an array of `Pool`s
  - `LootTable` has a `roll()` function that combines the result of `roll()`ing each of the `Pool`s

### Usage
- Payload type(s) can be any `Resource` type you want (scenes, materials, textures, custom Resources, etc)
- Can edit either in normal inspector, or using WIP custom graph editor:

![image](https://github.com/PieKing1215/godot-loot-tables/assets/13819558/2d38bd0e-3973-4e4b-aa86-6ab24de13e99)

