// RUN: iree-opt %s --iree-plugin=openxla-triton --emit-bytecode \
// RUN:   | od -v -t x1 -A n | tr -d ' \n' | FileCheck %s

// CHECK: 4d4cef520
tt.func @triton(%arg0: i32 {tt.foo}, %arg1: !tt.ptr<f32>, %arg2: !tt.ptr<f32>) {
  tt.return
}
