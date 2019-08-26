"""
Generate a barchart plot for SWAMP's SCARF results for multiple versions
of Pegasus.

Author: Randy Heiland
"""

import matplotlib
import matplotlib.pyplot as plt
import numpy as np


# vuln counts for versions of Pegasus: 4.7, 4.8, 4.9
bandit = (32, 9, 28)  # high
flake8 = (92, 0, 41)  # high
pylint = (86, 17, 77)  # medium  (high are all =0)

#women_means, women_std = (25, 32, 34, 20, 25), (3, 5, 2, 3, 3)

ind = np.arange(len(bandit))  # the x locations for the groups
width = 0.35  # the width of the bars
width = 0.35  # the width of the bars

fig, ax = plt.subplots()
#rects1 = ax.bar(ind - width/2, bandit, width, label='bandit')
width2 = .20
rects1 = ax.bar(ind - width*.66, bandit, width2, label='bandit/high')
rects2 = ax.bar(ind , flake8, width2, label='flake8/high')
rects3 = ax.bar(ind + width*.66, pylint, width2, label='pylint/medium')
                

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('# vulns')
ax.set_title('SWAMP assessment results')
ax.set_xticks(ind)
ax.set_xticklabels(('4.7', '4.8', '4.9'))
ax.legend(loc='upper center')


def autolabel(rects, xpos='center'):
    """
    Attach a text label above each bar in *rects*, displaying its height.

    *xpos* indicates which side to place the text w.r.t. the center of
    the bar. It can be one of the following {'center', 'right', 'left'}.
    """

    ha = {'center': 'center', 'right': 'left', 'left': 'right'}
    offset = {'center': 0, 'right': 1, 'left': -1}

    for rect in rects:
        height = rect.get_height()
        ax.annotate('{}'.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(offset[xpos]*3, 3),  # use 3 points offset
                    textcoords="offset points",  # in both directions
                    ha=ha[xpos], va='bottom')


autolabel(rects1, "center")
autolabel(rects2, "center")
autolabel(rects3, "center")

fig.tight_layout()

plt.show()
