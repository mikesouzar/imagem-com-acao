import 'dart:math';

import '../models/game_config.dart';
import '../models/word_card.dart';

class WordBank {
  static final _random = Random();

  static List<WordCard> getWords({Difficulty? difficulty, String? category}) {
    return _allWords.where((card) {
      if (difficulty != null && card.difficulty != difficulty) return false;
      if (category != null && card.category != category) return false;
      return true;
    }).toList();
  }

  static WordCard getRandomWord({Difficulty? difficulty}) {
    final filtered = difficulty != null
        ? _allWords.where((c) => c.difficulty == difficulty).toList()
        : _allWords;
    return filtered[_random.nextInt(filtered.length)];
  }

  /// Maps a word category to the corresponding board game category letter.
  /// P = Pessoa/Lugar/Animal, O = Objeto, A = Ação, L = Lazer
  static String mapToBoardCategory(String category) {
    return switch (category) {
      'Animal' || 'Profissão' || 'Lugar' || 'Personagem' => 'P',
      'Objeto' || 'Comida' => 'O',
      'Ação' => 'A',
      'Esporte' || 'Lazer' => 'L',
      _ => 'P', // default
    };
  }

  /// Returns all words that belong to a given board category.
  /// D = hard difficulty words, T = all words (Todos Jogam).
  static List<WordCard> getWordsForBoardCategory(String boardCat) {
    if (boardCat == 'D') {
      return getWords(difficulty: Difficulty.dificil);
    }
    if (boardCat == 'T') {
      return _allWords;
    }
    // Map board category to word categories
    final categories = switch (boardCat) {
      'P' => ['Animal', 'Profissão', 'Lugar', 'Personagem'],
      'O' => ['Objeto', 'Comida'],
      'A' => ['Ação'],
      'L' => ['Esporte', 'Lazer'],
      _ => <String>[],
    };
    return _allWords.where((w) => categories.contains(w.category)).toList();
  }

  /// Returns a single random word for the given board category.
  static WordCard getRandomWordForBoardCategory(String boardCat) {
    final words = getWordsForBoardCategory(boardCat);
    if (words.isEmpty) return getRandomWord();
    return words[_random.nextInt(words.length)];
  }

  // ---------------------------------------------------------------------------
  // Word bank: 150+ words across 9 categories and 3 difficulty levels
  // ---------------------------------------------------------------------------
  static const List<WordCard> _allWords = [
    // =========================================================================
    //  FACIL - Objeto
    // =========================================================================
    WordCard(
      word: 'Casa',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Lugar onde moramos',
    ),
    WordCard(
      word: 'Carro',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Veículo com quatro rodas',
    ),
    WordCard(
      word: 'Telefone',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Usado para fazer ligações',
    ),
    WordCard(
      word: 'Relógio',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Mostra as horas',
    ),
    WordCard(
      word: 'Cadeira',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Móvel para sentar',
    ),
    WordCard(
      word: 'Mesa',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Móvel com superfície plana',
    ),
    WordCard(
      word: 'Livro',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Tem páginas com palavras',
    ),
    WordCard(
      word: 'Chapéu',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Acessório usado na cabeça',
    ),
    WordCard(
      word: 'Óculos',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Ajuda a enxergar melhor',
    ),
    WordCard(
      word: 'Guarda-chuva',
      category: 'Objeto',
      difficulty: Difficulty.facil,
      hint: 'Protege da chuva',
    ),

    // =========================================================================
    //  FACIL - Animal
    // =========================================================================
    WordCard(
      word: 'Gato',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Felino doméstico que mia',
    ),
    WordCard(
      word: 'Cachorro',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Melhor amigo do homem',
    ),
    WordCard(
      word: 'Pássaro',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Tem asas e voa',
    ),
    WordCard(
      word: 'Peixe',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Vive na água e tem nadadeiras',
    ),
    WordCard(
      word: 'Elefante',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Maior animal terrestre, tem tromba',
    ),
    WordCard(
      word: 'Leão',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Rei da selva com juba',
    ),
    WordCard(
      word: 'Cobra',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Réptil longo e sem patas',
    ),
    WordCard(
      word: 'Borboleta',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Inseto com asas coloridas',
    ),
    WordCard(
      word: 'Tartaruga',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Animal lento com casco',
    ),
    WordCard(
      word: 'Macaco',
      category: 'Animal',
      difficulty: Difficulty.facil,
      hint: 'Primata que adora bananas',
    ),

    // =========================================================================
    //  FACIL - Profissão
    // =========================================================================
    WordCard(
      word: 'Médico',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Cuida da saúde das pessoas',
    ),
    WordCard(
      word: 'Professor',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Ensina em uma escola',
    ),
    WordCard(
      word: 'Bombeiro',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Apaga incêndios e faz resgates',
    ),
    WordCard(
      word: 'Policial',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Mantém a ordem e a segurança',
    ),
    WordCard(
      word: 'Cozinheiro',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Prepara refeições na cozinha',
    ),
    WordCard(
      word: 'Dentista',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Cuida dos dentes',
    ),
    WordCard(
      word: 'Carteiro',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Entrega cartas e encomendas',
    ),
    WordCard(
      word: 'Padeiro',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Faz pães e bolos',
    ),
    WordCard(
      word: 'Pintor',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Usa tinta e pincel para criar arte',
    ),
    WordCard(
      word: 'Motorista',
      category: 'Profissão',
      difficulty: Difficulty.facil,
      hint: 'Dirige veículos como profissão',
    ),

    // =========================================================================
    //  FACIL - Ação
    // =========================================================================
    WordCard(
      word: 'Dormir',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Fechar os olhos e descansar',
    ),
    WordCard(
      word: 'Comer',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Colocar comida na boca',
    ),
    WordCard(
      word: 'Correr',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Mover-se rápido com as pernas',
    ),
    WordCard(
      word: 'Nadar',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Mover-se dentro da água',
    ),
    WordCard(
      word: 'Dançar',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Mover o corpo no ritmo da música',
    ),
    WordCard(
      word: 'Cantar',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Produzir música com a voz',
    ),
    WordCard(
      word: 'Pular',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Saltar do chão',
    ),
    WordCard(
      word: 'Rir',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Expressão de alegria ou humor',
    ),
    WordCard(
      word: 'Chorar',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Lágrimas caem dos olhos',
    ),
    WordCard(
      word: 'Voar',
      category: 'Ação',
      difficulty: Difficulty.facil,
      hint: 'Mover-se pelo ar como um pássaro',
    ),

    // =========================================================================
    //  FACIL - Lugar
    // =========================================================================
    WordCard(
      word: 'Praia',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Areia, mar e sol',
    ),
    WordCard(
      word: 'Escola',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Lugar onde se estuda',
    ),
    WordCard(
      word: 'Hospital',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Lugar onde tratam doentes',
    ),
    WordCard(
      word: 'Parque',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Área verde para lazer',
    ),
    WordCard(
      word: 'Cinema',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Lugar para assistir filmes na tela grande',
    ),
    WordCard(
      word: 'Igreja',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Lugar de oração e culto',
    ),
    WordCard(
      word: 'Fazenda',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Propriedade rural com animais',
    ),
    WordCard(
      word: 'Mercado',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Onde se compra alimentos',
    ),
    WordCard(
      word: 'Biblioteca',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'Lugar cheio de livros para empréstimo',
    ),
    WordCard(
      word: 'Aeroporto',
      category: 'Lugar',
      difficulty: Difficulty.facil,
      hint: 'De onde os aviões decolam',
    ),

    // =========================================================================
    //  MEDIO - Objeto
    // =========================================================================
    WordCard(
      word: 'Bússola',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Instrumento que aponta para o norte',
    ),
    WordCard(
      word: 'Telescópio',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Usado para observar estrelas e planetas',
    ),
    WordCard(
      word: 'Ampulheta',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Mede o tempo com areia',
    ),
    WordCard(
      word: 'Catavento',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Gira com o vento',
    ),
    WordCard(
      word: 'Grampeador',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Prende folhas de papel com grampos',
    ),
    WordCard(
      word: 'Lanterna',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Emite luz portátil no escuro',
    ),
    WordCard(
      word: 'Martelo',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Ferramenta para bater pregos',
    ),
    WordCard(
      word: 'Violão',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Instrumento de cordas popular no Brasil',
    ),
    WordCard(
      word: 'Skate',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Prancha com rodinhas para manobras',
    ),
    WordCard(
      word: 'Patins',
      category: 'Objeto',
      difficulty: Difficulty.medio,
      hint: 'Calçado com rodas para deslizar',
    ),

    // =========================================================================
    //  MEDIO - Animal
    // =========================================================================
    WordCard(
      word: 'Camaleão',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Réptil que muda de cor',
    ),
    WordCard(
      word: 'Flamingo',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Ave rosa que fica em uma perna só',
    ),
    WordCard(
      word: 'Ornitorrinco',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Mamífero com bico de pato que bota ovos',
    ),
    WordCard(
      word: 'Polvo',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Criatura marinha com oito tentáculos',
    ),
    WordCard(
      word: 'Tubarão',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Grande predador dos oceanos com barbatana dorsal',
    ),
    WordCard(
      word: 'Águia',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Ave de rapina com visão poderosa',
    ),
    WordCard(
      word: 'Pinguim',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Ave que não voa e vive no gelo',
    ),
    WordCard(
      word: 'Cavalo-Marinho',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Peixe com formato de cavalo',
    ),
    WordCard(
      word: 'Tucano',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Ave tropical com bico enorme e colorido',
    ),
    WordCard(
      word: 'Jacaré',
      category: 'Animal',
      difficulty: Difficulty.medio,
      hint: 'Réptil grande dos rios e pântanos brasileiros',
    ),

    // =========================================================================
    //  MEDIO - Profissão
    // =========================================================================
    WordCard(
      word: 'Astronauta',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Alguém que viaja além da atmosfera da Terra',
    ),
    WordCard(
      word: 'Arqueólogo',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Estuda civilizações antigas escavando ruínas',
    ),
    WordCard(
      word: 'Mergulhador',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Trabalha debaixo da água com tanque de oxigênio',
    ),
    WordCard(
      word: 'Mágico',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Faz truques e ilusões no palco',
    ),
    WordCard(
      word: 'Pirata',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Navegador com tapa-olho e espada',
    ),
    WordCard(
      word: 'Detetive',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Investiga mistérios e resolve crimes',
    ),
    WordCard(
      word: 'Fotógrafo',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Captura imagens com uma câmera',
    ),
    WordCard(
      word: 'Surfista',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Desliza sobre ondas com uma prancha',
    ),
    WordCard(
      word: 'Equilibrista',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Anda sobre corda bamba no circo',
    ),
    WordCard(
      word: 'Jóquei',
      category: 'Profissão',
      difficulty: Difficulty.medio,
      hint: 'Pilota cavalos em corridas',
    ),

    // =========================================================================
    //  MEDIO - Ação
    // =========================================================================
    WordCard(
      word: 'Surfar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Deslizar sobre ondas do mar',
    ),
    WordCard(
      word: 'Escalar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Subir montanhas ou paredes rochosas',
    ),
    WordCard(
      word: 'Patinar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Deslizar sobre gelo ou piso com patins',
    ),
    WordCard(
      word: 'Malabarismo',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Jogar objetos para o alto e pegá-los em sequência',
    ),
    WordCard(
      word: 'Pescar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Capturar peixes com vara e anzol',
    ),
    WordCard(
      word: 'Mergulhar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Submergir na água de cabeça',
    ),
    WordCard(
      word: 'Acampar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Dormir em barraca na natureza',
    ),
    WordCard(
      word: 'Meditar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Concentrar a mente em silêncio e paz',
    ),
    WordCard(
      word: 'Fotografar',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Tirar fotos com uma câmera',
    ),
    WordCard(
      word: 'Esculpir',
      category: 'Ação',
      difficulty: Difficulty.medio,
      hint: 'Criar formas em argila, pedra ou madeira',
    ),

    // =========================================================================
    //  MEDIO - Comida
    // =========================================================================
    WordCard(
      word: 'Sushi',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Comida japonesa com arroz e peixe cru',
    ),
    WordCard(
      word: 'Brigadeiro',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Doce brasileiro de chocolate com granulado',
    ),
    WordCard(
      word: 'Pizza',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Massa redonda com queijo e molho de tomate',
    ),
    WordCard(
      word: 'Churrasco',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Carne assada na brasa, tradição gaúcha',
    ),
    WordCard(
      word: 'Feijoada',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Prato brasileiro com feijão preto e carnes',
    ),
    WordCard(
      word: 'Pipoca',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Milho estourado, companhia de cinema',
    ),
    WordCard(
      word: 'Açaí',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Fruta roxa da Amazônia servida gelada',
    ),
    WordCard(
      word: 'Tapioca',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Crepe feito de goma de mandioca',
    ),
    WordCard(
      word: 'Fondue',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Queijo ou chocolate derretido para mergulhar alimentos',
    ),
    WordCard(
      word: 'Coxinha',
      category: 'Comida',
      difficulty: Difficulty.medio,
      hint: 'Salgado brasileiro em formato de gota com frango',
    ),

    // =========================================================================
    //  DIFICIL - Objeto
    // =========================================================================
    WordCard(
      word: 'Caleidoscópio',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Tubo com espelhos que cria padrões coloridos',
    ),
    WordCard(
      word: 'Metrônomo',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Marca o tempo ritmicamente para músicos',
    ),
    WordCard(
      word: 'Sextante',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Instrumento de navegação que mede ângulos com as estrelas',
    ),
    WordCard(
      word: 'Abajur',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Luminária de mesa com cúpula decorativa',
    ),
    WordCard(
      word: 'Catapulta',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Arma medieval que lança projéteis a distância',
    ),
    WordCard(
      word: 'Periscópio',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Tubo com espelhos usado em submarinos para ver a superfície',
    ),
    WordCard(
      word: 'Astrolábio',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Antigo instrumento astronômico para medir posição de astros',
    ),
    WordCard(
      word: 'Teleprompter',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Tela transparente que mostra texto para apresentadores',
    ),
    WordCard(
      word: 'Desfibrilador',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Equipamento médico que dá choque elétrico no coração',
    ),
    WordCard(
      word: 'Holografia',
      category: 'Objeto',
      difficulty: Difficulty.dificil,
      hint: 'Imagem tridimensional feita com luz laser',
    ),

    // =========================================================================
    //  DIFICIL - Ação
    // =========================================================================
    WordCard(
      word: 'Procrastinar',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Adiar tarefas importantes repetidamente',
    ),
    WordCard(
      word: 'Improvisar',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Criar algo na hora sem planejamento',
    ),
    WordCard(
      word: 'Sonambulismo',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Caminhar enquanto está dormindo',
    ),
    WordCard(
      word: 'Hipnotizar',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Induzir alguém a um estado de transe',
    ),
    WordCard(
      word: 'Ventriloquismo',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Falar sem mover os lábios usando um boneco',
    ),
    WordCard(
      word: 'Prestidigitação',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Arte de fazer truques rápidos com as mãos',
    ),
    WordCard(
      word: 'Pantomima',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Representação teatral apenas com gestos, sem falar',
    ),
    WordCard(
      word: 'Ilusionismo',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Arte de criar ilusões visuais como mágica',
    ),
    WordCard(
      word: 'Telepatia',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Comunicação de pensamentos sem palavras',
    ),
    WordCard(
      word: 'Sabotagem',
      category: 'Ação',
      difficulty: Difficulty.dificil,
      hint: 'Destruir ou prejudicar algo de propósito em segredo',
    ),

    // =========================================================================
    //  DIFICIL - Personagem
    // =========================================================================
    WordCard(
      word: 'Frankenstein',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Cientista que criou um monstro com partes de corpos',
    ),
    WordCard(
      word: 'Cleópatra',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Famosa rainha do Egito Antigo',
    ),
    WordCard(
      word: 'Sherlock Holmes',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Detetive brilhante da literatura inglesa',
    ),
    WordCard(
      word: 'Robin Hood',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Roubava dos ricos para dar aos pobres',
    ),
    WordCard(
      word: 'Zorro',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Herói mascarado que marca a letra Z com a espada',
    ),
    WordCard(
      word: 'Napoleão',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Imperador francês de baixa estatura famoso por suas conquistas',
    ),
    WordCard(
      word: 'Medusa',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Criatura da mitologia grega com cobras no lugar do cabelo',
    ),
    WordCard(
      word: 'Minotauro',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Criatura mitológica metade homem, metade touro no labirinto',
    ),
    WordCard(
      word: 'Drácula',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Famoso vampiro da Transilvânia',
    ),
    WordCard(
      word: 'Don Quixote',
      category: 'Personagem',
      difficulty: Difficulty.dificil,
      hint: 'Cavaleiro que lutava contra moinhos de vento',
    ),

    // =========================================================================
    //  DIFICIL - Esporte
    // =========================================================================
    WordCard(
      word: 'Esgrima',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Luta com espadas finas usando máscara protetora',
    ),
    WordCard(
      word: 'Polo Aquático',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Esporte de equipe jogado na piscina com bola',
    ),
    WordCard(
      word: 'Salto com Vara',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Atleta usa uma vara flexível para pular sobre um sarrafo alto',
    ),
    WordCard(
      word: 'Lançamento de Disco',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Atleta gira o corpo e arremessa um disco pesado',
    ),
    WordCard(
      word: 'Bobsled',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Trenó de alta velocidade em pista de gelo',
    ),
    WordCard(
      word: 'Curling',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Pedra deslizando no gelo enquanto varrem o caminho',
    ),
    WordCard(
      word: 'Pentatlo',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Competição olímpica com cinco modalidades diferentes',
    ),
    WordCard(
      word: 'Canoagem',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Remar em canoa ou caiaque por rios ou lagos',
    ),
    WordCard(
      word: 'Hipismo',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Esporte praticado montado a cavalo com saltos',
    ),
    WordCard(
      word: 'Remo',
      category: 'Esporte',
      difficulty: Difficulty.dificil,
      hint: 'Equipe usa remos para impulsionar barco na água',
    ),

    // =========================================================================
    //  FACIL - Lazer
    // =========================================================================
    WordCard(
      word: 'Futebol',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Esporte mais popular do Brasil, jogado com os pés',
    ),
    WordCard(
      word: 'Carnaval',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Festa popular brasileira com fantasias e desfiles',
    ),
    WordCard(
      word: 'Novela',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Programa de TV com capítulos diários e drama',
    ),
    WordCard(
      word: 'Violão',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Instrumento de cordas tocado em rodas de música',
    ),
    WordCard(
      word: 'Dança',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Atividade de mover o corpo ao som de música',
    ),
    WordCard(
      word: 'Circo',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Espetáculo com palhaços, acrobatas e animais',
    ),
    WordCard(
      word: 'Dominó',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Jogo de peças retangulares com pontos',
    ),
    WordCard(
      word: 'Pipa',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Brinquedo de papel que voa com o vento preso a uma linha',
    ),
    WordCard(
      word: 'Desenho Animado',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Programa de TV com personagens ilustrados em movimento',
    ),
    WordCard(
      word: 'Show de Música',
      category: 'Lazer',
      difficulty: Difficulty.facil,
      hint: 'Evento ao vivo onde artistas cantam para o público',
    ),

    // =========================================================================
    //  MEDIO - Lazer
    // =========================================================================
    WordCard(
      word: 'Karaokê',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Cantar músicas lendo a letra numa tela',
    ),
    WordCard(
      word: 'Stand-up Comedy',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Espetáculo de humor com comediante sozinho no palco',
    ),
    WordCard(
      word: 'Escape Room',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Jogo onde você resolve enigmas para sair de uma sala',
    ),
    WordCard(
      word: 'Paintball',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Jogo de guerra com armas de tinta colorida',
    ),
    WordCard(
      word: 'Tirolesa',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Deslizar por um cabo suspenso entre dois pontos',
    ),
    WordCard(
      word: 'Rapel',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Descer paredes ou penhascos com corda e equipamento',
    ),
    WordCard(
      word: 'Caiaque',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Embarcação leve para remar em rios e lagos',
    ),
    WordCard(
      word: 'Frescobol',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Jogo de raquetes na praia sem rede',
    ),
    WordCard(
      word: 'Slackline',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Equilibrar-se sobre uma fita elástica esticada',
    ),
    WordCard(
      word: 'Bungee Jump',
      category: 'Lazer',
      difficulty: Difficulty.medio,
      hint: 'Pular de grande altura preso por elástico nos pés',
    ),

    // =========================================================================
    //  DIFICIL - Lazer
    // =========================================================================
    WordCard(
      word: 'Parapente',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Voar com uma asa flexível lançando-se de montanhas',
    ),
    WordCard(
      word: 'Balonismo',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Voar em um grande balão de ar quente',
    ),
    WordCard(
      word: 'Parkour',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Superar obstáculos urbanos com saltos e acrobacias',
    ),
    WordCard(
      word: 'Highline',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Andar sobre fita esticada em grande altitude',
    ),
    WordCard(
      word: 'Kitesurfe',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Deslizar na água puxado por uma pipa gigante',
    ),
    WordCard(
      word: 'Wakeboard',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Prancha rebocada por lancha fazendo manobras na água',
    ),
    WordCard(
      word: 'Motocross',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Corrida de motos em pista de terra com saltos',
    ),
    WordCard(
      word: 'Enduro',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Corrida de longa distância em terrenos difíceis',
    ),
    WordCard(
      word: 'Ultraleve',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Pequena aeronave motorizada para voo recreativo',
    ),
    WordCard(
      word: 'Asa-delta',
      category: 'Lazer',
      difficulty: Difficulty.dificil,
      hint: 'Voar pendurado em uma asa triangular rígida',
    ),
  ];
}
