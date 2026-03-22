## Wrapper for `zwlr_layer_shell_v1`
##
## Copyright (C) 2026 Trayambak Rai (xtrayambak@disroot.org)
import std/options
import pkg/nayland/bindings/protocols/wlr_layer_shell_unstable_v1
import
  pkg/nayland/types/protocols/core/[output, surface],
  pkg/nayland/types/protocols/wlr/layer_shell/[constants, surface]

type
  LayerShellObj = object
    handle*: ptr zwlr_layer_shell_v1

  LayerShell* = ref LayerShellObj

proc `=destroy`*(layerShell: LayerShellObj) =
  zwlr_layer_shell_v1_destroy(layerShell.handle)

proc getLayerSurface*(
    layerShell: LayerShell,
    surface: Surface,
    output: Option[Output] = none(Output),
    layer: Layer,
    namespace: string,
): LayerSurface =
  newLayerSurface(
    zwlr_layer_shell_v1_get_layer_surface(
      layerShell.handle,
      surface.handle,
      (if output.isSome: output.get().handle else: nil),
      cast[uint32](layer),
      cstring(namespace),
    )
  )

func initLayerShell*(handle: pointer): LayerShell {.inline.} =
  LayerShell(handle: cast[ptr zwlr_layer_shell_v1](handle))
