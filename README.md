# Class visualizer for lua/torch
Class hierarchy visualizer for torch classes, and classic classes (see github.com/deepmind/classic)

Currently generates a d3 visualization, easily adapted to graphviz.

## Example of viewing the classes in `nn`
```
th generate.lua htmld3tree nn > output.html
```
Then open `output.html` in your browser.

## Usage:
```sh
th [-lclassic] generate.lua output_mode package1 [package2 [package3 ...] ]
```
where `output_mode` is `htmld3force` or `htmld3tree`. See e.g. `htmld3tree.lua`; more can be added.

 * Output is to stdout; redirect it to a file like `output.html`.
 * Use `-lclassic` to monitor classic classes instead. (see <https://github.com/deepmind/classic>)

## Useful extensions/TODOs:

 * Output to graphviz
 * Parse libraries for documentation and include it in the visualization?
 * At the least, actually do something useful when clicking on the classes.

### Internals
For `torch.class` classes, it simply monkeypatches this function to monitor created classes when
the packages get `require`d. For classic classes, it uses a central (private) registry storing 
the classes and their parents.
