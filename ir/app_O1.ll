; ModuleID = 'sim_app/app.c'
source_filename = "sim_app/app.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @app() local_unnamed_addr #0 {
  %1 = alloca [16384 x i32], align 4
  %2 = alloca [16384 x i32], align 4
  call void @llvm.lifetime.start.p0(i64 65536, ptr nonnull %1) #5
  call void @llvm.lifetime.start.p0(i64 65536, ptr nonnull %2) #5
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(65536) %1, i8 noundef 0, i64 noundef 65536, i1 noundef false) #5
  br label %3

3:                                                ; preds = %3, %0
  %4 = phi i64 [ 0, %0 ], [ %10, %3 ]
  %5 = tail call i32 @simRand() #5
  %6 = srem i32 %5, 1000
  %7 = icmp slt i32 %6, 180
  %8 = zext i1 %7 to i32
  %9 = getelementptr inbounds i32, ptr %1, i64 %4
  store i32 %8, ptr %9, align 4, !tbaa !6
  %10 = add nuw nsw i64 %4, 1
  %11 = icmp eq i64 %10, 16384
  br i1 %11, label %12, label %3, !llvm.loop !10

12:                                               ; preds = %3, %65
  %13 = phi i32 [ %66, %65 ], [ 0, %3 ]
  br label %15

14:                                               ; preds = %65
  call void @llvm.lifetime.end.p0(i64 65536, ptr nonnull %2) #5
  call void @llvm.lifetime.end.p0(i64 65536, ptr nonnull %1) #5
  ret void

15:                                               ; preds = %12, %21
  %16 = phi i64 [ %22, %21 ], [ 0, %12 ]
  %17 = shl nsw i64 %16, 9
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  %19 = trunc i64 %16 to i32
  %20 = shl i32 %19, 2
  br label %24

21:                                               ; preds = %43
  %22 = add nuw nsw i64 %16, 1
  %23 = icmp eq i64 %22, 128
  br i1 %23, label %46, label %15, !llvm.loop !13

24:                                               ; preds = %43, %15
  %25 = phi i64 [ 0, %15 ], [ %44, %43 ]
  %26 = getelementptr inbounds i32, ptr %18, i64 %25
  %27 = load i32, ptr %26, align 4, !tbaa !6
  %28 = icmp eq i32 %27, 0
  %29 = select i1 %28, i32 -16777216, i32 -1
  %30 = trunc i64 %25 to i32
  %31 = shl i32 %30, 2
  br label %32

32:                                               ; preds = %35, %24
  %33 = phi i32 [ 0, %24 ], [ %36, %35 ]
  %34 = add nuw nsw i32 %33, %20
  br label %38

35:                                               ; preds = %38
  %36 = add nuw nsw i32 %33, 1
  %37 = icmp eq i32 %36, 4
  br i1 %37, label %43, label %32, !llvm.loop !14

38:                                               ; preds = %38, %32
  %39 = phi i32 [ 0, %32 ], [ %41, %38 ]
  %40 = add nuw nsw i32 %39, %31
  tail call void @simPutPixel(i32 noundef %40, i32 noundef %34, i32 noundef %29) #5
  %41 = add nuw nsw i32 %39, 1
  %42 = icmp eq i32 %41, 4
  br i1 %42, label %35, label %38, !llvm.loop !15

43:                                               ; preds = %35
  %44 = add nuw nsw i64 %25, 1
  %45 = icmp eq i64 %44, 128
  br i1 %45, label %21, label %24, !llvm.loop !16

46:                                               ; preds = %21
  tail call void @simFlush() #5
  br label %47

47:                                               ; preds = %62, %46
  %48 = phi i64 [ 0, %46 ], [ %63, %62 ]
  %49 = icmp eq i64 %48, 0
  %50 = icmp eq i64 %48, 127
  %51 = trunc i64 %48 to i32
  %52 = shl i32 %51, 7
  %53 = add i32 %52, -128
  %54 = select i1 %49, i32 16256, i32 %53
  %55 = shl nuw nsw i64 %48, 7
  %56 = add i32 %52, 128
  %57 = select i1 %50, i32 0, i32 %56
  %58 = sext i32 %57 to i64
  %59 = sext i32 %54 to i64
  %60 = getelementptr i32, ptr %1, i64 %55
  %61 = trunc nuw nsw i64 %55 to i32
  br label %68

62:                                               ; preds = %68
  %63 = add nuw nsw i64 %48, 1
  %64 = icmp eq i64 %63, 128
  br i1 %64, label %65, label %47, !llvm.loop !17

65:                                               ; preds = %62
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(65536) %1, ptr noundef nonnull align 4 dereferenceable(65536) %2, i64 65536, i1 false), !tbaa !6
  %66 = add nuw nsw i32 %13, 1
  %67 = icmp eq i32 %66, 1000
  br i1 %67, label %14, label %12, !llvm.loop !18

68:                                               ; preds = %68, %47
  %69 = phi i64 [ 0, %47 ], [ %74, %68 ]
  %70 = icmp eq i64 %69, 0
  %71 = trunc i64 %69 to i32
  %72 = add i32 %71, -1
  %73 = select i1 %70, i32 127, i32 %72
  %74 = add nuw nsw i64 %69, 1
  %75 = icmp eq i64 %69, 127
  %76 = trunc nuw nsw i64 %74 to i32
  %77 = select i1 %75, i32 0, i32 %76
  %78 = add nsw i32 %73, %54
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds i32, ptr %1, i64 %79
  %81 = load i32, ptr %80, align 4, !tbaa !6
  %82 = or disjoint i64 %69, %59
  %83 = getelementptr inbounds i32, ptr %1, i64 %82
  %84 = load i32, ptr %83, align 4, !tbaa !6
  %85 = add nsw i32 %84, %81
  %86 = add nsw i32 %77, %54
  %87 = sext i32 %86 to i64
  %88 = getelementptr inbounds i32, ptr %1, i64 %87
  %89 = load i32, ptr %88, align 4, !tbaa !6
  %90 = add nsw i32 %85, %89
  %91 = sext i32 %73 to i64
  %92 = getelementptr i32, ptr %60, i64 %91
  %93 = load i32, ptr %92, align 4, !tbaa !6
  %94 = add nsw i32 %90, %93
  %95 = add nuw nsw i32 %77, %61
  %96 = zext nneg i32 %95 to i64
  %97 = getelementptr inbounds i32, ptr %1, i64 %96
  %98 = load i32, ptr %97, align 4, !tbaa !6
  %99 = add nsw i32 %94, %98
  %100 = add nsw i32 %73, %57
  %101 = sext i32 %100 to i64
  %102 = getelementptr inbounds i32, ptr %1, i64 %101
  %103 = load i32, ptr %102, align 4, !tbaa !6
  %104 = add nsw i32 %99, %103
  %105 = or disjoint i64 %69, %58
  %106 = getelementptr inbounds i32, ptr %1, i64 %105
  %107 = load i32, ptr %106, align 4, !tbaa !6
  %108 = add nsw i32 %104, %107
  %109 = add nuw nsw i32 %77, %57
  %110 = zext nneg i32 %109 to i64
  %111 = getelementptr inbounds i32, ptr %1, i64 %110
  %112 = load i32, ptr %111, align 4, !tbaa !6
  %113 = add nsw i32 %108, %112
  %114 = or disjoint i64 %69, %55
  %115 = getelementptr inbounds i32, ptr %1, i64 %114
  %116 = load i32, ptr %115, align 4, !tbaa !6
  %117 = icmp eq i32 %116, 0
  %118 = and i32 %113, -2
  %119 = icmp eq i32 %118, 2
  %120 = icmp eq i32 %113, 3
  %121 = select i1 %117, i1 %120, i1 %119
  %122 = zext i1 %121 to i32
  %123 = getelementptr inbounds i32, ptr %2, i64 %114
  store i32 %122, ptr %123, align 4, !tbaa !6
  %124 = icmp eq i64 %74, 128
  br i1 %124, label %62, label %68, !llvm.loop !19
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare void @simFlush(...) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

declare i32 @simRand(...) local_unnamed_addr #2

declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #4

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 17.0.0 (clang-1700.3.19.1)"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = distinct !{!10, !11, !12}
!11 = !{!"llvm.loop.mustprogress"}
!12 = !{!"llvm.loop.unroll.disable"}
!13 = distinct !{!13, !11, !12}
!14 = distinct !{!14, !11, !12}
!15 = distinct !{!15, !11, !12}
!16 = distinct !{!16, !11, !12}
!17 = distinct !{!17, !11, !12}
!18 = distinct !{!18, !11, !12}
!19 = distinct !{!19, !11, !12}
