import 'dart:math';

import 'package:pop_pop_win/src/game.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() {
  test('initial values', _testInitial);
  test('setFlag', _testSetFlag);
  test('cannot reveal flagged', _testCannotRevealFlagged);
  test('cannot flag revealed', _testCannotFlagRevealed);
  test('reveal zero', _testRevealZero);
  test('loss', _testLoss);
  test('win', _testWin);
  test('random winner', _testRandomField);
  test('good chord', _testGoodChord);
  test('bad chord', _testBadChord);
  test('no-op chord', _testNoopChord);
  test('canReveal', _testCanReveal);
  test('canFlag', _testCanFlag);
  test('cannot re-reveal', _testCannotReReveal);
}

void _testCannotReReveal() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.canReveal(5, 3), isTrue);
  g
    ..reveal(5, 3)
    ..setFlag(4, 2, true);

  expect(g.canReveal(5, 3), isTrue);
  g.reveal(5, 3);

  expect(g.canReveal(5, 3), isFalse);
}

void _testCanFlag() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.canToggleFlag(0, 0), isTrue);
  expect(g.state, GameState.reset);
  g.setFlag(0, 0, true);
  expect(g.state, GameState.started);
  expect(g.canToggleFlag(0, 0), isTrue);
  g.setFlag(0, 0, false);
  expect(g.canToggleFlag(0, 0), isTrue);

  expect(g.canToggleFlag(5, 4), isTrue);
  g.reveal(5, 4);
  expect(g.canToggleFlag(5, 4), isFalse);
}

void _testCanReveal() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.canReveal(0, 0), isTrue);
  expect(g.state, GameState.reset);
  g.setFlag(0, 0, true);
  expect(g.state, GameState.started);
  expect(g.canReveal(0, 0), isFalse);

  expect(g.canReveal(5, 4), isTrue);
  g.reveal(5, 4);
  expect(g.canReveal(5, 4), isFalse);

  g.setFlag(4, 2, true);
  expect(g.canReveal(5, 3), isTrue);
  expect(g.canReveal(4, 3), isFalse);
  g.setFlag(3, 2, true);
  expect(g.canReveal(4, 3), isTrue);

  // now we'll over flag
  expect(g.canReveal(5, 3), isTrue);
  g.setFlag(5, 2, true);
  expect(g.canReveal(5, 3), isFalse);
}

void _testBadChord() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.bombsLeft, equals(13));
  final startReveals = f.length - 13;
  expect(g.revealsLeft, equals(startReveals));
  expect(g.state, equals(GameState.reset));

  g
    ..reveal(2, 3)
    ..setFlag(1, 2, true)
    ..setFlag(3, 2, true);

  expect(g.bombsLeft, equals(11));
  expect(g.revealsLeft, equals(startReveals - 1));

  final revealed = g.reveal(2, 3);
  expect(revealed, isNull);
  expect(g.state, equals(GameState.lost));
}

// Adjacent flag count != square count
// so nothing happens
void _testNoopChord() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.bombsLeft, equals(13));
  final startReveals = f.length - 13;
  expect(g.revealsLeft, equals(startReveals));
  expect(g.state, equals(GameState.reset));

  final revealed = g.reveal(2, 3);
  expect(revealed, unorderedEquals([const Point(2, 3)]));

  g.setFlag(2, 2, true);

  expect(g.bombsLeft, equals(12));
  expect(g.revealsLeft, equals(startReveals - 1));

  expect(() => g.reveal(2, 3), throwsAssertionError);
}

void _testGoodChord() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.bombsLeft, equals(13));
  final startReveals = f.length - 13;
  expect(g.revealsLeft, equals(startReveals));
  expect(g.state, equals(GameState.reset));

  g
    ..reveal(2, 3)
    ..setFlag(2, 2, true)
    ..setFlag(3, 2, true);

  expect(g.bombsLeft, equals(11));
  expect(g.revealsLeft, equals(startReveals - 1));

  g.reveal(2, 3);
  expect(g.bombsLeft, equals(11));
  expect(g.revealsLeft, equals(startReveals - 11));
  expect(g.duration, isNot(isNull));
}

// Test 5 random fields five times
void _testRandomField() {
  final rnd = Random();
  for (var i = 0; i < 5; i++) {
    final f = Field();

    for (var j = 0; j < 5; j++) {
      final g = Game(f);
      while (g.revealsLeft > 0) {
        final x = rnd.nextInt(f.width);
        final y = rnd.nextInt(f.height);
        if (g.getSquareState(x, y) == SquareState.hidden) {
          if (f.get(x, y)) {
            g.setFlag(x, y, true);
          } else if (!f.get(x, y)) {
            g.reveal(x, y);
          }
        }
      }
      expect(g.state == GameState.won, isTrue);
    }
  }
}

void _testRevealZero() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.bombsLeft, equals(13));
  final startReveals = f.length - 13;
  expect(g.revealsLeft, equals(startReveals));
  expect(g.state, equals(GameState.reset));

  g.reveal(5, 4);
  expect(g.revealsLeft, equals(startReveals - 10));
}

void _testInitial() {
  final f = getSampleField();
  final g = Game(f);

  expect(g.bombsLeft, equals(13));
  expect(g.revealsLeft, equals(f.length - 13));
  expect(g.state, equals(GameState.reset));
  expect(g.duration, isNull);

  for (var x = 0; x < f.width; x++) {
    for (var y = 0; y < f.height; y++) {
      expect(g.getSquareState(x, y), equals(SquareState.hidden));
    }
  }
}

void _testSetFlag() {
  final g = Game(getSampleField());

  expect(g.getSquareState(0, 0), equals(SquareState.hidden));
  g.setFlag(0, 0, true);
  expect(g.getSquareState(0, 0), equals(SquareState.flagged));
  expect(g.bombsLeft, equals(12));
  expect(g.state, equals(GameState.started));
}

void _testCannotRevealFlagged() {
  final g = Game(getSampleField());

  expect(g.getSquareState(0, 0), equals(SquareState.hidden));
  g.setFlag(0, 0, true);
  expect(g.getSquareState(0, 0), equals(SquareState.flagged));
  expect(g.bombsLeft, equals(12));
  expect(g.state, equals(GameState.started));

  expect(() => g.reveal(0, 0), throwsAssertionError);
}

void _testCannotFlagRevealed() {
  final g = Game(getSampleField());

  expect(g.getSquareState(1, 1), equals(SquareState.hidden));
  g.reveal(1, 1);
  expect(g.getSquareState(1, 1), equals(SquareState.revealed));
  expect(g.state, equals(GameState.started));

  expect(() => g.setFlag(1, 1, true), throwsAssertionError);
}

void _testLoss() {
  final g = Game(getSampleField());

  expect(g.getSquareState(0, 0), equals(SquareState.hidden));
  final revealed = g.reveal(0, 0);
  expect(revealed, isNull);
  expect(g.state, equals(GameState.lost));
  expect(g.getSquareState(0, 0), equals(SquareState.bomb));
}

void _testWin() {
  final f = getSampleField();
  final g = Game(f);

  var bombsLeft = f.bombCount;
  expect(g.revealsLeft, equals(f.length - 13));
  var revealsLeft = g.revealsLeft;
  for (var x = 0; x < f.width; x++) {
    for (var y = 0; y < f.height; y++) {
      if (f.get(x, y)) {
        g.setFlag(x, y, true);
        bombsLeft--;
        expect(g.bombsLeft, equals(bombsLeft));
      } else if (g.getSquareState(x, y) == SquareState.hidden) {
        revealsLeft -= g.reveal(x, y)!.length;
        expect(revealsLeft, equals(g.revealsLeft));
      } else {
        expect(g.getSquareState(x, y), equals(SquareState.revealed));
      }
      expect(g.state, isNot(equals(GameState.reset)));
      expect(g.state, isNot(equals(GameState.lost)));
    }
  }

  expect(g.state, equals(GameState.won));
}
