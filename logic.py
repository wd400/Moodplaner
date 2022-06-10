import numpy as np
import librosa
from collections import defaultdict
from tensorflow import keras

GENERATOR_STEP=60
FEATURES_STEP=45

MODELS={
    'v':keras.models.load_model("saved_models/valence_model.h5"),
    'a':keras.models.load_model("saved_models/arousal_model.h5")
 }


METRICS=list(MODELS.keys())+['bpm']

def L1StairFunction(musicMetric:list,musicDuration:float,generatorMetric:list,initialGeneratorOffset:float=0,idxGeneratorOffset:int=0)->float:
    global GENERATOR_STEP
    gIdx=idxGeneratorOffset
    mIdx=0
    mOffset=0
    gOffset=initialGeneratorOffset
    result=0
    totalTime=0
    while gIdx<len(generatorMetric) and mIdx<len(musicMetric):
        print("gIdx",gIdx,"mIdx",mIdx)
        print("result",result)
        if mIdx==len(musicMetric)-1:
            musicStepDuration=musicDuration-FEATURES_STEP*mIdx
        else:
            musicStepDuration=FEATURES_STEP
        
        if GENERATOR_STEP-gOffset<= musicStepDuration - mOffset:
            
            if generatorMetric[gIdx]!=None:
                result+=(GENERATOR_STEP-gOffset)*abs(musicMetric[mIdx]-generatorMetric[gIdx])
                totalTime+=GENERATOR_STEP-gOffset
            if GENERATOR_STEP-gOffset==musicStepDuration - mOffset:
                mIdx+=1
                mOffset=0
            else:
                mOffset+=GENERATOR_STEP-gOffset
            gOffset=0
            gIdx+=1
        else:
            if generatorMetric[gIdx]!=None:
                result+=(musicStepDuration - mOffset)*abs(musicMetric[mIdx]-generatorMetric[gIdx])
            totalTime+=musicStepDuration - mOffset
            gOffset+=musicStepDuration - mOffset
            mOffset=0
            mIdx+=1
    #/totalTime
    return result

def dist(music:dict,generator:dict,idxGeneratorOffset:int,offset:float)->float:
    #music={'m1':[...],'m2':[...],'bpm':[...],'duration':[...]}
    #troncatedGenerator={'m1':[...],'m2':[...]}
    result=0
    for metricGenerator in generator:
        result+=L1StairFunction(music[metricGenerator], music['duration'], generator[metricGenerator], offset,idxGeneratorOffset)
    return result/len(generator)

def generatorDuration(generator:dict)->float:
    return max(len(generator[metric]) for metric in generator)*GENERATOR_STEP

def buildPlaylistRAW(musicsdata:dict,generator:dict)->list:
    #{musicid:{'m1':[...],'m2':[...]},}
    #
    wantedDuration=generatorDuration(generator)
    result=[]
    playlistDuration=0
    while playlistDuration<wantedDuration and len(musicsdata)!=0:
        print("MUSICDATA",musicsdata)
        bestMusicFit=None
        smallestDist=float('+inf')
        generatorFilledTile=int(playlistDuration/GENERATOR_STEP)
        generatorTileOffset=playlistDuration-generatorFilledTile*GENERATOR_STEP

        for music in musicsdata:
            print("MUSIC",music)
            newDist=dist(musicsdata[music],generator,generatorFilledTile,generatorTileOffset)
            if newDist<smallestDist:
                smallestDist=newDist
                bestMusicFit=music
        print("CHOIX",bestMusicFit)
        result.append(bestMusicFit)
        playlistDuration+=musicsdata[bestMusicFit]['duration']
        musicsdata.pop(bestMusicFit)
    return result

def extract_feature(X,sample_rate):

    result=[]
    for binf in range(0,X.shape[0]+1,sample_rate*FEATURES_STEP):
        bsup=min(binf+sample_rate*FEATURES_STEP,X.shape[0])

        stft = np.abs(librosa.stft(X[binf:bsup]))
        mfccs = np.mean(librosa.feature.mfcc(y=X[binf:bsup], sr=sample_rate, n_mfcc=40).T,axis=0)
        chroma = np.mean(librosa.feature.chroma_stft(S=stft, sr=sample_rate).T,axis=0)
        mel = np.mean(librosa.feature.melspectrogram(X[binf:bsup], sr=sample_rate).T,axis=0)
        contrast = np.mean(librosa.feature.spectral_contrast(S=stft, sr=sample_rate).T,axis=0)
        tonnetz = np.mean(librosa.feature.tonnetz(y=librosa.effects.harmonic(X[binf:bsup]), sr=sample_rate).T,axis=0)

        tempo, _ = librosa.beat.beat_track(y=X[binf:bsup], sr=sample_rate)
        #[AI parameters,bpm]
        result.append([np.hstack([mfccs,chroma,mel,contrast,tonnetz]),tempo])

    return result

def measureSongRAW(X, sample_rate)->dict:
    #TODO:remplacer duration[] par duration,step
    #music={'m1':[...],'m2':[...],'bpm':[...],'duration':[...]}
    music=defaultdict(lambda:[])
    featureList=extract_feature(X,sample_rate)
    music['bpm']=[(max(0,min(1,(feature[1]-40)/220))) for feature in featureList]
    #  continue
    for model in MODELS:
        music[model]=MODELS[model].predict(np.array([x[0] for x in featureList])).flatten().tolist()
    return music, FEATURES_STEP