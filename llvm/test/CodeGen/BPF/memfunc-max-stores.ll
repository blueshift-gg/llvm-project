; RUN: llc -mtriple=bpfel < %s | FileCheck %s --check-prefix=DEFAULT
; RUN: not llc -mtriple=bpfel -bpf-max-stores-per-memfunc=3 < %s 2>&1 >/dev/null | FileCheck %s --check-prefix=ERR
; RUN: llc -mtriple=bpfel -verify-machineinstrs -bpf-expand-memcpy-in-order -bpf-max-stores-per-memfunc=4 < %s | FileCheck %s --check-prefix=INORDER
; RUN: not llc -mtriple=bpfel -bpf-expand-memcpy-in-order -bpf-max-stores-per-memfunc=3 < %s 2>&1 >/dev/null | FileCheck %s --check-prefix=ERR

; DEFAULT-LABEL: copy32:
; DEFAULT: [[TMP:r[0-9]+]] = *(u64 *)([[SRC:r[0-9]+]] + 24)
; DEFAULT: *(u64 *)([[DST:r[0-9]+]] + 24) = [[TMP]]
; DEFAULT: [[TMP]] = *(u64 *)([[SRC]] + 16)
; DEFAULT: *(u64 *)([[DST]] + 16) = [[TMP]]
; DEFAULT: [[TMP]] = *(u64 *)([[SRC]] + 8)
; DEFAULT: *(u64 *)([[DST]] + 8) = [[TMP]]
; DEFAULT: [[LASTTMP:r[0-9]+]] = *(u64 *)([[LASTSRC:r[0-9]+]] + 0)
; DEFAULT: *(u64 *)([[LASTDST:r[0-9]+]] + 0) = [[LASTTMP]]

; INORDER-LABEL: copy32:
; INORDER: [[TMP:r[0-9]+]] = *(u64 *)([[SRC:r[0-9]+]] + 0)
; INORDER: *(u64 *)([[DST:r[0-9]+]] + 0) = [[TMP]]
; INORDER: [[TMP]] = *(u64 *)([[SRC]] + 8)
; INORDER: *(u64 *)([[DST]] + 8) = [[TMP]]
; INORDER: [[TMP]] = *(u64 *)([[SRC]] + 16)
; INORDER: *(u64 *)([[DST]] + 16) = [[TMP]]
; INORDER: [[TMP]] = *(u64 *)([[SRC]] + 24)
; INORDER: *(u64 *)([[DST]] + 24) = [[TMP]]

; ERR: error:
; ERR: built-in function 'memcpy'
define dso_local void @copy32(ptr nocapture %dst, ptr nocapture readonly %src) local_unnamed_addr {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %src,
                                        i64 32, i1 false)
  ret void
}

declare void @llvm.memcpy.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1)
