# copy C files into their own directory for assessment
# Note there are duplicate base filenames which would get overwritten if we simply used the basenames:
# ~/Documents/Von/SWIP/SWAMP_2019/pegasus-4.9.2$ ll c_code/|wc -l
#      30
#
# so we do the ugly trick of using the full pathname (with "_") 
#~/Documents/Von/SWIP/SWAMP_2019/pegasus-4.9.2$ ll c_code/|wc -l
#      33
#
# Author: Randy Heiland


import fnmatch
import os
import sys

cfiles =[]
cfiles_base =[]
for root, dirnames, filenames in os.walk("."):
  for fname in fnmatch.filter(filenames, '*.c'):
    fname = os.path.join(root,fname)
    print(fname)
    newname = fname.replace("/","_")
    newname = newname[2:]
    print(newname)
    bname = os.path.basename(fname)
#    print(bname)
#    cfiles.append(bname)
    cfiles.append(newname)

    if bname in cfiles_base:
      print(bname, "  ---------- already in list")
    else:
      cfiles_base.append(bname)

#    cmd = 'cp ' + fname + ' ' + 'c_code/' + bname
    cmd = 'cp ' + fname + ' ' + 'c_code/' + newname
    print(cmd)
    os.system(cmd)
print(cfiles)
print('# cfiles =',len(cfiles))

