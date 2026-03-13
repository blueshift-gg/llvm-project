; RUN: llc < %s -mtriple=bpf -mcpu=v2 -verify-machineinstrs | FileCheck %s
;
; Test that the JSET peephole optimisation fires for the select IR pattern.
; When both branch outcomes are compile-time constants, LLVM emits select
; instead of br. This should fold AND + JNE into JSET, eliminating the AND.
;
; Source:
; uint64_t select_jset(uint64_t x, uint64_t m) {
;   return (x & m) == 0 ? 64 : 32;
; }
;
; uint32_t select_jset_32_zero(uint32_t x, uint32_t m) {
;   return (x & m) == 0 ? 64 : 32;
; }

; Function Attrs: norecurse nounwind readnone
define i64 @select_jset(i64 %0, i64 %1) {
  %3 = and i64 %1, %0
  %4 = icmp eq i64 %3, 0
  %5 = select i1 %4, i64 64, i64 32
; CHECK-LABEL: select_jset:
; CHECK:       r0 = 32
; CHECK-NEXT:  if r{{[0-9]+}} & r{{[0-9]+}} goto [[LABEL:LBB0_[0-9]+]]
; CHECK:       r0 = 64
; CHECK-NEXT: [[LABEL]]:
; CHECK-NEXT:  exit
; CHECK-NOT:   &=
  ret i64 %5
}

; Function Attrs: norecurse nounwind readnone
define i32 @select_jset_32_zero(i32 %0, i32 %1) {
  %3 = and i32 %1, %0
  %4 = icmp eq i32 %3, 0
  %5 = select i1 %4, i32 64, i32 32
; CHECK-LABEL: select_jset_32_zero:
; CHECK:       r{{[0-9]+}} &= r{{[0-9]+}}
; CHECK-NEXT:  r{{[0-9]+}} <<= 32
; CHECK-NEXT:  r{{[0-9]+}} >>= 32
; CHECK-NEXT:  r0 = 64
; CHECK-NEXT:  if r{{[0-9]+}} == 0 goto [[LABEL32:LBB[0-9]+_[0-9]+]]
; CHECK:  r0 = 32
; CHECK-NEXT: [[LABEL32]]:
; CHECK-NEXT:  exit
; CHECK-NOT:   if r{{[0-9]+}} & r{{[0-9]+}} goto
  ret i32 %5
}
