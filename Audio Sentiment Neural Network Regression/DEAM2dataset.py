#encoding: utf-8
import os
import librosa
import numpy as np
import glob
#import util


def extract_feature(file_name):
    X, sample_rate = librosa.load(file_name)

    
    stft = np.abs(librosa.stft(X))
    mfccs = np.mean(librosa.feature.mfcc(y=X, sr=sample_rate, n_mfcc=40).T,axis=0)
    chroma = np.mean(librosa.feature.chroma_stft(S=stft, sr=sample_rate).T,axis=0)
    mel = np.mean(librosa.feature.melspectrogram(X, sr=sample_rate).T,axis=0)
    contrast = np.mean(librosa.feature.spectral_contrast(S=stft, sr=sample_rate).T,axis=0)
    tonnetz = np.mean(librosa.feature.tonnetz(y=librosa.effects.harmonic(X), sr=sample_rate).T,axis=0)

    return mfccs,chroma,mel,contrast,tonnetz


def parse_audio_files(parent_dir,file_ext='*.mp3'):
    features, labels = np.empty((0,193)), np.empty(0)
    for fn in glob.glob(os.path.join(parent_dir, file_ext)):
        print("extract file: %s" % (fn))

        try:
            mfccs, chroma, mel, contrast,tonnetz = extract_feature(fn)
        except Exception as e:
            print("[Error] extract feature error. %s" % (e))
            continue
        ext_features = np.hstack([mfccs,chroma,mel,contrast,tonnetz])
        features = np.vstack([features,ext_features])
        
        labels = np.append(labels, fn.split('/')[-1].split('.')[0])
    return np.array(features), np.array(labels, dtype = np.int)

features,labels=parse_audio_files("/home/zach/Downloads/MEMD_audio")
np.save("features.npy",features)
np.save('labels.npy',labels)