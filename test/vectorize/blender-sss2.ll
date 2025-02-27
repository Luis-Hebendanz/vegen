; RUN: %opt -tbaa -gslp -no-unroll %s -o /dev/null

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

%struct.anon = type { float, float }

@g = external dso_local local_unnamed_addr global %struct.anon*, align 8
@d = external dso_local local_unnamed_addr global %struct.anon, align 4

define dso_local i32 @scatter_settings_new() local_unnamed_addr {
entry:
  %div = fdiv fast float 0.0, 1.000000e+00
  %0 = load %struct.anon*, %struct.anon** @g, align 8, !tbaa !0
  %c = getelementptr inbounds %struct.anon, %struct.anon* %0, i64 0, i32 1
  store float %div, float* %c, align 4, !tbaa !4
  br label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %1 = load float, float* getelementptr inbounds (%struct.anon, %struct.anon* @d, i64 0, i32 1), align 4, !tbaa !4
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %conv1 = sitofp i32 zeroinitializer to float
  %2 = fdiv fast float %conv1, %1
  br i1 true, label %for.cond.for.end_crit_edge, label %for.body, !llvm.loop !7

for.cond.for.end_crit_edge:                       ; preds = %for.body
  %conv1.lcssa = phi float [ %conv1, %for.body ]
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge
  %div4 = fdiv fast float 0.0, %conv1.lcssa
  %b = getelementptr inbounds %struct.anon, %struct.anon* %0, i64 0, i32 0
  store float %div4, float* %b, align 4, !tbaa !9
  ret i32 0
}

!0 = !{!1, !1, i64 0}
!1 = !{!"any pointer", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!5, !6, i64 4}
!5 = !{!"", !6, i64 0, !6, i64 4}
!6 = !{!"float", !2, i64 0}
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.mustprogress"}
!9 = !{!5, !6, i64 0}
