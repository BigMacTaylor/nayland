import std/[options, posix]
import
  pkg/nayland/types/display,
  pkg/nayland/types/protocols/core/prelude,
  pkg/nayland/bindings/protocols/[core, wlr_layer_shell_unstable_v1],
  pkg/nayland/types/protocols/wlr/layer_shell/prelude

const
  width = 320
  height = 240
  stride = width * 4
  poolSize = stride * height

var MFD_CLOEXEC {.importc, header: "<sys/mman.h>".}: uint32
proc memfd_create(
  name: cstring, flags: uint32
): int32 {.importc, header: "<sys/mman.h>".}

let disp = connectDisplay()
let reg = initRegistry(disp)
discard disp.roundtrip()

assert(
  "zwlr_layer_shell_v1" in reg,
  "The host compositor does not support wlr-layer-shell-v1 (or doesn't advertise it properly)",
)

let compIface = reg["wl_compositor"]
let comp = initCompositor(
  reg.bindInterface(compIface.name, wl_compositor_interface.addr, compIface.version)
)

let shmIface = reg["wl_shm"]
let shmObj =
  initShm(reg.bindInterface(shmIface.name, wl_shm_interface.addr, shmIface.version))

let
  layerShellIface = reg["zwlr_layer_shell_v1"]
  layerShell = initLayerShell(
    reg.bindInterface(
      layerShellIface.name, zwlr_layer_shell_v1_interface.addr, layerShellIface.version
    )
  )

var running = true
var configured = false
var committed = false
let surf = comp.createSurface()
let layerSurf =
  layerShell.getLayerSurface(surf, layer = Layer.Top, namespace = "nayland-layer-shell")

layerSurf.onConfigure = proc(ls: LayerSurface, serial, width, height: uint32) =
  ls.ackConfigure(serial)
  debugEcho "LayerSurface::configure ~> " & $width & " x " & $height
  configured = true

layerSurf.onClosed = proc(ls: LayerSurface) =
  running = false

layerSurf.attachCallbacks()

layerSurf.anchor = {Anchor.Bottom, Anchor.Right}

let fd = memfd_create("nayland-example-shm", MFD_CLOEXEC)
if fd < 0:
  quit "memfd_create failed"

discard ftruncate(fd, Off(poolSize))

let map = mmap(nil, poolSize, PROT_READ or PROT_WRITE, MAP_SHARED, fd, 0)
if map == cast[pointer](-1):
  quit "mmap failed"

let pixels = cast[ptr UncheckedArray[uint32]](map)
let pixelCount = width * height
let color = 0xff243447'u32
for i in 0 ..< pixelCount:
  pixels[i] = color

let pool = get shmObj.createPool(fd, int32(poolSize))
let buffer = get pool.createBuffer(
  0, int32(width), int32(height), int32(stride), ShmFormat.ARGB8888
)

surf.commit()

while running:
  disp.dispatch()
  if configured and not committed:
    debugecho "draw"
    committed = true
    surf.attach(buffer, 0, 0)
    surf.damage(0, 0, int32(width), int32(height))
    surf.commit()

layerSurf.destroy()
