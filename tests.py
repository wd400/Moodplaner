from logic import L1StairFunction,GENERATOR_STEP,FEATURES_STEP
#FEATURES_STEP=15
#GENERATOR_STEP=60
#L1StairFunction(musicMetric:list,musicDuration:float,generatorMetric:list,initialGeneratorOffset:float=0,idxGeneratorOffset:int=0)

print(L1StairFunction([0,0,0],FEATURES_STEP*9,[1,1],0,0))