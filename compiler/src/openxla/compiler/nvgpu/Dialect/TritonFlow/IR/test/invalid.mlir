// RUN: iree-opt %s --iree-plugin=openxla-triton --split-input-file --verify-diagnostics

// expected-error @+1 {{op expected exactly one inner builtin.module operation}}
triton.executable @foo {
}

// -----

// expected-error @+1 {{op expected exactly one inner builtin.module operation}}
triton.executable @foo {
  builtin.module {}
  builtin.module {}
}

// -----

#pipeline_layout = #hal.pipeline.layout<push_constants = 1,
  sets = [<0, bindings = [<0, storage_buffer, ReadOnly>]>]>

triton.executable @foo {
  // expected-error @+1 {{op refers to an unknown Triton function: @bar}}
  triton.executable.export @bar layout(#pipeline_layout)
  builtin.module {}
}

// -----

#pipeline_layout = #hal.pipeline.layout<push_constants = 1,
  sets = [<0, bindings = [<0, storage_buffer, ReadOnly>,
                          <1, storage_buffer>]>]>

triton.executable @foo {
  triton.executable.export @bar layout(#pipeline_layout)
  builtin.module {
    tt.func private @bar(!tt.ptr<f32>, !tt.ptr<i32>)
  }
}

func.func @main(%arg0: index, %arg1: tensor<f32>) {
  // expected-error @+1 {{op result #1 element type must match a Triton pointer type at #1 ('f32' vs 'i32')}}
  triton.dispatch @foo::@bar[%arg0](%arg1) : (tensor<f32>) -> (%arg1, tensor<f32>)
  return
}

// -----

func.func @main(%arg0: index) {
  // expected-error @+1 {{op refers to an unknown Triton entry point: @foo}}
  triton.dispatch @foo[%arg0]() : () -> ()
  return
}

// -----

func.func @main(%arg0: index) {
  // expected-error @+1 {{op refers to an unknown Triton function: @foo}}
  triton.call @foo[%arg0]() : () -> ()
  return
}

// -----

tt.func private @foo(!tt.ptr<f32>)

func.func @main(%arg0: index, %arg1: i32) {
  // expected-error @+1 {{op argument #0 must be a tensor matching Triton pointer type at #0 ('i32' vs '!tt.ptr<f32>')}}
  triton.call @foo[%arg0](%arg1) : (i32) -> ()
  return
}

// -----

tt.func private @foo(!tt.ptr<f32>)

func.func @main(%arg0: index) {
  // expected-error @+1 {{op result #0 element type must match a Triton pointer type at #0 ('i32' vs 'f32')}}
  triton.call @foo[%arg0]() : () -> tensor<i32>
  return
}

// -----

tt.func private @foo(!tt.ptr<f32>, !tt.ptr<i32>)

func.func @main(%arg0: index, %arg1: tensor<f32>) {
  // expected-error @+1 {{op result #1 element type must match a Triton pointer type at #1 ('f32' vs 'i32')}}
  triton.call @foo[%arg0](%arg1) : (tensor<f32>) -> (%arg1, tensor<f32>)
  return
}
