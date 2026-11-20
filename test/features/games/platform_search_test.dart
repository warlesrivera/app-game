import 'package:flutter_test/flutter_test.dart';
import 'package:gamevault/features/games/domain/models/platform_search.dart';

void main() {
  test('psp trae el catálogo de esa consola', () {
    final match = PlatformSearch.resolve('PSP');
    expect(match?.label, 'PSP');
    expect(match?.platforms, '17');
    expect(match?.isCatalog, isTrue);
  });

  test('nintendo switch 2 no se confunde con switch', () {
    final match = PlatformSearch.resolve('nintendo switch 2');
    expect(match?.label, 'Nintendo Switch 2');
    expect(match?.platforms, '7');
    expect(match?.dates, isNotNull);
    expect(PlatformSearch.resolve('switch')?.label, 'Nintendo Switch');
    expect(PlatformSearch.resolve('switch')?.dates, isNull);
  });

  test('un juego más la consola busca en esa plataforma', () {
    final match = PlatformSearch.resolve('god of war psp');
    expect(match?.platforms, '17');
    expect(match?.text, 'god of war');
    expect(match?.dates, isNull);

    final onSwitch2 = PlatformSearch.resolve('mario kart switch 2');
    expect(onSwitch2?.label, 'Nintendo Switch 2');
    expect(onSwitch2?.text, 'mario kart');
    expect(onSwitch2?.dates, isNull);
  });

  test('un título normal no se toma como consola', () {
    expect(PlatformSearch.resolve('hollow knight'), isNull);
    expect(PlatformSearch.resolve('pc building simulator'), isNull);
  });
}
