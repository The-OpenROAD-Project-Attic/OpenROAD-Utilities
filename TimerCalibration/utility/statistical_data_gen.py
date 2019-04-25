from __future__ import print_function
import matplotlib.pyplot as plt
import numpy as np
import sys

print(sys.argv, len(sys.argv))
if len(sys.argv) < 4:
	print("Error: No summary file or report file name be specified!!!")
	print("usage: python statistical_data_gen.py <Corner> <summary file> <report file>")
	quit()
fp = open(sys.argv[2], 'r') 
line = fp.readline()
cnt = 1
rel_err_th = 0.05
abs_err_th = 5
rel_err = np.empty([0, 1], dtype = np.float)
abs_err = np.empty([0, 1], dtype = np.float)

while line:
    #print("Line {}: {}".format(cnt, line.strip()))
    line = fp.readline()
    tmp = line.split()
    #print(len(tmp))
    if(len(tmp) >= 2):
       rel_err = np.vstack((rel_err, float(tmp[4])))
       abs_err = np.vstack((abs_err, float(tmp[3])))
    cnt += 1

#print(file.read())
#Data = file.read()
#print(Data)
fp.close()
#rel_err = np.array(rel_err)
#abs_err = np.array(abs_err)

#print (rel_err)
#print (abs_err)
#print("rel error mean: ", rel_err.mean(), " rel error std: ", rel_err.std())
#print("abs error mean: ", abs_err.mean(), " abs error std: ", abs_err.std())

# summary report
vio_path = 0
pass_path = 0
for i in range (0, len(abs_err)):
	if (abs_err[i] > abs_err_th):
		vio_path = vio_path + 1
	else:
		pass_path = pass_path + 1
abs_mean = '{:.2e}'.format(abs_err.mean())
abs_std = '{:.2e}'.format(abs_err.std())
txt_f = open(sys.argv[3], "w")
txt_f.write("Summary file: %s\n"%sys.argv[1])
txt_f.write("Passed: %d\n"%pass_path)
txt_f.write("Failed: %d\n"%vio_path)
txt_f.write("abs error mean %s, abs error standard deviation: %s\n"%(abs_mean, abs_std))
txt_f.write("rel error mean %f, rel error standard deviation: %f\n"%(rel_err.mean(), rel_err.std()))
txt_f.write("Status: ")
if ( abs(abs_err.mean() + abs_err.std()) > 5e-12):
	txt_f.write(" Failed\n")
else:
	txt_f.write(" Passed\n")
txt_f.write("( mean + standard deviation < 5ps )\n")
txt_f.close()

# An "interface" to mathplotlib.axes.Axes.hist() method
n, bins, patches = plt.hist(abs_err, bins='auto', color='#0504aa',
                               alpha=0.7, rwidth=0.85)
plt.grid(axis='y', alpha=0.75)
plt.xlabel('Error (s)')
plt.ylabel('Number')
histtitle = "Timer Calibration Base Delay Error Histogram"
plt.title(histtitle)
maxfreq = n.max()
# Set a clean upper y-axis limit.
plt.ylim(ymax=np.ceil(maxfreq / 10) * 10 if maxfreq % 10 else maxfreq + 10)
file_name = sys.argv[1]  + "_Error_Histogram"
plt.savefig(file_name);
plt.close();
