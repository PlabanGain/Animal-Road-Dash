import 'package:flutter/material.dart';

enum AnimalRarity {
  common,
  uncommon,
  rare,
  exotic,
}

class Animal {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String vocalClue;
  final List<String> vocalPhonetics;
  final List<Color> gradientColors;
  final double rarity; // 1.0 to 6.0 Stars
  final double ageRating; // 1.0 to 6.0 Stars
  final double weightRating; // 1.0 to 6.0 Stars
  final double heightRating; // 1.0 to 6.0 Stars
  final double strengthRating; // 1.0 to 6.0 Stars
  final String ageText;
  final String weightText;
  final String heightText;
  final String strengthText;
  final List<Offset> silhouettePoints; // Normalized path points (0.0 to 1.0)

  const Animal({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.vocalClue,
    required this.vocalPhonetics,
    required this.gradientColors,
    required this.rarity,
    required this.ageRating,
    required this.weightRating,
    required this.heightRating,
    required this.strengthRating,
    required this.ageText,
    required this.weightText,
    required this.heightText,
    required this.strengthText,
    required this.silhouettePoints,
  });

  String get emoji {
    switch (id) {
      case 'cat': return '🐱';
      case 'dog': return '🐶';
      case 'cow': return '🐮';
      case 'pig': return '🐷';
      case 'sheep': return '🐑';
      case 'horse': return '🐴';
      case 'chicken': return '🐔';
      case 'duck': return '🦆';
      case 'mouse': return '🐭';
      case 'rabbit': return '🐰';
      case 'elephant': return '🐘';
      case 'lion': return '🦁';
      case 'tiger': return '🐯';
      case 'bear': return '🐻';
      case 'deer': return '🦌';
      case 'monkey': return '🐵';
      case 'fox': return '🦊';
      case 'penguin': return '🐧';
      case 'frog': return '🐸';
      case 'turtle': return '🐢';
      case 'dolphin': return '🐬';
      case 'kangaroo': return '🦘';
      case 'koala': return '🐨';
      case 'panda': return '🐼';
      case 'shark': return '🦈';
      case 'eagle': return '🦅';
      case 'owl': return '🦉';
      case 'wolf': return '🐺';
      case 'cheetah': return '🐆';
      case 'zebra': return '🦓';
      case 'chameleon': return '🦎';
      case 'sloth': return '🦥';
      case 'flamingo': return '🦩';
      case 'platypus': return '🦦';
      case 'seahorse': return '🐠';
      case 'octopus': return '🐙';
      case 'peacock': return '🦚';
      case 'lemur': return '🐒';
      case 'meerkat': return '🐿️';
      case 'hedgehog': return '🦔';
      case 'axolotl': return '🐠';
      case 'shoebill': return '🐦';
      case 'pangolin': return '🦔';
      case 'greenland_shark': return '🦈';
      case 'narwhal': return '🐳';
      case 'tardigrade': return '🦠';
      case 'cassowary': return '🐦';
      case 'blobfish': return '🐡';
      case 'capybara': return '🐹';
      case 'quokka': return '🐹';
      default: return '🐾';
    }
  }

  AnimalRarity get rarityCategory {
    if (rarity < 2.0) {
      return AnimalRarity.common;
    } else if (rarity < 3.5) {
      return AnimalRarity.uncommon;
    } else if (rarity < 5.0) {
      return AnimalRarity.rare;
    } else {
      return AnimalRarity.exotic;
    }
  }

  String get vocalPitch {
    // Low pitch animals
    const lowPitchIds = {
      'cow', 'pig', 'elephant', 'lion', 'tiger', 'bear', 'bull', 'gorilla', 
      'greenland_shark', 'hippo', 'walrus', 'rhino', 'bison', 'camel'
    };
    // High pitch animals
    const highPitchIds = {
      'chicken', 'duck', 'mouse', 'rabbit', 'dolphin', 'eagle', 'axolotl', 
      'tardigrade', 'chameleon', 'frog', 'seahorse', 'quokka', 'canary', 
      'parrot', 'monkey', 'lemur'
    };
    
    if (lowPitchIds.contains(id)) {
      return 'low';
    } else if (highPitchIds.contains(id)) {
      return 'high';
    } else {
      return 'mid';
    }
  }

  String get assetPath => 'assets/images/$id.png';

  Path getPath(double width, double height) {
    final Path path = Path();
    if (silhouettePoints.isEmpty) return path;

    path.moveTo(
      silhouettePoints[0].dx * width,
      silhouettePoints[0].dy * height,
    );
    for (int i = 1; i < silhouettePoints.length; i++) {
      path.lineTo(
        silhouettePoints[i].dx * width,
        silhouettePoints[i].dy * height,
      );
    }
    path.close();
    return path;
  }

  Path getSmoothPath(double width, double height) {
    final Path path = Path();
    if (silhouettePoints.isEmpty) return path;
    if (silhouettePoints.length < 3) return getPath(width, height);

    final List<Offset> scaledPoints = silhouettePoints
        .map((p) => Offset(p.dx * width, p.dy * height))
        .toList();

    path.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);

    final int len = scaledPoints.length;
    for (int i = 0; i < len; i++) {
      final Offset p0 = scaledPoints[i == 0 ? len - 1 : i - 1];
      final Offset p1 = scaledPoints[i];
      final Offset p2 = scaledPoints[(i + 1) % len];
      final Offset p3 = scaledPoints[(i + 2) % len];

      const double tension = 0.5;
      final Offset cp1 = p1 + (p2 - p0) * (tension / 3.0);
      final Offset cp2 = p2 - (p3 - p1) * (tension / 3.0);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }
}

// Helper coordinates to build recognizable minimalist vector silhouettes
// 0.0,0.0 is top-left, 1.0,1.0 is bottom-right.
final List<Animal> allAnimals = [
  // TIER 1 - COMMON (Stages 1-10)
  Animal(
    id: 'cat',
    name: 'Cat',
    scientificName: 'Felis catus',
    description: 'A small domesticated carnivorous mammal known for its agility, playful nature, and attachment to humans.',
    vocalClue: 'Say "Meow" or make a high-pitched purr!',
    vocalPhonetics: ['meow', 'miao', 'purr', 'meoww', 'miow'],
    gradientColors: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
    rarity: 1.0,
    ageRating: 2.5,
    weightRating: 1.5,
    heightRating: 1.5,
    strengthRating: 2.0,
    ageText: '12-15 Years',
    weightText: '4.5 kg',
    heightText: '24 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.2, 0.4), Offset(0.3, 0.1), Offset(0.4, 0.3),
      Offset(0.6, 0.3), Offset(0.7, 0.1), Offset(0.8, 0.4), Offset(0.8, 0.8),
      Offset(0.7, 0.8), Offset(0.65, 0.6), Offset(0.35, 0.6), Offset(0.3, 0.8),
    ],
  ),
  Animal(
    id: 'dog',
    name: 'Dog',
    scientificName: 'Canis lupus familiaris',
    description: 'Man\'s best friend. Highly social, loyal, and capable of understanding human actions and vocabulary.',
    vocalClue: 'Say "Woof" or bark loudly!',
    vocalPhonetics: ['woof', 'bark', 'ruff', 'bowwow', 'wuf'],
    gradientColors: [const Color(0xFFFFC796), const Color(0xFFFF6B95)],
    rarity: 1.0,
    ageRating: 2.0,
    weightRating: 2.5,
    heightRating: 2.5,
    strengthRating: 3.0,
    ageText: '10-13 Years',
    weightText: '25 kg',
    heightText: '55 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.15, 0.85), Offset(0.2, 0.45), Offset(0.1, 0.25), Offset(0.3, 0.15),
      Offset(0.5, 0.15), Offset(0.7, 0.25), Offset(0.8, 0.25), Offset(0.85, 0.45),
      Offset(0.8, 0.85), Offset(0.6, 0.85), Offset(0.5, 0.65), Offset(0.4, 0.85),
    ],
  ),
  Animal(
    id: 'cow',
    name: 'Cow',
    scientificName: 'Bos taurus',
    description: 'A large, docile domesticated herbivore with cloven hooves and a specialized four-chamber stomach.',
    vocalClue: 'Say "Moo" in a deep voice!',
    vocalPhonetics: ['moo', 'muu', 'mooo'],
    gradientColors: [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
    rarity: 1.5,
    ageRating: 3.0,
    weightRating: 5.5,
    heightRating: 4.5,
    strengthRating: 4.5,
    ageText: '18-22 Years',
    weightText: '720 kg',
    heightText: '150 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.1, 0.8), Offset(0.1, 0.3), Offset(0.05, 0.2), Offset(0.2, 0.2),
      Offset(0.3, 0.15), Offset(0.7, 0.15), Offset(0.8, 0.2), Offset(0.95, 0.2),
      Offset(0.9, 0.3), Offset(0.9, 0.8), Offset(0.7, 0.8), Offset(0.5, 0.7),
      Offset(0.3, 0.8),
    ],
  ),
  Animal(
    id: 'pig',
    name: 'Pig',
    scientificName: 'Sus scrofa domesticus',
    description: 'An omnivorous, highly intelligent animal known for its round body, flat snout, and keen sense of smell.',
    vocalClue: 'Say "Oink" or make a snorting sound!',
    vocalPhonetics: ['oink', 'oinkk', 'snort', 'grunt'],
    gradientColors: [const Color(0xFFFEE140), const Color(0xFFFA709A)],
    rarity: 1.2,
    ageRating: 2.5,
    weightRating: 3.5,
    heightRating: 2.5,
    strengthRating: 3.0,
    ageText: '15-20 Years',
    weightText: '150 kg',
    heightText: '80 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.15, 0.5), Offset(0.25, 0.25), Offset(0.75, 0.25),
      Offset(0.85, 0.5), Offset(0.8, 0.8), Offset(0.6, 0.85), Offset(0.5, 0.7),
      Offset(0.4, 0.85),
    ],
  ),
  Animal(
    id: 'sheep',
    name: 'Sheep',
    scientificName: 'Ovis aries',
    description: 'A ruminant mammal valued for its thick, curly wool fleece. They are known for flocking behavior.',
    vocalClue: 'Say "Baa" or make a bleating sound!',
    vocalPhonetics: ['baa', 'bah', 'baaa', 'bleat'],
    gradientColors: [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)],
    rarity: 1.2,
    ageRating: 2.0,
    weightRating: 2.5,
    heightRating: 2.5,
    strengthRating: 2.0,
    ageText: '10-12 Years',
    weightText: '80 kg',
    heightText: '90 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.1, 0.6), Offset(0.15, 0.4), Offset(0.3, 0.2),
      Offset(0.5, 0.15), Offset(0.7, 0.2), Offset(0.85, 0.4), Offset(0.9, 0.6),
      Offset(0.8, 0.8), Offset(0.6, 0.85), Offset(0.5, 0.7), Offset(0.4, 0.85),
    ],
  ),
  Animal(
    id: 'horse',
    name: 'Horse',
    scientificName: 'Equus caballus',
    description: 'A majestic odd-toed ungulate built for speed, endurance, and strength. Instrumental in human history.',
    vocalClue: 'Say "Neigh" or mimic a whinny!',
    vocalPhonetics: ['neigh', 'nay', 'whinny', 'snort'],
    gradientColors: [const Color(0xFFF6D365), const Color(0xFFFDA085)],
    rarity: 1.8,
    ageRating: 3.5,
    weightRating: 5.0,
    heightRating: 4.8,
    strengthRating: 5.0,
    ageText: '25-30 Years',
    weightText: '500 kg',
    heightText: '160 cm',
    strengthText: 'Very High',
    silhouettePoints: const [
      Offset(0.15, 0.85), Offset(0.2, 0.4), Offset(0.1, 0.15), Offset(0.25, 0.05),
      Offset(0.35, 0.15), Offset(0.45, 0.35), Offset(0.85, 0.35), Offset(0.9, 0.85),
      Offset(0.75, 0.85), Offset(0.65, 0.6), Offset(0.4, 0.6), Offset(0.3, 0.85),
    ],
  ),
  Animal(
    id: 'chicken',
    name: 'Chicken',
    scientificName: 'Gallus gallus domesticus',
    description: 'The most populous domesticated bird on Earth. Valued for its eggs and social pecking orders.',
    vocalClue: 'Say "Cluck" or mimic a rooster crow!',
    vocalPhonetics: ['cluck', 'cockadoodledoo', 'bok', 'bagook'],
    gradientColors: [const Color(0xFFFFF1EB), const Color(0xFFACE0F9)],
    rarity: 1.0,
    ageRating: 1.5,
    weightRating: 1.2,
    heightRating: 1.2,
    strengthRating: 1.5,
    ageText: '5-10 Years',
    weightText: '2.5 kg',
    heightText: '40 cm',
    strengthText: 'Very Low',
    silhouettePoints: const [
      Offset(0.3, 0.85), Offset(0.2, 0.6), Offset(0.25, 0.35), Offset(0.15, 0.2),
      Offset(0.3, 0.1), Offset(0.45, 0.3), Offset(0.65, 0.4), Offset(0.85, 0.35),
      Offset(0.8, 0.6), Offset(0.6, 0.85),
    ],
  ),
  Animal(
    id: 'duck',
    name: 'Duck',
    scientificName: 'Anas platyrhynchos',
    description: 'An aquatic bird with webbed feet and a broad, flat bill, specialized for diving and paddling.',
    vocalClue: 'Say "Quack" sharply!',
    vocalPhonetics: ['quack', 'quak', 'kwak', 'quackk'],
    gradientColors: [const Color(0xFFD4FC79), const Color(0xFF96E6A1)],
    rarity: 1.1,
    ageRating: 1.8,
    weightRating: 1.1,
    heightRating: 1.2,
    strengthRating: 1.5,
    ageText: '5-8 Years',
    weightText: '1.2 kg',
    heightText: '35 cm',
    strengthText: 'Very Low',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.15, 0.6), Offset(0.25, 0.3), Offset(0.1, 0.25),
      Offset(0.2, 0.15), Offset(0.35, 0.25), Offset(0.7, 0.4), Offset(0.85, 0.5),
      Offset(0.7, 0.8),
    ],
  ),
  Animal(
    id: 'mouse',
    name: 'Mouse',
    scientificName: 'Mus musculus',
    description: 'A tiny rodent with round ears and a long hairless tail. Known for high metabolic rate and nesting.',
    vocalClue: 'Say "Squeak" in a tiny voice!',
    vocalPhonetics: ['squeak', 'squik', 'piip', 'squeek'],
    gradientColors: [const Color(0xFFE2EBF0), const Color(0xFFCFD9DF)],
    rarity: 1.0,
    ageRating: 1.0,
    weightRating: 0.5,
    heightRating: 0.5,
    strengthRating: 1.0,
    ageText: '1.5-3 Years',
    weightText: '20 g',
    heightText: '7 cm',
    strengthText: 'Trivial',
    silhouettePoints: const [
      Offset(0.3, 0.8), Offset(0.2, 0.6), Offset(0.25, 0.4), Offset(0.35, 0.3),
      Offset(0.5, 0.4), Offset(0.65, 0.3), Offset(0.75, 0.4), Offset(0.8, 0.6),
      Offset(0.7, 0.8), Offset(0.9, 0.85), Offset(0.5, 0.85),
    ],
  ),
  Animal(
    id: 'rabbit',
    name: 'Rabbit',
    scientificName: 'Oryctolagus cuniculus',
    description: 'A small herbivorous mammal with long ears, long hind legs, and a fluffy short tail.',
    vocalClue: 'Say "Thump" or mimic a soft squeak!',
    vocalPhonetics: ['thump', 'squeak', 'sniff', 'hop'],
    gradientColors: [const Color(0xFFF5F7FA), const Color(0xFFB8C6DB)],
    rarity: 1.2,
    ageRating: 2.0,
    weightRating: 1.2,
    heightRating: 1.5,
    strengthRating: 1.8,
    ageText: '8-12 Years',
    weightText: '2.0 kg',
    heightText: '40 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.25, 0.85), Offset(0.2, 0.6), Offset(0.2, 0.4), Offset(0.25, 0.1),
      Offset(0.35, 0.1), Offset(0.4, 0.4), Offset(0.5, 0.4), Offset(0.55, 0.1),
      Offset(0.65, 0.1), Offset(0.7, 0.4), Offset(0.8, 0.5), Offset(0.8, 0.85),
    ],
  ),

  // TIER 2 - UNCOMMON (Stages 11-20)
  Animal(
    id: 'elephant',
    name: 'Elephant',
    scientificName: 'Loxodonta africana',
    description: 'The largest land mammal. Known for its prehensile trunk, ivory tusks, and deep social bonds.',
    vocalClue: 'Say "Trumpet" or mimic a loud roar!',
    vocalPhonetics: ['trumpet', 'toot', 'pawoo', 'barr', 'rawr'],
    gradientColors: [const Color(0xFFA1C4FD), const Color(0xFFC2E9FB)],
    rarity: 2.5,
    ageRating: 5.5,
    weightRating: 6.0,
    heightRating: 5.5,
    strengthRating: 6.0,
    ageText: '60-70 Years',
    weightText: '6,000 kg',
    heightText: '320 cm',
    strengthText: 'Colossal',
    silhouettePoints: const [
      Offset(0.1, 0.85), Offset(0.05, 0.5), Offset(0.15, 0.35), Offset(0.35, 0.25),
      Offset(0.75, 0.25), Offset(0.85, 0.4), Offset(0.9, 0.85), Offset(0.75, 0.85),
      Offset(0.65, 0.6), Offset(0.4, 0.6), Offset(0.3, 0.85), Offset(0.2, 0.85),
      Offset(0.2, 0.55), Offset(0.12, 0.7),
    ],
  ),
  Animal(
    id: 'lion',
    name: 'Lion',
    scientificName: 'Panthera leo',
    description: 'The King of the Jungle. A social apex predator living in prides, recognized by the male\'s thick mane.',
    vocalClue: 'Roar loudly or say "Grrr"!',
    vocalPhonetics: ['roar', 'grrr', 'rawr', 'grr', 'growl'],
    gradientColors: [const Color(0xFFFAD961), const Color(0xFFF76B1C)],
    rarity: 2.8,
    ageRating: 2.5,
    weightRating: 4.0,
    heightRating: 3.5,
    strengthRating: 5.5,
    ageText: '10-14 Years',
    weightText: '190 kg',
    heightText: '120 cm',
    strengthText: 'Apex',
    silhouettePoints: const [
      Offset(0.15, 0.85), Offset(0.1, 0.4), Offset(0.25, 0.2), Offset(0.5, 0.25),
      Offset(0.75, 0.3), Offset(0.85, 0.45), Offset(0.8, 0.85), Offset(0.6, 0.85),
      Offset(0.55, 0.6), Offset(0.35, 0.6), Offset(0.3, 0.85),
    ],
  ),
  Animal(
    id: 'tiger',
    name: 'Tiger',
    scientificName: 'Panthera tigris',
    description: 'The largest cat species, instantly recognizable by its dark vertical stripes on reddish-orange fur.',
    vocalClue: 'Say "Roar" or make a fierce snarl!',
    vocalPhonetics: ['roar', 'snarl', 'grrr', 'rawr', 'growl'],
    gradientColors: [const Color(0xFFF83600), const Color(0xFFFE9000)],
    rarity: 3.0,
    ageRating: 2.8,
    weightRating: 4.5,
    heightRating: 3.5,
    strengthRating: 5.8,
    ageText: '15-20 Years',
    weightText: '220 kg',
    heightText: '110 cm',
    strengthText: 'Apex',
    silhouettePoints: const [
      Offset(0.15, 0.8), Offset(0.15, 0.45), Offset(0.25, 0.3), Offset(0.7, 0.3),
      Offset(0.85, 0.4), Offset(0.85, 0.8), Offset(0.65, 0.8), Offset(0.6, 0.6),
      Offset(0.4, 0.6), Offset(0.35, 0.8),
    ],
  ),
  Animal(
    id: 'bear',
    name: 'Bear',
    scientificName: 'Ursidae',
    description: 'Large, heavily built omnivorous mammals with shaggy hair, short tails, and non-retractile claws.',
    vocalClue: 'Growl deeply or say "Grr"!',
    vocalPhonetics: ['grrr', 'growl', 'grr', 'roar', 'snarl'],
    gradientColors: [const Color(0xFF330867), const Color(0xFF30CFD0)],
    rarity: 2.5,
    ageRating: 3.5,
    weightRating: 5.0,
    heightRating: 4.5,
    strengthRating: 5.5,
    ageText: '20-25 Years',
    weightText: '400 kg',
    heightText: '150 cm',
    strengthText: 'Very High',
    silhouettePoints: const [
      Offset(0.15, 0.85), Offset(0.1, 0.5), Offset(0.2, 0.25), Offset(0.5, 0.2),
      Offset(0.8, 0.25), Offset(0.85, 0.5), Offset(0.8, 0.85), Offset(0.6, 0.85),
      Offset(0.5, 0.65), Offset(0.4, 0.85),
    ],
  ),
  Animal(
    id: 'deer',
    name: 'Deer',
    scientificName: 'Cervidae',
    description: 'Graceful herbivores characterized by branching antlers which are shed and regrown annually.',
    vocalClue: 'Say "Bellow" or mimic a soft snort!',
    vocalPhonetics: ['bellow', 'snort', 'grunt', 'bleat'],
    gradientColors: [const Color(0xFFE6B980), const Color(0xFFEACDA3)],
    rarity: 2.0,
    ageRating: 2.0,
    weightRating: 2.8,
    heightRating: 3.5,
    strengthRating: 3.0,
    ageText: '10-12 Years',
    weightText: '120 kg',
    heightText: '100 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.2, 0.85), Offset(0.25, 0.4), Offset(0.15, 0.2), Offset(0.18, 0.05),
      Offset(0.25, 0.15), Offset(0.35, 0.2), Offset(0.5, 0.35), Offset(0.8, 0.35),
      Offset(0.85, 0.85), Offset(0.75, 0.85), Offset(0.68, 0.55), Offset(0.35, 0.55),
      Offset(0.3, 0.85),
    ],
  ),
  Animal(
    id: 'monkey',
    name: 'Monkey',
    scientificName: 'Simiiformes',
    description: 'An active, agile primate. Most species are arboreal, possessing clever problem-solving skills.',
    vocalClue: 'Say "Ooh Ooh Aah Aah"!',
    vocalPhonetics: ['ooh', 'aah', 'oohaah', 'ohoh', 'oohoohaahaah', 'screech'],
    gradientColors: [const Color(0xFFFEE140), const Color(0xFFFA709A)],
    rarity: 1.8,
    ageRating: 3.0,
    weightRating: 1.8,
    heightRating: 2.2,
    strengthRating: 2.8,
    ageText: '15-20 Years',
    weightText: '15 kg',
    heightText: '70 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.2, 0.85), Offset(0.25, 0.5), Offset(0.2, 0.3), Offset(0.35, 0.15),
      Offset(0.5, 0.15), Offset(0.65, 0.3), Offset(0.6, 0.5), Offset(0.65, 0.85),
      Offset(0.85, 0.7), Offset(0.7, 0.85), Offset(0.45, 0.85),
    ],
  ),
  Animal(
    id: 'fox',
    name: 'Fox',
    scientificName: 'Vulpes vulpes',
    description: 'A small, omnivorous, clever canine with a bushy tail, pointed ears, and a triangular muzzle.',
    vocalClue: 'Yip quickly or ask "What does the fox say?"',
    vocalPhonetics: ['yip', 'bark', 'screech', 'ringdingding', 'wa-pa-pa-pa-pa-pa-pow'],
    gradientColors: [const Color(0xFFFF9E7A), const Color(0xFFF9D423)],
    rarity: 2.2,
    ageRating: 1.5,
    weightRating: 1.5,
    heightRating: 1.8,
    strengthRating: 2.2,
    ageText: '3-5 Years',
    weightText: '6 kg',
    heightText: '40 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.15, 0.8), Offset(0.2, 0.5), Offset(0.1, 0.25), Offset(0.3, 0.2),
      Offset(0.45, 0.35), Offset(0.7, 0.35), Offset(0.85, 0.5), Offset(0.9, 0.8),
      Offset(0.75, 0.8),
    ],
  ),
  Animal(
    id: 'penguin',
    name: 'Penguin',
    scientificName: 'Spheniscidae',
    description: 'A flightless aquatic bird native to the Southern Hemisphere, adapted to swimming with wing-flippers.',
    vocalClue: 'Say "Honk" or make a squawking chirp!',
    vocalPhonetics: ['honk', 'squawk', 'chirp', 'peep'],
    gradientColors: [const Color(0xFF2C3E50), const Color(0xFFFD746C)],
    rarity: 2.0,
    ageRating: 2.8,
    weightRating: 2.0,
    heightRating: 2.5,
    strengthRating: 2.0,
    ageText: '15-20 Years',
    weightText: '30 kg',
    heightText: '110 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.3, 0.85), Offset(0.25, 0.5), Offset(0.35, 0.2), Offset(0.45, 0.1),
      Offset(0.55, 0.1), Offset(0.65, 0.2), Offset(0.75, 0.5), Offset(0.7, 0.85),
    ],
  ),
  Animal(
    id: 'frog',
    name: 'Frog',
    scientificName: 'Anura',
    description: 'A tailless amphibian with short squat body, bulging eyes, and long webbed hind legs for jumping.',
    vocalClue: 'Say "Ribbit" or croak!',
    vocalPhonetics: ['ribbit', 'croak', 'kwaak', 'gribbit'],
    gradientColors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    rarity: 1.5,
    ageRating: 1.8,
    weightRating: 0.8,
    heightRating: 0.8,
    strengthRating: 1.5,
    ageText: '5-10 Years',
    weightText: '200 g',
    heightText: '10 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.15, 0.6), Offset(0.25, 0.4), Offset(0.5, 0.35),
      Offset(0.75, 0.4), Offset(0.85, 0.6), Offset(0.8, 0.8), Offset(0.5, 0.85),
    ],
  ),
  Animal(
    id: 'turtle',
    name: 'Turtle',
    scientificName: 'Testudines',
    description: 'An ancient reptile sheltered by a heavy, protective bony or cartilaginous shell developed from ribs.',
    vocalClue: 'Say "Hiss" or make a slow breath sound!',
    vocalPhonetics: ['hiss', 'breath', 'sigh', 'grunt'],
    gradientColors: [const Color(0xFF134E5E), const Color(0xFF71B280)],
    rarity: 2.2,
    ageRating: 5.5,
    weightRating: 3.5,
    heightRating: 2.5,
    strengthRating: 2.8,
    ageText: '80-120 Years',
    weightText: '130 kg',
    heightText: '90 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.1, 0.7), Offset(0.2, 0.4), Offset(0.5, 0.3), Offset(0.8, 0.4),
      Offset(0.9, 0.55), Offset(0.8, 0.7), Offset(0.5, 0.75),
    ],
  ),

  // TIER 3 - RARE (Stages 21-30)
  Animal(
    id: 'dolphin',
    name: 'Dolphin',
    scientificName: 'Delphinidae',
    description: 'Highly intelligent marine mammals known for their playful nature, clicks, and echo-location skills.',
    vocalClue: 'Make a high-pitched click or say "Click-click"!',
    vocalPhonetics: ['click', 'whistle', 'squeak', 'clickclick'],
    gradientColors: [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    rarity: 3.5,
    ageRating: 3.5,
    weightRating: 4.2,
    heightRating: 4.0,
    strengthRating: 4.0,
    ageText: '25-30 Years',
    weightText: '200 kg',
    heightText: '250 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.1, 0.6), Offset(0.3, 0.4), Offset(0.5, 0.2), Offset(0.7, 0.35),
      Offset(0.9, 0.5), Offset(0.75, 0.6), Offset(0.5, 0.6), Offset(0.3, 0.65),
    ],
  ),
  Animal(
    id: 'kangaroo',
    name: 'Kangaroo',
    scientificName: 'Macropodidae',
    description: 'An Australian marsupial with powerful hind legs for hopping, a muscular tail, and a baby pouch.',
    vocalClue: 'Say "Chortle" or make a clicking grunt!',
    vocalPhonetics: ['grunt', 'cough', 'click', 'chortle'],
    gradientColors: [const Color(0xFFE29587), const Color(0xFFD66D75)],
    rarity: 3.2,
    ageRating: 2.0,
    weightRating: 2.8,
    heightRating: 3.8,
    strengthRating: 4.2,
    ageText: '8-12 Years',
    weightText: '60 kg',
    heightText: '150 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.2, 0.85), Offset(0.25, 0.5), Offset(0.18, 0.25), Offset(0.25, 0.1),
      Offset(0.32, 0.25), Offset(0.4, 0.4), Offset(0.6, 0.5), Offset(0.8, 0.85),
      Offset(0.4, 0.85),
    ],
  ),
  Animal(
    id: 'koala',
    name: 'Koala',
    scientificName: 'Phascolarctos cinereus',
    description: 'An arboreal herbivorous marsupial native to Australia, feeding almost exclusively on eucalyptus leaves.',
    vocalClue: 'Say "Snort" or make a low bellowing sound!',
    vocalPhonetics: ['snort', 'bellow', 'grunt', 'snore'],
    gradientColors: [const Color(0xFFD3CBB8), const Color(0xFF6D6027)],
    rarity: 3.5,
    ageRating: 2.2,
    weightRating: 1.8,
    heightRating: 2.0,
    strengthRating: 2.0,
    ageText: '13-18 Years',
    weightText: '10 kg',
    heightText: '70 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.25, 0.8), Offset(0.2, 0.5), Offset(0.15, 0.3), Offset(0.3, 0.15),
      Offset(0.5, 0.2), Offset(0.7, 0.15), Offset(0.85, 0.3), Offset(0.8, 0.8),
    ],
  ),
  Animal(
    id: 'panda',
    name: 'Giant Panda',
    scientificName: 'Ailuropoda melanoleuca',
    description: 'A large bear native to south central China, famous for its black-and-white coat and love for bamboo.',
    vocalClue: 'Say "Squeak" or bleat like a goat!',
    vocalPhonetics: ['bleat', 'squeak', 'honk', 'growl'],
    gradientColors: [const Color(0xFF3E5151), const Color(0xFFDECBA4)],
    rarity: 4.0,
    ageRating: 3.0,
    weightRating: 4.0,
    heightRating: 3.5,
    strengthRating: 4.5,
    ageText: '20 Years',
    weightText: '110 kg',
    heightText: '150 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.15, 0.5), Offset(0.25, 0.25), Offset(0.75, 0.25),
      Offset(0.85, 0.5), Offset(0.8, 0.8), Offset(0.5, 0.85),
    ],
  ),
  Animal(
    id: 'shark',
    name: 'Great White Shark',
    scientificName: 'Carcharodon carcharias',
    description: 'A large apex marine predator with torpedo-shaped body and rows of sharp, triangular teeth.',
    vocalClue: 'Make a silent swishing breath sound!',
    vocalPhonetics: ['swish', 'breath', 'hiss', 'none'],
    gradientColors: [const Color(0xFF141E30), const Color(0xFF243B55)],
    rarity: 4.2,
    ageRating: 5.0,
    weightRating: 5.5,
    heightRating: 5.0,
    strengthRating: 5.8,
    ageText: '70 Years',
    weightText: '1,100 kg',
    heightText: '450 cm',
    strengthText: 'Apex',
    silhouettePoints: const [
      Offset(0.1, 0.5), Offset(0.3, 0.35), Offset(0.5, 0.1), Offset(0.6, 0.35),
      Offset(0.9, 0.5), Offset(0.6, 0.6), Offset(0.4, 0.7), Offset(0.2, 0.6),
    ],
  ),
  Animal(
    id: 'eagle',
    name: 'Golden Eagle',
    scientificName: 'Aquila chrysaetos',
    description: 'A powerful bird of prey with massive wingspan, sharp vision, and strong curved talons.',
    vocalClue: 'Say "Screech" in a sharp tone!',
    vocalPhonetics: ['screech', 'shriek', 'caw', 'kree'],
    gradientColors: [const Color(0xFF5C258D), const Color(0xFF4389A2)],
    rarity: 3.8,
    ageRating: 3.0,
    weightRating: 1.5,
    heightRating: 2.2,
    strengthRating: 3.5,
    ageText: '20-25 Years',
    weightText: '4.5 kg',
    heightText: '80 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.3, 0.8), Offset(0.1, 0.5), Offset(0.3, 0.3), Offset(0.5, 0.15),
      Offset(0.7, 0.3), Offset(0.9, 0.5), Offset(0.7, 0.8),
    ],
  ),
  Animal(
    id: 'owl',
    name: 'Great Horned Owl',
    scientificName: 'Bubo virginianus',
    description: 'A nocturnal bird of prey with large forward-facing eyes, hawk-like beak, and silent flight feathers.',
    vocalClue: 'Say "Hoot" twice!',
    vocalPhonetics: ['hoot', 'hoothoot', 'hoo', 'hut'],
    gradientColors: [const Color(0xFF200122), const Color(0xFF6F0000)],
    rarity: 3.0,
    ageRating: 2.5,
    weightRating: 1.2,
    heightRating: 1.8,
    strengthRating: 3.0,
    ageText: '12-15 Years',
    weightText: '1.4 kg',
    heightText: '55 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.3, 0.8), Offset(0.25, 0.4), Offset(0.2, 0.15), Offset(0.35, 0.25),
      Offset(0.5, 0.2), Offset(0.65, 0.25), Offset(0.8, 0.15), Offset(0.75, 0.4),
      Offset(0.7, 0.8),
    ],
  ),
  Animal(
    id: 'wolf',
    name: 'Gray Wolf',
    scientificName: 'Canis lupus',
    description: 'A pack-hunting carnivore and ancestor of domestic dogs, known for its strategic coordination and howling.',
    vocalClue: 'Howl like a wolf or say "Awoo"!',
    vocalPhonetics: ['awoo', 'howl', 'awu', 'grrr'],
    gradientColors: [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
    rarity: 3.5,
    ageRating: 2.0,
    weightRating: 2.8,
    heightRating: 2.8,
    strengthRating: 4.5,
    ageText: '6-8 Years',
    weightText: '40 kg',
    heightText: '80 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.15, 0.8), Offset(0.2, 0.5), Offset(0.1, 0.3), Offset(0.3, 0.2),
      Offset(0.5, 0.3), Offset(0.75, 0.3), Offset(0.85, 0.5), Offset(0.8, 0.8),
    ],
  ),
  Animal(
    id: 'cheetah',
    name: 'Cheetah',
    scientificName: 'Acinonyx jubatus',
    description: 'The fastest land animal on Earth, built for short bursts of extreme speed with semi-retractable claws.',
    vocalClue: 'Say "Chirp" or make a high purring hiss!',
    vocalPhonetics: ['chirp', 'purr', 'hiss', 'growl'],
    gradientColors: [const Color(0xFFEDDE5D), const Color(0xFFF09819)],
    rarity: 3.8,
    ageRating: 2.0,
    weightRating: 2.8,
    heightRating: 2.8,
    strengthRating: 4.0,
    ageText: '10-12 Years',
    weightText: '50 kg',
    heightText: '80 cm',
    strengthText: 'High Speed',
    silhouettePoints: const [
      Offset(0.15, 0.8), Offset(0.15, 0.4), Offset(0.25, 0.2), Offset(0.5, 0.25),
      Offset(0.7, 0.3), Offset(0.85, 0.4), Offset(0.8, 0.8),
    ],
  ),
  Animal(
    id: 'zebra',
    name: 'Plains Zebra',
    scientificName: 'Equus quagga',
    description: 'An African wild horse characterized by unique black and white striped coats that deter biting flies.',
    vocalClue: 'Make a whinny bray or say "Bark"!',
    vocalPhonetics: ['bray', 'bark', 'neigh', 'snort'],
    gradientColors: [const Color(0xFF3A3D40), const Color(0xFF181719)],
    rarity: 3.2,
    ageRating: 3.0,
    weightRating: 4.2,
    heightRating: 4.2,
    strengthRating: 4.0,
    ageText: '20-25 Years',
    weightText: '300 kg',
    heightText: '130 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.15, 0.8), Offset(0.2, 0.4), Offset(0.1, 0.15), Offset(0.25, 0.05),
      Offset(0.35, 0.15), Offset(0.45, 0.35), Offset(0.8, 0.35), Offset(0.85, 0.8),
    ],
  ),

  // TIER 4 - EXOTIC (Stages 31-40)
  Animal(
    id: 'chameleon',
    name: 'Veiled Chameleon',
    scientificName: 'Chamaeleo calyptratus',
    description: 'A specialized lizard with zygodactylous feet, independently mobile eyes, and rapid color-changing skin.',
    vocalClue: 'Say "Hiss" softly!',
    vocalPhonetics: ['hiss', 'his', 'none'],
    gradientColors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
    rarity: 4.5,
    ageRating: 1.8,
    weightRating: 0.8,
    heightRating: 1.2,
    strengthRating: 1.5,
    ageText: '5-8 Years',
    weightText: '150 g',
    heightText: '45 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.2, 0.7), Offset(0.1, 0.5), Offset(0.2, 0.3), Offset(0.5, 0.3),
      Offset(0.8, 0.4), Offset(0.9, 0.6), Offset(0.7, 0.7),
    ],
  ),
  Animal(
    id: 'sloth',
    name: 'Three-Toed Sloth',
    scientificName: 'Bradypus',
    description: 'Slow-moving arboreal mammals of Central/South America, spending their lives hanging upside down in trees.',
    vocalClue: 'Sigh deeply or make a slow whistling "Ahee"!',
    vocalPhonetics: ['ahee', 'sigh', 'whistle', 'none'],
    gradientColors: [const Color(0xFF8D99AE), const Color(0xFF2B2D42)],
    rarity: 4.2,
    ageRating: 3.5,
    weightRating: 1.5,
    heightRating: 1.8,
    strengthRating: 2.0,
    ageText: '25-30 Years',
    weightText: '4.5 kg',
    heightText: '60 cm',
    strengthText: 'Very Low',
    silhouettePoints: const [
      Offset(0.25, 0.8), Offset(0.2, 0.5), Offset(0.3, 0.3), Offset(0.5, 0.25),
      Offset(0.7, 0.3), Offset(0.8, 0.5), Offset(0.75, 0.8),
    ],
  ),
  Animal(
    id: 'flamingo',
    name: 'Greater Flamingo',
    scientificName: 'Phoenicopterus roseus',
    description: 'A tall wading bird with bright pink feathers, webbed feet, and a unique downward-curved filtering beak.',
    vocalClue: 'Say "Honk" like a goose!',
    vocalPhonetics: ['honk', 'nasal', 'squawk', 'caw'],
    gradientColors: [const Color(0xFFEC008C), const Color(0xFFFC6767)],
    rarity: 4.0,
    ageRating: 3.5,
    weightRating: 1.2,
    heightRating: 4.2,
    strengthRating: 2.0,
    ageText: '20-30 Years',
    weightText: '3.5 kg',
    heightText: '130 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.35, 0.85), Offset(0.3, 0.6), Offset(0.4, 0.4), Offset(0.35, 0.2),
      Offset(0.45, 0.05), Offset(0.5, 0.15), Offset(0.45, 0.35), Offset(0.65, 0.45),
      Offset(0.55, 0.85),
    ],
  ),
  Animal(
    id: 'platypus',
    name: 'Platypus',
    scientificName: 'Ornithorhynchus anatinus',
    description: 'A semi-aquatic egg-laying mammal native to eastern Australia, with duck bill, beaver tail, and otter feet.',
    vocalClue: 'Make a growling click or say "Growl"!',
    vocalPhonetics: ['growl', 'click', 'grr', 'none'],
    gradientColors: [const Color(0xFF1F4037), const Color(0xFF99F2C8)],
    rarity: 4.8,
    ageRating: 2.2,
    weightRating: 1.0,
    heightRating: 1.2,
    strengthRating: 2.0,
    ageText: '12 Years',
    weightText: '1.5 kg',
    heightText: '50 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.15, 0.65), Offset(0.2, 0.45), Offset(0.5, 0.35), Offset(0.8, 0.45),
      Offset(0.85, 0.6), Offset(0.5, 0.65),
    ],
  ),
  Animal(
    id: 'seahorse',
    name: 'Seahorse',
    scientificName: 'Hippocampus',
    description: 'A small marine fish with an upright profile, horse-like head, prehensile tail, and armor-like plates.',
    vocalClue: 'Say "Click" quickly!',
    vocalPhonetics: ['click', 'klik', 'none'],
    gradientColors: [const Color(0xFFF3904F), const Color(0xFF3B4371)],
    rarity: 4.5,
    ageRating: 1.2,
    weightRating: 0.2,
    heightRating: 1.0,
    strengthRating: 1.0,
    ageText: '1-5 Years',
    weightText: '50 g',
    heightText: '15 cm',
    strengthText: 'Weak',
    silhouettePoints: const [
      Offset(0.4, 0.85), Offset(0.3, 0.7), Offset(0.35, 0.4), Offset(0.25, 0.25),
      Offset(0.4, 0.1), Offset(0.5, 0.2), Offset(0.45, 0.35), Offset(0.55, 0.5),
      Offset(0.5, 0.7),
    ],
  ),
  Animal(
    id: 'octopus',
    name: 'Common Octopus',
    scientificName: 'Octopus vulgaris',
    description: 'A soft-bodied, eight-limbed mollusc. Renowned for its problem-solving abilities and camouflage.',
    vocalClue: 'Make a wet bubbling sound or say "Gurgle"!',
    vocalPhonetics: ['gurgle', 'bubble', 'splosh', 'none'],
    gradientColors: [const Color(0xFFDA4453), const Color(0xFF89216B)],
    rarity: 4.5,
    ageRating: 1.2,
    weightRating: 2.0,
    heightRating: 2.2,
    strengthRating: 3.5,
    ageText: '1-2 Years',
    weightText: '10 kg',
    heightText: '90 cm',
    strengthText: 'Medium',
    silhouettePoints: const [
      Offset(0.3, 0.8), Offset(0.1, 0.6), Offset(0.2, 0.4), Offset(0.4, 0.25),
      Offset(0.6, 0.25), Offset(0.8, 0.4), Offset(0.9, 0.6), Offset(0.7, 0.8),
    ],
  ),
  Animal(
    id: 'peacock',
    name: 'Indian Peafowl',
    scientificName: 'Pavo crestatus',
    description: 'A colorful pheasant species, legendary for the male\'s spectacular fan of glowing eye-spotted tail feathers.',
    vocalClue: 'Say "Ka-aan" in a loud screech!',
    vocalPhonetics: ['kaan', 'screech', 'squawk', 'caw'],
    gradientColors: [const Color(0xFF0052D4), const Color(0xFF4364F7), const Color(0xFF6FB1FC)],
    rarity: 4.0,
    ageRating: 2.8,
    weightRating: 1.5,
    heightRating: 2.5,
    strengthRating: 2.2,
    ageText: '15-20 Years',
    weightText: '5 kg',
    heightText: '100 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.3, 0.8), Offset(0.2, 0.5), Offset(0.25, 0.3), Offset(0.15, 0.2),
      Offset(0.3, 0.1), Offset(0.4, 0.3), Offset(0.7, 0.4), Offset(0.85, 0.8),
    ],
  ),
  Animal(
    id: 'lemur',
    name: 'Ring-Tailed Lemur',
    scientificName: 'Lemur catta',
    description: 'A primate native to Madagascar, featuring a black-and-white ringed tail and expressive eyes.',
    vocalClue: 'Purr loudly or say "Chirp"!',
    vocalPhonetics: ['chirp', 'purr', 'grunt', 'howl'],
    gradientColors: [const Color(0xFF616161), const Color(0xFF9BC5C3)],
    rarity: 4.2,
    ageRating: 2.8,
    weightRating: 1.2,
    heightRating: 1.8,
    strengthRating: 2.0,
    ageText: '16-19 Years',
    weightText: '2.5 kg',
    heightText: '40 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.25, 0.8), Offset(0.2, 0.5), Offset(0.25, 0.3), Offset(0.35, 0.2),
      Offset(0.5, 0.35), Offset(0.7, 0.3), Offset(0.8, 0.5), Offset(0.75, 0.8),
    ],
  ),
  Animal(
    id: 'meerkat',
    name: 'Meerkat',
    scientificName: 'Suricata suricatta',
    description: 'A small, highly cooperative mongoose species living in underground tunnels in Kalahari clans.',
    vocalClue: 'Say "Chirp" or make a high-pitched bark!',
    vocalPhonetics: ['chirp', 'bark', 'chatter', 'yip'],
    gradientColors: [const Color(0xFFCC95C0), const Color(0xFFDBD4B4), const Color(0xFF7AA1D2)],
    rarity: 4.0,
    ageRating: 2.2,
    weightRating: 0.8,
    heightRating: 1.0,
    strengthRating: 1.8,
    ageText: '12-14 Years',
    weightText: '800 g',
    heightText: '30 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.4, 0.85), Offset(0.35, 0.5), Offset(0.4, 0.2), Offset(0.5, 0.1),
      Offset(0.6, 0.2), Offset(0.65, 0.5), Offset(0.6, 0.85),
    ],
  ),
  Animal(
    id: 'hedgehog',
    name: 'Four-Toed Hedgehog',
    scientificName: 'Atelerix albiventris',
    description: 'A small spiny mammal that rolls into a tight protective ball when threatened by predators.',
    vocalClue: 'Grump softly or say "Snuffle"!',
    vocalPhonetics: ['snuffle', 'grunt', 'hiss', 'sniff'],
    gradientColors: [const Color(0xFFFFECEF), const Color(0xFFC890A7)],
    rarity: 4.0,
    ageRating: 1.5,
    weightRating: 0.6,
    heightRating: 0.8,
    strengthRating: 1.5,
    ageText: '3-5 Years',
    weightText: '400 g',
    heightText: '18 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.2, 0.75), Offset(0.15, 0.55), Offset(0.25, 0.35), Offset(0.5, 0.3),
      Offset(0.75, 0.35), Offset(0.85, 0.55), Offset(0.8, 0.75), Offset(0.5, 0.8),
    ],
  ),

  // TIER 5 - OBSCURE & LEGENDARY (Stages 41-50)
  Animal(
    id: 'axolotl',
    name: 'Axolotl',
    scientificName: 'Ambystoma mexicanum',
    description: 'A critically endangered Mexican neotenic salamander that retains its aquatic larval form and regenerates limbs.',
    vocalClue: 'Say "Gloop" or blow a bubble!',
    vocalPhonetics: ['gloop', 'bubble', 'pop', 'glup'],
    gradientColors: [const Color(0xFFFFB6C1), const Color(0xFFFF69B4)],
    rarity: 5.5,
    ageRating: 2.2,
    weightRating: 0.6,
    heightRating: 1.0,
    strengthRating: 1.5,
    ageText: '10-15 Years',
    weightText: '150 g',
    heightText: '23 cm',
    strengthText: 'Low (High Regen)',
    silhouettePoints: const [
      Offset(0.2, 0.7), Offset(0.15, 0.45), Offset(0.25, 0.25), Offset(0.35, 0.35),
      Offset(0.5, 0.3), Offset(0.65, 0.35), Offset(0.75, 0.25), Offset(0.85, 0.45),
      Offset(0.8, 0.7), Offset(0.5, 0.75),
    ],
  ),
  Animal(
    id: 'shoebill',
    name: 'Shoebill Stork',
    scientificName: 'Balaeniceps rex',
    description: 'A prehistoric-looking stork of East African swamps, notorious for its massive shoe-like bill and machine-gun bill clattering.',
    vocalClue: 'Clatter your teeth loudly or say "Clack-clack"!',
    vocalPhonetics: ['clack', 'clatter', 'snap', 'clackclack', 'toktok'],
    gradientColors: [const Color(0xFF4A569D), const Color(0xFFDC2424)],
    rarity: 5.8,
    ageRating: 4.0,
    weightRating: 1.8,
    heightRating: 4.5,
    strengthRating: 4.0,
    ageText: '35 Years',
    weightText: '6 kg',
    heightText: '120 cm',
    strengthText: 'Intimidating',
    silhouettePoints: const [
      Offset(0.3, 0.85), Offset(0.2, 0.5), Offset(0.15, 0.3), Offset(0.3, 0.1),
      Offset(0.45, 0.25), Offset(0.5, 0.4), Offset(0.7, 0.45), Offset(0.6, 0.85),
    ],
  ),
  Animal(
    id: 'pangolin',
    name: 'Sunda Pangolin',
    scientificName: 'Manis javanica',
    description: 'The world\'s only scaly mammal, rolling into a armored shield-like sphere. Highly poached for its keratin scales.',
    vocalClue: 'Say "Hiss" or snuffle like a vacuum!',
    vocalPhonetics: ['hiss', 'snuffle', 'snort', 'none'],
    gradientColors: [const Color(0xFFE2D1C3), const Color(0xFFFDFCFB)],
    rarity: 5.8,
    ageRating: 2.8,
    weightRating: 2.0,
    heightRating: 2.2,
    strengthRating: 3.5,
    ageText: '20 Years',
    weightText: '8 kg',
    heightText: '90 cm',
    strengthText: 'Ultimate Defense',
    silhouettePoints: const [
      Offset(0.2, 0.75), Offset(0.15, 0.55), Offset(0.3, 0.35), Offset(0.6, 0.35),
      Offset(0.85, 0.55), Offset(0.8, 0.75),
    ],
  ),
  Animal(
    id: 'greenland_shark',
    name: 'Greenland Shark',
    scientificName: 'Somniosus microcephalus',
    description: 'The longest-lived vertebrate on Earth, dwelling in deep Arctic waters. Their tissue contains natural antifreeze.',
    vocalClue: 'Deep aquatic hum or say "Hummm"!',
    vocalPhonetics: ['hum', 'humm', 'deep', 'none'],
    gradientColors: [const Color(0xFF0D2C54), const Color(0xFFC1CAD6)],
    rarity: 6.0,
    ageRating: 6.0,
    weightRating: 5.5,
    heightRating: 5.5,
    strengthRating: 5.0,
    ageText: '400 Years',
    weightText: '1,000 kg',
    heightText: '500 cm',
    strengthText: 'Apex Deep',
    silhouettePoints: const [
      Offset(0.1, 0.5), Offset(0.3, 0.35), Offset(0.5, 0.15), Offset(0.6, 0.35),
      Offset(0.9, 0.5), Offset(0.6, 0.65), Offset(0.4, 0.75), Offset(0.2, 0.65),
    ],
  ),
  Animal(
    id: 'narwhal',
    name: 'Narwhal',
    scientificName: 'Monodon monoceros',
    description: 'The Unicorn of the Sea. An Arctic whale characterized by a long, spiraled sensory tusk (which is actually a tooth).',
    vocalClue: 'Say "Click-click whistle"!',
    vocalPhonetics: ['click', 'whistle', 'chirp', 'clickclick'],
    gradientColors: [const Color(0xFF649173), const Color(0xFFDBD5A4)],
    rarity: 5.5,
    ageRating: 4.5,
    weightRating: 5.2,
    heightRating: 5.0,
    strengthRating: 4.5,
    ageText: '50 Years',
    weightText: '900 kg',
    heightText: '450 cm',
    strengthText: 'High',
    silhouettePoints: const [
      Offset(0.02, 0.48), Offset(0.25, 0.4), Offset(0.5, 0.3), Offset(0.7, 0.45),
      Offset(0.9, 0.55), Offset(0.7, 0.65), Offset(0.5, 0.6), Offset(0.3, 0.5),
    ],
  ),
  Animal(
    id: 'tardigrade',
    name: 'Tardigrade',
    scientificName: 'Tardigrada',
    description: 'Also known as the Water Bear. A microscopic eight-legged animal capable of surviving extreme outer space vacuums and boiling heat.',
    vocalClue: 'Squeal microscopic vibrations or say "Bzzt"!',
    vocalPhonetics: ['bzzt', 'buzz', 'beep', 'micro', 'none'],
    gradientColors: [const Color(0xFF757F9A), const Color(0xFFD7DDE8)],
    rarity: 6.0,
    ageRating: 4.8,
    weightRating: 0.1,
    heightRating: 0.1,
    strengthRating: 6.0,
    ageText: '30 Years (Dry)',
    weightText: '0.0001 g',
    heightText: '0.5 mm',
    strengthText: 'Indestructible',
    silhouettePoints: const [
      Offset(0.2, 0.75), Offset(0.15, 0.5), Offset(0.25, 0.25), Offset(0.75, 0.25),
      Offset(0.85, 0.5), Offset(0.8, 0.75), Offset(0.65, 0.8), Offset(0.5, 0.65),
      Offset(0.35, 0.8),
    ],
  ),
  Animal(
    id: 'cassowary',
    name: 'Southern Cassowary',
    scientificName: 'Casuarius casuarius',
    description: 'The world\'s most dangerous bird. Flightless, possessing a bony head helmet (casque) and dagger-like inner claws.',
    vocalClue: 'Deep rumbling growl or say "Boom"!',
    vocalPhonetics: ['boom', 'rumble', 'growl', 'grunt'],
    gradientColors: [const Color(0xFF1D976C), const Color(0xFF93F9B9)],
    rarity: 5.5,
    ageRating: 4.0,
    weightRating: 2.8,
    heightRating: 4.5,
    strengthRating: 5.5,
    ageText: '35-40 Years',
    weightText: '60 kg',
    heightText: '155 cm',
    strengthText: 'Fierce Kick',
    silhouettePoints: const [
      Offset(0.3, 0.85), Offset(0.2, 0.5), Offset(0.15, 0.3), Offset(0.25, 0.1),
      Offset(0.35, 0.2), Offset(0.4, 0.4), Offset(0.6, 0.5), Offset(0.7, 0.85),
    ],
  ),
  Animal(
    id: 'blobfish',
    name: 'Blobfish',
    scientificName: 'Psychrolutes marcidus',
    description: 'A deep sea fish that looks like a gelatinous blob at sea level due to lack of bones and heavy water pressure support.',
    vocalClue: 'Say "Splat" or make a wet sigh!',
    vocalPhonetics: ['splat', 'sigh', 'blob', 'gloop'],
    gradientColors: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
    rarity: 5.8,
    ageRating: 5.0,
    weightRating: 2.0,
    heightRating: 1.2,
    strengthRating: 1.0,
    ageText: '130 Years',
    weightText: '9 kg',
    heightText: '30 cm',
    strengthText: 'Fragile',
    silhouettePoints: const [
      Offset(0.2, 0.7), Offset(0.1, 0.5), Offset(0.2, 0.3), Offset(0.5, 0.25),
      Offset(0.8, 0.35), Offset(0.9, 0.55), Offset(0.7, 0.7), Offset(0.5, 0.75),
    ],
  ),
  Animal(
    id: 'capybara',
    name: 'Capybara',
    scientificName: 'Hydrochoerus hydrochaeris',
    description: 'The largest living rodent in the world, highly social and famous for its remarkably calm, friendly disposition.',
    vocalClue: 'Say "Ok I pull up" or grunt softly!',
    vocalPhonetics: ['grunt', 'click', 'bark', 'pullup', 'capybara'],
    gradientColors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    rarity: 5.0,
    ageRating: 2.0,
    weightRating: 2.8,
    heightRating: 2.2,
    strengthRating: 2.8,
    ageText: '8-10 Years',
    weightText: '50 kg',
    heightText: '60 cm',
    strengthText: 'Maximum Chill',
    silhouettePoints: const [
      Offset(0.2, 0.8), Offset(0.15, 0.5), Offset(0.25, 0.3), Offset(0.7, 0.3),
      Offset(0.85, 0.5), Offset(0.8, 0.8), Offset(0.5, 0.85),
    ],
  ),
  Animal(
    id: 'quokka',
    name: 'Quokka',
    scientificName: 'Setonix brachyurus',
    description: 'A small Australian wallaby known as the "world\'s happiest animal" due to its constant smiling expression.',
    vocalClue: 'Squeak happily or say "Smile"!',
    vocalPhonetics: ['squeak', 'smile', 'chatter', 'quokka'],
    gradientColors: [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
    rarity: 5.2,
    ageRating: 2.0,
    weightRating: 1.5,
    heightRating: 1.5,
    strengthRating: 1.8,
    ageText: '10 Years',
    weightText: '3.5 kg',
    heightText: '45 cm',
    strengthText: 'Low',
    silhouettePoints: const [
      Offset(0.25, 0.8), Offset(0.2, 0.5), Offset(0.25, 0.35), Offset(0.35, 0.25),
      Offset(0.5, 0.3), Offset(0.65, 0.25), Offset(0.75, 0.35), Offset(0.8, 0.5),
      Offset(0.75, 0.8),
    ],
  ),
];
