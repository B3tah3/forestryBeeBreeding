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
import math
def plot_results(file_path):
    if not os.path.exists(file_path):
        print(f"File {file_path} does not exist.")
        return

    with open(file_path, 'r') as file:
        lines = file.readlines()

    other_genes = np.arange(1,12)
    super_genes = np.arange(1,12)
    median_generations = {}
    

    #change to read four lines at a time
    for i in range(0, len(lines), 4):
        fourLines = ''.join(lines[i:i+4])
        match = re.search(r'Genes: (\d+) / (\d+) \| Fertility: 2', fourLines)
        match_median = re.search(r'Median generations: ([\d.]+)', fourLines)
        if match and match_median:
            
            
            #fertility = int(match.group(2))
            #super_genes[(other_gene,super_gene)].append(super_gene)
            
            other_gene = int(match.group(1))
            super_gene = int(match.group(2))
            median_generation = float(match_median.group(1))
            median_generations[(other_gene,super_gene)] = (median_generation)
            median_generations[(super_gene,other_gene)] = (median_generation)
            

    Z = np.zeros((len(super_genes), len(other_genes)))  # rows: y, cols: x

    for i, y in enumerate(super_genes):
        for j, x in enumerate(other_genes):
            Z[i, j] = median_generations.get((x, y), np.nan)  # Use np.nan if missing
            
            
    
    X, Y = np.meshgrid(other_genes, super_genes)
    
    # Plotting
    plt.figure(figsize=(11, 7))
    font = {'family' : 'normal',
        'size'   : 22}
    plt.rc('font', **font)
    plt.imshow(Z, origin='lower', cmap='viridis', extent=[1, 12, 1, 12], aspect='equal')
    plt.xticks(other_genes)
    plt.yticks(super_genes)
    plt.grid(color='white', linestyle='-', linewidth=1)
    plt.colorbar(label='Median Generations')
    plt.xlabel('# A Genes')
    plt.ylabel('# B Genes')
    plt.title('Median # Generation of Trait Selection Combinations\nFertility 2')
    for i, y in enumerate(super_genes):
        for j, x in enumerate(other_genes):
            if not math.isnan(Z[i, j]):
                plt.text(x, y, f'{Z[i, j]:.0f}', ha='left', va='bottom', color='red', fontsize=15)
    plt.show()
    
    

if __name__ == "__main__":
    plot_results('simulations/results_multiAlg_1ksamples.txt')