## Constants/enums for `wlr-layer-shell-unstable-v1`
##
## Copyright (C) 2026 Trayambak Rai (xtrayambak@disroot.org)
import pkg/nayland/bindings/protocols/wlr_layer_shell_unstable_v1

type
  Layer* {.pure, size: sizeof(int32).} = enum
    Background = ZWLR_LAYER_SHELL_V1_LAYER_BACKGROUND
    Bottom = ZWLR_LAYER_SHELL_V1_LAYER_BOTTOM
    Top = ZWLR_LAYER_SHELL_V1_LAYER_TOP
    Overlay = ZWLR_LAYER_SHELL_V1_LAYER_OVERLAY

  Anchor* {.pure, size: sizeof(int32).} = enum
    Top = ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP
    Bottom = ZWLR_LAYER_SURFACE_V1_ANCHOR_BOTTOM
    Left = ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT
    Right = ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT

  KeyboardInteractivity* {.pure, size: sizeof(int32).} = enum
    None = ZWLR_LAYER_SURFACE_V1_KEYBOARD_INTERACTIVITY_NONE
    Exclusive = ZWLR_LAYER_SURFACE_V1_KEYBOARD_INTERACTIVITY_EXCLUSIVE
    OnDemand = ZWLR_LAYER_SURFACE_V1_KEYBOARD_INTERACTIVITY_ON_DEMAND
