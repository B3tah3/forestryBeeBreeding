import random
import math
#numberOfGenes = 8
numberOfRetainedGenes = 1
numberOfSuperGenes = 9
fertility = 4

class Bee:
    def __init__(self, gene, amount = 1):
        self.gene = gene
        self.amount = amount

    @classmethod
    def from_species(cls, species, amount = 1):
        gene = ((species, species),) * (numberOfRetainedGenes + numberOfSuperGenes)
        return cls(gene,amount)

    def __str__(self):
        return f"{self.amount} Bee: {self.gene}"
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

def isBeePure(bee, target, pure_species_gene = "A"):
    #check if the bee has all target A genes as A
    for (g1, g2), (tg1, tg2) in zip(bee.gene, target.gene):
        # does the target require an pure A gene?
        if tg1 == pure_species_gene and tg2 == pure_species_gene:
            # does the bee have an A gene?
            if g1 == pure_species_gene and g2 == pure_species_gene:
                return True
    return False

def isBeeMissingTargetGene(bee, target, target_species_gene= "B"):
    #check if the bee has at least one B of all B target genes
    for (g1, g2), (tg1, tg2) in zip(bee.gene, target.gene):
        # does the target require a B gene?
        if tg1 == target_species_gene or tg2 == target_species_gene:
            # does the bee not have a B gene?
            if g1 != target_species_gene and g2 != target_species_gene:
                return True
    return False

def isBeeWorseThanPure(bee, target, target_species_gene = "B", pure_species_gene = "A"):
    #check if the bee is pure A
    if(bee == Bee.from_species(pure_species_gene)):
        return False
    return isBeeMissingTargetGene(bee, target, target_species_gene)

def simulate_quality_breeding(): 
    population = set()
    for species in "AB":
        population.add(Bee.from_species(species,math.inf))
    queen = Bee.from_species("A")
    target = Bee((('B', 'B'),) *(numberOfRetainedGenes)+ (('A', 'A'),) * (numberOfSuperGenes))
    #print("Initial population:")
    #for bee in population:
    #    print(bee)
    
    #print(f"Target: {target}")
    
    # Simulate the breeding process
    for i in range(10000):
        
        #check if the queen and a drone are equal to the target
        if queen.__distance__(target) == 0:
            #print("Queen is equal to the target!")
            for drone in population:
                if drone.__distance__(target) == 0 :
                    #print(f"Drone {drone} is equal to the target!")
                    #print(f"Generation {i} complete.")
                    return i

        
        #print(f"\nQueen: {queen} Distance to target: {queen.__distance__(target)}")
        
        #automated purification
        purify_queen = isBeeWorseThanPure(queen, target)
        #print(f"Is Queen bad and should be reset: {purify_queen}")
        is_queen_pure = isBeePure(queen, target)
        father_drone = None
        if purify_queen:
            father_drone = Bee.from_species("A", math.inf)
        else:
            if not is_queen_pure:
                father_drone = Bee.from_species("A", math.inf)
            else:
                
                best_distance = math.inf
                for drone in population:
                    distance = drone.__distance__(target)
                    #print(f"    Drone: {drone} Distance to target: {distance}")
                    if distance < best_distance and not isBeeMissingTargetGene(drone, target):
                        best_distance = distance
                        father_drone = drone
        #print(f"Chosen drone: {father_drone}")
        #user input     
        '''for id, drone in enumerate(population):
                    distance = drone.__distance__(target)
                    print(f"    Drone {id}: {drone} Distance to target: {distance}")

                chosen_id = int(input("Enter the ID of the chosen drone: "))
                chosen_drone = list(population)[chosen_id]
                print(f"Chosen drone: {chosen_drone}")'''
        new_queen = breed(queen, father_drone)
        #print(f"New queen: {new_queen}")

        for f in range(fertility):
            new_drone = breed(queen, father_drone)
            if new_drone in population:
                for bee in population:
                    if bee == new_drone:
                        bee.amount += 1
                        break
            else:
                population.add(new_drone)

        #decrease one from the count of the father drone
        father_drone.amount -= 1
        if father_drone.amount <= 0:
            population.remove(father_drone)
        queen = new_queen
    return 1000

def __main__():
    print(f"Number of retained genes: {numberOfRetainedGenes}")
    print(f"Number of super genes: {numberOfSuperGenes}")
    print(f"Fertility: {fertility}")
    generations = []
    for i in range(100):
        generations.append(simulate_quality_breeding())
    print(f"Average generations to target: {sum(generations) / len(generations)}")
    print(f"Standard deviation: {math.sqrt(sum((g - sum(generations) / len(generations)) ** 2 for g in generations) / len(generations))}")

if __name__ == "__main__":
    __main__()