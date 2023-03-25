# Pythagoras and Marionette printer kinematics

Very early version, work in progress; no instructions or BOM yet. I'll write something up in the coming weeks when the design becomes more stable. 
## Pythagoras:

https://youtu.be/kwCWqJ1EkXo

## Marionette:

https://youtu.be/3ctT8vhLEVk

https://youtu.be/3ctT8vhLEVk

I recommend Marionette over Pythagoras. I will likely rebuild Pythagoras with linkage-driven counter tensioner actuation, to reduce space requirements behind the mechanism. 

While I hadn't yet gotten Marionette to print, it has been a lot easier to build and design once the initial obstacle of coming up with the kinematic was overcome.

## Cable based straight mechanism Z drive:

https://youtu.be/4MuK-TnRx-g

The source files for this are in mechanics/build123d_test . You need to unstall the right version of build123d (inside your python venv) via
```
cd submodules/build123d
python3 -m pip install .
```

## Simplified unklicky

https://youtu.be/UsTR6VBf8fE

You can download generated files from https://www.thingiverse.com/thing:5921800 . You may need to change dimensions to fit your hotend & printer.

BOM: 4x 5mm diameter 1mm thick neodymium magnet. 1x m2 x 20mm screw. A small piece of copper tape. A couple wires. 

2x m4 x8mm bolts and 2x rail nuts for installing the dock onto 2020 extrusions (exact dock installation may vary depending on the printer).

Assembly: install the wires into the base, superglue the magnets over the wires (I recommend placing a piece of polyethylene over a steel ruler and sticking magnets on it first then putting glue on the magnets then placing the probe body from above).

Probe: superglue the magnets  in, observing the polarity (so that they stick to the probe base). Place copper tape over the magnets, rub on the copper tape with cotton to clean and flatten it. Do not touch the copper tape, fingerprints increase oxidation. Screw in the screw. Test the probe with a multimeter (make sure that the wires made a connection to the magnets).

Dock: uses m4 screws and m4 rail nuts to install to the rail. You will likely need to re-design the dock for your printer.

Usage: make sure to keep any magnetic debris away from the probe and probe base.