#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
using namespace llvm;

struct InstrumentationPass : public PassInfoMixin<InstrumentationPass> {
  bool isAppFunction(StringRef name) {
    return name == "step_generation" || name == "neighbors" ||
           name == "randomize" || name == "idx" || name == "wrap" ||
           name == "clear_all" || name == "draw_frame" || name == "draw_cell" || name == "app";
  }

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM) {
    outs() << "[Pass] Analyzing module: " << M.getName() << "\n";

    for (auto &F : M) {
      if (!isAppFunction(F.getName()) || F.isDeclaration()) {
        continue;
      }

      outs() << "  [Function] " << F.getName() << " (arg_size: " << F.arg_size() << ")\n";

      LLVMContext &Ctx = F.getContext();
      IRBuilder<> builder(Ctx);
      Type *retType = Type::getVoidTy(Ctx);
      Type *int8PtrTy = PointerType::get(Type::getInt8Ty(Ctx), 0);
      Type *int64Ty = Type::getInt64Ty(Ctx);

      ArrayRef<Type *> execParamTypes = {int8PtrTy, int64Ty};
      FunctionType *execLogType = FunctionType::get(retType, execParamTypes, false);
      FunctionCallee execLogger = M.getOrInsertFunction("logExecution", execLogType);

      ArrayRef<Type *> relParamTypes = {int64Ty, int64Ty, int8PtrTy, int8PtrTy};
      FunctionType *relLogType = FunctionType::get(retType, relParamTypes, false);
      FunctionCallee relLogger = M.getOrInsertFunction("logRelation", relLogType);

      int instrCount = 0;

      for (auto &B : F) {
        for (auto &I : B) {
          if (isa<PHINode>(&I)) {
            continue;
          }

          Value *instrAddr = ConstantInt::get(int64Ty, (int64_t)(&I));
          std::string instrName = std::string(I.getOpcodeName());

          builder.SetInsertPoint(&I);
          Value *nameStr = builder.CreateGlobalStringPtr(instrName);
          Value *args[] = {nameStr, instrAddr};
          builder.CreateCall(execLogger, args);

          instrCount++;

          for (unsigned i = 0; i < I.getNumOperands(); ++i) {
            Value *operand = I.getOperand(i);
            if (Instruction *opI = dyn_cast<Instruction>(operand)) {
              if (isa<PHINode>(opI)) {
                continue;
              }

              Value *userAddr = ConstantInt::get(int64Ty, (int64_t)(&I));
              Value *opAddr = ConstantInt::get(int64Ty, (int64_t)(opI));
              Value *userName = builder.CreateGlobalStringPtr(instrName);
              Value *opName = builder.CreateGlobalStringPtr(std::string(opI->getOpcodeName()));
              Value *relArgs[] = {userAddr, opAddr, userName, opName};
              builder.CreateCall(relLogger, relArgs);
            }
          }
        }
      }

      outs() << "    Instrumented " << instrCount << " instructions\n";
      bool verif = verifyFunction(F, &outs());
      outs() << "    [VERIFICATION] " << (!verif ? "OK\n" : "FAIL\n");
    }

    return PreservedAnalyses::none();
  }
};

PassPluginLibraryInfo getPassPluginInfo() {
  const auto callback = [](PassBuilder &PB) {
    PB.registerPipelineParsingCallback(
      [](StringRef Name, ModulePassManager &MPM, ArrayRef<PassBuilder::PipelineElement>) {
        if (Name == "instrument") {
          MPM.addPass(InstrumentationPass{});
          return true;
        }
        return false;
      });

    PB.registerOptimizerLastEPCallback(
      [](ModulePassManager &MPM, OptimizationLevel Level, ThinOrFullLTOPhase Phase) {
        MPM.addPass(InstrumentationPass{});
      });
  };

  return {LLVM_PLUGIN_API_VERSION, "InstrumentationPass", "1.0", callback};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return getPassPluginInfo();
}
