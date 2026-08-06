# Loader shim for the kitty_grab kitten.
#
# grab.py does a bare `import _grab_ui` for its sibling module, but kitty 0.42
# runs custom kittens through runpy without putting the kitten's own directory
# on sys.path. That fails as ModuleNotFoundError no matter where the kitten
# lives — the documented ~/.config/kitty layout breaks the same way — so this
# is upstream drift, not a consequence of installing it via home-manager.
#
# The kitten itself stays read-only in the nix store, pinned in
# collection/nix/home.nix and linked to the path below.

import os
import sys

_KITTEN_DIR = os.path.expanduser('~/.local/share/kitty_grab')
if _KITTEN_DIR not in sys.path:
    sys.path.insert(0, _KITTEN_DIR)

from grab import handle_result, main  # noqa: E402,F401
