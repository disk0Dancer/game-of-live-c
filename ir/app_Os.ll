; ModuleID = 'sim_app/app.c'
source_filename = "sim_app/app.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nounwind optsize ssp uwtable(sync)
define void @app() local_unnamed_addr #0 {
  %1 = alloca [16384 x i32], align 4
  %2 = alloca [16384 x i32], align 4
  call void @llvm.lifetime.start.p0(i64 65536, ptr nonnull %1) #5
  call void @llvm.lifetime.start.p0(i64 65536, ptr nonnull %2) #5
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(65536) %1, i8 noundef 0, i64 noundef 65536, i1 noundef false) #6
  br label %3

3:                                                ; preds = %3, %0
  %4 = phi i64 [ 0, %0 ], [ %10, %3 ]
  %5 = tail call i32 @simRand() #6
  %6 = srem i32 %5, 1000
  %7 = icmp slt i32 %6, 180
  %8 = zext i1 %7 to i32
  %9 = getelementptr inbounds i32, ptr %1, i64 %4
  store i32 %8, ptr %9, align 4, !tbaa !6
  %10 = add nuw nsw i64 %4, 1
  %11 = icmp eq i64 %10, 16384
  br i1 %11, label %12, label %3, !llvm.loop !10

12:                                               ; preds = %3, %67
  %13 = phi i32 [ %68, %67 ], [ 0, %3 ]
  br label %15

14:                                               ; preds = %67
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
  br i1 %23, label %46, label %15, !llvm.loop !12

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
  br i1 %37, label %43, label %32, !llvm.loop !13

38:                                               ; preds = %38, %32
  %39 = phi i32 [ 0, %32 ], [ %41, %38 ]
  %40 = add nuw nsw i32 %39, %31
  tail call void @simPutPixel(i32 noundef %40, i32 noundef %34, i32 noundef %29) #6
  %41 = add nuw nsw i32 %39, 1
  %42 = icmp eq i32 %41, 4
  br i1 %42, label %35, label %38, !llvm.loop !14

43:                                               ; preds = %35
  %44 = add nuw nsw i64 %25, 1
  %45 = icmp eq i64 %44, 128
  br i1 %45, label %21, label %24, !llvm.loop !15

46:                                               ; preds = %21
  tail call void @simFlush() #6
  br label %47

47:                                               ; preds = %64, %46
  %48 = phi i64 [ 0, %46 ], [ %65, %64 ]
  %49 = add nsw i64 %48, -1
  %50 = icmp eq i64 %48, 0
  %51 = icmp ugt i64 %49, 127
  %52 = trunc i64 %49 to i32
  %53 = shl i32 %52, 7
  %54 = select i1 %51, i32 0, i32 %53
  %55 = icmp eq i64 %48, 127
  %56 = shl nuw nsw i64 %48, 7
  %57 = select i1 %50, i32 16256, i32 %54
  %58 = trunc i64 %56 to i32
  %59 = add i32 %58, 128
  %60 = select i1 %55, i32 0, i32 %59
  %61 = sext i32 %60 to i64
  %62 = sext i32 %57 to i64
  %63 = getelementptr i32, ptr %1, i64 %56
  br label %70

64:                                               ; preds = %70
  %65 = add nuw nsw i64 %48, 1
  %66 = icmp eq i64 %65, 128
  br i1 %66, label %67, label %47, !llvm.loop !16

67:                                               ; preds = %64
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(65536) %1, ptr noundef nonnull align 4 dereferenceable(65536) %2, i64 65536, i1 false), !tbaa !6
  %68 = add nuw nsw i32 %13, 1
  %69 = icmp eq i32 %68, 1000
  br i1 %69, label %14, label %12, !llvm.loop !17

70:                                               ; preds = %70, %47
  %71 = phi i64 [ 0, %47 ], [ %78, %70 ]
  %72 = icmp eq i64 %71, 0
  %73 = trunc i64 %71 to i32
  %74 = add i32 %73, -1
  %75 = icmp ugt i32 %74, 127
  %76 = select i1 %75, i32 0, i32 %74
  %77 = select i1 %72, i32 127, i32 %76
  %78 = add nuw nsw i64 %71, 1
  %79 = icmp eq i64 %71, 127
  %80 = trunc nuw nsw i64 %78 to i32
  %81 = select i1 %79, i32 0, i32 %80
  %82 = add nsw i32 %77, %57
  %83 = sext i32 %82 to i64
  %84 = getelementptr inbounds i32, ptr %1, i64 %83
  %85 = load i32, ptr %84, align 4, !tbaa !6
  %86 = or disjoint i64 %71, %62
  %87 = getelementptr inbounds i32, ptr %1, i64 %86
  %88 = load i32, ptr %87, align 4, !tbaa !6
  %89 = add nsw i32 %88, %85
  %90 = add nsw i32 %81, %57
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds i32, ptr %1, i64 %91
  %93 = load i32, ptr %92, align 4, !tbaa !6
  %94 = add nsw i32 %89, %93
  %95 = sext i32 %77 to i64
  %96 = getelementptr i32, ptr %63, i64 %95
  %97 = load i32, ptr %96, align 4, !tbaa !6
  %98 = add nsw i32 %94, %97
  %99 = add nuw nsw i32 %81, %58
  %100 = zext nneg i32 %99 to i64
  %101 = getelementptr inbounds i32, ptr %1, i64 %100
  %102 = load i32, ptr %101, align 4, !tbaa !6
  %103 = add nsw i32 %98, %102
  %104 = add nsw i32 %77, %60
  %105 = sext i32 %104 to i64
  %106 = getelementptr inbounds i32, ptr %1, i64 %105
  %107 = load i32, ptr %106, align 4, !tbaa !6
  %108 = add nsw i32 %103, %107
  %109 = or disjoint i64 %71, %61
  %110 = getelementptr inbounds i32, ptr %1, i64 %109
  %111 = load i32, ptr %110, align 4, !tbaa !6
  %112 = add nsw i32 %108, %111
  %113 = add nuw nsw i32 %81, %60
  %114 = zext nneg i32 %113 to i64
  %115 = getelementptr inbounds i32, ptr %1, i64 %114
  %116 = load i32, ptr %115, align 4, !tbaa !6
  %117 = add nsw i32 %112, %116
  %118 = or disjoint i64 %71, %56
  %119 = getelementptr inbounds i32, ptr %1, i64 %118
  %120 = load i32, ptr %119, align 4, !tbaa !6
  %121 = icmp eq i32 %120, 0
  %122 = and i32 %117, -2
  %123 = icmp eq i32 %122, 2
  %124 = icmp eq i32 %117, 3
  %125 = select i1 %121, i1 %124, i1 %123
  %126 = zext i1 %125 to i32
  %127 = getelementptr inbounds i32, ptr %2, i64 %118
  store i32 %126, ptr %127, align 4, !tbaa !6
  %128 = icmp eq i64 %78, 128
  br i1 %128, label %64, label %70, !llvm.loop !18
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: optsize
declare void @simFlush(...) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: optsize
declare i32 @simRand(...) local_unnamed_addr #2

; Function Attrs: optsize
declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #4

attributes #0 = { nounwind optsize ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { optsize "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { nounwind }
attributes #6 = { nounwind optsize }

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
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.mustprogress"}
!12 = distinct !{!12, !11}
!13 = distinct !{!13, !11}
!14 = distinct !{!14, !11}
!15 = distinct !{!15, !11}
!16 = distinct !{!16, !11}
!17 = distinct !{!17, !11}
!18 = distinct !{!18, !11}
