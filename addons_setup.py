from weblate.settings_docker import *
import os

if "CHECK_LIST" not in globals():
    CHECK_LIST = []
if "AUTOFIX_LIST" not in globals():
    AUTOFIX_LIST = []
if "WEBLATE_ADDONS" not in globals():
    WEBLATE_ADDONS = []

# Checks
CHECK_LIST += ("checks.FooCheck",)

# Autofixes
AUTOFIX_LIST += ("fixups.FooFixer",)

# Add-ons
WEBLATE_ADDONS += ("addons.ExamplePreAddon",)