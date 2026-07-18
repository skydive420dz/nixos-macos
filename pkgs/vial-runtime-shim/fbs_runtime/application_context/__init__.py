"""Small compatibility layer for the fbs APIs imported by Vial."""

from functools import cached_property


def is_frozen():
    return False
