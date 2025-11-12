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
#include <cstring>
using namespace llvm;

// Game of Life ASM2IR Generator with Emulating Functions
// Specialized instructions based on hot loop analysis

const int REG_FILE_SIZE = 16;
const int GOL_GRID_SIZE = 16384;
const int GOL_GRID_W = 128;
const int GOL_GRID_H = 128;

uint32_t REG_FILE[REG_FILE_SIZE];
uint32_t *CUR_ARRAY = nullptr;
uint32_t *NXT_ARRAY = nullptr;

// emulation funcs

void do_ALLOC_ARRAYS(int reg1, int reg2) {
  if (CUR_ARRAY) delete[] CUR_ARRAY;
  if (NXT_ARRAY) delete[] NXT_ARRAY;
  CUR_ARRAY = new uint32_t[GOL_GRID_SIZE];
  NXT_ARRAY = new uint32_t[GOL_GRID_SIZE];
  REG_FILE[reg1] = reinterpret_cast<uintptr_t>(CUR_ARRAY);
  REG_FILE[reg2] = reinterpret_cast<uintptr_t>(NXT_ARRAY);
}

void do_CLEAR_ARRAY(int base_reg, int size) {
  uint32_t *arr = reinterpret_cast<uint32_t*>(REG_FILE[base_reg]);
  memset(arr, 0, size * sizeof(uint32_t));
}

void do_COPY_ARRAY(int dst_reg, int src_reg, int size) {
  uint32_t *dst = reinterpret_cast<uint32_t*>(REG_FILE[dst_reg]);
  uint32_t *src = reinterpret_cast<uint32_t*>(REG_FILE[src_reg]);
  memcpy(dst, src, size * sizeof(uint32_t));
}

void do_GET_CELL(int result_reg, int array_reg, int x_reg, int y_reg) {
  uint32_t *arr = reinterpret_cast<uint32_t*>(REG_FILE[array_reg]);
  int x = REG_FILE[x_reg];
  int y = REG_FILE[y_reg];
  int idx = y * GOL_GRID_W + x;
  REG_FILE[result_reg] = arr[idx];
}

void do_SET_CELL(int array_reg, int x_reg, int y_reg, int value_reg) {
  uint32_t *arr = reinterpret_cast<uint32_t*>(REG_FILE[array_reg]);
  int x = REG_FILE[x_reg];
  int y = REG_FILE[y_reg];
  int idx = y * GOL_GRID_W + x;
  arr[idx] = REG_FILE[value_reg];
}

void do_DRAW_CELL_4x4(int cx_reg, int cy_reg, int color_reg) {
  int cx = REG_FILE[cx_reg];
  int cy = REG_FILE[cy_reg];
  uint32_t color = REG_FILE[color_reg];
  int px = cx * CELL_SIZE;
  int py = cy * CELL_SIZE;
  for (int yy = 0; yy < CELL_SIZE; ++yy) {
    for (int xx = 0; xx < CELL_SIZE; ++xx) {
      simPutPixel(px + xx, py + yy, color);
    }
  }
}

void do_SELECT_COLOR(int result_reg, int alive_reg, int color_alive, int color_dead) {
  REG_FILE[result_reg] = REG_FILE[alive_reg] ? color_alive : color_dead;
}

void do_FLUSH() {
  simFlush();
}

void do_COUNT_NEIGHBORS(int result_reg, int array_reg, int x_reg, int y_reg) {
  uint32_t *arr = reinterpret_cast<uint32_t*>(REG_FILE[array_reg]);
  int x = REG_FILE[x_reg];
  int y = REG_FILE[y_reg];
  int xm = (x - 1 + GOL_GRID_W) % GOL_GRID_W;
  int xp = (x + 1) % GOL_GRID_W;
  int ym = (y - 1 + GOL_GRID_H) % GOL_GRID_H;
  int yp = (y + 1) % GOL_GRID_H;
  int count = 0;
  count += arr[ym * GOL_GRID_W + xm];
  count += arr[ym * GOL_GRID_W + x];
  count += arr[ym * GOL_GRID_W + xp];
  count += arr[y * GOL_GRID_W + xm];
  count += arr[y * GOL_GRID_W + xp];
  count += arr[yp * GOL_GRID_W + xm];
  count += arr[yp * GOL_GRID_W + x];
  count += arr[yp * GOL_GRID_W + xp];
  REG_FILE[result_reg] = count;
}

void do_GAME_OF_LIFE_RULE(int result_reg, int alive_reg, int neighbors_reg) {
  int alive = REG_FILE[alive_reg];
  int neighbors = REG_FILE[neighbors_reg];
  int next_alive = 0;
  if (alive) {
    next_alive = (neighbors == 2 || neighbors == 3) ? 1 : 0;
  } else {
    next_alive = (neighbors == 3) ? 1 : 0;
  }
  REG_FILE[result_reg] = next_alive;
}

void do_RANDOMIZE_CELL(int array_reg, int x_reg, int y_reg, int permill) {
  uint32_t *arr = reinterpret_cast<uint32_t*>(REG_FILE[array_reg]);
  int x = REG_FILE[x_reg];
  int y = REG_FILE[y_reg];
  int idx = y * GOL_GRID_W + x;
  int rand_val = simRand() % 1000;
  arr[idx] = (rand_val < permill) ? 1 : 0;
}

void do_MOV(int reg, int imm) {
  REG_FILE[reg] = imm;
}

void do_INC_NEi(int result_reg, int counter_reg, int limit) {
  REG_FILE[counter_reg]++;
  REG_FILE[result_reg] = (REG_FILE[counter_reg] != limit) ? 1 : 0;
}

// asm 2 ir

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

  ArrayType *regFileType = ArrayType::get(builder.getInt32Ty(), REG_FILE_SIZE);
  GlobalVariable *regFile = new GlobalVariable(
      *module, regFileType, false, GlobalValue::PrivateLinkage, 0, "regFile");
  regFile->setInitializer(ConstantAggregateZero::get(regFileType));

  FunctionType *funcType = FunctionType::get(builder.getVoidTy(), false);
  Function *mainFunc = Function::Create(funcType, Function::ExternalLinkage, "main", module);

  std::string name, arg;
  std::unordered_map<std::string, BasicBlock *> BBMap;

  outs() << "\n#[Pass 1: Find Labels]\n";

  // find labels
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

  // register function types
  Type *voidType = builder.getVoidTy();
  Type *int32Type = builder.getInt32Ty();

  Type *i32x2Types[] = {int32Type, int32Type};
  Type *i32x3Types[] = {int32Type, int32Type, int32Type};
  Type *i32x4Types[] = {int32Type, int32Type, int32Type, int32Type};

  FunctionType *voidFT = FunctionType::get(voidType, false);
  FunctionType *i32x2FT = FunctionType::get(voidType, ArrayRef<Type*>(i32x2Types, 2), false);
  FunctionType *i32x3FT = FunctionType::get(voidType, ArrayRef<Type*>(i32x3Types, 3), false);
  FunctionType *i32x4FT = FunctionType::get(voidType, ArrayRef<Type*>(i32x4Types, 4), false);

  // declare emulation functions
  auto allocFunc = module->getOrInsertFunction("do_ALLOC_ARRAYS", i32x2FT);
  auto clearFunc = module->getOrInsertFunction("do_CLEAR_ARRAY", i32x2FT);
  auto copyFunc = module->getOrInsertFunction("do_COPY_ARRAY", i32x3FT);
  auto getCellFunc = module->getOrInsertFunction("do_GET_CELL", i32x4FT);
  auto setCellFunc = module->getOrInsertFunction("do_SET_CELL", i32x4FT);
  auto drawFunc = module->getOrInsertFunction("do_DRAW_CELL_4x4", i32x3FT);
  auto selectFunc = module->getOrInsertFunction("do_SELECT_COLOR", i32x4FT);
  auto flushFunc = module->getOrInsertFunction("do_FLUSH", voidFT);
  auto countFunc = module->getOrInsertFunction("do_COUNT_NEIGHBORS", i32x4FT);
  auto ruleFunc = module->getOrInsertFunction("do_GAME_OF_LIFE_RULE", i32x3FT);
  auto randFunc = module->getOrInsertFunction("do_RANDOMIZE_CELL", i32x4FT);
  auto movFunc = module->getOrInsertFunction("do_MOV", i32x2FT);
  auto incFunc = module->getOrInsertFunction("do_INC_NEi", i32x3FT);

  outs() << "\n#[Pass 2: Generate IR]\n";

  // ir
  while (input >> name) {
    if (name[0] == ';') { input.ignore(1000, '\n'); continue; }
    if (!name.compare("EXIT")) {
      builder.CreateRetVoid();
      continue;
    }
    if (!name.compare("ALLOC_ARRAYS")) {
      input >> arg; int r1 = std::stoi(arg.substr(1));
      input >> arg; int r2 = std::stoi(arg.substr(1));
      builder.CreateCall(allocFunc, {builder.getInt32(r1), builder.getInt32(r2)});
      continue;
    }
    if (!name.compare("CLEAR_ARRAY")) {
      input >> arg; int base = std::stoi(arg.substr(1));
      input >> arg; int size = std::stoi(arg);
      builder.CreateCall(clearFunc, {builder.getInt32(base), builder.getInt32(size)});
      continue;
    }
    if (!name.compare("COPY_ARRAY")) {
      input >> arg; int dst = std::stoi(arg.substr(1));
      input >> arg; int src = std::stoi(arg.substr(1));
      input >> arg; int size = std::stoi(arg);
      builder.CreateCall(copyFunc, {builder.getInt32(dst), builder.getInt32(src), builder.getInt32(size)});
      continue;
    }
    if (!name.compare("GET_CELL")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));
      builder.CreateCall(getCellFunc, {builder.getInt32(res), builder.getInt32(arr), builder.getInt32(x), builder.getInt32(y)});
      continue;
    }
    if (!name.compare("SET_CELL")) {
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));
      input >> arg; int val = std::stoi(arg.substr(1));
      builder.CreateCall(setCellFunc, {builder.getInt32(arr), builder.getInt32(x), builder.getInt32(y), builder.getInt32(val)});
      continue;
    }
    if (!name.compare("DRAW_CELL_4x4")) {
      input >> arg; int cx = std::stoi(arg.substr(1));
      input >> arg; int cy = std::stoi(arg.substr(1));
      input >> arg; int col = std::stoi(arg.substr(1));
      builder.CreateCall(drawFunc, {builder.getInt32(cx), builder.getInt32(cy), builder.getInt32(col)});
      continue;
    }
    if (!name.compare("SELECT_COLOR")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int alive = std::stoi(arg.substr(1));
      input >> arg; uint32_t ca = std::stoul(arg, nullptr, 0);
      input >> arg; uint32_t cd = std::stoul(arg, nullptr, 0);
      builder.CreateCall(selectFunc, {builder.getInt32(res), builder.getInt32(alive), builder.getInt32(ca), builder.getInt32(cd)});
      continue;
    }
    if (!name.compare("COUNT_NEIGHBORS")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));
      builder.CreateCall(countFunc, {builder.getInt32(res), builder.getInt32(arr), builder.getInt32(x), builder.getInt32(y)});
      continue;
    }
    if (!name.compare("GAME_OF_LIFE_RULE")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int alive = std::stoi(arg.substr(1));
      input >> arg; int neighb = std::stoi(arg.substr(1));
      builder.CreateCall(ruleFunc, {builder.getInt32(res), builder.getInt32(alive), builder.getInt32(neighb)});
      continue;
    }
    if (!name.compare("RANDOMIZE_CELL")) {
      input >> arg; int arr = std::stoi(arg.substr(1));
      input >> arg; int x = std::stoi(arg.substr(1));
      input >> arg; int y = std::stoi(arg.substr(1));
      input >> arg; int pm = std::stoi(arg);
      builder.CreateCall(randFunc, {builder.getInt32(arr), builder.getInt32(x), builder.getInt32(y), builder.getInt32(pm)});
      continue;
    }
    if (!name.compare("MOV")) {
      input >> arg; int reg = std::stoi(arg.substr(1));
      input >> arg; int imm = std::stoi(arg);
      builder.CreateCall(movFunc, {builder.getInt32(reg), builder.getInt32(imm)});
      continue;
    }
    if (!name.compare("INC_NEi")) {
      input >> arg; int res = std::stoi(arg.substr(1));
      input >> arg; int cnt = std::stoi(arg.substr(1));
      input >> arg; int lim = std::stoi(arg);
      builder.CreateCall(incFunc, {builder.getInt32(res), builder.getInt32(cnt), builder.getInt32(lim)});
      continue;
    }
    if (!name.compare("FLUSH")) {
      builder.CreateCall(flushFunc);
      continue;
    }
    if (!name.compare("BR_COND")) {
      input >> arg; int reg = std::stoi(arg.substr(1));
      input >> arg; std::string lt = arg + ":";
      input >> arg; std::string lf = arg + ":";
      Value *rp = builder.CreateConstGEP2_32(regFileType, regFile, 0, reg);
      Value *rv = builder.CreateLoad(int32Type, rp);
      Value *cond = builder.CreateTrunc(rv, builder.getInt1Ty());
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

  outs() << "\n#[Verification]\n";
  bool verif = verifyModule(*module, &outs());
  outs() << (verif ? "FAILED\n" : "OK\n");
  if (verif) { outs() << "Module verification failed, exiting\n"; return 1; }

  outs() << "\n#[JIT Execution]\n";
  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  ExecutionEngine *ee = EngineBuilder(std::unique_ptr<Module>(module)).create();
  if (!ee) { outs() << "Failed to create ExecutionEngine\n"; return 1; }
  ee->InstallLazyFunctionCreator([](const std::string &fn) -> void * {
    if (fn == "_do_ALLOC_ARRAYS" || fn == "do_ALLOC_ARRAYS") return reinterpret_cast<void *>(do_ALLOC_ARRAYS);
    if (fn == "_do_CLEAR_ARRAY" || fn == "do_CLEAR_ARRAY") return reinterpret_cast<void *>(do_CLEAR_ARRAY);
    if (fn == "_do_COPY_ARRAY" || fn == "do_COPY_ARRAY") return reinterpret_cast<void *>(do_COPY_ARRAY);
    if (fn == "_do_GET_CELL" || fn == "do_GET_CELL") return reinterpret_cast<void *>(do_GET_CELL);
    if (fn == "_do_SET_CELL" || fn == "do_SET_CELL") return reinterpret_cast<void *>(do_SET_CELL);
    if (fn == "_do_DRAW_CELL_4x4" || fn == "do_DRAW_CELL_4x4") return reinterpret_cast<void *>(do_DRAW_CELL_4x4);
    if (fn == "_do_SELECT_COLOR" || fn == "do_SELECT_COLOR") return reinterpret_cast<void *>(do_SELECT_COLOR);
    if (fn == "_do_FLUSH" || fn == "do_FLUSH") return reinterpret_cast<void *>(do_FLUSH);
    if (fn == "_do_COUNT_NEIGHBORS" || fn == "do_COUNT_NEIGHBORS") return reinterpret_cast<void *>(do_COUNT_NEIGHBORS);
    if (fn == "_do_GAME_OF_LIFE_RULE" || fn == "do_GAME_OF_LIFE_RULE") return reinterpret_cast<void *>(do_GAME_OF_LIFE_RULE);
    if (fn == "_do_RANDOMIZE_CELL" || fn == "do_RANDOMIZE_CELL") return reinterpret_cast<void *>(do_RANDOMIZE_CELL);
    if (fn == "_do_MOV" || fn == "do_MOV") return reinterpret_cast<void *>(do_MOV);
    if (fn == "_do_INC_NEi" || fn == "do_INC_NEi") return reinterpret_cast<void *>(do_INC_NEi);
    if (fn == "_simPutPixel" || fn == "simPutPixel") return reinterpret_cast<void *>(simPutPixel);
    if (fn == "_simFlush" || fn == "simFlush") return reinterpret_cast<void *>(simFlush);
    if (fn == "_simRand" || fn == "simRand") return reinterpret_cast<void *>(simRand);
    return nullptr;
  });

  ee->addGlobalMapping(regFile, (void *)REG_FILE);
  ee->finalizeObject();

  simInit();
  ArrayRef<GenericValue> noargs;
  ee->runFunction(mainFunc, noargs);
  outs() << "\n#[Done]\n";

  if (CUR_ARRAY) delete[] CUR_ARRAY;
  if (NXT_ARRAY) delete[] NXT_ARRAY;
  simExit();
  return 0;
}
