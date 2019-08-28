# Guide to SWIP Static Analysis 

See http://hdl.handle.net/2022/23413 for the SWIP software assurance Guide.

## Overview

The Scientific Workflow Integrity with Pegasus ([SWIP](https://cacr.iu.edu/projects/swip/index.php)) project improves the security and integrity of 
scientific data by integrating cryptographic integrity checking and provenance information into the Pegasus workflow 
management system (WMS). As part of the quality assurance for new developments in the underlying 
[Pegasus](https://pegasus.isi.edu/) WMS code, we will use static analysis tools in the Software Assurance 
Marketplace ([SWAMP](https://continuousassurance.org/)).

Pegasus ([github link](https://github.com/pegasus-isi/pegasus)) is a large code base written in multiple languages, e.g., 
C, Python, bash, and Java. However, there will be a very small percentage of the overall code that will be SWIP-related. 
For example, initially, there will be a few C files that are involved in checksums, e.g., 
[checksum.c](https://github.com/pegasus-isi/pegasus/blob/master/src/tools/pegasus-kickstart/checksum.c),
[appinfo.c](https://github.com/pegasus-isi/pegasus/blob/master/src/tools/pegasus-kickstart/appinfo.c), etc,
and a few Python scripts, e.g., [pegasus-integrity](https://github.com/pegasus-isi/pegasus/blob/master/bin/pegasus-integrity).
All SWIP-related files will be the focus of our attention for static analysis for this project.

## Getting started with SWAMP

To get started with SWAMP, ```Sign Up``` for an account at [www.mir-swamp.org](https://www.mir-swamp.org/). You can sign 
up using a personal account, or use your existing GitHub, Google, or university account. Once you have an account and 
you are logged in,
a typical workflow involves: 
* uploading your code package, 
* run an assessment (using one or more SWAMP-provided tools for the code/language), and
* view the results of the assessment.

Below is a screenshot of (Web UI) output from SWAMP after running an assessment on a sample Python project, ```test_swamp1```. Note that 3 (Python-related) tools (2nd column in table) were used to assess this package and each generated quite different results (last column): Bandit reported 0 warnings, Flake8 reported 117, and Pylint reported 1.

![alt text](https://github.com/IU-CACR/SWIP/blob/master/static_analysis/images/swamp_assessment1.png "Example assessment in SWAMP")

The [Pegasus User Guide](https://pegasus.isi.edu/documentation/pegasus-user-guide.pdf) describes some of the new tools introduced for the SWIP project, e.g., ```pegasus-integrity```.

## Manually parsing SCARF

We use the  `parseSCARF.py` script to manually parse a SCARF file (from SWAMP assessment tools for Python code) and report high, medium, and low vulnerabilities, for example:

```
$ python parseSCARF.py scarf-Bandit.xml 1 1 0
flags = 1 1 0

---- scarf-Bandit.xml:
AnalyzerReport
{'tool_name': 'bandit', 'platform_name': 'ubuntu-16.04-64', 'package_version': 'unknown', 'assessment_start_ts': '1522088324.7147691', 'uuid': '3d076660-4a05-49cc-aec7-331a209c49d9', 'parser_fw_version': '3.1.4', 'package_name': 'pegasus_bin_4.9.0dev', 'tool_version': '1.3.0', 'parser_fw': 'resultparser', 'build_root_dir': '/home/builder/build', 'package_root_dir': 'pkg1'}

================== High priority
Line 27 in pkg1/pegasus-db-admin.py ==> subprocess call with shell=True identified, security issue.
Line 29 in pkg1/pegasus-db-admin.py ==> subprocess call with shell=True identified, security issue.
Line 9 in pkg1/pegasus-em.py ==> subprocess call with shell=True identified, security issue.
Line 11 in pkg1/pegasus-em.py ==> subprocess call with shell=True identified, security issue.
Line 32 in pkg1/pegasus-exitcode.py ==> subprocess call with shell=True identified, security issue.
Line 11 in pkg1/pegasus-globus-online-init.py ==> subprocess call with shell=True identified, security issue.
Line 13 in pkg1/pegasus-globus-online-init.py ==> subprocess call with shell=True identified, security issue.
Line 9 in pkg1/pegasus-service.py ==> subprocess call with shell=True identified, security issue.
Line 11 in pkg1/pegasus-service.py ==> subprocess call with shell=True identified, security issue.
Line 9 in pkg1/pegasus-submitdir.py ==> subprocess call with shell=True identified, security issue.
Line 11 in pkg1/pegasus-submitdir.py ==> subprocess call with shell=True identified, security issue.

----- Got 11 high priority vulnerabilities.

================== Medium priority

----- Got 0 medium priority vulnerabilities.
```
