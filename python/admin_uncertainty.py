from SALib.sample import saltelli
from SALib.analyze import sobol
from SALib.test_functions import Ishigami
import numpy as np

# https://salib.readthedocs.io/en/latest/basics.html#what-is-sensitivity-analysis
# https://waterprogramming.wordpress.com/2013/08/05/running-sobol-sensitivity-analysis-using-salib/

variables_dict = {
    # var: [min, max]
    "food": [4, 11],  # [deflated_value, inflated_value]
    "lodging": [4.4, 15.1],  # [San Jose CA, Tulsa OK]
    "waste": [0.5, 2],  # [deflated_value, inflated_value]
    "stad_ops": [10, 25],  # [deflated_value, inflated_value]
    "travel": [8.71, 629.65],  # [Coach bus for shortest trip in data, Air for longest trip in data]
    "days": [2, 5],  # [shortest trip, longest trip]
    "attn": [23835, 144941]  # [least attendance per location, greatest attendance per location]
    # 'foodtot': [529137, 2684017], 'wastetot': [78655.5, 398975.5], 'travtot': [4541746.318, 28245996.483],  'hototeltot': [334854.012, 3580042.812], 'stadtot': [351327.9, 3199449.66],
}

problem = {
    "num_vars": len(variables_dict),
    "names": [key for key in variables_dict],
    "bounds": [variables_dict[key] for key in variables_dict],
}

# Generate samples
param_values = saltelli.sample(problem, 1000)

# Run model (example)
Y = Ishigami.evaluate(param_values)

# Perform analysis
Si = sobol.analyze(problem, Y, print_to_console=True)

# Print the first-order sensitivity indices
print("\n", Si["S1"])
print("\n", Si["ST"])
