; ModuleID = 'sim_app/sim.c'
source_filename = "sim_app/sim.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

%union.SDL_Event = type { %struct.SDL_SensorEvent, [8 x i8] }
%struct.SDL_SensorEvent = type { i32, i32, i32, [6 x float], i64 }
%struct.SDL_Rect = type { i32, i32, i32, i32 }

@.str = private unnamed_addr constant [20 x i8] c"SDL_Init failed: %s\00", align 1
@Window = internal global ptr null, align 8
@Renderer = internal global ptr null, align 8
@.str.1 = private unnamed_addr constant [39 x i8] c"SDL_CreateWindowAndRenderer failed: %s\00", align 1
@Ticks = internal global i32 0, align 4
@.str.2 = private unnamed_addr constant [20 x i8] c"User-requested quit\00", align 1
@__func__.simFlush = private unnamed_addr constant [9 x i8] c"simFlush\00", align 1
@.str.3 = private unnamed_addr constant [6 x i8] c"sim.c\00", align 1
@.str.4 = private unnamed_addr constant [60 x i8] c"SDL_TRUE != SDL_HasEvent(SDL_QUIT) && \22User-requested quit\22\00", align 1
@.str.5 = private unnamed_addr constant [13 x i8] c"Out of range\00", align 1
@__func__.simPutPixel = private unnamed_addr constant [12 x i8] c"simPutPixel\00", align 1
@.str.6 = private unnamed_addr constant [43 x i8] c"0 <= x && x < SIM_X_SIZE && \22Out of range\22\00", align 1
@.str.7 = private unnamed_addr constant [43 x i8] c"0 <= y && y < SIM_Y_SIZE && \22Out of range\22\00", align 1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @simInit() #0 {
  %1 = call i32 @SDL_Init(i32 noundef 32)
  %2 = icmp ne i32 %1, 0
  br i1 %2, label %3, label %5

3:                                                ; preds = %0
  %4 = call ptr @SDL_GetError()
  call void (ptr, ...) @SDL_Log(ptr noundef @.str, ptr noundef %4)
  call void @exit(i32 noundef 1) #4
  unreachable

5:                                                ; preds = %0
  %6 = call i32 @SDL_CreateWindowAndRenderer(i32 noundef 512, i32 noundef 512, i32 noundef 0, ptr noundef @Window, ptr noundef @Renderer)
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %10

8:                                                ; preds = %5
  %9 = call ptr @SDL_GetError()
  call void (ptr, ...) @SDL_Log(ptr noundef @.str.1, ptr noundef %9)
  call void @exit(i32 noundef 1) #4
  unreachable

10:                                               ; preds = %5
  call void @simClear(i32 noundef -16777216)
  %11 = load ptr, ptr @Renderer, align 8
  call void @SDL_RenderPresent(ptr noundef %11)
  %12 = call i32 @SDL_GetTicks()
  store i32 %12, ptr @Ticks, align 4
  %13 = call i64 @time(ptr noundef null)
  %14 = trunc i64 %13 to i32
  call void @srand(i32 noundef %14)
  ret void
}

declare i32 @SDL_Init(i32 noundef) #1

declare void @SDL_Log(ptr noundef, ...) #1

declare ptr @SDL_GetError() #1

; Function Attrs: noreturn
declare void @exit(i32 noundef) #2

declare i32 @SDL_CreateWindowAndRenderer(i32 noundef, i32 noundef, i32 noundef, ptr noundef, ptr noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @simClear(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %7 = load i32, ptr %2, align 4
  call void @unpack_argb_int(i32 noundef %7, ptr noundef %3, ptr noundef %4, ptr noundef %5, ptr noundef %6)
  %8 = load ptr, ptr @Renderer, align 8
  %9 = load i32, ptr %3, align 4
  %10 = trunc i32 %9 to i8
  %11 = load i32, ptr %4, align 4
  %12 = trunc i32 %11 to i8
  %13 = load i32, ptr %5, align 4
  %14 = trunc i32 %13 to i8
  %15 = load i32, ptr %6, align 4
  %16 = trunc i32 %15 to i8
  %17 = call i32 @SDL_SetRenderDrawColor(ptr noundef %8, i8 noundef zeroext %10, i8 noundef zeroext %12, i8 noundef zeroext %14, i8 noundef zeroext %16)
  %18 = load ptr, ptr @Renderer, align 8
  %19 = call i32 @SDL_RenderClear(ptr noundef %18)
  ret void
}

declare void @SDL_RenderPresent(ptr noundef) #1

declare i32 @SDL_GetTicks() #1

declare void @srand(i32 noundef) #1

declare i64 @time(ptr noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @simExit() #0 {
  %1 = alloca %union.SDL_Event, align 8
  br label %2

2:                                                ; preds = %0, %9
  %3 = call i32 @SDL_PollEvent(ptr noundef %1)
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %5, label %9

5:                                                ; preds = %2
  %6 = load i32, ptr %1, align 8
  %7 = icmp eq i32 %6, 256
  br i1 %7, label %8, label %9

8:                                                ; preds = %5
  br label %10

9:                                                ; preds = %5, %2
  br label %2

10:                                               ; preds = %8
  %11 = load ptr, ptr @Renderer, align 8
  %12 = icmp ne ptr %11, null
  br i1 %12, label %13, label %15

13:                                               ; preds = %10
  %14 = load ptr, ptr @Renderer, align 8
  call void @SDL_DestroyRenderer(ptr noundef %14)
  br label %15

15:                                               ; preds = %13, %10
  %16 = load ptr, ptr @Window, align 8
  %17 = icmp ne ptr %16, null
  br i1 %17, label %18, label %20

18:                                               ; preds = %15
  %19 = load ptr, ptr @Window, align 8
  call void @SDL_DestroyWindow(ptr noundef %19)
  br label %20

20:                                               ; preds = %18, %15
  call void @SDL_Quit()
  ret void
}

declare i32 @SDL_PollEvent(ptr noundef) #1

declare void @SDL_DestroyRenderer(ptr noundef) #1

declare void @SDL_DestroyWindow(ptr noundef) #1

declare void @SDL_Quit() #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @simFlush() #0 {
  %1 = alloca i32, align 4
  call void @SDL_PumpEvents()
  %2 = call i32 @SDL_HasEvent(i32 noundef 256)
  %3 = icmp ne i32 1, %2
  br i1 %3, label %4, label %5

4:                                                ; preds = %0
  br label %5

5:                                                ; preds = %4, %0
  %6 = phi i1 [ false, %0 ], [ true, %4 ]
  %7 = xor i1 %6, true
  %8 = zext i1 %7 to i32
  %9 = sext i32 %8 to i64
  %10 = icmp ne i64 %9, 0
  br i1 %10, label %11, label %13

11:                                               ; preds = %5
  call void @__assert_rtn(ptr noundef @__func__.simFlush, ptr noundef @.str.3, i32 noundef 51, ptr noundef @.str.4) #5
  unreachable

12:                                               ; No predecessors!
  br label %14

13:                                               ; preds = %5
  br label %14

14:                                               ; preds = %13, %12
  %15 = call i32 @SDL_GetTicks()
  %16 = load i32, ptr @Ticks, align 4
  %17 = sub i32 %15, %16
  store i32 %17, ptr %1, align 4
  %18 = load i32, ptr %1, align 4
  %19 = icmp ult i32 %18, 50
  br i1 %19, label %20, label %23

20:                                               ; preds = %14
  %21 = load i32, ptr %1, align 4
  %22 = sub i32 50, %21
  call void @SDL_Delay(i32 noundef %22)
  br label %23

23:                                               ; preds = %20, %14
  %24 = load ptr, ptr @Renderer, align 8
  call void @SDL_RenderPresent(ptr noundef %24)
  ret void
}

declare void @SDL_PumpEvents() #1

declare i32 @SDL_HasEvent(i32 noundef) #1

; Function Attrs: cold noreturn
declare void @__assert_rtn(ptr noundef, ptr noundef, i32 noundef, ptr noundef) #3

declare void @SDL_Delay(i32 noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define internal void @unpack_argb_int(i32 noundef %0, ptr noundef %1, ptr noundef %2, ptr noundef %3, ptr noundef %4) #0 {
  %6 = alloca i32, align 4
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  %9 = alloca ptr, align 8
  %10 = alloca ptr, align 8
  store i32 %0, ptr %6, align 4
  store ptr %1, ptr %7, align 8
  store ptr %2, ptr %8, align 8
  store ptr %3, ptr %9, align 8
  store ptr %4, ptr %10, align 8
  %11 = load i32, ptr %6, align 4
  %12 = ashr i32 %11, 24
  %13 = and i32 %12, 255
  %14 = load ptr, ptr %10, align 8
  store i32 %13, ptr %14, align 4
  %15 = load i32, ptr %6, align 4
  %16 = ashr i32 %15, 16
  %17 = and i32 %16, 255
  %18 = load ptr, ptr %7, align 8
  store i32 %17, ptr %18, align 4
  %19 = load i32, ptr %6, align 4
  %20 = ashr i32 %19, 8
  %21 = and i32 %20, 255
  %22 = load ptr, ptr %8, align 8
  store i32 %21, ptr %22, align 4
  %23 = load i32, ptr %6, align 4
  %24 = and i32 %23, 255
  %25 = load ptr, ptr %9, align 8
  store i32 %24, ptr %25, align 4
  ret void
}

declare i32 @SDL_SetRenderDrawColor(ptr noundef, i8 noundef zeroext, i8 noundef zeroext, i8 noundef zeroext, i8 noundef zeroext) #1

declare i32 @SDL_RenderClear(ptr noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @simPutPixel(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
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
  %12 = icmp sle i32 0, %11
  br i1 %12, label %13, label %17

13:                                               ; preds = %3
  %14 = load i32, ptr %4, align 4
  %15 = icmp slt i32 %14, 512
  br i1 %15, label %16, label %17

16:                                               ; preds = %13
  br label %17

17:                                               ; preds = %16, %13, %3
  %18 = phi i1 [ false, %13 ], [ false, %3 ], [ true, %16 ]
  %19 = xor i1 %18, true
  %20 = zext i1 %19 to i32
  %21 = sext i32 %20 to i64
  %22 = icmp ne i64 %21, 0
  br i1 %22, label %23, label %25

23:                                               ; preds = %17
  call void @__assert_rtn(ptr noundef @__func__.simPutPixel, ptr noundef @.str.3, i32 noundef 68, ptr noundef @.str.6) #5
  unreachable

24:                                               ; No predecessors!
  br label %26

25:                                               ; preds = %17
  br label %26

26:                                               ; preds = %25, %24
  %27 = load i32, ptr %5, align 4
  %28 = icmp sle i32 0, %27
  br i1 %28, label %29, label %33

29:                                               ; preds = %26
  %30 = load i32, ptr %5, align 4
  %31 = icmp slt i32 %30, 512
  br i1 %31, label %32, label %33

32:                                               ; preds = %29
  br label %33

33:                                               ; preds = %32, %29, %26
  %34 = phi i1 [ false, %29 ], [ false, %26 ], [ true, %32 ]
  %35 = xor i1 %34, true
  %36 = zext i1 %35 to i32
  %37 = sext i32 %36 to i64
  %38 = icmp ne i64 %37, 0
  br i1 %38, label %39, label %41

39:                                               ; preds = %33
  call void @__assert_rtn(ptr noundef @__func__.simPutPixel, ptr noundef @.str.3, i32 noundef 69, ptr noundef @.str.7) #5
  unreachable

40:                                               ; No predecessors!
  br label %42

41:                                               ; preds = %33
  br label %42

42:                                               ; preds = %41, %40
  %43 = load i32, ptr %6, align 4
  call void @unpack_argb_int(i32 noundef %43, ptr noundef %7, ptr noundef %8, ptr noundef %9, ptr noundef %10)
  %44 = load ptr, ptr @Renderer, align 8
  %45 = load i32, ptr %7, align 4
  %46 = trunc i32 %45 to i8
  %47 = load i32, ptr %8, align 4
  %48 = trunc i32 %47 to i8
  %49 = load i32, ptr %9, align 4
  %50 = trunc i32 %49 to i8
  %51 = load i32, ptr %10, align 4
  %52 = trunc i32 %51 to i8
  %53 = call i32 @SDL_SetRenderDrawColor(ptr noundef %44, i8 noundef zeroext %46, i8 noundef zeroext %48, i8 noundef zeroext %50, i8 noundef zeroext %52)
  %54 = load ptr, ptr @Renderer, align 8
  %55 = load i32, ptr %4, align 4
  %56 = load i32, ptr %5, align 4
  %57 = call i32 @SDL_RenderDrawPoint(ptr noundef %54, i32 noundef %55, i32 noundef %56)
  %58 = call i32 @SDL_GetTicks()
  store i32 %58, ptr @Ticks, align 4
  ret void
}

declare i32 @SDL_RenderDrawPoint(ptr noundef, i32 noundef, i32 noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define void @simFillRect(i32 noundef %0, i32 noundef %1, i32 noundef %2, i32 noundef %3, i32 noundef %4) #0 {
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca %struct.SDL_Rect, align 4
  store i32 %0, ptr %6, align 4
  store i32 %1, ptr %7, align 4
  store i32 %2, ptr %8, align 4
  store i32 %3, ptr %9, align 4
  store i32 %4, ptr %10, align 4
  %16 = load i32, ptr %8, align 4
  %17 = icmp sle i32 %16, 0
  br i1 %17, label %21, label %18

18:                                               ; preds = %5
  %19 = load i32, ptr %9, align 4
  %20 = icmp sle i32 %19, 0
  br i1 %20, label %21, label %22

21:                                               ; preds = %18, %5
  br label %62

22:                                               ; preds = %18
  %23 = load i32, ptr %6, align 4
  %24 = icmp sge i32 %23, 512
  br i1 %24, label %28, label %25

25:                                               ; preds = %22
  %26 = load i32, ptr %7, align 4
  %27 = icmp sge i32 %26, 512
  br i1 %27, label %28, label %29

28:                                               ; preds = %25, %22
  br label %62

29:                                               ; preds = %25
  %30 = load i32, ptr %6, align 4
  %31 = load i32, ptr %8, align 4
  %32 = add nsw i32 %30, %31
  %33 = icmp sle i32 %32, 0
  br i1 %33, label %39, label %34

34:                                               ; preds = %29
  %35 = load i32, ptr %7, align 4
  %36 = load i32, ptr %9, align 4
  %37 = add nsw i32 %35, %36
  %38 = icmp sle i32 %37, 0
  br i1 %38, label %39, label %40

39:                                               ; preds = %34, %29
  br label %62

40:                                               ; preds = %34
  %41 = load i32, ptr %10, align 4
  call void @unpack_argb_int(i32 noundef %41, ptr noundef %11, ptr noundef %12, ptr noundef %13, ptr noundef %14)
  %42 = load ptr, ptr @Renderer, align 8
  %43 = load i32, ptr %11, align 4
  %44 = trunc i32 %43 to i8
  %45 = load i32, ptr %12, align 4
  %46 = trunc i32 %45 to i8
  %47 = load i32, ptr %13, align 4
  %48 = trunc i32 %47 to i8
  %49 = load i32, ptr %14, align 4
  %50 = trunc i32 %49 to i8
  %51 = call i32 @SDL_SetRenderDrawColor(ptr noundef %42, i8 noundef zeroext %44, i8 noundef zeroext %46, i8 noundef zeroext %48, i8 noundef zeroext %50)
  %52 = getelementptr inbounds %struct.SDL_Rect, ptr %15, i32 0, i32 0
  %53 = load i32, ptr %6, align 4
  store i32 %53, ptr %52, align 4
  %54 = getelementptr inbounds %struct.SDL_Rect, ptr %15, i32 0, i32 1
  %55 = load i32, ptr %7, align 4
  store i32 %55, ptr %54, align 4
  %56 = getelementptr inbounds %struct.SDL_Rect, ptr %15, i32 0, i32 2
  %57 = load i32, ptr %8, align 4
  store i32 %57, ptr %56, align 4
  %58 = getelementptr inbounds %struct.SDL_Rect, ptr %15, i32 0, i32 3
  %59 = load i32, ptr %9, align 4
  store i32 %59, ptr %58, align 4
  %60 = load ptr, ptr @Renderer, align 8
  %61 = call i32 @SDL_RenderFillRect(ptr noundef %60, ptr noundef %15)
  br label %62

62:                                               ; preds = %40, %39, %28, %21
  ret void
}

declare i32 @SDL_RenderFillRect(ptr noundef, ptr noundef) #1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @simRand() #0 {
  %1 = call i32 @rand()
  ret i32 %1
}

declare i32 @rand() #1

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #2 = { noreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { cold noreturn "disable-tail-calls"="true" "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #4 = { noreturn }
attributes #5 = { cold noreturn }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 2]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 16.0.0 (clang-1600.0.26.6)"}
