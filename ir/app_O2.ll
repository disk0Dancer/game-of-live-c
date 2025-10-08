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

12:                                               ; preds = %3, %102
  %13 = phi i32 [ %103, %102 ], [ 0, %3 ]
  br label %15

14:                                               ; preds = %102
  call void @llvm.lifetime.end.p0(i64 65536, ptr nonnull %2) #5
  call void @llvm.lifetime.end.p0(i64 65536, ptr nonnull %1) #5
  ret void

15:                                               ; preds = %12, %24
  %16 = phi i64 [ %25, %24 ], [ 0, %12 ]
  %17 = shl nsw i64 %16, 9
  %18 = getelementptr inbounds i8, ptr %1, i64 %17
  %19 = trunc i64 %16 to i32
  %20 = shl i32 %19, 2
  %21 = or disjoint i32 %20, 1
  %22 = or disjoint i32 %20, 2
  %23 = or disjoint i32 %20, 3
  br label %27

24:                                               ; preds = %27
  %25 = add nuw nsw i64 %16, 1
  %26 = icmp eq i64 %25, 128
  br i1 %26, label %40, label %15, !llvm.loop !12

27:                                               ; preds = %27, %15
  %28 = phi i64 [ 0, %15 ], [ %38, %27 ]
  %29 = getelementptr inbounds i32, ptr %18, i64 %28
  %30 = load i32, ptr %29, align 4, !tbaa !6
  %31 = icmp eq i32 %30, 0
  %32 = select i1 %31, i32 -16777216, i32 -1
  %33 = trunc i64 %28 to i32
  %34 = shl i32 %33, 2
  tail call void @simPutPixel(i32 noundef %34, i32 noundef %20, i32 noundef %32) #5
  %35 = or disjoint i32 %34, 1
  tail call void @simPutPixel(i32 noundef %35, i32 noundef %20, i32 noundef %32) #5
  %36 = or disjoint i32 %34, 2
  tail call void @simPutPixel(i32 noundef %36, i32 noundef %20, i32 noundef %32) #5
  %37 = or disjoint i32 %34, 3
  tail call void @simPutPixel(i32 noundef %37, i32 noundef %20, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %34, i32 noundef %21, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %35, i32 noundef %21, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %36, i32 noundef %21, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %37, i32 noundef %21, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %34, i32 noundef %22, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %35, i32 noundef %22, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %36, i32 noundef %22, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %37, i32 noundef %22, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %34, i32 noundef %23, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %35, i32 noundef %23, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %36, i32 noundef %23, i32 noundef %32) #5
  tail call void @simPutPixel(i32 noundef %37, i32 noundef %23, i32 noundef %32) #5
  %38 = add nuw nsw i64 %28, 1
  %39 = icmp eq i64 %38, 128
  br i1 %39, label %24, label %27, !llvm.loop !13

40:                                               ; preds = %24
  tail call void @simFlush() #5
  br label %41

41:                                               ; preds = %99, %40
  %42 = phi i64 [ 0, %40 ], [ %100, %99 ]
  %43 = add nsw i64 %42, -1
  %44 = icmp eq i64 %42, 0
  %45 = icmp ugt i64 %43, 127
  %46 = trunc i64 %43 to i32
  %47 = shl i32 %46, 7
  %48 = select i1 %45, i32 0, i32 %47
  %49 = icmp eq i64 %42, 127
  %50 = shl nuw nsw i64 %42, 7
  %51 = select i1 %44, i32 16256, i32 %48
  %52 = trunc i64 %50 to i32
  %53 = add i32 %52, 128
  %54 = select i1 %49, i32 0, i32 %53
  %55 = sext i32 %54 to i64
  %56 = sext i32 %51 to i64
  %57 = or disjoint i32 %51, 127
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds i32, ptr %1, i64 %58
  %60 = load i32, ptr %59, align 4, !tbaa !6
  %61 = getelementptr inbounds i32, ptr %1, i64 %56
  %62 = load i32, ptr %61, align 4, !tbaa !6
  %63 = add nsw i32 %62, %60
  %64 = or disjoint i32 %51, 1
  %65 = sext i32 %64 to i64
  %66 = getelementptr inbounds i32, ptr %1, i64 %65
  %67 = load i32, ptr %66, align 4, !tbaa !6
  %68 = add nsw i32 %63, %67
  %69 = or disjoint i64 %50, 127
  %70 = getelementptr inbounds i32, ptr %1, i64 %69
  %71 = load i32, ptr %70, align 4, !tbaa !6
  %72 = add nsw i32 %68, %71
  %73 = or disjoint i64 %50, 1
  %74 = getelementptr inbounds i32, ptr %1, i64 %73
  %75 = load i32, ptr %74, align 4, !tbaa !6
  %76 = add nsw i32 %72, %75
  %77 = or disjoint i32 %54, 127
  %78 = sext i32 %77 to i64
  %79 = getelementptr inbounds i32, ptr %1, i64 %78
  %80 = load i32, ptr %79, align 4, !tbaa !6
  %81 = add nsw i32 %76, %80
  %82 = getelementptr inbounds i32, ptr %1, i64 %55
  %83 = load i32, ptr %82, align 4, !tbaa !6
  %84 = add nsw i32 %81, %83
  %85 = or disjoint i32 %54, 1
  %86 = zext nneg i32 %85 to i64
  %87 = getelementptr inbounds i32, ptr %1, i64 %86
  %88 = load i32, ptr %87, align 4, !tbaa !6
  %89 = add nsw i32 %84, %88
  %90 = getelementptr inbounds i32, ptr %1, i64 %50
  %91 = load i32, ptr %90, align 4, !tbaa !6
  %92 = icmp eq i32 %91, 0
  %93 = and i32 %89, -2
  %94 = icmp eq i32 %93, 2
  %95 = icmp eq i32 %89, 3
  %96 = select i1 %92, i1 %95, i1 %94
  %97 = zext i1 %96 to i32
  %98 = getelementptr inbounds i32, ptr %2, i64 %50
  store i32 %97, ptr %98, align 4, !tbaa !6
  br label %105

99:                                               ; preds = %105
  %100 = add nuw nsw i64 %42, 1
  %101 = icmp eq i64 %100, 128
  br i1 %101, label %102, label %41, !llvm.loop !14

102:                                              ; preds = %99
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 4 dereferenceable(65536) %1, ptr noundef nonnull align 4 dereferenceable(65536) %2, i64 65536, i1 false), !tbaa !6
  %103 = add nuw nsw i32 %13, 1
  %104 = icmp eq i32 %103, 1000
  br i1 %104, label %14, label %12, !llvm.loop !15

105:                                              ; preds = %105, %41
  %106 = phi i64 [ 1, %41 ], [ %109, %105 ]
  %107 = trunc i64 %106 to i32
  %108 = add i32 %107, -1
  %109 = add nuw nsw i64 %106, 1
  %110 = icmp eq i64 %106, 127
  %111 = trunc nuw nsw i64 %109 to i32
  %112 = select i1 %110, i32 0, i32 %111
  %113 = add nuw nsw i32 %108, %51
  %114 = sext i32 %113 to i64
  %115 = getelementptr inbounds i32, ptr %1, i64 %114
  %116 = load i32, ptr %115, align 4, !tbaa !6
  %117 = or disjoint i64 %106, %56
  %118 = getelementptr inbounds i32, ptr %1, i64 %117
  %119 = load i32, ptr %118, align 4, !tbaa !6
  %120 = add nsw i32 %119, %116
  %121 = add nsw i32 %112, %51
  %122 = sext i32 %121 to i64
  %123 = getelementptr inbounds i32, ptr %1, i64 %122
  %124 = load i32, ptr %123, align 4, !tbaa !6
  %125 = add nsw i32 %120, %124
  %126 = sext i32 %108 to i64
  %127 = getelementptr i32, ptr %90, i64 %126
  %128 = load i32, ptr %127, align 4, !tbaa !6
  %129 = add nsw i32 %125, %128
  %130 = add nuw nsw i32 %112, %52
  %131 = zext nneg i32 %130 to i64
  %132 = getelementptr inbounds i32, ptr %1, i64 %131
  %133 = load i32, ptr %132, align 4, !tbaa !6
  %134 = add nsw i32 %129, %133
  %135 = add nuw nsw i32 %108, %54
  %136 = sext i32 %135 to i64
  %137 = getelementptr inbounds i32, ptr %1, i64 %136
  %138 = load i32, ptr %137, align 4, !tbaa !6
  %139 = add nsw i32 %134, %138
  %140 = or disjoint i64 %106, %55
  %141 = getelementptr inbounds i32, ptr %1, i64 %140
  %142 = load i32, ptr %141, align 4, !tbaa !6
  %143 = add nsw i32 %139, %142
  %144 = add nuw nsw i32 %112, %54
  %145 = zext nneg i32 %144 to i64
  %146 = getelementptr inbounds i32, ptr %1, i64 %145
  %147 = load i32, ptr %146, align 4, !tbaa !6
  %148 = add nsw i32 %143, %147
  %149 = or disjoint i64 %106, %50
  %150 = getelementptr inbounds i32, ptr %1, i64 %149
  %151 = load i32, ptr %150, align 4, !tbaa !6
  %152 = icmp eq i32 %151, 0
  %153 = and i32 %148, -2
  %154 = icmp eq i32 %153, 2
  %155 = icmp eq i32 %148, 3
  %156 = select i1 %152, i1 %155, i1 %154
  %157 = zext i1 %156 to i32
  %158 = getelementptr inbounds i32, ptr %2, i64 %149
  store i32 %157, ptr %158, align 4, !tbaa !6
  %159 = icmp eq i64 %109, 128
  br i1 %159, label %99, label %105, !llvm.loop !16
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
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.mustprogress"}
!12 = distinct !{!12, !11}
!13 = distinct !{!13, !11}
!14 = distinct !{!14, !11}
!15 = distinct !{!15, !11}
!16 = distinct !{!16, !11, !17}
!17 = !{!"llvm.loop.peeled.count", i32 1}
