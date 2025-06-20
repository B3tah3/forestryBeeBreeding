import random
import math
verbosity = False
from breedingSamplingV11 import  Bee, choose_father, isDroneMissingAllRelevantTargetGenes


numberOfRetainedGenes = 4
numberOfSuperGenes = 8

def reset_population():
    population = {}
    population[Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes)] = 1
    target = Bee((('B', 'B'),) *(numberOfRetainedGenes)+ (('A', 'A'),) * (numberOfSuperGenes))
    princess = None
    return {"drones": population, "target":target, "princess":princess}


def __main__():
    state = reset_population()
    count_matching = 0
    with open("multi11decision.log") as logfile:
        for line in logfile:
            if len(line) < 3:
                continue
            k,v,*r = line.split('=')
            #print(k)
            if k == 'princess':
                #reset state, set princess
                state = reset_population()
                state['princess'] = Bee.from_gene(v)
                #print(state['princess'])
                pass
            elif k == 'drone':
                #add to state
                state['drones'][Bee.from_gene(v)] = 1
                pass
            elif k == 'chosen':
                #evaluate equalness
                python_father = choose_father(state['princess'], state['target'], state['drones'], numberOfRetainedGenes, numberOfSuperGenes)
                chosen_father = Bee.from_gene(v)
                if python_father != chosen_father:
                    py_dist = python_father.__distance__(state['target'])
                    lua_dist = chosen_father.__distance__(state['target'])
                    if py_dist != lua_dist:#seem to always be equal
                      pass  
                    print('choice mismatch detected!')
                    for drone in state['drones'].keys():
                        print('drone',drone)
                    print('princess',state['princess'])
                    print('python_father',python_father)
                    #print('pytho2_father',choose_father(state['princess'], state['target'], state['drones']))   
                    print('chosen_father',chosen_father)
                    
                    
                    py_relevant = not isDroneMissingAllRelevantTargetGenes(python_father, state['target'], state['princess'])
                    lua_relevant = not isDroneMissingAllRelevantTargetGenes(chosen_father, state['target'], state['princess'])
                    print(f'py dist={py_dist}={py_relevant}, lua dist={lua_dist}={lua_relevant}\n')
                    
                    
                    return
                else:
                    count_matching += 1
    print(f"Finished Listing non-matching. Matching={count_matching}")    

if __name__ == "__main__":
    __main__()