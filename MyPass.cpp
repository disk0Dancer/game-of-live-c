#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/IR/Instructions.h"
using namespace llvm;

struct InstrumentationPass : public PassInfoMixin<InstrumentationPass> {

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM) {
    outs() << "[Pass] Analyzing module: " << M.getName() << "\n";
    
    for (auto &F : M) {
      if (isGameOfLifeFunction(F.getName())) {
        outs() << "  Found function: " << F.getName() << "\n";
        addInstrumentation(F, M);
      }
    }
    
    return PreservedAnalyses::none();
  }

private:
  
  bool isGameOfLifeFunction(StringRef name) {
    return name == "step_generation" || name == "neighbors" || 
           name == "randomize" || name == "idx" || name == "wrap" ||
           name == "clear_all" || name == "draw_frame" || name == "app";
  }

  void addInstrumentation(Function &func, Module &module) {
    if (func.isDeclaration()) {
      outs() << "    Skipping declaration: " << func.getName() << "\n";
      return;
    }

    outs() << "  Instrumenting function: " << func.getName() << "\n";
    
    LLVMContext &ctx = func.getContext();
    IRBuilder<> builder(ctx);
    
    Type *voidType = Type::getVoidTy(ctx);
    Type *stringType = PointerType::get(ctx, 0);
    Type *addrType = Type::getInt64Ty(ctx);
    
    FunctionType *execLogType = FunctionType::get(voidType, {stringType, addrType}, false);
    FunctionCallee execLogger = module.getOrInsertFunction("logExecution", execLogType);
    
    FunctionType *relLogType = FunctionType::get(voidType, {addrType, addrType, stringType, stringType}, false);
    FunctionCallee relLogger = module.getOrInsertFunction("logRelation", relLogType);
    
    std::vector<Instruction*> allInstructions;
    for (auto &bb : func) {
      for (auto &instr : bb) {
        allInstructions.push_back(&instr);
      }
    }
    
    outs() << "    Found " << allInstructions.size() << " instructions\n";

    for (Instruction *instr : allInstructions) {
      if (instr != nullptr) {
        addLoggingToInstruction(*instr, builder, execLogger, relLogger);
      }
    }
  }
  
  void addLoggingToInstruction(Instruction &instr, IRBuilder<> &builder,
                              FunctionCallee &execLogger, FunctionCallee &relLogger) {

    builder.SetInsertPoint(&instr);

    std::string instrName = getName(instr);
    Value *nameString = builder.CreateGlobalString(instrName);
    Value *instrAddr = ConstantInt::get(Type::getInt64Ty(instr.getContext()), 0);

    builder.CreateCall(execLogger, {nameString, instrAddr});

    if (!isa<PHINode>(&instr)) {
      logOperandRelations(instr, builder, relLogger);
    }
  }

  void logOperandRelations(Instruction &user, IRBuilder<> &builder, FunctionCallee &relLogger) {
    for (unsigned i = 0; i < user.getNumOperands(); ++i) {
      Value *operand = user.getOperand(i);

      if (Instruction *operandInstr = dyn_cast<Instruction>(operand)) {
        Value *userAddr = ConstantInt::get(Type::getInt64Ty(user.getContext()), 0);
        Value *operandAddr = ConstantInt::get(Type::getInt64Ty(operandInstr->getContext()), 0);

        std::string userName = getName(user);
        std::string operandName = getName(*operandInstr);

        Value *userNameStr = builder.CreateGlobalString(userName);
        Value *operandNameStr = builder.CreateGlobalString(operandName);
        builder.CreateCall(relLogger, {userAddr, operandAddr, userNameStr, operandNameStr});
      }
    }
  }

  std::string getName(const Instruction &instr) {
    return std::string(instr.getOpcodeName());
  }
};

PassPluginLibraryInfo getPassPluginInfo() {
  const auto callback = [](PassBuilder &PB) {
    PB.registerPipelineStartEPCallback([=](ModulePassManager &MPM, auto) {
      MPM.addPass(InstrumentationPass{});
      return true;
    });
  };

  return {LLVM_PLUGIN_API_VERSION, "MyPass", "1.0", callback};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return getPassPluginInfo();
}
