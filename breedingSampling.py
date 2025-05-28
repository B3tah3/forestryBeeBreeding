import random
import math
numberOfGenes = 3
fertility = 4

class Bee:
    def __init__(self, gene, amount = 1):
        self.gene = gene
        self.amount = amount

    @classmethod
    def from_species(cls, species, amount = 1):
        gene = ((species, species),) * numberOfGenes
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

'''def quality(drone, queen, target):
    # Higher score means better quality
    def match_score(g, t): return sum(a == b for a, b in zip(g, t))
    score_to_target = sum(match_score(g, t) for g, t in zip(drone.gene, target.gene))
    score_to_queen = sum(match_score(g, q) for g, q in zip(drone.gene, queen.gene))
    return score_to_target * 2 + score_to_queen  # weight target more'''

def quality(drone, queen, target):
    score = 0
    for (dg1, dg2), (qg1, qg2), (tg1, tg2) in zip(drone.gene, queen.gene, target.gene):
        desired = {tg1, tg2}
        drone_alleles = {dg1, dg2}
        queen_alleles = {qg1, qg2}
        score += len(drone_alleles & desired) + len(drone_alleles & queen_alleles)
    return score


def __main__():
    generations = []
    for i in range(100):
        generations.append(simulate_quality_breeding())
    print(f"Average generations to target: {sum(generations) / len(generations)}")
    print(f"Standard deviation: {math.sqrt(sum((g - sum(generations) / len(generations)) ** 2 for g in generations) / len(generations))}")

#test results: 
#genes:        2  3   4   5
#generations: 35 98 262 392
def simulate_quality_breeding(): 
    population = set()
    for species in "AB":
        population.add(Bee.from_species(species,math.inf))
    queen = Bee.from_species("A")
    target = Bee((('B', 'B'),) + (('A', 'A'),) * (numberOfGenes - 1))
    #print("Initial population:")
    #for bee in population:
    #    print(bee)
    
    #print(f"Target: {target}")
    
    # Simulate the breeding process
    for i in range(1000):
        #print(f"\nQueen: {queen} Distance to target: {queen.__distance__(target)}")

        #check if the queen and a drone are equal to the target
        if queen.__distance__(target) == 0:
            #print("Queen is equal to the target!")
            for drone in population:
                if drone.__distance__(target) == 0 :
                    #print(f"Drone {drone} is equal to the target!")
                    #print(f"Generation {i} complete.")
                    return i

        #inverse distance weiting
        '''drone_distances = []
        for id, drone in enumerate(population):
            distance = drone.__distance__(target)
            drone_distances.append((distance, drone))
            print(f"    Drone {id}: {drone} Distance to target: {distance}")

        weights = [1 / d if d != 0 else 1e0 for d, _ in drone_distances]
        drones = [drone for _, drone in drone_distances]
        chosen_drone = random.choices(drones, weights=weights, k=1)[0]'''

        #quality weighting
        drone_qualities = []
        for id, drone in enumerate(population):
            q = quality(drone, queen, target)
            drone_qualities.append((q, drone))
            #print(f"    Drone {id}: {drone} Quality: {q}")

        weights = [q if q > 0 else 0.1 for q, _ in drone_qualities]
        drones = [drone for _, drone in drone_qualities]
        chosen_drone = random.choices(drones, weights=weights, k=1)[0]

        #user input
        '''for id, drone in enumerate(population):
            distance = drone.__distance__(target)
            print(f"    Drone {id}: {drone} Distance to target: {distance}")

        chosen_id = int(input("Enter the ID of the chosen drone: "))
        chosen_drone = list(population)[chosen_id]
        print(f"Chosen drone: {chosen_drone}")'''

        new_queen = breed(queen, chosen_drone)
        #print(f"New queen: {new_queen}")

        for f in range(fertility):
            new_drone = breed(queen, chosen_drone)
            if new_drone in population:
                for bee in population:
                    if bee == new_drone:
                        bee.amount += 1
                        break
            else:
                population.add(new_drone)

        #decrease one from the count of the best drone
        chosen_drone.amount -= 1
        if chosen_drone.amount <= 0:
            population.remove(chosen_drone)
        queen = new_queen
    return 1000
        
def test():
    #create two bees
    beeA = Bee.from_species("A")
    beeB = Bee.from_species("B")
    
    print(beeA)
    print(beeB)
    
    #breed the bees
    beeH = breed(beeA, beeB)
    print(beeH)
    
    for i in range(10):
        bee1 = breed(beeA, beeH)
        print(bee1)


if __name__ == "__main__":
    __main__()