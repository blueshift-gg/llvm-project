// RUN: %clang -target bpfel -O2 -S -o - %s | FileCheck --check-prefix=CHECK-ON %s
// RUN: %clang -target bpfel -O2 -mllvm -bpf-enable-jset=false -S -o - %s | FileCheck --check-prefix=CHECK-OFF %s

volatile unsigned long g1;
volatile unsigned long g2;

void c64_rr(unsigned long x, unsigned long m) {
  if ((x & m) == 0)
    g1 = x;
  else
    g2 = m;
}

// CHECK-OFF-LABEL: c64_rr:
// CHECK-OFF:       r{{[0-9]+}} &= r{{[0-9]+}}
// CHECK-OFF:       if r{{[0-9]+}} != 0 goto [[ELSE:LBB[0-9_]+]]
// CHECK-ON-LABEL:  c64_rr:
// CHECK-ON:        if r{{[0-9]+}} & r{{[0-9]+}} goto [[ELSE:LBB[0-9_]+]]
// CHECK-ON-NOT:    &=
