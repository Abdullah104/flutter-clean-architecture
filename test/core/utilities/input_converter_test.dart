import 'package:clean_architecture/core/error/failures/invalid_input_failure.dart';
import 'package:clean_architecture/core/utilities/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () {
        // Arrange
        const str = '123';

        // Act
        final result = inputConverter.stringToUnsignedInteger(str);

        // Assert
        expect(result, equals(const Right(123)));
      },
    );

    test('should return a failure when the string is not an integer', () {
      // Arrange
      const str = 'abc';

      // Act
      final result = inputConverter.stringToUnsignedInteger(str);

      // Assert
      expect(result, equals(Left(InvalidInputFailure())));
    });

    test('should return a failure when the string is a negative integer', () {
      // Arrange
      const str = '-123';

      // Act
      final result = inputConverter.stringToUnsignedInteger(str);

      // Assert
      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}
