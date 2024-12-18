import 'dart:io';
import 'dart:math';
import 'dart:convert';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
}

class Ship {
  int size;
  List<Point> coordinates = [];
  bool isSunk = false;

  Ship(this.size);
}

List<Ship> placeShips(List<List<int>> board, int numShips, int minSize, int maxSize) {
  List<Ship> ships = [];
  Random random = Random();

  for (int i = 0; i < numShips; i++) {
    int size = minSize + random.nextInt(maxSize - minSize + 1);
    bool placed = false;
    Ship ship = Ship(size);
    while (!placed) {
      int x = random.nextInt(10);
      int y = random.nextInt(10);
      bool horizontal = random.nextBool();
      ship.coordinates = [];
      bool canPlace = true;

      for (int j = 0; j < size; j++) {
        int curX = x + (horizontal ? j : 0);
        int curY = y + (!horizontal ? j : 0);
        if (curX < 0 || curX >= 10 || curY < 0 || curY >= 10 || board[curY][curX] != 0) {
          canPlace = false;
          break;
        }
      }

      if (canPlace) {
        for (int j = 0; j < size; j++) {
          int curX = x + (horizontal ? j : 0);
          int curY = y + (!horizontal ? j : 0);
          board[curY][curX] = 1;
          ship.coordinates.add(Point(curX, curY));
        }
        placed = true;
        ships.add(ship);
      }
    }
  }
  return ships;
}

void printBoard(List<List<int>> board) {
  stdout.write('  ');
  for (int i = 0; i < 10; i++) {
    stdout.write('${i + 1} ');
  }
  stdout.writeln();

  for (int i = 0; i < 10; i++) {
    stdout.write('${i + 1} ');
    for (int j = 0; j < 10; j++) {
      String cell;
      if (board[i][j] == 0) {
        cell = '. ';
      } else if (board[i][j] == 1) {
        cell = 'S ';
      } else if (board[i][j] == 2) {
        cell = 'X ';
      } else {
        cell = 'O ';
      }
      stdout.write(cell);
    }
    stdout.writeln();
  }
  stdout.writeln();
}

bool isShipSunk(List<List<int>> board, Ship ship) {
  for (var coord in ship.coordinates) {
    if (board[coord.y][coord.x] != 2) {
      return false;
    }
  }
  return true;
}

bool hasShips(List<List<int>> board) {
  for (var row in board) {
    if (row.contains(1)) {
      return true;
    }
  }
  return false;
}

void playerTurn(List<List<int>> playerBoard, List<List<int>> computerBoard, List<List<int>> computerBoardView, List<Ship> computerShips) {
  print("\nВаше поле:");
  printBoard(playerBoard);
  print("Поле компьютера:");
  printBoard(computerBoardView);

  stdout.write('Введите координаты (x y): ');
  String input = stdin.readLineSync()!;
  try {
    List<String> coordsStr = input.split(' ');
    if (coordsStr.length != 2) {
      print("Неверный ввод. Введите координаты в формате 'x y'.");
      return;
    }
    int x = int.parse(coordsStr[0]) - 1;
    int y = int.parse(coordsStr[1]) - 1;

    if (x < 0 || x > 9 || y < 0 || y > 9) {
      print("Неверные координаты. Введите числа от 1 до 10.");
      return;
    }

    if (computerBoard[y][x] == 1) {
      computerBoard[y][x] = 2;
      computerBoardView[y][x] = 2;
      for (var ship in computerShips) {
        if (ship.coordinates.contains(Point(x, y)) && isShipSunk(computerBoard, ship)) {
          ship.isSunk = true;
          print("Корабль потоплен!");
        }
      }
    } else if (computerBoard[y][x] == 0) {
      computerBoard[y][x] = 3;
      computerBoardView[y][x] = 3;
    }
  } on FormatException {
    print("Неверный ввод. Введите только числа.");
  } catch (e) {
    print("Произошла непредвиденная ошибка: $e");
  }
}

void computerTurn(List<List<int>> playerBoard, List<Ship> playerShips) {
  Random random = Random();
  int x, y;
  do {
    x = random.nextInt(10);
    y = random.nextInt(10);
  } while (playerBoard[y][x] != 0 && playerBoard[y][x] != 1);

  if (playerBoard[y][x] == 1) {
    playerBoard[y][x] = 2;
    for (var ship in playerShips) {
      if (ship.coordinates.contains(Point(x, y)) && isShipSunk(playerBoard, ship)) {
        ship.isSunk = true;
        print("Компьютер потопил ваш корабль!");
      }
    }
  } else {
    playerBoard[y][x] = 3;
  }
}

void saveGameResults(List<List<int>> playerBoard, List<List<int>> computerBoard) {
  String filePath = 'ShipFight/ShipFightResults.txt';
  try {
    final results = {
      'playerBoard': jsonEncode(playerBoard),
      'computerBoard': jsonEncode(computerBoard)
    };

    final file = File(filePath);
    file.writeAsString(jsonEncode(results), mode: FileMode.write);

    print('Результаты игры сохранены в файл $filePath');
  } catch (e) {
    print('Ошибка при сохранении результатов: $e');
  }
}

void main() {
  List<List<int>> playerBoard = List.generate(10, (_) => List.filled(10, 0));
  List<List<int>> computerBoard = List.generate(10, (_) => List.filled(10, 0));
  List<List<int>> computerBoardView = List.generate(10, (_) => List.filled(10, 0));

  List<Ship> playerShips = placeShips(playerBoard, 5, 1, 4);
  List<Ship> computerShips = placeShips(computerBoard, 5, 1, 4);

    bool _playerTurn = true;
    while (true) {
         bool playerHasShips = hasShips(playerBoard);
         bool computerHasShips = hasShips(computerBoard);

         if (!playerHasShips) {
              print("Компьютер победил! Все ваши корабли потоплены.");
              saveGameResults(playerBoard, computerBoard);
              break;
         }

         if(!computerHasShips) {
            print("Вы победили! Все корабли компьютера потоплены.");
              saveGameResults(playerBoard, computerBoard);
              break;
          }

         if (_playerTurn) {
            playerTurn(playerBoard, computerBoard, computerBoardView, computerShips);
        } else {
            computerTurn(playerBoard, playerShips);
        }
        
        bool playerWon = computerShips.every((ship) => ship.isSunk);
        bool computerWon = playerShips.every((ship) => ship.isSunk);

      if (playerWon) {
        print("Вы победили!");
          saveGameResults(playerBoard, computerBoard);
         break;
      }

      if (computerWon) {
        print("Компьютер победил!");
          saveGameResults(playerBoard, computerBoard);
        break;
      }
        
     _playerTurn = !_playerTurn;
    }
}