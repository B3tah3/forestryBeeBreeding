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

    super_genes = [[],[]]
    drone_consumption = [[],[]]
    

    #change to read four lines at a time
    for i in range(0, len(lines), 4):
        fourLines = ''.join(lines[i:i+4])
        match = re.search(r'Genes: 1 / (\d+) \| Fertility: 4', fourLines)
        if match:
            match_avgA = re.search(r'Average A drone consumption: ([\d.]+), Max: ([\d.]+), std: ([\d.]+), 5\*std\+avg: ([\d.]+)', fourLines)
            match_avgB = re.search(r'Average B drone consumption: ([\d.]+), Max: ([\d.]+), std: ([\d.]+), 5\*std\+avg: ([\d.]+)', fourLines)
            #match_median = re.search(r'Median generations: ([\d.]+)', fourLines)
            
            if match_avgA and match_avgB:
                super_gene = int(match.group(1))
                super_genes[0].append(super_gene)
                super_genes[1].append(super_gene)

                drone_consumption[0].append(float(match_avgA.group(4)))
                drone_consumption[1].append(float(match_avgB.group(4)))
                
    # Plotting
    plt.figure(figsize=(10, 7))
    font = {'family' : 'normal',
        'size'   : 22}
    plt.rc('font', **font)
    
    plt.plot(super_genes[0], drone_consumption[0], marker='o', linestyle='-')
    plt.plot(super_genes[1], drone_consumption[1], marker='o', linestyle='-')

    plt.legend(['Drones A', 'Drones B'])
    plt.title('Probable Drone Consumption vs # Super Genes \n (1,n), Fertility 4')
    plt.xlabel('# Super Genes')
    plt.ylabel('Probable Drone Consumption')
    plt.xticks(np.arange(min(super_genes[0]), max(super_genes[0]) + 1, 1))
    plt.yticks(np.arange(0, max(drone_consumption[0]) + 1, 3))
    plt.grid()
    plt.show()

    

if __name__ == "__main__":
    plot_results('results8.txt')