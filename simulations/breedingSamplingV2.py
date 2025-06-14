import random
import math
import statistics
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

def isPrincessMissingAllTargetGenes(bee:Bee, target:Bee, target_species_gene= "B"):
    #check if the bee has at least one B of any B target genes
    for (g1, g2), (tg1, tg2) in zip(bee.gene, target.gene):
        # does the target require a B gene?
        if tg1 == target_species_gene or tg2 == target_species_gene:
            # does the bee not have a B gene?
            if g1 == target_species_gene or g2 == target_species_gene:
                return False
    return True

#identify half trash that could become useful, but is irrelevant to the current queen
def isDroneMissingAllRelevantTargetGenes(drone, target, princess, target_species_gene= "B"):
    for (g1, g2), (tg1, tg2), (q1, q2) in zip(drone.gene, target.gene, princess.gene):
        # does the target require a B gene?
        if tg1 == target_species_gene or tg2 == target_species_gene:
            # is the queen missing a B gene
            if q1 != target_species_gene or q2 != target_species_gene:
                #does the drone have a B gene to contribute
                if g1 == target_species_gene or g2 == target_species_gene:
                    return False
    return True

def isPrincessWorseThanPure(bee, target,numberOfRetainedGenes:int, numberOfSuperGenes:int, target_species_gene = "B", pure_species_gene = "A"):
    #check if the bee is pure A
    if(bee == Bee.from_species(pure_species_gene, numberOfRetainedGenes, numberOfSuperGenes)):
        return False
    return isPrincessMissingAllTargetGenes(bee, target, target_species_gene)

def simulate_quality_breeding(numberOfRetainedGenes, numberOfSuperGenes, fertility): 
    population = set()
    for species in "AB":
        population.add(Bee.from_species(species,numberOfRetainedGenes, numberOfSuperGenes,math.inf))
    princess = Bee.from_species("B",numberOfRetainedGenes, numberOfSuperGenes)
    target = Bee((('B', 'B'),) *(numberOfRetainedGenes)+ (('A', 'A'),) * (numberOfSuperGenes))

    countADrones:int = 0
    countBDrones:int = 0
    
    # Simulate the breeding process
    for i in range(10000):
        
        #check if the queen and a drone are equal to the target
        if princess.__distance__(target) == 0:
            #print("Queen is equal to the target!")
            for drone in population:
                if drone.__distance__(target) == 0 :
                    #print(f"Drone {drone} is equal to the target!")
                    #print(f"Generation {i} complete.")
                    return (i, countADrones, countBDrones)

        
        if verbosity: print(f"\nQueen: {princess} Distance to target: {princess.__distance__(target)}")
        
        purify_princess = isPrincessWorseThanPure(princess,target,numberOfRetainedGenes, numberOfSuperGenes)
        father_drone:Bee = Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes, math.inf)
        if purify_princess:# or not is_queen_pure:
            father_drone = Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes, math.inf)
        else:
            best_distance = math.inf
            for drone in population:
                distance = drone.__distance__(target)
                isDroneRelevant = not isDroneMissingAllRelevantTargetGenes(drone, target, princess)
                if verbosity: print(f"    Drone: {drone} Distance to target: {distance}, isRelevant: {isDroneRelevant}")
                if distance < best_distance and isDroneRelevant:
                    best_distance = distance
                    father_drone = drone
            #is_father_pure_a = father_drone == Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes, math.inf)
            #if is_father_pure_a and best_distance!= math.inf: print(f'father is pure a, dist={best_distance}')
        
        if verbosity: print(f"Chosen drone: {father_drone}, Reset:{purify_princess}")
        
        new_princess = breed(princess, father_drone)

        for f in range(fertility):
            new_drone = breed(princess, father_drone)
            if new_drone in population:
                for bee in population:
                    if bee == new_drone:
                        bee.amount += 1
                        break
            else:
                population.add(new_drone)

        #decrease one from the count of the father drone
        father_drone.amount -= 1
        if father_drone == Bee.from_species("A",numberOfRetainedGenes, numberOfSuperGenes, math.inf):
            countADrones += 1
        if father_drone == Bee.from_species("B",numberOfRetainedGenes, numberOfSuperGenes, math.inf):
            countBDrones += 1
        
        if father_drone.amount <= 0:
            population.remove(father_drone)
        princess = new_princess
    return (i, countADrones, countBDrones)

Combinations_numberOfRetainedGenes = [1]#list(range(1,7))
Combinations_numberOfSuperGenes = [11]#list(range(1,12))
Combinations_fertility = [4]

def simulate_quality_breeding_with_params(numberOfRetainedGenes, numberOfSuperGenes, fertility):
    print(f"Genes: {numberOfRetainedGenes} / {numberOfSuperGenes} | Fertility: {fertility}")
    generations = []
    dronesA = []
    dronesB = []
    for i in range(1000):
        (numberOfGenerations, countADrones, countBDrones) = simulate_quality_breeding(numberOfRetainedGenes, numberOfSuperGenes, fertility)
        #print(numberOfGenerations)
        generations.append(numberOfGenerations)
        dronesA.append(countADrones)
        dronesB.append(countBDrones)
        
        
    average_generations = sum(generations) / len(generations)
    median_generations = sorted(generations)[len(generations) // 2]

    average_ADrones = sum(dronesA) / len(dronesA)
    max_ADrones = max(dronesA)
    std_ADrones = statistics.stdev(dronesA)
    fiveSigmaEnoughA = 5*std_ADrones+average_ADrones

    average_BDrones = sum(dronesB) / len(dronesB)
    max_BDrones = max(dronesB)
    std_BDrones = statistics.stdev(dronesB)
    fiveSigmaEnoughB = 5*std_BDrones+average_BDrones

    
    print(f"Average generations to target: {average_generations}, Median generations: {median_generations}")
    print(f"Average A drone consumption: {average_ADrones}, Max: {max_ADrones}, std: {std_ADrones}, 5*std+avg: {fiveSigmaEnoughA}")
    print(f"Average B drone consumption: {average_BDrones}, Max: {max_BDrones}, std: {std_BDrones}, 5*std+avg: {fiveSigmaEnoughB}")
    

    #print(f"Standard deviation: {math.sqrt(sum((g - sum(generations) / len(generations)) ** 2 for g in generations) / len(generations))}")
    return average_generations

def __main__():
    for numberOfRetainedGenes in Combinations_numberOfRetainedGenes:
        for numberOfSuperGenes in Combinations_numberOfSuperGenes:
            for fertility in Combinations_fertility:
                if numberOfRetainedGenes > numberOfSuperGenes:
                    continue
                if numberOfRetainedGenes + numberOfSuperGenes > 12:
                    continue
                simulate_quality_breeding_with_params(numberOfRetainedGenes, numberOfSuperGenes, fertility)

if __name__ == "__main__":
    __main__()