#
# parseSCARF.py: Python3 script to parse a SWAMP SCARF (XML) assessment.
#
import sys
import os
import xml.etree.ElementTree as ET

file_name = 'scarf-Bandit-4.8beta3-orig.xml'
if (len(sys.argv) < 2):
  print("Usage: %s <scarf.xml> [High_Fatal_flag  Medium_Error_flag  Low_Warning_flag]")
  print("e.g.,")
  print("python scarf-Bandit-4.9.xml  1  1  0")
  exit(0)

file_name = sys.argv[1]
if (os.path.exists(file_name) == False):
  print(file_name, " does not exist")
  sys.exit(0)

high_flag = int(sys.argv[2])
medium_flag = int(sys.argv[3])
low_flag = int(sys.argv[4])
print("flags = ",high_flag,medium_flag,low_flag)

print('\n---- ' + file_name + ':')
tree=ET.parse(file_name)

root=tree.getroot()
print(root.tag)
print(root.attrib)

"""-------------------------
Note that each static analysis tool uses different
classifications/adjectives for vulnerabilities:

Bandit uses: LOW | MEDIUM | HIGH
Flake8 use:  WARNING | ERROR | FATAL

https://docs.pylint.org/en/1.6.0/tutorial.html
  There are 5 kind of message types :
  * (C) convention, for programming standard violation
  * (R) refactor, for bad code smell
  * (W) warning, for python specific problems
  * (E) error, for much probably bugs in the code
  * (F) fatal, if an error occurred which prevented pylint from doing
  further processing.
---------------------------"""

for severity in [1,0,-1]:
  if (severity == 1) and (high_flag != 1):
    continue
  elif (severity == 0) and (medium_flag != 1):
    continue
  elif (severity == -1) and (low_flag != 1):
    continue

  if (severity > 0):
    print('\n================== High priority')
    num_high = 0
  elif (severity == 0):
    print('\n================== Medium priority')
    num_medium = 0
  elif (severity < 0):
    print('\n================== Low priority')
    num_low = 0


  for child1 in root:
    if (child1.tag != "BugInstance"):  # we only care about the "BugInstance" entries
  #    print(child1.tag, child1.attrib)
      continue

    for child2 in child1:
      if (child2.tag == "BugLocations"):
        locchild = child2
        for child3 in child2:
          for child4 in child3:
            if (child4.tag == "SourceFile"):
              source_file = child4.text
            elif (child4.tag == "StartLine"):
              start_line = child4.text

      elif (child2.tag == 'BugSeverity'):
        bug_severity = 0    # -1, 0, 1 = low, medium, high (equiv in different tools)

        # TODO: use case-insensitive string comparison
        # -1, 0, 1 = low, medium, high (equiv in different tools)
        if((child2.text == "HIGH") or (child2.text == "Fatal")):
          bug_severity = 1
        elif((child2.text == "MEDIUM") or (child2.text == "Error")):
          bug_severity = 0
        elif((child2.text == "LOW") or (child2.text == "Warning")):
          bug_severity = -1

      elif (child2.tag == 'BugMessage'):
        bug_message = child2.text
        if (severity > 0) and (bug_severity > 0):
          print('Line {0:4} in '.format(start_line), source_file, ' ==> ',bug_message)
          num_high += 1
        elif (severity == 0) and (bug_severity == 0):
          print('Line {0:4} in '.format(start_line), source_file, ' ==> ',bug_message)
          num_medium += 1
        elif (severity < 0) and (bug_severity < 0):
          print('Line {0:4} in '.format(start_line), source_file, ' ==> ',bug_message)
          num_low += 1

  if (severity > 0):
    print('\n----- Got ',num_high,' high priority vulnerabilities.')
  elif (severity == 0):
    print('\n----- Got ',num_medium,' medium priority vulnerabilities.')
  elif (severity < 0):
    print('\n----- Got ',num_low,' low priority vulnerabilities.')
  print()
#sys.exit(0)
