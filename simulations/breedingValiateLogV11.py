import random
import math
verbosity = False

class Bee:
    amout:float = 1.0  # Default amount of bees
    gene:tuple = ()  # Default gene representation

    def __init__(self, gene, amount:float = 1.):
        self.gene = gene
        self.amount:float = amount

    @classmethod
    def from_species(cls, species, numberOfRetainedGenes:int, numberOfSuperGenes:int, amount:float = 1.):
        gene = ((species, species),) * (numberOfRetainedGenes + numberOfSuperGenes)
        return cls(gene,amount)
    @classmethod
    def from_gene(cls, gene_string, amount:float = 1.):
        #[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],[A,B],
        #print(gene_string)
        gene_strings = gene_string.split('],')
        gene_list = []
        for trait_string in gene_strings:
            if len(trait_string) == 4:
                gene_list.append((trait_string[1],trait_string[3])) 
        gene = tuple(gene_list)
        return cls(gene,amount)

    def __str__(self):
        geneString = ''
        for trait in self.gene:
            geneString += '['+trait[0]+','+trait[1]+'],'
        return f"{self.amount} Bee: {geneString}"
    def __repr__(self):
        return f"{self.amount} Bee: {self.gene}"
    def __distance__(self, other):
        #calculate the distance between two bees
        #return sum(a != b for a, b in zip(self.gene, other.gene))
        return sum(x != y for t1, t2 in zip(self.gene, other.gene) for x, y in zip(t1, t2))
    def __eq__(self, other):
        #check if two bees are equal
        return self.gene == other.gene
    def __hash__(self):
        return hash(self.gene)

def breed(parent1, parent2):
    child = tuple((random.choice(g1), random.choice(g2)) for g1, g2 in zip(parent1.gene, parent2.gene))
    return Bee(child)

def isBeePure(bee:Bee, target:Bee, pure_species_gene = "A"):
    #check if the bee has all target A genes as A
    for (g1, g2), (tg1, tg2) in zip(bee.gene, target.gene):
        # does the target require an pure A gene?
        if tg1 == pure_species_gene and tg2 == pure_species_gene:
            # does the bee have an A gene?
            if g1 != pure_species_gene or g2 != pure_species_gene:
                return False
    return True
'''
def isBeeMissingTargetGene(bee:Bee, target:Bee, target_species_gene= "B"):
    #check if the bee has at least one B of all B target genes
    for (g1, g2), (tg1, tg2) in zip(bee.gene, target.gene):
        # does the target require a B gene?
        if tg1 == target_species_gene or tg2 == target_species_gene:
            # does the bee not have a B gene?
            if g1 != target_species_gene and g2 != target_species_gene:
                return True
    return False
'''
def isBeeMissingAllTargetGenes(bee:Bee, target:Bee, target_species_gene= "B"):
    #check if the bee has at least one B of all B target genes
    for (g1, g2), (tg1, tg2) in zip(bee.gene, target.gene):
        # does the target require a B gene?
        if tg1 == target_species_gene or tg2 == target_species_gene:
            # does the bee not have a B gene?
            if g1 == target_species_gene or g2 == target_species_gene:
                return False
    return True

#identify half trash that could become useful, but is irrelevant to the current queen
def isDroneMissingAllRelevantTargetGenes(drone, target, queen, target_species_gene= "B"):
    for (g1, g2), (tg1, tg2), (q1, q2) in zip(drone.gene, target.gene,queen.gene):
        # does the target require a B gene?
        if tg1 == target_species_gene or tg2 == target_species_gene:
            # is the queen missing a B gene
            if q1 != target_species_gene or q2 != target_species_gene:
                #does the drone have a B gene to contribute
                if g1 == target_species_gene or g2 == target_species_gene:
                    return False
    return True

def isBeeWorseThanPure(bee, target,numberOfRetainedGenes:int, numberOfSuperGenes:int, target_species_gene = "B", pure_species_gene = "A"):
    #check if the bee is pure A
    if(bee == Bee.from_species(pure_species_gene, numberOfRetainedGenes, numberOfSuperGenes)):
        return False
    return isBeeMissingAllTargetGenes(bee, target, target_species_gene)

def choose_father(queen, target, population):
    #automated purification
    purify_queen = isBeeWorseThanPure(queen,target,numberOfRetainedGenes, numberOfSuperGenes)
    #print(f"Is Queen bad and should be reset: {purify_queen}")
    is_queen_pure = isBeePure(queen, target) or (numberOfRetainedGenes>1)
    father_drone:Bee = Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes, math.inf)
    if purify_queen or not is_queen_pure:
        father_drone = Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes, math.inf)
    else:
        best_distance = math.inf
        for drone in population:
            distance = drone.__distance__(target)
            isDroneRelevant = not isDroneMissingAllRelevantTargetGenes(drone, target, queen)
            if verbosity: print(f"    Drone: {drone} Distance to target: {distance}, isRelevant: {isDroneRelevant}")
            if distance < best_distance and isDroneRelevant:
                best_distance = distance
                father_drone = drone
    if verbosity: print(f"Chosen drone: {father_drone}, Reset:{purify_queen}, Is pure: {is_queen_pure}")
    return father_drone
    

numberOfRetainedGenes = 4
numberOfSuperGenes = 8

def reset_population():
    population = set()
    population.add(Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes,math.inf))
    target = Bee((('B', 'B'),) *(numberOfRetainedGenes)+ (('A', 'A'),) * (numberOfSuperGenes))
    princess = None
    return {"drones": population, "target":target, "princess":princess}


def __main__():
    state = reset_population()
    with open("multi11decision.log") as logfile:
        for line in logfile:
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
                state['drones'].add(Bee.from_gene(v))
                pass
            elif k == 'chosen':
                #evaluate equalness
                python_father = choose_father(state['princess'], state['target'], state['drones'])
                chosen_father = Bee.from_gene(v)
                if python_father != chosen_father:
                    py_dist = python_father.__distance__(state['target'])
                    lua_dist = chosen_father.__distance__(state['target'])
                    if py_dist != lua_dist:#seem to always be equal
                      pass  
                    print('choice mismatch detected!')
                    #for drone in state['drones']:
                    #    print('drone',drone)
                    print('princess',state['princess'])
                    print('python_father',python_father)
                    #print('pytho2_father',choose_father(state['princess'], state['target'], state['drones']))   
                    print('chosen_father',chosen_father)
                    
                    
                    py_relevant = not isDroneMissingAllRelevantTargetGenes(python_father, state['target'], state['princess'])
                    lua_relevant = not isDroneMissingAllRelevantTargetGenes(chosen_father, state['target'], state['princess'])
                    print(f'py dist={py_dist}={py_relevant}, lua dist={lua_dist}={lua_relevant}\n')
                    
                    
                    #return
                pass

if __name__ == "__main__":
    __main__()