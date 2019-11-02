# Lunchpaid
Implements some of the Grid API for versions of the Novation Launchpad that
only have buttons and red and green LEDs. To be more Grid-like, the top row
of the Launchpad is treated as a 10th column (i.e., X = 10).

# Colors
16 possible colors 0-15. 4 red and green levels:

* More significant 2 bits (`8` and `4`) are green.
* Less significant 2 bits (`2` and `1`) are red.

# API

## Instance

### `lp:led(x, y, color)`
Set LED at (x, y) to color (see color bits above).

### `lp:all(color)`
Set all LEDs to color.

### `lp:refresh()`
Empty - only here to match Grid API.

## Static

### `lp.connect(id)`
Sets up MIDI connection (add/remove) overrides if not set up already, and
returns the API. `id` argument is currently ignored.

### `lp.key(id, x, y, velocity)`
Key handler. Bring your own implementation, just like Grid.

### `lp.update_devices()`
Update MIDI devices and find a device that matches known names of supported
Launchpad devices. Return `true` if device found, `false` otherwise. Called
by `lp.connect`, probably don't need to call manually.

### `lp.cleanup()`
Clear key handler.


# Not supported
* Multiple devices 
* RGB, Control, Keys, etc. (OG/Mini Red/Green only)
