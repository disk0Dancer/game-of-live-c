; ModuleID = 'sim_app/app.c'
source_filename = "sim_app/app.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @app() #0 {
  %1 = alloca [16384 x i32], align 4
  %2 = alloca [16384 x i32], align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = getelementptr inbounds [16384 x i32], ptr %1, i64 0, i64 0
  call void @clear_all(ptr noundef %5)
  %6 = getelementptr inbounds [16384 x i32], ptr %1, i64 0, i64 0
  call void @randomize(ptr noundef %6, i32 noundef 180)
  store i32 0, ptr %3, align 4
  br label %7

7:                                                ; preds = %29, %0
  %8 = load i32, ptr %3, align 4
  %9 = icmp slt i32 %8, 1000
  br i1 %9, label %10, label %32

10:                                               ; preds = %7
  %11 = getelementptr inbounds [16384 x i32], ptr %1, i64 0, i64 0
  call void @draw_frame(ptr noundef %11)
  call void @simFlush()
  %12 = getelementptr inbounds [16384 x i32], ptr %2, i64 0, i64 0
  %13 = getelementptr inbounds [16384 x i32], ptr %1, i64 0, i64 0
  call void @step_generation(ptr noundef %12, ptr noundef %13)
  store i32 0, ptr %4, align 4
  br label %14

14:                                               ; preds = %25, %10
  %15 = load i32, ptr %4, align 4
  %16 = icmp slt i32 %15, 16384
  br i1 %16, label %17, label %28

17:                                               ; preds = %14
  %18 = load i32, ptr %4, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds [16384 x i32], ptr %2, i64 0, i64 %19
  %21 = load i32, ptr %20, align 4
  %22 = load i32, ptr %4, align 4
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds [16384 x i32], ptr %1, i64 0, i64 %23
  store i32 %21, ptr %24, align 4
  br label %25

25:                                               ; preds = %17
  %26 = load i32, ptr %4, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, ptr %4, align 4
  br label %14, !llvm.loop !6

28:                                               ; preds = %14
  br label %29

29:                                               ; preds = %28
  %30 = load i32, ptr %3, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, ptr %3, align 4
  br label %7, !llvm.loop !8

32:                                               ; preds = %7
  ret void
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal void @clear_all(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  %3 = load ptr, ptr %2, align 8
  %4 = load ptr, ptr %2, align 8
  %5 = call i64 @llvm.objectsize.i64.p0(ptr %4, i1 false, i1 true, i1 false)
  %6 = call ptr @__memset_chk(ptr noundef %3, i32 noundef 0, i64 noundef 65536, i64 noundef %5) #4
  ret void
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal void @randomize(ptr noundef %0, i32 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store i32 %1, ptr %4, align 4
  store i32 0, ptr %5, align 4
  br label %6

6:                                                ; preds = %20, %2
  %7 = load i32, ptr %5, align 4
  %8 = icmp slt i32 %7, 16384
  br i1 %8, label %9, label %23

9:                                                ; preds = %6
  %10 = call i32 @simRand()
  %11 = srem i32 %10, 1000
  %12 = load i32, ptr %4, align 4
  %13 = icmp slt i32 %11, %12
  %14 = zext i1 %13 to i64
  %15 = select i1 %13, i32 1, i32 0
  %16 = load ptr, ptr %3, align 8
  %17 = load i32, ptr %5, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds i32, ptr %16, i64 %18
  store i32 %15, ptr %19, align 4
  br label %20

20:                                               ; preds = %9
  %21 = load i32, ptr %5, align 4
  %22 = add nsw i32 %21, 1
  store i32 %22, ptr %5, align 4
  br label %6, !llvm.loop !9

23:                                               ; preds = %6
  ret void
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal void @draw_frame(ptr noundef %0) #0 {
  %2 = alloca ptr, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store ptr %0, ptr %2, align 8
  store i32 -1, ptr %3, align 4
  store i32 -16777216, ptr %4, align 4
  store i32 0, ptr %5, align 4
  br label %7

7:                                                ; preds = %31, %1
  %8 = load i32, ptr %5, align 4
  %9 = icmp slt i32 %8, 128
  br i1 %9, label %10, label %34

10:                                               ; preds = %7
  store i32 0, ptr %6, align 4
  br label %11

11:                                               ; preds = %27, %10
  %12 = load i32, ptr %6, align 4
  %13 = icmp slt i32 %12, 128
  br i1 %13, label %14, label %30

14:                                               ; preds = %11
  %15 = load i32, ptr %6, align 4
  %16 = load i32, ptr %5, align 4
  %17 = load ptr, ptr %2, align 8
  %18 = load i32, ptr %6, align 4
  %19 = load i32, ptr %5, align 4
  %20 = call i32 @idx(i32 noundef %18, i32 noundef %19)
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds i32, ptr %17, i64 %21
  %23 = load i32, ptr %22, align 4
  %24 = icmp ne i32 %23, 0
  %25 = zext i1 %24 to i64
  %26 = select i1 %24, i32 -1, i32 -16777216
  call void @draw_cell(i32 noundef %15, i32 noundef %16, i32 noundef %26)
  br label %27

27:                                               ; preds = %14
  %28 = load i32, ptr %6, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, ptr %6, align 4
  br label %11, !llvm.loop !10

30:                                               ; preds = %11
  br label %31

31:                                               ; preds = %30
  %32 = load i32, ptr %5, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, ptr %5, align 4
  br label %7, !llvm.loop !11

34:                                               ; preds = %7
  ret void
}

declare void @simFlush(...) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal void @step_generation(ptr noundef %0, ptr noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  store ptr %1, ptr %4, align 8
  store i32 0, ptr %5, align 4
  br label %10

10:                                               ; preds = %59, %2
  %11 = load i32, ptr %5, align 4
  %12 = icmp slt i32 %11, 128
  br i1 %12, label %13, label %62

13:                                               ; preds = %10
  store i32 0, ptr %6, align 4
  br label %14

14:                                               ; preds = %55, %13
  %15 = load i32, ptr %6, align 4
  %16 = icmp slt i32 %15, 128
  br i1 %16, label %17, label %58

17:                                               ; preds = %14
  %18 = load ptr, ptr %4, align 8
  %19 = load i32, ptr %6, align 4
  %20 = load i32, ptr %5, align 4
  %21 = call i32 @neighbors(ptr noundef %18, i32 noundef %19, i32 noundef %20)
  store i32 %21, ptr %7, align 4
  %22 = load ptr, ptr %4, align 8
  %23 = load i32, ptr %6, align 4
  %24 = load i32, ptr %5, align 4
  %25 = call i32 @idx(i32 noundef %23, i32 noundef %24)
  %26 = sext i32 %25 to i64
  %27 = getelementptr inbounds i32, ptr %22, i64 %26
  %28 = load i32, ptr %27, align 4
  %29 = icmp ne i32 %28, 0
  %30 = zext i1 %29 to i32
  store i32 %30, ptr %8, align 4
  %31 = load i32, ptr %8, align 4
  %32 = icmp ne i32 %31, 0
  br i1 %32, label %33, label %42

33:                                               ; preds = %17
  %34 = load i32, ptr %7, align 4
  %35 = icmp eq i32 %34, 2
  br i1 %35, label %39, label %36

36:                                               ; preds = %33
  %37 = load i32, ptr %7, align 4
  %38 = icmp eq i32 %37, 3
  br label %39

39:                                               ; preds = %36, %33
  %40 = phi i1 [ true, %33 ], [ %38, %36 ]
  %41 = zext i1 %40 to i32
  br label %46

42:                                               ; preds = %17
  %43 = load i32, ptr %7, align 4
  %44 = icmp eq i32 %43, 3
  %45 = zext i1 %44 to i32
  br label %46

46:                                               ; preds = %42, %39
  %47 = phi i32 [ %41, %39 ], [ %45, %42 ]
  store i32 %47, ptr %9, align 4
  %48 = load i32, ptr %9, align 4
  %49 = load ptr, ptr %3, align 8
  %50 = load i32, ptr %6, align 4
  %51 = load i32, ptr %5, align 4
  %52 = call i32 @idx(i32 noundef %50, i32 noundef %51)
  %53 = sext i32 %52 to i64
  %54 = getelementptr inbounds i32, ptr %49, i64 %53
  store i32 %48, ptr %54, align 4
  br label %55

55:                                               ; preds = %46
  %56 = load i32, ptr %6, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, ptr %6, align 4
  br label %14, !llvm.loop !12

58:                                               ; preds = %14
  br label %59

59:                                               ; preds = %58
  %60 = load i32, ptr %5, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, ptr %5, align 4
  br label %10, !llvm.loop !13

62:                                               ; preds = %10
  ret void
}

; Function Attrs: nounwind
declare ptr @__memset_chk(ptr noundef, i32 noundef, i64 noundef, i64 noundef) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.objectsize.i64.p0(ptr, i1 immarg, i1 immarg, i1 immarg) #3

declare i32 @simRand(...) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal void @draw_cell(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  store i32 %2, ptr %6, align 4
  %11 = load i32, ptr %4, align 4
  %12 = mul nsw i32 %11, 4
  store i32 %12, ptr %7, align 4
  %13 = load i32, ptr %5, align 4
  %14 = mul nsw i32 %13, 4
  store i32 %14, ptr %8, align 4
  store i32 0, ptr %9, align 4
  br label %15

15:                                               ; preds = %34, %3
  %16 = load i32, ptr %9, align 4
  %17 = icmp slt i32 %16, 4
  br i1 %17, label %18, label %37

18:                                               ; preds = %15
  store i32 0, ptr %10, align 4
  br label %19

19:                                               ; preds = %30, %18
  %20 = load i32, ptr %10, align 4
  %21 = icmp slt i32 %20, 4
  br i1 %21, label %22, label %33

22:                                               ; preds = %19
  %23 = load i32, ptr %7, align 4
  %24 = load i32, ptr %10, align 4
  %25 = add nsw i32 %23, %24
  %26 = load i32, ptr %8, align 4
  %27 = load i32, ptr %9, align 4
  %28 = add nsw i32 %26, %27
  %29 = load i32, ptr %6, align 4
  call void @simPutPixel(i32 noundef %25, i32 noundef %28, i32 noundef %29)
  br label %30

30:                                               ; preds = %22
  %31 = load i32, ptr %10, align 4
  %32 = add nsw i32 %31, 1
  store i32 %32, ptr %10, align 4
  br label %19, !llvm.loop !14

33:                                               ; preds = %19
  br label %34

34:                                               ; preds = %33
  %35 = load i32, ptr %9, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, ptr %9, align 4
  br label %15, !llvm.loop !15

37:                                               ; preds = %15
  ret void
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal i32 @idx(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %5 = load i32, ptr %4, align 4
  %6 = mul nsw i32 %5, 128
  %7 = load i32, ptr %3, align 4
  %8 = add nsw i32 %6, %7
  ret i32 %8
}

declare void @simPutPixel(i32 noundef, i32 noundef, i32 noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal i32 @neighbors(ptr noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i32 %2, ptr %6, align 4
  %11 = load i32, ptr %5, align 4
  %12 = sub nsw i32 %11, 1
  %13 = call i32 @wrap(i32 noundef %12, i32 noundef 128)
  store i32 %13, ptr %7, align 4
  %14 = load i32, ptr %5, align 4
  %15 = add nsw i32 %14, 1
  %16 = call i32 @wrap(i32 noundef %15, i32 noundef 128)
  store i32 %16, ptr %8, align 4
  %17 = load i32, ptr %6, align 4
  %18 = sub nsw i32 %17, 1
  %19 = call i32 @wrap(i32 noundef %18, i32 noundef 128)
  store i32 %19, ptr %9, align 4
  %20 = load i32, ptr %6, align 4
  %21 = add nsw i32 %20, 1
  %22 = call i32 @wrap(i32 noundef %21, i32 noundef 128)
  store i32 %22, ptr %10, align 4
  %23 = load ptr, ptr %4, align 8
  %24 = load i32, ptr %7, align 4
  %25 = load i32, ptr %9, align 4
  %26 = call i32 @idx(i32 noundef %24, i32 noundef %25)
  %27 = sext i32 %26 to i64
  %28 = getelementptr inbounds i32, ptr %23, i64 %27
  %29 = load i32, ptr %28, align 4
  %30 = load ptr, ptr %4, align 8
  %31 = load i32, ptr %5, align 4
  %32 = load i32, ptr %9, align 4
  %33 = call i32 @idx(i32 noundef %31, i32 noundef %32)
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds i32, ptr %30, i64 %34
  %36 = load i32, ptr %35, align 4
  %37 = add nsw i32 %29, %36
  %38 = load ptr, ptr %4, align 8
  %39 = load i32, ptr %8, align 4
  %40 = load i32, ptr %9, align 4
  %41 = call i32 @idx(i32 noundef %39, i32 noundef %40)
  %42 = sext i32 %41 to i64
  %43 = getelementptr inbounds i32, ptr %38, i64 %42
  %44 = load i32, ptr %43, align 4
  %45 = add nsw i32 %37, %44
  %46 = load ptr, ptr %4, align 8
  %47 = load i32, ptr %7, align 4
  %48 = load i32, ptr %6, align 4
  %49 = call i32 @idx(i32 noundef %47, i32 noundef %48)
  %50 = sext i32 %49 to i64
  %51 = getelementptr inbounds i32, ptr %46, i64 %50
  %52 = load i32, ptr %51, align 4
  %53 = add nsw i32 %45, %52
  %54 = load ptr, ptr %4, align 8
  %55 = load i32, ptr %8, align 4
  %56 = load i32, ptr %6, align 4
  %57 = call i32 @idx(i32 noundef %55, i32 noundef %56)
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds i32, ptr %54, i64 %58
  %60 = load i32, ptr %59, align 4
  %61 = add nsw i32 %53, %60
  %62 = load ptr, ptr %4, align 8
  %63 = load i32, ptr %7, align 4
  %64 = load i32, ptr %10, align 4
  %65 = call i32 @idx(i32 noundef %63, i32 noundef %64)
  %66 = sext i32 %65 to i64
  %67 = getelementptr inbounds i32, ptr %62, i64 %66
  %68 = load i32, ptr %67, align 4
  %69 = add nsw i32 %61, %68
  %70 = load ptr, ptr %4, align 8
  %71 = load i32, ptr %5, align 4
  %72 = load i32, ptr %10, align 4
  %73 = call i32 @idx(i32 noundef %71, i32 noundef %72)
  %74 = sext i32 %73 to i64
  %75 = getelementptr inbounds i32, ptr %70, i64 %74
  %76 = load i32, ptr %75, align 4
  %77 = add nsw i32 %69, %76
  %78 = load ptr, ptr %4, align 8
  %79 = load i32, ptr %8, align 4
  %80 = load i32, ptr %10, align 4
  %81 = call i32 @idx(i32 noundef %79, i32 noundef %80)
  %82 = sext i32 %81 to i64
  %83 = getelementptr inbounds i32, ptr %78, i64 %82
  %84 = load i32, ptr %83, align 4
  %85 = add nsw i32 %77, %84
  ret i32 %85
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal i32 @wrap(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  %6 = load i32, ptr %4, align 4
  %7 = icmp slt i32 %6, 0
  br i1 %7, label %8, label %12

8:                                                ; preds = %2
  %9 = load i32, ptr %4, align 4
  %10 = load i32, ptr %5, align 4
  %11 = add nsw i32 %9, %10
  store i32 %11, ptr %3, align 4
  br label %22

12:                                               ; preds = %2
  %13 = load i32, ptr %4, align 4
  %14 = load i32, ptr %5, align 4
  %15 = icmp sge i32 %13, %14
  br i1 %15, label %16, label %20

16:                                               ; preds = %12
  %17 = load i32, ptr %4, align 4
  %18 = load i32, ptr %5, align 4
  %19 = sub nsw i32 %17, %18
  store i32 %19, ptr %3, align 4
  br label %22

20:                                               ; preds = %12
  %21 = load i32, ptr %4, align 4
  store i32 %21, ptr %3, align 4
  br label %22

22:                                               ; preds = %20, %16, %8
  %23 = load i32, ptr %3, align 4
  ret i32 %23
}

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #2 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 17.0.0 (clang-1700.3.19.1)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
