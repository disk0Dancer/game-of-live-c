#include "../sim_app/sim.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include <fstream>
#include <iostream>
#include <unordered_map>
using namespace llvm;

// Game of Life ASM2IR Generator with Full IR Equivalents
// Each specialized instruction expands to complete LLVM IR

const int REG_FILE_SIZE = 16;
const int GRID_SIZE = 16384;

int main(int argc, char *argv[]) {
  if (argc != 2) {
    outs() << "[ERROR] Need 1 argument: ASM file\n";
    return 1;
  }

  std::ifstream input(argv[1]);
  if (!input.is_open()) {
    outs() << "[ERROR] Can't open " << argv[1] << "\n";
    return 1;
  }

  LLVMContext context;
  Module *module = new Module("game_of_life", context);
  IRBuilder<> builder(context);
  Type *voidType = builder.getVoidTy();
  Type *int32Type = builder.getInt32Ty();
  Type *int8PtrType = builder.getPtrTy();

  ArrayType *regFileType = ArrayType::get(int32Type, REG_FILE_SIZE);
  GlobalVariable *regFile = new GlobalVariable(
      *module, regFileType, false, GlobalValue::PrivateLinkage, 0, "regFile");
  regFile->setInitializer(ConstantAggregateZero::get(regFileType));

  FunctionType *funcType = FunctionType::get(voidType, false);
  Function *mainFunc = Function::Create(funcType, Function::ExternalLinkage, "main", module);
  BasicBlock *entryBB = BasicBlock::Create(context, "entry", mainFunc);
  builder.SetInsertPoint(entryBB);

  std::string name, arg;
  std::unordered_map<std::string, BasicBlock *> BBMap;

  outs() << "\n#[Pass 1: Find Labels]\n";

  while (input >> name) {
    if (name[0] == ';') { input.ignore(1000, '\n'); continue; }
    if (!name.compare("ALLOC_ARRAYS") || !name.compare("MOV")) {
      input >> arg >> arg; continue;
    }
    if (!name.compare("CLEAR_ARRAY") || !name.compare("INC_NEi")) {
      input >> arg >> arg >> arg; continue;
    }
    if (!name.compare("RANDOMIZE_CELL") || !name.compare("GET_CELL") ||
        !name.compare("SET_CELL") || !name.compare("DRAW_CELL_4x4") ||
        !name.compare("COUNT_NEIGHBORS") || !name.compare("GAME_OF_LIFE_RULE")) {
      input >> arg >> arg >> arg >> arg; continue;
    }
    if (!name.compare("SELECT_COLOR")) {
      input >> arg >> arg >> arg >> arg >> arg; continue;
    }
    if (!name.compare("COPY_ARRAY")) {
      input >> arg >> arg >> arg; continue;
    }
    if (!name.compare("BR_COND")) {
      input >> arg >> arg >> arg; continue;
    }
    if (!name.compare("FLUSH") || !name.compare("EXIT")) continue;

    if (name.back() == ':') {
      outs() << "  " << name << "\n";
      BBMap[name] = BasicBlock::Create(context, name, mainFunc);
    }
  }

  input.clear();
  input.seekg(0);

  FunctionType *simPutPixelType = FunctionType::get(voidType, {int32Type, int32Type, int32Type}, false);
  auto simPutPixelFunc = module->getOrInsertFunction("simPutPixel", simPutPixelType);

  FunctionType *simFlushType = FunctionType::get(voidType, false);
  auto simFlushFunc = module->getOrInsertFunction("simFlush", simFlushType);

  FunctionType *simRandType = FunctionType::get(int32Type, false);
  auto simRandFunc = module->getOrInsertFunction("simRand", simRandType);

  // Helper lambdas
  auto getReg = [&](int idx) { return builder.CreateConstGEP2_32(regFileType, regFile, 0, idx); };
  auto loadReg = [&](int idx) { return builder.CreateLoad(int32Type, getReg(idx)); };
  auto storeReg = [&](int idx, Value *val) { builder.CreateStore(val, getReg(idx)); };

  outs() << "\n#[Pass 2: Generate Full IR]\n";

  while (input >> name) {
    if (name[0] == ';') { input.ignore(1000, '\n'); continue; }
    if (!name.compare("EXIT")) {
      builder.CreateRetVoid();
      continue;
    }

    if (!name.compare("ALLOC_ARRAYS")) {
      input >> arg; int r1 = std::stoi(arg.substr(1));
      input >> arg; int r2 = std::stoi(arg.substr(1));
      ArrayType *gridType = ArrayType::get(int32Type, GRID_SIZE);
      Value *cur = builder.CreateAlloca(gridType);
      Value *nxt = builder.CreateAlloca(gridType);
      storeReg(r1, builder.CreatePtrToInt(cur, int32Type));
      storeReg(r2, builder.CreatePtrToInt(nxt, int32Type));
      continue;
    }

    if (!name.compare("CLEAR_ARRAY")) {
      input >> arg; int base = std::stoi(arg.substr(1));
      input >> arg; int size = std::stoi(arg);
      Value *ptr = builder.CreateIntToPtr(loadReg(base), int8PtrType);

      // Call llvm.memset
      FunctionType *memsetType = FunctionType::get(voidType,
          {int8PtrType, builder.getInt8Ty(), builder.getInt64Ty(), builder.getInt1Ty()}, false);
      auto memsetFunc = module->getOrInsertFunction("llvm.memset.p0.i64", memsetType);
      builder.CreateCall(memsetFunc, {ptr, builder.getInt8(0), builder.getInt64(size * 4), builder.getInt1(false)});
      continue;
    }

    if (!name.compare("COPY_ARRAY")) {
      input >> arg; int dst = std::stoi(arg.substr(1));
      input >> arg; int src = std::stoi(arg.substr(1));
      input >> arg; int size = std::stoi(arg);
      Value *dstPtr = builder.CreateIntToPtr(loadReg(dst), int8PtrType);
      Value *srcPtr = builder.CreateIntToPtr(loadReg(src), int8PtrType);

      FunctionType *memcpyType = FunctionType::get(voidType,
          {int8PtrType, int8PtrType, builder.getInt64Ty(), builder.getInt1Ty()}, false);
      auto memcpyFunc = module->getOrInsertFunction("llvm.memcpy.p0.p0.i64", memcpyType);
      builder.CreateCall(memcpyFunc, {dstPtr, srcPtr, builder.getInt64(size * 4), builder.getInt1(false)});
      continue;
    }

    if (!name.compare("GET_CELL")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));

      Value *xVal = loadReg(x);
      Value *yVal = loadReg(y);
      Value *yMul = builder.CreateMul(yVal, builder.getInt32(GRID_W));
      Value *idx = builder.CreateAdd(yMul, xVal);
      Value *arrPtr = builder.CreateIntToPtr(loadReg(arr), builder.getPtrTy());
      Value *cellPtr = builder.CreateGEP(int32Type, arrPtr, idx);
      Value *cellVal = builder.CreateLoad(int32Type, cellPtr);
      storeReg(res, cellVal);
      continue;
    }

    if (!name.compare("SET_CELL")) {
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));
      input >> arg; int val = std::stoi(arg.substr(1));

      Value *xVal = loadReg(x);
      Value *yVal = loadReg(y);
      Value *yMul = builder.CreateMul(yVal, builder.getInt32(GRID_W));
      Value *idx = builder.CreateAdd(yMul, xVal);
      Value *arrPtr = builder.CreateIntToPtr(loadReg(arr), builder.getPtrTy());
      Value *cellPtr = builder.CreateGEP(int32Type, arrPtr, idx);
      builder.CreateStore(loadReg(val), cellPtr);
      continue;
    }

    if (!name.compare("DRAW_CELL_4x4")) {
      input >> arg; int cx = std::stoi(arg.substr(1));
      input >> arg; int cy = std::stoi(arg.substr(1));
      input >> arg; int col = std::stoi(arg.substr(1));

      Value *px = builder.CreateShl(loadReg(cx), 2);
      Value *py = builder.CreateShl(loadReg(cy), 2);
      Value *color = loadReg(col);

      // Unrolled 4x4 loop
      for (int yy = 0; yy < 4; yy++) {
        for (int xx = 0; xx < 4; xx++) {
          Value *pixX = builder.CreateAdd(px, builder.getInt32(xx));
          Value *pixY = builder.CreateAdd(py, builder.getInt32(yy));
          builder.CreateCall(simPutPixelFunc, {pixX, pixY, color});
        }
      }
      continue;
    }

    if (!name.compare("SELECT_COLOR")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int alive = std::stoi(arg.substr(1));
      input >> arg; uint32_t ca = std::stoul(arg, nullptr, 0);
      input >> arg; uint32_t cd = std::stoul(arg, nullptr, 0);

      Value *cmp = builder.CreateICmpNE(loadReg(alive), builder.getInt32(0));
      Value *sel = builder.CreateSelect(cmp, builder.getInt32(ca), builder.getInt32(cd));
      storeReg(res, sel);
      continue;
    }

    if (!name.compare("COUNT_NEIGHBORS")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));

      Value *xVal = loadReg(x);
      Value *yVal = loadReg(y);
      Value *arrPtr = builder.CreateIntToPtr(loadReg(arr), builder.getPtrTy());

      auto wrap = [&](Value *v, int max) {
        Value *mod = builder.CreateSRem(v, builder.getInt32(max));
        Value *cmp = builder.CreateICmpSLT(mod, builder.getInt32(0));
        return builder.CreateSelect(cmp, builder.CreateAdd(mod, builder.getInt32(max)), mod);
      };

      Value *xm = wrap(builder.CreateSub(xVal, builder.getInt32(1)), GRID_W);
      Value *xp = wrap(builder.CreateAdd(xVal, builder.getInt32(1)), GRID_W);
      Value *ym = wrap(builder.CreateSub(yVal, builder.getInt32(1)), GRID_H);
      Value *yp = wrap(builder.CreateAdd(yVal, builder.getInt32(1)), GRID_H);

      auto loadCell = [&](Value *x, Value *y) {
        Value *yMul = builder.CreateMul(y, builder.getInt32(GRID_W));
        Value *idx = builder.CreateAdd(yMul, x);
        Value *ptr = builder.CreateGEP(int32Type, arrPtr, idx);
        return builder.CreateLoad(int32Type, ptr);
      };

      Value *sum = builder.getInt32(0);
      sum = builder.CreateAdd(sum, loadCell(xm, ym));
      sum = builder.CreateAdd(sum, loadCell(xVal, ym));
      sum = builder.CreateAdd(sum, loadCell(xp, ym));
      sum = builder.CreateAdd(sum, loadCell(xm, yVal));
      sum = builder.CreateAdd(sum, loadCell(xp, yVal));
      sum = builder.CreateAdd(sum, loadCell(xm, yp));
      sum = builder.CreateAdd(sum, loadCell(xVal, yp));
      sum = builder.CreateAdd(sum, loadCell(xp, yp));

      storeReg(res, sum);
      continue;
    }

    if (!name.compare("GAME_OF_LIFE_RULE")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int alive = std::stoi(arg.substr(1));
      input >> arg; int neighb = std::stoi(arg.substr(1));

      Value *aliveVal = loadReg(alive);
      Value *neighbVal = loadReg(neighb);

      Value *isAlive = builder.CreateICmpNE(aliveVal, builder.getInt32(0));
      Value *nEq2 = builder.CreateICmpEQ(neighbVal, builder.getInt32(2));
      Value *nEq3 = builder.CreateICmpEQ(neighbVal, builder.getInt32(3));
      Value *aliveRule = builder.CreateOr(nEq2, nEq3);
      Value *resBool = builder.CreateSelect(isAlive, aliveRule, nEq3);
      Value *resInt = builder.CreateZExt(resBool, int32Type);
      storeReg(res, resInt);
      continue;
    }

    if (!name.compare("RANDOMIZE_CELL")) {
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));
      input >> arg; int pm = std::stoi(arg);

      Value *randVal = builder.CreateCall(simRandFunc);
      Value *modVal = builder.CreateSRem(randVal, builder.getInt32(1000));
      Value *cmp = builder.CreateICmpSLT(modVal, builder.getInt32(pm));
      Value *val = builder.CreateZExt(cmp, int32Type);

      Value *xVal = loadReg(x);
      Value *yVal = loadReg(y);
      Value *yMul = builder.CreateMul(yVal, builder.getInt32(GRID_W));
      Value *idx = builder.CreateAdd(yMul, xVal);
      Value *arrPtr = builder.CreateIntToPtr(loadReg(arr), builder.getPtrTy());
      Value *cellPtr = builder.CreateGEP(int32Type, arrPtr, idx);
      builder.CreateStore(val, cellPtr);
      continue;
    }

    if (!name.compare("MOV")) {
      input >> arg; int reg = std::stoi(arg.substr(1));
      input >> arg; int imm = std::stoi(arg);
      storeReg(reg, builder.getInt32(imm));
      continue;
    }

    if (!name.compare("INC_NEi")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int cnt = std::stoi(arg.substr(1));
      input >> arg; int lim = std::stoi(arg);

      Value *old = loadReg(cnt);
      Value *newVal = builder.CreateAdd(old, builder.getInt32(1));
      storeReg(cnt, newVal);
      Value *cmp = builder.CreateICmpNE(newVal, builder.getInt32(lim));
      storeReg(res, builder.CreateZExt(cmp, int32Type));
      continue;
    }

    if (!name.compare("FLUSH")) {
      builder.CreateCall(simFlushFunc);
      continue;
    }

    if (!name.compare("BR_COND")) {
      input >> arg; int reg = std::stoi(arg.substr(1));
      input >> arg; std::string lt = arg + ":";
      input >> arg; std::string lf = arg + ":";

      Value *cond = builder.CreateTrunc(loadReg(reg), builder.getInt1Ty());
      if (BBMap.find(lt) != BBMap.end() && BBMap.find(lf) != BBMap.end()) {
        builder.CreateCondBr(cond, BBMap[lt], BBMap[lf]);
      }
      continue;
    }

    if (BBMap.find(name) != BBMap.end()) {
      if (builder.GetInsertBlock() && !builder.GetInsertBlock()->getTerminator()) {
        builder.CreateBr(BBMap[name]);
      }
      builder.SetInsertPoint(BBMap[name]);
    }
  }

  outs() << "\n#[LLVM IR]\n";
  module->print(outs(), nullptr);

  outs() << "\n#[Verification]\n";
  bool verif = verifyFunction(*mainFunc, &outs());
  outs() << (verif ? "FAILED\n" : "OK\n");

  outs() << "\n#[JIT Execution]\n";
  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(module)).create();
  ee->InstallLazyFunctionCreator([](const std::string &fn) -> void * {
    if (fn == "simPutPixel") return reinterpret_cast<void *>(simPutPixel);
    if (fn == "simFlush") return reinterpret_cast<void *>(simFlush);
    if (fn == "simRand") return reinterpret_cast<void *>(simRand);
    return nullptr;
  });

  uint32_t REG_FILE[REG_FILE_SIZE] = {0};
  ee->addGlobalMapping(regFile, (void *)REG_FILE);
  ee->finalizeObject();

  simInit();
  ArrayRef<GenericValue> noargs;
  ee->runFunction(mainFunc, noargs);
  outs() << "\n#[Done]\n";

  simExit();
  return 0;
}

