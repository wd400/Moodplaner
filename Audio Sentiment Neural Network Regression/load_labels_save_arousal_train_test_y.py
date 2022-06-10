import glob
import os
import numpy as np
import csv

train_path_arousal = 'arousal_data_float.csv'
train_data = np.genfromtxt(train_path_arousal, delimiter=',', skip_header=1)
fn, y_vals = train_data[:, 0:-1], train_data[:, -1]
y_vals = y_vals.astype(float)
train_y = np.empty((0, 1))
test_y = np.empty((0, 1))
for i in range(0, 1351):
    train_y = np.vstack((train_y, y_vals[i]))
for i in range(1351, 1802):
    test_y = np.vstack((test_y, y_vals[i]))
# print("fn: {}".format(fn[-3]))
# print("train_y: {}".format(train_y.shape))
# print("test_y: {}".format(test_y.shape))
# print("test_y: {}".format(test_y[448]))
np.save('arousal_train_y.npy', train_y)
np.save('arousal_test_y.npy', test_y)
