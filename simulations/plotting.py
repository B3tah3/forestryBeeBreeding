#read the results6.txt which looks like this:
#Genes: 1 / 1 | Fertility: 4
#Average generations to target: 8.56, Median generations: 8
#Average A drone consumption: 2.74, Max: 12, std: 1.9777550787484155, 5*std+avg: 12.628775393742078
#Average B drone consumption: 1.27, Max: 4, std: 0.5478147589295218, 5*std+avg: 4.009073794647609
#and plot the number of genes vs median generations to target
import matplotlib.pyplot as plt
import numpy as np
import re
import os
def plot_results(file_path):
    if not os.path.exists(file_path):
        print(f"File {file_path} does not exist.")
        return

    with open(file_path, 'r') as file:
        lines = file.readlines()

    super_genes = [[],[],[]]
    median_generations = [[],[],[]]
    

    #change to read four lines at a time
    for i in range(0, len(lines), 4):
        fourLines = ''.join(lines[i:i+4])
        match = re.search(r'Genes: (\d+) / (\d+) \| Fertility: 4', fourLines)
        if match:
            retained_gene = int(match.group(1))
            super_gene = int(match.group(2))
            super_genes[retained_gene].append(super_gene)

            match_median = re.search(r'Median generations: ([\d.]+)', fourLines)
            if match_median:
                median_generations[retained_gene].append(float(match_median.group(1)))

    # Plotting
    plt.figure(figsize=(10, 6))
    font = {'family' : 'normal',
        'size'   : 22}
    plt.rc('font', **font)
    
    plt.plot(super_genes[1], median_generations[1], marker='o', linestyle='-', color='b')
    plt.plot(super_genes[2], median_generations[2], marker='o', linestyle='-', color='g')
    plt.legend(['1 other Gene', '2 other Genes'], loc='upper left')
    plt.title('Median Generations to Target vs # Super Genes')
    plt.xlabel('# Super Genes')
    plt.ylabel('Median Generations to Target')
    plt.xticks(np.arange(min(super_genes[1]), max(super_genes[1]) + 1, 1))
    plt.yticks(np.arange(0, max(median_generations[2]) + 1, 5))
    plt.grid()
    plt.show()

    

if __name__ == "__main__":
    plot_results('results7.txt')