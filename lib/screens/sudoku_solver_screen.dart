import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SudokuSolverScreen extends StatefulWidget {
  const SudokuSolverScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SudokuSolverScreenState();
  }
}

class _SudokuSolverScreenState extends State<SudokuSolverScreen> {
  List<List<String>> grid =
      List.generate(9, (i) => List.generate(9, (j) => '.'));

  List<List<TextEditingController>> controllers =
      List.generate(9, (i) => List.generate(9, (j) => TextEditingController()));

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  bool isSafe(List<List<String>> board, int row, int col, int number) {
    String numStr = number.toString();

    // Check if the number is present in the current row or column
    for (int i = 0; i < board.length; i++) {
      if (board[i][col] == numStr || board[row][i] == numStr) {
        return false;
      }
    }

    // Calculate the starting row and column for the 3x3 sub-grid
    int sr = (row ~/ 3) * 3;
    int sc = (col ~/ 3) * 3;

    // Check if the number is present in the 3x3 sub-grid
    for (int i = sr; i < sr + 3; i++) {
      for (int j = sc; j < sc + 3; j++) {
        if (board[i][j] == numStr) {
          return false;
        }
      }
    }

    return true;
  }

  bool helper(List<List<String>> board, int row, int col) {
    if (row == board.length) {
      return true;
    }

    int nrow = 0;
    int ncol = 0;

    if (col != board.length - 1) {
      nrow = row;
      ncol = col + 1;
    } else {
      nrow = row + 1;
      ncol = 0;
    }

    if (board[row][col] != '.') {
      return helper(board, nrow, ncol);
    } else {
      for (int i = 1; i <= 9; i++) {
        if (isSafe(board, row, col, i)) {
          board[row][col] = i.toString();
          if (helper(board, nrow, ncol)) {
            return true;
          } else {
            board[row][col] = '.';
          }
        }
      }
    }

    return false;
  }

  bool isValidSudoku(List<List<String>> grid) {
    // Function to check if a list of values contains duplicates.
    bool containsDuplicate(List<String> values) {
      Set<String> seen = {};
      for (String value in values) {
        if (value != '.' && seen.contains(value)) {
          return true;
        }
        seen.add(value);
      }
      return false;
    }

    // Check rows for duplicates.
    for (int i = 0; i < 9; i++) {
      if (containsDuplicate(grid[i])) {
        return false;
      }
    }

    // Check columns for duplicates.
    for (int j = 0; j < 9; j++) {
      List<String> column = [];
      for (int i = 0; i < 9; i++) {
        column.add(grid[i][j]);
      }
      if (containsDuplicate(column)) {
        return false;
      }
    }

    // Check 3x3 subgrids for duplicates.
    for (int i = 0; i < 9; i += 3) {
      for (int j = 0; j < 9; j += 3) {
        List<String> subgrid = [];
        for (int k = 0; k < 3; k++) {
          for (int l = 0; l < 3; l++) {
            subgrid.add(grid[i + k][j + l]);
          }
        }
        if (containsDuplicate(subgrid)) {
          return false;
        }
      }
    }

    // If all checks pass, the grid is valid.
    return true;
  }

  void solveSudoku(List<List<String>> board) {
    if (!isValidSudoku(grid)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid input'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    helper(board, 0, 0);

    setState(() {
      // Update the TextEditingController with the solved grid values
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          controllers[i][j].text = grid[i][j] == '.' ? '' : grid[i][j];
        }
      }
    });
  }

  void resetGrid() {
    setState(() {
      grid = List.generate(9, (i) => List.generate(9, (j) => '.'));
      // Update the TextEditingController with empty text
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          controllers[i][j].text = '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku Solver')),
      body: Stack(
        children: [
          // Background animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/back4.json',
              fit: BoxFit.cover,
            ),
          ),
          // Sudoku grid and buttons
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          controller: controllers[row][col],
                          style: TextStyle(
                            fontSize: 24, // Adjust the font size here
                            color: Colors.black, // Adjust text color if needed
                          ),
                          cursorColor:
                              Colors.black, // Adjust cursor color if needed
                          onChanged: (value) {
                            setState(() {
                              grid[row][col] = value.isEmpty ? '.' : value;
                            });
                          },
                          decoration: const InputDecoration(
                            counterText: '', // Hide max length counter
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0), // Adjust padding
                          ),
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      solveSudoku(grid);
                    },
                    child: const Text('Solve'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      resetGrid();
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
