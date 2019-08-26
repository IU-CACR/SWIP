import os
import glob
import shutil

for fname in glob.glob(os.path.join("..","peg*")):
#  print(fname)
  with open(fname) as fp:
    first_line = fp.readline()
#    print(first_line)
    if "python" in first_line:
      print(first_line)
      shutil.copy(fname, os.path.join('.',fname[3:]+".py"))
#    else:
#      break
#  if os.path.isfile(fname1):
#  shutil.copy(fname1, os.path.join('.',fname1+".py")
