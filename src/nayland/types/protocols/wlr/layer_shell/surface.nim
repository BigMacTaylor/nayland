## Wrapper for `zwlr_layer_surface_v1`
##
## Copyright (C) 2026 Trayambak Rai (xtrayambak@disroot.org)
import pkg/nayland/bindings/protocols/wlr_layer_shell_unstable_v1
import pkg/nayland/types/protocols/wlr/layer_shell/constants

type
  LayerSurfaceObj = object
    handle*: ptr zwlr_layer_surface_v1
    payload: LayerSurfacePayload

  LayerSurfaceConfigureCallback =
    proc(surface: LayerSurface, serial: uint32, width, height: uint32)
  LayerSurfaceClosedCallback = proc(surface: LayerSurface)

  LayerSurfacePObj = object
    configureCb: LayerSurfaceConfigureCallback
    closedCb: LayerSurfaceClosedCallback

  LayerSurfacePayload = ref LayerSurfacePObj

  LayerSurface* = ref LayerSurfaceObj

func newLayerSurface*(handle: ptr zwlr_layer_surface_v1): LayerSurface {.inline.} =
  LayerSurface(handle: handle, payload: LayerSurfacePayload())

let listener = zwlr_layer_surface_v1_listener(
  configure: proc(
      data: pointer,
      surface: ptr zwlr_layer_surface_v1,
      serial: uint32,
      width: uint32,
      height: uint32,
  ) {.cdecl.} =
    let payload = cast[LayerSurfacePayload](data)
    payload.configureCb(newLayerSurface(surface), serial, width, height),
  closed: proc(data: pointer, surface: ptr zwlr_layer_surface_v1) {.cdecl.} =
    let payload = cast[LayerSurfacePayload](data)
    payload.closedCb(newLayerSurface(surface)),
)

proc setSize*(surface: LayerSurface, width, height: uint32) =
  zwlr_layer_surface_v1_set_size(surface.handle, width, height)

proc `anchor=`*(surface: LayerSurface, anchor: set[Anchor] | Anchor) =
  var anc: uint32
  for a in anchor:
    anc = anc or cast[uint32](a)
  zwlr_layer_surface_v1_set_anchor(surface.handle, ensureMove(anc))

proc `exclusiveZone=`*(surface: LayerSurface, zone: int32) =
  zwlr_layer_surface_v1_set_exclusive_zone(surface.handle, zone)

proc setMargin*(surface: LayerSurface, top, right, bottom, left: int32) =
  zwlr_layer_surface_v1_set_margin(surface.handle, top, right, bottom, left)

proc `keyboardInteractivity=`*(surface: LayerSurface, value: KeyboardInteractivity) =
  zwlr_layer_surface_v1_set_keyboard_interactivity(surface.handle, cast[uint32](value))

proc `layer=`*(surface: LayerSurface, layer: Layer) =
  zwlr_layer_surface_v1_set_layer(surface.handle, cast[uint32](layer))

proc `exclusiveEdge=`*(surface: LayerSurface, edge: Anchor) =
  zwlr_layer_surface_v1_set_exclusive_edge(surface.handle, cast[uint32](edge))

proc ackConfigure*(surface: LayerSurface, serial: uint32) =
  zwlr_layer_surface_v1_ack_configure(surface.handle, serial)

proc destroy*(surface: LayerSurface) =
  zwlr_layer_surface_v1_destroy(surface.handle)

func `onConfigure=`*(surface: LayerSurface, cb: LayerSurfaceConfigureCallback) =
  surface.payload.configureCb = cb

func `onClosed=`*(surface: LayerSurface, cb: LayerSurfaceClosedCallback) =
  surface.payload.closedCb = cb

proc attachCallbacks*(surface: LayerSurface) =
  discard zwlr_layer_surface_v1_add_listener(
    surface.handle, listener.addr, cast[pointer](surface.payload)
  )
