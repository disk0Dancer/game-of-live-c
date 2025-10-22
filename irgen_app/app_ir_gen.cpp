#include "../sim_app/sim.h"

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

int main() {
  LLVMContext context;
  Module *module = new Module("app.c", context);
  IRBuilder<> builder(context);

  // Declare external functions
  Type *voidType = Type::getVoidTy(context);
  Type *int32Type = Type::getInt32Ty(context);

  // declare void @simPutPixel(i32, i32, i32)
  std::vector<Type *> simPutPixelParamTypesVec = {int32Type, int32Type, int32Type};
  ArrayRef<Type *> simPutPixelParamTypes(simPutPixelParamTypesVec);
  FunctionType *simPutPixelType =
      FunctionType::get(voidType, simPutPixelParamTypes, false);
  FunctionCallee simPutPixelFunc =
      module->getOrInsertFunction("simPutPixel", simPutPixelType);

  // declare void @simFlush()
  FunctionType *simFlushType = FunctionType::get(voidType, false);
  FunctionCallee simFlushFunc =
      module->getOrInsertFunction("simFlush", simFlushType);

  // declare i32 @simRand()
  FunctionType *simRandType = FunctionType::get(int32Type, false);
  FunctionCallee simRandFunc =
      module->getOrInsertFunction("simRand", simRandType);

  // define void @app()
  FunctionType *appFuncType = FunctionType::get(voidType, false);
  Function *appFunc =
      Function::Create(appFuncType, Function::ExternalLinkage, "app", module);

  // Create basic blocks
  BasicBlock *entryBB = BasicBlock::Create(context, "entry", appFunc);
  BasicBlock *loopFrameBB = BasicBlock::Create(context, "loop.frame", appFunc);
  BasicBlock *loopFrameBodyBB =
      BasicBlock::Create(context, "loop.frame.body", appFunc);
  BasicBlock *loopYBB = BasicBlock::Create(context, "loop.y", appFunc);
  BasicBlock *loopYBodyBB = BasicBlock::Create(context, "loop.y.body", appFunc);
  BasicBlock *loopXBB = BasicBlock::Create(context, "loop.x", appFunc);
  BasicBlock *loopXBodyBB = BasicBlock::Create(context, "loop.x.body", appFunc);
  BasicBlock *loopXEndBB = BasicBlock::Create(context, "loop.x.end", appFunc);
  BasicBlock *loopYEndBB = BasicBlock::Create(context, "loop.y.end", appFunc);
  BasicBlock *loopFrameEndBB =
      BasicBlock::Create(context, "loop.frame.end", appFunc);
  BasicBlock *exitBB = BasicBlock::Create(context, "exit", appFunc);

  // Entry block
  builder.SetInsertPoint(entryBB);
  builder.CreateBr(loopFrameBB);

  // Frame loop header: for (frame = 0; frame < 500; frame++)
  builder.SetInsertPoint(loopFrameBB);
  PHINode *framePHI = builder.CreatePHI(int32Type, 2, "frame");
  framePHI->addIncoming(builder.getInt32(0), entryBB);
  Value *frameCmp = builder.CreateICmpSLT(framePHI, builder.getInt32(500));
  builder.CreateCondBr(frameCmp, loopFrameBodyBB, exitBB);

  // Frame loop body
  builder.SetInsertPoint(loopFrameBodyBB);
  builder.CreateBr(loopYBB);

  // Y loop header: for (y = 0; y < GRID_H; y++)
  builder.SetInsertPoint(loopYBB);
  PHINode *yPHI = builder.CreatePHI(int32Type, 2, "y");
  yPHI->addIncoming(builder.getInt32(0), loopFrameBodyBB);
  Value *yCmp = builder.CreateICmpSLT(yPHI, builder.getInt32(GRID_H));
  builder.CreateCondBr(yCmp, loopYBodyBB, loopYEndBB);

  // Y loop body
  builder.SetInsertPoint(loopYBodyBB);
  builder.CreateBr(loopXBB);

  // X loop header: for (x = 0; x < GRID_W; x++)
  builder.SetInsertPoint(loopXBB);
  PHINode *xPHI = builder.CreatePHI(int32Type, 2, "x");
  xPHI->addIncoming(builder.getInt32(0), loopYBodyBB);
  Value *xCmp = builder.CreateICmpSLT(xPHI, builder.getInt32(GRID_W));
  builder.CreateCondBr(xCmp, loopXBodyBB, loopXEndBB);

  // X loop body - draw pixel with pattern
  builder.SetInsertPoint(loopXBodyBB);

  // Calculate pixel position (x * CELL_SIZE, y * CELL_SIZE)
  Value *pixelX = builder.CreateMul(xPHI, builder.getInt32(CELL_SIZE));
  Value *pixelY = builder.CreateMul(yPHI, builder.getInt32(CELL_SIZE));

  // Calculate color based on position and frame
  // color = (x ^ y ^ frame) & 0xFF
  Value *xorXY = builder.CreateXor(xPHI, yPHI);
  Value *xorAll = builder.CreateXor(xorXY, framePHI);
  Value *colorComponent = builder.CreateAnd(xorAll, builder.getInt32(0xFF));

  // Create RGB color: 0xFF000000 | (r << 16) | (g << 8) | b
  Value *r = builder.CreateShl(colorComponent, builder.getInt32(16));
  Value *g = builder.CreateShl(colorComponent, builder.getInt32(8));
  Value *b = colorComponent;
  Value *color = builder.getInt32(0xFF000000); // Alpha channel
  color = builder.CreateOr(color, r);
  color = builder.CreateOr(color, g);
  color = builder.CreateOr(color, b);

  // Draw a cell (CELL_SIZE x CELL_SIZE rectangle)
  // Create nested loops for cell drawing
  BasicBlock *cellLoopYBB = BasicBlock::Create(context, "cell.loop.y", appFunc);
  BasicBlock *cellLoopYBodyBB =
      BasicBlock::Create(context, "cell.loop.y.body", appFunc);
  BasicBlock *cellLoopXBB = BasicBlock::Create(context, "cell.loop.x", appFunc);
  BasicBlock *cellLoopXBodyBB =
      BasicBlock::Create(context, "cell.loop.x.body", appFunc);
  BasicBlock *cellLoopXEndBB =
      BasicBlock::Create(context, "cell.loop.x.end", appFunc);
  BasicBlock *cellLoopYEndBB =
      BasicBlock::Create(context, "cell.loop.y.end", appFunc);

  builder.CreateBr(cellLoopYBB);

  // Cell Y loop
  builder.SetInsertPoint(cellLoopYBB);
  PHINode *cellYPHI = builder.CreatePHI(int32Type, 2, "cell.y");
  cellYPHI->addIncoming(builder.getInt32(0), loopXBodyBB);
  Value *cellYCmp =
      builder.CreateICmpSLT(cellYPHI, builder.getInt32(CELL_SIZE));
  builder.CreateCondBr(cellYCmp, cellLoopYBodyBB, cellLoopYEndBB);

  builder.SetInsertPoint(cellLoopYBodyBB);
  builder.CreateBr(cellLoopXBB);

  // Cell X loop
  builder.SetInsertPoint(cellLoopXBB);
  PHINode *cellXPHI = builder.CreatePHI(int32Type, 2, "cell.x");
  cellXPHI->addIncoming(builder.getInt32(0), cellLoopYBodyBB);
  Value *cellXCmp =
      builder.CreateICmpSLT(cellXPHI, builder.getInt32(CELL_SIZE));
  builder.CreateCondBr(cellXCmp, cellLoopXBodyBB, cellLoopXEndBB);

  // Draw single pixel
  builder.SetInsertPoint(cellLoopXBodyBB);
  Value *finalX = builder.CreateAdd(pixelX, cellXPHI);
  Value *finalY = builder.CreateAdd(pixelY, cellYPHI);
  Value *putPixelArgs[] = {finalX, finalY, color};
  builder.CreateCall(simPutPixelFunc, putPixelArgs);

  Value *cellXNext = builder.CreateAdd(cellXPHI, builder.getInt32(1));
  cellXPHI->addIncoming(cellXNext, cellLoopXBodyBB);
  builder.CreateBr(cellLoopXBB);

  // Cell X loop end
  builder.SetInsertPoint(cellLoopXEndBB);
  Value *cellYNext = builder.CreateAdd(cellYPHI, builder.getInt32(1));
  cellYPHI->addIncoming(cellYNext, cellLoopXEndBB);
  builder.CreateBr(cellLoopYBB);

  // Cell Y loop end
  builder.SetInsertPoint(cellLoopYEndBB);
  Value *xNext = builder.CreateAdd(xPHI, builder.getInt32(1));
  xPHI->addIncoming(xNext, cellLoopYEndBB);
  builder.CreateBr(loopXBB);

  // X loop end
  builder.SetInsertPoint(loopXEndBB);
  Value *yNext = builder.CreateAdd(yPHI, builder.getInt32(1));
  yPHI->addIncoming(yNext, loopXEndBB);
  builder.CreateBr(loopYBB);

  // Y loop end - flush frame
  builder.SetInsertPoint(loopYEndBB);
  builder.CreateCall(simFlushFunc);
  builder.CreateBr(loopFrameEndBB);

  // Frame loop end
  builder.SetInsertPoint(loopFrameEndBB);
  Value *frameNext = builder.CreateAdd(framePHI, builder.getInt32(1));
  framePHI->addIncoming(frameNext, loopFrameEndBB);
  builder.CreateBr(loopFrameBB);

  // Exit
  builder.SetInsertPoint(exitBB);
  builder.CreateRetVoid();

  // Dump LLVM IR
  module->print(outs(), nullptr);
  outs() << "\n";
  bool verif = verifyFunction(*appFunc, &outs());
  outs() << "[VERIFICATION] " << (!verif ? "OK\n\n" : "FAIL\n\n");

  // LLVM IR Interpreter with ExecutionEngine
  outs() << "[EE] Run\n";
  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(module)).create();
  ee->InstallLazyFunctionCreator([=](const std::string &fnName) -> void * {
    if (fnName == "simPutPixel") {
      return reinterpret_cast<void *>(simPutPixel);
    }
    if (fnName == "simFlush") {
      return reinterpret_cast<void *>(simFlush);
    }
    if (fnName == "simRand") {
      return reinterpret_cast<void *>(simRand);
    }
    return nullptr;
  });
  ee->finalizeObject();

  simInit();

  ArrayRef<GenericValue> noargs;
  GenericValue v = ee->runFunction(appFunc, noargs);
  outs() << "[EE] Result: " << v.IntVal << "\n";

  simExit();
  return EXIT_SUCCESS;
}
